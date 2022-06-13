/****************************************************************************************
  * @filename      : GuideActionBondCheck_ba_ts
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-17Q
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-07-17             Park HE         Create
****************************************************************************************/

@IsTest
private class GuideActionBondCheck_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        User testUser = TestDataBaseFactory.businessOfficeUser;
        Database.executeBatch(new GuideActionBondCheck_ba(), 200);

    }

    @IsTest
    static void testBehaviorSchedule() {
        GuideActionBondCheck_sc.runSchedule();
        GuideActionBondCheck_sc.abortSchedule();
    }
}