/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0014_3_ba_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2021-04-28
  * @group         :
  * @group-content :
  * @description   : [강제채권 제로 생성]
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-28      i2max_my.Seo     Create
****************************************************************************************/
@IsTest
private class Dummy_IF_KR_ERP_SE_0014_3_ba_ts {
    @IsTest
    static void testBehavior() {
        //============================================================================
        // 필요시 Dummy 데이터 변경 및 추가
        //============================================================================
        AR__c ar_baseYearMonth = TestDataBizFactory.baseAR.clone(false, true);
        ar_baseYearMonth.BaseYearMonth__c = TestDataUtilFactory.d.addMonths(-1).toStartOfMonth();
        ar_baseYearMonth.Division__c = '실적';
        ar_baseYearMonth.BillingDocNo__c = '1234567890';

        AR__c ar_boforeMonthFromBaseYearMonth = ar_baseYearMonth.clone(false, true);
        ar_boforeMonthFromBaseYearMonth.BaseYearMonth__c = ar_baseYearMonth.BaseYearMonth__c.addMonths(-1).toStartOfMonth();
        ar_boforeMonthFromBaseYearMonth.BillingDocNo__c = '1234567891';

        insert new List<AR__c>{
            ar_baseYearMonth, ar_boforeMonthFromBaseYearMonth
        };

        //============================================================================
        // 배치 실행
        //============================================================================
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0014_3_ba(), 200);
    }
}