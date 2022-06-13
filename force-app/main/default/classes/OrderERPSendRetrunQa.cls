/****************************************************************************************
  * @filename      : OrderERPSendRetrunQa
  * @projectname   :
  * @author        : i2max.seo
  * @date          : 2020-12-10
  * @group         :
  * @group-content :
  * @description   : 전수배 반품 주문 - 전배 대리점 데이터를 반품 처리 한다.
  *
  * @tester        : OrderERPSendRetrunQa_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-16      i2max.seo      Create
****************************************************************************************/
public with sharing class OrderERPSendRetrunQa {

	/**
	 * 초기 거래 데이터
	 */
	public class InitData extends I2ComClass.InitData {
		@AuraEnabled public Order__c order {get;set;}
		@AuraEnabled public TransferOrder__c transferOrder {get;set;}
		@AuraEnabled public Boolean isValidOrder {
			get {
				return (transferOrder.Status__c == '대상' && String.isEmpty(transferOrder.SalesDocNo__c) == true && order.Division__c == '전수배' &&
						order.TransferProcessStatus__c == '승인' && order.AssetTransferAgreeStatus__c == '승인' && order.IsZRET__c == false)
						? true : false;
			}
			set;
		}
		@AuraEnabled public String validMessage {
			get {
				String message = '';
				if (!isValidOrder && String.isEmpty(transferOrder.SalesDocNo__c) == false) {
					message = 'ERP 전수배 반품 주문 신청이 완료된 건 입니다.';
				} else if (order.Division__c != '전수배') {
					message = '전수배 주문(반품)만 ERP 전송이 가능 합니다.';
				} else if (order.TransferProcessStatus__c != '승인' && order.AssetTransferAgreeStatus__c != '승인') {
					message = '수배 대리점의 전수배 동의와 전배 대리점의 전배 승인이 처리가 되어야 합니다. ';
				} else if (order.IsZRET__c == true) {
					message = '이미 ERP 반품 주문 신청이 처리 되었습니다.';
				} else {
					message = 'ERP 반품 주문 처리 상태가 아닙니다. 먼저 ERP 주문을 진행해주세요.';
				}
				return message;
			}
			set;
		}
	}

	/**
	 * 초기 거래
	 *
	 * @param recordId
	 *
	 * @return
	 */
	@AuraEnabled(Cacheable=true)
	public static InitData init(final String recordId) {
		InitData initData = new InitData();
		initData.transferOrder = new TransferOrder__c();
		initData.order = [
				SELECT Id, Division__c, SalesDocNo__c, Status__c, IsZRET__c, TransferProcessStatus__c, AssetTransferAgreeStatus__c,
				(SELECT Id, SalesDocNo__c, Status__c FROM TransferOrders__r LIMIT 1)
				FROM Order__c WHERE Id =: recordId
		];
		if(initData.order.TransferOrders__r != null && initData.order.TransferOrders__r.size() > 0) {
			initData.transferOrder = initData.order.TransferOrders__r[0];
		}
		return initData;
	}

	/**
	 * 주문 전송 to ERP
	 *
	 * @param recordId : Order__c 의 RecordId
	 */
	@AuraEnabled
	public static Map<String, String> sendERP(final String recordId, final Boolean isTransferOrder) {
		Order__c order = [
				SELECT Id, Division__c, SalesDocNo__c, Status__c, IsZRET__c, TransferProcessStatus__c, AssetTransferAgreeStatus__c,
				(SELECT Id, SalesDocNo__c, Status__c FROM TransferOrders__r LIMIT 1)
				FROM Order__c WHERE Id =: recordId
		];
		if(order.TransferOrders__r.isEmpty() == false) {
			for(TransferOrder__c r : order.TransferOrders__r) {
				if(String.isNotEmpty(r.SalesDocNo__c)) {
					throw new AuraHandledException('이미 반품 주문이 처리되었습니다.');
				}
			}
		}
		Map<String, String> returnMap = new Map<String, String>();
		returnMap = OrderService.IF_KR_SE_ERP_0007_ZRET(recordId);
		return returnMap;
	}

}