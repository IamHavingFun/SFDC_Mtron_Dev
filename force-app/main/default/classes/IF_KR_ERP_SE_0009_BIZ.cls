/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0009_BIZ 
  * Description : IF_KR_ERP_SE_0009_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.06.19   ldb3100            Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0009_BIZ {

    private static IF_KR_ERP_SE_0009_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0009_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0009_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0009.InputBody pre(IF_KR_ERP_SE_0009.InputBody inputBody, IF_KR_ERP_SE_0009.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작
        /*
            값할당 샘플
        */          
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return inputBody;
    }
    
    /**
     * post logic
     */
    public IF_KR_ERP_SE_0009.OutputBody post(IF_KR_ERP_SE_0009.InputBody inputBody, IF_KR_ERP_SE_0009.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            [Order__c] Update
            OrderID__c      : 주문ID
            ErpZTERM__c		: IF.ErpZTERM__c 설정
            SalesDocNo__c	: IF.SalesDocNo__c 설정
            ErpCMGST__c		: IF.ErpCMGST__c 설정
            ErpABGRU__c		: IF.ErpABGRU__c 설정
            ErpS_RESULT__c	: IF.ErpS_RESULT__c 설정
            ErpS_MESSAGE__c	: IF.ErpS_MESSAGE__c 설정
            Status__c		: if IF.ErpCMGST__c = B 이면 "본사 여신 검토" 설정
                              if IF.ErpCMGST__c = A, D 이면 "출하" 설정

            [OrderLineItemID__c] Update
            OrderID__c      : 주문ID
            ErpPOSNR__c		: IF.ErpPOSNR__c 설정
        */
        List<IF_KR_ERP_SE_0009.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();

        if(inputSize > 0) {
            Map<String, Order__c> orderMap = new Map<String, Order__c>();
            Map<String, OrderLineitem__c> orderLineitemMap = new Map<String, OrderLineitem__c>();

            List<Order__c> orders = new List<Order__c>();
            List<OrderLineitem__c> orderLineitems = new List<OrderLineitem__c>();

            Set<String> orderIds = new Set<String>();           // Order Ids

            // I/F에서 받은 데이터
            for (IF_KR_ERP_SE_0009.INPUT_T_DATA temp : inputList) {
                if(String.isNotBlank(temp.OrderID))          orderIds.add(temp.OrderID);
            }

            // Order Map
            for(Order__c o : [
                    SELECT  Id, ErpPOSNR__c, ErpZTERM__c, SalesDocNo__c, ErpCMGST__c, ErpABGRU__c, ErpS_RESULT__c, ErpS_MESSAGE__c, Status__c
                    FROM    Order__c
                    WHERE   Id IN :orderIds
            ]) {
                if(!orderMap.containsKey(o.id)) {
                    orderMap.put(o.Id, o);
                }
            }

            // OrderLineItem Map
            for(OrderLineitem__c oli : [
                    SELECT  Id, OrderId__c, ErpPOSNR__c
                    FROM    OrderLineitem__c
                    WHERE   OrderId__c IN :orderIds
            ]) {
                if(!orderLineitemMap.containsKey(oli.id)) {
                    orderLineitemMap.put(oli.Id, oli);
                }
            }

            Order__c tmpOrder;
            OrderLineitem__c tmpOrderLineitem;
            Boolean isGoodResponseData, isExistRecord;

            for (IF_KR_ERP_SE_0009.INPUT_T_DATA temp : inputList) {
                // 데이터 확인
                tmpOrder = orderMap.get(temp.OrderID);
                // 데이터 확인 여부
                isExistRecord = tmpOrder != null ? true : false;

                /** ================================================================
                * 정상 Response 데이터 여부
                * ErpPOSNR, SalesDocNo, ErpCMGST 필수 항목
                * ================================================================*/
                isGoodResponseData = String.isNotBlank(temp.ErpPOSNR)
                        && String.isNotBlank(temp.SalesDocNo)
                        && isExistRecord;

                if(isGoodResponseData == false) {
                    if(!isExistRecord) System.debug('### ' + temp.OrderID + '레코드가 존재하지 않습니다.');
                    System.debug('### 필수 값 : ErpPOSNR, SalesDocNo, ErpCMGST이 리턴되지 않음');
                    System.debug('### ErpPOSNR : ' + temp.ErpPOSNR);
                    System.debug('### SalesDocNo : ' + temp.SalesDocNo);
                }
                else {
                    ////////////////////////////////////// Order List
                    tmpOrder.ErpZTERM__c        = temp.ErpZTERM;
                    tmpOrder.SalesDocNo__c      = temp.SalesDocNo;
                    tmpOrder.ErpCMGST__c        = temp.ErpCMGST;
                    tmpOrder.ErpABGRU__c        = temp.ErpABGRU;
                    tmpOrder.ErpS_RESULT__c     = temp.ErpS_RESULT;
                    tmpOrder.ErpS_MESSAGE__c    = temp.ErpS_MESSAGE;

                    if (temp.ErpCMGST == 'B') {
                        tmpOrder.Status__c = '본사 여신 검토';
                        tmpOrder.SystemStatus__c = '본사 여신 검토';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
                    } else if (String.isEmpty(temp.ErpCMGST) || temp.ErpCMGST == 'A' || temp.ErpCMGST == 'D') {
                        tmpOrder.Status__c = '출하';
                        tmpOrder.SystemStatus__c = '출하';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
                    }
                    orders.add(tmpOrder);

                    ////////////////////////////////////// OrderLineItem List
                    tmpOrderLineitem = orderLineitemMap.get(temp.OrderLineItemID);
                    if (tmpOrderLineitem != null) {
                        tmpOrderLineitem.ErpPOSNR__c = temp.ErpPOSNR;

                        orderLineitems.add(tmpOrderLineitem);
                    }
                }
            }
            System.debug('### orders : '+orders + ' ::: ' + orders.size());
            System.debug('### orderLineitems : '+orderLineitems + ' ::: ' + orderLineitems.size());
            if(orders.size() > 0)            update orders;
            if(orderLineitems.size() > 0)    update orderLineitems;

            outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
            outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
            outputBody.ifRcvCnt         = String.valueOf(inputSize);
        }


        /*
            END 샘플 CODE
        */
        
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return outputBody;
    }
    
}