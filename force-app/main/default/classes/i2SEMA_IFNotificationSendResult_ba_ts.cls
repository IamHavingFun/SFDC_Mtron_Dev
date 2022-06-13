/****************************************************************************************
  * @filename      : i2SEMA_IFNotificationSendResult_ba_ts
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/22 4:13 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : i2SEMA_IFNotificationSendResult_ba_ts_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/22 4:13 PM     i2max_shlee       Create
****************************************************************************************/
@IsTest
public with sharing class i2SEMA_IFNotificationSendResult_ba_ts {
    private static string IF_ID = 'IF_SFDC_SEMA_0005';

    @TestSetup static void setTestData() {
        // Interface
        insert i2SEMA_TestDataUtil.getIFInfo(IF_ID);
        i2SEMA_TestDataUtil.getReservationSMSNotification();
        i2SEMA_TestDataUtil.getMMSManualReservNoti();
    }

    static testmethod void testCase01() {
        Test.startTest();

        try {
            // Interface Mock
            Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
            IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

            System.debug('NotificationList : '+[SELECT Id, NotificationGroup__c, Channel__c FROM Notification__c WHERE Validity__c=TRUE AND IsSendingReservation__c=TRUE AND SendingTime__c >= TOMORROW]);

//            i2SEMA_TestDataUtil.getReservationSMSNotification();
//            i2SEMA_TestDataUtil.getMMSManualReservNoti();
            Map<String, Map<String, Object>> responseMap = new Map<String, Map<String, Object>>();
            Map<String, Object> ifResultMap = null;
            for (Notification__c noti : [SELECT Id, NotificationGroup__c, Channel__c FROM Notification__c WHERE Validity__c=TRUE AND IsSendingReservation__c=TRUE AND SendingTime__c >= TOMORROW]) {
                ifResultMap = new Map<String, Object>();
                if ('2'.equals(noti.Channel__c)) { //성공
                    ifResultMap.put('ifResult', TRUE);
                } else { //실패
                    ifResultMap.put('ifResult', FALSE);
                    ifResultMap.put('ifFailMsg', 'Error');
                    ifResultMap.put('ifFailCode', '-9999');
                }
                responseMap.put(noti.id, ifResultMap);
            }

            i2SEMA_IFNotificationSendResult_ba batch = new i2SEMA_IFNotificationSendResult_ba(responseMap);
            Database.executeBatch(batch, 10);
        }catch(Exception e) {
            System.debug(e.getStackTraceString());
        }

        Test.stopTest();
    }

//    @isTest
//    static void testCaseLMS(){
//        Test.startTest();
//
//        // Interface Mock
//        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
//        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();
//
//        Id jobId = System.enqueueJob(new i2SEMA_IFNotificationSend_qu(i2SEMA_TestDataUtil.lmsNotification));
//
//        Test.stopTest();
//    }
//
//    @isTest
//    static void testCaseKFT(){
//        Test.startTest();
//
//        // Interface Mock
//        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
//        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();
//
//        Id jobId = System.enqueueJob(new i2SEMA_IFNotificationSend_qu(i2SEMA_TestDataUtil.kftNotification));
//
//        Test.stopTest();
//    }
//
    /**
     * @description Interface Mock
     */
    private class ManualSendInterfaceMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type','application/json');
            response.setStatusCode(200);
            response.setBody(getResponseBody());
            return response;
        }
    }
    /**
     * @description Interface Response 생성
     * @return {String} IF_SFDC_SEMA_0005.OutputDIH
     */
    private static String getResponseBody() {
        IF_SFDC_SEMA_0005.OutputDIH output = new IF_SFDC_SEMA_0005.OutputDIH();

        // Header
        output.response.header.ifId             = IF_ID;
        output.response.header.ifSenderGp       = 'I2MAX';
        output.response.header.ifSender         = 'SEMA';
        output.response.header.ifReceiverGp     = 'I2MAX';
        output.response.header.ifReceiver       = 'SFDC';
        output.response.header.ifTrackingId     = '';
        output.response.header.ifDateTime       = '';
        output.response.header.ifResult         = '';
        output.response.header.ifFailMsg        = '';
        output.response.header.ifFailCode       = '';

        // Payload
        output.response.payload.t_data = new List<IF_SFDC_SEMA_0005.OUTPUT_T_DATA>();

        return JSON.serialize(output);
    }
}