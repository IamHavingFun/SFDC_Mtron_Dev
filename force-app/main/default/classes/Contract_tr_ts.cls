/**
** @filename     : Contract_tr_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-20 오후 12:55
* @group         :
* @group-content :
* @description   : 계약의 인도기일이 업데이트 되면 기회 인도기일 업데이트.
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
private class Contract_tr_ts {
	@IsTest
	static void testBehavior() {
		TestDataSalesFactory.init();
		Opportunity oppty = TestDataSalesFactory.baseOpportunity;
		Contract__c contract = TestDataSalesFactory.baseContract;
		contract.Opportunity__c = oppty.Id;
		contract.CustomerExpectedDate__c = Date.today();
		update contract;

		Contract__c contract2 = contract.clone(false, false);
		contract2.Opportunity__c = oppty.Id;
		contract2.CustomerExpectedDate__c = Date.today();
		insert contract2;
	}
}