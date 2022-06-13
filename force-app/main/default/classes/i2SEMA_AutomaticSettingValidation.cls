/****************************************************************************************
  * @filename       : i2SEMA_AutomaticSettingValidation
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-17 오후 12:46
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : i2SEMA_AutomaticSettingValidation_Test.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-17 오후 12:46     i2max_byeon.jw       Create
****************************************************************************************/
public without sharing class i2SEMA_AutomaticSettingValidation {

    private static Map<String,SObjectType> globalDescribe;

    final static String NOT_FOUND           = Label.i2SEMA_MSG_AUTOMATIC_SETTING_NOT_FOUND;
    final static String FIELD_MISSING       = Label.i2SEMA_MSG_REQUIRED_FIELD_EMPTY;
    final static String OBJECT_INVALID      = Label.i2SEMA_MSG_OBJECT_API_INVALID;
    final static String RECIPIENT_INVALID   = Label.i2SEMA_MSG_RECEIVER_API_INVALID;
    final static String LABEL_INVALID       = Label.i2SEMA_MSG_TEMPLATE_FIELD_INVALID;
    final static String FIELD_INVALID       = Label.i2SEMA_MSG_FIELD_API_INVALID;
    final static String TYPE_INVALID        = Label.i2SEMA_MSG_FIELD_TYPE_INVALID;
    final static String REFERENCE_INVALID   = Label.i2SEMA_MSG_REFERENCE_TYPE_INVALID;

    static {
        globalDescribe = Schema.getGlobalDescribe();
    }

    /**
     * Notification Setting 유효확인
     *
     * @param ns {NotificationAutomaticSetting__c} Notification Setting
     * @return {ValidationResult} 유효 확인 결과
     */
    public static ValidationResult check(NotificationAutomaticSetting__c ns){
        if( ns == null ){
            return new ValidationResult().invalid(NOT_FOUND);
        }
        List<ValidationResult> validationResults = i2SEMA_AutomaticSettingValidation.check(new List<NotificationAutomaticSetting__c>{ns});
        if(!validationResults.isEmpty()){
            return validationResults[0];
        }
        return new ValidationResult().invalid(NOT_FOUND);
    }
    /**
     * Notification Setting 유효확인
     *
     * @param nsList {List<NotificationAutomaticSetting__c>} Notification Setting 목록
     * @return {ValidationResult} 각 인덱스의 유효 결과
     */
    public static List<ValidationResult> check(List<NotificationAutomaticSetting__c> nsList){
        System.debug('[i2SEMA_AutomaticSettingValidation] - 유효확인 시작');
        System.debug(nsList);

        List<ValidationResult> vrList = new List<ValidationResult>();
        /*---------------------------------------------------------
        - Setting 및 Field Condition 의 필수필드 확인
        ---------------------------------------------------------*/
        for( NotificationAutomaticSetting__c ns : nsList ){
            // 초기 유효상태. 하위 조건이 없는경우 하위 조건이 유효하다고 판단.
            Boolean settingFieldValid   = i2SEMA_Util.isNotEmpty(ns.ObjectType__c) && i2SEMA_Util.isNotEmpty(ns.ExecuteOn__c) && i2SEMA_Util.isNotEmpty(ns.RecipientField__c) && i2SEMA_Util.isNotEmpty(ns.NotificationTemplate__c)
                    && ( ns.NotificationTemplate__r.LABEL1__c == false || (ns.NotificationTemplate__r.LABEL1__c && i2SEMA_Util.isNotEmpty(ns.Label1FieldAPI__c)))
                    && ( ns.NotificationTemplate__r.LABEL2__c == false || (ns.NotificationTemplate__r.LABEL2__c && i2SEMA_Util.isNotEmpty(ns.Label2FieldAPI__c)))
                    && ( ns.NotificationTemplate__r.LABEL3__c == false || (ns.NotificationTemplate__r.LABEL3__c && i2SEMA_Util.isNotEmpty(ns.Label3FieldAPI__c)))
                    && ( ns.NotificationTemplate__r.LABEL4__c == false || (ns.NotificationTemplate__r.LABEL4__c && i2SEMA_Util.isNotEmpty(ns.Label4FieldAPI__c)))
                    && ( ns.NotificationTemplate__r.LABEL5__c == false || (ns.NotificationTemplate__r.LABEL5__c && i2SEMA_Util.isNotEmpty(ns.Label5FieldAPI__c)))
                    && ( ns.NotificationAutomaticConditions__r.isEmpty() || (!ns.NotificationAutomaticConditions__r.isEmpty() && i2SEMA_Util.isNotEmpty(ns.LogicalExpression__c)));
            Boolean conditionEmpty      = ns.NotificationAutomaticConditions__r.isEmpty();
            Boolean conditionAllValid   = !ns.NotificationAutomaticConditions__r.isEmpty();

            for( NotificationAutomaticCondition__c nfc : ns.NotificationAutomaticConditions__r ){
                if( !settingFieldValid ){
                    break;
                }

                conditionAllValid = conditionAllValid && (i2SEMA_Util.isNotEmpty(nfc.Alias__c) && i2SEMA_Util.isNotEmpty(nfc.Field__c) && i2SEMA_Util.isNotEmpty(nfc.FieldType__c) && i2SEMA_Util.isNotEmpty(nfc.Operator__c)
                        && ( 'Any Change'.equalsIgnoreCase(nfc.Operator__c)
                        || 'it-self'.equalsIgnoreCase(nfc.CompareWith__c)
                        || ( 'other field'.equalsIgnoreCase(nfc.CompareWith__c)  && i2SEMA_Util.isNotEmpty(nfc.CompareField__c))));
            }
            vrList.add( settingFieldValid && (conditionEmpty || conditionAllValid) ? new ValidationResult().valid() : new ValidationResult().invalid(FIELD_MISSING) );

            System.debug('[NOTI AUTO SEND VALIDATION] - 건별 유효확인(필수필드,하위조건)');
            System.debug('필수항목: ' + settingFieldValid + ' , 조건없음: '+ conditionEmpty + ' ,조건유효: ' + conditionAllValid);
            System.debug(vrList);
        }
        /*---------------------------------------------------------
        - Object API 확인
        ---------------------------------------------------------*/
        Set<String> validObjectAPIs = new Set<String>();
        for( Integer idx=0; idx < nsList.size(); idx++ ){
            NotificationAutomaticSetting__c ns   = nsList[idx];
            ValidationResult vr                             = vrList[idx];

            if( vr.isValid ){
                if( globalDescribe.containsKey(ns.ObjectType__c)){
                    validObjectAPIs.add(ns.ObjectType__c);
                }
                else{
                    vrList[idx] = vr.invalid(OBJECT_INVALID);
                }
            }
        }
        System.debug('[i2SEMA_AutomaticSettingValidation] - 건별 유효확인(오브젝트 API)');
        System.debug(vrList);
        /*---------------------------------------------------------
        - Field API & Type 유효확인
        ---------------------------------------------------------*/
        Map<String,Map<String,SObjectField>> objectFieldMap = new Map<String,Map<String,SObjectField>>();
        for( String objectAPI : validObjectAPIs ){
            objectFieldMap.put( objectAPI , globalDescribe.get(objectAPI).getDescribe().fields.getMap());
        }
        for( Integer idx=0; idx < nsList.size(); idx++ ){
            if( vrList[idx].isValid ){
                NotificationAutomaticSetting__c ns               = nsList[idx];
                List<NotificationAutomaticCondition__c> fcs      = ns.NotificationAutomaticConditions__r;
                Map<String,SObjectField> fieldMap       = objectFieldMap.get(ns.ObjectType__c);

                // Recipient Field 확인
                if( !fieldMap.containsKey(ns.RecipientField__c) || (!'REFERENCE'.equalsIgnoreCase(fieldMap.get(ns.RecipientField__c).getDescribe().getType().name()) && !'ID'.equalsIgnoreCase(fieldMap.get(ns.RecipientField__c).getDescribe().getType().name()))){
                    vrList[idx] = vrList[idx].invalid(RECIPIENT_INVALID);
                    continue;
                }

                // Template Label 확인 (Label 을 사용하지 않는 경우 True)
                Boolean label1Valid = i2SEMA_Util.isNotEmpty(ns.Label1FieldAPI__c) ? fieldMap.containsKey(ns.Label1FieldAPI__c) : true;
                Boolean label2Valid = i2SEMA_Util.isNotEmpty(ns.Label2FieldAPI__c) ? fieldMap.containsKey(ns.Label2FieldAPI__c) : true;
                Boolean label3Valid = i2SEMA_Util.isNotEmpty(ns.Label3FieldAPI__c) ? fieldMap.containsKey(ns.Label3FieldAPI__c) : true;
                Boolean label4Valid = i2SEMA_Util.isNotEmpty(ns.Label4FieldAPI__c) ? fieldMap.containsKey(ns.Label4FieldAPI__c) : true;
                Boolean label5Valid = i2SEMA_Util.isNotEmpty(ns.Label5FieldAPI__c) ? fieldMap.containsKey(ns.Label5FieldAPI__c) : true;

                if( !label1Valid || !label2Valid || !label3Valid || !label4Valid || !label5Valid ){
                    vrList[idx] = vrList[idx].invalid(LABEL_INVALID);
                    continue;
                }

                // Field Condition 확인
                for( NotificationAutomaticCondition__c fc : fcs ){
                    // 기준필드 API 및 Type 확인
                    SObjectField field = fieldMap.get(fc.Field__c);
                    if( field != null){
                        DescribeFieldResult fieldDesc   = field.getDescribe();
                        String fieldType                = fieldDesc.getType().name();
                        Boolean typeValidity            = fieldType == fc.FieldType__c;

                        if( typeValidity ){
                            // Reference 형태일 경우, 참조타입 추가확인
//                            if( fieldType == 'REFERENCE' ){
//                                Set<String> referenceTypes      = new Set<String>();
//                                for( SObjectType referenceType : fieldDesc.getReferenceTo()){
//                                    referenceTypes.add(referenceType.getDescribe().getName());
//                                }
//                                if(!referenceTypes.contains(fc.ReferenceType__c)){
//                                    vrList[idx] = vrList[idx].invalid(REFERENCE_INVALID);
//                                }
//                            }
                        }
                        else{
                            vrList[idx] = vrList[idx].invalid(TYPE_INVALID);
                            continue;
                        }
                    }else{
                        vrList[idx] = vrList[idx].invalid(FIELD_INVALID);
                        continue;
                    }
                    // 비교필드 API 및 Type 확인
                    if( fc.CompareField__c != null ){
                        SObjectField compareField = fieldMap.get(fc.CompareField__c);
                        if( compareField != null){
                            DescribeFieldResult fieldDesc   = compareField.getDescribe();
                            String fieldType                = fieldDesc.getType().name();
                            Boolean typeValidity            = fieldType == fc.FieldType__c;

                            if( typeValidity){
                                // Reference 형태일 경우, 참조타입 추가확인
//                                if( fieldType == 'REFERENCE' ){
//                                    Set<String> referenceTypes      = new Set<String>();
//                                    for( SObjectType referenceType : fieldDesc.getReferenceTo()){
//                                        referenceTypes.add(referenceType.getDescribe().getName());
//                                    }
//                                    if(!referenceTypes.contains(fc.ReferenceType__c)){
//                                        vrList[idx] = vrList[idx].invalid(REFERENCE_INVALID);
//                                    }
//                                }
                            }
                            else{
                                vrList[idx] = vrList[idx].invalid(TYPE_INVALID);
                                continue;
                            }
                        }
                        else{
                            vrList[idx] = vrList[idx].invalid(FIELD_INVALID);
                            continue;
                        }
                    }
                }
            }
            System.debug('[i2SEMA_AutomaticSettingValidation] - 건별 유효확인(하위 조건)');
            System.debug(vrList);
        }

        System.debug('[i2SEMA_AutomaticSettingValidation] - 자동규칙 유효 확인 종료');
        System.debug(vrList);

        return vrList;
    }
    /**
     * 유효여부 처리를 위한 Wrapper Class
     */
    public class ValidationResult {
        @AuraEnabled public Boolean isValid;
        @AuraEnabled public String errorMessage;

        private ValidationResult valid(){
            this.isValid = true;
            return this;
        }
        private ValidationResult invalid(String message){
            this.isValid = false;
            this.errorMessage = message;
            return this;
        }
    }
}