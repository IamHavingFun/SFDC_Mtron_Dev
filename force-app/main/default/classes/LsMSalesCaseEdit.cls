/****************************************************************************************
 * @filename      : LsMSalesCaseEdit
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-11 오전 11:22
 * @group         :
 * @group-content :
 * @description   : [모바일] 질문/개선 신규 등록
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1    2020-06-11 오전 11:22      SEOKHO LEE          Create
 ****************************************************************************************/

public with sharing class LsMSalesCaseEdit {

	/**
	 *
	 * init
	 * @return
	 */
	@AuraEnabled
	public static CaseCreateData init(String recordId) {
		CaseCreateData caseCreateData = new CaseCreateData();
		caseCreateData.caseData = new CustomizedCase__c();

		if(String.isNotEmpty(recordId)) {
			caseCreateData.caseData = [
					SELECT Id, RecordTypeId, RecordType.Name, CreatedDate, RequestDate__c,
							Subject__c, Type__c, TypeLevel2__c, Status__c, Description__c, ProcessingResult__c,
							AssetNo__r.Name, UsingTime__c, SelectedModel__c, IssueDetails__c, DoneDetails__c,
							CountReview__c, ClosePlanedDate__c, InChargeDepartment__c, AnswerClosedDate__c, AppliedDate__c, Feedback__c,
							DealerFeedback__c, DealerFeedbackComment__c,
							(SELECT Id, ContentDocumentId, Title, FileExtension FROM AttachedContentDocuments)
					FROM CustomizedCase__c
					WHERE Id = :recordId
			];
			caseCreateData.assetName = caseCreateData.caseData.AssetNo__r.Name;
		}

		return caseCreateData;
	}

	/**
	 *
	 * Save(Create & Edit)
	 * @param caseCreateData
	 *
	 * @return
	 */
	@AuraEnabled
	public static CustomizedCase__c save(CaseCreateData caseCreateData) {

		if(String.isNotBlank(caseCreateData.assetName)) {
			List<Asset> asset = [
					SELECT Id
					FROM Asset
					WHERE Name = :caseCreateData.assetName
			];
			if(asset.isEmpty()){
				throw new DmlException('해당 기대번호를 찾을 수 없습니다. 기대번호를 다시 확인 해주세요.');
			}
			caseCreateData.caseData.AssetNo__c = asset[0].Id;
		}
		// 레코드 아이디가 존재 하지 않으면 insert
		if(String.isEmpty(caseCreateData.caseData.Id)){

			Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
			for(RecordType r : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'CustomizedCase__c']) {
				caseRecordTypeMap.put(r.Name, r.Id);
			}

			if(caseRecordTypeMap.containsKey(caseCreateData.caseData.Type__c)) {
				caseCreateData.caseData.RecordTypeId = caseRecordTypeMap.get(caseCreateData.caseData.Type__c);
			} else {

			}


			caseCreateData.caseData.AccountId__c = ModelUser.getUserData().AccountId;
			caseCreateData.caseData.ContactId__c = ModelUser.getUserData().ContactId;
			caseCreateData.caseData.Status__c = '제출';
			insert caseCreateData.caseData;
			// 레코드 아이디가 존재하면 update
		} else{
			update caseCreateData.caseData;
		}
		return caseCreateData.caseData;
	}
	/**
	* @WrapperClass
	* Case picklist , 질문/개선
	*/
	public class CaseCreateData extends I2ComClass.InitData {
		@AuraEnabled public List<I2ComClass.Option> typeList {
			get {
				if (this.typeList == null) {
					this.typeList = I2ComUtil.makePickListOptions('CustomizedCase__c', 'Type__c', true);
				}
				return this.typeList;
			}
			private set;
		}
		@AuraEnabled public List<I2ComClass.Option> type2List1 {
			get {
				if (this.type2List1 == null) {
					type2List1 = new List<I2ComClass.Option>();
					type2List1.add(new I2ComClass.Option('시스템 사용', '시스템 사용'));
					type2List1.add(new I2ComClass.Option('시스템 오류', '시스템 오류'));
					type2List1.add(new I2ComClass.Option('작업기 등록', '작업기 등록'));
					type2List1.add(new I2ComClass.Option('영업사원 소통', '영업사원 소통'));
					type2List1.add(new I2ComClass.Option('기타', '기타'));
				}
				return this.type2List1;
			}
			private set;
		}
		@AuraEnabled public List<I2ComClass.Option> type2List2 {
			get {
				if (this.type2List2 == null) {
					type2List2 = new List<I2ComClass.Option>();
					type2List2.add(new I2ComClass.Option('판매 지원', '판매 지원'));
					type2List2.add(new I2ComClass.Option('프로모션 제안', '프로모션 제안'));
					type2List2.add(new I2ComClass.Option('부품 공급 지연', '부품 공급 지연'));
					type2List2.add(new I2ComClass.Option('Warranty', 'Warranty'));
				}
				return this.type2List2;
			}
			private set;
		}
		@AuraEnabled public List<I2ComClass.Option> type2List3 {
			get {
				if (this.type2List3 == null) {
					type2List3 = new List<I2ComClass.Option>();
					type2List3.add(new I2ComClass.Option('모델 개선', '모델 개선'));
					type2List3.add(new I2ComClass.Option('품질 문제', '품질 문제'));
					type2List3.add(new I2ComClass.Option('조립 불량', '조립 불량'));
					type2List3.add(new I2ComClass.Option('부품 불량', '부품 불량'));
				}
				return this.type2List3;
			}
			private set;
		}
		@AuraEnabled public CustomizedCase__c            caseData      {get;set;}
		@AuraEnabled public String          assetName {get; set;}
	}
}