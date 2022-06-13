/****************************************************************************************
  * @filename      : i2SEMA_AutoNotificationEvaluation_qu_ts
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/24 9:58 AM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : i2SEMA_AutoNotificationEvaluation_qu_ts_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/24 9:58 AM     i2max_shlee       Create
****************************************************************************************/
@IsTest
private class i2SEMA_AutoNotificationEvaluation_qu_ts {

    static NotificationAutomaticSetting__c realTimeAutomaticSetting;

    @TestSetup static void setup(){
        NotificationAutomaticSetting__c setting = i2SEMA_TestDataUtil.getRealTimeAutomaticSetting(new Map<String,Object>{
                'LogicalExpression__c'  => 'A || B || C'
        });
        insert i2SEMA_TestDataUtil.getBooleanCondition(setting);
    }

    static void getData(){
        realTimeAutomaticSetting = [SELECT Id,IsActive__c,LogicalExpression__c,IsSchedule__c,RecipientField__c
                                        ,ScheduleBasedOn__c
                                        ,FieldForSchedule__c
                                        ,ScheduleTime__c
                                        ,NotificationTemplate__c
                                        ,NotificationTemplate__r.Channel__c
                                        ,NotificationTemplate__r.Title__c
                                        ,NotificationTemplate__r.Content__c
                                        ,Label1FieldAPI__c
                                        ,Label2FieldAPI__c
                                        ,Label3FieldAPI__c
                                        ,Label4FieldAPI__c
                                        ,Label5FieldAPI__c
                                    FROM NotificationAutomaticSetting__c LIMIT 1];
    }

    // 발송 테스트
    @IsTest static void testCase01(){
        getData();

        // 발송대상
        NotificationAutomaticTest__c testRecord =  i2SEMA_TestDataUtil.getAutomaticTestRecord(new Map<String,Object>());
        insert testRecord;

        // Param
        Map<SObject,Map<NotificationAutomaticSetting__c,Map<String,Boolean>>> param = new  Map<SObject,Map<NotificationAutomaticSetting__c,Map<String,Boolean>>>();
        Map<NotificationAutomaticSetting__c,Map<String,Boolean>> settingResultMap = new Map<NotificationAutomaticSetting__c,Map<String,Boolean>>{
                realTimeAutomaticSetting    => new Map<String,Boolean>{'A' => false , 'B' => false , 'C' => true}
        };

        param.put(testRecord,settingResultMap);

        i2SEMA_AutoNotificationEvaluation_qu evaluationQu = new i2SEMA_AutoNotificationEvaluation_qu(param);
        System.enqueueJob(evaluationQu);
    }
}