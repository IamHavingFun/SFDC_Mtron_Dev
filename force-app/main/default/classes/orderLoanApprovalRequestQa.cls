/****************************************************************************************
  * @filename      : orderLoanApprovalRequestQa
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-04-16
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : orderLoanApprovalRequestQa_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-16         i2max          Create
****************************************************************************************/
public with sharing class orderLoanApprovalRequestQa {

	/**
	 * 초기 거래 데이터
	 */
	public class InitData extends I2ComClass.InitData {
		@AuraEnabled public Order__c order {get;set;}
		@AuraEnabled public Boolean isApprovalRequest {
			get {
				//============================================================================
				// 바인딩 되는 필드만
				//============================================================================
				return (order.Status__c == '본사 주문 확정' && order.LoanApprovalStatus__c == '') ? true : false;
			}
			set;
		}
	}

	/**
	 * 초기 거래
	 * @return InitData
	 */
	@AuraEnabled(Cacheable=true)
	public static InitData init(String recordId) {
		InitData initData = new InitData();
		initData.order = [SELECT Id, Status__c, LoanApprovalStatus__c FROM Order__c WHERE Id = :recordId];
		return initData;
	}

	/**
	 * 여신 한도 승인 요청
	 *
	 * @param recordId : Order__c 의 RecordId
	 */
	@AuraEnabled
	public static void submitForApproval(final String recordId) {

		System.debug(System.LoggingLevel.INFO, 'recordId :' + recordId);
		Order__c order = new Order__c(Id=recordId);
		order.LoanApprovalStatus__c = '요청';
		update order;

		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('승인 요청 드립니다.');
		req1.setObjectId(recordId);

		// Submit on behalf of a specific submitter
		req1.setSubmitterId(UserInfo.getUserId());
		if(!Test.isRunningTest()) Approval.ProcessResult result = Approval.process(req1);

	}

}