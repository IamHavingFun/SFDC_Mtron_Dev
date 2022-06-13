/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0014_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-17
  * @group         : 
  * @group-content : 
  * @description   : [채권현황]
  *                : IF_KR_ERP_SE_0014 -> Ar__c : insert
  * @tester        : Dummy_IF_KR_ERP_SE_0014_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-17      i2max          Create
****************************************************************************************/
public class Dummy_IF_KR_ERP_SE_0014_ba extends Dummy_IF_Batch {

    public String query;
    public Boolean isNextBatch = true;
    public Date baseYearMonth;

    public Dummy_IF_KR_ERP_SE_0014_ba() {
        this(null);
    }

    public Dummy_IF_KR_ERP_SE_0014_ba(final String query) {
        this(query, true);
    }

    public Dummy_IF_KR_ERP_SE_0014_ba(final String query, final Boolean isNextBatch) {
        this.query = query;
        this.isNextBatch = isNextBatch;
    }

    /**
     * Start
     * @param BC : BatchableContext
     *
     * @return Database.QueryLocator
     */
    public override Database.QueryLocator start(Database.BatchableContext BC) {
        //============================================================================
        // 후행 Dummy 데이터 삭제 배치 정보
        //============================================================================
        this.interfaceId = 'IF_KR_ERP_SE_0014';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
                'IF_KR_ERP_SE_0006__c',
                interfaceId,
                Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.MONTHLY,
                this.exeDatetime
        );

        /*
        ErpBUKRS__c	            PK	회사코드(ERP)	    Text	10
        BillingDocNo__c	        PK	청구문서번호	        Text	20
        FiscalYear__c	        PK	회계연도	            Text	10
        BillingDocItem__c	    PK	청구문서품목	        Text	20
        QueryDate__c	        PK	조회기준년월(yyyyMM)	Text	10
        ErpVKORG__c		            영업조직	            Text	10
        DistributionChannel__c		유통경로	            Text	10
        ErpSPART__c		            제품군	            Text	10
        SalesTeam__c		        영업팀	            Text	10
        SalesGroupCode__c		    SGrp	            Text	10
        CustomerCode__c		        고객코드	            Text	20
        ArAmtKRW__c		            채권(원)	            Num	    18,0
        CurrencyName__c		        통화	                Text	10
        BookkeepingDate__c		    전기일(yyyyMMdd)	    Text	20
        PlanDate__c		            계획일(yyyyMMdd)	    Text	20
        RepaymentKRW__c		        반제가능(원)	        Num	    18,0
        NoteCollectMoneyKRW__c		어음수금(원)	        Num	    18,0
        GlCode__c		            회계계정코드(ERP)	    Text	20
        GlName__c		            회계계정	            Text	40
        SalesTeamName__c		    영업팀명	            Text	50
        SalesGroupName__c		    영업그룹명	        Text	50
        CustomerName__c		        고객명	            Text	50
        BusinessOfficeCode__c		영업소코드	        Text	10
        BusinessOfficeName__c		영업소명	            Text	20
        ErpZUONR__c		            채권전표지정	        Text	20
        ArAmt__c		            채권 (ERP 현지통화)	Num	    18,0
        SalesDocNo__c               판매문서번호
         */
        if(baseYearMonth == null) {
            baseYearMonth = Date.today();
            if(baseYearMonth.day() == 1) {
                baseYearMonth = baseYearMonth.addMonths(-1).toStartOfMonth();
            } else {
                baseYearMonth = baseYearMonth.toStartOfMonth();
            }
        }
        // 이번달 생성된 채권 데이터를 삭제 처리 한다.
        // 실 채권과 0원 채권 동시 삭제 처리.
        delete [
                SELECT Id FROM AR__c WHERE Division__c = '실적' AND BaseYearMonth__c = :baseYearMonth
        ];

        if(String.isNotBlank(this.query)) {
            return Database.getQueryLocator(this.query);
        } else {
            return Database.getQueryLocator([
                    SELECT
                            ErpBUKRS__c,
                            BillingDocNo__c,
                            FiscalYear__c,
                            BillingDocItem__c,
                            QueryDate__c,
                            ErpVKORG__c,
                            DistributionChannel__c,
                            ErpSPART__c,
                            SalesTeam__c,
                            SalesGroupCode__c,
                            CustomerCode__c,
                            ArAmtKRW__c,
                            CurrencyName__c,
                            BookkeepingDate__c,
                            PlanDate__c,
                            RepaymentKRW__c,
                            NoteCollectMoneyKRW__c,
                            GlCode__c,
                            GlName__c,
                            SalesTeamName__c,
                            SalesGroupName__c,
                            CustomerName__c,
                            BusinessOfficeCode__c,
                            BusinessOfficeName__c,
                            ErpZUONR__c,
                            MachineNo__c,
                            ArAmt__c,
                            CoCd__c,
                            SalesDocNo__c,
                            isBatchCompleted__c,
                            isBatchError__c,
                            BatchErrorMessage__c
                    FROM IF_KR_ERP_SE_0006__c
                    WHERE InterfaceId__c = 'IF_KR_ERP_SE_0014'
                    AND isBatchCompleted__c = FALSE
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
        final List<IF_KR_ERP_SE_0006__c> scope = (List<IF_KR_ERP_SE_0006__c>) targetScope;
        Set<String> customerCodeSet = new Set<String>();    // 대리점 ERP 코드
        Set<String> erpZUONRSet = new Set<String>();        //
        Set<String> salesDocNoSet = new Set<String>();      // 판매문서번호
        Map<String, Account> accountMap = new Map<String, Account>();
        Map<String, String> dealerOwnerIdMap = new Map<String, String>();
        Map<String, Asset> assetMap = new Map<String, Asset>();
        Map<String, Order__c> orderMap = new Map<String, Order__c>();

        /*
	* AR__c OBJ Insert
1)	owner : IF.CustomerCode__c = Account.ErpCode__c 레코드 Owner 참조
2)	Division__c : [실적] 설정
3)	BaseYearMonth__c : QueryDate__c 필드로 설정, 포맷 변환
4)	FiscalYear__c : FiscalYear__c 필드로 설정
5)	DistributionChannel__c : DistributionChannel__c 필드로 설정
6)	CoCd__c : CoCd__c 필드로 설정
7)	BillingDocNo__c : BillingDocNo__c 필드로 설정
8)	GlName__c : GlName__c 필드로 설정
9)	BusinessOfficeName__c : BusinessOfficeName__c 필드로 설정
10)	Area__c : IF.CustomerCode__c = Account.ErpCode__c 레코드 지역 참조
11)	SalesRep__c : IF.CustomerCode__c = Account.ErpCode__c 레코드 "영업소 영업사원" 참조
12)	Channel__c : IF.CustomerCode__c = Account.ErpCode__c 레코드 "고객유형" 참조
13)	CustomerCode__c : CustomerCode__c 필드로 설정
14)	CustomerName__c : CustomerName__c 필드로 설정
15)	SalesTeam__c : SalesTeam__c 필드로 설정
16)	SGrp__c : SGrp__c 필드로 설정
17)	BookkeepingDate__c : BookkeepingDate__c 필드로 설정
18)	PlanDate__c : PlanDate__c 필드로 설정
19)	OverdueStatus__c : IF TODAY() > PlanDate__c then "연체" else "정상채권"
20)	OverdueDay__c : IF TODAY() > PlanDate__c then TODAY() - PlanDate__c else 0
21)	OverdueMonth__c : PlanDate__c / 30 소수점 이하 절사
22)	OverdueStatusDetail__c : 연체(일)=OverdueDay__c, IF(연체(일)<0,"정상채권",    IF(연체(일)<30,"1~29일",   IF(연체(일)<61,"30~60일",   IF(연체(일)<121,"61~120일",    IF(연체(일)<153,"121~152일",   IF(연체(일)<183,"153~182일",    IF(연체(일)<304,"183~303일",  IF(D62<336,"304~335일",    IF( 연체(일)<366,"336~365일",  IF(연체(일)>365,"1년초과"))))))))))
23)	OverdueStatusSummary__c : 연체(일)=OverdueDay__c, IF(연체(일)<0,"정상채권",IF(연체(일)<183,"6개월 미만",IF(연체(일)<365,"6~12개월","1년 초과")))
24)	CurrencyIsoCode : Currency__c 필드로 설정
25)	ArAmt__c : ArAmt__c 필드로 설정
26)	ArAmtKRW__c : ArAmtKRW__c 필드로 설정
27)	RepaymentKRW__c : RepaymentKRW__c 필드로 설정
28)	NoteCollectMoneyKRW__c : NoteCollectMoneyKRW__c 필드로 설정
         ----------------------------------------------------------------------------------------
         *
      */
        String customerCode = '';

        for (IF_KR_ERP_SE_0006__c dummy : scope) {
            // 일단 lpad 하여 비교
            customerCode = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.CustomerCode__c);
            customerCodeSet.add(customerCode);
            erpZUONRSet.add(dummy.ErpZUONR__c);
            salesDocNoSet.add(dummy.SalesDocNo__c);
        }

        for (Account a : [
                SELECT Id, ERPCode__c, CustomerType__c, SalesRep__c, Owner.LastName, Area__c, Dealer__r.OwnerId, BusinessOffice__c, BusinessOfficeName__c, Parent.BusinessOfficeName__c
                FROM Account
                WHERE ERPCode__c IN :customerCodeSet
        ]) {
            if (!accountMap.containsKey(a.ERPCode__c)) {
                accountMap.put(a.ERPCode__c, a);
            }
        }

        for (Asset ast : [
                SELECT Id, Name, BatchNo__c,
                        Contract__c,
                        Contract__r.SelfPayDebtAmt__c,
                        Contract__r.SelfPayDueDate__c,
                        Contract__r.fm_LeaseDebtAmt__c,
                        Contract__r.fm_LoanDebtAmt__c,
                        Contract__r.LeaseDueDate__c,
                        Contract__r.LoanDueDate__c
                FROM Asset
                WHERE BatchNo__c IN :erpZUONRSet
        ]) {
            if (!assetMap.containsKey(ast.BatchNo__c)) {
                assetMap.put(ast.BatchNo__c, ast);
            }
        }

        for (Order__c order : [
                SELECT Id, Name, SalesDocNo__c
                FROM Order__c
                WHERE SalesDocNo__c IN :salesDocNoSet
        ]) {
            if (!orderMap.containsKey(order.SalesDocNo__c)) {
                orderMap.put(order.SalesDocNo__c, order);
            }
        }

        // 소유자
        Map<String, Id> recordOwnerMap = Dummy_IF_BatchUtil.getRecordOwnder(this.interfaceId, customerCodeSet);

        // DML 처리 target List
        List<SObject> targetList = new List<SObject>();
        // validation 처리시 비정상 Dummy Data List
        List<SObject> targetBadDummyList = new List<SObject>();
        // Dml 수행 에러 Dummy Data List
        List<SObject> targetDmlDummyList = new List<SObject>();

        AR__c tmpAr;
        Account tempAccount;
        Asset tempAsset;
        Boolean isGoodDummy, isGoodDate;
        Date tmpPlanDate, tmpBookKeepingDate, tmpQueryDate;

        /*
         * ================================================================
         * 대상건 :
         * ================================================================
         */

        for (IF_KR_ERP_SE_0006__c dummy : scope) {
            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            dummy.isBatchCompleted__c = true;
            dummy.isBatchError__c = false;
            dummy.BatchErrorMessage__c = null;
            dummy.BatchErrorComment__c = null;
            customerCode = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.CustomerCode__c);
            tempAccount = accountMap.get(customerCode);
            tempAsset = assetMap.get(dummy.ErpZUONR__c);

            // 날짜 형식 체크
            isGoodDate = true;
            try {
                tmpPlanDate = String.isNotBlank(dummy.PlanDate__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.PlanDate__c) : null;
                tmpBookKeepingDate = String.isNotBlank(dummy.BookkeepingDate__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.BookkeepingDate__c) : null;
                tmpQueryDate = String.isNotBlank(dummy.QueryDate__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.QueryDate__c + '01') : null;
            } catch (Exception e) {
                isGoodDate = false;
            }

//            isGoodDummy = dummy.CustomerCode__c != null && isGoodDate && Dummy_IF_BatchUtil.isValidCurrency(dummy.CurrencyName__c) && tempAccount != null;

            isGoodDummy = true;
            List<String> errorComments = new List<String>();

            if(dummy.CustomerCode__c == null || !isGoodDate || !Dummy_IF_BatchUtil.isValidCurrency(dummy.CurrencyName__c) || tempAccount == null){
                isGoodDummy = false;

                if(dummy.CustomerCode__c == null) errorComments.add('Dummy CustomerCode__c 없음');
                if(!isGoodDate) errorComments.add('날짜오류 = ' + dummy.PlanDate__c + ', ' + dummy.BookkeepingDate__c + ', ' + dummy.QueryDate__c);
                if(!Dummy_IF_BatchUtil.isValidCurrency(dummy.CurrencyName__c)) errorComments.add('CurrencyName__c != KRW');
                if(tempAccount == null) errorComments.add('Account 없음 = [' + customerCode + ']');

                dummy.BatchErrorComment__c = String.join(errorComments, ', ');
            }

            if (isGoodDummy == false) {
                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                                Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                                new String[]{
                                        'CustomerCode__c or PlanDate__c or BookkeepingDate__c or QueryDate__c or CurrencyName__c or Account is Null'
                                }
                        ),
                        this.errorDummyIds
                ));

                continue;
            }


            tmpAr = new AR__c();
            tmpAr.ExternalId__c = '실적_'+dummy.QueryDate__c+'_'+dummy.BillingDocNo__c;
            tmpAr.Division__c = '실적';
            tmpAr.ArAmt__c = dummy.ArAmt__c;
            tmpAr.ArAmtKRW__c = dummy.ArAmtKRW__c;
            tmpAr.RepaymentKRW__c = dummy.RepaymentKRW__c;
            tmpAr.NoteCollectMoneyKRW__c = dummy.NoteCollectMoneyKRW__c;
            tmpAr.CurrencyIsoCode = dummy.CurrencyName__c.toUpperCase();
            tmpAr.PlanDate__c = tmpPlanDate;
            tmpAr.BookkeepingDate__c = tmpBookKeepingDate;
            tmpAr.SGrp__c = dummy.SalesGroupCode__c;
            tmpAr.SaleTeam__c = dummy.SalesTeam__c;
            tmpAr.CustomerName__c = dummy.CustomerName__c;
            tmpAr.CustomerCode__c = customerCode;
            tmpAr.GlName__c = dummy.GlName__c;
            tmpAr.BillingDocNo__c = dummy.BillingDocNo__c;
            tmpAr.CoCd__c = dummy.CoCd__c;
            tmpAr.DistributionChannel__c = dummy.DistributionChannel__c;
            tmpAr.FiscalYear__c = dummy.FiscalYear__c;
            tmpAr.BaseYearMonth__c = tmpQueryDate;

            tmpAr.BusinessOffice__c  = tempAccount.BusinessOffice__c;
            tmpAr.BusinessOfficeName__c = dummy.BusinessOfficeCode__c;      //tempAccount.BusinessOfficeName__c;

            tmpAr.AccountId__c = tempAccount.Id;
            //tmpAr.Channel__c = tempAccount.CustomerType__c;
            tmpAr.SalesRep__c = tempAccount.Owner.LastName;
            tmpAr.Area__c = tempAccount.Area__c;
            tmpAr.OwnerId = recordOwnerMap.get(customerCode);

            // 2021-06-16 : 판매문서번호를 통한 주문 연결.
            tmpAr.SalesOrderNumber__c = dummy.SalesDocNo__c;
            System.debug('판매문서번호 : ' + dummy.SalesDocNo__c + ' / ' + tmpQueryDate);
            tmpAr.Order__c = orderMap.containsKey(dummy.SalesDocNo__c) ? orderMap.get(dummy.SalesDocNo__c).Id : null;

            if (dummy.ErpZUONR__c != null) {
                tmpAr.AssetId__c = dummy.ErpZUONR__c;
                if (tempAsset != null) {
                    tmpAr.Asset__c = tempAsset.Id;
                }
            }
            targetList.add(tmpAr);
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
         * Dml 수행 및 Dummy 상태처리 : 에러시 Dummy 상태값 세팅
         * ================================================================
         */
        System.Savepoint sp;
        try {
            sp = Database.setSavepoint();
            System.debug('start====================');
            System.debug('targetList size => ' + targetList.size());
            System.debug('end====================');
//            insert targetList;
            Database.upsertResult[] urList = Database.upsert(targetList, AR__c.ExternalId__c, false);
            for(Integer i=0; i<urList.size(); i++) {
                Database.upsertResult ur = urList[i];
                if(ur.isSuccess()==false) {
                    //System.debug('ERROR ID : ' + JSON.serializePretty(ur.errors));
                } else {
                }
            }
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(System.LoggingLevel.ERROR, e);
            targetDmlDummyList = Dummy_IF_BatchUtil.setDummyBatchResult(targetDmlDummyList, this.errorDummyIds, e);
        } finally {
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
        // 후행 삭제
        //============================================================================
        // Dummy_IF_KR_ERP_SE_0014_3_ba 배치의 후행으로 연결됨
        //if(this.isNextBatch)    Database.executeBatch(new Dummy_IF_KR_ERP_SE_0015_ba(), 200);

        // 채권 강제 제로 레코드 생성 배치를 수행
        if(this.isNextBatch)    Database.executeBatch(new Dummy_IF_KR_ERP_SE_0014_3_ba(), 200);

        /*super.finish(BC);*/
    }
}