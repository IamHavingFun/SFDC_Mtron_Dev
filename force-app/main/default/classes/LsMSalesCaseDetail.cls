/****************************************************************************************
 * @filename      : LsMSalesCaseDetail
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-18 오후 3:24
 * @group         :
 * @group-content :
 * @description   : [모바일] 질문/개선 상세조회
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-18 오후 3:24        SEOKHO LEE          Create
 ****************************************************************************************/

public with sharing class LsMSalesCaseDetail {

	/**
	 * @param recordId
	 *
	 * @return
	 */
	@AuraEnabled
	public static WrapperData init(String recordId) {
		WrapperData wrapperData = new WrapperData();

		wrapperData.caseData = [
				SELECT Id, RecordTypeId, RecordType.Name, CreatedDate, RequestDate__c,
						Subject__c, Type__c, TypeLevel2__c, Status__c, Description__c, ProcessingResult__c,
						AssetNo__r.Name, UsingTime__c, SelectedModel__c, IssueDetails__c, DoneDetails__c,
						CountReview__c, ClosePlanedDate__c, InChargeDepartment__c, AnswerClosedDate__c, AppliedDate__c, Feedback__c,
						DealerFeedback__c, DealerFeedbackComment__c,
				(SELECT Id, ContentDocumentId, Title, FileExtension FROM AttachedContentDocuments)
				FROM CustomizedCase__c
				WHERE Id = :recordId
		];
		return wrapperData;
	}

	public class WrapperData {
		@AuraEnabled public List<I2ComClass.Option> typeList {
			get {
				if (this.typeList == null) {
					this.typeList = I2ComUtil.makePickListOptions('CustomizedCase__c', 'Type__c', true);
				}
				return this.typeList;
			}
			private set;
		}

		@AuraEnabled public CustomizedCase__c caseData {get;set;}
		@AuraEnabled public String sitePathPrefix {
			get{
				return I2ComUtil.getSitePathPrefix();
			}
			set;
		}
	}
}