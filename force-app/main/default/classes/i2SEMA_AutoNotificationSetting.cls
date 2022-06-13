/****************************************************************************************
      * @filename       : i2SEMA_AutoNotificationSetting
      * @projectname    : i2SEMA Core
      * @author         : i2max_byeon.jw
      * @date           : 2020-04-14 오전 10:25
      * @group          :
      * @group-content  :
      * @description    :
      * @tester         : i2SEMA_AutoNotificationSetting_Test.cls
      * @reference      :
      * @copyright      : Copyright © I2max. All Rights Reserved.
      * @modification Log
      * ===============================================================
      * ver     date                author              description
      * ===============================================================
        0.1     2020-04-14 오전 10:25     i2max_byeon.jw       Create
    ****************************************************************************************/

    public with sharing class i2SEMA_AutoNotificationSetting extends i2SEMA_Base{
        /**
         * @description 초기정보 조회
         *
         * @param recordId {String} Notification ID
         * @return {i2SEMA_ComponentResponse} 조회결과
         */
        @AuraEnabled
        public static i2SEMA_ComponentResponse initialize(String recordId){
            // Response
            i2SEMA_ComponentResponse resp = new i2SEMA_ComponentResponse();

            // Record ID 없는 경우 Error
            if( recordId == null || !recordId.startsWithIgnoreCase(Schema.SObjectType.NotificationAutomaticSetting__c.getKeyPrefix())){
                throw  new AuraHandledException(LABEL.i2SEMA_MSG_INVALID_AUTO_SETTING_ID);
            }

            // Notification Setting & Field Condition 조회
            NotificationAutomaticSetting__c nts = [ SELECT  Id, Name,IsActive__c, ObjectType__c, ExecuteOn__c, LogicalExpression__c,RecipientField__c, NotificationTemplate__c
                                                                        ,Label1FieldAPI__c, Label2FieldAPI__c, Label3FieldAPI__c, Label4FieldAPI__c, Label5FieldAPI__c
                                                                        ,IsSchedule__c, ScheduleTime__c, ScheduleBasedOn__c , FieldForSchedule__c
                                                                FROM NotificationAutomaticSetting__c
                                                                WHERE Id =:recordId];

            List<NotificationAutomaticCondition__c> ntfcs = [ SELECT Id, Alias__c, Field__c,FieldType__c, CompareWith__c, Operator__c, CompareField__c,
                                                                            BOOLEAN__c,CURRENCY__c,DATETIME__c,DATE__c,TIME__c,EMAIL__c,DOUBLE__c,LONG__c,INTEGER__c,PERCENT__c,PHONE__c,REFERENCE__c,PICKLIST__c,STRING__c
                                                                    FROM NotificationAutomaticCondition__c
                                                                WHERE NotificationAutomaticSetting__c =:recordId
                                                                ORDER BY Alias__c ASC];


            // 전체 Object 목록 조회
            List<DropBoxItem> objects                           = new List<DropBoxItem>();
            Map<String,SObjectType> globalDescribe              = Schema.getGlobalDescribe();
            Map<String,SObjectType> globalDescribeNameKeyMap    = new Map<String,SObjectType>();  // Global Describe 의 Key 값들이 Lower Case 이므로.. 이후 참조를 위해 Name 값으로 변환
            for( String key : globalDescribe.keySet() ){
                SObjectType objType = globalDescribe.get(key);
                DescribeSObjectResult dsr = objType.getDescribe();

                objects.add( new DropBoxItem( dsr.getLabel() , dsr.getName()));
                globalDescribeNameKeyMap.put(dsr.getName(),objType);
            }

            // 스케쥴링 기준 조회
            List<DropBoxItem> scheduleBaseOptions                   = new List<DropBoxItem>();
            Schema.DescribeFieldResult scheduleBaseResult           = NotificationAutomaticSetting__c.ScheduleBasedOn__c.getDescribe();
            List<Schema.PicklistEntry> scheduleBasePicklistEntries  = scheduleBaseResult.getPicklistValues();
            for (Schema.PicklistEntry p : scheduleBasePicklistEntries) {
                scheduleBaseOptions.add(new DropBoxItem(p.getLabel(),p.getValue()));
            }

            // 필드목록 조회 (Object 설정값이 있는 경우)
            List<DropBoxItem> fields                = new List<DropBoxItem>();
            List<DropBoxItem> recipientFields       = new List<DropBoxItem>();
            List<DropBoxItem> scheduleBaseFields    = new List<DropBoxItem>();
            Map<String,String> fieldTypes           = new Map<String,String>();
            if( i2SEMA_Util.isNotEmpty(nts.ObjectType__c)){
                Map<String,SObjectField> fieldMap = globalDescribeNameKeyMap.get(nts.ObjectType__c).getDescribe().fields.getMap();
                for( SObjectField field : fieldMap.values() ){
                    DescribeFieldResult fieldDesc = field.getDescribe();

                    // Schedule 기준으로 설정될수 있는 DateTime 필드 목록
                    if( Schema.DisplayType.DATETIME === fieldDesc.getType()){
                        scheduleBaseFields.add( new DropBoxItem(fieldDesc.getLabel(), fieldDesc.getName()));
                    }

                    // 발송조건으로 설정할 필드목록 (지원 타입만 허용)
                    if( getSupportedTypes().contains(fieldDesc.getType())){
                        fields.add( new DropBoxItem(fieldDesc.label,fieldDesc.name));
                        fieldTypes.put(fieldDesc.name , fieldDesc.type.name());
                    }

                    // 수신자로 사용할수 있는 필드 목록 (Account,Contact,Lead,User 오브젝트의 Id, Lookup 필드)
                    Set<String> referenceTypes = new Set<String>();
                    if(fieldDesc.getType() == Schema.DisplayType.ID){
                        // 기준 Object 가 Account,Contact,Lead,User 일 경우 ID 필드를 통해 발신가능
                        if( nts.ObjectType__c.equalsIgnoreCase(SObjectType.Account.getName()) || nts.ObjectType__c.equalsIgnoreCase(SObjectType.Contact.getName())
                                || nts.ObjectType__c.equalsIgnoreCase(SObjectType.Lead.getName()) || nts.ObjectType__c.equalsIgnoreCase(SObjectType.CampaignMember.getName()) || nts.ObjectType__c.equalsIgnoreCase(SObjectType.User.getName())){
                            recipientFields.add(new DropBoxItem(fieldDesc.getLabel(), fieldDesc.getName()));
                        }
                    }
                    else if(fieldDesc.getType() == Schema.DisplayType.REFERENCE){
                        // Reference 필드의 참조타입이 Account,Contact,Lead,User 일 경우 발신가능
                        for (SObjectType referenceType : fieldDesc.getReferenceTo()) {
                            referenceTypes.add(referenceType.getDescribe().getName());
                        }
                        if (referenceTypes.contains(SObjectType.Account.getName()) || referenceTypes.contains(SObjectType.Contact.getName())
                                || referenceTypes.contains(SObjectType.Lead.getName()) || referenceTypes.contains(SObjectType.User.getName())) {
                            recipientFields.add(new DropBoxItem(fieldDesc.getLabel(), fieldDesc.getName()));
                        }
                    }
                    // Formula(TEXT) 필드 발신가능 : ID 가 입력되는 필드
                    else if( fieldDesc.isCalculated() && Schema.DisplayType.STRING.equals(fieldDesc.getType())){
                        recipientFields.add(new DropBoxItem(fieldDesc.getLabel(), fieldDesc.getName()));
                    }
                }
            }

            // 템플릿 조회 (Template 설정값이 있는 경우)
            NotificationTemplate__c template = new NotificationTemplate__c();
            if( i2SEMA_Util.isNotEmpty(nts.NotificationTemplate__c)){
                List<NotificationTemplate__c> templates = [SELECT Id, Title__c, Content__c, LABEL1__c, LABEL2__c, LABEL3__c, LABEL4__c, LABEL5__c
                                                                            FROM NotificationTemplate__c
                                                                        WHERE Id =: nts.NotificationTemplate__c AND IsActive__c=TRUE];
                template = !templates.isEmpty() ? templates[0] : template;
            }


            resp.setData('notificationSetting',nts);
            resp.setData('fieldConditions',ntfcs);
            resp.setData('scheduleBaseOptions',scheduleBaseOptions);
            resp.setData('scheduleBaseFields',scheduleBaseFields);
            resp.setData('objects',objects);
            resp.setData('fields',fields);
            resp.setData('fieldTypes',fieldTypes);
            resp.setData('recipientFields',recipientFields);
            resp.setData('template',template);

            return resp;
        }
        /**
         * @description Object Field 조회
         *
         * @param objectType {String} Object Type
         * @return {i2SEMA_ComponentResponse} 필드 조회결과
         */
        @AuraEnabled
        public static i2SEMA_ComponentResponse getFieldData(String objectType){
            // Response
            i2SEMA_ComponentResponse resp = new i2SEMA_ComponentResponse();

            if( String.isEmpty(objectType) ){
                throw new AuraHandledException(LABEL.i2SEMA_MSG_INVALID_OBJECT_TYPE);
            }

            List<DropBoxItem> fields        = new List<DropBoxItem>();
            List<DropBoxItem> scheduleBaseFields    = new List<DropBoxItem>();
            Map<String,String> fieldTypes   = new Map<String,String>();

            Map<String,SObjectType> globalDescribe              = Schema.getGlobalDescribe();
            Map<String,SObjectType> globalDescribeNameKeyMap    = new Map<String,SObjectType>();  // Global Describe 의 Key 값들이 Lower Case 이므로.. 이후 참조를 위해 Name 값으로 변환

            for( String key : globalDescribe.keySet() ){
                SObjectType objType = globalDescribe.get(key);
                DescribeSObjectResult dsr = objType.getDescribe();

                globalDescribeNameKeyMap.put(dsr.getName(), objType);
            }

            Map<String,SObjectField> fieldMap = globalDescribeNameKeyMap.get(objectType).getDescribe().fields.getMap();
            for( SObjectField field : fieldMap.values() ){
                DescribeFieldResult fieldDesc = field.getDescribe();

                // Schedule 기준으로 설정될수 있는 DateTime 필드 목록
                if( Schema.DisplayType.DATETIME === fieldDesc.getType()){
                    scheduleBaseFields.add( new DropBoxItem(fieldDesc.getLabel(), fieldDesc.getName()));
                }

                // 지원하는 Data Type 만 반환
                if( getSupportedTypes().contains(fieldDesc.getType())) {
                    fields.add(new DropBoxItem(fieldDesc.label, fieldDesc.name));
                    fieldTypes.put(fieldDesc.name, fieldDesc.type.name());
                }
            }

            resp.setData('fields',fields);
            resp.setData('fieldTypes',fieldTypes);
            resp.setData('scheduleBaseFields',scheduleBaseFields);
            return resp;
        }
        /**
         * @description 수신자 Field 조회
         * @param objectType
         * @return {i2SEMA_ComponentResponse} 수신자 필드 조회결과
         */
        @AuraEnabled
        public static i2SEMA_ComponentResponse getRecipientFields(String objectType){
            // Response
            i2SEMA_ComponentResponse resp = new i2SEMA_ComponentResponse();

            if( i2SEMA_Util.isEmpty(objectType)){
                throw new AuraHandledException(LABEL.i2SEMA_MSG_INVALID_OBJECT_TYPE);
            }

            Map<String,SObjectType> globalDescribe              = Schema.getGlobalDescribe();
            Map<String,SObjectType> globalDescribeNameKeyMap    = new Map<String,SObjectType>();  // Global Describe 의 Key 값들이 Lower Case 이므로.. 이후 참조를 위해 Name 값으로 변환

            for( String key : globalDescribe.keySet() ){
                SObjectType objType = globalDescribe.get(key);
                DescribeSObjectResult dsr = objType.getDescribe();

                globalDescribeNameKeyMap.put(dsr.getName(), objType);
            }

            List<DropBoxItem> recipientFields = new List<DropBoxItem>();

            Map<String,SObjectField> fieldMap = globalDescribeNameKeyMap.get(objectType).getDescribe().fields.getMap();
            for( SObjectField field : fieldMap.values() ){
                DescribeFieldResult fieldDesc = field.getDescribe();
                // Reference Type 인 경우 (Account,Contact,Lead)
                Set<String> referenceTypes = new Set<String>();

                // Account,Contact,Lead,User 일 경우 ID 추가
                if(fieldDesc.getType() == Schema.DisplayType.ID){
                    if( objectType.equalsIgnoreCase(SObjectType.Account.getName()) || objectType.equalsIgnoreCase(SObjectType.Contact.getName())
                            || objectType.equalsIgnoreCase(SObjectType.Lead.getName()) || objectType.equalsIgnoreCase(SObjectType.User.getName())){
                        recipientFields.add(new DropBoxItem(fieldDesc.getLabel(), fieldDesc.getName()));
                    }
                }
                // Lookup,Master-Detail
                else if(fieldDesc.getType() == Schema.DisplayType.REFERENCE){
                    for (SObjectType referenceType : fieldDesc.getReferenceTo()) {
                        referenceTypes.add(referenceType.getDescribe().getName());
                    }
                    if (referenceTypes.contains(SObjectType.Account.getName()) || referenceTypes.contains(SObjectType.Contact.getName())
                            || referenceTypes.contains(SObjectType.Lead.getName()) || referenceTypes.contains(SObjectType.User.getName())) {
                        recipientFields.add(new DropBoxItem(fieldDesc.getLabel(), fieldDesc.getName()));
                    }
                }
                // Formula(TEXT) 필드 발신가능 : ID 가 입력되는 필드
                else if( fieldDesc.isCalculated() && Schema.DisplayType.STRING.equals(fieldDesc.getType())){
                    recipientFields.add(new DropBoxItem(fieldDesc.getLabel(), fieldDesc.getName()));
                }
            }

            resp.setData('recipientFields',recipientFields);
            return resp;
        }
        /**
         * @description Template 상세 정보 조회
         *
         * @param templateId {String} Notification Template ID
         * @return {i2SEMA_ComponentResponse} Template 상세 조회결과
         */
        @AuraEnabled
        public static i2SEMA_ComponentResponse getTemplateData(String templateId){
            // Response
            i2SEMA_ComponentResponse resp = new i2SEMA_ComponentResponse();

            if( i2SEMA_Util.isEmpty(templateId)){
                throw new AuraHandledException(LABEL.i2SEMA_MSG_INVALID_TEMPLATE_ID);
            }
            List<NotificationTemplate__c> templates = [SELECT Id, Title__c, Content__c, LABEL1__c, LABEL2__c, LABEL3__c, LABEL4__c, LABEL5__c
                                                                        FROM NotificationTemplate__c
                                                                    WHERE Id =: templateId AND IsActive__c=true];

            NotificationTemplate__c template = !templates.isEmpty() ? templates[0] : new NotificationTemplate__c();

            resp.setData('template',template);
            return resp;
        }
        /**
         * @description Notification Setting 저장
         *
         * @param notificationSetting {NotificationAutomaticSetting__c} 처리대상
         * @return {i2SEMA_ComponentResponse} 처리결과
         */
        @AuraEnabled
        public static i2SEMA_ComponentResponse doSaveNotificationSetting(Map<String,Object> param){
            // Response
            i2SEMA_ComponentResponse resp = new i2SEMA_ComponentResponse();

            NotificationAutomaticSetting__c notificationSetting = (NotificationAutomaticSetting__c)JSON.deserialize(JSON.serialize(param.get('notificationSetting')),NotificationAutomaticSetting__c.class);
            List<NotificationAutomaticCondition__c> fieldConditions = (List<NotificationAutomaticCondition__c>)JSON.deserialize(JSON.serialize(param.get('fieldConditions')),List<NotificationAutomaticCondition__c>.class);

            update notificationSetting;

            // 전체 Setting 삭제후 현재 목록 재생성
            delete [SELECT Id FROM NotificationAutomaticCondition__c WHERE NotificationAutomaticSetting__c =:notificationSetting.Id];

            for( NotificationAutomaticCondition__c condition : fieldConditions ){
                condition.Id                                            = null;
                condition.BOOLEAN__c                         = condition.BOOLEAN__c == true;
                condition.NotificationAutomaticSetting__c    = notificationSetting.Id;
            }
            insert fieldConditions;

            return resp;
        }
        @AuraEnabled
        public static i2SEMA_ComponentResponse toggleActivateNotificationSetting(Map<String,Object> param){
            // Response
            i2SEMA_ComponentResponse resp = new i2SEMA_ComponentResponse();

            NotificationAutomaticSetting__c notificationSetting = (NotificationAutomaticSetting__c)JSON.deserialize(JSON.serialize(param.get('notificationSetting')),NotificationAutomaticSetting__c.class);

            // 다른 항목 업데이트 하지않고, ID 를 통해 Active 값만 변경
            NotificationAutomaticSetting__c updateSetting = new NotificationAutomaticSetting__c(Id=notificationSetting.Id);
            updateSetting.IsActive__c = !notificationSetting.IsActive__c;
            update updateSetting;


            resp.setData('notificationSetting',updateSetting);

            return resp;
        }

        /**
         * @description DropBox 컴포넌트 용도 Wrapper
         */
        public class DropBoxItem{
            @AuraEnabled public String label;
            @AuraEnabled public String value;

            public DropBoxItem(String label, String value){
                this.label = label;
                this.value = value;
            }
        }
    }