/****************************************************************************************
  * @filename      : LsMSalesCaseEdit_ts
  * @author        : i2max_my.Seo
  * @date          : 2020-11-27 오전 8:09
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-11-27 오전 8:09     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesCaseEdit_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesCaseEdit.CaseCreateData caseCreateData = LsMSalesCaseEdit.init(TestDataBaseFactory.baseNewCase.Id);
        System.assertNotEquals(caseCreateData.typeList, null);
        caseCreateData.assetName = TestDataSalesFactory.baseAsset.Name;
        LsMSalesCaseEdit.save(caseCreateData);
        caseCreateData.caseData.Id = null;
        LsMSalesCaseEdit.save(caseCreateData);

        LsMSalesCaseEdit.CaseCreateData caseCreateData2 = new LsMSalesCaseEdit.CaseCreateData();
        System.assertNotEquals(caseCreateData2.type2List1, null);
        System.assertNotEquals(caseCreateData2.type2List2, null);
        System.assertNotEquals(caseCreateData2.type2List3, null);
    }
}