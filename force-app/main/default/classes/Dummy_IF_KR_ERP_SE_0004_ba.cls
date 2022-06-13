/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0004_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-17
  * @group         : 
  * @group-content : 
  * @description   : [공장재고] - 30분 배치 : 당일 전체건
  *                : IF_KR_ERP_SE_0004 -> Asset : upsert
  * @tester        : Dummy_IF_KR_ERP_SE_0004_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-17      i2max          Create
    0.2     2022-05-19      i2max          시리얼 번호 필드 추가 (기대번호), 기존 머신번호는 배치번호로 사용
****************************************************************************************/
// Database.executeBatch(new Dummy_IF_KR_ERP_SE_0004_ba(), 2000);
/*

		배치 수행여부	IS Error
12:00	A	FALSE
	B	TRUE
	c	TRUE
	d	TRUE

12:30	A	FALSE
	B	FALSE
	c	FALSE
	d	FALSE
	E	FALSE
	F	FALSE


 */
public class Dummy_IF_KR_ERP_SE_0004_ba extends Dummy_IF_Batch {

    public String query;
    public Boolean isNextBatch = true;

    // 공장재고 Fix Account Id
    private static Id      fixAccountIdForAsset {get;set;}
    // 공장재고 Fix Account OwnerId
    private static Id      fixAccountOwnerIdForAsset {get;set;}

    // 공장재고 Fix Account
    private static Account fixAccountForAsset {get;set;}

    static {
        List<Account> fixAccounts = [SELECT Id, OwnerId FROM Account WHERE Name = '공장재고' AND ERPCode__c = '100000'];
        fixAccountForAsset = fixAccounts.isEmpty() ? null : fixAccounts[0];

         //============================================================================
         // 고정 공장재고의 Account가 없을 경우 에러처리
         //============================================================================
        if(fixAccountForAsset == null) {
            throw new Dummy_IF_BatchUtil.DummyValidException('공장재고 Account 가 존재하지 않습니다. 확인 바랍니다.');
        }

        fixAccountIdForAsset = fixAccountForAsset == null ? null : fixAccountForAsset.Id;
        fixAccountOwnerIdForAsset = fixAccountForAsset == null ? null : fixAccountForAsset.OwnerId;
    }

    // target Product2 맵
    private static Map<String, Product2> productsByProductCode {get;set;}
    static {
        Dummy_IF_KR_ERP_SE_0004_ba.productsByProductCode = Dummy_IF_BatchUtil.getTargetProduct2();
    }

    private Map<String, SObject> disctinctMap = new Map<String, SObject>();
    private List<SObject> duplicatedList = new List<SObject>();

    public Dummy_IF_KR_ERP_SE_0004_ba() {
        this(null);
    }

    public Dummy_IF_KR_ERP_SE_0004_ba(final String query) {
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
        this.interfaceId = 'IF_KR_ERP_SE_0004';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
            'IF_KR_ERP_SE_0004__c',
            interfaceId,
             // 20140414 : Monthly 에서 Daily 로 변경
            Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.DAILY,
            this.exeDatetime
        );

        /*
        ErpWERKS__c		        플랜트	CHAR	    18
        ErpLGORT__c		        저장위치	Text	    20
        ProductCode__c		    제품코드	Text	    20
        Name	            PK	기대번호	Text	    20 <===== 레코드 자동번호로 변경...
        Stock__c		        가용(정품)재고	    Num	18,0
        QiStock__c		        QI재고	            Num	18,0
        ProductionDate__c	    제품생산일(yyyyMMdd)	Text	20

        MachineNo__c            기대번호 ==> 배치번호
        SerialNo__c             기대번호(시리얼번호)
         */

        //============================================================================
        // append 로 데이터가 들어오기 때문에 동일한 dummy 인 machineNo를 기준으로 한건씩만
        // execute로 넘김
        // 중복된 Dummy는 finish에서 일괄 처리 업데이트 함 (재고가 일일기준 몇건이 안될것임.)
        //============================================================================
        String machineNo;
        for(IF_KR_ERP_SE_0004__c dummy : [
            SELECT  Id, MachineNo__c
            FROM    IF_KR_ERP_SE_0004__c
            WHERE   InterfaceId__c = :this.interfaceId
            AND     isBatchCompleted__c = FALSE
            AND     isBatchError__c = FALSE
            ORDER BY CreatedDate DESC
        ]) {
            machineNo = dummy.MachineNo__c;
            if(!disctinctMap.containsKey(machineNo)) {
                disctinctMap.put(machineNo, dummy);
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
                            MachineNo__c,
                            SerialNo__c,
                            ErpLGORT__c,
                            ErpWERKS__c,
                            Id,
                            InterfaceId__c,
                            Name,
                            ProductCode__c,
                            ProductionDate__c,
                            QiStock__c,
                            Stock__c,
                            isBatchCompleted__c,
                            isBatchError__c,
                            BatchErrorMessage__c
                    FROM  IF_KR_ERP_SE_0004__c
                    WHERE Id IN :this.disctinctMap.values()
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
        final List<IF_KR_ERP_SE_0004__c> scope = (List<IF_KR_ERP_SE_0004__c>)targetScope;

        /*
         * 공장재고가 수신되면 기대번호 기준으로 Asset Upsert
             1) Account : 고객명=공장재고, ERPCode__c = 100000 데이터 이용 Account lookup
             2) Name : Name move
             3) Product2 : ProductCode__c 이용하여 제품 Lookup
             4) ProductionDate__c : ProductionDate__c move
             5) InventoryType__c : Stock__c>0 이면 "공장재고(가용)", QiStock__c>0 이면 "공장재고(QI)"
             6) ErpLGORT__c : ErpLGORT__c 세팅
         ----------------------------------------------------------------------------------------
         *
         */

        //============================================================================
        // MachineNo(기대번호) 기준 Dummy 맵
        //============================================================================
        String tmpMachineNo;
        Map<String, IF_KR_ERP_SE_0004__c> DummyByMachineNo = new Map<String, IF_KR_ERP_SE_0004__c>();
        for(IF_KR_ERP_SE_0004__c dummy : scope) {
            tmpMachineNo = dummy.MachineNo__c;
            if(String.isNotBlank(tmpMachineNo) && !DummyByMachineNo.containsKey(tmpMachineNo)) {
                DummyByMachineNo.put(tmpMachineNo, dummy);
            }
        }

        //============================================================================
        // 존재하는 Name 기준 이미 생성된 Asset 맵
        //============================================================================
        String assetName;
        Map<String, Asset> AssetByName = new Map<String, Asset>();
        for(Asset asset : [
            SELECT  Id,
                    Name,           // 일련번호
                    BatchNo__c,     // 배치번호
                    Product2Id,
                    ProductionDate__c,
                    InventoryType__c,
                    ErpLGORT__c,
                    Brand__c
            FROM    Asset
            WHERE   BatchNo__c IN :DummyByMachineNo.keySet()
        ]) {
            assetName = asset.BatchNo__c;
            if(!AssetByName.containsKey(assetName)) {
                AssetByName.put(assetName, asset);
            }
        }

        //============================================================================
        // SObject 로는 upsert 가 불가. 따라서 insert, update 분리 처리
        //============================================================================
        List<SObject> targetInstList = new List<SObject>();
        List<SObject> targetUpdList = new List<SObject>();
        // validation 처리시 비정상 Dummy Data List
        List<SObject> targetBadDummyList = new List<SObject>();
        // Dml 수행 에러 Dummy Data List
        List<SObject> targetDmlDummyList = new List<SObject>();

        Asset tmpAsset, tmpExistAsset;
        Product2 tmpProduct;
        String tmpProductCode;
        Boolean isExistRecord, isGoodDummy, isGoodProductDate;
        Date tmpProductDate;
        List<String> errorComments = new List<String>();
        /*
         * ================================================================
         * 대상건 : Name은 무조건 존재하니 전체 데이터가 대상건임
         * ================================================================
         */
        for(IF_KR_ERP_SE_0004__c dummy : scope) {
            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            dummy.isBatchCompleted__c = true;

            //============================================================================
            // Asset의 Name 과 매핑이 되므로 required.
            //============================================================================
            tmpMachineNo = dummy.MachineNo__c;

            //============================================================================
            // 제품코드
            // 실제 제품은 객체형식으로 주입하므로 dml 주입시에 없으면 에러발생
            // 일단 productCode를 lpad 하여 처리
            //============================================================================
            tmpProductCode = Dummy_IF_BatchUtil.getProductCodeLpad(dummy.ProductCode__c);
            tmpProduct = Dummy_IF_KR_ERP_SE_0004_ba.productsByProductCode.get(tmpProductCode);

            //============================================================================
            // 날짜 형식 체크
            //============================================================================
            isGoodProductDate = true;

            try {
                tmpProductDate = String.isNotBlank(dummy.ProductionDate__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.ProductionDate__c) : null;
            }
            catch(Exception e) {
                isGoodProductDate = false;
            }

            //============================================================================
            // 기존 데이터 존재 여부 판단
            //============================================================================
            tmpExistAsset = AssetByName.get(tmpMachineNo);
            isExistRecord = tmpExistAsset != null ? true : false;

            //============================================================================
            // 정상 Dummy 데이터 여부
            // 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]
            //============================================================================
            isGoodDummy = String.isNotBlank(tmpProductCode) && (tmpProduct != null) && String.isNotBlank(tmpMachineNo) && isGoodProductDate;

            errorComments = new List<String>();
            if(isGoodDummy == false) {
                if(String.isBlank(dummy.ProductCode__c) || (dummy.ProductCode__c == null)) errorComments.add('Dummy ProductCode 값 없음');
                if(String.isBlank(dummy.SerialNo__c)) errorComments.add('Dummy SerialNo 값 없음');
                if(String.isBlank(dummy.MachineNo__c)) errorComments.add('Dummy MachineNo 값 없음');
                if(isGoodProductDate == false) errorComments.add('Dummy 날짜오류 = ['+dummy.ProductionDate__c+']');

                dummy.BatchErrorComment__c = String.join(errorComments, ', ');

                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                    dummy,
                    String.format(
                        Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                        new String[]{'ProductCode__c or 매핑 Product2 or MachineNo__c or ProductDate__c'}
                    ),
                    this.errorDummyIds
                ));

                continue;
            }

            //============================================================================
            // 신규 데이터인 경우
            // 1. OwnerId를 공장재고 Account의 OwnerId로 세팅
            // 2. 재고유형의 분리 처리
            //============================================================================
            if(isExistRecord == false) {
                targetInstList.add(tmpAsset = new Asset(
                    OwnerId = fixAccountOwnerIdForAsset,
                    // 신규인 경우 stock__c 와 QiStorc__c 의 값을 비교하여 유형 세팅
                    InventoryType__c    = (dummy.Stock__c > 0) ? '공장재고(가용)' : ((dummy.QiStock__c > 0) ? '공장재고(QI)' : null),
                    AccountId           = Dummy_IF_KR_ERP_SE_0004_ba.fixAccountIdForAsset,
                    Dealer__c           = null,
                    Customer__c         = null,
                    Name                = dummy.SerialNo__c,
                    BatchNo__c          = tmpMachineNo,
                    Product2Id          = tmpProduct.Id,
                    ProductionDate__c   = tmpProductDate,
                    ErpLGORT__c         = dummy.ErpLGORT__c
//                    Brand__c            = 'LS',
//                    FilterText__c       = tmpProduct.Name,
//                    AssetNumber__c      = tmpMachineNo
                ));
            }
            //============================================================================
            // 기존 데이터인 경우
            //============================================================================
            else {
                targetUpdList.add(tmpAsset = tmpExistAsset);
                // 기존인 경우 기존 재고유형이 공장재고(QI) 이고 dummy Stock__c > 0 보다 큰 경우만 공장재고(가용) 으로 세팅
                // 20140414 수정 : 신규와 동일 로직으로 변경
                //tmpAsset.InventoryType__c  = (tmpAsset.InventoryType__c == '공장재고(QI)' && (dummy.Stock__c > 0)) ? '공장재고(가용)' : tmpAsset.InventoryType__c;
                tmpAsset.InventoryType__c  = (dummy.Stock__c > 0) ? '공장재고(가용)' : ((dummy.QiStock__c > 0) ? '공장재고(QI)' : null);
                // ERP 저장 위치
                tmpAsset.ErpLGORT__c       = dummy.ErpLGORT__c;
            }

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
            insert targetInstList;

            //============================================================================
            // 공장재고 Asset에 해당날짜에 생성되었다는 의미의 task 생서
            // 따라서 task의 OwnerId는 배치수행 User로 할당됨.
            //============================================================================
            List<Task> newAssetTasks = new List<Task>();

            for(Asset asset: (List<Asset>)targetInstList) {
                newAssetTasks.add(new Task(
                    WhatId = asset.Id,
                    Subject = '생산입고',
                    Status = 'Completed',
                    ActivityDate = asset.ProductionDate__c
                ));
            }

            insert newAssetTasks;

            //============================================================================
            // 데이터가 append로 들어오기 때문에 dup발생. Id로 Map하여 values만 update 처리
            // start에서 MachineNo 기준으로 distinct 되어 들어와 중복될 일이 없지만, 혹시나 해서
            // Map으로 재구성함
            // 바로 map 구성시 에러발생 : putAll 하여 중복 제거
            //============================================================================
            if(targetUpdList.isEmpty() == false) {
                Map<Id, SObject> distinctMapForTargetUpdList = new Map<Id, SObject>();
                distinctMapForTargetUpdList.putAll(targetUpdList);
                update distinctMapForTargetUpdList.values();
            }
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
        super.finish(BC);
        if(this.isNextBatch && this.duplicatedList.size() > 0)    Database.executeBatch(new Dummy_IF_KR_ERP_SE_0004_2_ba(this.duplicatedList), 2000);
    }

}