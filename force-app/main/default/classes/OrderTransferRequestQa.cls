/****************************************************************************************
  * @filename      : OrderTransferRequestQa
  * @author        : i2max_my.Seo 
  * @date          : 2020-11-19 오후 12:46
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OrderTransferRequestQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-11-19 오후 12:46     i2max_my.Seo           Create
****************************************************************************************/
public without sharing class OrderTransferRequestQa {

    /**
     * Wrapper class for InitData
     */
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled
        public AssetTransferRequest__c assetTransferRequest {get;set;}
        @AuraEnabled
        public Boolean isTransferAgree {get;set;}
        @AuraEnabled
        public Boolean isRequestProcess {get;set;}
        @AuraEnabled
        public Boolean isNhGovAccount {get;set;}
        @AuraEnabled
        public String  notiMessage {get;set;}
    }

    /**
     * Init method
     *
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static I2ComClass.InitData init(final String recordId) {
        InitData initData = new InitData();

        Order__c order = [
                SELECT Id, OrderAccount__r.CustomerType__c, Dealer__c, TransferProcessStatus__c, AssetTransferAgreeStatus__c
                FROM Order__c
                WHERE Id = :recordId
        ];

        List<OrderLineitem__c> orderLineitemList = [
                SELECT Id, OrderId__c, OrderId__r.Dealer__c, OrderId__r.TransferProcessStatus__c, OrderId__r.AssetTransferAgreeStatus__c,
                       ProductId__c, ProductId__r.Name
                FROM OrderLineitem__c
                WHERE OrderId__c = :recordId
                LIMIT 1
        ];

        List<AssetTransferRequest__c> assetTransferRequestList = [
                SELECT Id, Status__c
                FROM AssetTransferRequest__c
                WHERE Order__c = :recordId
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];

        if(order.AssetTransferAgreeStatus__c == '승인') {
            initData.isTransferAgree = true;

            if(orderLineitemList.size() > 0) {
                if(assetTransferRequestList.isEmpty() == false && assetTransferRequestList[0].Status__c != '거부') {
                    AssetTransferRequest__c atr = assetTransferRequestList[0];
                    initData.isRequestProcess = true;
                    if(assetTransferRequestList[0].Status__c == '요청') initData.notiMessage = '이미 해당 주문에 대한 전배 ['+atr.Status__c+'] 중입니다.';
                    if(assetTransferRequestList[0].Status__c == '승인') initData.notiMessage = '해당 주문에 대한 전배 요청이 ['+atr.Status__c+'] 처리 되었습니다. 전수배 주문 진행 해주세요.';
                } else {
                    initData.isRequestProcess = false;  // 진행 가능.
                    initData.assetTransferRequest = new AssetTransferRequest__c(
                            Status__c = '요청',
                            Order__c = orderLineitemList[0].OrderId__c,
                            Order__r = orderLineitemList[0].OrderId__r,
                            WantedDealer__c = orderLineitemList[0].OrderId__r.Dealer__c,
                            Model__c = orderLineitemList[0].ProductId__c,
                            Model__r = orderLineitemList[0].ProductId__r
                    );
                }

            }
        } else {
            initData.isTransferAgree = false;
            if(order.AssetTransferAgreeStatus__c == '거부') {
                initData.notiMessage = '전수배 주문 전환 거부한건 입니다. 공장 주문으로 진행 해주세요.';
            } else {
                initData.notiMessage = '전수배 주문 전환 대상건이 아니거나 수배 대리점의 전수배 주문 전환 동의 처리가 되지 않은 건입니다.';
            }
        }

        return initData;
    }

    /**
     * Save
     *
     * @param assetTransferRequest : AssetTransferRequest__c
     *
     * @return String : Id
     */
    @AuraEnabled
    public static String save(AssetTransferRequest__c assetTransferRequest) {

        Set<String> nhGovCheck = new Set<String>{
                '농협', '관납'
        };

        if(assetTransferRequest.AssetNo__c == null) {
            throw new AuraHandledException('전배 대상이 지정 되지 않았습니다.');
        }

        Asset transAsset = [SELECT Id, Account.CustomerType__c, Account.OwnerId FROM Asset WHERE Id = :assetTransferRequest.AssetNo__c];
        Account transferAccount = [SELECT OwnerId, Owner.ManagerId FROM Account WHERE Id = :assetTransferRequest.TransferDealer__c];

//        System.debug(JSON.serializePretty(transAsset));

        Boolean isNhGovAccount = false;
        if(nhGovCheck.contains(transAsset.Account.CustomerType__c)) {
            // 고객이 농협 관납이면 자동 승인 처리.
            // 전배 요청 레코드의 소유자는 농협관납고객의 담당자로 지정.
            isNhGovAccount = true;
            assetTransferRequest.Status__c = '승인';
            assetTransferRequest.Order__r.TransferProcessStatus__c = '승인';
            assetTransferRequest.Order__r.TransferBusinessOffice__c = assetTransferRequest.TransferDealer__c;
            assetTransferRequest.Order__r.TransferMachineNo__c = assetTransferRequest.AssetNo__c;
            assetTransferRequest.Order__r.Division__c = '전수배';
            assetTransferRequest.OwnerId = transAsset.Account.OwnerId;
            assetTransferRequest.DealerSalesOwner__c   = transferAccount.OwnerId;             // 전배 대리점 영업사원
            assetTransferRequest.DealerSalesManager__c = transferAccount.Owner.ManagerId;     // 전배 대리점 영업소장

            // 해당 Asset 업데이트
//            assetTransferRequest.AssetNo__r.TransferOrder__c = assetTransferRequest.Order__c;
//            update assetTransferRequest.AssetNo__r;

            // 해당 OrderLineItem 업데이트
            update assetTransferRequest.Order__r;
            assetTransferRequest.Order__r = null;

            OrderLineitem__c oli = [
                    SELECT TransferAsset__c
                    FROM OrderLineitem__c
                    WHERE OrderId__c = :assetTransferRequest.Order__c
                    LIMIT 1
            ];
            oli.TransferAsset__c = assetTransferRequest.AssetNo__c;
            update oli;
        } else {
            assetTransferRequest.Order__r.TransferProcessStatus__c = '요청';
            update assetTransferRequest.Order__r;

            assetTransferRequest.Order__r = null;
            assetTransferRequest.Model__r = null;
            assetTransferRequest.DealerSalesOwner__c   = transferAccount.OwnerId;             // 전배 대리점 영업사원
            assetTransferRequest.DealerSalesManager__c = transferAccount.Owner.ManagerId;     // 전배 대리점 영업소장

        }
        System.debug(JSON.serializePretty(assetTransferRequest));
        insert assetTransferRequest;
        return assetTransferRequest.Id;
    }
}