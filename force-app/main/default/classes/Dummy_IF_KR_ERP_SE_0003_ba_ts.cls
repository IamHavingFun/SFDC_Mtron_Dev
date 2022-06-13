/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0003_ba_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-05-11 오후 5:04
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-05-11 오후 5:04     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class Dummy_IF_KR_ERP_SE_0003_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
        //============================================================================
        // 필요시 Dummy 데이터 변경 및 추가
        //============================================================================
        Product2 product = TestDataProductFactory.baseProduct2.clone(false, true);
        product.ProductCode = '000000000000000001';
        insert product;

        IF_KR_ERP_SE_0003__c erpSe0003s1 = TestDataDummyBatchFactory.erpSe0003dummyDataBase.clone(false, true);
        erpSe0003s1.ErpPriceType__c = 'FC';
        erpSe0003s1.DATAB__c = Datetime.now().format('yyyyMMdd');
        erpSe0003s1.DATBI__c = Datetime.now().format('yyyyMMdd');
        insert erpSe0003s1;


        IF_KR_ERP_SE_0003__c erpSe0003s2 = TestDataDummyBatchFactory.erpSe0003dummyDataBase.clone(false, true);
        erpSe0003s2.ProductCode__c = null;
        insert erpSe0003s2;


        //============================================================================
        // 배치 실행
        //============================================================================\
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0003_ba(), 200);
    }
}