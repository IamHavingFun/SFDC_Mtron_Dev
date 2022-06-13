/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0008_BIZ 
  * Description : IF_KR_ERP_SE_0008_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.06.18   ldb3100            Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0008_BIZ {

    private static IF_KR_ERP_SE_0008_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0008_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0008_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0008.InputBody pre(IF_KR_ERP_SE_0008.InputBody inputBody, IF_KR_ERP_SE_0008.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0008.OutputBody post(IF_KR_ERP_SE_0008.InputBody inputBody, IF_KR_ERP_SE_0008.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            [Order__c] 업데이트
            SalesDocNo__c(판매문서) 기준 조회 & ErpCMGST__c (ERP 여신 상태) = B
            ErpLVORM__c		    IF.ErpLVORM__c 설정
            Status__c		    if IF.ErpLVORM__c = X 이면 "종료" 설정
            isOrderCancel__c	if IF.ErpLVORM__c = X 이면 True 설정
        */
        List<IF_KR_ERP_SE_0008.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();

        if(inputSize > 0) {
            Map<String, Order__c> orderMap = new Map<String, Order__c>();
            List<Order__c> orders = new List<Order__c>();
            Set<String> orderIds = new Set<String>();

            // I/F에서 받은 데이터
            for (IF_KR_ERP_SE_0008.INPUT_T_DATA temp : inputList) {
                if(String.isNotBlank(temp.SalesDocNo))          orderIds.add(temp.SalesDocNo);
            }

            // Order Map
            for(Order__c o : [
                    SELECT  Id, SalesDocNo__c, ErpLVORM__c, Status__c, isOrderCancel__c
                    FROM    Order__c
                    WHERE   SalesDocNo__c IN :orderIds
                    AND     ErpCMGST__c = 'B'
            ]) {
                if(!orderMap.containsKey(o.id)) {
                    orderMap.put(o.SalesDocNo__c, o);
                }
            }

            Order__c tmpOrder;
            Boolean isGoodResponseData, isExistRecord;

            for (IF_KR_ERP_SE_0008.INPUT_T_DATA temp : inputList) {
                // 데이터 확인
                tmpOrder = orderMap.get(temp.SalesDocNo);
                // 데이터 확인 여부
                isExistRecord = tmpOrder != null ? true : false;

                /** ================================================================
                * 정상 Response 데이터 여부
                *
                * ================================================================*/
                isGoodResponseData = isExistRecord;

                if(isGoodResponseData == false) {
                    if (!isExistRecord) System.debug('### ' + temp.SalesDocNo + '레코드가 존재하지 않습니다.');
                }
                else {
                    ////////////////////////////////////// Order List
                    tmpOrder.ErpLVORM__c = temp.ErpLVORM;

                    if (temp.ErpLVORM == 'X') {

/*                        tmpOrder.Status__c = '종료';
                        tmpOrder.SystemStatus__c = '종료';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
                        tmpOrder.isOrderCancel__c = true;*/
                    }
                    orders.add(tmpOrder);
                }
            }

            System.debug('### orders : '+orders + ' ::: ' + orders.size());
            if(orders.size() > 0) update orders;

            outputBody.ifAggregation = IF_Comm.convertEmpty(inputBody.ifAggregation);
            outputBody.ifSplitCnt = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
            outputBody.ifRcvCnt = String.valueOf(inputSize);
        }

        /*
            END 샘플 CODE
        */
        
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return outputBody;
    }
    
}