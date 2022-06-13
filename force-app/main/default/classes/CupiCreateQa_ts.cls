/****************************************************************************************
 * @filename      : CupiCreateQa_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-07-07 오전 11:16
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
 0.1     2020-07-07 오전 11:16        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class CupiCreateQa_ts {
    @isTest
    static void testBehavior() {
        CupiCreateQa.WrapperData wrapperData = CupiCreateQa.init(TestDataBaseFactory.personAccount.Id);
        CupiCreateQa.save(wrapperData);
    }
}