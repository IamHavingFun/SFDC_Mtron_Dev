/****************************************************************************************
  * @filename      : LsMSalesPDIDetail
  * @projectname   : LS
  * @author        : i2max.seo
  * @date          : 2020-06-19 오후 2:11
  * @group         :
  * @group-content :
  * @description   : PDI 등록 및 조회
  * @tester        : LsMSalesPDIDetail_ts
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                      author          description
  * ===============================================================
    0.1     2020-06-19 오후 2:11       Park JW         Create
****************************************************************************************/
public with sharing class LsMSalesPDIDetail {

	/**
	 * @param assetName
	 *
	 * @return
	 */
	@AuraEnabled
	public static LsMSalesStepVO init(String contractId) {
		System.debug('====');
		System.debug(contractId);
		System.debug('====');

		if(String.isEmpty(contractId)) throw new AuraHandledException('계약정보가 없습니다.');

		Contract__c contract = [
				SELECT Id, Name, Customer__r.Name, Customer__r.fm_Mobile__c,ContractNumber__c, Opportunity__c,
				(SELECT Id, ProductId__r.Name, ProductId__r.ProductCode, fm_ProductType__c  FROM ContractLineItem__r WHERE fm_Type__c = '본체'),
				(SELECT Id, Name, AccountId, Account.Name, Account.fm_Mobile__c, Product2.Name, InventoryType__c FROM Assets__r ORDER BY CreatedDate ASC LIMIT 1)
				FROM Contract__c WHERE Id =: contractId
		];

		PDI__c pdi;
		List<PDI__c> pdis = [
			SELECT
				Id,
				Name,
				Opportunity__c,
				OwnerId,
				LastModifiedDate,
				Action__c,
				Asset__c,
				Consumer__c,
				Contract__c,
				CreatedDate,
				Check1_1__c,
				Check1_2__c,
				Check1_3__c,
				Check1_4__c,
				Check1_5__c,
				Check1_6__c,
				Check1_7__c,
				Check1_8__c,
				Check1_9__c,
				Check2_1__c,
				Check2_2__c,
				Check2_3__c,
				Check2_4__c,
				Check2_5__c,
				Check2_6__c,
				Check2_7__c,
				Check2_8__c,
				Check3_1__c,
				Check3_2__c,
				Check3_3__c,
				Check3_4__c,
				Check3_5__c,
				Check3_6__c,
				Check3_7__c,
				Education1__c,
				Education2__c,
				Education3__c,
				Education4__c,
				Education5__c,
				Education6__c,
				Education7__c,
				Education8__c,
				Education9__c,
				ErpLWSUniqueNo__c,
				ETC__c,
				fm_CheckerSignature__c,
				fm_CustomerSignature__c,
				fm_Mobile__c,
				fm_Model__c,
				HandoverDate__c,
				SalesIQ_1__c,
				SalesIQ_2__c,
				SalesIQ_3__c,
				(SELECT Id, ContentDocumentId, Title FROM AttachedContentDocuments)
			FROM PDI__c
			WHERE Contract__c = : contract.Id ORDER BY CreatedDate DESC LIMIT 1
		];

		LsMSalesPDIVO lsMSalesPDIVO = new LsMSalesPDIVO();
		lsMSalesPDIVO.bizData = new lsMSalesPDIVO.BizData();
		lsMSalesPDIVO.bizData.isViewMode = true;    // 상세 조회 처리.
		lsMSalesPDIVO.bizData.contract = contract;
		lsMSalesPDIVO.bizData.contractItem = contract.ContractLineItem__r;
		lsMSalesPDIVO.bizData.asset = contract.Assets__r.isEmpty() ? null : contract.Assets__r;
		if(pdis.isEmpty() == true || pdis.size() == 0) {
			lsMSalesPDIVO.bizData.pdi = new PDI__c();
			lsMSalesPDIVO.bizData.isPDI = true;
		} else {
			lsMSalesPDIVO.bizData.pdi = pdis[0];
			//for (AttachedContentDocument r : pdi.AttachedContentDocuments) {
 			for (AttachedContentDocument r : lsMSalesPDIVO.bizData.pdi.AttachedContentDocuments) {
				if (r.Title == 'dealerSign.png') {
					// 대리점 사인
					lsMSalesPDIVO.bizData.dealerSign = r;
				} else if (r.Title == 'customerSign.png') {
					// 고객 사인
					lsMSalesPDIVO.bizData.customerSign = r;
				}
			}
		}
		return lsMSalesPDIVO;
	}

}