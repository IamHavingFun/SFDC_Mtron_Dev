/****************************************************************************************
  * @filename      : OrderAssetTransferRequestButtons
  * @author        : i2max_my.Seo
  * @date          : 2020-11-19 오후 12:46
  * @group         :
  * @group-content :
  * @description   : 파트너 주문에 전수배 전환 동의 버튼 활성화 처리
  * @tester        : OrderAssetTransferRequestQa_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-11-19 오후 12:46     i2max_my.Seo           Create
****************************************************************************************/
public without sharing class OrderAssetTransferRequestButtons {

	/**
	 * Wrapper class for InitData
	 */
	public class InitData extends I2ComClass.InitData {
		@AuraEnabled
		public Order__c order {get;private set;}
		@AuraEnabled
		public Boolean isRequested {
			get {
				return (String.isNotEmpty(this.order.AssetTransferAgreeStatus__c) && this.order.AssetTransferAgreeStatus__c == '요청') ? true : false;
			}
			private set;
		}
	}

	/**
	 * Init method
	 *
	 * @return I2ComClass.InitData
	 */
	@AuraEnabled
	public static InitData init(final String recordId) {
		InitData initData = new InitData();

		Order__c order = [SELECT Id, AssetTransferAgreeStatus__c, PurposeOfOrder__c FROM Order__c WHERE Id = :recordId];

		initData.order = order;

		return initData;
	}

}