/****************************************************************************************
  * @filename      : OrderCancelQa
  * @author        : I2MAX
  * @date          : 2021-05-10
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OrderCancelQa_ts.cls
  * @reference     : 
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author        description
  * ===============================================================
    1.0     2021-05-10          I2MAX           Create
****************************************************************************************/
public without sharing class OrderCancelQa {

    /**
     * Init method
     *
     * @param orderId String
     *
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static Order__c init(String orderId) {
        return [
                SELECT Id, SalesDocNo__c, IsZRET__c, isOrderCancel__c, Status__c, SystemStatus__c, Division__c, ERPOrderCancelStatus__c
                FROM Order__c
                WHERE Id = :orderId
        ];
    }

    /**
     * save method
     *
     * @param order Order__c
     */
    @AuraEnabled
    public static Order__c save(Order__c order) {

        order.isOrderCancel__c = true;
        order.Status__c = '종료';
        order.SystemStatus__c = '종료';

        update order;

        return order;
    }

    /**
     * callIF method
     *
     * @param order Order__c
     */
    @AuraEnabled
    public static Order__c callIF(Order__c order, String callType) {
        Map<String, String> returnMap = new Map<String, String>();

        if ('OR'.equals(callType)) {
            returnMap = OrderServiceIF.OrderCancel_OR(order.Id);
            if(returnMap != null && returnMap.get('STATUS') == 'Y') {
                order.isOrderCancel__c = true;
                order.Status__c = '종료';
                order.SystemStatus__c = '종료';
            }
        } else if('ZORT'.equals(callType)) {
            if(order.ERPOrderCancelStatus__c == 'ZORT 취소성공' || order.ERPOrderCancelStatus__c == 'ZRET 취소실패') {
                // ZORT 성공 이므로 ZRET만 처리 한다.
                returnMap.put('STATUS','Y');
                returnMap.put('MESSAGE','ZORT 취소 정상처리');
            } else {
                returnMap = OrderServiceIF.OrderCancel_ZORT(order.Id);
            }
        } else {
            // ZRET
            // 반푼 주문이 완료 된 상태이어야만 처리.
            if(order.ERPOrderCancelStatus__c != 'ZRET 취소성공' && order.IsZRET__c == true) {
                returnMap = OrderServiceIF.OrderCancel_ZRET(order.Id);
            } else {
                // ZRET 성공 이므로 데이터 저장만 처리 한다.
                returnMap.put('STATUS','Y');
                returnMap.put('MESSAGE','ZRET 취소 정상처리');
            }
        }

        if(returnMap != null && returnMap.get('STATUS') == 'Y') order.ERPOrderCancelStatus__c = callType+' 취소성공';
        else                                                    order.ERPOrderCancelStatus__c = callType+' 취소실패';
        order.ERPOrderCancelMessage__c = returnMap.get('MESSAGE').left(255);
        update order;

        return order;
    }

}