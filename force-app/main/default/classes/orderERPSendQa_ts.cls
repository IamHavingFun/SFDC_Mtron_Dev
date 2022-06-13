/**
** @filename     : orderERPSendQa_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-20 오후 3:53
* @group         :
* @group-content :
* @description   :
* @tester        :
* @reference     :
* @copyright     : Copyright © I2max. All Rights Reserved.
* @modification Log
* ===============================================================
* ver     date             author              description
* ===============================================================
  0.1                            Create
 */
@IsTest
private class orderERPSendQa_ts {
    @TestSetup
    static void setup() {
        /*
         * ================================================================
         * 필요시 IF_INFO__c 객체의 데이터를 변경하여 insert 할것
         * one transaction 처리 때문에 TestSetup 에서 insert 할것
         * ================================================================
         */
        IF_INFO__c ifInfo = TestDataIFCalloutFactory.createIFInfo();
        ifInfo.IF_ID__c = 'IF_KR_SE_ERP_0007';
        insert ifInfo;
    }

    @IsTest
    static void testBehavior() {
        TestDataSalesFactory.init();
        TestDataProductFactory.init();

        List<Order__c> orderList = new List<Order__c>();
        Order__c order = TestDataSalesFactory.orderForPerFarCorp;
        OrderLineitem__c oli = TestDataSalesFactory.oliForNhGov;
        Order__c order2 = order.clone(false, true);
        order2.SalesDocNo__c = '';
        order2.Division__c = '공장주문';
        order2.Status__c = '본사 주문 확정';
        orderList.add(order2);
        insert orderList;

        orderERPSendQa.InitData initData = orderERPSendQa.init(order.Id);
        System.assertNotEquals(initData.validMessage,null);
        System.assertNotEquals(initData.isOrderSend,null);
        for(Order__c o : orderList){
            initData = orderERPSendQa.init(o.Id);
            System.assertNotEquals(initData.validMessage,null);
            System.assertNotEquals(initData.isOrderSend,null);
            System.assertNotEquals(initData.isTransferOrder, null);
        }

        IfStaticValue__c ifStaticValue = TestDataIFCalloutFactory.createIfStaticValue();
        IF_Base.IfStaticValue(ifStaticValue);
        // Mock 객체 세팅
        Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock(
                '{"Response":{"Header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_ERP_0007","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"Payload":{"TOTAL_RECORD_CNT":"2"}}}'
        ));

        final String OrderId = order.Id;
        Test.startTest();

            try {
                orderERPSendQa.sendERPNew(orderId, true);
            } catch (Exception e) {

            }
            orderERPSendQa.sendERP(orderId);

            orderERPSendQa.setTransferOrder(oli.OrderId__c);
        Test.stopTest();
        

    }
}