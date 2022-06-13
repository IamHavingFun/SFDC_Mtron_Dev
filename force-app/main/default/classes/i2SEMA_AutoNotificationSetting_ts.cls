/****************************************************************************************
  * @filename       : i2SEMA_AutoNotificationSetting_ts
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-22 오후 4:09
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : i2SEMA_AutoNotificationSetting_ts_Test.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-22 오후 4:09     i2max_byeon.jw       Create
****************************************************************************************/

@IsTest
private class i2SEMA_AutoNotificationSetting_ts {

    static NotificationAutomaticSetting__c realTimeAutomaticSetting;
    static NotificationTemplate__c mmsTemplate;

    @TestSetup static void setup(){
        i2SEMA_TestDataUtil.getRealTimeAutomaticSetting(new Map<String,Object>());
        i2SEMA_TestDataUtil.getMMSTemplate();
    }

    static void getData(){
        realTimeAutomaticSetting = [SELECT Id,IsActive__c FROM NotificationAutomaticSetting__c LIMIT 1];
        mmsTemplate = [SELECT Id FROM NotificationTemplate__c LIMIT 1];
    }


    // Case 1. 자동화 조건 상세조회
    @IsTest static void testCase01(){
        getData();
        i2SEMA_ComponentResponse response = i2SEMA_AutoNotificationSetting.initialize(realTimeAutomaticSetting.Id);
        // Assert Equal
        System.assertEquals( true, response.getData('notificationSetting') != null);
        System.assertEquals( realTimeAutomaticSetting.Id , ((NotificationAutomaticSetting__c)JSON.deserialize(JSON.serialize(response.getData('notificationSetting')),NotificationAutomaticSetting__c.class)).Id);
    }
    // Case 2. Object Field 조회
    @IsTest static void testCase02(){
        i2SEMA_ComponentResponse response = i2SEMA_AutoNotificationSetting.getFieldData('NotificationAutomaticTest__c');
        // Assert Equal
        System.assertEquals( true, response.getData('fields') != null);
        System.assertEquals( true, response.getData('fieldTypes') != null);
    }
    // Case 3. 수신자 조회
    @IsTest static void testCase03(){
        i2SEMA_ComponentResponse response = i2SEMA_AutoNotificationSetting.getRecipientFields('NotificationAutomaticTest__c');
        // Assert Equal
        System.assertEquals( true, response.getData('recipientFields') != null);
    }
    // Case 4. Template 조회
    @IsTest static void testCase04(){
        getData();
        i2SEMA_ComponentResponse response = i2SEMA_AutoNotificationSetting.getTemplateData(mmsTemplate.Id);
        // Assert Equal
        System.assertEquals( true, response.getData('template') != null);
    }
    // Case 5. Toggle Active
    @IsTest static void testCase05(){
        getData();
        i2SEMA_ComponentResponse response = i2SEMA_AutoNotificationSetting.toggleActivateNotificationSetting(new Map<String,Object>{'notificationSetting'=>realTimeAutomaticSetting});
        // Assert Equal
        System.assertEquals( true, response.getData('notificationSetting') != null);
    }
    // Case 6. Save
    @IsTest static void testCase06(){
        getData();

        Map<String,Object> param = new Map<String,Object>();
        realTimeAutomaticSetting.LogicalExpression__c = 'A || B || C';
        param.put('notificationSetting',realTimeAutomaticSetting);
        param.put('fieldConditions',i2SEMA_TestDataUtil.getBooleanCondition(realTimeAutomaticSetting));

        i2SEMA_ComponentResponse response = i2SEMA_AutoNotificationSetting.doSaveNotificationSetting(param);
    }
}