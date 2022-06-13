/****************************************************************************************
  * @filename      : Order_tr
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-05-06
  * @group         :
  * @group-content :
  * @description   : 주문 Trigger class
  * @tester        : Order_tr_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-06      i2max_my.seo   Create
    0.2     2022-03-10      i2max          ITVOC-2022-03-0696
****************************************************************************************/
public without sharing class Order_tr extends TriggerHandler {

    public override void beforeInsert() {
        this.preOrderCheckInsert((List<Order__c>)Trigger.new);
    }

    public override void beforeUpdate() {
        //============================================================================
        // 업데이트 되는 order__c 레코드에 기회를 연결하기 위해 beforeUpdate 에서 수행됨
        //============================================================================
        this.createOQCAllRecord((List<Order__c>)Trigger.new, (Map<Id, Order__c>)Trigger.newMap, (Map<Id, Order__c>)Trigger.oldMap);
        this.preOrderCheckUpdate((List<Order__c>)Trigger.new, (Map<Id, Order__c>)Trigger.oldMap);
    }

    public override void afterUpdate() {
        this.internalApprovalComplete(Trigger.new, Trigger.oldMap);
        this.loanApprovalComplete(Trigger.new, Trigger.oldMap);
        this.orderKeepApprovalComplete(Trigger.new, Trigger.oldMap);
    }


    private void preOrderCheckInsert(List<Order__c> orderList){
        for (Order__c orderTemp : orderList) {
            if(orderTemp.Status__c != '종료') {
                if(orderTemp.OrderScheduleDate__c == null) {
                    orderTemp.OrderScheduleDate__c = orderTemp.DeliveryDate__c;
                }
                if (orderTemp.OrderScheduleDate__c.toStartOfMonth() >= Date.today().toStartOfMonth().addMonths(3)) {
                    orderTemp.IsPreOrder__c = true;
                }
            }
        }
    }

    /**
     * 최초 입력 時 사전주문(납품요청월-작성월이 3 이상)인 경우, 사전주문 Field가 True이고,
        이후 납품요청월이 변경되어, 납품요청월-작성월이 3 미만이 되는 경우, 사전주문 Field가 False로 변경
        이후 다시 3 이상이 되더라도 사전주문 Field는 변경되지 않음.
        (즉, 한번 해제되고 나면, 다시 사전주문이 될 수 없음.)
     *
     * @param newList
     * @param oldMap
     */
    private void preOrderCheckUpdate(List<Order__c> newList,  Map<Id, SObject> oldMap){

        Order__c oldOrder;
        for (Order__c r : newList) {
            oldOrder = (Order__c) oldMap.get(r.Id);

            //System.debug(r.OrderScheduleDate__c.toStartOfMonth() + ' / ' + oldOrder.CreatedDate.date().toStartOfMonth().addMonths(3));
            if(r.Status__c == '종료') {
                continue;
            }
            if(r.OrderScheduleDate__c == null) {
                r.OrderScheduleDate__c = r.DeliveryDate__c;
            }
            // ITVOC-2022-03-0696
            // 사전 주문 이면서 납품요청월이 바뀌었는데 3개월 미만이 되면 사전 주문에서 제외 처리.
            if (oldOrder.IsPreOrder__c == true && r.OrderScheduleDate__c != oldOrder.OrderScheduleDate__c &&
                    r.OrderScheduleDate__c.toStartOfMonth() < oldOrder.CreatedDate.date().toStartOfMonth().addMonths(3)) {
                r.IsPreOrder__c = false;
            }
        }
    }

    /**
     * 보관처리 승인 처리.
     * 상태 : 출하 , KeppApprovalStatus__c 이 '승인' 인 데이터건만 target
     *
     * @param newList trigger new List
     */
    private void orderKeepApprovalComplete(List<Order__c> newList, Map<Id, SObject> oldMap) {
        Order__c oldOrder;
        List<OrderKeep__c> orderKeeps = new List<OrderKeep__c>();
        Set<Id> orderIds = new Set<Id>();
        for (Order__c r : newList) {
            oldOrder = (Order__c) oldMap.get(r.Id);
            if (r.Status__c == '출하' && r.KeppApprovalStatus__c != oldOrder.KeppApprovalStatus__c && r.KeppApprovalStatus__c == '승인') {
                // 보관처리 승인
                orderKeeps.add(new OrderKeep__c(
                        Order__c = r.Id,
                        Status__c = '주문입력'
                ));
                orderIds.add(r.Id);
            }
        }
        if(orderKeeps.isEmpty() == false) insert orderKeeps;

        if(orderIds.isEmpty() == false) OrderServiceIF.sendOrderKeepData(orderIds);
    }

    /**
     * 본사 주문 확정 - 본사 승인 완료
     * LoanApprovalStatus__c 이 '승인','반려' 인 데이터건만 target
     *
     * @param newList trigger new List
     */
    private void internalApprovalComplete(List<Order__c> newList, Map<Id, SObject> oldMap) {
/*
        Set<Id> orderIds = new Set<Id>();
        Map<Id, Order__c> orderApproveMap = new Map<Id, Order__c>();        // 승인건 처리
        Map<Id, Order__c> orderRejectMap = new Map<Id, Order__c>();        // 반려건 처리
        List<Asset> rejectAssets = new List<Asset>();                                // 반려시 자산 정보 초기화.
        Set<Id> approveAssets = new Set<Id>();
        Order__c oldOrder;
        System.debug('newList========================================');
        System.debug(JSON.serialize(newList));
        System.debug('========================================');
        for (Order__c r : newList) {
            oldOrder = (Order__c) oldMap.get(r.Id);
            if (r.Status__c != oldOrder.Status__c && r.Status__c == '영업소 주문 확정' && r.Division__c == '전수배') {
                orderApproveMap.put(r.Id, r);
                approveAssets.add(r.TransferMachineNo__c);
            } else if (r.Status__c != oldOrder.Status__c && r.Status__c == '종료' && r.isOrderCancel__c == true && r.Division__c == '전수배' && r.TransferMachineNo__c != null) {
                // 승인 반려시 상태 종료 변경, 주문취소 = true, 주문 구분이 전수배이면,
//                rejectAssets.add(r.TransferMachineNo__c);
                rejectAssets.add(
                        new Asset(
                                Id = r.TransferMachineNo__c,
                                TransferOrder__c = null
                        )
                );
            }
        }

        // 승인 처리 건
        System.debug('orderApproveMap========================================');
        //System.debug(JSON.serialize(orderApproveMap));
        System.debug('========================================');
        List<Task> tasks = new List<Task>();        // 전수배 대상 가이드 액션 알림
        List<Order__Share> orderShares = new List<Order__Share>();
        if(orderApproveMap.isEmpty() == false) {
            //
            Map<Id, Asset> assetSalesOwnerIdMap = new Map<Id, Asset>();
            for(Asset r : [SELECT Id, Dealer__r.Name, Dealer__r.OwnerId, Product2.Name, TransferOrder__c FROM Asset WHERE Id IN :approveAssets]) {
                assetSalesOwnerIdMap.put(r.Id, r);
            }

            for(Order__c r : orderApproveMap.values()) {
                if(assetSalesOwnerIdMap.containsKey(r.TransferMachineNo__c)) {
                    Asset asset = assetSalesOwnerIdMap.get(r.TransferMachineNo__c);
                    tasks.add(
                           new Task(
                                   OwnerId = asset.Dealer__r.OwnerId,
                                   Type__c = 'Guide',
                                   ActivityDate = System.today(),
                                   Status = 'Open',
                                   Subject = '전수배 요청',
                                   Description = asset.Dealer__r.Name + ' 대리점의 ' + asset.Product2.Name + ' 자산에 대해서 전배 요청이 있습니다.\n' +
                                           '해당 주문건에 대해서 내용 확인 하시고, 전수배 출하 처리 바랍니다.',
                                   CustomAlert__c = true
                           )
                    );

                    // 기본 공개 형이라 공유를 추가로 할 필요는 없다.
                    // 향후 영업소 끼리도 비공개 되면 주석 풀어 주자.
                    orderShares.add(
                            new Order__Share(
                                    ParentId = r.Id,
                                    AccessLevel = 'Read',
                                    RowCause = 'Manual',
                                    UserOrGroupId = asset.Dealer__r.OwnerId
                            )
                    );
                }
            }
            //if(tasks.isEmpty() == false) insert tasks;
            //if(orderShares.isEmpty() == false) insert orderShares;
        }


        // 반려 처리 건
        // 자산에 전수배 주문 정보를 초기화 한다.
        System.debug('rejectAssets========================================');
        System.debug(JSON.serialize(rejectAssets));
        System.debug('========================================');
        if(rejectAssets.isEmpty() == false) {
            update rejectAssets;
        }
*/

    }

    /**
     * 여신 승인 결과 전송.
     * LoanApprovalStatus__c 이 '승인','반려' 인 데이터건만 target
     *
     * @param newList
     * @param oldMap
     */
    private void loanApprovalComplete(List<Order__c> newList, Map<Id, SObject> oldMap) {

        Set<Id> orderIds = new Set<Id>();
        Map<Id, Order__c> orderMap = new Map<Id, Order__c>();
        Order__c oldOrder;
        System.debug('newList========================================');
//        System.debug(JSON.serialize(newList));
        System.debug('========================================');
        for(Order__c r : newList) {
            oldOrder = (Order__c) oldMap.get(r.Id);
            if(r.LoanApprovalStatus__c != oldOrder.LoanApprovalStatus__c && (r.LoanApprovalStatus__c == '승인' || r.LoanApprovalStatus__c == '반려')) {
                // ERP 승인 결과 처리 대상.
                orderMap.put(r.Id, r);
            }
        }
        System.debug('orderMap========================================');
        System.debug(JSON.serialize(orderMap));
        System.debug('========================================');
        if(orderMap.isEmpty() == false) {
            Map<String, ProcessInstanceStep> approverMap = new Map<String, ProcessInstanceStep>();
            ProcessInstanceStep pis;
            String externalKey;
            for(ProcessInstanceStep r : [
                    SELECT
                            ProcessInstance.TargetObjectId,
                            ActorId,
                            OriginalActorId,
                            Comments,
                            StepStatus,
                            SystemModstamp
                    FROM ProcessInstanceStep
                    WHERE ProcessInstance.TargetObjectId IN :orderMap.keySet()
                    AND StepStatus != 'NoResponse'
            ]) {
                externalKey = r.ProcessInstance.TargetObjectId + '_' + r.OriginalActorId;
                approverMap.put(externalKey, r);
            }
            System.debug('approverMap========================================');
            System.debug(JSON.serialize(approverMap));
            System.debug('========================================');
            List<OrderApprover__c> oaList = new List<OrderApprover__c>();
            String externalKey2 = '';
            Id LastApprover = null;
            for(Order__c r : orderMap.values()) {
                for(Integer i=1; i<=5; i++) {
                    if(r.get('LoanApprover'+i+'__c') == null) break;
                    externalKey = r.Id + '_' + ((Id) r.get('LoanApprover'+i+'__c'));
                    externalKey2 = r.Id + '_' + ((Id) r.get('LoanApprover'+i+'_1__c'));
                    OrderApprover__c oa = new OrderApprover__c();
                    oa.ExternalKey__c = externalKey;        // 외부 키
                    oa.ErpAPSTA__c = String.valueOf(r.get('ERPApprovalStatus'+i+'__c'));                   // 승인 상태 (Y/N)
                    oa.ErpZLADD__c = '';                                        // 코멘트
                    oa.ErpAPDAT__c = '';                                        // 승인일
                    oa.ErpAPTIM__c = '';                                        // 승인시간
                    if(approverMap.containsKey(externalKey)) {
                        pis = approverMap.get(externalKey);
                        if(pis.StepStatus != 'NoResponse') {
                            oa.ErpZPICH_UserId__c = pis.ActorId;                                                     // 승인자
                            oa.ErpZLADD__c = pis.Comments;                                                           // 코멘트
                            oa.ErpAPDAT__c = pis.SystemModstamp.format('yyyyMMdd');                                  // 승인일
                            oa.ErpAPTIM__c = pis.SystemModstamp.format('HHmmss');                                    // 승인시간
                            LastApprover = pis.ActorId;
                        }
                    } else if(approverMap.containsKey(externalKey2)) {
                        // 위임자 결제 체크.
                        pis = approverMap.get(externalKey2);
                        if(pis.StepStatus != 'NoResponse') {
//                            Rejected, Approved
                            oa.ExternalKey__c = externalKey;        // 외부 키
                            oa.ErpZPICH_UserId__c = pis.ActorId;                                                     // 승인자
                            oa.ErpZLADD__c = pis.Comments;                                                           // 코멘트
                            oa.ErpAPDAT__c = pis.SystemModstamp.format('yyyyMMdd');                                  // 승인일
                            oa.ErpAPTIM__c = pis.SystemModstamp.format('HHmmss');                                    // 승인시간
                            LastApprover = pis.ActorId;
                        }
                    } else {
                        if(r.LoanApprovalStatus__c == '승인') {
                            oa.ErpAPSTA__c = 'Y';                   // 승인 상태 (Y/N)
                        } else if(r.LoanApprovalStatus__c == '반려') {
                            oa.ErpAPSTA__c = 'N';                   // 승인 상태 (Y/N)
                            // ITVOC-2022-02-0660 : 수정
                            oa.ErpZLNNO__c = null;      // 여신번호
                        }
                        oa.ExternalKey__c = externalKey;        // 외부 키
                        oa.ErpZPICH_UserId__c = LastApprover;                                                     // 승인자
                        oa.ErpZLADD__c = '';                                                                     // 코멘트
                        oa.ErpAPDAT__c = Datetime.now().format('yyyyMMdd');                                      // 승인일
                        oa.ErpAPTIM__c = Datetime.now().format('HHmmss');                                        // 승인시간
                    }
                    oaList.add(oa);
                }
            }

            System.debug('oaList========================================');
            System.debug(JSON.serialize(oaList));
            System.debug('========================================');
            if(oaList.isEmpty() == false) {
                upsert oaList ExternalKey__c;
                if(!Test.isRunningTest()) OrderService.loanApprovalCompleteReturnERP(orderMap.keySet());
                //OrderService.loanApprovalCompleteReturnERP(orderMap.keySet());
            }
        }
    }

    // Opportunity 레코드 Id : 관납/농협
    private static Id nhGovOrderRecordTypeId {get;set;}
    // Opportunity 레코드 Id : 관납/농협
    private static Id nhGovOpptyRecordTypeId {get;set;}
    // Quote__c 레코드 Id : 관납/농협
    private static Id nhGovQuoteRecordTypeId {get;set;}
    // QuoteLineItem__c 레코드 Id : 관납/농협
    private static Id nhGovQuoteLineItemRecordTypeId {get;set;}
    // Contract__c 레코드 Id : 관납/농협
    private static Id nhGovContractRecordTypeId {get;set;}
    // ContractLineItem__c 레코드 Id : 관납/농협
    private static Id nhGovContractLineItemRecordTypeId {get;set;}
    static {
        nhGovOrderRecordTypeId = I2ComUtil.getRecordType('Order__c', 'NhGov');
        nhGovOpptyRecordTypeId = I2ComUtil.getRecordType('Opportunity', 'NhGov');
        nhGovQuoteRecordTypeId = I2ComUtil.getRecordType('Quote__c', 'NhGov');
        nhGovQuoteLineItemRecordTypeId = I2ComUtil.getRecordType('QuoteLineitem__c', 'NhGov');
        nhGovContractRecordTypeId = I2ComUtil.getRecordType('Contract__c', 'NhGov');
        nhGovContractLineItemRecordTypeId = I2ComUtil.getRecordType('ContractLineitem__c', 'NhGov');
    }

    /**
     * 주문제품을 기반으로 한 기회/견적/견적제품/계약/계약제품 일괄 생성 Wrapper Class
     */
    class OQCData {
        public Order__c order {get;set;}
        public OrderLineitem__c orderLineItem {get;set;}
        public Opportunity opportunity {get;set;}
        public Quote__c quote {get;set;}
        public QuoteLineItem__c quoteLineItem {get;set;}
        public Contract__c contract {get;set;}
        public ContractLineItem__c contractLineItem {get;set;}
        public Task task {get;set;}

        public OQCData(Order__c order) {
            this.order = order;
            this.orderLineItem = this.order.OrderProduct__r[0];
            this.opportunity = new Opportunity(
                RecordTypeId            = nhGovOpptyRecordTypeId,
                Name                    = LsMSalesQCService.getOpptyName(
                    this.order.OrderAccount__r.Name,
                    this.orderLineItem.ProductId__r.Name,
                    ((Datetime)this.order.DeliveryDate__c).format('yyyyMMdd')
                ),
                //============================================================================
                // 견적생성시 단계가 견적 으로 세팅되어야 됨.
                // Quote_tr 에서 제어되어 이후 단계일 경우 에러발생함.
                // insert 이후 기회의 단계를 계약 으로 변경하여 다시 업데이이트 처리함.
                //============================================================================
                StageName               = '견적',
                SystemStatus__c         = '견적',
                AccountId               = this.order.OrderAccount__c,
                Dealer__c               = this.order.Dealer__c,
                BusinessOffice__c       = this.order.BusinessOffice__c,
                OwnerId                 = this.order.OwnerId,
                InterestModel__c        = (this.orderLineItem.ProductId__r.Type__c == '본체') ? this.orderLineItem.ProductId__c : null,
                Amount                  = this.order.ru_NhGovListPrice__c,
                CloseDate               = this.order.DeliveryDate__c
            );

            this.quote = new Quote__c(
                RecordTypeId            = nhGovQuoteRecordTypeId,
                CustomerName__c         = this.order.OrderAccount__c,
                OwnerId                 = this.order.OwnerId,
                LastQuoteAmt__c         = this.order.ru_NhGovListPrice__c,
                IsPrimary__c            = true,
                Opportunity__c          = this.opportunity.Id
            );

            this.quoteLineItem = new QuoteLineItem__c(
                RecordTypeId            = nhGovQuoteLineItemRecordTypeId,
                OpportunityId__c        = this.opportunity.Id,
                Product__c              = this.orderLineItem.ProductId__c,
                Type__c                 = this.orderLineItem.ProductId__r.Type__c,
                apex_ProductName__c     = this.orderLineItem.ProductId__r.Name,
                Quantity__c             = this.orderLineItem.Quanitity__c,
                NetPrice__c             = this.orderLineItem.NhGovListPrice__c,
                TotalPrice__c           = this.orderLineItem.NhGovListPrice__c,
                Quote__c                = this.quote.Id
            );

            this.contract = new Contract__c(
                RecordTypeId            = nhGovContractRecordTypeId,
                ContractStartDate__c    = this.order.DeliveryDate__c,                // 주문의 DeliveryDate__c
                CustomerExpectedDate__c = this.order.DeliveryDate__c,                // 주문의 DeliveryDate__c
                SelfPayDueDate__c       = this.order.DeliveryDate__c.addDays(30),    // 주문의 DeliveryDate__c + 30일
                Status__c               = '계약',
                SystemStatus__c         = '계약',
                eFormsignStatus__c      = '계약체결',
                Customer__c             = this.order.OrderAccount__c,
                Dealer__c               = this.order.Dealer__c,
                BusinessOffice__c       = this.order.BusinessOffice__c,
                OwnerId                 = this.order.OwnerId,
                TotalPrice__c           = this.order.ru_NhGovListPrice__c,
                SelfPayContractAmt__c   = this.order.ru_NhGovListPrice__c,
                Opportunity__c          = this.opportunity.Id,
                Quote__c                = this.quote.Id
            );

            this.contractLineItem = new ContractLineItem__c(
                RecordTypeId            = nhGovContractLineItemRecordTypeId,
                Quanitity__c            = this.orderLineItem.Quanitity__c,
                ProductId__c            = this.orderLineItem.ProductId__c,
                NetPrice__c             = this.orderLineItem.NhGovListPrice__c,
                TotalPrice__c           = this.orderLineItem.NhGovListPrice__c,
                Contract__c             = this.contract.Id
            );

            this.task = new Task(
                OwnerId = this.order.DealerRep__c,  // 대리점 담당자
                WhatId = this.opportunity.Id,       // 기회
                ActivityDate = System.today(),      // 현재일자
                Status = 'Completed',               // Completed
                Subject = '농협/관납 발주',
                Description = this.order.OrderAccount__r.Name + ' 에 대한 발주 정보가 등록되었습니다.\n자세한 정보 영업기회에서 확인 부탁 드립니다.',
                CustomAlert__c = true
            );
        }
    }

    /**
     *
     * 농협/관납 주문 승인시 주문의 상태가 '본사 주문 확정' 인 경우
     * 기회, 견적, 견적제품, 계약, 계약제품 일괄 생성
     * 주문의 기회 연결 업데이트 처리

     * @param newList Trigger.new
     * @param newMap Trigger.newMap
     */
    public void createOQCAllRecord(List<Order__c> newList, Map<Id, Order__c> newMap, Map<Id, Order__c> oldMap) {

        // 대상 상태
        String checkStatus = '영업소 주문 확정';

        // 처리 대상 정리
        Set<Id> targetOrderIds = new Set<Id>();
        for(Order__c r : newList) {
            if((r.IsDummyContractOrder__c && r.Opportunity__c == null) || (oldMap != null && oldMap.containsKey(r.Id) && r.Status__c != oldMap.get(r.Id).Status__c && r.Status__c == checkStatus)) {
                targetOrderIds.add(r.Id);
            }
        }
        if(Test.isRunningTest()) targetOrderIds.add(newList[0].Id);

        //============================================================================
        // 주문제품을 기준으로 대상건과 필요데이터 필드를 구함
        //============================================================================
        List<Order__c> targetList = [
            SELECT  Id,
                RecordType.Name,                     // 주문제품: 레코드타입
                OrderAccount__c,                     // 주문:주문고객
                OrderAccount__r.Name,                // 주문:주문고객명
                OrderAccount__r.RecordType.Name,     // 주문:주문고객명
                Dealer__c,                           // 주문:대리점
                DealerRep__c,                        // 주문:대리점 담당자
                Dealer__r.DealerOwner__c,            // 주문:대리점 주
                BusinessOffice__c,                   // 주문:영업소
                OwnerId,                             // 주문:소유자
                DeliveryDate__c,                     // 주문:인도기일
                ru_NhGovListPrice__c,                // 주문:농협/관납 기준가
                Opportunity__c,                      // 주문:판매기회
                (
                    SELECT  Id, Quanitity__c, NhGovListPrice__c,
                        ProductId__c, ProductId__r.Name, ProductId__r.Type__c
                    FROM OrderProduct__r
                    LIMIT 1
                )
            FROM Order__c
            WHERE Id IN :targetOrderIds
            AND RecordTypeId = :nhGovOrderRecordTypeId
//            AND Status__c = :checkStatus
        ];



        if(targetList.size() > 0) {

            List<Opportunity> insertOpportunities = new List<Opportunity>();
            List<Quote__c> insertQuotes = new List<Quote__c>();
            List<QuoteLineItem__c> insertQuoteLineItems = new List<QuoteLineItem__c>();
            List<Contract__c> insertContracts = new List<Contract__c>();
            List<ContractLineItem__c> insertContractLineItems = new List<ContractLineItem__c>();
            List<Task> insertTasks = new List<Task>();

            List<OQCData> OQCDataList = new List<OQCData>();

            Set<Id> targetOwnerIds = new Set<Id>();
            // 1. Wrapper Class 리스트를 구성
            for(Order__c order : targetList) {
                OQCDataList.add(new OQCData(order));
                targetOwnerIds.add(order.Dealer__r.DealerOwner__c);
            }

            Map<Id, User> activeUserMap = new Map<Id, User>(
                [SELECT Id FROM User WHERE Id IN :targetOwnerIds AND IsActive = true ]
            );

            // 2. 판매기회 생성
            for(OQCData oqcData : OQCDataList) {
                insertOpportunities.add(oqcData.opportunity);
            }
            insert insertOpportunities;

            // 3. 견적 생성 / 기회 단계 변경 / Task 생성 / 주문 기회 연결
            for(OQCData oqcData : OQCDataList) {
                //============================================================================
                // 견적 생성
                //============================================================================
                oqcData.quote.Opportunity__c = oqcData.opportunity.Id;
                insertQuotes.add(oqcData.quote);

                //============================================================================
                // 기회 상태 변경
                // 견적상태에서 -> 계약 단계 변경
                //============================================================================
                oqcData.opportunity.StageName = '계약';
                oqcData.opportunity.SystemStatus__c = '계약';

                //============================================================================
                // Task 기회 연결
                //============================================================================
                oqcData.task.WhatId = oqcData.opportunity.Id;
                if(activeUserMap.containsKey(oqcData.order.Dealer__r.DealerOwner__c)) insertTasks.add(oqcData.task);

                //============================================================================
                // 주문의 판매기회 세팅
                //============================================================================
                ((Order__c)newMap.get(oqcData.order.Id)).Opportunity__c = oqcData.opportunity.Id;
                // 2022/02/15 : ITVOC-2022-02-0659
                // 농협관납 주문일때 주문목적도 판매기회로 변경 처리.
                ((Order__c)newMap.get(oqcData.order.Id)).PurposeOfOrder__c = '판매기회';
            }
            insert insertQuotes;

            // 4. 견적제품 생성 및 계약 생성
            for(OQCData oqcData : OQCDataList) {
                oqcData.quoteLineItem.Quote__c = oqcData.quote.Id;
                insertQuoteLineItems.add(oqcData.quoteLineItem);

                oqcData.contract.Opportunity__c = oqcData.opportunity.Id;
                oqcData.contract.Quote__c = oqcData.quote.Id;
                insertContracts.add(oqcData.contract);
            }
            insert insertQuoteLineItems;
            insert insertContracts;

            // 5. 계약제품 생성
            for(OQCData oqcData : OQCDataList) {
                oqcData.contractLineItem.Contract__c = oqcData.contract.Id;
                insertContractLineItems.add(oqcData.contractLineItem);
            }
            insert insertContractLineItems;

            // 6. 기회 단계 변경 업데이트
            update insertOpportunities;

            // 7. Task 생성
            insert insertTasks;

            // 8. 최종 로깅처리[지우지 말것]
            System.debug(System.LoggingLevel.INFO, '최종 OQCDataList :' + JSON.serialize(OQCDataList));
        }

    }


}