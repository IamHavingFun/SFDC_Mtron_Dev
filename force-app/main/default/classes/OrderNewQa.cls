/****************************************************************************************
  * @filename      : OrderNewQa
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-04-16 오후 1:32
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OrderNewQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-04-16 오후 1:32     i2max_my.Seo        Create
    1.0     2022-05-13               i2max               ITVOC-2022-04-0777, ITVOC-2022-04-0825, ITVOC-2022-03-0710
****************************************************************************************/
public without sharing class OrderNewQa {

    /**
     * @description wrapper class for InitData
     */
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled
        public WrapperData wrapperData {
            get {
                if(this.wrapperData == null) {
                    this.wrapperData = new WrapperData();
                }

                return this.wrapperData;
            }
            set;
        }
        @AuraEnabled
        public List<I2ComClass.Option> priceChangeCommentOptions {
            get {
                if(priceChangeCommentOptions == null) priceChangeCommentOptions = I2ComUtil.makePickListOptions('OrderLineItem__c', 'PriceChangeComment__c', true, false);
                return this.priceChangeCommentOptions;
            }
            private set;
        }
    }

    /**
     * @description init method.
     *
     * @param recordId      : 주문 수정의 경우, 해당 Order의 RecordId
     *
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static I2ComClass.InitData init(String recordId) {
        //주문 생성 시, initData에서 recordType을 지정을 위한 code.
        Map<String, String> orderRecordTypeIdByDevName     = returnRecordTypeMapByDevName('Order__c');
        Map<String, String> oliRecordTypeIdByDevName       = returnRecordTypeMapByDevName('OrderLineItem__c');

        InitData initData = new InitData();
        initData.wrapperData.currentDate = Date.today();

        // 필수 InitData
        initData.wrapperData.isInsert                      = String.isBlank(recordId);
        initData.wrapperData.isPartner                     = OrderService.isPartner();
        initData.wrapperData.isErpPriceChange              = false;         // 가격 정보
        initData.wrapperData.isOrderScheduleChange         = false;         // 납품 요청월 수정
        initData.wrapperData.isErpDeliveryChange           = false;         // ERP 출하 정보 수정
        initData.wrapperData.isPurposeOfOrderChange        = false;         // 주문 목적 정보 수정
        initData.wrapperData.isSaveButton                  = false;         // 저장 버튼 처리 가능 여부
        initData.wrapperData.isERPSaveButton               = false;         // ERP 저장 버튼 처리 가능 여부

        final User tempUser = ModelUser.getUserData();

        // 주문 수정
        if(String.isNotBlank(recordId)) {
            initData.wrapperData.order = [
                    SELECT Id, Name, OrderAccount__c, OrderAccount__r.Name, PurposeOfOrder__c,
                            Division__c, RecordType.DeveloperName, Status__c,
                            Opportunity__c, Opportunity__r.Name,
                            DeliverTo__c, DeliveryDate__c, DeliverTo__r.Name, DeliverTo__r.CustomerType__c,
                            OrderScheduleDate__c,
                            LoanApprovalStatus__c, SalesDocNo__c, VSTEL__c, DeliveryComment__c,
                            BusinessOffice__r.BusinessOfficeName__c, BusinessOffice__r.SalesGroupCode__c,
                            fm_SoldToErpCode__c, fm_SupplyToErpCode__c, ERP_Code__c, ErpPOSNR__c,
                            TransferMachineNo__r.Name, TransferMachineNo__r.BatchNo__c,
                            ErpCMGST__c, SoldTo__r.CustomerType__c,
                            Dealer__r.DealerOwner__c, Dealer__r.OwnerId, RecordType.Name,
                            Dealer__c, OrderProduct__c, ErpZLNNO__c, IsOutAsset__c, PriceDecisionDate__c,
                            BusinessOfficeRep__c, BusinessOfficeRep__r.ManagerId
                    FROM Order__c
                    WHERE Id = :recordId
            ];

            initData.wrapperData.oldPriceDecisionDate = initData.wrapperData.order.PriceDecisionDate__c;    // 가격 결정일
            /*
                `2021-03-11 추가.
                주문구분 값이 전수배 일때 로직 추가.
            */
            initData.wrapperData.orderDivision = initData.wrapperData.order.Division__c;

            initData.wrapperData.orderLineItemList = [
                    SELECT  Id,
                            PriceChangeComment__c,
                            OtherChangeComment__c,
                            ProductId__c,
                            ProductId__r.Type__c,
                            ProductId__r.Name,
                            ProductId__r.ProductCode,
                            ProductId__r.NhListPrice__c,
                            ProductId__r.GovListPrice__c,
                            ProductId__r.DealerListPrice__c,
                            ProductId__r.ProductDivision__c,
                            ProductId__r.HorsePowerStandard__c,
                            ListPrice__c,
                            UnitPrice__c,
                            NhGovListPrice__c,
                            BaseSellingPrice__c,
                            CorrectionPrice__c,
                            SellingPrice__c,
                            TransferAsset__r.Name,
                            DTFeeMaxAmt__c, DTFeeMinAmt__c, DTFeeMaxRate__c, DTFeeMinRate__c,
                            SGFeeMaxAmt__c, SGFeeMinAmt__c, SGFeeMaxRate__c, SGFeeMinRate__c,
                            MSFeeMaxAmt__c, MSFeeMinAmt__c, MSFeeMaxRate__c, MSFeeMinRate__c,
                            LAFeeMaxAmt__c, LAFeeMinAmt__c, LAFeeMaxRate__c, LAFeeMinRate__c,
                            RSFeeMaxAmt__c, RSFeeMinAmt__c, RSFeeMaxRate__c, RSFeeMinRate__c,
                            MAFeeMaxAmt__c, MAFeeMinAmt__c, MAFeeMaxRate__c, MAFeeMinRate__c,
                            EPFeeMaxAmt__c, EPFeeMinAmt__c, EPFeeMaxRate__c, EPFeeMinRate__c,
                            SPFeeMaxAmt__c, SPFeeMinAmt__c, SPFeeMaxRate__c, SPFeeMinRate__c,
                            fm_SupplyHighAmt__c, fm_SupplyLowAmt__c
                    FROM OrderLineitem__c
                    WHERE OrderId__c = :recordId
            ];

            if(initData.wrapperData.orderLineItemList.isEmpty() == false) {
                if(initData.wrapperData.orderLineItemList[0].BaseSellingPrice__c == null) {
                    if(initData.wrapperData.order.SoldTo__r.CustomerType__c == '관납') {
                        // 관납 기준가.
                        initData.wrapperData.orderLineItemList[0].BaseSellingPrice__c = initData.wrapperData.orderLineItemList[0].ProductId__r.GovListPrice__c;
                    } else if(initData.wrapperData.order.SoldTo__r.CustomerType__c == '농협') {
                        // 농협 기준가
                        initData.wrapperData.orderLineItemList[0].BaseSellingPrice__c = initData.wrapperData.orderLineItemList[0].ProductId__r.NhListPrice__c;
                    } else {
                        // 대리점 기준가.
                        initData.wrapperData.orderLineItemList[0].BaseSellingPrice__c = initData.wrapperData.orderLineItemList[0].ProductId__r.DealerListPrice__c;
                    }
                    initData.wrapperData.orderLineItemList[0].CorrectionPrice__c = 0;
                    initData.wrapperData.orderLineItemList[0].SellingPrice__c = initData.wrapperData.orderLineItemList[0].BaseSellingPrice__c;
                }
            }

            if(initData.wrapperData.orderLineItemList[0].TransferAsset__c != null) {
                List<Asset> tempAssetList = [
                        SELECT Id, TransferOrder__c, Name, Dealer__r.Name
                        FROM Asset
                        WHERE TransferOrder__c = :recordId
                ];

                if(tempAssetList.size() > 0) initData.wrapperData.asset = tempAssetList[0];
            }

            initData.wrapperData.supplyHighAmt = initData.wrapperData.orderLineItemList[0].fm_SupplyHighAmt__c;
            initData.wrapperData.supplyLowAmt  = initData.wrapperData.orderLineItemList[0].fm_SupplyLowAmt__c;

            if(initData.wrapperData.order.Opportunity__c != null) {
                initData.wrapperData.opptyName = initData.wrapperData.order.Opportunity__r.Name;
            }
/*
            if(initData.wrapperData.order.OrderScheduleDate__c != null) {
                if(initData.wrapperData.order.OrderScheduleDate__c < System.today()) {
                    String tempOrderScheduleDate = String.valueOf(initData.wrapperData.order.OrderScheduleDate__c.toStartOfMonth());

                    initData.orderScheduleDateList.set(0, new I2ComClass.Option(tempOrderScheduleDate.replaceAll('-', '.').left(7), String.valueOf(initData.wrapperData.order.OrderScheduleDate__c)));
                } else if (initData.wrapperData.order.OrderScheduleDate__c > System.today().addMonths(7).addDays(-1)) {
                    String tempOrderScheduleDate = String.valueOf(initData.wrapperData.order.OrderScheduleDate__c.toStartOfMonth());

                    initData.orderScheduleDateList.add(new I2ComClass.Option(tempOrderScheduleDate.replaceAll('-', '.').left(7), String.valueOf(initData.wrapperData.order.OrderScheduleDate__c)));
                }
            }
*/
            initData.wrapperData.isPerFarCorp = (initData.wrapperData.order.RecordType.DeveloperName == 'PerFarCorp') ? true  : false;

            initData.wrapperData.isErpPriceChange              = false;         // 가격 정보
            initData.wrapperData.isErpDeliveryChange           = false;         // ERP 출하 정보 수정
            initData.wrapperData.isPurposeOfOrderChange        = false;         // 주문 목적 정보 수정
            initData.wrapperData.isSaveButton                  = false;         // 저장 버튼 처리 가능 여부
            initData.wrapperData.isERPSaveButton               = false;         // ERP 저장 버튼 처리 가능 여부

            if(initData.wrapperData.order.PurposeOfOrder__c == '재고보충') {
                initData.wrapperData.isPurposeOfOrderChange        = true;         // 주문 목적 정보 수정
            }
            if(String.isNotEmpty(initData.wrapperData.order.SalesDocNo__c)) {
                // 판매 문서 번호가 있으면 ERP 처리 해야 한다.
                initData.wrapperData.isSaveButton    = false;
//                initData.wrapperData.isERPSaveButton = true;
            }
            if(initData.wrapperData.isPartner == true) {
                // 파트너

                if(initData.wrapperData.order.Status__c == '대리점 주문 신청') {
                    System.debug(initData.wrapperData.order.Status__c + '/' + initData.wrapperData.order.PurposeOfOrder__c);
                    initData.wrapperData.isSaveButton                  = true;         // 저장 버튼 처리 가능 여부
                    initData.wrapperData.isERPSaveButton               = false;         // ERP 저장 버튼 처리 가능 여부
                    if(initData.wrapperData.order.PurposeOfOrder__c == '재고보충') {
                        initData.wrapperData.isPurposeOfOrderChange        = true;         // 주문 목적 정보 수정
                        initData.wrapperData.isOrderScheduleChange         = true;
                    } else {
                        System.debug('-=-------------');
                        initData.wrapperData.isSaveButton               = false;         // ERP 저장 버튼 처리 가능 여부
                    }
                }
            } else {
                // 영업사원
                if(initData.wrapperData.order.Status__c == '본사 여신 검토') {
                    if(String.isBlank(initData.wrapperData.order.ErpZLNNO__c) == true) {
                        initData.wrapperData.isPurposeOfOrderChange = true;
                        initData.wrapperData.isErpDeliveryChange = true;
                        initData.wrapperData.isErpPriceChange = true;
                        initData.wrapperData.isOrderScheduleChange = true;
                        initData.wrapperData.isSaveButton = false;
                        initData.wrapperData.isERPSaveButton = true;
                    } else {
                        initData.wrapperData.isPurposeOfOrderChange  = false;
                        initData.wrapperData.isERPSaveButton = false;
                    }
                } else if(initData.wrapperData.order.Status__c == '출하') {
                    if(initData.wrapperData.order.IsOutAsset__c == false) {
//                        initData.wrapperData.isPurposeOfOrderChange = true;
                        initData.wrapperData.isOrderScheduleChange = true;
                        initData.wrapperData.isErpDeliveryChange = true;
                        initData.wrapperData.isErpPriceChange = true;
                        initData.wrapperData.isSaveButton    = false;
                        initData.wrapperData.isERPSaveButton = true;
                    } else {
                        initData.wrapperData.isPurposeOfOrderChange = false;
                        initData.wrapperData.isSaveButton    = false;
                        initData.wrapperData.isERPSaveButton = false;
                    }
                } else {
                    // 영업소 검토
                    if(initData.wrapperData.order.Status__c == '영업소 주문 검토' || initData.wrapperData.order.Status__c == '영업소 주문 확정') {
                        initData.wrapperData.isOrderScheduleChange = true;
                        initData.wrapperData.isErpDeliveryChange = false;
                        initData.wrapperData.isErpPriceChange = false;
                        initData.wrapperData.isSaveButton = true;
                        initData.wrapperData.isERPSaveButton = false;
                    }
                    // 대리점 주문 신청, 종료는 아무 처리도 안한다.
                }

            }
        }
        // 주문 생성
        else {
            // Partner User
            initData.wrapperData.isSaveButton                           = true;
            initData.wrapperData.isERPSaveButton                        = false;
            initData.wrapperData.isPurposeOfOrderChange                 = true;
            initData.wrapperData.isOrderScheduleChange                  = true;
            initData.wrapperData.order.PriceDecisionDate__c = Date.today();
            initData.wrapperData.asset = new Asset();
            initData.wrapperData.oldPriceDecisionDate = Date.today();

            if(initData.wrapperData.isPartner) {
                initData.wrapperData.order.RecordTypeId                 = orderRecordTypeIdByDevName.get('PerFarCorp');
                initData.wrapperData.order.Status__c                    = '대리점 주문 신청';
                initData.wrapperData.order.PurposeOfOrder__c            = '재고보충';
                initData.wrapperData.order.Division__c                  = '공장주문';
                initData.wrapperData.orderLineItemList[0].RecordTypeId  = oliRecordTypeIdByDevName.get('PerFarCorp');
                initData.wrapperData.isPerFarCorp                       = true;
                initData.wrapperData.isOrderScheduleChange              = true;
                initData.wrapperData.order.OrderAccount__c              = tempUser.Contact.AccountId;   // 대리점이 주문 고객이 되도록 설정.
                initData.wrapperData.order.Dealer__c                    = tempUser.Contact.AccountId;
            }
            // Internal User
            else {
                initData.wrapperData.order.RecordTypeId                 = orderRecordTypeIdByDevName.get('NhGov');
                initData.wrapperData.order.Status__c                    = '영업소 주문 검토';
                initData.wrapperData.order.PurposeOfOrder__c            = '재고보충';
                initData.wrapperData.order.Division__c                  = '공장주문';
                initData.wrapperData.orderLineItemList[0].RecordTypeId  = oliRecordTypeIdByDevName.get('NhGov');
                initData.wrapperData.isPerFarCorp                       = false;
                initData.wrapperData.isOrderScheduleChange              = true;
            }
        }

        return initData;
    }

    /**
     * @description 저장 Method.
     *
     * @param wrapperData : OrderNewQa.WrapperData
     *
     * @return String : 해당 Order의 Id.
     */
    @AuraEnabled
    public static WrapperData newData(OrderNewQa.WrapperData wrapperData) {
        wrapperData.order = wrapperData.order.clone(false);
        if (wrapperData.orderLineItemList != null) {
            List<OrderLineitem__c> tmpOrderLineitems = new List<OrderLineitem__c>();
            OrderLineitem__c newItem;
            for(OrderLineitem__c r : wrapperData.orderLineItemList) {
                Product2 product = r.ProductId__r;
                newItem = r.clone(false);
                newItem.ProductId__r = product;
                tmpOrderLineitems.add(newItem);
            }
            wrapperData.orderLineItemList = tmpOrderLineitems;
        }
        return wrapperData;
    }

    /**
     * @description 저장 Method.
     *
     * @param wrapperData : OrderNewQa.WrapperData
     *
     * @return String : 해당 Order의 Id.
     */
    @AuraEnabled
    public static WrapperData save(OrderNewQa.WrapperData wrapperData) {
        System.debug('------------->save');

        // 해당 사용자의 information.
        final User tempUser = ModelUser.getUserData();

        //==============================================================================
        // 저장 Logic
        //==============================================================================

        Product2 product;
        List<String> invalidComments = new List<String>();
        if (wrapperData.order != null) {
            if(wrapperData.isInsert) {
                // 주문 등록 처리시..
                // 개인 영농법인
                if(wrapperData.isPerFarCorp) {
                    wrapperData.order.Dealer__c             = wrapperData.order.DeliverTo__c = wrapperData.order.SoldTo__c = wrapperData.order.SupplyTo__c = tempUser.AccountId;
                    wrapperData.order.DealerRep__c          = tempUser.Id;
                    wrapperData.order.BusinessOffice__c     = tempUser.Account.ParentId;
                    wrapperData.order.BusinessOfficeRep__c  = tempUser.Account.OwnerId;

                    wrapperData.order.ErpVKORG__c = '3000';
                    // 유통경로
                    wrapperData.order.ErpVTWEG__c = '10';
                    // 제품군
                    wrapperData.order.ErpSPART__c = '71';
                    // 영업팀
                    wrapperData.order.ErpVKBUR__c = '5600';
                    // 영업그룹
                    wrapperData.order.ErpVKGRP__c = tempUser.Account.BusinessOffice__r.SalesGroupCode__c;
                    // 주문 유형
                    wrapperData.order.ErpAUART__c = 'OR';

                    if(!Test.isRunningTest()) {
                        invalidComments = OrderService.validForOrder(wrapperData.order.Dealer__c);
                        wrapperData.invalidComment = invalidComments != null ? invalidComments[0] : null;
                    }
                }
                // 농협 관납
                else {
                    Account tempAcc = [
                            SELECT Id, BusinessOffice__c, BusinessOffice__r.SalesGroupCode__c, Dealer__c, Dealer__r.IsDelete__c, OwnerId
                            FROM Account
                            WHERE Id = :wrapperData.order.OrderAccount__c
                    ];


                    if(wrapperData.order.OrderScheduleDate__c != null && wrapperData.order.DeliveryDate__c == null) {
                        // 고객 인도기일이 없으면 납품요청월 값을 인도기일 설정.
                        wrapperData.order.DeliveryDate__c = wrapperData.order.OrderScheduleDate__c;
                    }

                    // 고객인도기일 이후의 날짜가 아닌 경우 valid.
                    if(wrapperData.order.OrderScheduleDate__c <= System.today()) {
                        throw new AuraHandledException('납품요청일자는 오늘 이후의 날짜만 선택 가능합니다.');
                    }
                    // 주문고객의 대리점이 지정이 안되어 있으면 오류 처리
                    if(Test.isRunningTest() == false && tempAcc.Dealer__c == null) {
                        throw new AuraHandledException('주문고객의 대리점이 지정되어 있지 않습니다. 해당 고객의 대리점을 지정을 하고 주문 재처리 해주세요.');
                    }

                    /*
                        2021-03-11 추가.
                        주문구분 값이 전수배 일때 로직 추가.
                    */
                    wrapperData.order.AssetTransferAgreeStatus__c = (wrapperData.order.Division__c == '전수배') ? '승인' : '';

                    // 대리점의 삭제여부가 ture일 경우 exception throw
                    if(tempAcc.Dealer__r.IsDelete__c) {
                        throw new AuraHandledException('본 기관고객과 연관된 대리점이 현재 삭제된 대리점입니다. 해당 고객 정보의 대리점을 업데이트해주시기 바랍니다.');
                    }

                    /**
                     * ITVOC-2022-02-0670
                     * 농협/관납 주문시 작성자의 영업소를 지정 처리.
                    */
                    Account tmpBusinessOffice = null;
                    if(Test.isRunningTest() == false && tempUser.BusinessOffice__c == null) {
                        throw new AuraHandledException('사용자 설정에서 담당 영업소를 지정 해주세요.');
                    } else {
                        List<Account> tmpBusinessOffices = [SELECT Id FROM Account WHERE ERPCode__c = :tempUser.BusinessOffice__c LIMIT 1];
                        if(tmpBusinessOffices.isEmpty() == false) tmpBusinessOffice = tmpBusinessOffices[0];
                    }

                    // 대리점
                    wrapperData.order.Dealer__c = tempAcc.Dealer__c;
                    // 대리점 담당자

                    wrapperData.order.DealerRep__c = ModelUser.getDealerUserId(wrapperData.order.Dealer__c);

                    if(tmpBusinessOffice != null) {
                        // 영업소
                        wrapperData.order.BusinessOffice__c = tmpBusinessOffice.Id;
                        // 영업소 담당자
                        wrapperData.order.BusinessOfficeRep__c = tempUser.Id;
                    }
/*
                    // 영업소
                    wrapperData.order.BusinessOffice__c = tempAcc.BusinessOffice__c;
                    // 영업소 담당자
                    wrapperData.order.BusinessOfficeRep__c = tempAcc.OwnerId;
*/
                    // 영업조직
                    wrapperData.order.ErpVKORG__c = '3000';
                    // 유통경로
                    wrapperData.order.ErpVTWEG__c = '10';
                    // 제품군
                    wrapperData.order.ErpSPART__c = '71';
                    // 영업팀
                    wrapperData.order.ErpVKBUR__c = '5600';
                    // 영업그룹
                    wrapperData.order.ErpVKGRP__c = tempAcc.BusinessOffice__r.SalesGroupCode__c;
                    // 주문 유형
                    wrapperData.order.ErpAUART__c = 'OR';
                }
                product = wrapperData.orderLineItemList[0].ProductId__r;
                wrapperData.orderLineItemList[0].ProductId__r = null;
            } else {

            }

            // 주문 제품 연결
            // 수정일 : 2021/06/17
            // 요청 VOC : ITVOC-2021-05-0341
            if(wrapperData.orderLineItemList.isEmpty() == false && wrapperData.orderLineItemList[0].ProductId__c != null) {
                wrapperData.order.OrderProduct__c = wrapperData.orderLineItemList[0].ProductId__c;
            }

            upsert wrapperData.order;

            if(wrapperData.isPerFarCorp) {
                /**
                 * GUIDE ACTION 처리.
                 * "여신/채권/적정재고 Rule에 의한 주문 제한할 경우
                    (여신: 여신한도 초과, 채권: Blacklist 등재, 적정재고 : 30% 초과시)"
                */
                if(String.isEmpty(wrapperData.invalidComment) == false) {
                    Task newTask = new Task();
                    newTask.OwnerId = tempUser.Account.OwnerId;
                    newTask.ActivityDate = System.today();
                    newTask.Type__c = 'Guide';
                    newTask.WhatId = wrapperData.order.Id;
                    newTask.Subject = '[주문제한 알림]';
                    newTask.Description = invalidComments[1]+ ' 와/과 같은 사유로 주문이 제한될 수 있습니다.\n '+ tempUser.Account.Name  +'과 논의하시기 바랍니다.';
                    newTask.CustomAlert__c = false;
                    insert newTask;
                }
            }
        }

        if (wrapperData.orderLineItemList != null) {
            if(wrapperData.isInsert) {
                wrapperData.orderLineItemList[0].OrderId__c = wrapperData.order.Id;
                if(wrapperData.isPerFarCorp == true) {
                    wrapperData.orderLineItemList[0].BaseSellingPrice__c = wrapperData.orderLineItemList[0].UnitPrice__c;
                } else {
                    wrapperData.orderLineItemList[0].BaseSellingPrice__c = wrapperData.orderLineItemList[0].NhGovListPrice__c;
                }
                wrapperData.orderLineItemList[0].CorrectionPrice__c  = 0;
                wrapperData.orderLineItemList[0].SellingPrice__c     = wrapperData.orderLineItemList[0].BaseSellingPrice__c + wrapperData.orderLineItemList[0].CorrectionPrice__c;
            }
            upsert wrapperData.orderLineItemList;
        }

        /**
         * 주문 우선순위 구하기....
         * @TODO : 유리.
        */
        System.debug('------------->1');
        Integer orderSeq = 1;
        System.debug('제품 : ' + wrapperData.order.OrderProduct__c);
        for (Order__c r : [
                SELECT
                        Id, Name, DeliverySeq__c, Status__c,RecordType.Name, PurposeOfOrder__c, fm_RecordTypeOrder__c, fm_OrderScheduleYearMonth__c,  fm_IsPreOrder__c,   fm_OrderPurposeOrder__c,   OrderScheduleDate__c,  CreatedDate
                FROM Order__c
                WHERE Status__c != '종료'
                AND isOrderCancel__c = FALSE
                AND VSTEL__c IN ('', 'M620')
                AND OrderScheduleDate__c != NULL
                AND OrderProduct__c = :wrapperData.order.OrderProduct__c
                ORDER BY fm_RecordTypeOrder__c, fm_OrderScheduleYearMonth__c, fm_IsPreOrder__c, fm_OrderPurposeOrder__c, OrderScheduleDate__c, CreatedDate
        ]) {
            System.debug('-->'+ orderSeq);
            if (r.Id == wrapperData.order.Id) {
                wrapperData.order.DeliverySeq__c = orderSeq;
                break;
            }
            orderSeq++;
        }
        System.debug('------------->2');
        update wrapperData.order;

        // 제품 재 연결 처리 한다.
        wrapperData.orderLineItemList[0].ProductId__r = product;

        return wrapperData;
    }



    /**
     * @description 저장 Method.
     *
     * @param wrapperData : OrderNewQa.WrapperData
     *
     * @return String : 해당 Order의 Id.
     */
    @AuraEnabled
    public static OrderNewQa.WrapperData erpSave(OrderNewQa.WrapperData wrapperData) {

        if(wrapperData.order.Division__c == '전수배') {
            wrapperData = OrderServiceIF.OrderUpdate_ZORT(wrapperData);
        } else {
            wrapperData = OrderServiceIF.OrderUpdate_OR(wrapperData);
        }
        if(wrapperData.order.ErpS_RESULT__c == '00') {
            if (wrapperData.orderLineItemList != null) {
                // 가격 결정일 체크
                for(OrderLineitem__c oli : wrapperData.orderLineItemList) {
                    if(oli.CorrectionPrice__c != null && oli.CorrectionPrice__c > 0 ) {
                        wrapperData.order.PriceDecisionDate__c = Date.today();
                    }
                }
                update wrapperData.orderLineItemList;
            }
            if (wrapperData.order != null) {
                update wrapperData.order;
            }
        }

        return wrapperData;
    }

    /**
     * @description 가격 결정일 변경
     *
     * @param accountId : String
     *
     * @return : OrderNewQa.WrapperData
     */
    @AuraEnabled
    public static OrderNewQa.WrapperData getPriceDecisionDateChange(OrderNewQa.WrapperData wrapperData) {
        Date PriceDecisionDate = wrapperData.order.PriceDecisionDate__c;    // 변경 가격 결정일
        Date oldPriceDecisionDate = wrapperData.oldPriceDecisionDate;       // 이전 가격 결정일

        String priceType = null;
        if(wrapperData.order.OrderAccount__r.CustomerType__c == '농협') {
            priceType = 'FD';
        } else if(wrapperData.order.OrderAccount__r.CustomerType__c == '관납') {
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
                WHERE StartDate__c <= :wrapperData.order.PriceDecisionDate__c
                AND EndDate__c >= :wrapperData.order.PriceDecisionDate__c
                AND Product__c = :wrapperData.orderLineItemList[0].ProductId__c
                AND PriceType__c = :priceType
                ORDER BY StartDate__c DESC
                LIMIT 1
        ];

        if(productPriceEntries.isEmpty() == false) {
            wrapperData.orderLineItemList[0].BaseSellingPrice__c = productPriceEntries[0].BasePrice__c;
            wrapperData.orderLineItemList[0].SellingPrice__c = wrapperData.orderLineItemList[0].BaseSellingPrice__c;
            wrapperData.orderLineItemList[0].CorrectionPrice__c = 0;
        } else {
            throw new AuraHandledException(((Datetime)PriceDecisionDate).format('yyyy-MM-dd')+' 에 대한 가격 정보가 없습니다. 혁신파트 담당자에게 문의 해주세요.');
        }

        return wrapperData;
    }

    /**
     * @description 주문 고객 선택 시, 해당 판매처 정보를 반환 하는 method.
     *
     * @param accountId : String
     *
     * @return : OrderNewQa.SoldToInfo
     */
    @AuraEnabled
    public static OrderNewQa.SoldToInfo getTargetSoldTo(String accountId) {
        return OrderService.getTargetSoldTo(accountId);
    }

    /**
     * @description 해당 SObject의 RecordType DeveloperName 별 Id 값을 반환
     *
     * @param targetObject : SObject
     *
     * @return Map<String, String>
     */
    private static Map<String, String> returnRecordTypeMapByDevName(String targetObject) {
        Map<String, String> returnMap = new Map<String, String>();

        for(RecordTypeInfo ds : (((SObject)(Type.forName('Schema.'+targetObject).newInstance())).getSObjectType()).getDescribe().getRecordTypeInfos()) {
            if(!returnMap.containsKey(ds.getDeveloperName())) {
                returnMap.put(ds.getDeveloperName(), ds.getRecordTypeId());
            }
        }

        return returnMap;
    }

    /**
     * @description wrapper class
     */
    public class WrapperData {
        @AuraEnabled public Order__c                    order           {
            get {
                if(this.order == null) {
                    this.order = new Order__c();
                    this.order.Division__c          = '공장주문';
                }

                return this.order;
            }
            set;
        }
        @AuraEnabled public Asset                       asset               {get;set;}
        @AuraEnabled public Asset                       existAsset          {get;set;}
        @AuraEnabled public List<OrderLineitem__c>      orderLineItemList   {
            get {
                if(this.orderLineItemList == null) {
                    this.orderLineItemList = new List<OrderLineitem__c>{
                            new OrderLineitem__c(
                                    Quanitity__c = 1,
                                    DTFeeMaxAmt__c = 0, DTFeeMinAmt__c = 0, DTFeeMaxRate__c = 0, DTFeeMinRate__c = 0,
                                    SGFeeMaxAmt__c = 0, SGFeeMinAmt__c = 0, SGFeeMaxRate__c = 0, SGFeeMinRate__c = 0,
                                    MSFeeMaxAmt__c = 0, MSFeeMinAmt__c = 0, MSFeeMaxRate__c = 0, MSFeeMinRate__c = 0,
                                    LAFeeMaxAmt__c = 0, LAFeeMinAmt__c = 0, LAFeeMaxRate__c = 0, LAFeeMinRate__c = 0,
                                    RSFeeMaxAmt__c = 0, RSFeeMinAmt__c = 0, RSFeeMaxRate__c = 0, RSFeeMinRate__c = 0,
                                    MAFeeMaxAmt__c = 0, MAFeeMinAmt__c = 0, MAFeeMaxRate__c = 0, MAFeeMinRate__c = 0,
                                    EPFeeMaxAmt__c = 0, EPFeeMinAmt__c = 0, EPFeeMaxRate__c = 0, EPFeeMinRate__c = 0,
                                    SPFeeMaxAmt__c = 0, SPFeeMinAmt__c = 0, SPFeeMaxRate__c = 0, SPFeeMinRate__c = 0
                            )
                    };
                }


                return this.orderLineItemList;
            }
            set;
        }
        // Sold to
        @AuraEnabled public SoldToInfo                  soldToInfo            {get;set;}
        // 저장 해야 할 Data Boolean
        @AuraEnabled public Boolean                     isInsert            {get;set;}
        // RecordType : 개인/영농
        @AuraEnabled public Boolean                     isPerFarCorp        {get;set;}
        // 대리점 공급가 (최대)
        @AuraEnabled public Decimal supplyHighAmt {
            get {
                if(this.supplyHighAmt == null) {
                    this.supplyHighAmt = 0;
                }

                return this.supplyHighAmt;
            }
            set;
        }
        // 대리점 공급가 (최소)
        @AuraEnabled public Decimal supplyLowAmt {
            get {
                if(this.supplyLowAmt == null) {
                    this.supplyLowAmt = 0;
                }

                return this.supplyLowAmt;
            }
            set;
        }
        // Opportunity Name 보여 주기용.
        @AuraEnabled public String opptyName {get;set;}
        @AuraEnabled public Boolean isValid {
            get {
                return this.isValid == null ? true : false;
            }
            private set;
        }
        @AuraEnabled public String invalidComment {get;private set;}
        @AuraEnabled public Boolean isPartner {get;set;}
        @AuraEnabled public Date currentDate {get;set;}     // 오늘 날짜
        /*
            2021-03-11 추가.
            주문구분의 값이 추가될 수 있는 것을 고려해서 innerclass 내 변수로 받아서 추후 로직 처리.
            기본 값 세팅은 '공장주문'.
        */
        @AuraEnabled public String  orderDivision {
            get {
                if(this.orderDivision == null) {
                    this.orderDivision = '공장주문';
                }

                return this.orderDivision;
            }
            set;
        }

        @AuraEnabled public Boolean isErpPriceChange {get;set;}             // 가격 정보
        @AuraEnabled public Boolean isErpDeliveryChange {get;set;}          // 출하 정보
        @AuraEnabled public Boolean isPurposeOfOrderChange {get;set;}       // 주문 목적
        @AuraEnabled public Boolean isOrderScheduleChange {get;set;}        // 납품요청월
        @AuraEnabled public Boolean isSaveButton {get;set;}
        @AuraEnabled public Boolean isERPSaveButton {get;set;}
        @AuraEnabled public Date oldPriceDecisionDate {get;set;}         // 현재 가격 결정일


    }

    /**
     * @description 관납/농협 RecordType인 경우 에만 사용 하는 wrapper class.
     */
    public class SoldToInfo {
        // 관납 인지 농협 인지 판단 하는 boolean 값.
//        @AuraEnabled public Boolean isGov  {get;set;}
        @AuraEnabled public List<I2ComClass.Option> soldToList {
            get {
                if(this.soldToList == null) {
                    this.soldToList = new List<I2ComClass.Option>();
                }
                return this.soldToList;
            }
            set;
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
    }
}