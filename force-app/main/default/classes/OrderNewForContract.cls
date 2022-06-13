/****************************************************************************************
  * @filename      : OrderNewForContract
  * @author        : i2max_my.Seo 
  * @date          : 2020-12-14 오후 2:05
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OrderNewForContract_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-12-14 오후 2:05     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class OrderNewForContract {

    /**
     * Wrapper class for InitData
     */
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled
        public OrderNewQa.WrapperData wrapperData {
            get {
                if(this.wrapperData == null) {
                    this.wrapperData = new OrderNewQa.WrapperData();
                }

                return this.wrapperData;
            }
            set;
        }
    }

    /**
     * Init method
     *
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static I2ComClass.InitData init() {
        InitData initData = new InitData();

        initData.wrapperData.order.Status__c = '종료';
        initData.wrapperData.order.DeliveryDate__c = System.today();
        initData.wrapperData.order.RecordTypeId = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Order__c'
                AND DeveloperName = 'NhGov'
        ].Id;
        initData.wrapperData.orderLineItemList[0].RecordTypeId = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'OrderLineitem__c'
                AND DeveloperName = 'NhGov'
        ].Id;

        return initData;
    }

    @AuraEnabled
    public static String save(OrderNewQa.WrapperData wrapperData) {
        Account tempAcc = [
                SELECT Id, BusinessOffice__c, BusinessOffice__r.SalesGroupCode__c, Dealer__c, OwnerId
                FROM Account
                WHERE Id = :wrapperData.order.OrderAccount__c
        ];

        // 대리점
        wrapperData.order.Dealer__c = tempAcc.Dealer__c;
        // 대리점 담당자
        wrapperData.order.DealerRep__c = ModelUser.getDealerUserId(wrapperData.order.Dealer__c);
        // 영업소
        wrapperData.order.BusinessOffice__c = tempAcc.BusinessOffice__c;
        // 영업소 담당자
        wrapperData.order.BusinessOfficeRep__c = tempAcc.OwnerId;
        // 영업조직
        wrapperData.order.ErpVKORG__c = '3000';
        // 유통경로
        wrapperData.order.ErpVTWEG__c = '10';
        // 제품군
        wrapperData.order.ErpSPART__c = '71';
        // 영업팀
        wrapperData.order.ErpVKBUR__c = '5600';
        // 영업그룹
        wrapperData.order.ErpVKGRP__c = tempAcc.BusinessOffice__r.SalesGroupCode__c;
        // 주문 유형
        wrapperData.order.ErpAUART__c = 'OR';

        insert wrapperData.order;

        wrapperData.orderLineItemList[0].ProductId__r = null;
        wrapperData.orderLineItemList[0].OrderId__c = wrapperData.order.Id;

        insert wrapperData.orderLineItemList[0];

        wrapperData.order.IsDummyContractOrder__c = true;

        update wrapperData.order;

        return wrapperData.order.Id;
    }

    @AuraEnabled
    public static String getTargetSoldToId(String accountId) {
        return OrderService.getTargetSoldToId(accountId);
    }
}