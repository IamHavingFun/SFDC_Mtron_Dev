/****************************************************************************************
  * @filename      : LsMSalesContractVO_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-15 오후 2:20
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-15 오후 2:20     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesContractVO_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        
        LsMSalesContractVO lsMSalesContractVO = new LsMSalesContractVO();
        lsMSalesContractVO.bizData = new LsMSalesContractVO.BizData();
        lsMSalesContractVO.dateData = new LsMSalesContractVO.DateData();
        lsMSalesContractVO.UnchangedData = new LsMSalesContractVO.UnchangedData(TestDataSalesFactory.baseContract, lsMSalesContractVO.dateData);
        lsMSalesContractVO.bizData.quote = TestDataSalesFactory.baseQuote;

        System.assertNotEquals(lsMSalesContractVO.bizData.qliList, null);
        System.assertNotEquals(lsMSalesContractVO.bizData.contract, null);
        System.assertEquals(lsMSalesContractVO.bizData.tempDetailAddress, null);
        System.assertEquals(lsMSalesContractVO.dateData.tempYear, null);
        System.assertEquals(lsMSalesContractVO.dateData.tempMonth, null);
        System.assertEquals(lsMSalesContractVO.dateData.tempDay, null);
        System.assertEquals(lsMSalesContractVO.dateData.tempAmtYear, null);
        System.assertEquals(lsMSalesContractVO.dateData.tempAmtMonth, null);
        System.assertEquals(lsMSalesContractVO.dateData.tempAmtDay, null);
        System.assertEquals(lsMSalesContractVO.dateData.tempCustomerYear, null);
        System.assertEquals(lsMSalesContractVO.dateData.tempCustomerMonth, null);
        System.assertEquals(lsMSalesContractVO.dateData.tempCustomerDay, null);
        System.assertNotEquals(lsMSalesContractVO.dateData.yearAmtList, null);
        System.assertNotEquals(lsMSalesContractVO.dateData.yearList, null);
        System.assertNotEquals(lsMSalesContractVO.dateData.monthList, null);
        System.assertNotEquals(lsMSalesContractVO.dateData.dayList, null);
    }
}