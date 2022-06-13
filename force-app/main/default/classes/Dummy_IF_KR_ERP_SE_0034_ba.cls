/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0034_ba
  * @projectname   : 
  * @author        : i2max 
  * @date          : 2020-06-29
  * @group         : 
  * @group-content : 
  * @description   : [블랙리스트]
  *                : IF_KR_ERP_SE_0001 -> Account : update
  * @tester        : Dummy_IF_KR_ERP_SE_0034_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-06-29               i2max               Create
    0.2     2022-04-22               i2max               ITVOC-2022-03-0723
*************a***************************************************************************/
public with sharing class Dummy_IF_KR_ERP_SE_0034_ba extends Dummy_IF_Batch{

    public String query;

    public Dummy_IF_KR_ERP_SE_0034_ba() {
        this(null);
    }

    public Dummy_IF_KR_ERP_SE_0034_ba(final String query) {
        this.query = query;
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
        this.interfaceId = 'IF_KR_ERP_SE_0034';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
                'IF_KR_ERP_SE_0001__c',
                interfaceId,
                Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.MONTHLY,
                this.exeDatetime
        );

        /*
        ERPCode__c	            PK	거래선코드(ERP)	        Text	20
        ErpName__c		            거래선명(ERP)	        Text	100
        BlacklistWarning__c		    S.E 경고여부 (Y/N)	    Text	10
        BlacklistErpDelivery__c		SAP 출하중지여부 (Y/N)    Text	10
        Blacklist30Days__c		    30일 예외적용여부 (Y/N)	Text	10
        DeliveryStopDate__c		    출하중지일자	            Text	10
        BlacklistReason__c		    경고 사유	            Text	200
        */
        if (String.isNotBlank(this.query)) {
            return Database.getQueryLocator(this.query);
        } else {
            return Database.getQueryLocator([
                    SELECT
                            Id,
                            ERPCode__c,
                            ErpName__c,
                            BlacklistWarning__c,
                            BlacklistErpDelivery__c,
                            Blacklist30Days__c,
                            DeliveryStopDate__c,
                            BlacklistReason__c,
                            isBatchCompleted__c,
                            isBatchError__c,
                            BatchErrorMessage__c
                    FROM IF_KR_ERP_SE_0001__c
                    WHERE InterfaceId__c = :this.interfaceId
                    AND isBatchCompleted__c = FALSE
                    AND isBatchError__c = FALSE
            ]);
        }
    }

    public override void execute(Database.BatchableContext BC, List<SObject> targetScope) {
        //============================================================================
        // 실제 SObject 형변환
        //============================================================================
        final List<IF_KR_ERP_SE_0001__c> scope = (List<IF_KR_ERP_SE_0001__c>)targetScope;
        Set<String> erpCodeSet = new Set<String>();
        Map<String, Account> accountMap = new Map<String, Account>();

        /*
        * 대리점 ERP코드를 기준으로 Account 업데이트
        1)	BlacklistWarning__c		    IF 더미.BlacklistWarning__c       Y -> True, N -> False
        2)	BlacklistErpDelivery__c		IF 더미.BlacklistErpDelivery__c   Y -> True, N -> False
        3)	Blacklist30Days__c		    IF 더미.Blacklist30Days__c        Y -> True, N -> False
        4)	BlacklistReason__c		    IF 더미.BlacklistReason__c
        5)	DeliveryStopDate__c		    IF 더미.DeliveryStopDate__c => date 변환

        *	S.E 경고여부(BlacklistWarning__c) = Y  이면 고객정보에 저장된 출하중지일(Account.DeliveryStopDate__c)과 인터페이스로 수신된 출하중지일(IF.DeliveryStopDate__c)이 다르면 대리점 대상 메시지 발신(메시지 수신시 1번 발송을 위하여)
	        (메시지)
            6개월 이상 연체채권이 존재합니다.
            당월에도 6개월 이상 연체채권이 증가하면 %/%출하중지일(DeliveryStopDate__c)%/% 출하 중지 예정입니다.
            또한, 당월 포함 향후 3개월간 6개월 이상 연체채권이 존재하면 그 다음달 출하 중지 예정입니다."
        */
        String  erpCode;
        for(IF_KR_ERP_SE_0001__c dummy : scope) {
            // lpad 하여 비교
            erpCode = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.ERPCode__c);
            erpCodeSet.add(erpCode);
        }

        for(Account a : [
                SELECT  Id,
                        Name,
                        ERPCode__c,
                        BlacklistWarning__c,
                        BlacklistErpDelivery__c,
                        Blacklist30Days__c,
                        BlacklistReason__c,
                        DeliveryStopDate__c,
                        DealerOwner__c,         // 대리점주
                        OwnerId                 // 영업사원
                FROM Account
                WHERE ERPCode__c IN :erpCodeSet
        ]) {
            if(!accountMap.containsKey(a.ERPCode__c) && String.isNotBlank(a.ERPCode__c)) {
                accountMap.put(a.ERPCode__c, a);
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

        Boolean isGoodDummy, isGoodDate;
        Account tmpAccount;
        Date tmpDeliveryStopDate;

        List<Task> guideTasks = new List<Task>();    // 가이드 액션 처리용.
        Task guideTask;
        Boolean isNotiTarget = false;

        List<String> errorComments = new List<String>();

                /*
				 * ================================================================
				 * 대상건 : 전체 데이터
				 * ================================================================
				 */
        for(IF_KR_ERP_SE_0001__c dummy : scope) {
            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            dummy.isBatchCompleted__c = true;
            isNotiTarget = false;

            // 자신의 CustomerCode : lpad 하여 비교
            erpCode = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.ERPCode__c);
            System.debug('dummy.ERPCode__c : ' + dummy.ERPCode__c);
            tmpAccount = accountMap.get(dummy.ERPCode__c);

            //============================================================================
            // 날짜 형식 체크
            //============================================================================
            isGoodDate = true;
            try {
                tmpDeliveryStopDate  = String.isNotBlank(dummy.DeliveryStopDate__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.DeliveryStopDate__c) : null;
            }
            catch(Exception e) {
                isGoodDate = false;
            }

            /*
             * ================================================================
             * 정상 Dummy 데이터 여부
             * 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]
             * ERPCode__c, tmpAccount, isGoodDate 이 필수 항목
             * ================================================================
             */
            isGoodDummy = (String.isNotBlank(dummy.ERPCode__c)
                        && tmpAccount != null
                        && isGoodDate
            );
            errorComments = new List<String>();
            if(isGoodDummy == false) {

                if(String.isBlank(dummy.ERPCode__c)) errorComments.add('ERPCode 누락 = ['+dummy.ERPCode__c+']');
                if(tmpAccount == null) errorComments.add('Account 없음 = ['+dummy.ERPCode__c+']');
                if(isGoodDate == false) errorComments.add('날짜오류 = ['+dummy.DeliveryStopDate__c+']');

                dummy.BatchErrorComment__c = String.join(errorComments, ', ');

                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                                Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                                new String[]{'IF.ERPCode__c IS NULL or Account IS NULL or IF.DeliveryStopDate__c Format Error'}
                        ),
                        this.errorDummyIds
                ));
                continue;
            }
            else {
                // todo : tmpAccount.DeliveryStopDate__c <> dummy.DeliveryStopDate__c 다르면 메시지 발신
                if(tmpAccount.DeliveryStopDate__c != Dummy_IF_BatchUtil.getIFDate(dummy.DeliveryStopDate__c)) {
                    isNotiTarget = true;
                }

                /*
                    ITVOC-2022-03-0723 로 인한 변경 로직
                    [출하 제한]: SAP으로 부터 수신한 STOP Field가 True이고, EXPTN Field가 False일 때, True
                    [출하 중지]: SAP으로 부터 수신한 STOP Field가 True이고, EXPTN Field가 True일 때, True
                    [경고 사유]: SAP으로 부터 수신한 Field값의 앞 "사유1.", "사유2."는 제외하고 나머지 값만 TEXT로 입력`
                 */
                Boolean BlacklistWarning     = Dummy_IF_BatchUtil.getBooleanFromString(dummy.BlacklistWarning__c);       // 출하 주의
                Boolean BlacklistErpDelivery = Dummy_IF_BatchUtil.getBooleanFromString(dummy.BlacklistErpDelivery__c);   // 출하 중지
                Boolean Blacklist30Days      = Dummy_IF_BatchUtil.getBooleanFromString(dummy.Blacklist30Days__c);        // 30일 예외 적용
                BlacklistWarning             = BlacklistWarning == null ? false : BlacklistWarning;
                BlacklistErpDelivery         = BlacklistErpDelivery == null ? false : BlacklistErpDelivery;
                Blacklist30Days              = Blacklist30Days == null ? false : BlacklistWarning;
                String  BlacklistReason = dummy.BlacklistReason__c;
                if(BlacklistReason != null) {
                    BlacklistReason = BlacklistReason.replaceAll('사유1.', '');
                    BlacklistReason = BlacklistReason.replaceAll('사유2.', '');
                }
                System.debug('BlacklistWarning : ['+BlacklistWarning+'], BlacklistErpDelivery : ['+BlacklistErpDelivery+'], Blacklist30Days : ['+Blacklist30Days+'], ');
                // 출하주의
                tmpAccount.BlacklistWarning__c      = BlacklistWarning;
                // 출하 중지
                tmpAccount.BlacklistErpDelivery__c  = BlacklistErpDelivery && Blacklist30Days ? true : false;
                // 출하 제한
                tmpAccount.Blacklist30Days__c       = BlacklistErpDelivery && !Blacklist30Days ? true : false;

                tmpAccount.BlacklistReason__c       = BlacklistReason;
                tmpAccount.DeliveryStopDate__c      = Dummy_IF_BatchUtil.getIFDate(dummy.DeliveryStopDate__c);
/*
    원본 :
                // 출하주의
                tmpAccount.BlacklistWarning__c      = Dummy_IF_BatchUtil.getBooleanFromString(dummy.BlacklistWarning__c);
                // 출하 중지
                tmpAccount.BlacklistErpDelivery__c  = Dummy_IF_BatchUtil.getBooleanFromString(dummy.BlacklistErpDelivery__c);
                // 출하 제한
                tmpAccount.Blacklist30Days__c       = Dummy_IF_BatchUtil.getBooleanFromString(dummy.Blacklist30Days__c);

                tmpAccount.BlacklistReason__c       = BlacklistReason;
                tmpAccount.DeliveryStopDate__c      = Dummy_IF_BatchUtil.getIFDate(dummy.DeliveryStopDate__c);
*/
                targetList.add(tmpAccount);
                targetDmlDummyList.add(dummy);

                /**
                 *  블랙 리스트 등재 되면 대리점과 영업사원에게 알림.
                 *  tmpAccount.DeliveryStopDate__c <> dummy.DeliveryStopDate__c 다르면 메시지 발신
                */

                String description = null;
                if(tmpAccount.Blacklist30Days__c == true) {
                    description = '[' + tmpAccount.Name + ']은 [경고 사유]에 따라, 매출채권 만기 30일 조건으로만 출하 가능합니다.';
                }
                if(tmpAccount.BlacklistErpDelivery__c == true) {
                    description = '[' + tmpAccount.Name + ']은 [경고 사유]에 따라, 악성채권 개선 이전까지는 출하가 불가능합니다.';
                }

                if(isNotiTarget == true && description != null && tmpAccount.DealerOwner__c != null) {
                    guideTask = new Task();
                    guideTask.OwnerId = tmpAccount.DealerOwner__c;
                    guideTask.ActivityDate = System.today();
                    guideTask.Type__c = 'Guide';
                    guideTask.WhatId = tmpAccount.Id;
                    guideTask.Subject = '[주문제한]';
                    guideTask.Description = description;
                    guideTask.CustomAlert__c = true;
                    guideTask.Status = 'Completed';
                    guideTasks.add(guideTask);

                    guideTask = new Task();
                    guideTask.OwnerId = tmpAccount.OwnerId;
                    guideTask.ActivityDate = System.today();
                    guideTask.Type__c = 'Guide';
                    guideTask.WhatId = tmpAccount.Id;
                    guideTask.Subject = '[주문제한]';
                    guideTask.Description = description;
                    guideTask.CustomAlert__c = true;
                    guideTask.Status = 'Completed';
                    guideTasks.add(guideTask);
                }

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
            update targetList;
            if(guideTasks.isEmpty() == false) insert guideTasks;
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
}