/****************************************************************************************
  * @filename      : orderERPSendQa
  * @projectname   :
  * @author        : i2max.seo
  * @date          : 2020-04-16
  * @group         :
  * @group-content :
  * @description   :
  *         // 주문 구분 : Division__c = 공장주문, 판매문서번호 : SalesDocNo__c == null
            // 상태 : Status__c = 대리점 주문 신청,영업소 주문 검토,본사 주문 검토,본사 주문 확정,본사 여신 검토,출하
  *
  * @tester        : orderERPSendQa_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-16      i2max.seo      Create
    0.2     2020-12-09      i2max.seo      전수배 주문 포함.
****************************************************************************************/
public with sharing class orderERPSendQa {

    /**
     * 초기 거래 데이터
     */
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public Order__c order {get;set;}
        @AuraEnabled public String defaultVSTEL {get;set;}
        @AuraEnabled public Boolean isOrderSend {get;set;}
        @AuraEnabled public Boolean isTransferOrder {
            get {
                return ( order.Division__c == '전수배' ) ? true : false;
                // && order.Division__c == '공장주문'
            }
            set;
        }
        @AuraEnabled public String validMessage {
            get {
                String message = '';
                if (!isOrderSend && String.isEmpty(order.SalesDocNo__c) == false) {
                    message = 'ERP 주문 신청이 완료된 건 입니다.';
  /*              } else if (order.Division__c != '공장주문') {
                    message = '공장주문만 ERP 전송이 가능 합니다.';*/
                } else if (order.Status__c == '본사 여신 검토' || order.Status__c == '출하') {
                    message = '이미 ERP 주문 신청이 처리 되었습니다.';
                } else if (order.AssetTransferAgreeStatus__c == '요청') {
                    message = '전수배 전환 동의 요청 중 상태여서 ERP 전송이 불가합니다.';
                } else {
                    message = '영업소 주문 확정 상태에서만 ERP 전송이 가능 합니다.';
                }
                return message;
            }
            set;
        }
    }

    public static String getVSTEL(String param) {
        Map<String, String> VSTELMap = new Map<String, String>();
        VSTELMap.put('71A', 'M621');        // M621경기
        VSTELMap.put('71C', 'M622');        // M622충북
        VSTELMap.put('71E', 'M623');        // M623전북
        VSTELMap.put('71G', 'M624');        // M624경북
        VSTELMap.put('71B', 'M625');        // M625강원
        VSTELMap.put('71D', 'M626');        // M626충남
        VSTELMap.put('71F', 'M627');        // M627전남
        VSTELMap.put('71H', 'M628');        // M628경남
        if(VSTELMap.containsKey(param)) return VSTELMap.get(param);
        return '';
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
        initData.defaultVSTEL = 'M620';
        initData.isOrderSend = false;
        initData.order = [
                SELECT Id, VSTEL__c, Division__c, TransferBusinessOffice__r.BusinessOfficeName__c,
                        AssetTransferAgreeStatus__c, TransferProcessStatus__c, SalesDocNo__c, Status__c, BusinessOffice__r.BusinessOfficeName__c
                FROM Order__c WHERE Id =: recordId
        ];
        if((String.isEmpty(initData.order.SalesDocNo__c) == true && initData.order.Status__c == '영업소 주문 확정' )) {
            if(String.isNotEmpty(initData.order.AssetTransferAgreeStatus__c)) {
                if(initData.order.AssetTransferAgreeStatus__c == '승인' && (initData.order.TransferProcessStatus__c == '승인' || initData.order.TransferProcessStatus__c == '거부')) {
                    // 전배 전환 동의 및 전배 승인이 완료 되어야 한다.
                    initData.isOrderSend = true;
                }
            } else {
                initData.isOrderSend = true;
            }
        }
        if(String.isEmpty(initData.order.VSTEL__c) == false) {
            initData.defaultVSTEL = initData.order.VSTEL__c;
        } else {
            if(initData.order.Division__c == '전수배') {
                initData.defaultVSTEL = getVSTEL(initData.order.TransferBusinessOffice__r.BusinessOfficeName__c);
            }
        }
        return initData;
    }

    /**
 * 주문 전송 to ERP
 *
 * @param recordId : Order__c 의 RecordId
 */
    @AuraEnabled
    public static Id save(final Order__c order) {
        update order;
        return order.Id;
    }

    /**
     * 주문 전송 to ERP
     *
     * @param recordId : Order__c 의 RecordId
     */
    @AuraEnabled
    public static Map<String, String> sendERP(final String recordId) {
        Map<String, String> returnMap = new Map<String, String>();
        returnMap = OrderService.IF_KR_SE_ERP_0007(recordId);
//        returnMap.put('STATUS','Y');
        return returnMap;
    }

    @AuraEnabled
    public static Map<String, String> sendERPNew(final String recordId, final Boolean isTransferOrder) {
        Map<String, String> returnMap = new Map<String, String>();
        System.debug(isTransferOrder + '==>' + isTransferOrder);

        Order__c order = [SELECT Id, SalesDocNo__c FROM Order__c WHERE Id =: recordId];
        if(String.isEmpty(order.SalesDocNo__c) == false) {
            throw new AuraHandledException('이미 ERP 주문 처리가 완료 되었습니다');
        }

        if(isTransferOrder == true) {
            // 전수배 ZORT
            returnMap = OrderService.IF_KR_SE_ERP_0007_ZORT(recordId);
            if(returnMap.get('STATUS') == 'Y') {
                System.debug('------------2');
                setTransferOrder(recordId);
            }
        } else {
            // 기존 OR 주문
            returnMap = OrderService.IF_KR_SE_ERP_0007(recordId);
        }
        return returnMap;
    }

    /**
     * 전수배 정상 주문 처리 후 출고 주문을 생성한다.
     *
     * @param recordId
     */
    public static void setTransferOrder(String recordId) {
        // 정상 처리 되었으면 전수배 반품 처리할 레코드를 생성 한다.
        List<OrderLineitem__c> inputOrderLineitems = [
                SELECT  Id,
                        ProductId__c,
                        ProductId__r.ProductCode,
                        OrderId__c,
                        OrderId__r.BusinessOffice__r.SalesGroupCode__c,
                        OrderId__r.TransferBusinessOffice__c,
                        OrderId__r.Name,
                        OrderId__r.fm_SoldToErpCode__c,
                        OrderId__r.fm_SupplyToErpCode__c,
                        OrderId__r.TransferMachineNo__r.DealerReceiptDate__c,
                        OrderId__r.TransferMachineNo__r.Account.CustomerType__c,
                        OrderId__r.TransferMachineNo__r.Order__r.PriceDecisionDate__c,
                        OrderId__r.ERP_Code__c
                FROM OrderLineitem__c
                WHERE OrderId__c = :recordId
        ];

        if(inputOrderLineitems.isEmpty() == false) {

            OrderLineitem__c orderLineitem = inputOrderLineitems[0];
            Order__c order = orderLineitem.OrderId__r;

            TransferOrder__c tOrder = new TransferOrder__c();
            tOrder.Order__c = order.Id;
            tOrder.OrderLineitem__c = orderLineitem.Id;
            tOrder.Product__c = orderLineitem.ProductId__c;
            tOrder.TransferDealer__c = order.TransferBusinessOffice__c;
            tOrder.Status__c = '대상';
            tOrder.PriceDecisionDate__c = order.TransferMachineNo__r.Order__r.PriceDecisionDate__c;

            String priceType = null;
            if(order.TransferMachineNo__r.Account.CustomerType__c == '농협') {
                priceType = 'FD';
            } else if(order.TransferMachineNo__r.Account.CustomerType__c == '관납') {
                priceType = 'FE';
            } else {
                priceType = 'FC';
            }
            List<ProductPriceEntry__c> productPriceEntries =  [
                    SELECT Id, PriceType__c,
                            BasePrice__c,
                            StartDate__c,
                            EndDate__c
                    FROM ProductPriceEntry__c
                    WHERE StartDate__c <= :order.TransferMachineNo__r.Order__r.PriceDecisionDate__c
                    AND EndDate__c >= :order.TransferMachineNo__r.Order__r.PriceDecisionDate__c
                    AND Product__c = :orderLineitem.ProductId__c
                    AND PriceType__c = :priceType
                    ORDER BY StartDate__c DESC
                    LIMIT 1
            ];

            if(productPriceEntries.isEmpty() == false) {
                tOrder.BaseSellingPrice__c = productPriceEntries[0].BasePrice__c;
                tOrder.SellingPrice__c = tOrder.BaseSellingPrice__c;
                tOrder.CorrectionPrice__c = 0;
            }
            //tOrder.
            insert tOrder;
            System.debug('------------1');
        }
    }

}