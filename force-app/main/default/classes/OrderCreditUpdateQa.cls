/**
** @filename     : OrderCreditUpdateQa
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-09-04 오후 4:41
* @group         :
* @group-content :
* @description   :
* @tester        :
* @reference     :
* @copyright     : Copyright © I2max. All Rights Reserved.
* @modification Log
* ===============================================================
* ver     date             author              description
* ===============================================================
  0.1                            Create
 */
public with sharing class OrderCreditUpdateQa {

    @AuraEnabled
    public static Order__c init(String recordId) {
        Order__c ord = [
                SELECT Id, SalesDocNo__c, PurposeOfOrder__c, ErpZLNNO__c, ErpLRESN_T__c, ErpLPLAN_T__c, ErpLFDBK_T__c, Status__c, ErpZLNST__c
                FROM Order__c
                WHERE Id = :recordId
        ];
        return ord;
    }

    @AuraEnabled
    public static String save(Order__c order){

        String returnMessage = '';
        String zflag = 'I';
        if(order.ErpZLNNO__c != NULL) zflag = 'A';
        IF_KR_SE_ERP_0040.OutputDIH result = call_IF_KR_SE_ERP_0040(order, zflag);
        System.debug(JSON.serializePretty(result));
        if(result.response.header.ifResult == 'S') {
            // 성공
            for (IF_KR_SE_ERP_0040.OUTPUT_T_DATA temp : result.Response.payload.t_data) {
                if(temp.ZLNNO != null) {
                    order.ErpZLNNO__c = temp.ZLNNO;
                } else {
                    returnMessage = '추가여신 문서 생성 실패';
                }
            }
        } else {
            // 실패
            returnMessage = '추가여신 문서 생성 I/F 실패';
            if(result.response.header.ifFailMsg != null) {
                returnMessage = result.response.header.ifFailMsg;
            }
        }

        // 주문이 있고, 여신문서번호가 있는 경우만 업데이트
        // 아니면 화면에서 오류 처리.
        if(order != null && String.isEmpty(order.ErpZLNNO__c) == false) update order;
        return returnMessage;
    }


    /**
	 * 여신 한도 승인 문서 생성
	 *
	 * @param recordId : Order__c 의 RecordId
	 */
    @AuraEnabled
    public static IF_KR_SE_ERP_0040.OutputDIH call_IF_KR_SE_ERP_0040(final Order__c order, String zflag) {

        User user = [SELECT Id, EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()];

        OrderLineitem__c oli = [SELECT Id FROM OrderLineitem__c WHERE OrderId__c = :order.Id LIMIT 1];

        IF_KR_SE_ERP_0040 instance = IF_KR_SE_ERP_0040.getInstance();
        // 서비스 실행
        IF_KR_SE_ERP_0040.InputDIH input = new IF_KR_SE_ERP_0040.InputDIH();
        IF_KR_SE_ERP_0040.INPUT_T_DATA tData = new IF_KR_SE_ERP_0040.INPUT_T_DATA();

        tData.SE_REQ_HEADER_NO   = order.Id;
        tData.ZFLAG              = zflag;
        tData.PERNR              = user.EmployeeNumber;
        tData.ZLNNO              = '';
        tData.SE_REQ_ITEM_NO     = order.Id;
        tData.SE_REQ_ITEM        = oli.Id;
        tData.VBELN              = order.SalesDocNo__c;
        tData.POSNR              = '000010';
        tData.RQIND              = order.PurposeOfOrder__c == '재고보충' ? 'F' : 'G';
        tData.REMARK             = '';

        // 연체 사유
        IF_KR_SE_ERP_0040.DETAIL_DATA detail = new IF_KR_SE_ERP_0040.DETAIL_DATA();
        detail.SE_REQ_TEXT_NO    = order.Id;
        detail.TDID              = 'Z001';
        detail.ZSEQ              = '0001';
        detail.TDLINE            = order.ErpLRESN_T__c;
        tData.Detail.add(detail);

        // 수금계획 : ErpLPLAN_T__c
        IF_KR_SE_ERP_0040.DETAIL_DATA detail2 = new IF_KR_SE_ERP_0040.DETAIL_DATA();
        detail2.SE_REQ_TEXT_NO    = order.Id;
        detail2.TDID              = 'Z002';
        detail2.ZSEQ              = '0002';
        detail2.TDLINE            = order.ErpLPLAN_T__c;
        tData.Detail.add(detail2);

        // 담당자 코멘트
        IF_KR_SE_ERP_0040.DETAIL_DATA detail3 = new IF_KR_SE_ERP_0040.DETAIL_DATA();
        detail2.SE_REQ_TEXT_NO    = order.Id;
        detail2.TDID              = 'Z004';
        detail2.ZSEQ              = '0003';
        detail2.TDLINE            = order.ErpLFDBK_T__c;
        tData.Detail.add(detail3);

        input.request.payload.t_data.add(tData);

        System.debug('result input : '+ JSON.serialize(input));

        return instance.execute(input);

    }
}