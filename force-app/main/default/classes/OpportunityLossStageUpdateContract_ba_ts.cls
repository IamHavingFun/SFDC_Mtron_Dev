/****************************************************************************************
  * @filename      : OpportunityLossStageUpdateContract_ba_ts
  * @author        : i2max
  * @date          : 2021-04-19
  * @group         :
  * @group-content :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date           author           description
  * ===============================================================
    0.1     2021-04-19     i2max            Create
****************************************************************************************/
@IsTest
private class OpportunityLossStageUpdateContract_ba_ts {
    @IsTest
    static void testBehavior() {
        Opportunity opportunity = TestDataSalesFactory.baseOpportunity.clone(true, true);
        // StageName 과 SystemStatus__c 를 동일하게 적용할 것
        opportunity.StageName = '계약';
        opportunity.SystemStatus__c = '계약';
        opportunity.CloseDate = System.today().addDays(OpportunityLossStageUpdateContract_ba.calDays);
        opportunity.CustomerExpectedDate__c = System.today().addDays(OpportunityLossStageUpdateContract_ba.calDays);
        opportunity.LossReason__c = '';
        opportunity.Dealer__c = TestDataBaseFactory.agencyAccount.Id;
        update opportunity;

        Order__c order = TestDataSalesFactory.orderForPerFarCorp.clone(false, true);
        order.Opportunity__c = opportunity.Id;
        order.Division__c = '공장주문';

        insert order;

        Database.executeBatch(new OpportunityLossStageUpdateContract_ba(), 200);
    }
}