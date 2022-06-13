/****************************************************************************************
  * @filename      : OrderAssetTransferApprovalQa
  * @author        : i2max_my.Seo
  * @date          : 2020-11-19 오후 12:46
  * @group         :
  * @group-content :
  * @description   : 주문 자산 전배 승인 / 거부 처리.
  * @tester        : OrderAssetTransferApprovalQa_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-11-19 오후 12:46     i2max_my.Seo           Create
****************************************************************************************/
public without sharing class OrderAssetTransferApprovalQa {

	/**
	 * Wrapper class for InitData
	 */
	public class InitData extends I2ComClass.InitData {
		@AuraEnabled
		public Order__c order {get;private set;}

		@AuraEnabled
		public Boolean isProcessed {
			get {
				return (order.AssetTransferAgreeStatus__c == '승인' || order.AssetTransferAgreeStatus__c == '거부') ? true : false;
			}
			private set;
		}

        @AuraEnabled
        public Boolean isNotRequested {
            get {
                return (String.isBlank(order.AssetTransferAgreeStatus__c)) ? true : false;
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

		Order__c order = [SELECT Id, AssetTransferAgreeStatus__c FROM Order__c WHERE Id = :recordId ];

		initData.order = order;

		return initData;
	}

	/**
	 * Save
	 *
	 * @param order : Order__c
	 * @param status : 승인
	 *
	 * @return String : Id
	 */
	@AuraEnabled
	public static String setApprove(Order__c order, String status) {
		order.AssetTransferAgreeStatus__c = status;
		update order;
		return order.Id;
	}

	/**
	 * Save
	 *
	 * @param order : Order__c
	 * @param status : 거부
	 *
	 * @return String : Id
	 */
	@AuraEnabled
	public static String setReject(Order__c order, String status) {
		order.AssetTransferAgreeStatus__c = status;
		update order;
		return order.Id;
	}
}