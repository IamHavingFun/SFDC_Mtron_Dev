/****************************************************************************************
 * @filename      : GuideActionAR6MonthOverByAsset_sc_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-08-18 오후 5:16
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
 0.1     2020-08-18 오후 5:16        SEOKHO LEE          Create
 ****************************************************************************************/

@isTest
private class GuideActionAR6MonthOverByAsset_sc_ts {
    @isTest
    static void testBehavior() {

        GuideActionAR6MonthOverByAsset_sc.runSchedule();
        GuideActionAR6MonthOverByAsset_sc.abortSchedule();
    }
}