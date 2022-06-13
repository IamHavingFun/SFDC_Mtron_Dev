/****************************************************************************************
 * @filename      : DailyCheck_ba_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-12-17 오후 12:38
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
 0.1     2020-12-17 오후 12:38      SEOKHO LEE          Create
 ****************************************************************************************/

@isTest
private class DailyCheck_ba_ts {
    @isTest
    static void testBehavior() {
        TestDataDummyBatchFactory.init();
        
        Database.executeBatch(new DailyCheck_ba(), 2000);
    }
}