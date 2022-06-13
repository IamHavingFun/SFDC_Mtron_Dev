/****************************************************************************************
  * @filename      : OrderAssetTransferRequestQa
  * @author        : i2max_my.Seo
  * @date          : 2020-11-19 오후 12:46
  * @group         :
  * @group-content :
  * @description   : 주문 전수배 전환 동의 요청
  *                    - 영업소검토 단계에서만
  * @tester        : OrderAssetTransferRequestQa_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-11-19 오후 12:46     i2max_my.Seo           Create
****************************************************************************************/
public without sharing class OrderAssetTransferRequestQa {

	/**
	 * Wrapper class for InitData
	 */
	public class InitData extends I2ComClass.InitData {
		@AuraEnabled
		public Order__c order {get;set;}

		@AuraEnabled
		public Boolean isRequested {
			get {
				return (String.isEmpty(this.order.AssetTransferAgreeStatus__c)) ? false : true;
			}
			private set;
		}
		@AuraEnabled
		public Boolean isPossible {
			get {
				return (this.order.Status__c == '영업소 주문 검토') ? true : false;
			}
			private set;
		}

        @AuraEnabled
        public Boolean isOpportunityOrder {
            get {
                return (this.order.PurposeOfOrder__c.equals('실판매기회')) ? true : false;
            }
            private set;
        }

		@AuraEnabled
		public Boolean isNhGovAccount {
			get {
				Set<String> nhGovCheck = new Set<String>{
						'농협', '관납'
				};
				return nhGovCheck.contains(this.order.OrderAccount__r.CustomerType__c) ? true : false;
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
	public static I2ComClass.InitData init(final String recordId) {
		InitData initData = new InitData();

		Order__c order = [SELECT Id, Status__c, OrderAccount__r.CustomerType__c, AssetTransferAgreeStatus__c, PurposeOfOrder__c FROM Order__c WHERE Id = :recordId];

		initData.order = order;

		return initData;
	}

	/**
	 * Save
	 *
	 * @param order : Order__c
	 *
	 * @return String : Id
	 */
	@AuraEnabled
	public static String save(Order__c order) {
		Set<String> nhGovCheck = new Set<String>{
				'농협', '관납'
		};
		if(nhGovCheck.contains(order.OrderAccount__r.CustomerType__c)) {
			// 고객이 농협 관납이면 자동 승인 처리.
			order.AssetTransferAgreeStatus__c = '승인';
		} else {
			order.AssetTransferAgreeStatus__c = '요청';
		}
		update order;
		return order.Id;
	}
}