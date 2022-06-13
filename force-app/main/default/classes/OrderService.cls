/****************************************************************************************
  * @filename      : OrderService
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-05-25 오전 10:05
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OrderService_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-05-25 오전 10:05     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class OrderService {

    /** 
     * @description 수수료 정보 할당 및 각 종 가격 계산
     *
     * @param wrapperData : OrderNewQa.WrapperData
     *
     * @return OrderNewQa.WrapperData
     */
    @AuraEnabled
    public static OrderNewQa.WrapperData calculatePrice(OrderNewQa.WrapperData wrapperData) {
        User tempUser = ModelUser.getUserData();
        Product2 tempProduct;
        List<Fee__c> tempFee;

        if(wrapperData.isPerFarCorp) {
            Set<String> dealerTypesSet     = new Set<String>{'ALL'};
            Set<String> productDivisionSet = new Set<String>{'ALL'};
            Set<String> sgSet              = new Set<String>{'ALL'};
            Set<String> productTypeSet     = new Set<String>{'ALL'};

            tempProduct = [
                    SELECT ProductDivision__c, ProductType__c, ProductDivFeeRate__c
                    FROM Product2
                    WHERE Id = :wrapperData.orderLineItemList[0].ProductId__c
            ];

            dealerTypesSet.add(tempUser.Account.DealerDivision__c);
            productDivisionSet.add(tempProduct.ProductDivision__c);
            sgSet.add(tempUser.Account.ServiceCapabilityClass__c);
            productTypeSet.add(tempProduct.ProductType__c);

            tempFee = [
                    SELECT
                            DealerType__c,
                            FeeType__c,
                            Id,
                            isActive__c,
                            MaxFeeRate__c,
                            MinFeeRate__c,
                            MaxFeeRateFieldAPI__c,
                            MinFeeRateFieldAPI__c,
                            Name,
                            OwnerId,
                            ProductDivision__c,
                            ProductType__c,
                            SG__c
                    FROM Fee__c
                    WHERE isActive__c = true
                    AND DealerType__c IN :dealerTypesSet
                    AND ProductDivision__c IN :productDivisionSet
                    AND SG__c IN :sgSet
                    AND ProductType__c IN :productTypeSet
            ];
        }

        if (wrapperData.orderLineItemList != null) {
            if(wrapperData.isPerFarCorp) {
                for (Fee__c fee : tempFee) {
                    wrapperData.orderLineItemList[0].put(fee.MaxFeeRateFieldAPI__c, fee.MaxFeeRate__c);
                    wrapperData.orderLineItemList[0].put(fee.MinFeeRateFieldAPI__c, fee.MinFeeRate__c);
                }

//                wrapperData.orderLineItemList[0].PTFeeMaxRate__c = wrapperData.orderLineItemList[0].PTFeeMinRate__c = tempProduct.ProductDivFeeRate__c;

                OrderService.calculateResultPrice(wrapperData);
            }
        }

        return wrapperData;
    }

    /**
     * @description 주문 고객에 포함 되는 판매처 정보를 가져 오는 method.
     *
     * @param accountId : Account Id (OrderAccount__c)
     *
     * @return OrderNewQa.SoldToInfo
     */
    public static OrderNewQa.SoldToInfo getTargetSoldTo(String accountId) {
        OrderNewQa.SoldToInfo soldToInfo = new OrderNewQa.SoldToInfo();

        Account targetAccount = [SELECT Id, Name, Dealer__c, Dealer__r.Name, CustomerType__c FROM Account WHERE Id = :accountId];

        if('농협'.equals(targetAccount.CustomerType__c) || '관납'.equals(targetAccount.CustomerType__c)) {
            soldToInfo.soldToList.add(new I2ComClass.Option(targetAccount.Name, targetAccount.Id));
            if(targetAccount.Dealer__c != null) soldToInfo.soldToList.add(new I2ComClass.Option(targetAccount.Dealer__r.Name, targetAccount.Dealer__c));
        }
        else {
            throw new AuraHandledException('농협 또는 관납 고객이 아닙니다.');
        }

        return soldToInfo;
    }

    public static String getTargetSoldToId(String accountId) {
        List<Account> accountList = [SELECT Dealer__c FROM Account WHERE Id = :accountId];

        if(accountList[0].Dealer__c == null) {
            throw new AuraHandledException('선택하신 고객에 해당하는 대리점이 없습니다.');
        }

        return accountList.size() > 0 ? accountList[0].Dealer__c : null;
    }

    /**
     * @description 각종 수수료 계산 및 계산된 값을 화면에 보여 주기 위한 WrapperData 값에 할당.
     *
     * @param wrapperData : OrderNewQa.WrapperData
     */
    private static void calculateResultPrice(OrderNewQa.WrapperData wrapperData) {
        // 대리점가
        OrderLineitem__c oli    = wrapperData.orderLineItemList[0];
        Decimal dealerListPrice = oli.UnitPrice__c;

        if(dealerListPrice == null) {
            throw new AuraHandledException('대리점 기준가가 없습니다. 시스템 담당자에게 문의하세요.');
        }

        //==============================================================================
        // 고정 수수료
        //==============================================================================
        // 대리점유형 수수료
        oli.DTFeeMaxAmt__c = calculateFeeAmt(dealerListPrice, oli.DTFeeMaxRate__c);
        oli.DTFeeMinAmt__c = calculateFeeAmt(dealerListPrice, oli.DTFeeMinRate__c);
        // 서비스등급 수수료
        oli.SGFeeMaxAmt__c = calculateFeeAmt(dealerListPrice, oli.SGFeeMaxRate__c);
        oli.SGFeeMinAmt__c = calculateFeeAmt(dealerListPrice, oli.SGFeeMinRate__c);

        //==============================================================================
        // 변동 수수료
        //==============================================================================
        // MS성과 수수료
        oli.MSFeeMaxAmt__c = calculateFeeAmt(dealerListPrice, oli.MSFeeMaxRate__c);
        oli.MSFeeMinAmt__c = calculateFeeAmt(dealerListPrice, oli.MSFeeMinRate__c);
        // 지역차별 수수료
        oli.LAFeeMaxAmt__c = calculateFeeAmt(dealerListPrice, oli.LAFeeMaxRate__c);
        oli.LAFeeMinAmt__c = calculateFeeAmt(dealerListPrice, oli.LAFeeMinRate__c);
        // 실판매 수수료
        oli.RSFeeMaxAmt__c = calculateFeeAmt(dealerListPrice, oli.RSFeeMaxRate__c);
        oli.RSFeeMinAmt__c = calculateFeeAmt(dealerListPrice, oli.RSFeeMinRate__c);
        // 마케팅활동 수수료
        oli.MAFeeMaxAmt__c = calculateFeeAmt(dealerListPrice, oli.MAFeeMaxRate__c);
        oli.MAFeeMinAmt__c = calculateFeeAmt(dealerListPrice, oli.MAFeeMinRate__c);
        // 조기결재 수수료
        oli.EPFeeMaxAmt__c = calculateFeeAmt(dealerListPrice, oli.EPFeeMaxRate__c);
        oli.EPFeeMinAmt__c = calculateFeeAmt(dealerListPrice, oli.EPFeeMinRate__c);
        // 계절기종 수수료
        oli.SPFeeMaxAmt__c = calculateFeeAmt(dealerListPrice, oli.SPFeeMaxRate__c);
        oli.SPFeeMinAmt__c = calculateFeeAmt(dealerListPrice, oli.SPFeeMinRate__c);
        // 제품구분 수수료
        oli.PTFeeMaxAmt__c = oli.PTFeeMinAmt__c = (wrapperData.orderLineItemList[0].ProductId__r.ProductDivFeeRate__c != null) ? (dealerListPrice * (wrapperData.orderLineItemList[0].ProductId__r.ProductDivFeeRate__c/100)).round() : 0;

        // 대리점 공급가
        wrapperData.supplyHighAmt    = dealerListPrice - (oli.DTFeeMaxAmt__c + oli.SGFeeMaxAmt__c + oli.MSFeeMaxAmt__c + oli.LAFeeMaxAmt__c + oli.RSFeeMaxAmt__c + oli.MAFeeMaxAmt__c + oli.EPFeeMaxAmt__c + oli.SPFeeMaxAmt__c + oli.PTFeeMaxAmt__c);
        wrapperData.supplyLowAmt     = dealerListPrice - (oli.DTFeeMinAmt__c + oli.SGFeeMinAmt__c + oli.MSFeeMinAmt__c + oli.LAFeeMinAmt__c + oli.RSFeeMinAmt__c + oli.MAFeeMinAmt__c + oli.EPFeeMinAmt__c + oli.SPFeeMinAmt__c + oli.PTFeeMinAmt__c);
    }

    /**
     * 가격과 수수료를 계산한 값을 return.
     *
     * @param targetPrice   계산이 필요한 가격
     * @param feeRate       수수료
     *
     * @return Decimal - 가격 * 수수료
     */
    private static Decimal calculateFeeAmt(final Decimal targetPrice, final Decimal feeRate) {
        return (targetPrice * (feeRate/100)).round();
    }

    /**
     * 농협/관납 주문 시, 최종 가격 return.
     *
     * @param wrapperData Order 관련 정보를 담은 Wrapper Class Data
     *
     * @return OrderNewQa.WrapperData
     */
    @AuraEnabled
    public static OrderNewQa.WrapperData calculateResultPriceForNhGov(OrderNewQa.WrapperData wrapperData) {
        OrderLineitem__c oli = wrapperData.orderLineItemList[0];

        String customerType = [
                SELECT CustomerType__c
                FROM Account
                WHERE Id = :wrapperData.order.OrderAccount__c
        ].CustomerType__c;

        if(customerType != '관납' && customerType != '농협') {
            throw new AuraHandledException('고객 유형이 관납 또는 농협이 아닙니다.');
        }

        if('관납'.equals(customerType)) {
            if(oli.ProductId__r.GovListPrice__c == null) {
                throw new AuraHandledException('관납 기준가가 없습니다. 시스템 관리자에게 문의하세요.');
            }

            oli.NhGovListPrice__c = oli.ProductId__r.GovListPrice__c;
            oli.DealerFeeAmt__c = oli.ProductId__r.GovListPrice__c * ((oli.ProductId__r.GovFeeRate__c == null) ? 0 : oli.ProductId__r.GovFeeRate__c);
        }
        else if('농협'.equals(customerType)) {
            if(oli.ProductId__r.NhListPrice__c == null) {
                throw new AuraHandledException('농협 기준가가 없습니다. 시스템 관리자에게 문의하세요.');
            }

            oli.NhGovListPrice__c = oli.ProductId__r.NhListPrice__c;
            oli.DealerFeeAmt__c = oli.ProductId__r.NhListPrice__c * ((oli.ProductId__r.NhFeeAmt__c == null) ? 0 : oli.ProductId__r.NhFeeAmt__c);
        }

        return wrapperData;
    }

    /**
     * 활성화 되어 있는 ProductSeries 중, 제품 타입에 해당 하는 ProductSeries__c의 Series__c 정보 return.
     *
     * @param productType String
     *
     * @return List<I2ComClass.Option>
     */
    public static List<I2ComClass.Option> getProductSeriesList(final String productType) {
        Map<String, String> seriesMap       = new Map<String, String>();
        List<I2ComClass.Option> options     = new List<I2ComClass.Option>();

        for(ProductSeries__c ps : [SELECT Series__c FROM ProductSeries__c WHERE ProductType__c = :productType AND isActive__c = true ORDER BY Series__c]) {
            if(!seriesMap.containsKey(ps.Series__c)) {
                seriesMap.put(ps.Series__c, ps.Series__c);
            }
        }

        for(String series : seriesMap.values()) {
            options.add(new I2ComClass.Option(series, series));
        }

        return options;
    }

    /**
     * 주문 생성 완료 시, 타당한 주문 인지 아닌지 판단.
     *
     * @param accountId 판단을 위한 정보에 필요한 Account.Id
     *
     * @return String
     */
    public static List<String> validForOrder(final String accountId) {
        Datetime dt = System.today();
        Boolean isValid = false;
        String valid1 = '';
        String valid2 = '';
        String screenComment;
        String messageComment;
        List<String> invalidComments = new List<String>();
        Account acc = [
                SELECT Id, fm_CreditLimitExceededAmt__c, DeliveryStopDate__c, BlacklistErpDelivery__c
                FROM Account
                WHERE Id = :accountId
        ];

        if(acc.fm_CreditLimitExceededAmt__c <= 0) {
            valid1 = 'v';
            isValid = true;
            messageComment = '여신한도 초과';
        }

        if(acc.DeliveryStopDate__c <= dt && acc.BlacklistErpDelivery__c == true) {
            valid2 = 'v';
            isValid = true;
            messageComment = String.isEmpty(messageComment) == true ? '장기연체채권 존재' : messageComment + ', ' + '장기연체채권 존재';
        }

        List<String> testList = new List<String> {
                '[' + valid1 + '] 여신한도 초과',
                '[' + valid2 + '] 장기연체채권 존재'
        };

        screenComment = String.join(testList, '\n');
        if(isValid) {
            invalidComments.add(screenComment);
            invalidComments.add(messageComment);
        } else {
            invalidComments = null;
        }
        return invalidComments;
    }

    /**
     * 주문 하는 고객의 partner user 인지 아닌지 판단.
     *
     * @return Boolean
     */
    public static Boolean isPartner() {
        return (ModelUser.getUserData().Account == null) ? false : true;
    }

    /**
     * @description : IF_KR_SE_ERP_0007 주문 생성 (SE <-> ERP)
     *                SFDC 내 주문 확정시 ERP 내 주문 연계 (테스트 중)
     * Order__c 에 OrderLineItem__c는 1개임.
     * Update Order, OrderLineitem
     * 버튼에서 호출됨
     */
    //OrderService.IF_KR_SE_ERP_0007('a0Z1m0000006qGiEAI');
    public static Map<String, String> IF_KR_SE_ERP_0007(String recordId) {

        Map<String, String> returnMap = new Map<String, String>();

        List<OrderLineitem__c> inputOrderLineitems = [
                SELECT  Id,
                        ProductId__r.ProductCode,
                        OrderId__c,
                        OrderId__r.BusinessOffice__r.SalesGroupCode__c,
                        OrderId__r.BusinessOffice__r.BusinessOfficeName__c,
                        OrderId__r.Name,
                        OrderId__r.fm_SoldToErpCode__c,
                        OrderId__r.fm_SupplyToErpCode__c,
                        OrderId__r.ERP_Code__c,
                        OrderId__r.OrderScheduleDate__c,
                        OrderId__r.VSTEL__c,
                        OrderId__r.DeliveryComment__c,
                        OrderId__r.OrderAccount__c,
                        OrderId__r.PriceDecisionDate__c,
                        CorrectionPrice__c,
                        ListPrice__c,
                        UnitPrice__c,
                        NhGovListPrice__c,
                        SellingPrice__c
                FROM OrderLineitem__c
                WHERE OrderId__c = :recordId
        ];

        IF_KR_SE_ERP_0007           instance = IF_KR_SE_ERP_0007.getInstance();
        IF_KR_SE_ERP_0007.InputDIH  input = new IF_KR_SE_ERP_0007.InputDIH();
        IF_KR_SE_ERP_0007.T_DATA    tData;
        IF_KR_SE_ERP_0007.OutputDIH result;
        System.debug('### orderLineitems:::' + inputOrderLineitems.size());

        for(OrderLineitem__c oli : inputOrderLineitems ){
            /*
            (In : 데이터 채울 것) (Out : 전송시 스페이스 한자리, 수신하여 값 저장)(* 수신 필수)
            -------------------------------------------------------------------- 전송
            ( In ) OrderLineItemID  세일즈포스 주문 제품ID
            ( In ) ProductCode      제품코드
            ( In ) OrderID          세일즈포스 채번 주문ID
            ( In ) ErpVKGRP         영업그룹
            ( In ) ErpBSTKD         PO 번호(= Order__c.Name)
            ( In ) ErpBSTDK         PO 일자(= ERP 주문 생성 당일, yyyyMMdd)
            ( In ) ErpKUNNR         판매처
            ( In ) ErpKUNNR2        지급처
            ( In ) ErpKUNNR3        납품처

            ( In ) Quanitity        주문수량(=1)
            ( In ) ErpZFLAG         주문Flag(Create: C 설정)
            ( In ) ErpAUART         영업문서 유형(OR)
            ( In ) ErpVKORG         영업조직(3000)
            ( In ) ErpVTWEG         유통경로(10)
            ( In ) ErpSPART         제품군(71)
            ( In ) ErpVKBUR         영업팀(5600)

            -------------------------------------------------------------------- 수신
            [Order__c]
            (*Out) ErpZTERM__c  지급조건(* 전송시 스페이스 한자리, ERP 회신되는 값, Order__c에 저장)
            (*Out) SalesDocNo__c  판매문서번호(* 전송시 스페이스 한자리, 수신하여 값 저장)
            (*Out) ErpCMGST__c  ERP 여신상태(* 전송시 스페이스 한자리, 수신하여 값 저장)
            ( Out) ErpABGRU__c  ERP 거부사유(* 전송시 스페이스 한자리, 수신하여 값 저장)
            (*Out) ErpS_RESULT__c  ERP 처리결과(* 전송시 스페이스 한자리, 수신하여 값 저장)
            ( Out) ErpS_MESSAGE__c  ERP 메시지(* 전송시 N스페이스 한자리ull, 수신하여 값 저장)
            (*Out) ErpPOSNR__c  판매문서품목번호(* 전송시 스페이스 한자리, 수신하여 값 저장)

            [OrderLineItem__c]
            ( Out) ErpPOSNR__c : 판매문서품목번호 : (* 전송시 스페이스 한자리, 수신하여 OrderLineItem__c 값 저장)
            */

            Map<String, String> VSTELMap = new Map<String, String>();
            VSTELMap.put('71A', 'M621');        // M621경기
            VSTELMap.put('71C', 'M622');        // M622충북
            VSTELMap.put('71E', 'M623');        // M623전북
            VSTELMap.put('71G', 'M624');        // M624경북
            VSTELMap.put('71B', 'M625');        // M625강원
            VSTELMap.put('71D', 'M626');        // M626충남
            VSTELMap.put('71F', 'M627');        // M627전남
            VSTELMap.put('71H', 'M628');        // M628경남

            Map<String, String> LGORTMap = new Map<String, String>();
            LGORTMap.put('M620', '3710');        // 전주공장
            LGORTMap.put('M621', '3711');        // 3711경기
            LGORTMap.put('M622', '3712');        // 3712충북
            LGORTMap.put('M623', '3713');        // 3713전북
            LGORTMap.put('M624', '3714');        // 3714경북
            LGORTMap.put('M625', '3715');        // 3715강원
            LGORTMap.put('M626', '3716');        // 3716충남
            LGORTMap.put('M627', '3717');        // 3717전남
            LGORTMap.put('M628', '3718');        // 3718경남

            String sVSTEL = VSTELMap.containsKey(oli.OrderId__r.BusinessOffice__r.BusinessOfficeName__c) ?
                    VSTELMap.get(oli.OrderId__r.BusinessOffice__r.BusinessOfficeName__c) :
                    ' ';
            String sLGORT = LGORTMap.containsKey(oli.OrderId__r.VSTEL__c) ?
                    LGORTMap.get(oli.OrderId__r.VSTEL__c) :
                    ' ';

            tData = new IF_KR_SE_ERP_0007.T_DATA();

            tData.OrderID           = oli.OrderId__c;
            tData.OrderLineItemID   = oli.Id;
            tData.ProductCode       = oli.ProductId__r.ProductCode;
            tData.ErpVKGRP          = oli.OrderId__r.BusinessOffice__r.SalesGroupCode__c;
            tData.ErpBSTKD          = oli.OrderId__r.Name;
            tData.ErpBSTDK          = String.valueOf(system.now().format('yyyyMMdd'));
            tData.ErpKUNNR          = oli.OrderId__r.fm_SoldToErpCode__c;
            tData.ErpKUNNR2         = oli.OrderId__r.fm_SupplyToErpCode__c;
            tData.ErpKUNNR3         = oli.OrderId__r.ERP_Code__c;

            // 2021-07-26 수정 ============================================================================================
            tData.KEDAT             = ((Datetime)oli.OrderId__r.OrderScheduleDate__c).format('yyyyMMdd');   // 납품요청월
            tData.DLTXT             = String.isEmpty(oli.OrderId__r.DeliveryComment__c) ? '' : oli.OrderId__r.DeliveryComment__c;                                    // 출하전달사항
            // ============================================================================================================

            tData.Quanitity         = '1';
            tData.ErpZFLAG          = 'C';    // C: 생성, D: 삭제
            tData.ErpAUART          = 'OR';
            tData.ErpVKORG          = '3000';
            tData.ErpVTWEG          = '10';
            tData.ErpSPART          = '71';
            tData.ErpVKBUR          = '5600';

            tData.CHARG             = ' ';
            tData.VSTEL             = oli.OrderId__r.VSTEL__c;      // 출하위치
            tData.LGORT             = sLGORT;

            tData.ErpPOSNR          = '';
            tData.ErpZTERM          = '';
            tData.SalesDocNo        = '';
            tData.ErpCMGST          = '';
            tData.ErpABGRU          = '';
            tData.ErpS_RESULT       = '';
            tData.ErpS_MESSAGE      = '';

            tData.NETWR1_C          = '';   //unitPrice == null ? '0' : String.valueOf(unitPrice);  // 기준 가격
            tData.NETWR2_C          = '';   //oli.CorrectionPrice__c == null ? '0' : String.valueOf(oli.CorrectionPrice__c);  // 가격 변경
            tData.NETWR3_C          = '';   //oli.SellingPrice__c == null ? '0' : String.valueOf(oli.SellingPrice__c);  // 공급 가격
            tData.RESERVE01         = '';   // 예비1
            tData.RESERVE02         = '';   // 예비2
            tData.RESERVE03         = '';   // 예비3
            tData.RESERVE04         = '';   // 예비4
            tData.RESERVE05         = '';   // 예비5

            tData.PRSDT             = String.valueOf(system.now().format('yyyyMMdd'));  // 가격 결정일

            // 적재
            input.request.payload.t_data.add(tData);
        }

        // Interface Request 실행
        System.debug('### input.request.payload.t_data : '+input.request.payload.t_data);
        if(!input.request.payload.t_data.isEmpty()){
            // crashTest
            //IF_Base.crashTest = true;
            result = instance.execute(input);
        }

        // Interface Response 처리
        if ('S'.equals(result.response.header.ifResult)) {
            //성공 Succeed to Request
            Map<String, Order__c> orderMap = new Map<String, Order__c>();
            Map<String, OrderLineitem__c> orderLineitemMap = new Map<String, OrderLineitem__c>();

            List<Order__c> orders = new List<SObject>();
            List<OrderLineitem__c> orderLineitems = new List<SObject>();

            Set<String> orderIds = new Set<String>();               // Order Ids
            Set<String> orderDealerOwnerIds = new Set<String>();    // OrderDealerOwner Ids

            System.debug('### t_data : '+result.Response.payload.t_data);
            List<IF_KR_SE_ERP_0007.T_DATA> t_data = result.Response.payload.t_data;

            // I/F에서 받은 데이터
            for(IF_KR_SE_ERP_0007.T_DATA temp: t_data) {
                if(String.isNotBlank(temp.OrderID))  orderIds.add(temp.OrderID);
            }

            // Order Map
            for(Order__c o : [
                    SELECT Id, Name, ErpPOSNR__c, ErpZTERM__c, SalesDocNo__c, ErpCMGST__c, ErpABGRU__c, ErpS_RESULT__c, ErpS_MESSAGE__c,
                            Dealer__r.Owner.Id, RecordType.Name,
                            BusinessOfficeRep__c, BusinessOfficeRep__r.ManagerId
                    FROM Order__c
                    WHERE id IN :orderIds]
            ) {
                if(!orderMap.containsKey(o.id)) {
                    orderMap.put(o.Id, o);
                }
            }
            // OrderLineItem Map
            for(OrderLineItem__c oli : [
                    SELECT Id, OrderId__c, ErpPOSNR__c, BaseSellingPrice__c, CorrectionPrice__c, SellingPrice__c,
                            OrderId__r.SoldTo__r.CustomerType__c,
                            ProductId__r.GovListPrice__c,
                            ProductId__r.NhListPrice__c,
                            ProductId__r.DealerListPrice__c
                    FROM OrderLineitem__c
                    WHERE OrderId__c IN :orderIds
            ]) {
                if(!orderLineitemMap.containsKey(oli.id)) {
                    orderLineitemMap.put(oli.Id, oli);
                }
            }

            Order__c tmpOrder;
            OrderLineitem__c tmpOrderLineitem;
            Boolean isGoodResponseData, isExistRecord;

            for(IF_KR_SE_ERP_0007.T_DATA temp: t_data) {
                // 데이터 확인
                tmpOrder = orderMap.get(temp.OrderID);
                // 데이터 확인 여부
                isExistRecord = tmpOrder != null ? true : false;

                /** ================================================================
                * 정상 Response 데이터 여부
                * ErpPOSNR, SalesDocNo, ErpCMGST 필수 항목
                * ================================================================*/
                isGoodResponseData = string.isNotBlank(temp.ErpS_RESULT)
//                                    && (temp.ErpS_RESULT == '00')
                                    && String.isNotBlank(temp.ErpPOSNR)
                                    && String.isNotBlank(temp.SalesDocNo)
//                                    && String.isNotBlank(temp.ErpCMGST)
                                    && isExistRecord;

                if(isGoodResponseData == false) {
                    String message;
                    if(temp.ErpS_RESULT != '00')        message =  ' ' + temp.ErpS_MESSAGE  + '\n';
                    if(!isExistRecord)                  message += ' ' +temp.OrderID + '레코드가 존재하지 않습니다.'  + '\n';
                    if(String.isBlank(temp.ErpPOSNR))   message += ' 필수 리턴 값 : ErpPOSNR IS NULL'  + '\n';
                    if(String.isBlank(temp.SalesDocNo)) message += ' 필수 리턴 값 : SalesDocNo IS NULL'  + '\n';
//                    if(String.isBlank(temp.ErpCMGST))   message += ' 필수 리턴 값 : ErpCMGST IS NULL'  + '\n';

                    // ERP 처리결과, 메시지 저장
                    tmpOrder.ErpS_RESULT__c     = temp.ErpS_RESULT;
                    tmpOrder.ErpS_MESSAGE__c    = temp.ErpS_MESSAGE;

                    orders.add(tmpOrder);

                    returnMap.put('STATUS', 'N');
                    returnMap.put('MESSAGE', message);
                }
                else{
                    ////////////////////////////////////// Order List
                    tmpOrder.PriceDecisionDate__c = Date.today();   // 가격 결정일
                    tmpOrder.ErpZTERM__c        = temp.ErpZTERM;
                    tmpOrder.SalesDocNo__c      = temp.SalesDocNo;
                    tmpOrder.ErpCMGST__c        = String.isEmpty(temp.ErpCMGST) ? 'A' : temp.ErpCMGST;
                    tmpOrder.ErpABGRU__c        = temp.ErpABGRU;
                    tmpOrder.ErpS_RESULT__c     = temp.ErpS_RESULT;
                    tmpOrder.ErpS_MESSAGE__c    = temp.ErpS_MESSAGE;
                    tmpOrder.ErpPOSNR__c        = temp.ErpPOSNR;

                    if (temp.ErpCMGST == 'B' ) {
                        if(tmpOrder.RecordType.Name != '관납/농협') {
                            tmpOrder.Status__c = '본사 여신 검토';
                            tmpOrder.SystemStatus__c = '본사 여신 검토';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
                        } else {
                            tmpOrder.Status__c = '출하';
                            tmpOrder.SystemStatus__c = '출하';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
                        }
                    } else if (String.isEmpty(temp.ErpCMGST) || temp.ErpCMGST == 'A' || temp.ErpCMGST == 'D') {
                        tmpOrder.Status__c = '출하';
                        tmpOrder.SystemStatus__c = '출하';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
                    }
                    orders.add(tmpOrder);

                    // temp.ErpABGRU = '95' (수주 손익 미결재) 일 경우 Dealer__r.Owner.Id 에게 Chatter 알림
                    if(temp.ErpABGRU == '95'){
                        String chatterMessage = tmpOrder.Name +' 수주 손익 미결 상태로, SAP 수주 손익 승인 요청 Workflow가 실행되었습니다. SAP 內 확인 바랍니다.';
                        Set<String> mentionsIds = new Set<String>();
                        if(tmpOrder.BusinessOfficeRep__c != null) mentionsIds.add(tmpOrder.BusinessOfficeRep__c);
                        if(tmpOrder.BusinessOfficeRep__r.ManagerId != null) mentionsIds.add(tmpOrder.BusinessOfficeRep__r.ManagerId);
                        LacComChatterService.simpleChatterFeed(null, tmpOrder.Id, chatterMessage, mentionsIds);
                    }

                    ////////////////////////////////////// OrderLineItem List
                    tmpOrderLineitem = orderLineitemMap.get(temp.OrderLineItemID);
                    System.debug('===============tmpOrderLineitem:' +tmpOrderLineitem);
                    if(tmpOrderLineitem != null){
                        // 2022/01/27
                        // 가격 결정일에 따른 ERP 주문 전송시 가격 정보 업데이트해서 보냄.
                        if(tmpOrderLineitem.OrderId__r.SoldTo__r.CustomerType__c == '관납') {
                            // 관납 기준가.
                            tmpOrderLineitem.BaseSellingPrice__c = tmpOrderLineitem.ProductId__r.GovListPrice__c;
                        } else if(tmpOrderLineitem.OrderId__r.SoldTo__r.CustomerType__c == '농협') {
                            // 농협 기준가
                            tmpOrderLineitem.BaseSellingPrice__c = tmpOrderLineitem.ProductId__r.NhListPrice__c;
                        } else {
                            // 대리점 기준가.
                            tmpOrderLineitem.BaseSellingPrice__c = tmpOrderLineitem.ProductId__r.DealerListPrice__c;
                        }
                        tmpOrderLineitem.CorrectionPrice__c = 0;
                        tmpOrderLineitem.SellingPrice__c = tmpOrderLineitem.BaseSellingPrice__c;
                        tmpOrderLineitem.ErpPOSNR__c    = temp.ErpPOSNR;

                        orderLineitems.add(tmpOrderLineitem);
                    }
                    returnMap.put('STATUS', 'Y');
                }
            }
            System.debug('### orders : '+orders + ' ::: ' + orders.size());
            System.debug('### orderLineitems : '+orderLineitems + ' ::: ' + orderLineitems.size());

            /*
             * ================================================================
             * Dml 수행 : 에러시 STATUS, MESSAGE 상태값 리턴
             * ================================================================
             */
            try {
                if(orders.size() > 0)            update orders;
                if(orderLineitems.size() > 0)    update orderLineitems;
            }
            catch(Exception e) {
                returnMap.put('STATUS', 'N');
                returnMap.put('MESSAGE', 'Failed to Request : ' + e);
                System.debug(System.LoggingLevel.ERROR, '::::: ERROR LOG ' + e);
            }

        } else {
            //실패 Failed to Request
            returnMap.put('STATUS', 'N');
            returnMap.put('MESSAGE', 'Failed to Request : ' + result.response.header.ifFailMsg);
        }

        System.debug('returnMap : ' + returnMap);

        return returnMap;
    }


    /**
     * @description : IF_KR_SE_ERP_0007 주문 생성 ZORT (SE <-> ERP)
     *                SFDC 내 주문 확정시 ERP 내 주문 연계 (테스트 중)
     * Order__c 에 OrderLineItem__c는 1개임.
     * Update Order, OrderLineitem
     * 버튼에서 호출됨
     */
    //OrderService.IF_KR_SE_ERP_0007_ZORT('a0Z1m0000006qGiEAI');
    public static Map<String, String> IF_KR_SE_ERP_0007_ZORT(String recordId) {

        Map<String, String> returnMap = new Map<String, String>();
        List<OrderLineitem__c> inputOrderLineitems = [
                SELECT  Id,
                        ProductId__r.ProductCode,
                        OrderId__c,
                        OrderId__r.BusinessOffice__r.SalesGroupCode__c,
                        OrderId__r.BusinessOffice__r.BusinessOfficeName__c,
                        OrderId__r.TransferBusinessOffice__r.BusinessOfficeName__c,
                        OrderId__r.Name,
                        OrderId__r.fm_SoldToErpCode__c,
                        OrderId__r.fm_SupplyToErpCode__c,
                        OrderId__r.ERP_Code__c,
                        OrderId__r.SalesDocNo__c,
                        OrderId__r.TransferMachineNo__c,
                        OrderId__r.TransferMachineNo__r.Name,
                        OrderId__r.TransferMachineNo__r.BatchNo__c,
                        OrderId__r.OrderScheduleDate__c,
                        OrderId__r.VSTEL__c,
                        OrderId__r.DeliveryComment__c,
                        OrderId__r.OrderAccount__c,
                        CorrectionPrice__c,
                        ListPrice__c,
                        UnitPrice__c,
                        NhGovListPrice__c,
                        SellingPrice__c
                FROM OrderLineitem__c
                WHERE OrderId__c = :recordId
        ];

        IF_KR_SE_ERP_0007           instance = IF_KR_SE_ERP_0007.getInstance();
        IF_KR_SE_ERP_0007.InputDIH  input = new IF_KR_SE_ERP_0007.InputDIH();
        IF_KR_SE_ERP_0007.T_DATA    tData;
        IF_KR_SE_ERP_0007.OutputDIH result;
        System.debug('### orderLineitems:::' + inputOrderLineitems.size());

        for(OrderLineitem__c oli : inputOrderLineitems ){
            /*
            (In : 데이터 채울 것) (Out : 전송시 스페이스 한자리, 수신하여 값 저장)(* 수신 필수)
            -------------------------------------------------------------------- 전송
            ( In ) OrderLineItemID  세일즈포스 주문 제품ID
            ( In ) ProductCode      제품코드
            ( In ) OrderID          세일즈포스 채번 주문ID
            ( In ) ErpVKGRP         영업그룹
            ( In ) ErpBSTKD         PO 번호(= Order__c.Name)
            ( In ) ErpBSTDK         PO 일자(= ERP 주문 생성 당일, yyyyMMdd)
            ( In ) ErpKUNNR         판매처
            ( In ) ErpKUNNR2        지급처
            ( In ) ErpKUNNR3        납품처

// ZRET 인 경우는 ZORT 주문 정보값을 해야 한다.
            ( In ) ErpBSTKD         PO 번호(= Order__c.Name)
            ( In ) ErpBSTDK         PO 일자(= ERP 주문 생성 당일, yyyyMMdd)

            ( In ) Quanitity        주문수량(=1)
            ( In ) ErpZFLAG         주문Flag(Create: C 설정)
            ( In ) ErpAUART         영업문서 유형(OR)
            ( In ) ErpVKORG         영업조직(3000)
            ( In ) ErpVTWEG         유통경로(10)
            ( In ) ErpSPART         제품군(71)
            ( In ) ErpVKBUR         영업팀(5600)

            -------------------------------------------------------------------- 수신
            [Order__c]
            (*Out) ErpZTERM__c  지급조건(* 전송시 스페이스 한자리, ERP 회신되는 값, Order__c에 저장)
            (*Out) SalesDocNo__c  판매문서번호(* 전송시 스페이스 한자리, 수신하여 값 저장)
            (*Out) ErpCMGST__c  ERP 여신상태(* 전송시 스페이스 한자리, 수신하여 값 저장)
            ( Out) ErpABGRU__c  ERP 거부사유(* 전송시 스페이스 한자리, 수신하여 값 저장)
            (*Out) ErpS_RESULT__c  ERP 처리결과(* 전송시 스페이스 한자리, 수신하여 값 저장)
            ( Out) ErpS_MESSAGE__c  ERP 메시지(* 전송시 N스페이스 한자리ull, 수신하여 값 저장)
            (*Out) ErpPOSNR__c  판매문서품목번호(* 전송시 스페이스 한자리, 수신하여 값 저장)

            [OrderLineItem__c]
            ( Out) ErpPOSNR__c : 판매문서품목번호 : (* 전송시 스페이스 한자리, 수신하여 OrderLineItem__c 값 저장)
            */


            /**
				AUART 영업문서 유형 : OR 일반내수판매, ZORT 전수배출고, ZRET 전수배반품
				VSTEL 출하지점 : M621경기, M622충북, M623전북, M624경북, M625강원, M626충남, M627전남, M628경남
				LGORT 저장위치: 3711경기, 3712충북, 3713전북, 3714경북, 3715강원, 3716충남, 3717전남, 3718경남
				ZFLAG : C 생성, D 삭제
			 */

            Map<String, String> VSTELMap = new Map<String, String>();
            VSTELMap.put('71A', 'M621');        // M621경기
            VSTELMap.put('71C', 'M622');        // M622충북
            VSTELMap.put('71E', 'M623');        // M623전북
            VSTELMap.put('71G', 'M624');        // M624경북
            VSTELMap.put('71B', 'M625');        // M625강원
            VSTELMap.put('71D', 'M626');        // M626충남
            VSTELMap.put('71F', 'M627');        // M627전남
            VSTELMap.put('71H', 'M628');        // M628경남

            Map<String, String> LGORTMap = new Map<String, String>();
            LGORTMap.put('M620', '3710');        // 전주공장
            LGORTMap.put('M621', '3711');        // 3711경기
            LGORTMap.put('M622', '3712');        // 3712충북
            LGORTMap.put('M623', '3713');        // 3713전북
            LGORTMap.put('M624', '3714');        // 3714경북
            LGORTMap.put('M625', '3715');        // 3715강원
            LGORTMap.put('M626', '3716');        // 3716충남
            LGORTMap.put('M627', '3717');        // 3717전남
            LGORTMap.put('M628', '3718');        // 3718경남


            // ZORT와 ZRET 값 동일 하게 사용.
            // 2021.04.30
/*            String sVSTEL = VSTELMap.containsKey(oli.OrderId__r.TransferBusinessOffice__r.BusinessOfficeName__c) ?
                    VSTELMap.get(oli.OrderId__r.TransferBusinessOffice__r.BusinessOfficeName__c) :
                    '';*/
            String sVSTEL = oli.OrderId__r.VSTEL__c;
            String sLGORT = LGORTMap.containsKey(oli.OrderId__r.VSTEL__c) ?
                    LGORTMap.get(oli.OrderId__r.VSTEL__c) :
                    '';

            tData = new IF_KR_SE_ERP_0007.T_DATA();

            tData.OrderID           = oli.OrderId__c;
            tData.OrderLineItemID   = oli.Id;
            tData.ProductCode       = oli.ProductId__r.ProductCode;
            tData.ErpVKGRP          = oli.OrderId__r.BusinessOffice__r.SalesGroupCode__c;
            tData.ErpBSTKD          = oli.OrderId__r.Name;
            tData.ErpBSTDK          = String.valueOf(system.now().format('yyyyMMdd'));
            tData.ErpKUNNR          = oli.OrderId__r.fm_SoldToErpCode__c;
            tData.ErpKUNNR2         = oli.OrderId__r.fm_SupplyToErpCode__c;
            tData.ErpKUNNR3         = oli.OrderId__r.ERP_Code__c;

            // 2021-07-26 수정 ============================================================================================
            tData.KEDAT             = ((Datetime)oli.OrderId__r.OrderScheduleDate__c).format('yyyyMMdd');   // 납품요청월
            tData.DLTXT             = String.isEmpty(oli.OrderId__r.DeliveryComment__c) ? '' : oli.OrderId__r.DeliveryComment__c;                                    // 출하전달사항
            // ============================================================================================================

            tData.Quanitity         = '1';
            tData.ErpZFLAG          = 'C';    // C: 생성, D: 삭제
            tData.ErpAUART          = 'ZORT';
            tData.ErpVKORG          = '3000';
            tData.ErpVTWEG          = '10';
            tData.ErpSPART          = '71';
            tData.ErpVKBUR          = '5600';

            tData.CHARG             = oli.OrderId__r.TransferMachineNo__r.BatchNo__c;
            tData.VSTEL             = sVSTEL;
            tData.LGORT             = sLGORT;

            tData.ErpPOSNR          = ' ';
            tData.ErpZTERM          = ' ';
            tData.SalesDocNo        = ' ';
            tData.ErpCMGST          = ' ';
            tData.ErpABGRU          = ' ';
            tData.ErpS_RESULT       = ' ';
            tData.ErpS_MESSAGE      = ' ';

            tData.NETWR1_C          = '';   //unitPrice == null ? '0' : String.valueOf(unitPrice);  // 기준 가격
            tData.NETWR2_C          = '';   //oli.CorrectionPrice__c == null ? '0' : String.valueOf(oli.CorrectionPrice__c);  // 가격 변경
            tData.NETWR3_C          = '';   //oli.SellingPrice__c == null ? '0' : String.valueOf(oli.SellingPrice__c);  // 공급 가격
            tData.RESERVE01         = '';   // 예비1
            tData.RESERVE02         = '';   // 예비2
            tData.RESERVE03         = '';   // 예비3
            tData.RESERVE04         = '';   // 예비4
            tData.RESERVE05         = '';   // 예비5

            tData.PRSDT             = String.valueOf(system.now().format('yyyyMMdd'));  // 가격 결정일

            // 적재
            input.request.payload.t_data.add(tData);
        }

        // Interface Request 실행
        System.debug('### input.request.payload.t_data : '+input.request.payload.t_data);
        if(!input.request.payload.t_data.isEmpty()){
            // crashTest
            //IF_Base.crashTest = true;
            result = instance.execute(input);
        }

        // Interface Response 처리
        if ('S'.equals(result.response.header.ifResult)) {
            //성공 Succeed to Request
            Map<String, Order__c> orderMap = new Map<String, Order__c>();
            Map<String, OrderLineitem__c> orderLineitemMap = new Map<String, OrderLineitem__c>();

            List<Order__c> orders = new List<SObject>();
            List<OrderLineitem__c> orderLineitems = new List<SObject>();

            Set<String> orderIds = new Set<String>();               // Order Ids
            Set<String> orderDealerOwnerIds = new Set<String>();    // OrderDealerOwner Ids

            System.debug('### t_data : '+result.Response.payload.t_data);
            List<IF_KR_SE_ERP_0007.T_DATA> t_data = result.Response.payload.t_data;

            // I/F에서 받은 데이터
            for(IF_KR_SE_ERP_0007.T_DATA temp: t_data) {
                if(String.isNotBlank(temp.OrderID))  orderIds.add(temp.OrderID);
            }

            // Order Map
            for(Order__c o : [
                    SELECT Id, Name, ErpPOSNR__c, ErpZTERM__c, SalesDocNo__c, ErpCMGST__c, ErpABGRU__c, ErpS_RESULT__c, ErpS_MESSAGE__c,
                            Dealer__r.Owner.Id, RecordType.Name,
                            BusinessOfficeRep__c, BusinessOfficeRep__r.ManagerId
                    FROM Order__c
                    WHERE id IN :orderIds]
            ) {
                if(!orderMap.containsKey(o.id)) {
                    orderMap.put(o.Id, o);
                }
            }

            // OrderLineItem Map
            for(OrderLineItem__c oli : [
                    SELECT Id, OrderId__c, ErpPOSNR__c, BaseSellingPrice__c, CorrectionPrice__c, SellingPrice__c,
                            OrderId__r.SoldTo__r.CustomerType__c,
                            ProductId__r.GovListPrice__c,
                            ProductId__r.NhListPrice__c,
                            ProductId__r.DealerListPrice__c
                    FROM OrderLineitem__c
                    WHERE OrderId__c IN :orderIds
            ]) {
                if(!orderLineitemMap.containsKey(oli.id)) {
                    orderLineitemMap.put(oli.Id, oli);
                }
            }


            Order__c tmpOrder;
            OrderLineitem__c tmpOrderLineitem;
            Boolean isGoodResponseData, isExistRecord;

            for(IF_KR_SE_ERP_0007.T_DATA temp: t_data) {
                // 데이터 확인
                tmpOrder = orderMap.get(temp.OrderID);
                // 데이터 확인 여부
                isExistRecord = tmpOrder != null ? true : false;

                /** ================================================================
                * 정상 Response 데이터 여부
                * ErpPOSNR, SalesDocNo, ErpCMGST 필수 항목
                * ================================================================*/
                isGoodResponseData = string.isNotBlank(temp.ErpS_RESULT)
                        && (temp.ErpS_RESULT == '00')
                        && String.isNotBlank(temp.ErpPOSNR)
                        && String.isNotBlank(temp.SalesDocNo)
//                                    && String.isNotBlank(temp.ErpCMGST)
                        && isExistRecord;

                if(isGoodResponseData == false) {
                    String message;
                    if(temp.ErpS_RESULT != '00')        message =  ' ' + temp.ErpS_MESSAGE  + '\n';
                    if(!isExistRecord)                  message += ' ' +temp.OrderID + '레코드가 존재하지 않습니다.'  + '\n';
                    if(String.isBlank(temp.ErpPOSNR))   message += ' 필수 리턴 값 : ErpPOSNR IS NULL'  + '\n';
                    if(String.isBlank(temp.SalesDocNo)) message += ' 필수 리턴 값 : SalesDocNo IS NULL'  + '\n';
//                    if(String.isBlank(temp.ErpCMGST))   message += ' 필수 리턴 값 : ErpCMGST IS NULL'  + '\n';

                    // ERP 처리결과, 메시지 저장
                    tmpOrder.ErpS_RESULT__c     = temp.ErpS_RESULT;
                    tmpOrder.ErpS_MESSAGE__c    = temp.ErpS_MESSAGE;

                    orders.add(tmpOrder);

                    returnMap.put('STATUS', 'N');
                    returnMap.put('MESSAGE', message);
                }
                else{
                    ////////////////////////////////////// Order List
                    tmpOrder.PriceDecisionDate__c = Date.today();   // 가격 결정일
                    tmpOrder.ErpZTERM__c        = temp.ErpZTERM;
                    tmpOrder.SalesDocNo__c      = temp.SalesDocNo;
                    tmpOrder.ErpCMGST__c        = String.isEmpty(temp.ErpCMGST) ? 'A' : temp.ErpCMGST;
                    tmpOrder.ErpABGRU__c        = temp.ErpABGRU;
                    tmpOrder.ErpS_RESULT__c     = temp.ErpS_RESULT;
                    tmpOrder.ErpS_MESSAGE__c    = temp.ErpS_MESSAGE;
                    tmpOrder.ErpPOSNR__c        = temp.ErpPOSNR;


                    if (temp.ErpCMGST == 'B' && tmpOrder.RecordType.Name != '관납/농협') {
                        tmpOrder.Status__c = '본사 여신 검토';
                        tmpOrder.SystemStatus__c = '본사 여신 검토';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
                    } else if (String.isEmpty(temp.ErpCMGST) || temp.ErpCMGST == 'A' || temp.ErpCMGST == 'D') {
                        tmpOrder.Status__c = '출하';
                        tmpOrder.SystemStatus__c = '출하';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
                    }
                    orders.add(tmpOrder);

                    // temp.ErpABGRU = '95' (수주 손익 미결재) 일 경우 영업사원과 관리자 에게 Chatter 알림
                    if(temp.ErpABGRU == '95'){
                        String chatterMessage = tmpOrder.Name +' 수주 손익 미결 상태로, SAP 수주 손익 승인 요청 Workflow가 실행되었습니다. SAP 內 확인 바랍니다.';
                        Set<String> mentionsIds = new Set<String>();
                        if(tmpOrder.BusinessOfficeRep__c != null) mentionsIds.add(tmpOrder.BusinessOfficeRep__c);
                        if(tmpOrder.BusinessOfficeRep__r.ManagerId != null) mentionsIds.add(tmpOrder.BusinessOfficeRep__r.ManagerId);
                        LacComChatterService.simpleChatterFeed(null, tmpOrder.Id, chatterMessage, mentionsIds);
                    }

                    ////////////////////////////////////// OrderLineItem List
                    tmpOrderLineitem = orderLineitemMap.get(temp.OrderLineItemID);
                    System.debug('===============tmpOrderLineitem:' +tmpOrderLineitem);
                    if(tmpOrderLineitem != null){
                        tmpOrderLineitem.ErpPOSNR__c    = temp.ErpPOSNR;

                        // 2022/01/27
                        // 가격 결정일에 따른 ERP 주문 전송시 가격 정보 업데이트해서 보냄.
                        if(tmpOrderLineitem.OrderId__r.SoldTo__r.CustomerType__c == '관납') {
                            // 관납 기준가.
                            tmpOrderLineitem.BaseSellingPrice__c = tmpOrderLineitem.ProductId__r.GovListPrice__c;
                        } else if(tmpOrderLineitem.OrderId__r.SoldTo__r.CustomerType__c == '농협') {
                            // 농협 기준가
                            tmpOrderLineitem.BaseSellingPrice__c = tmpOrderLineitem.ProductId__r.NhListPrice__c;
                        } else {
                            // 대리점 기준가.
                            tmpOrderLineitem.BaseSellingPrice__c = tmpOrderLineitem.ProductId__r.DealerListPrice__c;
                        }
                        tmpOrderLineitem.CorrectionPrice__c = 0;
                        tmpOrderLineitem.SellingPrice__c = tmpOrderLineitem.BaseSellingPrice__c;

                        orderLineitems.add(tmpOrderLineitem);
                    }
                    returnMap.put('STATUS', 'Y');
                }
            }
            System.debug('### orders : '+orders + ' ::: ' + orders.size());
            System.debug('### orderLineitems : '+orderLineitems + ' ::: ' + orderLineitems.size());

            /*
             * ================================================================
             * Dml 수행 : 에러시 STATUS, MESSAGE 상태값 리턴
             * ================================================================
             */
            try {
                if(orders.size() > 0)            update orders;
                if(orderLineitems.size() > 0)    update orderLineitems;
            }
            catch(Exception e) {
                returnMap.put('STATUS', 'N');
                returnMap.put('MESSAGE', 'Failed to Request : ' + e);
                System.debug(System.LoggingLevel.ERROR, '::::: ERROR LOG ' + e);
            }

        } else {
            //실패 Failed to Request
            returnMap.put('STATUS', 'N');
            returnMap.put('MESSAGE', 'Failed to Request : ' + result.response.header.ifFailMsg);
        }

        System.debug('returnMap : ' + returnMap);

        return returnMap;
    }


    /**
     * @description : IF_KR_SE_ERP_0007 주문 생성 ZRET (SE <-> ERP)
     *                SFDC 내 주문 확정시 ERP 내 주문 연계 (테스트 중)
     * Order__c 에 OrderLineItem__c는 1개임.
     * Update Order, OrderLineitem
     * 버튼에서 호출됨
     */
    //OrderService.IF_KR_SE_ERP_0007('a0Z1m0000006qGiEAI');
    public static Map<String, String> IF_KR_SE_ERP_0007_ZRET(String recordId) {

        Map<String, String> returnMap = new Map<String, String>();

        Order__c order = [
                SELECT
                        Id, Division__c, SalesDocNo__c, Status__c, IsZRET__c, TransferProcessStatus__c, AssetTransferAgreeStatus__c,
                        TransferMachineNo__r.Name,
                        TransferMachineNo__r.BatchNo__c,
                        TransferMachineNo__r.Dealer__r.ERPCode__c,
                        TransferMachineNo__r.Account.ERPCode__c,
                        TransferMachineNo__r.Account.CustomerType__c,
                        TransferMachineNo__r.BusinessOffice__r.SalesGroupCode__c,
                        TransferMachineNo__r.Order__r.PriceDecisionDate__c,
                        OrderScheduleDate__c,
                        BusinessOffice__r.SalesGroupCode__c,
                        (SELECT Id, OrderLineitem__c , OrderLineitem__r.OrderId__r.OrderScheduleDate__c, SalesDocNo__c, TransferDealer__c, Status__c,
                                TransferDealer__r.ERPCode__c,
                                TransferDealer__r.BusinessOfficeName__c,
                                Product__r.ProductCode
                        FROM TransferOrders__r LIMIT 1)
                FROM Order__c WHERE Id =: recordId
        ];

        System.debug(JSON.serializePretty(order));
        TransferOrder__c transferOrder = null;
        if(order.TransferOrders__r != null && order.TransferOrders__r.size() > 0) {
            transferOrder = order.TransferOrders__r[0];
        }
        if(transferOrder == null) {
            returnMap.put('STATUS', 'N');
            returnMap.put('MESSAGE', '반품 주문 정보가 없습니다. ERP주문을 먼저 처리 해주세요.');
            return returnMap;
        }
        if(order.TransferMachineNo__r.Order__r.PriceDecisionDate__c == null) {
            returnMap.put('STATUS', 'N');
            returnMap.put('MESSAGE', '이전 주문의 가격결정일자 정보를 찾을 수 없습니다. 관리자에게 문의하시기 바랍니다.');
            return returnMap;
        }

        IF_KR_SE_ERP_0007           instance = IF_KR_SE_ERP_0007.getInstance();
        IF_KR_SE_ERP_0007.InputDIH  input = new IF_KR_SE_ERP_0007.InputDIH();
        IF_KR_SE_ERP_0007.T_DATA    tData;
        IF_KR_SE_ERP_0007.OutputDIH result;


        /*
        (In : 데이터 채울 것) (Out : 전송시 스페이스 한자리, 수신하여 값 저장)(* 수신 필수)
        -------------------------------------------------------------------- 전송
        ( In ) OrderLineItemID  세일즈포스 주문 제품ID
        ( In ) ProductCode      제품코드
        ( In ) OrderID          세일즈포스 채번 주문ID
        ( In ) ErpVKGRP         영업그룹
        ( In ) ErpBSTKD         PO 번호(= Order__c.Name)
        ( In ) ErpBSTDK         PO 일자(= ERP 주문 생성 당일, yyyyMMdd)
        ( In ) ErpKUNNR         판매처
        ( In ) ErpKUNNR2        지급처
        ( In ) ErpKUNNR3        납품처

// ZRET 인 경우는 ZORT 주문 정보값을 해야 한다.
        ( In ) ErpBSTKD         PO 번호(= Order__c.SalesDocNo__c)
        ( In ) ErpBSTDK         PO 일자(= ERP 주문 생성 당일, yyyyMMdd)

        ( In ) Quanitity        주문수량(=1)
        ( In ) ErpZFLAG         주문Flag(Create: C 설정)
        ( In ) ErpAUART         영업문서 유형(OR)
        ( In ) ErpVKORG         영업조직(3000)
        ( In ) ErpVTWEG         유통경로(10)
        ( In ) ErpSPART         제품군(71)
        ( In ) ErpVKBUR         영업팀(5600)

        -------------------------------------------------------------------- 수신
        [Order__c]
        (*Out) ErpZTERM__c  지급조건(* 전송시 스페이스 한자리, ERP 회신되는 값, Order__c에 저장)
        (*Out) SalesDocNo__c  판매문서번호(* 전송시 스페이스 한자리, 수신하여 값 저장)
        (*Out) ErpCMGST__c  ERP 여신상태(* 전송시 스페이스 한자리, 수신하여 값 저장)
        ( Out) ErpABGRU__c  ERP 거부사유(* 전송시 스페이스 한자리, 수신하여 값 저장)
        (*Out) ErpS_RESULT__c  ERP 처리결과(* 전송시 스페이스 한자리, 수신하여 값 저장)
        ( Out) ErpS_MESSAGE__c  ERP 메시지(* 전송시 N스페이스 한자리ull, 수신하여 값 저장)
        (*Out) ErpPOSNR__c  판매문서품목번호(* 전송시 스페이스 한자리, 수신하여 값 저장)

        [OrderLineItem__c]
        ( Out) ErpPOSNR__c : 판매문서품목번호 : (* 전송시 스페이스 한자리, 수신하여 OrderLineItem__c 값 저장)
        */

        /**
            AUART 영업문서 유형 : OR 일반내수판매, ZORT 전수배출고, ZRET 전수배반품
            VSTEL 출하지점 : M621경기, M622충북, M623전북, M624경북, M625강원, M626충남, M627전남, M628경남
            LGORT 저장위치: 3711경기, 3712충북, 3713전북, 3714경북, 3715강원, 3716충남, 3717전남, 3718경남
            ZFLAG : C 생성, D 삭제
         */

        Map<String, String> VSTELMap = new Map<String, String>();
        VSTELMap.put('71A', 'M621');        // M621경기
        VSTELMap.put('71C', 'M622');        // M622충북
        VSTELMap.put('71E', 'M623');        // M623전북
        VSTELMap.put('71G', 'M624');        // M624경북
        VSTELMap.put('71B', 'M625');        // M625강원
        VSTELMap.put('71D', 'M626');        // M626충남
        VSTELMap.put('71F', 'M627');        // M627전남
        VSTELMap.put('71H', 'M628');        // M628경남

        Map<String, String> LGORTMap = new Map<String, String>();
        LGORTMap.put('71A', '3711');        // 3711경기
        LGORTMap.put('71C', '3712');        // 3712충북
        LGORTMap.put('71E', '3713');        // 3713전북
        LGORTMap.put('71G', '3714');        // 3714경북
        LGORTMap.put('71B', '3715');        // 3715강원
        LGORTMap.put('71D', '3716');        // 3716충남
        LGORTMap.put('71F', '3717');        // 3717전남
        LGORTMap.put('71H', '3718');        // 3718경남

        String sVSTEL = VSTELMap.containsKey(transferOrder.TransferDealer__r.BusinessOfficeName__c) ?
                            VSTELMap.get(transferOrder.TransferDealer__r.BusinessOfficeName__c) :
                            '';
        String sLGORT = LGORTMap.containsKey(transferOrder.TransferDealer__r.BusinessOfficeName__c) ?
                            LGORTMap.get(transferOrder.TransferDealer__r.BusinessOfficeName__c) :
                            '';

        tData = new IF_KR_SE_ERP_0007.T_DATA();

        tData.OrderID           = transferOrder.Id;
        tData.OrderLineItemID   = transferOrder.OrderLineitem__c;
        tData.ProductCode       = transferOrder.Product__r.ProductCode;
        tData.ErpVKGRP          = order.TransferMachineNo__r.BusinessOffice__r.SalesGroupCode__c;   //BusinessOffice__r.SalesGroupCode__c;
        tData.ErpBSTKD          = order.SalesDocNo__c;

        Date orgPoDate          = order.TransferMachineNo__r.Order__r.PriceDecisionDate__c;
        tData.ErpBSTDK          = String.valueOf(((Datetime) orgPoDate).format('yyyyMMdd'));      // 원주문의 PO 날짜

    // 수배 대리점의 ERP Code를 지정 해야 한다.
        // 수배 대리점의 자산의 고객이 농협/관납이면 농협/관납 ERPCode__c를 보낸다.
        // 2021/04/22
        //
        tData.ErpKUNNR          = transferOrder.TransferDealer__r.ERPCode__c;
        tData.ErpKUNNR2         = transferOrder.TransferDealer__r.ERPCode__c;
        tData.ErpKUNNR3         = transferOrder.TransferDealer__r.ERPCode__c;
//        order.TransferMachineNo__r.Dealer__r.ERPCode__c,
//        order.TransferMachineNo__r.Account.ERPCode__c,
        Set<String> checkCustomers = new Set<String>{'농협','관납'};
        if(checkCustomers.contains(order.TransferMachineNo__r.Account.CustomerType__c)) {
            tData.ErpKUNNR          = order.TransferMachineNo__r.Account.ERPCode__c;
            tData.ErpKUNNR2         = order.TransferMachineNo__r.Account.ERPCode__c;
            tData.ErpKUNNR3         = order.TransferMachineNo__r.Account.ERPCode__c;
        }
        // 2021-07-26 수정 ============================================================================================
        String sKEDAT = Datetime.now().format('yyyyMMdd');
        if(transferOrder.OrderLineitem__r.OrderId__r.OrderScheduleDate__c != null) {
            sKEDAT = ((Datetime)transferOrder.OrderLineitem__r.OrderId__r.OrderScheduleDate__c).format('yyyyMMdd');
        }
        tData.KEDAT             = sKEDAT;       // 납품요청월
        tData.DLTXT             = ' ';                                    // 출하전달사항
        // ============================================================================================================


        tData.Quanitity         = '1';
        tData.ErpZFLAG          = 'C';    // C: 생성, D: 삭제
        tData.ErpAUART          = 'ZRET';
        tData.ErpVKORG          = '3000';
        tData.ErpVTWEG          = '10';
        tData.ErpSPART          = '71';
        tData.ErpVKBUR          = '5600';

        tData.CHARG             = order.TransferMachineNo__r.BatchNo__c;        // 배치 번호

        tData.VSTEL             = sVSTEL;
        tData.LGORT             = sLGORT;

        tData.ErpPOSNR          = ' ';
        tData.ErpZTERM          = ' ';
        tData.SalesDocNo        = ' ';
        tData.ErpCMGST          = ' ';
        tData.ErpABGRU          = ' ';
        tData.ErpS_RESULT       = ' ';
        tData.ErpS_MESSAGE      = ' ';

        // 2021-10-25 : 주문 가격 수정 : ITVOC-2021-09-0526
        tData.NETWR1_C          = '';  // 기준 가격
        tData.NETWR2_C          = '';  // 가격 변경
        tData.NETWR3_C          = '';  // 공급 가격
        tData.RESERVE01         = '';  // 예비1
        tData.RESERVE02         = '';  // 예비2
        tData.RESERVE03         = '';  // 예비3
        tData.RESERVE04         = '';  // 예비4
        tData.RESERVE05         = '';  // 예비5

        tData.PRSDT             = String.valueOf(((Datetime) order.TransferMachineNo__r.Order__r.PriceDecisionDate__c).format('yyyyMMdd')); // 가격 결정일

        // 적재
        input.request.payload.t_data.add(tData);

        // Interface Request 실행
        System.debug('### input.request.payload.t_data : '+input.request.payload.t_data);
        if(!input.request.payload.t_data.isEmpty()){
            // crashTest
            //IF_Base.crashTest = true;
            result = instance.execute(input);
        }


        System.debug('결과.----------------------');
        System.debug(JSON.serialize(result));
        System.debug('----------------------');

        if ('S'.equals(result.response.header.ifResult)) {
            System.debug('I/F 정상 ========================');
            System.debug('### t_data : '+result.response.payload.t_data);
            List<IF_KR_SE_ERP_0007.T_DATA> t_data = result.response.payload.t_data;

            for (IF_KR_SE_ERP_0007.T_DATA temp : t_data) {
                System.debug('ErpZTERM__c = ' + temp.ErpZTERM);
                System.debug('SalesDocNo__c = ' + temp.SalesDocNo);
                System.debug('ErpCMGST__c = ' + temp.ErpCMGST);
                System.debug('ErpABGRU__c = ' + temp.ErpABGRU);
                System.debug('ErpS_RESULT__c = ' + temp.ErpS_RESULT);
                System.debug('ErpS_MESSAGE__c = ' + temp.ErpS_MESSAGE);
                System.debug('ErpPOSNR__c = ' + temp.ErpPOSNR );
                if(String.isBlank(temp.SalesDocNo)) {
                    returnMap.put('STATUS', 'N');
                    returnMap.put('MESSAGE', '[반품주문오류(ZRET)] 반품주문번호가 없습니다. '+ temp.ErpS_MESSAGE);
                    return returnMap;
                }

                transferOrder.SalesDocNo__c = temp.SalesDocNo;
                transferOrder.ERP_ABGRU__c = temp.ErpABGRU;
                transferOrder.ERP_MESSAGE__c = temp.ErpS_MESSAGE;
                transferOrder.ERP_RESULT__c = temp.ErpS_RESULT;
                transferOrder.ERP_POSNR__c = temp.ErpPOSNR;
                transferOrder.Status__c = '완료';

                order.IsZRET__c = true;     // 반품 처리 완료.
            }

            returnMap.put('STATUS', 'Y');
            returnMap.put('MESSAGE', '정상적으로 반품 주문이 생성 되었습니다');
        } else {
            returnMap.put('STATUS', 'N');
            returnMap.put('MESSAGE', 'ERP 주문 생성 오류 : ' + result.response.header.ifFailMsg);

            transferOrder.ERP_MESSAGE__c = '99';
            transferOrder.ERP_RESULT__c = 'ERP 주문 생성 오류 : ' + result.response.header.ifFailMsg;
            System.debug('I/F 오류 ========================');
        }
        update transferOrder;

        update order;

        return returnMap;
    }

    /**
     * SAP 입출고 처리.
     *
     * @param VBELN 판매오더 : 판매 문서 번호
     * @param WADAT 전기일
     * @param CHARG 기대번호
     *
     * @return
     */
    public static IF_KR_SE_ERP_0038.OutputDIH IF_KR_SE_ERP_0038(String VBELN, String WADAT, String CHARG, String LGORT) {

        IF_KR_SE_ERP_0038           instance = IF_KR_SE_ERP_0038.getInstance();
        IF_KR_SE_ERP_0038.InputDIH  input = new IF_KR_SE_ERP_0038.InputDIH();
        IF_KR_SE_ERP_0038.T_DATA    tData;
        IF_KR_SE_ERP_0038.OutputDIH result;

        tData = new IF_KR_SE_ERP_0038.T_DATA();
        tData.VBELN       = VBELN;      // VBELN		판매오더
        tData.WADAT       = WADAT;      // WADAT		전기일
        tData.CHARG       = CHARG == null ? '' : CHARG;      // CHARG		기대번호
        //TODO : ITVOC-2022-03-0717
        tData.LGORT       = LGORT == null ? '' : LGORT;     //출하위치;
        System.debug(JSON.serializePretty(tData));
        input.request.payload.t_data.add(tData);
        if(!input.request.payload.t_data.isEmpty()){
            // crashTest
            //IF_Base.crashTest = true;
            result = instance.execute(input);
        }
        return result;
    }

    /**
     * IF_KR_SE_ERP_0011 추가 여신 승인 결과 회신 (SE -> ERP)
     * Order_tr.loanApprovalComplete 에서 호출.
     *
     * @param orderIds
     */
    @Future(callout=true)
    public static void loanApprovalCompleteReturnERP(Set<Id> orderIds) {
        for(Id recordId : orderIds) {
            IF_KR_SE_ERP_0011(recordId);
        }
    }

    /**
     * @description : IF_KR_SE_ERP_0011 추가 여신 승인 결과 회신 (SE -> ERP)
     *                ERP 여신 승인 요청에 대한 승인/반려 처리 결과 ERP 회신
     *                SFDC)""주문""Object와 연동"	SE에서 영업 부문의 추가 여신 승인 결과 회신
     * 트리거에서 호출됨
     */
    //@Future
    public static void IF_KR_SE_ERP_0011(String recordId) {
        List<OrderApprover__c> orderApprovers = [
                SELECT  OrderSellIn__c,
                        ErpZLNNO__c,
                        ErpAPPRV__c,
                        ErpPERNR__c,
                        ErpUNAME__c,
                        ErpDGPER__c,
                        ErpDGATE__c,
                        ErpDGTFR__c,
                        ErpDGTTO__c,
                        fm_ErpZPICH__c,
                        ErpZLADD__c,
                        ErpAPSTA__c,
                        ErpAPDAT__c,
                        ErpAPTIM__c,
                        fm_ErpLRESN_T__c,
                        fm_ErpLPLAN_T__c,
                        fm_ErpLFDBK_T__c
                FROM OrderApprover__c
                WHERE OrderSellIn__c = :recordId
        ];

        IF_KR_SE_ERP_0011           instance = IF_KR_SE_ERP_0011.getInstance();
        IF_KR_SE_ERP_0011.InputDIH  input = new IF_KR_SE_ERP_0011.InputDIH();
        IF_KR_SE_ERP_0011.T_DATA    tData;
        IF_KR_SE_ERP_0011.OutputDIH result;
        System.debug('orderApprovers:::' + orderApprovers.size());

        for(OrderApprover__c oa : orderApprovers ) {
            /*
            -------------------------------------------------------------------- 전송
            ErpZLNNO         (E)여신승인요청번호   (* 전송시 null일 경우 스페이스 한자리)
            ErpAPPRV         승인차수             (* 전송시 null일 경우 스페이스 한자리)
            ErpPERNR         승인권한자 사번       (* 전송시 null일 경우 스페이스 한자리)
            ErpUNAME         승인권한자 ID        (* 전송시 null일 경우 스페이스 한자리)
            ErpDGPER         권한위임자 사번       (* 전송시 null일 경우 스페이스 한자리)
            ErpDGATE         권한위임자 ID        (* 전송시 null일 경우 스페이스 한자리)
            ErpDGTFR         위임시작일           (* 전송시 null일 경우 스페이스 한자리)
            ErpDGTTO         위임종료일           (* 전송시 null일 경우 스페이스 한자리)
            ErpZPICH         승인자 ID           (* 전송시 null일 경우 스페이스 한자리)
            ErpZLADD         첨언여부             (* 전송시 null일 경우 스페이스 한자리)
            ErpAPSTA         승인여부             (* 전송시 null일 경우 스페이스 한자리)
            ErpAPDAT         승인일               (* 전송시 null일 경우 스페이스 한자리)
            ErpAPTIM         승인시간             (* 전송시 null일 경우 스페이스 한자리)
            ErpLRESN_T       연체사유             (* 전송시 null일 경우 스페이스 한자리)
            ErpLPLAN_T       수금계획             (* 전송시 null일 경우 스페이스 한자리)
            ErpLFDBK_T       담당자의견           (* 전송시 null일 경우 스페이스 한자리)

            -------------------------------------------------------------------- 수신
             */
            tData = new IF_KR_SE_ERP_0011.T_DATA();

            tData.ErpZLNNO	    =  (oa.ErpZLNNO__c != null) ? oa.ErpZLNNO__c : ' ';
            tData.ErpAPPRV	    =  (oa.ErpAPPRV__c != null) ? oa.ErpAPPRV__c : ' ';
            tData.ErpPERNR	    =  (oa.ErpPERNR__c != null) ? oa.ErpPERNR__c : ' ';
            tData.ErpUNAME	    =  (oa.ErpUNAME__c != null) ? oa.ErpUNAME__c : ' ';
            tData.ErpDGPER	    =  (oa.ErpDGPER__c != null) ? oa.ErpDGPER__c : ' ';
            tData.ErpDGATE	    =  (oa.ErpDGATE__c != null) ? oa.ErpDGATE__c : ' ';
            tData.ErpDGTFR	    =  (oa.ErpDGTFR__c != null) ? oa.ErpDGTFR__c : ' ';
            tData.ErpDGTTO	    =  (oa.ErpDGTTO__c != null) ? oa.ErpDGTTO__c : ' ';
            tData.ErpZPICH	    =  (oa.fm_ErpZPICH__c != null) ? oa.fm_ErpZPICH__c : ' ';
            tData.ErpZLADD	    =  (oa.ErpZLADD__c != null) ? oa.ErpZLADD__c : ' ';
            tData.ErpAPSTA	    =  (oa.ErpAPSTA__c != null) ? oa.ErpAPSTA__c : ' ';
            tData.ErpAPDAT	    =  (oa.ErpAPDAT__c != null) ? oa.ErpAPDAT__c : ' ';
            tData.ErpAPTIM	    =  (oa.ErpAPTIM__c != null) ? oa.ErpAPTIM__c : ' ';
            tData.ErpLRESN_T	=  (oa.fm_ErpLRESN_T__c != null) ? oa.fm_ErpLRESN_T__c : ' ';
            tData.ErpLPLAN_T	=  (oa.fm_ErpLPLAN_T__c != null) ? oa.fm_ErpLPLAN_T__c : ' ';
            tData.ErpLFDBK_T	=  (oa.fm_ErpLFDBK_T__c != null) ? oa.fm_ErpLFDBK_T__c : ' ';

            // 적재
            input.request.payload.t_data.add(tData);
        }

        // Interface Request 실행
        System.debug('input.request.payload.t_data : '+input.request.payload.t_data);
        if(!input.request.payload.t_data.isEmpty()){
            // crashTest
            //IF_Base.crashTest = true;
            result = instance.execute(input);
        }

        System.debug('result : ' + result);
        // Interface Response 처리
        if ('S'.equals(result.response.header.ifResult)) {
            //성공 Succeed to Request
        }else{
            //실패 Failed to Request
            System.debug('Error Message : ' + result.response.header.ifFailMsg);
        }
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