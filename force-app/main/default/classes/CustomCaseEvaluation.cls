/****************************************************************************************
 * @filename      : CustomCaseEvaluation
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-05 오전 11:24
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
 0.1     2020-06-05 오전 11:24     SEOKHO LEE          Create
 ****************************************************************************************/

public with sharing class CustomCaseEvaluation {
	/**
	* @description wrapper class for InitData
	*/
	public class InitData extends I2ComClass.InitData {
		@AuraEnabled public List<I2ComClass.Option> dealerFeedBackList {
			get {
				if (this.dealerFeedBackList == null) {
					this.dealerFeedBackList = I2ComUtil.makePickListOptions('CustomizedCase__c', 'DealerFeedback__c', true);
				}
				return this.dealerFeedBackList;
			}
			set;
		}
		@AuraEnabled public CustomizedCase__c caseData{get;set;}

		public InitData() {
		}

		public InitData(final CustomizedCase__c caseData) {
			this.caseData = caseData;
		}
	}
	/**
	 * 초기화
	 * @param recordId
	 * @return
	 */
	@AuraEnabled
	public static InitData init(final String recordId){
		CustomizedCase__c newCase = [
				SELECT  Id, Status__c, DealerFeedback__c, DealerFeedbackComment__c
				FROM CustomizedCase__c
				WHERE Id =:recordId ];
		InitData initData = new InitData(newCase);
		return initData;
	}
	/**
	* 저장
	* @param caseData
	*/
	@AuraEnabled
	public static void save(CustomizedCase__c caseData) {
/*
		if(caseData.DealerFeedback__c == '만족') {
			caseData.Status__c = '평가 완료 및 마감';
		} else {
			caseData.Status__c = '담당부서 검토';
		}
*/
		update caseData;
	}
}