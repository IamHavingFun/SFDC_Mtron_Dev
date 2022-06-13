/****************************************************************************************
  * @filename      : i2SEMA_NotificationKakaoButtonLink_ts
  * @projectname   : i2SEMA Core
  * @author        : i2max_ys.seo
  * @date          : 2020-04-20 오후 1:20
  * @group         : e.g)tab name
  * @group-content : e.g)view file
  * @description   : 카카오버튼  테스트 클래
  * @tester        : i2SEMA_TemplateKakaoButton_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author              description
  * ===============================================================
    0.1     2020-04-20 오후 1:20     i2max_ys.seo         Create
    0.1     2020/04/28 11:31 AM     i2max_shlee          Rename i2SEMA_NotificationKakaoButtonLink_ts -> i2SEMA_TemplateKakaoButton_ts
****************************************************************************************/
@IsTest
public with sharing class i2SEMA_TemplateKakaoButton_ts {
    @TestSetup
    private static void setTestData() {
        i2SEMA_TestDataUtil.kakaoFriendTemplate = null; i2SEMA_TestDataUtil.getKakaoNotificationTalkTemplate();
        i2SEMA_TestDataUtil.kakaoNotificationTemplate = null; i2SEMA_TestDataUtil.getKakaoFriendTalkTemplate();
        i2SEMA_TestDataUtil.ktb = null; i2SEMA_TestDataUtil.getKakaoTalkButton();
    }

    static testmethod void testCase01(){
        Test.startTest();
        List<NotificationTemplate__c> notificationTemplates = [SELECT Id, Name, Title__c, Content__c, Channel__c, ContentLength__c, isActive__c FROM NotificationTemplate__c WHERE Channel__c = '1009'];
        List<KakaoTalkButton__c> ktbList = [
                SELECT Id, NotificationTemplates__c, Name, Button_Type__c, ButtonLink1__c, ButtonLink2__c FROM KakaoTalkButton__c
                WHERE NotificationTemplates__c = :notificationTemplates[0].Id
                LIMIT 1
        ];

        i2SEMA_TemplateKakaoButton.initialize(notificationTemplates[0].Id);

        Test.stopTest();
    }
}