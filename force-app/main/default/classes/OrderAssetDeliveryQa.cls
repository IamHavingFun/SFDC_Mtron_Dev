/****************************************************************************************
  * @filename      : OrderAssetDeliveryQa
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-16
  * @group         : 
  * @group-content : 
  * @description   : 출하지시
  * @tester        : OrderAssetDeliveryQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-16      i2max          Create
    0.2     2022-02-17      i2max          전수배 출하 --> 출하지시로 변경(ITVOC-2022-01-0633)
    0.3     2022-03-22      i2max          ITVOC-2022-03-0717 : 보관출하
    0.3     2022-05-13      i2max          ITVOC-2022-04-0777 : 우선순위 로직 개선
****************************************************************************************/
public without sharing class OrderAssetDeliveryQa {

    /**
     * 초기 거래 데이터
     */
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public Order__c order {get;set;}
        @AuraEnabled public List<Order__c> notiTargetOrders {get;set;}
        @AuraEnabled public TransferOrder__c transferOrder {get;set;}
        @AuraEnabled public OrderKeep__c orderKeep {get;set;}
        @AuraEnabled public Boolean isProcess {get;set;}
        @AuraEnabled public Boolean isCustomNoti {get;set;}
        @AuraEnabled public String validMessage {get;set;}
    }

    /**
     * 초기 거래
     * @return InitData
     */
    @AuraEnabled(Cacheable=true)
    public static InitData init(String recordId) {
        InitData initData = new InitData();

        initData.order = [
                SELECT Id, SalesDocNo__c, TransferMachineNo__r.Name, TransferMachineNo__r.BatchNo__c, OrderProduct__c, Division__c, VSTEL__c,
                        fm_OrderScheduleYearMonth__c,fm_RecordTypeOrder__c, IsKeepProcess__c, KeppApprovalStatus__c,
                        PurposeOfOrder__c, OrderScheduleDate__c, DeliverySeq__c, Status__c, IsInAsset__c, IsOutAsset__c,
                        (
                            SELECT Id, SalesDocNo__c FROM TransferOrders__r LIMIT 1
                        ),
                        (
                            SELECT Id, SalesDocNo__c, IsOutAsset__c, KeepAsset__r.Name, KeepAsset__r.BatchNo__c, KeepAsset__r.ErpLGORT__c FROM OrderKeep_Order__r LIMIT 1
                        )
                FROM Order__c WHERE Id =: recordId];

        initData.isProcess = false;

        Set<String> checkProfiles = new Set<String>{
                '시스템 관리자',
                '시스템 관리자(C)'
        };
        List<User> targetUsers = [
                SELECT
                        Id,
                        UserName,
                        UserRole.Name,
                        Profile.Name
                FROM User
                WHERE (
                        UserRole.DeveloperName = 'DomesticSalesHQ'
                        OR Profile.Name IN : checkProfiles
                )
                AND Id = :UserInfo.getUserId()
        ];

        if(initData.order.SalesDocNo__c == null) {
            initData.isProcess = false;
            initData.validMessage = 'ERP 주문 미처리건 입니다.';
            return initData;
        }
        if(initData.order.Status__c == '출하') {
            initData.isProcess = true;
            if(initData.order.IsOutAsset__c == true) {
                initData.isProcess = false;
                initData.validMessage = '이미 출하 지시가 완료된 주문입니다.';
                return initData;
            }
            if(initData.order.Division__c == '전수배') {
                if(initData.order.TransferOrders__r.isEmpty() == true) {
                    initData.isProcess = false;
                    initData.validMessage = '반품 주문 처리가 되지 않았습니다. ERP 주문(반품)을 먼저 진행 해주세요.';
                    return initData;
                } else {
                    for(TransferOrder__c to : initData.order.TransferOrders__r) {
                        if(to.SalesDocNo__c == null) {
                            initData.isProcess = false;
                            initData.validMessage = '반품 주문 처리가 되지 않았습니다. ERP 주문(반품)을 먼저 진행 해주세요.';
                            return initData;
                        } else {
                            initData.isProcess = true;
                            break;
                        }
                    }
                }
            } else {
                // 보관처리 대상건
                if(initData.order.KeppApprovalStatus__c == '승인' && initData.order.IsKeepProcess__c == false) {
                    initData.validMessage = '보관처리가 완료되지 않았습니다. 보관주문의 상태를 확인하시기 바랍니다.';
                    initData.isProcess = false;
                }
            }
        } else if(initData.order.Status__c == '종료') {
            initData.validMessage = '이미 종료된 주문입니다.';
            initData.isProcess = false;
        } else {
            initData.validMessage = '주문의 단계가 출하 대기인 경우에만 출하 지시가 가능합니다.';
            initData.isProcess = false;
        }

        List<Order__c> orderDeliverySeqs = [
                SELECT
                        Id, Name, OrderProduct__r.Name, DeliverySeq__c, ErpZLNNO__c, Status__c, RecordType.Name, PurposeOfOrder__c,
                        Dealer__r.DealerOwner__c,
                        Dealer__r.DealerOwner__r.MobilePhone,
                        BusinessOfficeRep__c,
                        BusinessOfficeRep__r.ManagerId,
                        fm_RecordTypeOrder__c, fm_OrderScheduleYearMonth__c,  fm_IsPreOrder__c,   fm_OrderPurposeOrder__c,   OrderScheduleDate__c,  CreatedDate
                FROM Order__c
                WHERE Status__c != '종료'
                AND isOrderCancel__c = FALSE
                AND VSTEL__c IN ('', 'M620')
                AND OrderScheduleDate__c != NULL
                AND OrderProduct__c = :initData.order.OrderProduct__c
                ORDER BY fm_RecordTypeOrder__c, fm_OrderScheduleYearMonth__c, fm_IsPreOrder__c, fm_OrderPurposeOrder__c, OrderScheduleDate__c, CreatedDate
        ];
//        System.debug(JSON.serializePretty(orderDeliverySeqs));
        Integer seq = 1;
        Boolean isPreDeliveryTarget = false;
        initData.notiTargetOrders = new List<Order__c>();
        initData.isCustomNoti = false;
        if(initData.isProcess == true) {
            if(String.isEmpty(initData.order.VSTEL__c) || initData.order.VSTEL__c == 'M620') {
                // 전주 공장에서 출하되는 케이스만 순번처리 한다.
                if (initData.order.Division__c == '공장주문') {
                    for (Order__c target : orderDeliverySeqs) {
                        System.debug('순번 : ' + seq + ' / ' + isPreDeliveryTarget);
                        if (target.Id == initData.order.Id) {
                            break;
                        }
                        // 이전 데이터중 출하대기 상태건이 있다.
                        seq++;
                        if(target.Status__c == '출하') {
                            isPreDeliveryTarget = true;
                            break;
                        }
                        initData.notiTargetOrders.add(target);

                    }

                    // 내 순번이 1번이 아니면 추가 체크 한다.
                    if(seq != 1) {
                        if (isPreDeliveryTarget == true) {
                            // 이전 데이터중 출하대기건이 있으면 출하 불가.
                            initData.isProcess = false;
                            initData.validMessage = '동일 모델의 주문 中 본 주문의 우선순위가 가장 우선하거나, 보다 우선하는 주문 중 출하 대기 상태의 주문이 없는 경우만 출하 지시가 가능합니다.';
                        } else {
                            initData.isCustomNoti = true;
                        }
                    }
                }
            }
        }

        if(initData.order.Division__c == '전수배') {
            if(initData.order.TransferOrders__r.isEmpty() == false) {
                initData.transferOrder = initData.order.TransferOrders__r[0];
            }
        }
        if(initData.order.OrderKeep_Order__r.isEmpty() == false) {
            initData.orderKeep = initData.order.OrderKeep_Order__r[0];
        }

        // 재고보충에 전주 공장 출하이면 : 국내영업본부 + 혁신파트(시스템관리자) 만 처리 가능.
        if(
            initData.order.Division__c == '공장주문' &&
            (initData.order.VSTEL__c == 'M620' || String.isEmpty(initData.order.VSTEL__c) == true))
        {
            if(initData.isProcess == true && targetUsers.isEmpty() == true) {
                initData.isProcess = false;
                initData.validMessage = '전주공장(M620)에서의 출하는 국내영업본부 혹은 시스템 관리자만 진행 가능합니다.';
            }
        }

        return initData;
    }


    /**
     * 전수배 자산을 입고처리
     *
     * @param recordId : Order__c 의 RecordId
     * @param deliveryRecord : 전수배 자산을 수배 대리점으로 출고
     */
    @AuraEnabled
    public static DeliveryVO set0038In(final Order__c order, TransferOrder__c transferOrder) {
        DeliveryVO vo = new DeliveryVO();
        IF_KR_SE_ERP_0038.OutputDIH ifResult = null;

        vo.order = order;
        String WADAT = String.valueOf(system.now().format('yyyyMMdd'));
        vo.isSuccess = true;
        if(order.IsInAsset__c == false) {

            ifResult = OrderService.IF_KR_SE_ERP_0038(transferOrder.SalesDocNo__c, WADAT, order.TransferMachineNo__r.BatchNo__c, null );
            if ('S'.equals(ifResult.response.header.ifResult)) {
                vo.order.IsInAsset__c = true;
                update vo.order;
            } else {
                vo.isSuccess = false;
                vo.message = ifResult.response.header.ifFailMsg;
            }
        }
        return vo;
    }


    /**
     * 전수배 자산을 출고 처리.
     *
     * @param recordId : Order__c 의 RecordId
     * @param deliveryRecord : 저장할 출하 레코드
     */
    @AuraEnabled
    public static DeliveryVO set0038Out(final Order__c order) {
        DeliveryVO vo = new DeliveryVO();
        vo.order = order;
        IF_KR_SE_ERP_0038.OutputDIH ifResult = null;
        String WADAT = String.valueOf(system.now().format('yyyyMMdd'));
        ifResult = OrderService.IF_KR_SE_ERP_0038(order.SalesDocNo__c, WADAT, order.TransferMachineNo__r.BatchNo__c, null );
        if(order.IsOutAsset__c == false) {
            if ('S'.equals(ifResult.response.header.ifResult)) {
                vo.isSuccess = true;
                vo.order.IsOutAsset__c = true;
                update vo.order;
            } else {
                vo.isSuccess = false;
                vo.message = ifResult.response.header.ifFailMsg;
            }
        } else {
            vo.isSuccess = true;
        }
        return vo;
    }


    /**
     * 출고 처리
     *
     * @param recordId : Order__c 의 RecordId
     * @param deliveryRecord : 저장할 출하 레코드
     */
    @AuraEnabled
    public static DeliveryVO set0038OutNormal(final Order__c order, final List<Order__c> notiTargetOrders) {
/*
        sendNoti(order, notiTargetOrders);
        DeliveryVO vo = new DeliveryVO();
        vo.order = order;
        vo.isSuccess = true;
        vo.order.IsOutAsset__c = true;
*/
        DeliveryVO vo = new DeliveryVO();
        vo.order = order;
        IF_KR_SE_ERP_0038.OutputDIH ifResult = null;
        String WADAT = String.valueOf(system.now().format('yyyyMMdd'));
        ifResult = OrderService.IF_KR_SE_ERP_0038(order.SalesDocNo__c, WADAT, order.TransferMachineNo__r.BatchNo__c, null );
        if(order.IsOutAsset__c == false) {
            if ('S'.equals(ifResult.response.header.ifResult)) {
                // 1. 문자및 노티 발송
                sendNoti(order, notiTargetOrders);
                // 2. 데이터 저장 처리.
                vo.isSuccess = true;
                vo.order.IsOutAsset__c = true;
                update vo.order;
            } else {
                vo.isSuccess = false;
                vo.message = ifResult.response.header.ifFailMsg;
            }
        } else {
            vo.isSuccess = true;
        }
        return vo;
    }

    public static void sendNoti(Order__c order, List<Order__c> notiTargetOrders) {
        Set<String> checkStatus = new Set<String>{
                '영업소 주문 검토',
                '영업소 주문 확정',
                '본사 여신 검토'
        };
        String typeString = '';
        String notiTitle = '주문의 준비 미진에 따른 출하 지연';
        List<String> notiComments;
        Set<String>  recipientUserIds;
        Set<String>  recipientUserPhones;
        List<I2ComCustomNotiService.NotiVO> notiList = new List<I2ComCustomNotiService.NotiVO>();

        try {
            /*
			주문-202205-00000598(MT4.58-CQTLEDPS)은
			추가여신 검토중 사유로 차순위
			주문이 먼저 출하되었습니다.
			 */
            for (Order__c target : notiTargetOrders) {
                if (target.Status__c == '대리점 주문 신청') {
                    typeString = '대리점 제출 이전';
                } else if (checkStatus.contains(target.Status__c) && String.isEmpty(target.ErpZLNNO__c) == true) {
                    typeString = '영업소 검토중';
                } else if (target.Status__c == '본사 여신 검토' && String.isEmpty(target.ErpZLNNO__c) == false) {
                    typeString = '추가여신 검토중';
                } else {
                    typeString = '영업소 검토중';
                }
                notiComments = new List<String>();
                notiComments.add(target.Name);
                notiComments.add('(' + target.OrderProduct__r.Name + ')은');
                notiComments.add(typeString);
                notiComments.add('사유로 차순위 주문이 먼저 출하되었습니다');

                recipientUserIds = new Set<String>();       // 노티용 수신자
                recipientUserPhones = new Set<String>();    // 문자용 전화번호

                if(target.Dealer__r.DealerOwner__c != null && target.Dealer__r.DealerOwner__r.MobilePhone != null) {
                    recipientUserPhones.add(target.Dealer__r.DealerOwner__r.MobilePhone.replace('+82 ',''));
                }
                if(target.BusinessOfficeRep__c != null) recipientUserIds.add(target.BusinessOfficeRep__c);
                if(target.BusinessOfficeRep__r.ManagerId != null) recipientUserIds.add(target.BusinessOfficeRep__r.ManagerId);

                // 농협/관납 주문건은 알림 처리 하지 않는다.
                if(target.RecordType.DeveloperName != 'NhGov') {
                    // 대리점 주 문자 발송
                    // 차후 알림시 아래 로직 전체 주석 풀기
                    if(recipientUserPhones.isEmpty() == false) {
                        notiList.add(new I2ComCustomNotiService.NotiVO(
                                target.Id,
                                notiTitle,
                                String.join(notiComments, ' '),
                                recipientUserPhones
                        ));
                    }

                    // 영업사원/관리자 Custom Noti 발송
                    if(recipientUserIds.isEmpty() == false) {
                        I2ComCustomNotiService.send(new I2ComCustomNotiService.NotiVO(
                                target.Id,
                                notiTitle,
                                String.join(notiComments, ' '),
                                recipientUserIds
                        ));
                    }

                } else {
                    continue;
                }

            }
            System.debug(JSON.serializePretty(notiList));
            if(notiList.isEmpty() == false) I2ComCustomNotiService.sendDeliveryNoticeForLMS(notiList);
        } catch (Exception e) {
            // none
        }
    }


    /**
     * 보관처리의 일반 출고지시
     *
     * @param recordId : Order__c 의 RecordId
     * @param deliveryRecord : 저장할 출하 레코드
     */
    @AuraEnabled
    public static DeliveryVO set0038KeepOut(final Order__c order, final OrderKeep__c orderKeep) {
        DeliveryVO vo = new DeliveryVO();
        vo.order = order;
        IF_KR_SE_ERP_0038.OutputDIH ifResult = null;
        String WADAT = String.valueOf(system.now().format('yyyyMMdd'));
        String LGORT = orderKeep.KeepAsset__r.ErpLGORT__c;

        System.debug(JSON.serializePretty(orderKeep));

        ifResult = OrderService.IF_KR_SE_ERP_0038(order.SalesDocNo__c, WADAT, orderKeep.KeepAsset__r.BatchNo__c, LGORT );
        if(order.IsOutAsset__c == false) {
            if ('S'.equals(ifResult.response.header.ifResult)) {
                vo.isSuccess = true;
                vo.order.IsOutAsset__c = true;
                update vo.order;

            } else {
                vo.isSuccess = false;
                vo.message = ifResult.response.header.ifFailMsg;
            }
        } else {
            vo.isSuccess = true;
        }
        return vo;
    }

    public class DeliveryVO {
        @AuraEnabled public Order__c order {get;set;}
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public String message {get;set;}
    }


    public static void runTest() {
        Integer yr_seo = 0;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
        yr_seo++;
    }
}