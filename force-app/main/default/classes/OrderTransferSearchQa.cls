/****************************************************************************************
  * @filename      : OrderTransferSearchQa
  * @author        : i2max_my.Seo 
  * @date          : 2020-11-19 오후 12:28
  * @group         : 
  * @group-content : 
  * @description   : 전수배 대상 조회
  * @tester        : OrderTransferSearchQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-11-19 오후 12:28     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class OrderTransferSearchQa {

    public class InitData {
        @AuraEnabled
        public String currentUserBusinessOfficeName {get;private set;}
        @AuraEnabled
        public List<I2ComClass.Option> businessOfficeNameList {
            get {
                if(this.businessOfficeNameList == null) {
                    this.businessOfficeNameList = new List<I2ComClass.Option>();

                    for(Schema.PicklistEntry sp : Account.getSObjectType().getDescribe().fields.getMap().get('BusinessOfficeName__c').getDescribe().getPicklistValues()) {
                        if(!sp.getLabel().equals('영업지원')) {
                            this.businessOfficeNameList.add(new I2ComClass.Option(sp.getLabel(), sp.getValue()));
                        }
                    }
                }

                return this.businessOfficeNameList;
            }
            private set;
        }
        @AuraEnabled
        public List<OrderTransferSearchQa.WrapperData> wrapperDataList {
            get {
                if(this.wrapperDataList == null) {
                    this.wrapperDataList = new List<OrderTransferSearchQa.WrapperData>();
                }

                return this.wrapperDataList;
            }
            private set;
        }
    }

    /**
     * Wrapper Class for Asset
     */
    public class WrapperData{
        @AuraEnabled
        public Asset asset {get;private set;}
        @AuraEnabled
        public String assetTransferStatus {get;private set;}
        @AuraEnabled
        public Boolean isSamOffice {get;private set;}
        @AuraEnabled
        public final Boolean isRejected {
            get {
                return (this.assetTransferStatus != null && this.assetTransferStatus.equals('거부')) ? true : false;
            }
            private set;
        }
    }

    @AuraEnabled
    public static InitData init(final String productId, final String orderId, final Map<String, String> reqData) {
        InitData initData = new InitData();

        final String currentBusinessOfficeName = String.isNotBlank(getBusinessOfficeName(orderId)) ? getBusinessOfficeName(orderId) : '71A';

        reqData.put('businessOfficeName', currentBusinessOfficeName);

        initData.wrapperDataList = search(productId, orderId, reqData);
        initData.currentUserBusinessOfficeName = currentBusinessOfficeName;

        return initData;
    }


    /**
     * Search method
     *
     * @return List<OrderTransferSearchQa.WrapperData>
     */
    @AuraEnabled
    public static List<OrderTransferSearchQa.WrapperData> search(final String productId, final String orderId, final Map<String, String> reqData) {
        User currentUser = ModelUser.getUserData();
        List<Asset> assetList;
        List<OrderTransferSearchQa.WrapperData> wrapperDataList = new List<OrderTransferSearchQa.WrapperData>();

        Order__c order = [SELECT Id, OrderAccount__r.CustomerType__c, Dealer__c, BusinessOffice__r.ERPCode__c FROM Order__c WHERE Id = :orderId];

        String query = 'SELECT Id, BusinessOffice__r.Name, BusinessOffice__r.ERPCode__c,' +
                'Dealer__c, Dealer__r.Name, Dealer__r.DealerOwner__c, Dealer__r.BusinessOffice__r.ERPCode__c, Account.CustomerType__c, ' +
                'Name, ProductionDate__c, Product2.Name, fm_DistributionStockExpiration__c ' +
                'FROM Asset ' +
                'WHERE InventoryType__c = \'대리점재고\' ' +
                'AND ( TransferCount__c < 2 OR TransferCount__c = NULL ) ' +
                'AND Product2Id = :productId ' +
                'AND DealerReceiptDate__c < THIS_MONTH ' +
                'AND (Order__c = NULL OR Order__r.Status__c = \'종료\' ) ' +
                'AND Dealer__c != NULL ' +
                'AND Dealer__c != \''+order.Dealer__c+'\' ';
/*
        String query = 'SELECT Id, BusinessOfficeName__c, BusinessOffice__r.Name, BusinessOffice__r.ERPCode__c,' +
                       'Dealer__c, Dealer__r.Name, Dealer__r.DealerOwner__c, Dealer__r.BusinessOffice__r.ERPCode__c, Account.CustomerType__c, ' +
                       'Name, ProductionDate__c, Product2.Name, IsSendReceiveItem__c, fm_DistributionStockExpiration__c ' +
                       'FROM Asset ' +
                       'WHERE InventoryType__c = \'대리점재고\' ' +
                       'AND (DealerReceiptType__c = \'공장주문\' OR (DealerReceiptType__c = \'전수배주문\' AND IsAddTransferApprove__c = TRUE )) '+
                       'AND ( TransferCount__c < 2 OR TransferCount__c = NULL ) ' +
                       'AND Product2Id = :productId ' +
                       'AND DealerReceiptDate__c < THIS_MONTH ' +
                       'AND (TransferOrder__c = NULL OR TransferOrder__r.Status__c = \'종료\' ) ' +
                       'AND (Order__c = NULL OR Order__r.Status__c = \'종료\' ) ' +
                       'AND Dealer__c != NULL ' +
                       'AND Dealer__c != \''+order.Dealer__c+'\' ';
*/

        if(String.isNotBlank(reqData.get('businessOfficeName'))) {
            query += 'AND BusinessOffice__r.ERPCode__c = \'' + reqData.get('businessOfficeName') + '\' ';
        } else {
            query += 'AND BusinessOffice__r.ERPCode__c = \'' + currentUser.BusinessOffice__c + '\'';
        }
/*        if(String.isNotBlank(reqData.get('assetTransferTarget'))) {
            query += 'AND IsSendReceiveItem__c = ' + reqData.get('assetTransferTarget') + '\n';
        }*/
        if(String.isNotBlank(reqData.get('assetName'))) {
            final String likeIdioms = '\'%' + String.escapeSingleQuotes(reqData.get('assetName')) + '%\'';
            query += 'AND Name LIKE ' + likeIdioms;
        }

        query += 'ORDER BY BusinessOffice__r.Name ASC, ProductionDate__c DESC ';

        assetList = Database.query(query);

        List<AssetTransferRequest__c> assetTransferRequests = [
                SELECT AssetNo__r.Name, Status__c
                FROM AssetTransferRequest__c
                WHERE Order__c = :orderId
        ];

        Map<String, String> assetTransferRequestMap = new Map<String, String>();

        for(AssetTransferRequest__c r : assetTransferRequests) {
            assetTransferRequestMap.put(r.AssetNo__r.Name, r.Status__c);
        }

        Set<String> nhGovCheck = new Set<String>{
                '농협', '관납'
        };
        for(Asset asset : assetList) {
            WrapperData wrapperData = new WrapperData();
            wrapperData.asset = asset;
            wrapperData.isSamOffice = false;
            System.debug(order.OrderAccount__r.CustomerType__c + ' / ' + asset.Account.CustomerType__c + ' / ' + asset.Dealer__r.BusinessOffice__r.ERPCode__c + ' / ' + order.BusinessOffice__r.ERPCode__c);
            if(nhGovCheck.contains(order.OrderAccount__r.CustomerType__c) == false &&
                    nhGovCheck.contains(asset.Account.CustomerType__c) &&
                    asset.Dealer__r.BusinessOffice__r.ERPCode__c == order.BusinessOffice__r.ERPCode__c) {
                // 주문 고객이 대리점이면서
                wrapperData.isSamOffice = true;
            }
            if(assetTransferRequestMap.containsKey(asset.Name)) {
                wrapperData.assetTransferStatus = assetTransferRequestMap.get(asset.Name);
            }
            wrapperDataList.add(wrapperData);
        }
        System.debug(JSON.serializePretty(wrapperDataList));
        return wrapperDataList;
    }

    private static String getBusinessOfficeName(String orderId) {
        return [SELECT BusinessOffice__r.BusinessOfficeName__c FROM Order__c WHERE Id = :orderId]?.BusinessOffice__r.BusinessOfficeName__c;
    }
}