@IsTest
private class OrderAssetDeliveryQa_ts {
    @IsTest
    static void testBehavior() {

        TestDataSalesFactory.init();
        TestDataBaseFactory.init();

        List<Order__c> orderList = new List<Order__c>();
        Order__c order = TestDataSalesFactory.orderForPerFarCorp;
        order.TransferMachineNo__c = TestDataSalesFactory.baseAsset.Id;
        update order;
        Order__c order2 = order.clone(false, true);
        order2.Division__c = '공장주문';
        order2.Status__c = '출하';
        order2.PurposeOfOrder__c = '판매기회';
        orderList.add(order2);
        Order__c order3 = order2.clone(false, true);
        order3.Division__c = '전수배';
        order3.Status__c = '출하';
        order3.PurposeOfOrder__c = '판매기회';
        orderList.add(order3);
        Order__c order4 = order.clone(false, true);
        order4.Division__c = '공장주문';
        order4.Status__c = '출하';
        order4.PurposeOfOrder__c = '판매기회';
        orderList.add(order4);
        Order__c order5 = order.clone(false, true);
        order5.Division__c = '공장주문';
        order5.Status__c = '출하';
        order5.PurposeOfOrder__c = '판매기회';
        order5.IsOutAsset__c = true;
        orderList.add(order5);
        Order__c order6 = order.clone(false, true);
        order6.Division__c = '공장주문';
        order6.Status__c = '출하';
        order6.PurposeOfOrder__c = '재고보충';
        order6.IsOutAsset__c = true;
        orderList.add(order6);

        insert orderList;

        TransferOrder__c to = new TransferOrder__c(SalesDocNo__c = '1234', Order__c = order.Id);
        insert to;
        TransferOrder__c to2 = new TransferOrder__c(SalesDocNo__c = null, Order__c = order4.Id);
        insert to2;


        OrderAssetDeliveryQa.InitData initData = OrderAssetDeliveryQa.init(order.Id);
        System.assertNotEquals(initData.validMessage,null);

        initData =OrderAssetDeliveryQa.init(order2.Id);
        //System.assertNotEquals(initData.validMessage,null);
        initData = OrderAssetDeliveryQa.init(order3.Id);
        //System.assertNotEquals(initData.validMessage,null);
        initData = OrderAssetDeliveryQa.init(order4.Id);
        //System.assertNotEquals(initData.validMessage,null);
        initData = OrderAssetDeliveryQa.init(order5.Id);
        //System.assertNotEquals(initData.validMessage,null);
        //System.assertNotEquals(initData.isProcess,null);

        ///////////////////////////////////////////////////////////////
        
        Delivery__c delivery = TestDataBizFactory.baseDelivery;
        delivery.ReleaseDate__c = TestDataUtilFactory.d;
        update delivery;

        Test.startTest();
        Order__c testorder = [
                SELECT Id, SalesDocNo__c, TransferMachineNo__r.Name, TransferMachineNo__r.BatchNo__c, OrderProduct__c, Division__c,
                        fm_OrderScheduleYearMonth__c,fm_RecordTypeOrder__c,
                        PurposeOfOrder__c, OrderScheduleDate__c, DeliverySeq__c, Status__c, IsInAsset__c, IsOutAsset__c,
                (
                        SELECT Id, SalesDocNo__c FROM TransferOrders__r LIMIT 1
                )
                FROM Order__c WHERE Id =: order.Id AND SalesDocNo__c != NULL];

        List<Order__c> notiTargetOrders = new List<Order__c>();

        OrderAssetDeliveryQa.set0038In(testorder, testorder.TransferOrders__r[0]);
        OrderAssetDeliveryQa.set0038Out(order2);
        OrderAssetDeliveryQa.set0038OutNormal(order2, new List<Order__c>{order2});
        OrderAssetDeliveryQa.sendNoti(order2, new List<Order__c>{order2});

        Asset asset = new Asset();
        asset.ErpLGORT__c = '1111';
        asset.Name = '203121211111';
        asset.BatchNo__c = '203121211111';

        OrderKeep__c orderKeep = new OrderKeep__c();
        orderKeep.KeepAsset__r = asset;
        OrderAssetDeliveryQa.set0038KeepOut(order2, orderKeep);

        OrderAssetDeliveryQa.runTest();
        Test.stopTest();

    }
}