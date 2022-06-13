/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0010_BIZ 
  * Description : IF_KR_ERP_SE_0010_BIZ list
  *               SAP 여신승인 요청 결과 처리.
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.06.15   ldb3100            Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0010_BIZ {

    private static IF_KR_ERP_SE_0010_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0010_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0010_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0010.InputBody pre(IF_KR_ERP_SE_0010.InputBody inputBody, IF_KR_ERP_SE_0010.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0010.OutputBody post(IF_KR_ERP_SE_0010.InputBody inputBody, IF_KR_ERP_SE_0010.OutputBody outputBody) {

        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            1차 승인요청 시 받은데이터 매핑, 2차는 상태값만 변경

            1차 승인요청 : ErpLNREL__c = 공란              => (변경) ErpLNREL__c = 'A' AND ErpRELDT__c = ''          -> (변경) ERPZLNST = 'A' (진행중)
                         1차 승인요청 시 전체 필드 매핑
            2차 승인완료 : ErpLNREL__c = X                 => (변경) ErpLNREL__c = 'C' AND ErpRELDT__c = '20200622' -> (변경) ERPZLNST = 'B' (승인) OR 'C'(부결)
            2차 승인완료 수신시 ErpZLNST__c(추가여신승인 진행 상태) 값에 따라 승인 결과 확인 : B=승인 or  C=부결
            2차 승인완료 수신		Order__c.ErpCMGST__c = D 설정
		            if ErpZLNST__c = B(승인) 이면 Order__c.Status__c = "출하" 설정
		            if ErpZLNST__c = C(부결) 이면 Order__c.Status__c = "종료" 설정, Order__c.isOrderCancel__c = True 설정
        */
        List<IF_KR_ERP_SE_0010.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();
        List<Order__c> autoOrderApprovalRequests = new List<Order__c>();

        if(inputSize > 0) {
            //String tmpErpZLNSTname, tmpErpZGUBUNname, tmpErpRQINDname;
            String productCode;
            Product2 tmpProduct;
            User tmpErpPernr, tmpErpDgper;

            // 전체 Product Map
            Map<String, Product2> productsByProductCode = Dummy_IF_BatchUtil.getTargetProduct2(true);

            // 전체 User Map (User.EmployeeNumber(직원번호) 가 있는 사용자)
            Map<String, User> usersByEmployeeNumber = Dummy_IF_BatchUtil.getEmployeeNumber();

            Map<String, Order__c> orderMap = new Map<String, Order__c>();
            //Map<String, OrderApprover__c> orderLineitem_TargetMap = new Map<String, OrderApprover__c>();

            List<Order__c> orders = new List<Order__c>();
            List<OrderApprover__c> orderApprovers = new List<OrderApprover__c>();

            Set<String> orderIds = new Set<String>();

            // I/F에서 받은 데이터
            for (IF_KR_ERP_SE_0010.INPUT_T_DATA temp : inputList) {
                if(String.isNotBlank(temp.SalesDocNo))          orderIds.add(temp.SalesDocNo);
            }

            // Order Map
            for(Order__c o : [
                    SELECT  Id,
                            Name,
                            SalesDocNo__c,
                            ErpZLNNO__c,
                            ErpPERNR__c,
                            ErpZLNST__c,
                            ErpAPPRV__c,
                            ErpLAPPR__c,
                            ErpZGUBUN__c,
                            ErpZBESU__c,
                            ErpCRED_GRAD__c,
                            ErpWAERS__c,
                            ErpGUAR_AMNT_C__c,
                            ErpKLIMK_C__c,
                            ErpUSELN_C__c,
                            ErpZRATE__c,
                            ErpAPPAM_C__c,
                            ErpLNREQ_C__c,
                            ErpUSELN_F_C__c,
                            ErpZRATE_F__c,
                            ErpSUMME_C__c,
                            ErpBILIN_C__c,
                            ErpARRME_C__c,
                            ErpARRRT__c,
                            ErpINTVL0_C__c,
                            ErpINTVL1_C__c,
                            ErpINTVL2_C__c,
                            ErpINTVL3_C__c,
                            ErpINTVL4_C__c,
                            ErpINTVL5_C__c,
                            ErpLNREL__c,
                            ErpRELDT__c,
                            ErpLVORM__c,
                            ErpPOSNR__c,
                            ErpMATNR__c,
                            ProductId__c,
                            ErpMENGE__c,
                            ErpVRKME__c,
                            ErpNETPR_C__c,
                            ErpNETWR_C__c,
                            ErpSTOCK__c,
                            ErpRQIND__c,
                            ErpLVORM1__c,
                            ErpCMGST__c,
                            Status__c,
                            isOrderCancel__c,
                            BusinessOfficeRep__c
                    FROM    Order__c
                    WHERE   SalesDocNo__c IN :orderIds
            ]) {
                if(!orderMap.containsKey(o.id)) {
                    orderMap.put(o.SalesDocNo__c, o);
                }
            }

            Order__c tmpOrder;
            Boolean isGoodResponseData, isExistRecord;

            for (IF_KR_ERP_SE_0010.INPUT_T_DATA temp : inputList) {
                // 데이터 확인
                tmpOrder = orderMap.get(temp.SalesDocNo);
                // 데이터 확인 여부
                isExistRecord = tmpOrder != null ? true : false;

                /** ================================================================
                * 정상 Response 데이터 여부
                * ErpLNREL 필수 항목
                * ================================================================*/
                isGoodResponseData = String.isNotBlank(temp.ErpZLNST)
                                  && isExistRecord;

                if(isGoodResponseData == false) {
                    if(!isExistRecord) System.debug('### ' + temp.SalesDocNo + '레코드가 존재하지 않습니다.');
                    System.debug('### (필수 값 : ErpLNREL이 리턴되지 않음)');
                }
                else {
                    // 1차 승인 요청
                    if (temp.ErpZLNST == 'A') {
                        // productCode를 lpad 하여 처리
                        productCode = Dummy_IF_BatchUtil.getProductCodeLpad(temp.ErpMATNR);
                        tmpProduct = productsByProductCode.get(productCode);

                        ////////////////////////////////////// Order List
                        tmpOrder.LoanApprovalStatus__c = '';    // 결재 상태 초기화.
                        tmpOrder.ErpZLNNO__c        = temp.ErpZLNNO;
                        tmpOrder.ErpPERNR__c        = temp.ErpPERNR;
                        tmpOrder.ErpZLNST__c        = temp.ErpZLNST;
                        tmpOrder.ErpAPPRV__c        = IF_Comm.stringToDecimal(temp.ErpAPPRV);
                        tmpOrder.ErpLAPPR__c        = IF_Comm.stringToDecimal(temp.ErpLAPPR);
                        tmpOrder.ErpZGUBUN__c       = temp.ErpZGUBUN;
                        tmpOrder.ErpZBESU__c        = IF_Comm.stringToDecimal(temp.ErpZBESU);
                        tmpOrder.ErpCRED_GRAD__c    = temp.ErpCRED_GRAD;
                        tmpOrder.ErpWAERS__c        = temp.ErpWAERS;
                        tmpOrder.ErpGUAR_AMNT_C__c  = IF_Comm.stringToDecimal(temp.ErpGUAR_AMNT_C);
                        tmpOrder.ErpKLIMK_C__c      = IF_Comm.stringToDecimal(temp.ErpKLIMK_C);
                        tmpOrder.ErpUSELN_C__c      = IF_Comm.stringToDecimal(temp.ErpUSELN_C);
                        tmpOrder.ErpZRATE__c        = IF_Comm.stringToDecimal(temp.ErpZRATE);
                        tmpOrder.ErpAPPAM_C__c      = IF_Comm.stringToDecimal(temp.ErpAPPAM_C);
                        tmpOrder.ErpLNREQ_C__c      = IF_Comm.stringToDecimal(temp.ErpLNREQ_C);
                        tmpOrder.ErpUSELN_F_C__c    = IF_Comm.stringToDecimal(temp.ErpUSELN_F_C);
                        tmpOrder.ErpZRATE_F__c      = IF_Comm.stringToDecimal(temp.ErpZRATE_F);
                        tmpOrder.ErpSUMME_C__c      = IF_Comm.stringToDecimal(temp.ErpSUMME_C);
                        tmpOrder.ErpBILIN_C__c      = IF_Comm.stringToDecimal(temp.ErpBILIN_C);
                        tmpOrder.ErpARRME_C__c      = IF_Comm.stringToDecimal(temp.ErpARRME_C);
                        tmpOrder.ErpARRRT__c        = IF_Comm.stringToDecimal(temp.ErpARRRT);
                        tmpOrder.ErpINTVL0_C__c     = IF_Comm.stringToDecimal(temp.ErpINTVL0_C);
                        tmpOrder.ErpINTVL1_C__c     = IF_Comm.stringToDecimal(temp.ErpINTVL1_C);
                        tmpOrder.ErpINTVL2_C__c     = IF_Comm.stringToDecimal(temp.ErpINTVL2_C);
                        tmpOrder.ErpINTVL3_C__c     = IF_Comm.stringToDecimal(temp.ErpINTVL3_C);
                        tmpOrder.ErpINTVL4_C__c     = IF_Comm.stringToDecimal(temp.ErpINTVL4_C);
                        tmpOrder.ErpINTVL5_C__c     = IF_Comm.stringToDecimal(temp.ErpINTVL5_C);
                        tmpOrder.ErpLNREL__c        = temp.ErpLNREL;
                        tmpOrder.ErpRELDT__c        = temp.ErpRELDT;
                        tmpOrder.ErpLVORM__c        = temp.ErpLVORM;
                        tmpOrder.ErpPOSNR__c        = temp.ErpPOSNR;
                        tmpOrder.ErpMATNR__c        = temp.ErpMATNR;
                        tmpOrder.ProductId__c       = (tmpProduct != null) ? tmpProduct.Id : null;
                        tmpOrder.ErpMENGE__c        = IF_Comm.stringToDecimal(temp.ErpMENGE);
                        tmpOrder.ErpVRKME__c        = temp.ErpVRKME;
                        tmpOrder.ErpNETPR_C__c      = IF_Comm.stringToDecimal(temp.ErpNETPR_C);
                        tmpOrder.ErpNETWR_C__c      = IF_Comm.stringToDecimal(temp.ErpNETWR_C);
                        tmpOrder.ErpSTOCK__c        = IF_Comm.stringToDecimal(temp.ErpSTOCK);
                        tmpOrder.ErpRQIND__c        = temp.ErpRQIND;
                        tmpOrder.ErpLVORM1__c       = temp.ErpLVORM1;


                        ///////////////////// Detail Data INSERT 처리 (OrderApprover 생성)
                        List<IF_KR_ERP_SE_0010.DETAIL_DATA> input_detail_list = temp.Detail;

                        if(input_detail_list.size() > 0) {
                            
                            OrderApprover__c tmpOrderApprover;

                            for (IF_KR_ERP_SE_0010.DETAIL_DATA tempDetail : input_detail_list) {
                                tmpOrderApprover = new OrderApprover__c();

                                // User.EmployeeNumber(직원번호)와 일치하는 사용자
                                tmpErpPernr = (usersByEmployeeNumber.get(tempDetail.ErpPERNR) != null) ? usersByEmployeeNumber.get(tempDetail.ErpPERNR) : null;
                                tmpErpDgper = (usersByEmployeeNumber.get(tempDetail.ErpDGPER) != null) ? usersByEmployeeNumber.get(tempDetail.ErpDGPER) : null;

                                String erpPernrId = (tmpErpPernr !=null) ? tmpErpPernr.Id : null;
                                String erpDgperId = (tmpErpDgper !=null) ? tmpErpDgper.Id : null;

                                tmpOrderApprover.ExternalKey__c     = tmpOrder.Id +'_'+ erpPernrId;         // 'Order ID'_'승인자 ID'
                                tmpOrderApprover.ErpZLNNO__c        = tempDetail.ErpZLNNO;
                                tmpOrderApprover.ErpAPPRV__c        = tempDetail.ErpAPPRV;
                                tmpOrderApprover.ErpPERNR__c        = tempDetail.ErpPERNR;
                                tmpOrderApprover.ErpUNAME__c        = tempDetail.ErpUNAME;
                                tmpOrderApprover.ErpDGPER__c        = tempDetail.ErpDGPER;
                                tmpOrderApprover.ErpDGATE__c        = tempDetail.ErpDGATE;
                                tmpOrderApprover.ErpDGTFR__c        = tempDetail.ErpDGTFR;
                                tmpOrderApprover.ErpDGTTO__c        = tempDetail.ErpDGTTO;

                                // 재요청이 오므로 초기화 시킨다.
                                tmpOrderApprover.ErpZLADD__c = '';                                        // 코멘트
                                tmpOrderApprover.ErpAPSTA__c = '';                                        // 승인여부
                                tmpOrderApprover.ErpAPDAT__c = '';                                        // 승인일
                                tmpOrderApprover.ErpAPTIM__c = '';                                        // 승인시간

                                tmpOrder.ERPApprovalStatus1__c  = 'N';                                    // 승인자1 승인 상태
                                tmpOrder.ERPApprovalStatus2__c  = 'N';                                    // 승인자2 승인 상태
                                tmpOrder.ERPApprovalStatus3__c  = 'N';                                    // 승인자3 승인 상태
                                tmpOrder.ERPApprovalStatus4__c  = 'N';                                    // 승인자4 승인 상태
                                tmpOrder.ERPApprovalStatus5__c  = 'N';                                    // 승인자5 승인 상태

                                tmpOrderApprover.OrderSellIn__c     = (orderMap.get(temp.SalesDocNo).Id) !=null ? orderMap.get(temp.SalesDocNo).Id : null;

                                tmpOrderApprover.ErpPERNR_UserId__c = erpPernrId;
                                tmpOrderApprover.ErpDGPER_UserId__c = erpDgperId;

                                orderApprovers.add(tmpOrderApprover);

                                // OrderApprover 승인차수에 따른 여신승인자, 위임승인자 Order__c Update
                                // 로직 변경 : https://i2max.lightning.force.com/lightning/r/0D50o00009xwgk9CAA/view


                                if(tempDetail.ErpAPPRV == '0001') {
                                    tmpOrder.LoanApprover1__c       = erpPernrId;
                                    tmpOrder.LoanApprover1_1__c     = erpDgperId != null ? erpDgperId : erpPernrId;
                                }
                                if(tempDetail.ErpAPPRV == '0002') {
                                    tmpOrder.LoanApprover2__c       = erpPernrId;
                                    tmpOrder.LoanApprover2_1__c     = erpDgperId != null ? erpDgperId : erpPernrId;
                                }
                                if(tempDetail.ErpAPPRV == '0003') {
                                    tmpOrder.LoanApprover3__c       = erpPernrId;
                                    tmpOrder.LoanApprover3_1__c     = erpDgperId != null ? erpDgperId : erpPernrId;
                                    tmpOrder.ERPApprovalStatus2__c  = 'N';
                                }
                                if(tempDetail.ErpAPPRV == '0004') {
                                    tmpOrder.LoanApprover4__c       = erpPernrId;
                                    tmpOrder.LoanApprover4_1__c     = erpDgperId != null ? erpDgperId : erpPernrId;
                                }
                                if(tempDetail.ErpAPPRV == '0005') {
                                    tmpOrder.LoanApprover5__c       = erpPernrId;
                                    tmpOrder.LoanApprover5_1__c     = erpDgperId != null ? erpDgperId : erpPernrId;
                                }
                            }
                        }

                        // 2022-04-22
                        // 자동 취소가 안되었을 경우를 위해 승인 취소 이후에 재 승인 요청 되도록 함.
                        List<ProcessInstanceWorkitem> piwiList = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: tmpOrder.Id];
                        if(piwiList != null && piwiList.size() > 0) {
                            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                            req.setAction('Removed');
                            req.setWorkitemId(piwiList[0].Id);
                            Approval.process(req, false);
                        }

                        // 자동 승인 요청 처리.
                        // 2021-09-01
                        autoOrderApprovalRequests.add(tmpOrder);
                    }

                    // 2차 승인 완료시 상태값만 변경
                    if (temp.ErpZLNST == 'B' || temp.ErpZLNST == 'C') {
                        tmpOrder.ErpZLNST__c = temp.ErpZLNST;
                        // 승인
                        if (temp.ErpZLNST == 'B') {
                            tmpOrder.ErpCMGST__c = 'D';
                            tmpOrder.Status__c = '출하';
                            tmpOrder.SystemStatus__c = '출하';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
                            tmpOrder.LoanApprovalStatus__c = '승인';
                        }
                        // 부결
                       if (temp.ErpZLNST == 'C') {
                           tmpOrder.ErpCMGST__c = 'B';
                           tmpOrder.LoanApprovalStatus__c = '반려';
                           tmpOrder.ErpZLNNO__c = null;      // 여신번호

                           // ITVOC-2021-06-0367 수정 처리
                           // 노티
/*                            tmpOrder.Status__c = '종료';
                            tmpOrder.SystemStatus__c = '종료';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
                            tmpOrder.isOrderCancel__c = true;*/
                        }
                        if(tmpOrder.BusinessOfficeRep__c != null) {
                            I2ComCustomNotiService.send(new I2ComCustomNotiService.NotiVO(
                                    tmpOrder.Id,
                                    '[추가여신승인 알림] 주문번호 : ' + tmpOrder.Name,
                                    '' + tmpOrder.Name + '에 대한 여신승인요청건이 ' + tmpOrder.LoanApprovalStatus__c + ' 처리 되었습니다.',
                                    new Set<String>{
                                            tmpOrder.BusinessOfficeRep__c
                                    }
                            ));
                        }
                    }
                    orders.add(tmpOrder);
                }
            }

            System.debug('### orders : '+orders + ' ::: ' + orders.size());
            System.debug('### orderApprovers : '+orderApprovers + ' ::: ' + orderApprovers.size());
            if(orders.size() > 0)           update orders;
            if(orderApprovers.size() > 0)   {
                upsert orderApprovers ExternalKey__c;
            }

            if(autoOrderApprovalRequests.isEmpty() == false) {
                // 자동 승인 요청.
                for(Order__c r : autoOrderApprovalRequests) {
                    // 1분후 스케쥴러를 통해서 승인요청
                    // 스케쥴러 명 : OrderLoanApprovalRequest='+recordId;
                    OrderLoanApprovalRequest_sc.runSchedule(r.Id);
                    //OrderService.loanApprovalRequest(r.Id);
                }
            }

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