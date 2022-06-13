/****************************************************************************************
  * @filename      : Dummy_IF_KR_SE_PLM_0037_ba_ts
  * @projectname   : 
  * @author        : i2max 
  * @date          : 2020-07-13 오후 6:13
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : Dummy_IF_KR_SE_PLM_0037_ba_ts_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-13 오후 6:13       i2max                  Create
*************a***************************************************************************/
@IsTest
private class Dummy_IF_KR_SE_PLM_0037_ba_ts {

    @TestSetup
    static void setup() {
        /*
         * ================================================================
         * 필요시 IF_INFO__c 객체의 데이터를 변경하여 insert 할것
         * one transaction 처리 때문에 TestSetup 에서 insert 할것
         * ================================================================
         */
        IF_INFO__c ifInfo = TestDataIFCalloutFactory.createIFInfo();
        insert ifInfo;
    }

    @IsTest
    static void testBehavior() {
        /*
         * ================================================================
         * IF_Base 세팅
         * 필요시 IfStaticValue__c 객체의 데이터를 변경하여 insert 할것
         * ================================================================
         */
        IfStaticValue__c ifStaticValue = TestDataIFCalloutFactory.createIfStaticValue();
        IF_Base.IfStaticValue(ifStaticValue);

        // Mock 객체 세팅
        Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock(
            '{"Response":{"Header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_SFDC_SEMA_0006","SenderGroup":"I2MAX","SenderCode":"SFDC","ResultCode":"S","IFDatetime":"20191107082747","ErrorMsg":"","ErrorCode":"","DestinationGroup":"I2MAX","DestinationCode":"SEMA"},"Payload":{"TOTAL_RECORD_CNT":"2"}}}'
        ));

        Database.executeBatch(new Dummy_IF_KR_SE_PLM_0037_ba(), 1);
    }

}