/****************************************************************************************
  * @filename      : LsMSalesCustomerConsult
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-06-05
  * @group         : 
  * @group-content : 
  * @description   : [모바일]고객상담
  * @tester        : LsMSalesCustomerConsult_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-05         i2max          Create
    0.2     2020-06-30         i2max          Account 조회 문제발생으로 without 변경
****************************************************************************************/
public without sharing class LsMSalesCustomerConsult {

    // 현재날짜시간
    private static Datetime dt = Datetime.now();
    // 현재날짜
    private static Date d = dt.date();
    // Account 레코드 Id : 개인고객
    private static Id personAccountRecordTypeId {get;set;}
    // Account recordTypeId 별 recordType info
    private static Map<String, RecordType> accountRecordTypeMapById {
        get {
            if(accountRecordTypeMapById == null) {
                accountRecordTypeMapById = new Map<String, RecordType>();
            }

            return accountRecordTypeMapById;
        }
        set;
    }
    // Opportunity 레코드 Id : 개인/농업법인
    private static Id perFarCorpOpportunityRecordTypeId {get;set;}
    // 로그인 정보
    private static User loginUser {get;set;}

    static {
        personAccountRecordTypeId = I2ComUtil.getRecordType('Account', 'PersonAccount');
        perFarCorpOpportunityRecordTypeId = I2ComUtil.getRecordType('Opportunity', 'PerFarCorp');
        loginUser = ModelUser.getUserData();

        for(RecordType rt : [SELECT Id, DeveloperName
                             FROM RecordType
                             WHERE SobjectType = 'Account']
        ) {
            accountRecordTypeMapById.put(rt.Id, rt);
        }
    }

    /**
     * [모바일-step업무] 샘플
     * 리턴은 LsMSalesStepVO 타입으로 리턴할 것
     *
     * @return LsMSalesStepVO
     */
    @AuraEnabled
    public static LsMSalesStepVO init() {
        LsMSalesCustomerConsultVO lsMSalesCustomerConsultVO = new LsMSalesCustomerConsultVO();
        //============================================================================
        // 필요에 따라서는 초기화 함.
        //============================================================================
        // 1. 업무처리용
        lsMSalesCustomerConsultVO.bizData = new LsMSalesCustomerConsultVO.BizData();
        lsMSalesCustomerConsultVO.bizData.guidedSellingType = 'C';
        lsMSalesCustomerConsultVO.bizData.prodSerRecStd = new ProdSerRecStd__c();
        lsMSalesCustomerConsultVO.bizData.productSeriesVO = new LsMSalesProductSeriesVO();
        lsMSalesCustomerConsultVO.bizData.productVO = new LsMSalesProductVO();
        lsMSalesCustomerConsultVO.bizData.customerVO = new LsMSalesCustomerVO();

        //============================================================================
        // 원래는 고객카드시 init으로 초기화 한 로직을 데이터 유지를 위해 초기에 세팅을 하고
        // 계속 데이터를 유지한다.
        //============================================================================
//        lsMSalesCustomerConsultVO.bizData.customerVO.customer = getNewPersonAccount();
//        lsMSalesCustomerConsultVO.bizData.customerVO.cupi = getNewCUPI();
        //================================================================================================================
        // 2021-03-17 수정
        // 초기 세팅은 개인고객
        //================================================================================================================

        lsMSalesCustomerConsultVO.bizData.customerVO.customer = getNewAccountByRecordType(accountRecordTypeMapById.get(personAccountRecordTypeId));
        lsMSalesCustomerConsultVO.bizData.customerVO.cupi = getNewCUPI();
        lsMSalesCustomerConsultVO.bizData.customerVO.isPersonAccount = (accountRecordTypeMapById.get(personAccountRecordTypeId).DeveloperName == 'PersonAccount');
        lsMSalesCustomerConsultVO.bizData.isAuthenticated = false;

        // 2. 참조용
        lsMSalesCustomerConsultVO.infoData = new LsMSalesCustomerConsultVO.InfoData();
        lsMSalesCustomerConsultVO.infoData.searchProductSeries = new ProductSeries__c();

        // 2021-03-16 추가
        // 3. combobox용
        lsMSalesCustomerConsultVO.infoData.accountRecordTypeList = new List<I2ComClass.Option>();
        lsMSalesCustomerConsultVO.infoData.accountCustomerTypeList = new List<I2ComClass.Option>();

        for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE DeveloperName IN ('PersonAccount', 'CorporationAccount')]) {
            lsMSalesCustomerConsultVO.infoData.accountRecordTypeList.add(new I2ComClass.Option(rt.Name, rt.Id));
        }

        return (LsMSalesStepVO)lsMSalesCustomerConsultVO;
    }

    /**
     * 고객카드 데이터 클래스
     */
    public class CustomerCardData {
        @AuraEnabled public Account newPersonAccount {get;set;}
        @AuraEnabled public CUPI__c newCUPI {get;set;}

        public CustomerCardData(Account newPersonAccount, CUPI__c newCUPI) {
            this.newPersonAccount = newPersonAccount;
            this.newCUPI = newCUPI;
        }
    }

    /**
     * 신규 고객카드 데이터 구함
     *
     * 사용하는 곳 없음
     *
     * @return CustomerCardData
     */
    @AuraEnabled
    public static CustomerCardData getNewCustomerCardData() {
        return new CustomerCardData(getNewPersonAccount(), getNewCUPI());
    }

    /**
     * 신규 개인고객
     * @return Account
     */
    private static Account getNewPersonAccount() {
        return new Account(
            // 개인고객 레코드타입
            RecordTypeId = personAccountRecordTypeId,
            // 대리점
            Dealer__c = loginUser.AccountId,
            // 개인정보활용동의 최초 동의일
            CUPIInitialStartDate__pc = d,
            // 개인정보활용동의여부
            IsCUPI__pc = true,
            // 로그인 사용자의 영업소
            BusinessOffice__c = ModelUser.getUserData().Account.BusinessOffice__c

        );
    }

    /**
     * 신규 개인정보
     * @return CUPI__c
     */
    private static CUPI__c getNewCUPI() {
        return new CUPI__c(
                OwnerId = loginUser.Id
        );
    }

    /**
     * 영농정보
     * [유의] 초기값으로 영농형태 리스트만 존재하지만 기본 틀은 유지함.
     */
    public class FarmInfo {
        @AuraEnabled public List<I2ComClass.Option> farmingForm {get;set;}

        public FarmInfo(
            final List<I2ComClass.Option> farmingForm
        ) {
            this.farmingForm = farmingForm;
        }
    }

    /**
     * 영농정보
     * @return FarmInfo
     * @deprecated
     */
//    @AuraEnabled(Cacheable=true)
//    public static FarmInfo getFarmingInfo() {
//        return new FarmInfo(
//            I2ComUtil.makePickListOptions('ProdSerRecStd__c', 'FarmingForm__c', true)
//        );
//    }

    @AuraEnabled(Cacheable=true)
    public static FarmInfo getFarmingInfo(final String customerType) {
        return new FarmInfo(
            I2ComDependencyUtil.getDependentPickListOptions('Account', 'CustomerType__c', 'FarmingForm__c', customerType, true, false)
        );
    }

    /**
     * 영농형태에 따른 영농규모 구함
     *
     * @param farmingForm 영농형태
     *
     * @return List<I2ComClass.Option>
     */
    @AuraEnabled(Cacheable=true)
    public static List<I2ComClass.Option> getFarmingSizeOptions(final String farmingForm) {

        System.debug(System.LoggingLevel.INFO, 'farmingForm :' + farmingForm);

        return I2ComDependencyUtil.getDependentPickListOptions('ProdSerRecStd__c', 'FarmingForm__c', 'FarmingSize__c', farmingForm, true, false);
    }

    /**
     * 영농정보에 해당하는 제품시리즈 VO 리스트를 구함
     *
     * @param reqData : 영농정보
     *
     * @return List<LsMSalesProductSeriesVO>
     */
    @AuraEnabled
    public static List<LsMSalesProductSeriesVO> getProductSeriesVOS(String reqData) {

        System.debug(System.LoggingLevel.INFO, 'reqData :' + reqData);

        Map<String, String> paramMap = I2ComHelper.gfnCheckCondition(reqData);

        String farmingForm = (String)paramMap.get('farmingForm');
        String farmingSize = (String)paramMap.get('farmingSize');

        return LsMSalesProductService.getProductSeriesVOS(farmingForm, farmingSize);
    }

    /**
     * 제품시리즈를 통한 단 하나의 제품 구함
     *
     * @deprecated : 단일제품이 아닌 제품리스트 조회로 삭제
     * @param searchProductSeries 조회용 제품시리즈
     *
     * @return Product2
     */
    @AuraEnabled
    public static Product2 getProduct(final ProductSeries__c searchProductSeries) {
        System.debug(System.LoggingLevel.INFO, 'searchProductSeries :' + searchProductSeries);
        return LsMSalesProductService.getProduct(searchProductSeries);
    }

    /**
     * 해달 시리즈의 제품리스트
     *
     * @param searchProductSeries 조회용 제품시리즈
     *
     * @return List<Product2>
     */
    @AuraEnabled
    public static List<Product2> getProducts(final ProductSeries__c searchProductSeries) {
        System.debug(System.LoggingLevel.INFO, 'searchProductSeries :' + searchProductSeries);
        return LsMSalesProductService.getProducts(searchProductSeries);
    }

    /**
     * 제품 VO 구함 : 제품
     * carousel 용의 제품 컨텐츠를 구함
     *
     * @param product 제품
     *
     * @return LsMSalesProductVO
     */
    @AuraEnabled
    public static LsMSalesProductVO getProductVO(final Product2 product) {
        System.debug(System.LoggingLevel.INFO, product);
        return LsMSalesProductService.getProductVO(product, LsMSalesProductService.carouselContentsTypeList);
    }

    /**
     * 고객 카드 init 시, 필요한 기본 정보 세팅을 위한 inner class return
     *
     * @param farmInfo : String
     *
     * @return LsMSalesCustomerConsult.DefaultCustomerConsultData
     */
    @AuraEnabled
    public static LsMSalesCustomerConsult.DefaultCustomerConsultData getDefaultData(final String customerType, final String farmInfo, final String guidedSellingType) {
        LsMSalesCustomerConsult.DefaultCustomerConsultData defaultCustomerConsultData = new LsMSalesCustomerConsult.DefaultCustomerConsultData();

        List<String> dateList = new List<String>();

        for(Integer i = 0; i < 7; i++) {
            if(i == 0) {
                dateList.add(String.valueOf(d.addMonths(i + 1).toStartOfMonth().addDays(-1)));
            } else {
                dateList.add(String.valueOf(d.addMonths(i).toStartOfMonth()));
            }
        }

        for(String s : dateList) {
            defaultCustomerConsultData.closeDateList.add(new I2ComClass.Option(s.replaceAll('-', '.').left(7), s));
        }

//        defaultCustomerConsultData.farmFormList = I2ComUtil.makePickListOptions('ProdSerRecStd__c', 'FarmingForm__c', true);
//        defaultCustomerConsultData.farmAreaList = LsMSalesCustomerConsult.getFarmingSizeOptions(farmInfo);

        if(guidedSellingType == 'A') {
            for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE DeveloperName IN ('PersonAccount', 'CorporationAccount')]) {
                defaultCustomerConsultData.accountRecordTypeList.add(new I2ComClass.Option(rt.Name, rt.Id));
            }
        }

        defaultCustomerConsultData.farmFormList = I2ComDependencyUtil.getDependentPickListOptions('Account', 'CustomerType__c', 'FarmingForm__c', customerType, true, false);
        defaultCustomerConsultData.farmAreaList = LsMSalesCustomerConsult.getFarmingSizeOptions(farmInfo);


        return defaultCustomerConsultData;

    }

    // 2021-03-16 추가
    /**
     * 고객의 RecordType에 맞는 고객 유형 List return
     *
     * @param recordTypeId : String
     *
     * @return List<I2ComClass.Option>
     */
//    @AuraEnabled
//    public static List<I2ComClass.Option> getCustomerTypeList(final String recordTypeId) {
//        List<I2ComClass.Option> customerTypeList = new List<I2ComClass.Option>();
//        Map<String, List<String>> customerTypeByRecordTypeId = new Map<String, List<String>>();
//
//        // hard coding
//        // TODO : 2021-03-16    metadata 이용 동적 처리 필요
//        customerTypeByRecordTypeId.put(personAccountRecordTypeId, new List<String>{'자영농', '영업농'});
//        customerTypeByRecordTypeId.put(I2ComUtil.getRecordType('Account', 'CorporationAccount'), new List<String>{'농업법인', '기타법인'});
//
//        for(String s : customerTypeByRecordTypeId.get(recordTypeId)) {
//            customerTypeList.add(new I2ComClass.Option(s, s));
//        }
//
//        return customerTypeList;
//    }

    /**
     * 고객의 RecordType에 맞는 고객 유형 List return
     *
     * @param recordTypeId : String
     *
     * @return List<I2ComClass.Option>
     */
    @AuraEnabled
    public static LsMSalesCustomerConsult.CustomerClassForSettingByRecordType getCustomerDataByRecordType(final String recordTypeId) {
        CustomerClassForSettingByRecordType customerClassForSettingByRecordType = new CustomerClassForSettingByRecordType();
        Map<String, List<String>> customerTypeByRecordTypeId = new Map<String, List<String>>();

        customerClassForSettingByRecordType.newAccount = getNewAccountByRecordType(accountRecordTypeMapById.get(recordTypeId));
        customerClassForSettingByRecordType.isPersonAccount = (accountRecordTypeMapById.get(recordTypeId).DeveloperName == 'PersonAccount');
//        customerClassForSettingByRecordType.newCupi = getNewCUPI();

        // hard coding
        // TODO : 2021-03-16    metadata 이용 동적 처리 필요
        customerTypeByRecordTypeId.put(personAccountRecordTypeId, new List<String>{'자영농', '영업농'});
        customerTypeByRecordTypeId.put(I2ComUtil.getRecordType('Account', 'CorporationAccount'), new List<String>{'농업법인', '기타법인'});

        for(String s : customerTypeByRecordTypeId.get(recordTypeId)) {
            customerClassForSettingByRecordType.customerTypeList.add(new I2ComClass.Option(s, s));
        }

        return customerClassForSettingByRecordType;
    }

    /**
     *
     * 기존에 하나였던 recordtype의 추가와 그에 따른 로직 변화로
     * recordType 별 account 생성 관리를 하나의 method에서 처리함
     *
     * @date  2021-03-17
     * @param accountRecordType
     *
     * @return
     */
    private static Account getNewAccountByRecordType(RecordType accountRecordType) {
        Account newAccount = new Account(
                RecordTypeId = accountRecordType.Id,
                Dealer__c = loginUser.AccountId,
                BusinessOffice__c = ModelUser.getUserData().Account.BusinessOffice__c
        );

        //================================================================================================================
        // RecordType의 추가에 따른 로직 처리를 위한 switch
        //================================================================================================================
        switch on accountRecordType.DeveloperName {
            // 개인고객
            when 'PersonAccount' {
                // 개인정보활용동의 최초 동의일
                newAccount.CUPIInitialStartDate__pc = d;
                // 개인정보활용동의여부
                newAccount.IsCUPI__pc = true;
                newAccount.IsPhoneCheck__pc = false;
            }
        }

        return newAccount;
    }

    public class CustomerClassForSettingByRecordType {
        @AuraEnabled public List<I2ComClass.Option> customerTypeList {
            get {
                if(this.customerTypeList == null) {
                    this.customerTypeList = new List<I2ComClass.Option>();
                }

                return this.customerTypeList;
            }
            set;
        }
        @AuraEnabled public Account newAccount {get;set;}
        @AuraEnabled public CUPI__c newCupi {get;set;}
        @AuraEnabled public Boolean isPersonAccount {get;set;}
    }

    // ??
    private static List<I2ComClass.Option> getFarmOptions(final String customerType) {
        return I2ComDependencyUtil.getDependentPickListOptions('Account', 'CustomerType__c', 'FarmingForm__c', customerType, true, false);
    }

    /**
     * 최종선택된 고객상담 내용 저장
     * 1. 고객 upsert
     * 2. 기회 생성
     *
     * @param bizData 고객상담 VO 의 bizData
     *
     * @return Opportunity
     */
    @AuraEnabled
    public static Opportunity consultSave(LsMSalesCustomerConsultVO.BizData bizData) {
        System.debug(System.LoggingLevel.INFO, 'bizData :' + bizData);

        // 대상이 되는 Account
        Account account = bizData.customerVO.customer;
        // B2B일 때 대상이 되는 Contact
        Contact contact = bizData.customerVO.customerContact;

        CUPI__c cupi = bizData.customerVO?.cupi;
        Product2 product = bizData.productVO.product;
        ProdSerRecStd__c prdSerRecStd = bizData.prodSerRecStd;
        // 개인 고객 여부
        Boolean isPersonAccount = bizData.customerVO.isPersonAccount;
        List<Account> accounts;

        final String guideSellingType = bizData.guidedSellingType;

        // 1. 고객조회가 아닌 입력을 통해 들어온 경우
        if(account.Id == null) {
            //============================================================================
            // Account의 PersonDuplicateCheck 필드가 fmt로 구성되어 있음.
            // 해당 필드의 로직이 변경시 여기도 변경이 되어야 한다.
            //============================================================================
            // 개인고객일 경우 duplicate check
            if(isPersonAccount) {
                final String personDuplicateCheck = String.join(new List<String>{
                        account.LastName,
                        String.join(account.PersonMobilePhone.split('-'), ''),
                        account.Dealer__c
                }, '/');

                // 중복 고객 조회
                accounts = [
                        SELECT Id, fm_PersonDuplicateCheck__c, IsCUPI__pc, LastName, PersonMobilePhone,
                                FarmingForm__c, FarmingArea__c, Dealer__c
                        FROM Account
                        WHERE fm_PersonDuplicateCheck__c = :personDuplicateCheck
                        AND IsDelete__c = FALSE
                ];
            } else {
                // 법인고객일 경우 duplicate check
                final String corporationDuplicateCheck = String.join(new List<String>{
                        account.Name,
                        String.join(account.Phone.split('-'), ''),
                        account.Dealer__c
                }, '/');

                // 중복 고객 조회
                accounts = [
                        SELECT Id, fm_CorporationDuplicateCheck__c, Name, PersonMobilePhone,
                                FarmingForm__c, FarmingArea__c, Dealer__c
                        FROM Account
                        WHERE fm_CorporationDuplicateCheck__c = :corporationDuplicateCheck
                        AND IsDelete__c = FALSE
                ];
            }

            if(accounts.isEmpty()) {
                account.FarmingForm__c              = (prdSerRecStd != null) ? prdSerRecStd.FarmingForm__c : null;
                account.FarmingArea__c              = (prdSerRecStd != null) ? prdSerRecStd.FarmingSize__c : null;
                account.InterestModel__c            = product.Id;
                account.Dealer__c                   = loginUser.AccountId; // 대리점
                account.BusinessOffice__c           = loginUser.Account.BusinessOffice__c;
                account.BusinessOfficeName__c       = loginUser.Account.BusinessOfficeName__c;

                if(isPersonAccount) {
                    account.IsCUPI__pc                  = true; // 개인정보활용동의여부
                    account.CUPIInitialStartDate__pc    = d;    // 개인정보최초동의일
                    account.IsPhoneCheck__pc            = true; // 전화번호 인증

                    cupi.ConsentType__c = '신규';
                }
            }
            else {
                account = accounts[0];
                if(isPersonAccount) {
                    account.CUPIInitialStartDate__pc = d; // 개인정보최초동의일

                    cupi.ConsentType__c = '재동의';
                }
            }
        }
        else {
            if(isPersonAccount) {
                // Name은 업데이트가 안되기에 별도 new 해서 다시 세팅함.
                account = new Account(
                        Id = account.Id,
                        PersonMobilePhone = account.PersonMobilePhone,
                        IsCUPI__pc = true,
                        LastName = account.LastName,
                        CustomerType__c = account.CustomerType__c,
                        IsPhoneCheck__pc = true
                );

                cupi.ConsentType__c = '재동의';
            }
        }

        System.debug(System.LoggingLevel.INFO, 'account :' + account);

        // 동일 수행
        account.InterestModel__c = product.Id;
        // 기존 고객이 제품 시리즈 추천으로 들어올 경우, farimng 정보를 가지고 올 경우에만 세팅
        if(account.Id != null && prdSerRecStd != null && String.isNotBlank(prdSerRecStd.FarmingForm__c) && String.isNotBlank(prdSerRecStd.FarmingSize__c)) {
            account.FarmingForm__c = prdSerRecStd.FarmingForm__c;
            account.FarmingArea__c = prdSerRecStd.FarmingSize__c;
        }

        upsert account;

        // B2B일 경우에만 처리하는 연락처 로직
        if(contact != null) {
            contact.AccountId = account.Id;
            contact.IsRepresentative__c = true;

            cupi.ConsentType__c = (contact.Id == null) ? '신규' : ' 재동의';

            upsert contact;
        }

        // 개인정보동의 레코드 공통 세팅.
        cupi.IsCUPIThirdParty__c = true;
        cupi.Dealer__c = loginUser.AccountId;
        cupi.ConsentDate__c = d;
        cupi.NextConsentScheduledDate__c = d.addYears(2);

        // 개인고객일 경우에만 처리 하는 로직.
        if(isPersonAccount) {
            // 2. 개인정보 동의 레코드 생성
            cupi.ConsentedAccount__c = account.Id;
            cupi.PromotionFK__c = account.LastName + '|' + account.PersonMobilePhone.replaceAll('-', '') + '|' + loginUser.AccountId;

            insert cupi;

            // 최종 개인정보 동의 정보를 Account에 업데이트 처리 한다.
            account.CUPI__pc = cupi.Id;

            update account;
        } else {
            // B2B일 경우에만 처리 하는 로직
            // 개인정보 동의 레코드 생성
            cupi.ConsentedContact__c = contact.Id;
            cupi.PromotionFK__c = contact.LastName + '|' + contact.Phone.replaceAll('-', '') + '|' + loginUser.AccountId;

            insert cupi;

            // 최종 개인정보 동의 정보를 Account에 업데이트 처리 한다.
            contact.CUPI__c = cupi.Id;
            contact.IsPhoneCheck__c = true;     // 전화번호 인증.
            if(!contact.IsCUPI__c) contact.IsCUPI__c = true;
            if(contact.CUPIInitialStartDate__c == null) contact.CUPIInitialStartDate__c = d;

            update contact;
        }



        //================================================================================================================
        // Opportunity insert
        //================================================================================================================
        if(String.isBlank(bizData.strCloseDate)) {
            if(!Test.isRunningTest())    throw new AuraHandledException('희망구매월을 입력하세요.');
        }

        // 3. 기회생성
        Opportunity opportunity = new Opportunity(
            Name = String.join(new List<String>{product.Name, dt.addDays(30).format('yyyyMMdd')}, '-'),
            AccountId = account.Id,
            InterestModel__c = product.Id,
            CloseDate = Date.valueOf(bizData.strCloseDate),
            RecordTypeId = perFarCorpOpportunityRecordTypeId,
            StageName = '상담',
            SystemStatus__c = '상담',
            isGuidedSelling__c = true,
            Dealer__c = loginUser.AccountId,
            BusinessOffice__c = loginUser.Account.BusinessOffice__c
        );

        insert opportunity;
/*
        // SalesIQ 점수 등록
        try {
            SalesIQService.setOpportunitySalesIQ(new Set<String>{opportunity.Id}, 'IQ-0001');
        } catch (Exception e) {
            // none ;
        }
*/

        return opportunity;
    }

    /**
     * 고객 카드에서 필요한 정보 세팅 하기 위한 inner class
     */
    public class DefaultCustomerConsultData {

        @AuraEnabled
        public List<I2ComClass.Option> closeDateList {
            get {
                if(this.closeDateList == null) {
                    this.closeDateList = new List<I2ComClass.Option>();
                }

                return this.closeDateList;
            }
            private set;
        }

        @AuraEnabled
        public List<I2ComClass.Option> accountRecordTypeList {
            get {
                if(this.accountRecordTypeList == null) {
                    this.accountRecordTypeList = new List<I2ComClass.Option>();
                }

                return this.accountRecordTypeList;
            }
            private set;
        }

        @AuraEnabled
        public List<I2ComClass.Option> farmFormList {
            get {
                if(this.farmFormList == null) {
                    this.farmFormList = new List<I2ComClass.Option>();
                }

                return this.farmFormList;
            }
            private set;
        }

        @AuraEnabled
        public List<I2ComClass.Option> farmAreaList {
            get {
                if(this.farmAreaList == null) {
                    this.farmAreaList = new List<I2ComClass.Option>();
                }

                return this.farmAreaList;
            }
            private set;
        }
    }

    // 확인중
    @AuraEnabled
    public static LsMSalesCustomerConsult.CustomerDataClass getCustomerDataForGuidedSellingType(String accountId) {
        Map<String, List<String>> customerTypeByRecordTypeId = new Map<String, List<String>>();
        Account tempCustomer;

        customerTypeByRecordTypeId.put(I2ComUtil.getRecordType('Account', 'PersonAccount'), new List<String>{'자영농', '영업농'});
        customerTypeByRecordTypeId.put(I2ComUtil.getRecordType('Account', 'CorporationAccount'), new List<String>{'농업법인', '기타법인'});


        LsMSalesCustomerConsult.CustomerDataClass customerDataClass = new LsMSalesCustomerConsult.CustomerDataClass();

        tempCustomer = [
                SELECT Id, Name, LastName, FarmingArea__c, FarmingForm__c, Phone, PersonMobilePhone, CustomerType__c,
                        RecordTypeId
                FROM Account
                WHERE Id = :accountId
        ];

        // 고객 setting
        customerDataClass.customer = tempCustomer;

        // 고객유형 option setting
        for(String s : customerTypeByRecordTypeId.get(tempCustomer.RecordTypeId)) {
            customerDataClass.customerTypeList.add(new I2ComClass.Option(s, s));
        }

        customerDataClass.farmFormList = testMethod1(tempCustomer.CustomerType__c);
        customerDataClass.farmAreaList = testMethod2(tempCustomer.FarmingForm__c);

        return customerDataClass;
    }

    private static List<I2ComClass.Option> testMethod1(String customerType) {
        return I2ComDependencyUtil.getDependentPickListOptions('Account', 'CustomerType__c', 'FarmingForm__c', customerType, true, false);
    }

    private static List<I2ComClass.Option> testMethod2(String farmForm) {
        return I2ComDependencyUtil.getDependentPickListOptions('Account', 'FarmingForm__c', 'FarmingArea__c', farmForm, true, false);
    }

    public class CustomerDataClass {
        @AuraEnabled public Account customer {get;set;}
        @AuraEnabled public List<I2ComClass.Option> customerTypeList {
            get {
                if(this.customerTypeList == null) {
                    this.customerTypeList = new List<I2ComClass.Option>();
                }

                return this.customerTypeList;
            }
            set;
        }
        @AuraEnabled public List<I2ComClass.Option> farmFormList {
            get {
                if(this.farmFormList == null) {
                    this.farmFormList = new List<I2ComClass.Option>();
                }

                return this.farmFormList;
            }
            set;
        }
        @AuraEnabled public List<I2ComClass.Option> farmAreaList {
            get {
                if(this.farmAreaList == null) {
                    this.farmAreaList = new List<I2ComClass.Option>();
                }

                return this.farmAreaList;
            }
            set;
        }
    }
}