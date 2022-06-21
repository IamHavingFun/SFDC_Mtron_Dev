/**
 * Created by MS on 2021-12-08.
 */

public without sharing class IF_KR_ERP_SE_0042_Service {

	public static void createDeliveryRecords(List<IF_KR_ERP_SE_0042.INPUT_T_DATA> inputList)  {

		Set<String> assetNos = new Set<String>();
		Set<String> dealerCodes = new Set<String>();
		for (IF_KR_ERP_SE_0042.INPUT_T_DATA temp : inputList) {
			assetNos.add(temp.CHARG);
			dealerCodes.add(temp.KUNNR_TO);
			dealerCodes.add(temp.KUNNR_FROM);
		}
		Map<String, Asset> assetMap = new Map<String, Asset>();
		for(Asset r : [
				SELECT Id, Name, BatchNo__c, Dealer__c, Order__c, BusinessOffice__c, DealerCode__c, OwnerId, AccountId, Product2Id, Product2.ProductCode
				FROM Asset
				WHERE BatchNo__c IN : assetNos
		]) {
			assetMap.put(r.BatchNo__c, r);
		}
		Map<String, Account> accountMap = new Map<String, Account>();
		for(Account r : [
				SELECT Id, Name, Dealer__c, ERPCode__c, BusinessOffice__c, BusinessOffice__r.ERPCode__c, OwnerId, DealerOwner__c, CustomerType__c,
						Dealer__r.OwnerId, Dealer__r.ERPCode__c, Dealer__r.DealerOwner__c, Dealer__r.BusinessOffice__c,
						Dealer__r.BusinessOffice__r.ERPCode__c
				FROM Account
				WHERE ERPCode__c IN : dealerCodes
		]) {
			accountMap.put(r.ERPCode__c, r);
		}

		List<Delivery__c> upsertDeliveries = new List<Delivery__c>();
		Asset asset;
		Account dealer;
		for (IF_KR_ERP_SE_0042.INPUT_T_DATA temp : inputList) {
			dealer = new Account();
			if(temp.ZREASON != '03') {
				if (accountMap.containsKey(temp.KUNNR_TO)) {
					dealer = accountMap.get(temp.KUNNR_TO);
				} else {
					throw new IF_Base.IFException('대리점 정보 없음 : [' + temp.KUNNR_TO + ']');
				}
			}
			if(temp.ZREASON == '03') {
				if (accountMap.containsKey(temp.KUNNR_FROM)) {
					dealer = accountMap.get(temp.KUNNR_FROM);
				} else {
					throw new IF_Base.IFException('대리점 정보 없음 : [' + temp.KUNNR_FROM + ']');
				}
			}
			asset = null;
			if(assetMap.containsKey(temp.CHARG)) {
				asset = assetMap.get(temp.CHARG);
				if(temp.ZREASON == '01') {
					// 대리점 이관
					if(asset.Dealer__c == asset.AccountId) {
						asset.AccountId = dealer.Id;
					}
					asset.DealerCode__c = dealer.ERPCode__c;
					asset.Dealer__c = dealer.Id;
					asset.OwnerId = dealer.DealerOwner__c == null ? dealer.OwnerId : dealer.DealerOwner__c;
					asset.BusinessOffice__c = dealer.BusinessOffice__c;
				} else if(temp.ZREASON == '02') {
					// 농협 이관.
					if(dealer.CustomerType__c != '농협') {
						throw new IF_Base.IFException('농협판매기대 대리점 지정 사유에 대해서는 지역 단위 농협으로의 이관만 가능합니다.');
					}
					asset.AccountId = dealer.Id;
					asset.DealerCode__c = dealer.Dealer__r.ERPCode__c;
					asset.Dealer__c = dealer.Dealer__c;
					asset.OwnerId = dealer.Dealer__r.DealerOwner__c == null ? dealer.Dealer__r.OwnerId : dealer.Dealer__r.DealerOwner__c;
					asset.BusinessOffice__c = dealer.Dealer__r.BusinessOffice__c;
				} else if(temp.ZREASON == '03') {
					// 농협경제지주 주식회사 자재부 재 이관. : 소유자 : 최상현
					asset.AccountId = dealer.Id;
					asset.DealerCode__c = dealer.ERPCode__c;
					asset.Dealer__c = dealer.Id;
					asset.OwnerId = dealer.OwnerId;
					asset.BusinessOffice__c = dealer.BusinessOffice__c;
				}
			} else {
				throw new IF_Base.IFException('기대번호 없음 : ['+temp.CHARG+']');
			}

			String deliveryType = '';
			if(temp.ZREASON == '01') deliveryType = '대리점 이관';
			else if(temp.ZREASON == '02') deliveryType = '보관재고 이관';
			else if(temp.ZREASON == '03') deliveryType = '보관재고 환입';

			// 01: 대리점 이관, 02: 보관재고 이관
			Delivery__c tmpDelivery = new Delivery__c();
			tmpDelivery.Externalkey__c = temp.CHARG + '|' + temp.KUNNR_FROM + '|' +  temp.KUNNR_TO + '|' + temp.ZREASON;
			if(temp.ZREASON == '01') {
				tmpDelivery.OwnerId = dealer.DealerOwner__c == null ? dealer.OwnerId : dealer.DealerOwner__c;
				tmpDelivery.Dealer__c = dealer.Id;
				tmpDelivery.BusinessOffice__c = dealer.BusinessOffice__c;
			} else if(temp.ZREASON == '02') {
				tmpDelivery.OwnerId = dealer.Dealer__r.DealerOwner__c == null ? dealer.Dealer__r.OwnerId : dealer.Dealer__r.DealerOwner__c;
				tmpDelivery.Dealer__c = dealer.Dealer__c;
				tmpDelivery.BusinessOffice__c = dealer.Dealer__r.BusinessOffice__c;
			} else if(temp.ZREASON == '03') {
				tmpDelivery.OwnerId = dealer.OwnerId;       // 농협경제지주의 소유자를 지정
				tmpDelivery.Dealer__c = dealer.Id;          // 농협경제지주를 대리점으로 지정
				tmpDelivery.BusinessOffice__c = dealer.BusinessOffice__c;
			}
			tmpDelivery.AssetId__c = asset == null ? null : asset.Id;
			tmpDelivery.Division__c = ''; // 멀로 지정 하지;
			tmpDelivery.AssetIdApex__c = asset.BatchNo__c;
			tmpDelivery.DeliveryType__c = deliveryType;
			tmpDelivery.DeliveryName__c = '';
			tmpDelivery.DeliveryCode__c = '';
			tmpDelivery.ProductCode__c = asset.Product2.ProductCode;
			tmpDelivery.ProductName__c = asset.Product2Id;
			tmpDelivery.DateOfLoading__c = Datetime.now();
			tmpDelivery.CarrierName__c = '';
			tmpDelivery.CarrierContact__c = '';
			tmpDelivery.CarNumber__c = '';
			tmpDelivery.GetOffDate__c = Date.today();
			tmpDelivery.SalesDocNo__c = '';
			tmpDelivery.SalesDocItem__c = '';
			tmpDelivery.DeliveryDocNo__c = '';
			tmpDelivery.DeliveryDocItem__c = '';
			tmpDelivery.ErpIV_NO__c = '';
			tmpDelivery.ErpIV_SEQ__c = '';
			tmpDelivery.ErpIV_TYPE__c = '';
			tmpDelivery.ErpOUT_YN__c = '';
			tmpDelivery.ErpOUT_DATE__c = '';
			tmpDelivery.ErpOUT_TIME__c = '';
			tmpDelivery.ErpCANCEL_DATE__c = '';
			tmpDelivery.ErpCANCEL_TIME__c = '';
			tmpDelivery.SoldTo__c = dealer.Id;
			tmpDelivery.SoldToCode__c = temp.KUNNR_FROM;
			tmpDelivery.OrderSellIn__c = asset.Order__c;    // 주문 연결
			tmpDelivery.IsProcessed__c = true;
			upsertDeliveries.add(tmpDelivery);
		}

		if(assetMap.isEmpty() == false) update assetMap.values();
		if(upsertDeliveries.isEmpty() == false) upsert upsertDeliveries Delivery__c.Externalkey__c;

	}
}