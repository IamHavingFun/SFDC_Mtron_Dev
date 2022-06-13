/****************************************************************************************
 * @filename      : LsMSalesCaseEvaluationQa_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-07-07 오전 11:25
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
 0.1     2020-07-07 오전 11:25        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class LsMSalesCaseEvaluationQa_ts {
    @IsTest
    static void testBehavior() {
        System.assertNotEquals(LsMSalesCaseEvaluationQa.init(TestDataBaseFactory.baseNewCase.Id), null);
        System.assertNotEquals(LsMSalesCaseEvaluationQa.save(TestDataBaseFactory.baseNewCase), null);
    }
}