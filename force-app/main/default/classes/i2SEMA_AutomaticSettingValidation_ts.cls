/****************************************************************************************
  * @filename      : i2SEMA_AutomaticSettingValidation_ts
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/24 9:59 AM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : i2SEMA_AutomaticSettingValidation_ts_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/24 9:59 AM     i2max_shlee       Create
****************************************************************************************/
@IsTest
private class i2SEMA_AutomaticSettingValidation_ts {

    static NotificationAutomaticSetting__c realTimeAutomaticSetting;

    @TestSetup static void setup(){
        NotificationAutomaticSetting__c setting = i2SEMA_TestDataUtil.getRealTimeAutomaticSetting(new Map<String,Object>{
                'LogicalExpression__c'  => 'A || B || C'
        });
        insert i2SEMA_TestDataUtil.getBooleanCondition(setting);
    }

    static void getData(){
        realTimeAutomaticSetting = [SELECT Id
                ,IsActive__c
                ,IsSchedule__c
                ,ScheduleTime__c
                ,ObjectType__c
                ,ExecuteOn__c
                ,RecipientField__c
                ,NotificationTemplate__c
                ,NotificationTemplate__r.Channel__c
                ,NotificationTemplate__r.Title__c
                ,NotificationTemplate__r.Content__c
                ,NotificationTemplate__r.LABEL1__c
                ,NotificationTemplate__r.LABEL2__c
                ,NotificationTemplate__r.LABEL3__c
                ,NotificationTemplate__r.LABEL4__c
                ,NotificationTemplate__r.LABEL5__c
                ,Label1FieldAPI__c
                ,Label2FieldAPI__c
                ,Label3FieldAPI__c
                ,Label4FieldAPI__c
                ,Label5FieldAPI__c
                ,LogicalExpression__c
                ,(SELECT ID
                ,NotificationAutomaticSetting__c
                ,Alias__c
                ,fm_ObjectType__c
                ,Field__c
                ,FieldType__c
                ,ReferenceType__c
                ,Operator__c
                ,CompareWith__c
                ,CompareField__c
                ,BOOLEAN__c
                ,CURRENCY__c
                ,DATETIME__c
                ,DATE__c
                ,TIME__c
                ,EMAIL__c
                ,DOUBLE__c
                ,LONG__c
                ,INTEGER__c
                ,PERCENT__c
                ,PHONE__c
                ,REFERENCE__c
                ,PICKLIST__c
                ,STRING__c
        FROM NotificationAutomaticConditions__r )
        FROM NotificationAutomaticSetting__c
        LIMIT 1];
    }

    @IsTest static void testCase01(){
        getData();
        i2SEMA_AutomaticSettingValidation.ValidationResult result = i2SEMA_AutomaticSettingValidation.check(realTimeAutomaticSetting);

        System.assertEquals(true , result != null);
    }

}