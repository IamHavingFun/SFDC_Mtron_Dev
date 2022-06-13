/**
** @filename     : ContractPDFController_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-20 오후 12:55
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
private class ContractPDFController_ts {
	@IsTest
	static void testBehavior() {
		TestDataSalesFactory.init();

		Contract__c contract = TestDataSalesFactory.baseContract;
		contract.SocialNoIn__c = EncodingUtil.base64Encode(Blob.valueOf('7001011234567'));
		update contract;
		ContractLineItem__c baseCli = TestDataSalesFactory.baseCli;

		ApexPages.currentPage().getParameters().put('contractid',contract.Id);

		ContractPDFController controller = new ContractPDFController();
		controller.searchContract(contract.Id);

		System.debug(controller.totalAmt );
		System.debug(controller.totalCnt );
		System.debug(controller.contentType );
        System.assertEquals(null, ContractPDFController.dealerSignId);
        System.assertEquals(null, ContractPDFController.customerSignId);
	}
}