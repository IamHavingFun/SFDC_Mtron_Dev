@IsTest
public with sharing class Dummy_IF_KR_ERP_SE_0036_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
        //============================================================================
        // 필요시 Dummy 데이터 변경 및 추가
        //============================================================================
        Order__c order = TestDataSalesFactory.createOrder(true);

        IF_KR_ERP_SE_0036__c dummy1 = TestDataDummyBatchFactory.erpSe0036dummyDataBase.clone(false, true);
        dummy1.OrderID__c = order.Id;
        dummy1.ErpABGRU__c = '00';

        IF_KR_ERP_SE_0036__c dummy2 = TestDataDummyBatchFactory.erpSe0036dummyDataBase.clone(false, true);
        dummy2.OrderID__c = order.Id;
        dummy2.ErpABGRU__c = '01';

        insert dummy1;
        insert dummy2;

        //============================================================================
        // 배치 실행
        //============================================================================\
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0036_ba(), 200);
    }
}