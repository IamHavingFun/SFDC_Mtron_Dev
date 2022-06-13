/****************************************************************************************
 * @filename      : CaseEvaluation_ts
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-07-07 오전 11:15
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
 0.1     2020-07-07 오전 11:15        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class CustomCaseEvaluation_ts {
	@isTest
	static void testBehavior() {
		CustomCaseEvaluation.initData initData = CustomCaseEvaluation.init(TestDataBaseFactory.baseNewCase.Id);
		CustomCaseEvaluation.save(TestDataBaseFactory.baseNewCase);
		System.assertNotEquals(initData.dealerFeedBackList,null);
	}
}