/**
** @filename     : ContractDetail_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-20 오후 12:55
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
private class ContractDetail_ts {
    @IsTest
    static void testBehavior() {
        TestDataSalesFactory.init();

       ContractDetail.InitData initData =  ContractDetail.init(TestDataSalesFactory.baseContract.Id);
       ContractDetail.save(initData.contractData);

    }
}