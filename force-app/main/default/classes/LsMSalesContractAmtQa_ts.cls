/****************************************************************************************
  * @filename      : LsMSalesContractAmtQa_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-17 오전 8:33
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-17 오전 8:33     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesContractAmtQa_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesContractAmtQa.InitData initData = new LsMSalesContractAmtQa.InitData();
        System.assertNotEquals(initData.yearList, null);

        List<String> typeList = new List<String>{
                '계약금', '융자금', '보조금', '리스', '자부담'
        };
        Contract__c contract = TestDataSalesFactory.baseContract;
        contract.ContractAmtCollectDueDate__c = TestDataUtilFactory.d;

        for(String type : typeList) {
            LsMSalesContractAmtQa.init(contract, type);
            LsMSalesContractAmtQa.setContractDate(contract, ((Datetime)TestDataUtilFactory.d.addDays(3)).format('yyyy-MM-dd'), type);
        }

        LsMSalesContractAmtQa.setContractDate(contract, null, '자부담');
    }
}