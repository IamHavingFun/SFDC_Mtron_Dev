/****************************************************************************************
  * @filename      : INPUT_T_DATA_tr
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-05-06
  * @group         :
  * @group-content :
  * @description   : 반환승인 신청건에 대한 승인 후 처리.
  * @tester        : INPUT_T_DATA_tr_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-06         i2max          Create
****************************************************************************************/
public with sharing class AssetReturn_tr extends TriggerHandler {

	public override void afterupdate() {
		this.afterUpdateApprovalUpdate(trigger.new);
	}

	/**
	 * @param newList Asset List
	 */
	private void afterUpdateApprovalUpdate(List<AssetReturn__c> scope) {
		Set<Id> dealerIds = new Set<Id>();

		Map<Id, AssetReturn__c> oldMap = (Map<Id, AssetReturn__c>)trigger.oldMap;

		Map<Id, Account> dealerMap = new Map<Id, Account>([SELECT Id, ERPCode__c FROM Account WHERE Id IN :dealerIds]);

		Set<Id> assetIds = new Set<Id>();
		Map<Id, AssetReturn__c> assetReturnMap = new Map<Id, AssetReturn__c>();
		AssetReturn__c oldAssetReturn;
		for(AssetReturn__c r : scope) {
			oldAssetReturn = oldMap.get(r.Id);
			if(oldAssetReturn.ApprovalStatus__c != r.ApprovalStatus__c && r.ApprovalStatus__c == '승인') {
				assetIds.add(r.Asset__c);
				assetReturnMap.put(r.Asset__c, r);
			}
		}

		List<Asset> assetList = [
				SELECT Id, InventoryType__c, AccountId, Account.CustomerType__c, Dealer__c, Customer__c, WtyStartDate__c, WtyEndDate__c,
						PDI__c, Contract__c
				FROM Asset WHERE Id IN : assetIds
		];

		AssetReturn__c assetReturn;
		Set<String> assetReturnIds = new Set<String>();
		for(Asset r : assetList) {
			assetReturn = assetReturnMap.get(r.Id);
			assetReturnIds.add(assetReturn.Id);
			if(assetReturn.ReturnType__c == '품질 문제') {
				r.WtyStartDate__c = null;
				r.WtyEndDate__c = null;
				r.SalesDate__c = null;
			}
			r.InventoryType__c = '대리점재고';
			r.IsReturnCheck__c  = true;           // 반환 유무
			if(r.Account.CustomerType__c == '농협' || r.Account.CustomerType__c == '관납') {
				r.AccountId         = r.AccountId;    // 고객 - 변경 하지 않는다.
			} else {
				r.AccountId         = r.Dealer__c;    // 고객
			}
			r.Contract__c       = null;           // 계약
			r.PDI__c            = null;           // PDI / 실판매일
			r.Customer__c       = null;           // 실소유자
		}

		if(assetList.isEmpty() == false) update assetList;

		// PDI 반환 처리.
		// 처리일자 : 2021-08-23
		System.debug('---------');
		System.debug(assetReturnIds);
		System.debug('---------');
		if(assetReturnIds.isEmpty() == false && Test.isRunningTest() == false) PDIService.sendReturnPDI(assetReturnIds);
	}

}