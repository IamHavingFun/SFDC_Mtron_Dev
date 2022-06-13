/****************************************************************************************
  * @filename      : Dummy_IF_KR_SE_LWS_0035_ba
  * @projectname   : 
  * @author        : i2max 
  * @date          : 2020-07-06
  * @group         : 
  * @group-content : 
  * @description   : [LWS 고객정보 전송]
  *                : SE와 LWS간 고객(개인고객, 영농법인)정보 공유
  *                : SE에서 전일 변경이 발생한 고객(개인고객, 영농법인) 데이터를 LWS에 일괄 전송
  * @tester        : Dummy_IF_KR_SE_LWS_0035_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-06               i2max                  Create
    0.2     2021-05-29               i2max               LWS NO 처리 삭제
*************a***************************************************************************/

/**
    //실행 (오늘 날짜)
    Database.executeBatch(new Dummy_IF_KR_SE_LWS_0035_ba(), 200);

    //실행 (날짜 지정)
    Dummy_IF_KR_SE_LWS_0035_ba batch = new Dummy_IF_KR_SE_LWS_0035_ba('select id from account limit 1');
    Database.executeBatch(batch, 200);

    id = '0011m00000DLxarAAD'
*/

public with sharing class Dummy_IF_KR_SE_LWS_0035_ba extends Dummy_IF_Batch implements Database.AllowsCallouts{

    public String query;
    public Boolean isNextBatch = true;

    public Dummy_IF_KR_SE_LWS_0035_ba() {
        this(null);

    }

    public Dummy_IF_KR_SE_LWS_0035_ba(final String query) {
        this(query, true);
    }

    public Dummy_IF_KR_SE_LWS_0035_ba(final String query, final Boolean isNextBatch) {
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
        /*
        	* Account의 변경 데이터를 추출(매일 저녁 23:00 기준 추출)
            1)	변경일 = 당일
            2)	CustomerType__c	= "개인고객" or "영농법인"
        */
        System.debug(System.LoggingLevel.INFO, 'BaseDateTime : ' + System.today());


        /*
        * 7/23 테스트 데이터
            (LWS 등록 고객 : 고객정보 변경 or 신규 구매 처리)
            ID                 이름   LWSNo__c
            0011m00000DvdxzAAB 도태순 636034
            0011m00000Dvdy0AAB 박영운 636374
            0011m00000Dvdy1AAB 신완철 636429
            0011m00000Dvdy2AAB 안광조 636206
            0011m00000Dvdy3AAB 안혁기 636240

            (LWS 미등록 고객 - 신규 구매 고객)
            홍길순1
            홍길순2
            홍길순3
            홍길순4
            홍길순5

            @최선웅 과장님
            LWS에서 신규 구매처리 가능한 기대번호 목록 제공 바랍니다.
        */
        Set<String> customerTypes = new Set<String>{
                '자영농',
                '영업농',
                '농업법인',
                '기타법인'
        };
        if(String.isNotBlank(this.query)) {
            return Database.getQueryLocator(this.query);
        } else {
            return Database.getQueryLocator([
                    SELECT
                            Id
                    FROM Account
                    WHERE CustomerType__c IN : customerTypes
                    AND LastModifiedDate >= :System.today()
                    AND CustomerStatus__c = '실고객'
                    //AND LWSNo__c != NULL
                    //AND Id = '0011m00000DLxarAAD'
            ]);
        }
    }

    public override void execute(Database.BatchableContext BC, List<SObject> targetScope) {
        System.debug(System.LoggingLevel.INFO, 'execute ');

        //============================================================================
        // 실제 SObject 형변환
        //============================================================================
        final List<Account> scope = (List<Account>)targetScope;
        Set<String> accountIdSet = new Set<String>();

        for(Account dummy : scope) {
            accountIdSet.add(dummy.Id);
        }

        List<Asset> assets = [
                SELECT
                        Id,
                        Name,
                        BatchNo__c,
                        Account.Id,
                        Account.Name,
                        Account.IsCUPI__pc,
                        Account.fm_Mobile__c,
                        Account.Phone,
                        Account.Fax,
                        Account.fm_Email__c,
                        Account.BillingPostalCode,
                        Account.BillingState,
                        Account.BillingCity,
                        Account.BillingStreet,
                        Account.FarmingForm__c,
                        Account.Dealer__r.ErpName__c,
                        Account.Dealer__r.ERPCode__c
                FROM    Asset
                WHERE   AccountId IN :accountIdSet
        ];

        IF_KR_SE_LWS_0035 instance = IF_KR_SE_LWS_0035.getInstance();
        IF_KR_SE_LWS_0035.InputDIH input = new IF_KR_SE_LWS_0035.InputDIH();
        IF_KR_SE_LWS_0035.INPUT_T_DATA inputTData;
        IF_KR_SE_LWS_0035.OutputDIH result;

        for(Asset dummy : assets){
            /*
            -------------------------------------------------------------------- 전송
            Account__c		    고객ID (* 고객을 식별하는 SE 고유 ID)	Text	20
            AccountName__c		고객명	                            Text	80
            IsCUPI__pc		    개인정보활용동의여부(TRUE,FALSE)	    Text	10
            PersonMobilePhone	핸드폰번호	                        Text	30
            Phone		        전화번호	                            Text	30
            Fax		            팩스번호	                            Text	30
            PersonEmail		    이메일	                            Text	80
            BillingPostalCode	우편번호	                            Text	10
            BillingState		주소-시도	                        Text	50
            BillingCity		    주소-시군구	                        Text	50
            BillingStreet		주소-상세	                        Text	100
            FarmingForm__c		영농형태(수도작,전작,과수,축산(일반),하우스(일반),축산(영업),하우스(대형))	Text	80
            DealerName__c		거래선명(ERP)  Account.ErpName__c	Text	80
            ERPCode__c		    대리점코드(ERP)	                    Text	20
            LWSNo__c		    LWS 고유번호	                        Text	50
            AssetNo             기대번호
            isCreatedLS         LS Dream 고객 여부.
            */

            inputTData = new IF_KR_SE_LWS_0035.INPUT_T_DATA();

            inputTData.Account              = dummy.Account.Id;
            inputTData.AccountName          = dummy.Account.Name;
            inputTData.IsCUPI               = dummy.Account.IsCUPI__pc == true ? 'TRUE' : 'FALSE';
            inputTData.PersonMobilePhone    = dummy.Account.fm_Mobile__c;
            inputTData.Phone                = dummy.Account.Phone;
            inputTData.Fax                  = dummy.Account.Fax;
            inputTData.PersonEmail          = dummy.Account.fm_Email__c;
            inputTData.BillingPostalCode    = dummy.Account.BillingPostalCode;
            inputTData.BillingState         = dummy.Account.BillingState;
            inputTData.BillingCity          = dummy.Account.BillingCity;
            inputTData.BillingStreet        = dummy.Account.BillingStreet;
            inputTData.FarmingForm          = dummy.Account.FarmingForm__c;
            inputTData.DealerName           = dummy.Account.Dealer__r.ErpName__c;
            inputTData.ERPCode              = dummy.Account.Dealer__r.ERPCode__c;
            inputTData.LWSNo                = '';   // LWSNO 는 LWS 시스템에서 사용하지 않기로 함.
            inputTData.AssetNo              = dummy.BatchNo__c;     //dummy.Name; 시리얼 번호
            inputTData.isCreatedByLS        = 'N';  //dummy.Account.isCreatedByLS__pc == true ? 'Y' : 'N';
            // ITVOC-2021-12-0592 : 2021/12/02

            // 적재
            input.request.payload.t_data.add(inputTData);
            //System.debug(System.LoggingLevel.INFO, 'inputTData : ' + inputTData);
        }

        // Interface Request 실행
//        System.debug('result input : '+ JSON.serialize(input));
        if (!input.request.payload.t_data.isEmpty()) {
            // crashTest
            //IF_Base.crashTest = true;
            result = instance.execute(input);
        }

        System.debug('result : ' + result);
        // Interface Response 처리
        if ('S'.equals(result.response.header.ifResult)) {
            //성공 Succeed to Request
            System.debug(System.LoggingLevel.INFO, '::::: Succeed to Request :::::');
        } else {
            //실패 Failed to Request
            System.debug(System.LoggingLevel.ERROR, '::::: Failed to Request ' + result.response.header.ifFailMsg);
        }
    }

    /**
     * 개별적 finish 수행
     * 후행배치가 먼저 수행이 되어야 한다.(에러 상관없이 수행되어야 함.)
     *
     * @param BC Database.BatchableContext
     */
    public override void finish(Database.BatchableContext BC) {
        if(this.isNextBatch) Database.executeBatch(new Dummy_IF_KR_SE_PLM_0037_ba(), 1);
        super.finish(BC);
    }
}