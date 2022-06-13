/****************************************************************************************
  * @filename      : GuideActionOpportunityActivityChk_ba_ts
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-09
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
    0.1     2020-07-09             Park HE         Create
****************************************************************************************/

@IsTest
private class GuideActionOpportunityActivityChk_ba_ts {
    @IsTest
    static void testBehavior() {

        //============================================================================
        // 배치수행 : 조건에 맞는 데이터가 없어 execute 수행이 안됨
        // 강제로 execute 수행
        //============================================================================
        Database.executeBatch(new GuideActionOpportunityActivityCheck_ba(), 1);
        new GuideActionOpportunityActivityCheck_ba().execute(null, new List<Opportunity>{TestDataSalesFactory.baseOpportunity});

    }

    @IsTest
    static void testBehavior2() {
        GuideActionOpportunityActivityCheck_sc.runSchedule();
        GuideActionOpportunityActivityCheck_sc.abortSchedule();
    }
}