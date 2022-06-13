/**
** @filename     : GuideActionLeadConfirm_sc_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-08-18 오후 5:37
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
private class GuideActionLeadConfirm_sc_ts {
    @IsTest
    static void testBehavior() {
        GuideActionLeadConfirm_sc.runSchedule();
        GuideActionLeadConfirm_sc.abortSchedule();

    }
}