/**
** @filename     : GuideActionBondCheck_sc_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-08-18 오후 5:35
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
private class GuideActionBondCheck_sc_ts {
    @IsTest
    static void testBehavior() {

        GuideActionBondCheck_sc.runSchedule();
        GuideActionBondCheck_sc.abortSchedule();
    }
}