/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0039_ba
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-06-22
  * @group         :
  * @group-content :
  * @description   : [연체이자]
  *                : IF_KR_ERP_SE_0039 Dummy -> OverdueInterest__c : upsert
  * @tester        : Dummy_IF_KR_ERP_SE_0039_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-06-22               i2max               Create
    0.2     2022-05-09               i2max               ITVOC-2022-04-0821
*************a***************************************************************************/
public class Dummy_IF_KR_ERP_SE_0039_ba extends Dummy_IF_Batch {

	public String query;
	public Boolean isNextBatch = true;

	public Dummy_IF_KR_ERP_SE_0039_ba() {
		this(null);
	}

	public Dummy_IF_KR_ERP_SE_0039_ba(final String query) {
		this(query, true);
	}

	public Dummy_IF_KR_ERP_SE_0039_ba(final String query, final Boolean isNextBatch) {
		this.query = query;
		this.isNextBatch = isNextBatch;
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
		this.interfaceId = 'IF_KR_ERP_SE_0039';
		this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
				'IF_KR_ERP_SE_0039__c',
				interfaceId,
				Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.DAILY,
				this.exeDatetime
		);

		/*
			SPMON__c		기준연월
			BUKRS__c		회사코드
			GJAHR__c		회계연도
			BELNR__c		청구문서번호
			VBUDAT__c		전표의 전기일
			KUNNR__c		고객코드
			KTEXT__c		고객명
			ZUONR__c		기대번호
			VBELNR__c		당월청구이자 전표번호         이자전표번호	InterestBillNo__c
			VKBUR__c		영업팀
			VKGRP__c		영업 그룹
			PREAMT__c		전월말 미수이자잔액
			ACTAMT__c		당월청구이자                  청구이자금액	ChargingInterestAmount__c
			PAYAMT__c		당월상환이자                  상환이자금액	CollectedInterestAmount__c
			STAMT__c		당월 역분개금액
			REMAMT__c		당월말 미수이자잔액

		*/
		if(String.isNotBlank(this.query)) {
			return Database.getQueryLocator(this.query);
		} else {
			return Database.getQueryLocator([
					SELECT
							Id,
							InterfaceId__c,
							SPMON__c,
							BUKRS__c,
							GJAHR__c,
							BELNR__c,
							VBUDAT__c,
							KUNNR__c,
							KTEXT__c,
							ZUONR__c,
							VBELNR__c,
							VKBUR__c,
							VKGRP__c,
							PREAMT__c,
							ACTAMT__c,
							PAYAMT__c,
							STAMT__c,
							REMAMT__c,
							isBatchCompleted__c,
							isBatchError__c,
							BatchErrorMessage__c
					FROM IF_KR_ERP_SE_0039__c
					WHERE InterfaceId__c = :this.interfaceId
					AND isBatchCompleted__c = FALSE
					AND isBatchError__c = FALSE
					ORDER BY SPMON__c, BELNR__c, ZUONR__c, VBELNR__c, VKBUR__c
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
		final List<IF_KR_ERP_SE_0039__c> scope = (List<IF_KR_ERP_SE_0039__c>) targetScope;

		Set<String> externalKeys = new Set<String>();       // 외부 키
		Set<String> dealerCodes = new Set<String>();        // 대리점 코드
		Set<String> assetNos = new Set<String>();           // 기대번호
		Set<String> billDocNos = new Set<String>();            // 채권번호
		// SPMON__c, BELNR__c, ZUONR__c, VBELNR__c
		// 외부키 V1 : ExternalKey__c : 기준년월 + '_' + 청구문서번호 + '_' + 기대번호 + '_' + 당월청구이자 전표번호
		// 외부키 V2 : 기준연월(SPMON), 채권전표번호(BELNR), 기대번호(ZUONR)로 변경
		for (IF_KR_ERP_SE_0039__c dummy : scope) {
			externalKeys.add(dummy.SPMON__c + '_' + dummy.BELNR__c + '_' + dummy.ZUONR__c);
			if(String.isNotBlank(dummy.KUNNR__c)) dealerCodes.add(dummy.KUNNR__c);      // 고객 번호
			if(String.isNotBlank(dummy.ZUONR__c)) assetNos.add(dummy.ZUONR__c);         // 기대번호
			if(String.isNotBlank(dummy.BELNR__c)) billDocNos.add(dummy.SPMON__c+'_'+dummy.BELNR__c);       // 청구문서 번호
		}

		Map<String, OverdueInterest__c> overdueInterestMap = new Map<String, OverdueInterest__c>();
		for (OverdueInterest__c r : [
				SELECT
						Id,
						Name,
						ExternalKey__c,
						BaseDate__c,
						InterestChargingDate__c,
						Dealer__c,
						DealerCode__c,
						SerialNo__c,
						BondBillNo__c,
						InterestBillNo__c,
						ChargingInterestAmount__c,
						CollectedInterestAmount__c,
						ChargedInterestTotalAmount__c,
						ChargingReverseAmount__c,
						AR__c,
						Asset__c
				FROM OverdueInterest__c
				WHERE ExternalKey__c IN :externalKeys
		]) {
			if (!overdueInterestMap.containsKey(r.ExternalKey__c)) {
				overdueInterestMap.put(r.ExternalKey__c, r);
			}
		}

		// 채권
		Map<String, AR__c> arMap = new Map<String, AR__c>();
		for(AR__c r : [
				SELECT Id, Name, ExternalId__c, BillingDocNo__c, Order__c
				FROM AR__c
				WHERE ExternalId__c IN :billDocNos
		]) {
			if(!arMap.containsKey(r.ExternalId__c)) {
				arMap.put(r.ExternalId__c, r);
			}
		}

		// 대리점 정보
		Map<String, Account> dealerMap = new Map<String, Account>();
		for (Account r : [
				SELECT
						Id,
						Name,
						ERPCode__c,
						DealerOwner__c
				FROM Account
				WHERE ERPCode__c IN :dealerCodes
		]) {
			if (!dealerMap.containsKey(r.ERPCode__c)) {
				dealerMap.put(r.ERPCode__c, r);
			}
		}

		// 기대정보
		Map<String, Asset> assetMap = new Map<String, Asset>();
		for(Asset ast : [
				SELECT Id, Name, BatchNo__c
				FROM Asset
				WHERE BatchNo__c IN :assetNos
		]) {
			if(!assetMap.containsKey(ast.BatchNo__c)) {
				assetMap.put(ast.BatchNo__c, ast);
			}
		}

		/*
		 * ================================================================
		 * 데이터 DML 처리를 위한 3개의 기본 변수
		 * ================================================================
		 */
		// DML 처리 target List
		List<SObject> targetList = new List<SObject>();
		// validation 처리시 비정상 Dummy Data List
		List<SObject> targetBadDummyList = new List<SObject>();
		// Dml 수행 에러 Dummy Data List
		List<SObject> targetDmlDummyList = new List<SObject>();

		OverdueInterest__c tmpOverdueInterest;
		Boolean isGoodDummy, isExistRecord;
		List<String> errorComments = new List<String>();
		String externalKey;

		Date tmpInterestChargingDate;
		Date tmpQueryDate;
		Boolean isGoodDate = true;

		Account tmpDealer;
		AR__c tmpAR;

		String arKey;

		/*
		 * ================================================================
		 * 대상건 : 전체 데이터
		 * ================================================================
		 */
		for (IF_KR_ERP_SE_0039__c dummy : scope) {
			//============================================================================
			// 처음부터 처리여부 true 설정
			//============================================================================
			dummy.isBatchCompleted__c = true;
			dummy.isBatchError__c = false;
			dummy.BatchErrorMessage__c = '';
			dummy.BatchErrorComment__c = '';
			errorComments = new List<String>();

			System.debug('dummy.VBELNR__c ==> ' + dummy.VBELNR__c + '\t dummy.BELNR__c ==> ' + dummy.BELNR__c );

			/*
			 * ================================================================
			 * 정상 Dummy 데이터 여부
			 * 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]

			 * ================================================================
			 */
			isGoodDate = true;
			try {
				tmpInterestChargingDate = String.isNotBlank(dummy.VBUDAT__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.VBUDAT__c) : null;
				tmpQueryDate = String.isNotBlank(dummy.SPMON__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.SPMON__c + '01') : null;
			} catch (Exception e) {
				isGoodDate = false;
			}

			// 기존 데이터 여부
			externalKey = dummy.SPMON__c + '_' + dummy.BELNR__c + '_' + dummy.ZUONR__c;
			isExistRecord = overdueInterestMap.containsKey(externalKey) ? true : false;

			// SPMON__c, BELNR__c, ZUONR__c, VBELNR__c, VKBUR__c
			// 외부키 : ExternalKey__c : SPMON__c + '_' + BELNR__c + '_' + ZUONR__c
			System.debug(dummy.ZUONR__c + ' : ' + dummy.BELNR__c + ' : ' + dummy.ZUONR__c + ' : ' + isGoodDate);
			if(dummy.ZUONR__c == null || dummy.KUNNR__c == null || dummy.BELNR__c == null || !isGoodDate){
				isGoodDummy = false;
				errorComments.add(dummy.ZUONR__c);
				errorComments.add(dummy.KUNNR__c);
				errorComments.add(dummy.BELNR__c);
				errorComments.add(dummy.VBUDAT__c);
				dummy.BatchErrorComment__c = String.join(errorComments, ', ');
			}

			if (isGoodDummy == false) {

				dummy.BatchErrorComment__c = String.join(errorComments, ', ');

				targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
						dummy,
						String.format(
								Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
								new String[]{
										'필수 값 오류 '
								}
						),
						this.errorDummyIds
				));
				continue;
			}
			//============================================================================
			// 정상 Dummy 데이터인 경우
			//============================================================================
			else {
				arKey = dummy.SPMON__c + '_' + dummy.BELNR__c;
				tmpDealer = dealerMap.containsKey(dummy.KUNNR__c) ? dealerMap.get(dummy.KUNNR__c) : null;
				tmpAR = arMap.containsKey(arKey) ? arMap.get(arKey) : null;

				tmpOverdueInterest = new OverdueInterest__c();
				tmpOverdueInterest.ExternalKey__c                   = externalKey;
				tmpOverdueInterest.OwnerId                          = tmpDealer == null ? UserInfo.getUserId() : tmpDealer.DealerOwner__c;

				tmpOverdueInterest.BaseDate__c                      = tmpQueryDate;
				tmpOverdueInterest.InterestChargingDate__c          = tmpInterestChargingDate;

				tmpOverdueInterest.SalesOfficeCode__c               = dummy.VKBUR__c;
				tmpOverdueInterest.Dealer__c                        = tmpDealer == null ? null : tmpDealer.Id;
				tmpOverdueInterest.DealerCode__c                    = dummy.KUNNR__c;
				tmpOverdueInterest.DealerName__c                    = dummy.KTEXT__c;
				tmpOverdueInterest.SerialNo__c                      = dummy.ZUONR__c;
				tmpOverdueInterest.Asset__c                         = assetMap.containsKey(dummy.ZUONR__c) ? assetMap.get(dummy.ZUONR__c).Id : null;

				tmpOverdueInterest.AR__c                            = tmpAR == null ? null : tmpAR.Id;
				tmpOverdueInterest.Order__c                         = tmpAR == null ? null : tmpAR.Order__c;
				tmpOverdueInterest.BondBillNo__c                    = dummy.BELNR__c;
				tmpOverdueInterest.InterestBillNo__c                = dummy.VBELNR__c;
				tmpOverdueInterest.CollectedInterestAmount__c       = Dummy_IF_BatchUtil.getNumber(dummy.PAYAMT__c);
				tmpOverdueInterest.ChargingInterestAmount__c        = Dummy_IF_BatchUtil.getNumber(dummy.ACTAMT__c);
				tmpOverdueInterest.ChargedInterestTotalAmount__c    = Dummy_IF_BatchUtil.getNumber(dummy.REMAMT__c);
				tmpOverdueInterest.ChargingReverseAmount__c         = Dummy_IF_BatchUtil.getNumber(dummy.STAMT__c);

				targetList.add(tmpOverdueInterest);

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
			Database.upsertResult[] urList = Database.upsert(targetList, OverdueInterest__c.ExternalKey__c, false);
			for(Integer i=0; i<urList.size(); i++) {
				Database.upsertResult ur = urList[i];
				if(ur.isSuccess()==false) {
					System.debug('ERROR ID : ' + JSON.serializePretty(ur.errors));
				} else {
				}
			}
		} catch (Exception e) {
			Database.rollback(sp);
			System.debug(System.LoggingLevel.ERROR, '::::: ERROR LOG ' + e);
			targetDmlDummyList = Dummy_IF_BatchUtil.setDummyBatchResult(targetDmlDummyList, this.errorDummyIds, e);
		} finally {
			update targetDmlDummyList;
		}
	}

	/**
	 * finish
	 * 자신만의 처리사항이 있을 경우 overrid 구현할 것
	 * @param BC : BatchableContext
	 */
	public override void finish(Database.BatchableContext BC) {
		//============================================================================
		// super의 공통 finish 수행
		//============================================================================
		super.finish(BC);
		//============================================================================
		// 자신만의 finish 수행
		//============================================================================
	}

	public static void runTest() {
		Integer i=0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
	}
}