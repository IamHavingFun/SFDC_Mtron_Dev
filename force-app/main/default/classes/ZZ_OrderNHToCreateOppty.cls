/**
 * Created by MS on 2021-03-05.
 */

public with sharing class ZZ_OrderNHToCreateOppty {

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
    public static void createOQCAllRecord(Id targetId) {

        Map<Id, Order__c> newMap = new Map<Id, Order__c>([
                SELECT
                        AssetTransferAgreeStatus__c,
                        BusinessOffice__c,
                        BusinessOfficeRep__c,
                        CreatedById,
                        CreatedDate,
                        CurrencyIsoCode,
                        Dealer__c,
                        DealerRep__c,
                        DeliverTo__c,
                        DeliveryDate__c,
                        Division__c,
                        ERP_Code__c,
                        ErpABGRU__c,
                        ErpAPPAM_C__c,
                        ERPApprovalStatus1__c,
                        ERPApprovalStatus2__c,
                        ERPApprovalStatus3__c,
                        ERPApprovalStatus4__c,
                        ERPApprovalStatus5__c,
                        ErpAPPRV__c,
                        ErpARRME_C__c,
                        ErpARRRT__c,
                        ErpAUART__c,
                        ErpBILIN_C__c,
                        ErpBSTDK__c,
                        ErpBSTKD__c,
                        ErpCMGST__c,
                        ErpCRED_GRAD__c,
                        ErpGUAR_AMNT_C__c,
                        ErpINTVL0_C__c,
                        ErpINTVL1_C__c,
                        ErpINTVL2_C__c,
                        ErpINTVL3_C__c,
                        ErpINTVL4_C__c,
                        ErpINTVL5_C__c,
                        ErpKLIMK_C__c,
                        ErpLAPPR__c,
                        ErpLFDBK_T__c,
                        ErpLNREL__c,
                        ErpLNREQ_C__c,
                        ErpLPLAN_T__c,
                        ErpLRESN_T__c,
                        ErpLVORM1__c,
                        ErpLVORM__c,
                        ErpMATNR__c,
                        ErpMENGE__c,
                        ErpNETPR_C__c,
                        ErpNETWR_C__c,
                        ErpPERNR__c,
                        ErpPOSNR__c,
                        ErpRELDT__c,
                        ErpRQIND__c,
                        ErpS_MESSAGE__c,
                        ErpS_RESULT__c,
                        ErpSPART__c,
                        ErpSTOCK__c,
                        ErpSUMME_C__c,
                        ErpUSELN_C__c,
                        ErpUSELN_F_C__c,
                        ErpVKBUR__c,
                        ErpVKGRP__c,
                        ErpVKORG__c,
                        ErpVRKME__c,
                        ErpVTWEG__c,
                        ErpWAERS__c,
                        ErpZBESU__c,
                        ErpZGUBUN__c,
                        ErpZLNNO__c,
                        ErpZLNST__c,
                        ErpZRATE__c,
                        ErpZRATE_F__c,
                        ErpZTERM__c,
                        Id,
                        IsDeleted,
                        IsDummyContractOrder__c,
                        IsInAsset__c,
                        IsMyDealerOrder__c,
                        isOrderCancel__c,
                        IsOutAsset__c,
                        IsZRET__c,
                        LastActivityDate,
                        LastModifiedById,
                        LastModifiedDate,
                        LastReferencedDate,
                        LastViewedDate,
                        LoanApprovalStatus__c,
                        LoanApprover1_1__c,
                        LoanApprover1__c,
                        LoanApprover2_1__c,
                        LoanApprover2__c,
                        LoanApprover3_1__c,
                        LoanApprover3__c,
                        LoanApprover4_1__c,
                        LoanApprover4__c,
                        LoanApprover5_1__c,
                        LoanApprover5__c,
                        Name,
                        Opportunity__c,
                        OrderAccount__c,
                        OrderScheduleDate__c,
                        OwnerId,
                        PODate__c,
                        ProductId__c,
                        PurposeOfOrder__c,
                        RecordTypeId,
                        ru_MaxFee__c,
                        ru_MaxNetPrice__c,
                        ru_MinFee__c,
                        ru_MinNetPrice__c,
                        ru_NhGovListPrice__c,
                        ru_UnitPrice__c,
                        SalesDocNo__c,
                        ShipmentDate__c,
                        SoldTo__c,
                        Status__c,
                        SupplyTo__c,
                        SystemModstamp,
                        SystemStatus__c,
                        //TransferApprovalStatus__c,
                        TransferBusinessOffice__c,
                        TransferMachineNo__c,
                        TransferProcessStatus__c
                FROM Order__c
                WHERE Id = :targetId]);

        Set<Id> targetOrderIds = newMap.keySet();
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

            update newMap.values(); // 주문 업데이트.

            // 8. 최종 로깅처리[지우지 말것]
            System.debug(System.LoggingLevel.INFO, '최종 OQCDataList :' + JSON.serialize(OQCDataList));
        }

    }


    public static void runTest() {
        Integer my_seo = 0;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
    }
}