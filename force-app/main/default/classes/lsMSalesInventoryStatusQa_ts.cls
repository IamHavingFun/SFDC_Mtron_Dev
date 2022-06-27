/****************************************************************************************
  * @filename      : lsMSalesInventoryStatusQa_ts
  * @projectname   : LS
  * @author        : Park JW
  * @date          : 2020-07-14 오후 5:18
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                      author          description
  * ===============================================================
    0.1     2020-07-14 오후 5:18           Park JW         Create
****************************************************************************************/
@IsTest
private class lsMSalesInventoryStatusQa_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        Asset testAsset = TestDataSalesFactory.baseAsset;
        Account businessAccount = TestDataBaseFactory.businessOfficeAccount;
        Product2 testProduct = TestDataProductFactory.baseProduct2;

        Asset testAsset2 = testAsset.clone(false, true);
        testAsset2.InventoryType__c = '공장재고(가용)';
        testAsset2.Name = 'N12345678911';
        testAsset2.BatchNo__c = '12345678911';
        insert testAsset2;

        testAsset.Product2 = testProduct;
        testAsset.InventoryType__c = '대리점재고';
        testAsset.BusinessOffice__r = businessAccount;
        lsMSalesInventoryStatusQa.init(testAsset.Product2);
    }
}