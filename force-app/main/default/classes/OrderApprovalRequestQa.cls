/****************************************************************************************
  * @filename      : OrderApprovalRequestQa
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-07-27
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : OrderApprovalRequestQa_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-16      i2max.my_seo.  Create
****************************************************************************************/
public with sharing class OrderApprovalRequestQa {

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
				return (order.Status__c == '대리점 주문 신청') ? true : false;
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
		initData.order = [SELECT Id, Status__c FROM Order__c WHERE Id = :recordId];
		return initData;
	}

	/**
	 * 주문 제출 승인 요청
	 *
	 * @param recordId : Order__c 의 RecordId
	 * @param comment : 승인 요청 코멘트
	 */
	@AuraEnabled
	public static void submitForApproval(final String recordId, String comment) {

		System.debug(System.LoggingLevel.INFO, 'recordId :' + recordId);
		if(String.isEmpty(comment) == true) comment = '주문 검토 요청 드립니다.';
		Approval.ProcessSubmitRequest reqApproval = new Approval.ProcessSubmitRequest();
		reqApproval.setComments(comment);
		reqApproval.setObjectId(recordId);

		// Submit on behalf of a specific submitter
		reqApproval.setSubmitterId(UserInfo.getUserId());
		if(!Test.isRunningTest()) Approval.ProcessResult result = Approval.process(reqApproval);

	}

}