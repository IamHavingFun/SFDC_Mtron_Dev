/****************************************************************************************
  * @filename      : Asset_tr
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-05-06
  * @group         :
  * @group-content :
  * @description   : 자산의 대리점정보와 대리점코드 매칭이 안되는 경우를 위한 백업 조치.
  * @tester        : ActualSales_tr_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-06         i2max          Create
****************************************************************************************/
public with sharing class Asset_tr extends TriggerHandler {

	public override void beforeInsert() {
		this.beforeDupCheck(false);
		this.beforeUpdateDealerCode(trigger.new);
	}

	public override void beforeUpdate() {
		this.beforeDupCheck(true);
		this.beforeUpdateDealerCode(trigger.new);
	}

	/**
	 * @param newList Asset List
	 */
	private void beforeUpdateDealerCode(List<Asset> scopes) {
		Set<Id> dealerIds = new Set<Id>();
		for(Asset r : scopes) dealerIds.add(r.Dealer__c);

		Map<Id, Account> dealerMap = new Map<Id, Account>([SELECT Id, ERPCode__c FROM Account WHERE Id IN :dealerIds]);

		for(Asset r : scopes) {
			if(dealerMap.containsKey(r.Dealer__c)) {
				r.DealerCode__c = dealerMap.get(r.Dealer__c).ERPCode__c;
			}
		}
	}

	/**
	 * @param newList Asset List
	 */
	private void beforeDupCheck(Boolean isUpdate) {
		Set<String> assetNoSet = new Set<String>();
		Map<Id, Asset> oldAssetMap = (Map<Id, Asset>)Trigger.oldMap;
		List<Asset> assetList = (List<Asset>) Trigger.new;
		for(Asset r : assetList) {
			assetNoSet.add(r.Name);
		}
		Map<String, String> assetDupCheckMap = new Map<String, String>();
		for(Asset r : [
				SELECT Name FROM Asset WHERE Name IN :assetNoSet
		]) {
			assetDupCheckMap.put(r.Name, r.Name);
		}
		for(Asset r : assetList) {
			if(isUpdate == true) {
				// 수정시 체크.
				if(oldAssetMap.get(r.Id).Name != r.Name) {
					//r.addError('기대번호는 변경이 불가 합니다.');
				}
			} else {
				// 신규 체크
				if(assetDupCheckMap.containsKey(r.Name)) {
					r.addError('기존에 중복 기대번호가 존재 합니다.');
				}
			}
		}

	}
}