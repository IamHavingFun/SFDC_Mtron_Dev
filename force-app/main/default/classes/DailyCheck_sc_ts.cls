/****************************************************************************************
 * @filename      : DailyCheck_sc_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-12-17 오후 12:41
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
 0.1     2020-12-17 오후 12:41      SEOKHO LEE          Create
 ****************************************************************************************/

@isTest
private class DailyCheck_sc_ts {
    @isTest
    static void testBehavior() {
        DailyCheck_sc.runSchedule();
        DailyCheck_sc.abortSchedule();
    }
}