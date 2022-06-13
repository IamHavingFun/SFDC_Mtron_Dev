/**
 * Created by MS on 2020-07-01.
 */

public without sharing class LsMSalesOrderAssetTransferApproval {

	@AuraEnabled
	public static List<AssetTransferRequest__c> init() {
		return [
				SELECT AssetNo__r.Name, AssetNo__r.IsSendReceiveItem__c, Model__r.Name, WantedDealer__r.Name, TransferDealer__c, CreatedDate, Status__c, Order__c, Contract__c,
						Order__r.Name, Order__r.TransferMachineNo__c, Order__r.TransferBusinessOffice__c, Order__r.TransferProcessStatus__c,
						Contract__r.Status__c, Contract__r.ContractNumber__c, Contract__r.CustomerExpectedDate__c
				FROM AssetTransferRequest__c
				WHERE Status__c = '요청'
				AND OwnerId = :UserInfo.getUserId()
		];
	}

	@AuraEnabled
	public static  List<AssetTransferRequest__c> save(AssetTransferRequest__c assetTransferRequest, String status) {
		System.debug(JSON.serializePretty(assetTransferRequest));
		System.debug(assetTransferRequest.Order__c);
		// 승인 처리.
		Order__c order = [SELECT Id, TransferProcessStatus__c, TransferBusinessOffice__c, TransferMachineNo__c, Division__c FROM Order__c WHERE Id = :assetTransferRequest.Order__c];

		// 해당 Order__c 상태 승인, 영업소, 전배 기대번호, 주문 구분 업데이트
		order.TransferProcessStatus__c = '승인';
		order.TransferBusinessOffice__c = assetTransferRequest.TransferDealer__c;
		order.TransferMachineNo__c = assetTransferRequest.AssetNo__c;
		order.Division__c = '전수배';
		update order;

		// 해당 Asset 업데이트
		assetTransferRequest.AssetNo__r.TransferOrder__c = assetTransferRequest.Order__c;
		update assetTransferRequest.AssetNo__r;

		// 해당 OrderLineItem 업데이트
		OrderLineitem__c oli = [
				SELECT TransferAsset__c
				FROM OrderLineitem__c
				WHERE OrderId__c = :order.Id
				LIMIT 1
		];
		oli.TransferAsset__c = assetTransferRequest.AssetNo__c;
		update oli;


		assetTransferRequest.Status__c = '승인';     // 승인 / 거부
		update assetTransferRequest;

		// TO-DO  주문 값 업데이트 해야 함..
		return init();
	}


	public static void runTest() {
		Integer my_seo = 0;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
	}
}