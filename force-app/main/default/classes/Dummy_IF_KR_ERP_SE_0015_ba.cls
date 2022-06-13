/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0015_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-17
  * @group         : 
  * @group-content : 
  * @description   : [수금]
  *                : IF_KR_ERP_SE_0015 Dummy -> CollectMoney__c : insert
  * @tester        : Dummy_IF_KR_ERP_SE_0015_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-17      i2max          Create
****************************************************************************************/
public class Dummy_IF_KR_ERP_SE_0015_ba extends Dummy_IF_Batch {

    public Boolean isNextBatch = true;

    public String query;

    public Dummy_IF_KR_ERP_SE_0015_ba() {
        this(null);
    }

    public Dummy_IF_KR_ERP_SE_0015_ba(final String query) {
        this.query = query;
    }
    
    /**
     * Start
     *
     * @param BC : BatchableContextd
     *
     * @return Database.QueryLocator
     */
    public override Database.QueryLocator start(Database.BatchableContext BC) {
        //============================================================================
        // 후행 Dummy 데이터 삭제 배치 정보
        //============================================================================
        this.interfaceId = 'IF_KR_ERP_SE_0015';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
                'IF_KR_ERP_SE_0006__c',
                interfaceId,
                Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.MONTHLY,
                this.exeDatetime
        );

        /*
        QueryDate__c	                PK	조회기준년월(yyyyMM)	Text	10
        ErpVKORG__c	                    PK	영업조직	            Text	10
        DistributionChannel__c      	PK	유통경로	            Text	10
        ErpSPART__c	                    PK	제품군	            Text    10
        SalesTeam__c	                PK	영업팀	            Text    10
        SGrp__c	                        PK	SGrp	            Text	10
        CustomerCode__c	                PK	고객코드	            Text	20
        ArStatement__c	                PK	채권전표	            Text	10
        Type__c		                        유형	                Text	10
        CurrencyName__c		                채권통화	            Text	20
        ArAmtKRW__c		                    채권금액(원)	        Num	    18,0
        DateOfSales__c		                매출발생일	        Text	10
        CollectMoneyDocNo__c		        수금문서번호	        Text	20
        ErpBLARST__c		                수금전표유형명	        Text	20
        CollectMoneyStatementType__c		수금전표유형	        Text	40
        ErpWAERK__c		                    수금통화	            Text	20
        CollectMoneyKRW__c		            수금(원)	            Num	    18,0
        RealCollectMoneyDay		            실제수금일	        Text	10
        ErpHKONT__c		                    회계계정코드	        Text	20
        GlName__c		                    회계계정	            Text	40
        BillingDocNo__c		                청구문서번호	        Text	20
        SalesTeamName__c		            영업팀명	            Text	50
        SalesGroupName__c		            영업그룹명	        Text	50
        CustomerName__c		                고객명	            Text	80
        BusinessOfficeCode__c		        영업소코드	        Text	10
        BusinessOfficeName__c		        영업소명	            Text	20
        ErpZUONR__c		                    채권전표지정	        Text	20
         */
        if(String.isNotBlank(this.query)) {
            return Database.getQueryLocator(this.query);
        } else {
            return Database.getQueryLocator([
                    SELECT
                            QueryDate__c,
                            ErpVKORG__c,
                            DistributionChannel__c,
                            ErpSPART__c,
                            SalesTeam__c,
                            SGrp__c,
                            CustomerCode__c,
                            ArStatement__c,
                            Type__c,
                            CurrencyName__c,
                            ArAmtKRW__c,
                            DateOfSales__c,
                            CollectMoneyDocNo__c,
                            ErpBLARST__c,
                            CollectMoneyStatementType__c,
                            ErpWAERK__c,
                            CollectMoneyKRW__c,
                            RealCollectMoneyDay__c,
                            ErpHKONT__c,
                            GlName__c,
                            BillingDocNo__c,
                            SalesTeamName__c,
                            SalesGroupName__c,
                            CustomerName__c,
                            BusinessOfficeCode__c,
                            BusinessOfficeName__c,
                            ErpZUONR__c,
                            Currency__c
                    FROM IF_KR_ERP_SE_0006__c
                    WHERE InterfaceId__c = :this.interfaceId
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
        final List<IF_KR_ERP_SE_0006__c> scope = (List<IF_KR_ERP_SE_0006__c>)targetScope;
        Set<String> customerCodeSet = new Set<String>();
        Set<String> erpZUONRSet = new Set<String>();
        Set<String> billDocIds = new Set<String>();
        Map<String, Account> accountMap = new Map<String, Account>();
        Map<String, String> dealerOwnerIdMap = new Map<String, String>();
        Map<String, Asset> assetMap = new Map<String, Asset>();
        Map<String, AR__c> arMap = new Map<String, AR__c>();


        /*
		* CollectMoney__c OBJ Insert
1)	owner : IF.CustomerCode__c = Account.ErpCode__c 레코드 Owner 참조
2)	CurrencyIsoCode : Currency__c 필드로 설정
3)	Division__c : [실적] 설정
4)	BaseYearMonth__c : QueryDate__c 필드로 설정, 포맷 변환
5)	SGrp__c : SGrp__c 필드로 설정
6)	SalesTeam__c : SalesTeam__c 필드로 설정
7)	SalesTeamName__c : SalesTeamName__c 필드로 설정
8)	SalesGroupName__c : SalesGroupName__c 필드로 설정
9)	BusinessOfficeName__c : BusinessOfficeName__c 필드로 설정
10)	Area__c : IF.CustomerCode__c = Account.ErpCode__c 레코드 지역 참조
11)	SalesRep__c : IF.CustomerCode__c = Account.ErpCode__c 레코드 "영업소 영업사원" 참조
12)	Channel__c : IF.CustomerCode__c = Account.ErpCode__c 레코드 "고객유형" 참조
13)	CustomerCode__c : CustomerCode__c 필드로 설정
14)	CustomerName__c : CustomerName__c 필드로 설정
15)	DateOfSales__c : DateOfSales__c 필드로 설정
16)	Type__c : Type__c 필드로 설정
17)	ArStatement__c : ArStatement__c 필드로 설정
18)	ArAmtKRW__c : ArAmtKRW__c 필드로 설정
19)	CollectMoneyStatementType__c : CollectMoneyStatementType__c 필드로 설정
20)	CollectMoneyDocNo__c : CollectMoneyDocNo__c 필드로 설정
21)	CollectMoneyKRW__c : CollectMoneyKRW__c 필드로 설정
22)	RealCollectMoneyDay : RealCollectMoneyDay 필드로 설정
23)	OverdueMonth__c : : IF TODAY() > PlanDate__c then (TODAY() - PlanDate__c) / 30 else 0, 소수점 이하 절사
24)	GlName__c : GlName__c 필드로 설정
25)	BillingDocNo__c : BillingDocNo__c 필드로 설정
         ----------------------------------------------------------------------------------------
         *
      */
        String customerCode = '';
        for(IF_KR_ERP_SE_0006__c dummy : scope) {
            // 일단 lpad 하여 비교
            customerCode = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.CustomerCode__c);
            customerCodeSet.add(customerCode);
            erpZUONRSet.add(dummy.ErpZUONR__c);
            billDocIds.add(dummy.BillingDocNo__c);
        }

        for(Account a : [
                SELECT Id, ERPCode__c, CustomerType__c, SalesRep__c, Area__c, Dealer__r.OwnerId, Parent.BusinessOfficeName__c
                FROM Account
                WHERE ERPCode__c IN :customerCodeSet
        ]) {
            if(!accountMap.containsKey(a.ERPCode__c)) {
                accountMap.put(a.ERPCode__c, a);
            }
        }

        for(Asset ast : [
                SELECT Id, Name, BatchNo__c,
                        Contract__c,
                        Contract__r.LeasePaymentAmt__c,
                        Contract__r.SelfPayPaymentAmt__c,
                        Contract__r.fm_LeaseDebtAmt__c,
                        Contract__r.fm_LoanDebtAmt__c,
                        Contract__r.LoanPaymentAmt__c
                FROM Asset
                WHERE BatchNo__c IN :erpZUONRSet
        ]) {
            if(!assetMap.containsKey(ast.BatchNo__c)) {
                assetMap.put(ast.BatchNo__c, ast);
            }
        }

        for(AR__c r : [
                SELECT Id, Name, BillingDocNo__c
                FROM AR__c
                WHERE BillingDocNo__c IN :billDocIds
        ]) {
            if(!arMap.containsKey(r.BillingDocNo__c)) {
                arMap.put(r.BillingDocNo__c, r);
            }
        }

        Map<String, Id> recordOwnerMap = Dummy_IF_BatchUtil.getRecordOwnder(this.interfaceId, customerCodeSet);

        // DML 처리 target List
        List<SObject> targetList = new List<SObject>();
        List<Contract__c> updateContractList = new List<Contract__c>();
        // validation 처리시 비정상 Dummy Data List
        List<SObject> targetBadDummyList = new List<SObject>();
        // Dml 수행 에러 Dummy Data List
        List<SObject> targetDmlDummyList = new List<SObject>();

        CollectMoney__c tmpCollectMoney;
        Account tempAccount;
        Asset tempAsset;
        Contract__c updateContract;
        Boolean isGoodDummy, isGoodDate;
        Date tmpBaseYearMonth, tmpDateOfSales, tmpRealCollectMoneyDay;

        /*
         * ================================================================
         * 대상건 :
         * ================================================================
         */
        for(IF_KR_ERP_SE_0006__c dummy : scope) {

            dummy.isBatchCompleted__c = true;
            dummy.isBatchError__c = false;
            dummy.BatchErrorMessage__c = null;
            dummy.BatchErrorComment__c = null;

            customerCode = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.CustomerCode__c);
            tempAccount = accountMap.get(customerCode);
            tempAsset   = assetMap.get(dummy.ErpZUONR__c);

            // 날짜 형식 체크
            isGoodDate = true;
            try {
                tmpBaseYearMonth = String.isNotBlank(dummy.QueryDate__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.QueryDate__c + '01') : null;
                tmpDateOfSales = String.isNotBlank(dummy.DateOfSales__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.DateOfSales__c) : null;
                tmpRealCollectMoneyDay = String.isNotBlank(dummy.RealCollectMoneyDay__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.RealCollectMoneyDay__c) : null;
            }
            catch(Exception e) {
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

            if(isGoodDummy == false) {
                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                                Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                                new String[]{'CustomerCode__c or QueryDate__c or DateOfSales__c or RealCollectMoneyDay__c or CurrencyName__c or Account is Null'}
                        ),
                        this.errorDummyIds
                ));
                continue;
            }
            else {
                tmpCollectMoney = new CollectMoney__c();
                tmpCollectMoney.ExternalId__c                   = dummy.QueryDate__c+'_'+dummy.BillingDocNo__c+'_'+dummy.CollectMoneyDocNo__c;
                tmpCollectMoney.CurrencyIsoCode                 = dummy.CurrencyName__c.toUpperCase();
                tmpCollectMoney.Division__c                     = '실적';
                tmpCollectMoney.BaseYearMonth__c                = tmpBaseYearMonth;
                tmpCollectMoney.SGrp__c                         = dummy.SGrp__c;
                tmpCollectMoney.SalesTeam__c                    = dummy.SalesTeam__c;
                tmpCollectMoney.SalesTeamName__c                = dummy.SalesTeamName__c;
                tmpCollectMoney.CustomerCode__c                 = customerCode;
                tmpCollectMoney.CustomerName__c                 = dummy.CustomerName__c;
                tmpCollectMoney.DateOfSales__c                  = tmpDateOfSales;
                tmpCollectMoney.Type__c                         = dummy.Type__c;
                tmpCollectMoney.BondStatement__c                = Decimal.valueOf(dummy.ArStatement__c);
                tmpCollectMoney.BondAmountWon__c                = dummy.ArAmtKRW__c;
                tmpCollectMoney.CollectMoney__c                 = dummy.CollectMoneyKRW__c;
                tmpCollectMoney.AccountingAccount__c            = dummy.GlName__c;
                tmpCollectMoney.SalesGroupName__c               = dummy.SalesGroupName__c;

                tmpCollectMoney.CollectMoneyStatementType__c    = dummy.CollectMoneyStatementType__c;
                tmpCollectMoney.CollectMoneyDocNo__c            = dummy.CollectMoneyDocNo__c;
                tmpCollectMoney.RealCollectMoneyDay__c          = tmpRealCollectMoneyDay;
                tmpCollectMoney.BillingDocumentNumber__c        = dummy.BillingDocNo__c;

                tmpCollectMoney.OwnerId                         = recordOwnerMap.get(customerCode);
                tmpCollectMoney.AccountId__c                    = tempAccount.Id;
                tmpCollectMoney.BusinessOfficeName__c           = tempAccount.Parent.BusinessOfficeName__c;
                tmpCollectMoney.SalesRep__c                     = tempAccount.SalesRep__c;
                tmpCollectMoney.Area__c                         = tempAccount.Area__c;
                tmpCollectMoney.Channel__c                      = tempAccount.CustomerType__c;

                if(dummy.ErpZUONR__c != null) {
                    tmpCollectMoney.AssetId__c = dummy.ErpZUONR__c;

                    if(tempAsset != null) {
                        tmpCollectMoney.Asset__c = tempAsset.Id;
/*
                        if(tempAsset.Contract__c != null) {
                            updateContract = tempAsset.Contract__r;
                            //==============================================================================
                            // 리스가 있는 경우.
                            //==============================================================================
                            if (updateContract.fm_LeaseDebtAmt__c > 0) {
                                if (updateContract.fm_LeaseDebtAmt__c > dummy.CollectMoneyKRW__c) {
                                    updateContract.LeasePaymentAmt__c = dummy.CollectMoneyKRW__c;
                                }
                                else {
//                                    updateContract.LeasePaymentAmt__c = updateContract.LeasePaymentAmt__c;
                                    updateContract.SelfPayPaymentAmt__c = dummy.CollectMoneyKRW__c - updateContract.LeasePaymentAmt__c;
                                }
                            }
                            //==============================================================================
                            // 융자가 있는 경우.
                            //==============================================================================
                            else if(updateContract.fm_LoanDebtAmt__c > 0) {
                                if(updateContract.LoanPaymentAmt__c > dummy.CollectMoneyKRW__c) {
                                    updateContract.LoanPaymentAmt__c = dummy.CollectMoneyKRW__c;
                                }
                                else {
//                                    updateContract.LoanPaymentAmt__c = updateContract.LoanPaymentAmt__c;
                                    updateContract.SelfPayPaymentAmt__c = dummy.CollectMoneyKRW__c - updateContract.SelfPayPaymentAmt__c;
                                }
                            }
                            else {
                                updateContract.SelfPayPaymentAmt__c = dummy.CollectMoneyKRW__c;
                            }
                        }
*/
                    }
                }

                targetList.add(tmpCollectMoney);
                targetDmlDummyList.add(dummy);
            }
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
            //insert targetList;
            //Database.upsert(targetList, CollectMoney__c.ExternalId__c, false);
            Database.upsertResult[] urList = Database.upsert(targetList, CollectMoney__c.ExternalId__c, false);
            //오류/성공 기록 저장
/*            for(Integer i=0; i<urList.size(); i++) {
                Database.upsertResult ur = urList[i];
                IF_DMS_0016_Indonesia_ERP_DMS_DUMMY__c dummy = dummyMap.get(cmList[i].ExternalID__c);
//                dummy.SuccessYN__c = ur.isSuccess()?'Y':'N';
                dummy.IsSuccess__c = ur.isSuccess()?'S':'F';
                if(ur.isSuccess()==false) {
                    logger.error('['+cmList[i].ExternalID__c+']'+ur.getErrors()[0]);
                } else {
                    tCnt++;
                }
            }*/
        }
        catch(Exception e) {
            Database.rollback(sp);
            System.debug(System.LoggingLevel.ERROR, e);
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
        // 후행 삭제
        //============================================================================
        // Dummy_IF_KR_ERP_SE_0014_3_ba 배치의 후행으로 연결됨
        //if(this.isNextBatch)    Database.executeBatch(new Dummy_IF_KR_ERP_SE_0015_ba(), 200);

        // 채권 강제 제로 레코드 생성 배치를 수행
        if(this.isNextBatch)    Database.executeBatch(new Dummy_IF_KR_ERP_SE_0039_ba(), 200);

        super.finish(BC);
    }

}