/****************************************************************************************
  * @filename       : i2SEMA_AutomaticNotification_tr
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-17 오후 12:37
  * @group          : 
  * @group-content  : 
  * @description    : Notification 자동 발신
  * @tester         : i2SEMA_AutomaticNotification_tr_Test.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-17 오후 12:37     i2max_byeon.jw       Create
****************************************************************************************/

public without sharing class i2SEMA_AutomaticNotification_tr extends i2SEMA_TriggerHandler{
    /*---------------------------------------------------------
    - CONSTANT
    ---------------------------------------------------------*/
    private final static Integer executeLimit;
    /*---------------------------------------------------------
    - STATIC VARIABLE
    ---------------------------------------------------------*/
    private static Map<Id,SObject> newDataMap;                              // Trigger Data
    private static Map<Id,SObject> oldDataMap;                              // Trigger Data
    private static List<NotificationAutomaticSetting__c> validSettings;      // 유효한 Event Setting
    private static List<NotificationAutomaticSetting__c> invalidSettings;    // 유효하지 않은 Event Setting
    private static Map<String,String> extractedObjectKeyAPIs;               // 자동화 규칙이 조회된 Object 목록 (K: ID Prefix 3자리, V: Object API)

    /**
     * @description 트랜잭션 초기설정
     */
    static {
        /*---------------------------------------------------------
        - 자동화 처리 제한건수
       ---------------------------------------------------------*/
        executeLimit            = getEventExecuteLimit();
        /*---------------------------------------------------------
        - 트랜잭션 내 조회 & 유효검사 진행한 Object API 집합
        ---------------------------------------------------------*/
        extractedObjectKeyAPIs  = new Map<String,String>();
        /*---------------------------------------------------------
        - 유효한 & 유효하지 않은 자동화 조건목록
        ---------------------------------------------------------*/
        validSettings           = new List<NotificationAutomaticSetting__c>();
        invalidSettings         = new List<NotificationAutomaticSetting__c>();
    }

    public override void afterInsert(){ this.execute(); }
    public override void afterUpdate(){ this.execute(); }

    /**
     * @description 발신자동화 수행
     */
    private void execute(){
        // Trigger 외부 호출 제한
        if(!(Trigger.isExecuting && (Trigger.isInsert||Trigger.isUpdate))){
            return;
        }
        // 처리건수 제한
        if( (Trigger.new != null && Trigger.new.size() > executeLimit) || (Trigger.old != null && Trigger.old.size() > executeLimit)){
            return;
        }

        this.getNotificationSettings();
        this.compareFieldCondition();
    }
    /**
     * @description 자동화규칙 조회
     *  트랜잭션 내에서 Object 별 조회는 1회만 수행
     */
    private void getNotificationSettings(){
        System.debug('[i2SEMA_AutomaticNotification_tr] - 자동규칙 조회 시작');

        // Trigger Object 타입 추출
        newDataMap = Trigger.newMap != null ? Trigger.newMap : new Map<Id,SObject>();
        oldDataMap = Trigger.oldMap != null ? Trigger.oldMap : new Map<Id,SObject>();

        Map<String,String> objectKeyAPIs = new Map<String,String>();

        if( Trigger.isInsert || Trigger.isUpdate ){
            for( Id recordId : newDataMap.keySet()){
                if(!objectKeyAPIs.containsKey(String.valueOf(recordId).left(3))){
                    objectKeyAPIs.put(String.valueOf(recordId).left(3) , recordId.getSobjectType().getDescribe().getName());
                }
            }
        }
        system.debug('[i2SEMA_AutomaticNotification_tr] - Object : ' + objectKeyAPIs);

        // 조회된적 없는 Object 타입에 대해 자동화조건 조회
        if( !extractedObjectKeyAPIs.keySet().containsAll(objectKeyAPIs.keySet()) ){
            objectKeyAPIs.keySet().removeAll(extractedObjectKeyAPIs.keySet());
            List<String> targetAPIs = objectKeyAPIs.values();

            String queryString = 'SELECT ID '
                    + ' ,IsActive__c'
                    + ' ,IsSchedule__c'
                    + ' ,ScheduleBasedOn__c'
                    + ' ,FieldForSchedule__c'
                    + ' ,ScheduleTime__c'
                    + ' ,ObjectType__c'
                    + ' ,ExecuteOn__c'
                    + ' ,RecipientField__c'
                    + ' ,NotificationTemplate__c'
                    + ' ,NotificationTemplate__r.Channel__c'
                    + ' ,NotificationTemplate__r.Title__c'
                    + ' ,NotificationTemplate__r.Content__c'
                    + ' ,NotificationTemplate__r.LABEL1__c'
                    + ' ,NotificationTemplate__r.LABEL2__c'
                    + ' ,NotificationTemplate__r.LABEL3__c'
                    + ' ,NotificationTemplate__r.LABEL4__c'
                    + ' ,NotificationTemplate__r.LABEL5__c'
                    + ' ,Label1FieldAPI__c'
                    + ' ,Label2FieldAPI__c'
                    + ' ,Label3FieldAPI__c'
                    + ' ,Label4FieldAPI__c'
                    + ' ,Label5FieldAPI__c'
                    + ' ,LogicalExpression__c'
                    + ' ,(SELECT ID'
                    + '        ,NotificationAutomaticSetting__c'
                    + '        ,Alias__c'
                    + '        ,fm_ObjectType__c'
                    + '        ,Field__c'
                    + '        ,FieldType__c'
                    + '        ,ReferenceType__c'
                    + '        ,Operator__c'
                    + '        ,CompareWith__c'
                    + '        ,CompareField__c'
                    + '         ,BOOLEAN__c'
                    + '         ,CURRENCY__c'
                    + '         ,DATETIME__c'
                    + '         ,DATE__c'
                    + '         ,TIME__c'
                    + '         ,EMAIL__c'
                    + '         ,DOUBLE__c'
                    + '         ,LONG__c'
                    + '         ,INTEGER__c'
                    + '         ,PERCENT__c'
                    + '         ,PHONE__c'
                    + '         ,REFERENCE__c'
                    + '         ,PICKLIST__c'
                    + '         ,STRING__c'
                    + '    FROM NotificationAutomaticConditions__r )'
                    + ' FROM NotificationAutomaticSetting__c'
                    + ' WHERE IsActive__c = TRUE'
                    + ' AND ObjectType__c IN:targetAPIs';

            List<NotificationAutomaticSetting__c> candidateSettings = (List<NotificationAutomaticSetting__c>)Database.query(queryString);

            // 자동발신 조건의 유효여부 확인
            validSettings   = validSettings != null ? validSettings : new List<NotificationAutomaticSetting__c>();
            invalidSettings = invalidSettings != null ? invalidSettings : new List<NotificationAutomaticSetting__c>();

            List<i2SEMA_AutomaticSettingValidation.ValidationResult> results = i2SEMA_AutomaticSettingValidation.check(candidateSettings);

            for( Integer idx=0; idx<results.size();idx++ ){
                if( results[idx].isValid ){
                    validSettings.add(candidateSettings[idx]);
                }else{
                    system.debug('[i2SEMA_AutomaticNotification_tr] - 유효하지 않은 자동화 사유 : ' + results[idx].errorMessage);
                    invalidSettings.add(candidateSettings[idx]);
                }
            }
            /*---------------------------------------------------------
            - 자동화 규칙 조회된 Object 타입 추가
            ---------------------------------------------------------*/
            for( String objectKey : objectKeyAPIs.keySet()){
                String objectAPI = objectKeyAPIs.get(objectKey);
                extractedObjectKeyAPIs.put(objectKey,objectAPI);
            }
        }
        System.debug('[i2SEMA_AutomaticNotification_tr] - 유효한 규칙 선별 종료 ( 정상적인 자동화 건수 :'+ validSettings.size() + ' 건 )' );
        System.debug(validSettings);
        System.debug('[i2SEMA_AutomaticNotification_tr] - 유효하지않은 규칙 선별 종료 ( 비정상적인 자동화 건수 : '+ invalidSettings.size() + ' 건 )' );
        System.debug(invalidSettings);
    }
    /**
     * @description 발신조건 비교
     *  - 필드 조건이 없는경우, 발신대상으로 판정
     *  - 필드 조건이 있는경우, 개별 필드에 대해 정의된 비교 수행
     */
    private void compareFieldCondition(){
        if(validSettings.isEmpty()) return;

        // Record 별 자동화규칙의 필드조건 결과값
        Map<SObject,Map<NotificationAutomaticSetting__c,Map<String,Boolean>>> recordEventSettingAliasResults = new Map<SObject,Map<NotificationAutomaticSetting__c,Map<String,Boolean>>>();

        /*---------------------------------------------------------
        - 유효한 자동화 규칙과 후보 레코드 선별
        ---------------------------------------------------------*/
        List<SObject> candidateRecords  = (Trigger.isInsert || Trigger.isUpdate) ? newDataMap.values() : oldDataMap.values();

        System.debug('[i2SEMA_AutomaticNotification_tr] - 전체 레코드 건수 : ' + candidateRecords.size() + '건');

        // Loop 1 : 레코드 (트리거 레코드 전체 대상)
        for( SObject candidateRecord : candidateRecords ){
            // Object Type
            String recordId     = candidateRecord.get('Id') != null ? (String)candidateRecord.get('Id') : null;
            String objectType   = recordId != null ? extractedObjectKeyAPIs.get(String.valueOf(recordId).left(3)) : candidateRecord.getSObjectType().getDescribe().getName();

            // Loop 2 : 자동화규칙 (유효한 자동화규칙 대상 )
            for( NotificationAutomaticSetting__c setting : validSettings ){
                // Object 타입이 다르거나, Execute Context 가 다를경우 continue
                if( setting.ObjectType__c != objectType || (Trigger.isInsert && setting.ExecuteOn__c == 'Update') || (Trigger.isUpdate && setting.ExecuteOn__c == 'Insert') ){
                    continue;
                }
                Map<String,Boolean> aliasResultMap  = new Map<String,Boolean>();
                Boolean conditionDefect             = false;

                // Loop 3 : 개별 필드조건 True,False 비교
                for( NotificationAutomaticCondition__c fieldCondition : setting.NotificationAutomaticConditions__r ){
                    String operator     = fieldCondition.Operator__c;
                    String compareWith  = fieldCondition.CompareWith__c;
                    Object fieldValue   = candidateRecord.get(fieldCondition.Field__c);
                    String fieldType    = fieldCondition.FieldType__c;

                    Boolean conditionResult;

                    // 단순 변경
                    if('Any Change'.equalsIgnoreCase(operator)){
                        if( Trigger.isInsert ){
                            conditionResult = true;
                            conditionDefect = false;
                        }
                        if(Trigger.isUpdate){
                            SObject oldrecord   = oldDataMap.get(candidateRecord.Id);
                            Object compareValue = oldrecord.get(fieldCondition.Field__c);

                            conditionResult = this.getConditionResult(fieldValue,compareValue,fieldType,operator);
                            conditionDefect = conditionResult == null;
                        }
                    }
                    // 필드값을 조건값과 비교
                    else if('it-self'.equalsIgnoreCase(compareWith)){
                        String fieldName = getTypeSaveAs().get(fieldType);
                        Object compareValue = fieldCondition.get('' + fieldName + '__c');

                        conditionResult = this.getConditionResult(fieldValue,compareValue,fieldType,operator);
                        conditionDefect = conditionResult == null;
                    }
                    // 다른 필드와 비교
                    else if('other field'.equalsIgnoreCase(compareWith)){
                        Object compareFieldValue = candidateRecord.get(fieldCondition.CompareField__c);

                        conditionResult = this.getConditionResult(fieldValue, compareFieldValue, fieldType, operator);
                        conditionDefect = conditionResult == null;
                    }

                    // Loop 3 Break
                    if( conditionDefect ){
                        system.debug('[i2SEMA_AutomaticNotification_tr] Loop3 Break');
                        break;
                    }
                    // 결과값 처리
                    aliasResultMap.put(fieldCondition.Alias__c , conditionResult);
                }
                // Loop 2 Break
                if( conditionDefect ){
                    system.debug('[i2SEMA_AutomaticNotification_tr] Loop2 Break');
                    break;
                }
                // 정상 처리된 자동화 규칙을 Record 별로 분류
                Map<NotificationAutomaticSetting__c,Map<String,Boolean>> eventAliasResult = recordEventSettingAliasResults.containsKey(candidateRecord)
                        ? recordEventSettingAliasResults.get(candidateRecord)
                        : new Map<NotificationAutomaticSetting__c,Map<String,Boolean>>();

                eventAliasResult.put( setting , aliasResultMap );                           // 현재 자동화 규칙의 Alias 별 결과
                recordEventSettingAliasResults.put( candidateRecord , eventAliasResult );   // 현재 레코드의 자동화 규칙 판단 결과
            }
        }

        System.debug('[i2SEMA_AutomaticNotification_tr] - 정상 필드확인된 레코드 건수 : ' + recordEventSettingAliasResults.keySet().size() + '건');
        System.debug(recordEventSettingAliasResults);

        // 자동발송 판정 및 Notification 생성
        System.enqueueJob(new i2SEMA_AutoNotificationEvaluation_qu(recordEventSettingAliasResults));
    }
    /**
     * @description 조건 일치여부 확인
     */
    public Boolean getConditionResult(Object value1,Object value2, String typeString, String operator){
        system.debug('[i2SEMA_AutomaticNotification_tr] 필드값 비교 : ' + value1 + ' / ' + value2 + ' / ' + typeString + ' / ' + operator);

        if( i2SEMA_Util.isEmpty(typeString) || i2SEMA_Util.isEmpty(operator)){
            return null;
        }

        // Field Type
        Boolean isBooleanType   = typeString.equalsIgnoreCase(Schema.DisplayType.BOOLEAN.name());
        Boolean isDecimalType   = typeString.equalsIgnoreCase(Schema.DisplayType.CURRENCY.name()) || typeString.equalsIgnoreCase(Schema.DisplayType.DOUBLE.name()) || typeString.equalsIgnoreCase(Schema.DisplayType.LONG.name())
                                    || typeString.equalsIgnoreCase(Schema.DisplayType.INTEGER.name()) || typeString.equalsIgnoreCase(Schema.DisplayType.PERCENT.name());
        Boolean isDateTimeType  = typeString.equalsIgnoreCase(Schema.DisplayType.DATETIME.name());
        Boolean isDateType      = typeString.equalsIgnoreCase(Schema.DisplayType.DATE.name());
        Boolean isTimeType      = typeString.equalsIgnoreCase(Schema.DisplayType.TIME.name());
        Boolean isIDType        = typeString.equalsIgnoreCase(Schema.DisplayType.REFERENCE.name());
        Boolean isStringType    = typeString.equalsIgnoreCase(Schema.DisplayType.EMAIL.name()) || typeString.equalsIgnoreCase(Schema.DisplayType.PHONE.name())
                                    || typeString.equalsIgnoreCase(Schema.DisplayType.PICKLIST.name()) || typeString.equalsIgnoreCase(Schema.DisplayType.STRING.name());


        // Field Value
        Boolean     val1_BOO = isBooleanType ? (Boolean)value1 : null   , val2_BOO = isBooleanType ? (Boolean)value2 : null;
        Decimal     val1_DCM = isDecimalType ? (Decimal)value1 : null   , val2_DCM = isDecimalType ? (Decimal)value2 : null;
        Datetime    val1_DTM = isDateTimeType ? (Datetime)value1 : null , val2_DTM = isDateTimeType ? (Datetime)value2 : null;
        Date        val1_DTE = isDateType ? (Date)value1 : null         , val2_DTE = isDateType ? (Date)value2 : null;
        Time        val1_TME = isTimeType ? (Time)value1 : null         , val2_TME = isTimeType ? (Time)value2 : null;
        Id          val1_REF = isIDType ? (Id)value1 : null             , val2_REF = isIDType ? (Id)value2 : null;
        String      val1_STR = isStringType ? (String)value1 : null     , val2_STR = isStringType ? (String)value2 : null;


        /*---------------------------------------------------------
        - Operator : Argument 가 null 이 되면 Error => return null
        ---------------------------------------------------------*/
        try{
            switch on operator {
                // 각 항목 초기값 null 이므로, 입력된 항목만 비교.
                when 'Any change'{
                    return ( isBooleanType && (val1_BOO != val2_BOO))
                            || ( isDecimalType && (val1_DCM != val2_DCM))
                            || ( isDateTimeType && (val1_DTM != val2_DTM))
                            || ( isDateType && (val1_DTE != val2_DTE))
                            || ( isTimeType && (val1_TME != val2_TME))
                            || ( isIDType && (val1_REF != val2_REF))
                            || ( isStringType && (val1_STR != val2_STR));
                }
                // 타입별 Equal 비교
                when 'Equals'{
                    return ( isBooleanType && (val1_BOO == val2_BOO))
                            || ( isDecimalType && (val1_DCM == val2_DCM))
                            || ( isDateTimeType && (val1_DTM == val2_DTM))
                            || ( isDateType && (val1_DTE == val2_DTE))
                            || ( isTimeType && (val1_TME == val2_TME))
                            || ( isIDType && (val1_REF == val2_REF))
                            || ( isStringType && (val1_STR == val2_STR));
                }
                // 타입별 Not Equal 비교
                when 'Not equal to'{
                    return ( isBooleanType && (val1_BOO != val2_BOO))
                            || ( isDecimalType && (val1_DCM != val2_DCM))
                            || ( isDateTimeType && (val1_DTM != val2_DTM))
                            || ( isDateType && (val1_DTE != val2_DTE))
                            || ( isTimeType && (val1_TME != val2_TME))
                            || ( isIDType && (val1_REF != val2_REF))
                            || ( isStringType && (val1_STR != val2_STR));
                }
                // String 타입의 value1.contains(value2) 처리. 그 외의 타입은 비교불가 > return null;
                when 'Contains'{
                    return isStringType ? val1_STR.contains(val2_STR) : null;
                }
                // String 타입의 !value1.contains(value2) 처리. 그 외의 타입은 비교불가 > return null;
                when 'Does not contain'{
                    return isStringType ? !val1_STR.contains(val2_STR) : null;
                }
                //  Decimal,Datetime,Date,Time,String 타입의 value1 > value2 비교. 그 외의 타입(Id,Boolean)은 비교불가 > return null;
                when 'Greater than'{
                    return isDecimalType    ? val1_DCM > val2_DCM
                        : isDateTimeType    ? val1_DTM > val2_DTM
                        : isDateType        ? val1_DTE > val2_DTE
                        : isTimeType        ? val1_TME > val2_TME
                        : isStringType      ? val1_STR > val2_STR
                        : null;
                }
                //  Decimal,Datetime,Date,Time,String 타입의 value1 >= value2 비교. 그 외의 타입(Id,Boolean)은 비교불가 > return null;
                when 'Greater than or Equal'{
                    return isDecimalType    ? val1_DCM >= val2_DCM
                        : isDateTimeType    ? val1_DTM >= val2_DTM
                        : isDateType        ? val1_DTE >= val2_DTE
                        : isTimeType        ? val1_TME >= val2_TME
                        : isStringType      ? val1_STR >= val2_STR
                        : null;
                }
                //  Decimal,Datetime,Date,Time,String 타입의 value1 < value2 비교. 그 외의 타입(Id,Boolean)은 비교불가 > return null;
                when 'Less than'{
                    return isDecimalType    ? val1_DCM < val2_DCM
                        : isDateTimeType    ? val1_DTM < val2_DTM
                        : isDateType        ? val1_DTE < val2_DTE
                        : isTimeType        ? val1_TME < val2_TME
                        : isStringType      ? val1_STR < val2_STR
                        : null;
                }
                //  String,Decimal,Date,Datetime 타입의 value1 <= value2 비교. 그 외의 타입은 비교불가 > return null;
                when 'Less than or Equal'{
                    return isDecimalType    ? val1_DCM <= val2_DCM
                        : isDateTimeType    ? val1_DTM <= val2_DTM
                        : isDateType        ? val1_DTE <= val2_DTE
                        : isTimeType        ? val1_TME <= val2_TME
                        : isStringType      ? val1_STR <= val2_STR
                        : null;
                }
                // Null 비교. String 타입은 '' 인 경우 포함
                when 'Empty'{
                    return isBooleanType    ? val1_BOO == null
                        : isDecimalType     ? val1_DCM == null
                        : isDateTimeType    ? val1_DTM == null
                        : isDateType        ? val1_DTE == null
                        : isTimeType        ? val1_TME == null
                        : isIDType          ? val1_REF == null
                        : isStringType      ? i2SEMA_Util.isEmpty(val1_STR)
                        : null;
                }
                // Not Null 비교. String 타입은 '' 이 아닌경우 포함
                when 'Not empty'{
                    return isBooleanType    ? val1_BOO != null
                        : isDecimalType     ? val1_DCM != null
                        : isDateTimeType    ? val1_DTM != null
                        : isDateType        ? val1_DTE != null
                        : isTimeType        ? val1_TME != null
                        : isIDType          ? val1_REF != null
                        : isStringType      ? i2SEMA_Util.isNotEmpty(val1_STR)
                        : null;
                }
                // String 타입의 startWith() 처리, Argument 가 Null 이들어오는 경우 Exception > return null;
                when 'Start with'{
                    return isStringType ? val1_STR.startsWithIgnoreCase(val2_STR) : null;
                }
                // String 타입의 endWith() 처리, Argument 가 Null 이들어오는 경우 Exception > return null;
                when 'End with'{
                    return isStringType ? val1_STR.endsWithIgnoreCase(val2_STR) : null;
                }
            }
        }
        catch(Exception e){
            // Argument 값이 NULL 이 되어 Exception 이 발생하는 경우, NULL 리턴
            return null;
        }
        // 지원하지 않는 필드타입 값일경우 NULL 리턴
        return null;
    }
}