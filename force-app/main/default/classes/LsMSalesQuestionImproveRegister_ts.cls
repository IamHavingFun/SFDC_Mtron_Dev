/****************************************************************************************
 * @filename      : LsMSalesQuestionImproveRegister_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-07-07 오전 11:19
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-07-07 오전 11:19        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class LsMSalesQuestionImproveRegister_ts {
    @isTest
    static void testBehavior() {

        LsMSalesQuestionImproveRegister.CaseCreateData caseCreateData = LsMSalesQuestionImproveRegister.init(TestDataBaseFactory.baseCase.Id);
        System.assertNotEquals(caseCreateData.typeList, null);
        caseCreateData.assetName = TestDataSalesFactory.baseAsset.Name;
        LsMSalesQuestionImproveRegister.save(caseCreateData);
        caseCreateData.caseData.Id = null;
        LsMSalesQuestionImproveRegister.save(caseCreateData);
    }
}