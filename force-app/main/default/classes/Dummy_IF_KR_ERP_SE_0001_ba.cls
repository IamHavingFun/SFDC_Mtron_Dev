/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0001_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-17
  * @group         : 
  * @group-content : 
  * @description   : [고객정보]
  *                : IF_KR_ERP_SE_0001 Dummy 에서 Account 정보 upsert
  *                : 인터페이스에서 들어오는 데이터는 농협/관내, 대리점 데이터만 들어옴
  *                : 영업소 Account 이미 세팅이 되어 있다고 판단하에 농협/관내, 대리점 Account를 적용
  *                : cf) PersonAccount는 전혀 상관없음
  * @tester        : Dummy_IF_KR_ERP_SE_0001_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-17      i2max          Create
****************************************************************************************/
public class Dummy_IF_KR_ERP_SE_0001_ba extends Dummy_IF_Batch {

    public String query;
    public Boolean isNextBatch = true;

    private Map<String, SObject> disctinctMap = new Map<String, SObject>();
    private List<SObject> duplicatedList = new List<SObject>();

    public Dummy_IF_KR_ERP_SE_0001_ba() {
        this(null);
    }

    public Dummy_IF_KR_ERP_SE_0001_ba(final String query) {
        this(query, true);
    }

    public Dummy_IF_KR_ERP_SE_0001_ba(final String query, final Boolean isNextBatch) {
        this.query = query;
        this.isNextBatch = isNextBatch;
    }

    /**
     * 영업소코드 기준 영업소고객 정보
     */
    private static Map<String, Account> businessOfficeAccountsByIds {get;set;}
    /**
     * Business Account의 레코드 타입
     */
    private static Map<String, RecordType> recordTypesByNames {get;set;}
    /**
     * ErpKVGR2 데이터 기준 매핑 Account의 레코드 타입
     */
    private static Map<String, RecordType> recordTypeByErpKVGR2 {get;set;}
    /**
     * ErpKVGR2 데이터 기준 매핑 CustomerType
     */
    private static Map<String, String> customerTypeByErpKVGR2 {get;set;}

    static {
        Dummy_IF_KR_ERP_SE_0001_ba.businessOfficeAccountsByIds = new Map<String, Account>();
        String erpCode;
        for(Account businessOfficeAccount : [
            SELECT  Id, Name, ERPCode__c, BusinessOffice__c, BusinessOfficeName__c, OwnerId, Owner.Name
            FROM    Account
            WHERE   CustomerType__c = '영업소'
        ]) {
            erpCode = businessOfficeAccount.ERPCode__c;
            if(String.isNotBlank(erpCode) && !Dummy_IF_KR_ERP_SE_0001_ba.businessOfficeAccountsByIds.containsKey(erpCode)) {
                Dummy_IF_KR_ERP_SE_0001_ba.businessOfficeAccountsByIds.put(erpCode, businessOfficeAccount);
            }
        }

        Dummy_IF_KR_ERP_SE_0001_ba.recordTypesByNames = new Map<String, RecordType>();
        for(RecordType recordType : [
            SELECT  Id, Name, IsActive, IsPersonType, DeveloperName
            FROM    RecordType
            WHERE   SobjectType = 'Account'
            AND     IsActive = TRUE
            AND     IsPersonType = FALSE
        ]) {
            /*
            0121m000000ANtkAAG	관납/농협	true	false	BusinessAccount1
            0121m000000BFZwAAO	대리점	true	false	BusinessAccount3
            0121m000000Ai5TAAS	영업소	true	false	BusinessAccount2
             */
            // 일단 DeveloperName 기준으로 맵구성
            Dummy_IF_KR_ERP_SE_0001_ba.recordTypesByNames.put(recordType.DeveloperName.trim(), recordType);
        }

        Dummy_IF_KR_ERP_SE_0001_ba.recordTypeByErpKVGR2 = new Map<String, RecordType> {
            '71B' => Dummy_IF_KR_ERP_SE_0001_ba.recordTypesByNames.get('BusinessAccount1'),    // 관납/농협
            '71F' => Dummy_IF_KR_ERP_SE_0001_ba.recordTypesByNames.get('BusinessAccount1'),    // 관납/농협
            '71A' => Dummy_IF_KR_ERP_SE_0001_ba.recordTypesByNames.get('BusinessAccount3'),    // 대리점
            '71I' => Dummy_IF_KR_ERP_SE_0001_ba.recordTypesByNames.get('BusinessAccount3')     // 대리점
        };

        Dummy_IF_KR_ERP_SE_0001_ba.customerTypeByErpKVGR2 = new Map<String, String> {
            '71B' => '농협',
            '71F' => '관납',
            '71A' => '대리점',
            '71I' => '대리점'
        };
    }

    /**
     * Start
     *
     * @param BC : BatchableContext
     *
     * @return Database.QueryLocator
     */
    public override Database.QueryLocator start(Database.BatchableContext BC) {
        //============================================================================
        // 후행 Dummy 데이터 삭제 배치 정보
        //============================================================================
        this.interfaceId = 'IF_KR_ERP_SE_0001';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
            'IF_KR_ERP_SE_0001__c',
            interfaceId,
            Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.DAILY,
            this.exeDatetime
        );

        /*
        ERPCode__c	PK	        거래선코드(ERP)	                            Text	20
        "	Name"		        고객명	                                    Text	80
        isDelete__c		        삭제여부	                                    Text	10
        ErpVKBUR__c		        ERP 영업팀	                                Text	10
        ErpKVGR2__c		        ERP 고객유형 코드	                        Text	10
        CustomerType__c		    고객유형 : 대리점/농협/관납	                Text	20
        BusinessOffice__c	    영업소코드(ERP) - 거래선 관할 영업소코드(ERP)	Text	20
        ErpBEZEI3__c		    영업소 코드 명	                            Text	20
        "	Phone"		        전화	                                    Text	30
        Mobile__c		        이동전화                                    	Text	30
        "	Fax"		        팩스	                                    Text	30
        ErpAddr__c		        ERP 주소	                                Text	255
        BillingPostalCode	    우편번호	                                    Text	20
        BillingCountry		    국가명	                                    Text	80
        "	Representative__c"	대표자	                                    Text	50
        BizRegNo__c		        사업자등록번호	                            Text    20
        ErpPriceType__c		    ERP 가격리스트 유형(화면 표시 안함)	        Text	10

         */

        /*
        ERPCode__c
        CustomerName__c
        CustomerType__c
        InterfaceId__c
        BillingCountry__c
        Representative__c
        BizRegNo__c
        isDelete__c
        ErpBEZEI3__c
        BusinessOffice__c
        BillingPostalCode
        Mobile__c
        Phone__c
        Fax__c
        ErpPriceType__c
        ErpKVGR2__c
        ErpVKBUR__c
        ErpAddr__c
         */

        //----------------------------------------------------------------------------------
        // 2021-04-14 : 허이사님 수정 요청
        // Account의 ErpCode로 중복된 데이터가 존재할 수 있으므로 미리 정제하여 Dummy를 기준으로
        // 한건씩만 execue로 넘김
        // ErpCode가 동일한 Dummy는 finish에서 일괄 처리 업데이트 함
        //----------------------------------------------------------------------------------
        String erpCode;

        for(IF_KR_ERP_SE_0001__c dummy : [
            SELECT  Id, ERPCode__c
            FROM    IF_KR_ERP_SE_0001__c
            WHERE   InterfaceId__c = :this.interfaceId
            AND     isBatchCompleted__c = FALSE
            AND     isBatchError__c = FALSE
            ORDER BY CreatedDate DESC
        ]) {
            erpCode = dummy.ERPCode__c;
            if(!disctinctMap.containsKey(erpCode)) {
                disctinctMap.put(erpCode, dummy);
            }
            else {
                duplicatedList.add(dummy);
            }
        }

        if(String.isNotBlank(this.query)) {
            return Database.getQueryLocator(this.query);
        } else {
            return Database.getQueryLocator([
                    SELECT
                            ERPCode__c,
                            CustomerName__c,
                            CustomerType__c,
                            InterfaceId__c,
                            BillingCountry__c,
                            Representative__c,
                            BizRegNo__c,
                            isDelete__c,
                            ErpBEZEI3__c,
                            BusinessOffice__c,
                            BillingPostalCode__c,
                            Mobile__c,
                            Phone__c,
                            Fax__c,
                            ErpPriceType__c,
                            ErpKVGR2__c,
                            ErpVKBUR__c,
                            ErpAddr__c,
                            isBatchCompleted__c,
                            isBatchError__c,
                            BatchErrorMessage__c
                    FROM    IF_KR_ERP_SE_0001__c
                    WHERE   Id IN :this.disctinctMap.values()
            ]);
        }
    }

    /**
     * 수행 로직 구현
     *
     * @param BC : BatchableContext
     * @param targetScope : Batch Size 실행 리스트
     */
    public override void execute(Database.BatchableContext BC, List<SObject> targetScope) {
        //============================================================================
        // 실제 SObject 형변환
        //============================================================================
        final List<IF_KR_ERP_SE_0001__c> scope = (List<IF_KR_ERP_SE_0001__c>)targetScope;

        /*
         * 수신 데이터 Accout Upsert
            1)	ERPCode__c : ERPCode__c 세팅
            2)	RecordType : ErpKVGR2__c = 71B, 71F 이면 농협/관납,  71A, 71I 이면 대리점
            3)	Owner : 신규인 경우 BusinessOffice__c = Account.ErpCode__c & CustomerType__c = "영업소" 레코드 조회, Account.Owner를 설정
            4)	Name : Name 설정
            5)	CustomerType__c : ErpKVGR2__c가 71B이면 농협, 71F 이면 관납, 71A or 71I 이면 대리점
            6)	Representative__c : Representative__c 설정
            7)	BizRegNo__c : BizRegNo__c 설정
            8)	Parent : ErpKVGR2__c = 71A, 71I 이면 BusinessOffice__c = Account.ErpCode__c & CustomerType__c = "영업소" 레코드 Lookup
            9)	BusinessOffice__c : BusinessOffice__c = Account.ErpCode__c & CustomerType__c = "영업소" 레코드 조회, Account.Name 필드로 설정
            10)	Phone : Phone 필드로 설정
            11)	Fax : Fax 필드로 설정
            12)	Mobile__c : Mobile__c 필드로 설정
            13)	ErpAddr__c : ErpAddr__c 필드로 설정
            14)	BillingPostalCode : BillingPostalCode 필드로 설정
            15)	BillingCountry : BillingCountry 필드로 설정
            16)	ErpPriceType__c : ErpPriceType__c 필드로 설정
            17)	isDelete__c :  isDelete__c = "X" 이면 True, 아니면 False 치환
            ----------------------------------------------------------------------------------------
         * 영업소는 이미 Account 에 적재되어 있음
         * PersonAccount는 해당 사항 없음
         * BusinessOffice__c : Dummy 데이터의 영업소 ERPCode가 됨
         * Dummy의 BusinessOffice__c 에 해당하는 Account(영업소) 데이터를 구함
         */

        //============================================================================
        // ErpCode 기준 Dummy 맵
        //============================================================================
        Map<String, IF_KR_ERP_SE_0001__c> DummyByErpCode = new Map<String, IF_KR_ERP_SE_0001__c>();
        String erpCode;
        for(IF_KR_ERP_SE_0001__c dummy : scope) {
            // 일단 lpad 하여 비교
            erpCode = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.ERPCode__c);
            if(String.isNotBlank(erpCode) && !DummyByErpCode.containsKey(erpCode)) {
                DummyByErpCode.put(erpCode, dummy);
            }
        }

        //============================================================================
        // 존재하는 ErpCode 기준 이미 생성된 Account 맵
        //============================================================================
        Map<String, Account> AccountByErpCode = new Map<String, Account>();
        for(Account account : [
            SELECT  Id,
                ERPCode__c,
                RecordTypeId,
                ParentId,
                BusinessOffice__c,
                BusinessOfficeName__c,
                Name,
                CustomerType__c,
                Representative__c,
                BusinessRegNo__c,
                Phone,
                Fax,
                Mobile__c,
                ErpAddr__c,
                BillingPostalCode,
                BillingCountry,
                ErpPriceType__c,
                IsDelete__c
            FROM    Account
            WHERE   ERPCode__c IN :DummyByErpCode.keySet()
        ]) {
            erpCode = Dummy_IF_BatchUtil.getErpCodeLpad(account.ERPCode__c);
            if(String.isNotBlank(erpCode) && !AccountByErpCode.containsKey(erpCode)) {
                AccountByErpCode.put(account.ERPCode__c, account);
            }
        }

        /*
         * ================================================================
         * 데이터 DML 처리를 위한 3개의 기본 변수
         * ================================================================
         */
        //============================================================================
        // SObject 로는 upsert 가 불가. 따라서 insert, update 분리 처리
        //============================================================================
        List<SObject> targetInsList = new List<SObject>();
        List<SObject> targetUpdList = new List<SObject>();
        // validation 처리시 비정상 Dummy Data List
        List<SObject> targetBadDummyList = new List<SObject>();
        // Dml 수행 에러 Dummy Data List
        List<SObject> targetDmlDummyList = new List<SObject>();
        // ErpPriceType null 인 경우 별도 처리
        List<SObject> erpPriceTypeNullDummyList = new List<SObject>();

        String erpKVGR2, businessOffice, customerName;
        Account tmpBusinessOfficeAccount, tmpExistAccount, tmpAccount;
        RecordType tmpRecordType;
        Boolean isExistRecord, isGoodDummy;

        Set<String> insDupSetByErpCode = new Set<String>();

        for(IF_KR_ERP_SE_0001__c dummy : scope) {

            //============================================================================
            // ERP의 가격이 없는 경우에는 dummy만 배치 처리
            // '대리점 가격정보 없음' 처리
            // 2021-04 -19 : 수정요청
            //============================================================================
            if(String.isBlank(dummy.ErpPriceType__c)) {
                dummy.isBatchCompleted__c = true;
                dummy.BatchErrorMessage__c = '대리점 가격정보 없음';
                erpPriceTypeNullDummyList.add(dummy);
                continue;
            }

            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            dummy.isBatchCompleted__c = true;

            // 자신의 ERPCode : 일단 lpad 하여 비교
            erpCode = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.ERPCode__c);
            // 식별코드
            erpKVGR2 = dummy.ErpKVGR2__c;
            // 상위 영업소 ERPCode(대리점, 농협/관내 모두 상위 영업소 코드는 반드시 들어온다)
            // 영업소 ERPCode 인 BusinessOffice__c는 71E, 71A, 71D 이런 코드값으로 들어옴
            businessOffice = dummy.BusinessOffice__c;
            // 더미 CustomerName
            customerName = dummy.CustomerName__c;
            // 기존 데이터
            tmpExistAccount = AccountByErpCode.get(erpCode);
            // 기존 데이터 여부
            isExistRecord = tmpExistAccount != null ? true : false;
            // 상위 영업소 Account
            tmpBusinessOfficeAccount = businessOfficeAccountsByIds.get(businessOffice);
            // 해당 레코드타입
            tmpRecordType = Dummy_IF_KR_ERP_SE_0001_ba.recordTypeByErpKVGR2.get(erpKVGR2);

            //============================================================================
            // 정상 Dummy 데이터 여부
            // erpKVGR2, tmpRecordType, businessOffice, tmpBusinessOfficeAccount
            // 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]
            //============================================================================
            // TODO : dummy.ErpPriceType__c 가 NULL 이면 오류 처리 없이 정상 배치 완료로 처리 필요, 실제 신규 및 수정 처리 안함.
            isGoodDummy =   String.isNotBlank(erpKVGR2)
                &&  (tmpRecordType != null)
                &&  String.isNotBlank(businessOffice)
                &&  (tmpBusinessOfficeAccount != null)
                &&  String.isNotBlank(customerName)
            ;

            if(isGoodDummy == false) {
                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                    dummy,
                    String.format(
                        Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                        new String[]{'ErpKVGR2__c or 매핑 레코드타입 or BusinessOffice__c or 상위영업소 or CustomerName__c'}
                    ),
                    this.errorDummyIds
                ));

                continue;
            }

            //============================================================================
            // 신규 데이터인 경우
            //============================================================================
            if(isExistRecord == false) {
                targetInsList.add(tmpAccount = new Account(
                    OwnerId = tmpBusinessOfficeAccount.OwnerId,
                    Name = customerName
                ));
            }
            //============================================================================
            // 기존 데이터인 경우
            // OwnerId, Name 을 제외하고 모두 없데이트 처리
            //============================================================================
            else {
                targetUpdList.add(tmpAccount = tmpExistAccount);
            }
            //============================================================================
            // 신규 or 기존 데이터 모두 데이터 update 처리
            //============================================================================
            // 업데이트시는 명칭 바꾸지 않도록 한다.
            // 수정일 : 2021.06.17
            // 요청자 : 최희웅
//            tmpAccount.Name              = customerName;
            tmpAccount.ERPCode__c        = erpCode;
            tmpAccount.RecordTypeId      = (tmpRecordType != null) ? tmpRecordType.Id : null;
            tmpAccount.ErpName__c        = customerName;
            tmpAccount.CustomerType__c   = Dummy_IF_KR_ERP_SE_0001_ba.customerTypeByErpKVGR2.get(erpKVGR2);
            tmpAccount.Representative__c = dummy.Representative__c;
            // 10자리 이상 특수무자 포함되서 제거
            tmpAccount.BusinessRegNo__c  = dummy.BizRegNo__c != null ? dummy.BizRegNo__c.replaceAll('[^0-9]', '') : null;
            // ParentId 와 BusinessOffice__c 는 동일한 영업소 lookup
            tmpAccount.ParentId          = tmpBusinessOfficeAccount.Id;
            // 2020-04-28 : 필드 수정 추가됨
            tmpAccount.BusinessOffice__c = tmpBusinessOfficeAccount.Id;
            // 영업소의 BusinessOfficeName__c 를 하위 고객의 BusinessOfficeName__c 로 세팅
            // 2020-04-28 : 필드 수정 추가됨
            tmpAccount.BusinessOfficeName__c = tmpBusinessOfficeAccount.BusinessOfficeName__c;
            tmpAccount.Phone             = dummy.Phone__c;
            tmpAccount.Fax               = dummy.Fax__c;
            tmpAccount.Mobile__c         = dummy.Mobile__c;
            tmpAccount.ErpAddr__c        = dummy.ErpAddr__c;
            tmpAccount.BillingPostalCode = dummy.BillingPostalCode__c;
            tmpAccount.BillingCountry    = dummy.BillingCountry__c;
            tmpAccount.ErpPriceType__c   = dummy.ErpPriceType__c;
            //============================================================================
            // dummy 데이터는 Active 데이터만 들어오기에 아래 IsDelete 반영은 주석처리
            // SE 담당자가 임의로 관리함. 따라서 Account에 아래 필드는 반영되면 안됨.
            //============================================================================
            //tmpAccount.IsDelete__c       = (dummy.isDelete__c == 'X') ? true : false;

            //============================================================================
            // target or dummy 데이터 리스트 add
            //============================================================================
            targetDmlDummyList.add(dummy);
        }

        /*
         * ================================================================
         * Dummy 상태처리 : validation 체크로 비정상 Dummy Data 리스트를 먼저 update
         * ================================================================
         */
        update targetBadDummyList;

        /*
         * ================================================================
         * 대리점 가격정보 없음 dummy 리스트 update
         * ================================================================
         */
        update erpPriceTypeNullDummyList;

        /*
         * ================================================================
         * Dml 수행 및 Dummy 상태처리 : 에러시 Dummy 상태값 세팅
         * ================================================================
         */
        System.Savepoint sp;
        try {
            sp = Database.setSavepoint();
            insert targetInsList;
            update targetUpdList;
        }
        catch(Exception e) {
            Database.rollback(sp);
            System.debug(System.LoggingLevel.ERROR, '::::: ERROR LOG ' + e);
            targetDmlDummyList = Dummy_IF_BatchUtil.setDummyBatchResult(targetDmlDummyList, this.errorDummyIds, e);
        }
        finally {
            update targetDmlDummyList;
        }

    }

    /**
     * 개별적 finish 수행
     * 후행배치가 먼저 수행이 되어야 한다.(에러 상관없이 수행되어야 함.)
     *
     * @param BC Database.BatchableContext
     */
    public override void finish(Database.BatchableContext BC) {
        //============================================================================
        // 27번 배치 수행
        //============================================================================
        if(this.isNextBatch)    Database.executeBatch(new Dummy_IF_KR_ERP_SE_0027_ba(), 200);
        //============================================================================
        // 중복된 dummy Data를 일괄 처리
        //============================================================================
        if(this.duplicatedList.size() > 0)  Database.executeBatch(new Dummy_IF_KR_ERP_SE_0001_2_ba(this.duplicatedList), 2000);
        //============================================================================
        // 상위 공통 처리 수행
        //============================================================================
        super.finish(BC);

    }

}