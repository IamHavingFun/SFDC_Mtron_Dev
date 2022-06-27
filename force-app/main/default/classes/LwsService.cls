/****************************************************************************************
  * @filename      : LwsService
  * @projectname   : 
  * @author        : i2max 
  * @date          : 2020-07-02 오후 5:24
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LwsService_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-02 오후 5:24       i2max                  Create
*************a***************************************************************************/
public without sharing class LwsService {

    /**
     * @description : IF_KR_SE_LWS_0018 Warranty 등록 (SE <-> ERP)
     *                SE(모바일) 화면에서 입력된 실판매 정보(PDI + 고객 정보)를 LWS에 실시간 송신
     *                대리점에서 실판매된 정보를 LWS 등록
     *
     * @param recordId : PDI ID
     * @param recordId : ContentVersion ID
     *
     * @return
     */
    public static Map<String, String> IF_KR_SE_LWS_0018(String recordId, String contentVersionId) {

        Map<String, String> returnMap = new Map<String, String>();

        List<PDI__c> pdis = [
                SELECT  Id,
                        Asset__c,
                        Asset__r.Name,          // 기대번호
                        Asset__r.Dealer__r.ERPCode__c,          // 대리점.ERPCode
                        Asset__r.Dealer__r.ErpName__c,          // 대리점명
                        HandoverDate__c,
                        Consumer__c,
                        Consumer__r.Name,
                        Consumer__r.IsCUPI__pc,
                        Consumer__r.fm_Mobile__c,
                        Consumer__r.Phone,
                        Consumer__r.Fax,
                        Consumer__r.fm_Email__c,
                        Consumer__r.BillingPostalCode,
                        Consumer__r.BillingState,
                        Consumer__r.BillingCity,
                        Consumer__r.BillingStreet,
                        Consumer__r.FarmingForm__c,
                        Consumer__r.ErpName__c,
                        Consumer__r.ErpCode__c,
                        Consumer__r.LWSNo__c,
                        Contract__c
                FROM PDI__c
                WHERE Id = :recordId
        ];

        PDI__c pdi = null;
        if(pdis.isEmpty() == true && pdis.size() == 0) {
            returnMap.put('STATUS', 'N');
            returnMap.put('MESSAGE', 'PDI 정보가 없습니다.');
            return returnMap;
        } else {
            pdi = pdis[0];
        }

        // PDI 파일
        List<ContentVersion> contentVersions = [SELECT Id, VersionData FROM ContentVersion WHERE Id = : contentVersionId LIMIT 1];
        ContentVersion contentVersion = (contentVersions.size() == 1) ? contentVersions.get(0) : null;

        IF_KR_SE_LWS_0018 instance = IF_KR_SE_LWS_0018.getInstance();
        IF_KR_SE_LWS_0018.InputDIH input = new IF_KR_SE_LWS_0018.InputDIH();
        IF_KR_SE_LWS_0018.INPUT_T_DATA inputTData;
        IF_KR_SE_LWS_0018.OutputDIH result;
        System.debug('pdis:::' + pdis.size());


        Set<String> accountIds = new Set<String>();           // Account Ids
        Set<String> assetNames = new Set<String>();           // Asset Names

        for (PDI__c r : pdis) {
            /*
            -------------------------------------------------------------------- 전송
            Asset__c	        PK	기대번호	Text	20
            HandoverDate__c		    인도일(yyyyMMdd)	Text	10
            Account__c		        고객ID (* 고객을 식별하는 SE 고유 ID)	Text	20
            AccountName__c		    고객명	Text	80
            IsCUPI__pc		        개인정보활용동의여부(TRUE,FALSE)	Text	10
            PersonMobilePhone		핸드폰번호	Text	30
            Phone		            전화번호	Text	30
            Fax		                팩스번호	Text	30
            PersonEmail		        이메일	Text	80
            BillingPostalCode		우편번호	Text	10
            BillingState		    주소-시도	Text	50
            BillingCity		        주소-시군구	Text	50
            BillingStreet		    주소-상세	Text	100
            FarmingForm__c		    영농형태(수도작,전작,과수,축산(일반),하우스(일반),축산(영업),하우스(대형))	Text	80
            PdiFile__c		        PDI 파일(PDF 타입, 1MB 이내)	Text
            DealerName__c		    거래선명(ERP)  Account.ErpName__c	Text	80
            ERPCode__c		        대리점코드(ERP)	Text	20
            LWSNo__c                LWS 고유번호(식별번호)
            -------------------------------------------------------------------- 수신
            	* 고객 데이터 업데이트(기준 : IF.Account__c = Account.ID)
            1)	LWSNo__c		IF.LwsNo


                * 자산 데이터 업데이트(기준 : IF.AssetNo = Asset.Name)
            1)	WtyStartDate__c		IF.WtyStartDate
            2)	WtyEndDate__c		IF.WtyEndDate

             */
            inputTData = new IF_KR_SE_LWS_0018.INPUT_T_DATA();

            inputTData.AssetNo      = r.Asset__r.Name;
            inputTData.SalesDate    = String.valueOf(pdi.HandoverDate__c);
            inputTData.AccountNo    = r.Consumer__c;
            inputTData.AccountName  = r.Consumer__r.Name;
            inputTData.AgreeYn      = String.valueOf(r.Consumer__r.IsCUPI__pc);
            inputTData.PhoneNo      = r.Consumer__r.fm_Mobile__c;
            inputTData.TelNo        = r.Consumer__r.Phone;
            inputTData.FaxNo        = r.Consumer__r.Fax;
            inputTData.Email        = r.Consumer__r.fm_Email__c;
            inputTData.PostNo       = r.Consumer__r.BillingPostalCode;
            inputTData.Address      = r.Consumer__r.BillingState;
            inputTData.Address2     = r.Consumer__r.BillingCity;
            inputTData.Address3     = r.Consumer__r.BillingStreet;
            inputTData.GroundType   = r.Consumer__r.FarmingForm__c;
            inputTData.PdiFile      = EncodingUtil.base64Encode(contentVersion.VersionData);      // 파일 내용 Byte Stream
            inputTData.DealerName   = r.Asset__r.Dealer__r.ErpName__c;        // 대리점.ERPCode
            inputTData.ErpCode      = r.Asset__r.Dealer__r.ERPCode__c;        // 대리점명
            inputTData.LwsNo        = r.Consumer__r.LWSNo__c;
            inputTData.isCreatedByLS  = '';//r.Consumer__r.isCreatedByLS__pc == true ? 'Y' : 'N';      // LS Dream Check.

            // 적재
            input.request.payload.t_data.add(inputTData);

            if (String.isNotBlank(inputTData.AccountNo))    accountIds.add(inputTData.AccountNo);
            if (String.isNotBlank(inputTData.AssetNo))      assetNames.add(inputTData.AssetNo);        // 기대번호

        }
        // Interface Request 실행
        System.debug('input data : '+ JSON.serialize(input));
        if (!input.request.payload.t_data.isEmpty()) {
            // crashTest
            //IF_Base.crashTest = true;
            result = instance.execute(input);
        }

        System.debug('result : ' + result);
        // Interface Response 처리
        if ('S'.equals(result.response.header.ifResult)) {
            //성공 Succeed to Request
            Map<String, Account> accountMap = new Map<String, Account>();
            Map<String, Asset> assetMap = new Map<String, Asset>();

            List<Account> accounts = new List<Account>();
            List<Asset> assets = new List<Asset>();
            List<Task> tasks = new List<Task>();

            System.debug('### outputTdata : ' + result.Response.payload.t_data);
            List<IF_KR_SE_LWS_0018.OUTPUT_T_DATA> outputTdata = result.Response.payload.t_data;

            // Account Map
            for (Account acc : [
                    SELECT Id, LWSNo__c, IsTractorStatus__c, AssetId__c
                    FROM Account
                    WHERE Id IN :accountIds
            ]
            ) {
                if (!accountMap.containsKey(acc.Id)) {
                    accountMap.put(acc.Id, acc);
                }
            }

            // Asset Map
            for (Asset ass : [
                    SELECT Id, Name, Dealer__r.DealerOwner__c, WtyStartDate__c, Customer__c,InventoryType__c,WtyEndDate__c, OwnerId
                    FROM Asset
                    WHERE Name IN :assetNames
            ]
            ) {
                if (!assetMap.containsKey(ass.Name)) {
                    assetMap.put(ass.Name, ass);
                }
            }

            Account tmpAccount;
            Asset tmpAsset;
            Task tmpTask;
            Boolean isGoodResponseData;

            for (IF_KR_SE_LWS_0018.OUTPUT_T_DATA temp : outputTdata) {

                /** ================================================================
                * 정상 Response 데이터 여부
                * LWSNo__c 필수 항목
                * ================================================================*/

                isGoodResponseData = String.isNotBlank(temp.LwsNo);

                if (isGoodResponseData == false) {
                    returnMap.put('STATUS', 'N');
                    returnMap.put('MESSAGE', '필수 리턴 값 : LwsNo IS NULL ');

                } else {
                    // Account 데이터 확인
                    if (accountMap.containsKey(temp.AccountNo)) {
                        tmpAccount = accountMap.get(temp.AccountNo);
                        tmpAccount.LWSNo__c             = temp.LwsNo;
                        tmpAccount.IsTractorStatus__c   = true;
                        tmpAccount.AssetId__c           = pdi.Asset__c;
                        accounts.add(tmpAccount);
                    }

                    // Asset 데이터 확인
                    if (assetMap.containsKey(temp.AssetNo)) {
                        tmpAsset = assetMap.get(temp.AssetNo);
                        tmpAsset.InventoryType__c                   = '실판매'; // 재고유형
                        tmpAsset.Customer__c                        = pdi.Consumer__c; // 실소유자
                        tmpAsset.AccountId                          = pdi.Consumer__c; // 실소유자
                        tmpAsset.PDI__c                             = pdi.Id; // PDI 연결
                        tmpAsset.Contract__c                        = pdi.Contract__c; // 계약 연결
/*
                        tmpAsset.IsSendReceiveItem__c               = false;
                        tmpAsset.SendReceiveSpecifiedDate__c        = null;
                        tmpAsset.DateSendReceiveExcept__c           = null;
                        tmpAsset.CondSendReceiveExcept__c           = '';
                        tmpAsset.NumSendReceiveExcept__c            = 0;
                        tmpAsset.TransferOrder__c                   = null;
*/
                        tmpAsset.WtyStartDate__c                    = String.isNotBlank(temp.WtyStartDate) ? Dummy_IF_BatchUtil.getIFDate(temp.WtyStartDate) : null;
                        tmpAsset.WtyEndDate__c                      = String.isNotBlank(temp.WtyEndDate) ? Dummy_IF_BatchUtil.getIFDate(temp.WtyEndDate) : null;
                        assets.add(tmpAsset);

                        tmpTask = new Task();
                        tmpTask.WhatId = tmpAsset.Id;
                        tmpTask.Subject = '고객인도';
                        tmpTask.Status = 'Completed';
                        tmpTask.ActivityDate = pdi.HandoverDate__c;
                        tmpTask.OwnerId = tmpAsset.OwnerId;
                        tasks.add(tmpTask);

                        Task newTask = new Task();
                        newTask.OwnerId = tmpAsset.Dealer__r.DealerOwner__c;
                        newTask.ActivityDate = System.today();
                        newTask.Type__c='Guide';
                        newTask.WhatId = pdi.Id;
                        newTask.Subject = '[LWS 등록]';
                        newTask.Description =   pdi.Consumer__r.Name + '고객의 기대 정보가 LWS에 등록 되었습니다.('+tmpAsset.Name+')';
                        newTask.CustomAlert__c = true;
                        newTask.Status = 'Completed';
                        tasks.add(newTask);

                    }
                    returnMap.put('STATUS', 'Y');
                    returnMap.put('MESSAGE', '');
                }


                //============================================================================
                // 변경된 작업분
                //============================================================================

                // Asset 데이터 확인
                if (assetMap.containsKey(temp.AssetNo)) {
                    tmpAsset = assetMap.get(temp.AssetNo);
                    tmpAsset.InventoryType__c                   = '실판매'; // 재고유형
                    tmpAsset.Customer__c                        = pdi.Consumer__c; // 실소유자
                    tmpAsset.AccountId                          = pdi.Consumer__c; // 실소유자
                    tmpAsset.PDI__c                             = pdi.Id; // PDI 연결
                    tmpAsset.Contract__c                        = pdi.Contract__c; // 계약 연결
                    tmpAsset.WtyStartDate__c                    = String.isNotBlank(temp.WtyStartDate) ? Dummy_IF_BatchUtil.getIFDate(temp.WtyStartDate) : null;
                    tmpAsset.WtyEndDate__c                      = String.isNotBlank(temp.WtyEndDate) ? Dummy_IF_BatchUtil.getIFDate(temp.WtyEndDate) : null;
                    assets.add(tmpAsset);

                    tmpTask = new Task();
                    tmpTask.WhatId = tmpAsset.Id;
                    tmpTask.Subject = '고객인도';
                    tmpTask.Status = 'Completed';
                    tmpTask.ActivityDate = pdi.HandoverDate__c;
                    tmpTask.OwnerId = tmpAsset.OwnerId;
                    tasks.add(tmpTask);

                    Task newTask = new Task();
                    newTask.OwnerId = tmpAsset.Dealer__r.DealerOwner__c;
                    newTask.ActivityDate = System.today();
                    newTask.Type__c='Guide';
                    newTask.WhatId = pdi.Id;
                    newTask.Subject = '[LWS 등록]';
                    newTask.Description =   pdi.Consumer__r.Name + '고객의 기대 정보가 LWS에 등록 되었습니다.('+tmpAsset.Name+')';
                    newTask.CustomAlert__c = true;
                    newTask.Status = 'Completed';
                    tasks.add(newTask);


                    // Account 데이터 확인
                    if (accountMap.containsKey(tmpAsset.AccountId)) {
                        tmpAccount = accountMap.get(tmpAsset.AccountId);
                        tmpAccount.IsTractorStatus__c   = true;
                        tmpAccount.AssetId__c           = pdi.Asset__c;
                        accounts.add(tmpAccount);
                    }

                }
                returnMap.put('STATUS', 'Y');
                returnMap.put('MESSAGE', '');

            }
            System.debug('### accounts : '+accounts + ' ::: ' + accounts.size());
            System.debug('### assets : '+assets + ' ::: ' + assets.size());


            /*
             * ================================================================
             * Dml 수행 : 에러시 STATUS, MESSAGE 상태값 리턴
             * ================================================================
             */
            try {
                if(accounts.isEmpty() == false && accounts.size() > 0)       update accounts;
                if(assets.isEmpty() == false && assets.size() > 0)           update assets;
                if(tasks.isEmpty() == false && tasks.size() > 0)             insert tasks;
            }
            catch(Exception e) {
                returnMap.put('STATUS', 'N');
                returnMap.put('MESSAGE', 'I/F 처리중 오류 발생 : ' + e.getMessage());
                System.debug(System.LoggingLevel.ERROR, '::::: ERROR LOG ' + e);
            }

        } else {
            //실패 Failed to Request
            returnMap.put('STATUS', 'N');
            returnMap.put('MESSAGE', 'Failed to Request : ' + result.response.header.ifFailMsg);
            System.debug(System.LoggingLevel.ERROR, '::::: Failed to Request ' + result.response.header.ifFailMsg);
        }
        return returnMap;
    }


    /**
     * @description : IF_KR_SE_LWS_0021 Warranty 청구 등록 (SE <-> ERP)
     *                SE(모바일) 화면에서 입력된 기대번호 정보를 LWS에 실시간 송신(워런티 청구 임시 저장)
     *                대리점에서 Warranty 청구 요청하는 정보 등록
     *
     * @param recordId : WarrantyClaim ID
     *
     * @return
     */
    public static Map<String, String> IF_KR_SE_LWS_0021(String recordId) {

        Map<String, String> returnMap = new Map<String, String>();

        WarrantyClaim__c wc = [
                SELECT
                        AssetId__r.Name,
                        AssetId__r.BatchNo__c,
                        Customer__c,
                        Customer__r.Name,
                        Dealer__c,
                        Dealer__r.ErpName__c,
                        fm_DealerErpCode__c,
                        fm_ProductCode__c,
                        ProductId__r.ProductType__c,
                        Id,
                        ClaimNo__c,
                        Externalkey__c
                FROM WarrantyClaim__c
                WHERE Id = :recordId
        ];

        IF_KR_SE_LWS_0021 instance = IF_KR_SE_LWS_0021.getInstance();
        IF_KR_SE_LWS_0021.InputDIH input = new IF_KR_SE_LWS_0021.InputDIH();
        IF_KR_SE_LWS_0021.INPUT_T_DATA inputTData;
        IF_KR_SE_LWS_0021.OutputDIH result;

        /*
        -------------------------------------------------------------------- 전송
        Asset__c	    PK	기대번호	                                Text	20
        Account__c		    고객ID (* 고객을 식별하는 SE 고유 ID)	    Text	20
        AccountName__c		고객명	                                Text	80
        Dealer__c		    대리점ID (* 대리점을 식별하는 SE 고유 ID)	Text	20
        DealerName__c		거래선명(ERP)  Account.ErpName__c	    Text	80
        ERPCode__c		    대리점ERP코드	                            Text	20
        ProductCode__c		제품코드 (ERP 자재코드)	                Text	30
        ProductType__c		기종명	                                Text	50
        WarrantyClaimId__c	클레임ID (* 클레임을 식별하는 SE 고유 ID)	Text	20
        ClaimNo             클레임번호
        -------------------------------------------------------------------- 수신
        * 인터페이스 회신 값을 이용하여 WarrantyClaim__c 업데이트
            기준 : IF.WarrantyClaimId = WarrantyClaim__c.Id
        1)	ClaimNo__c		    IF.ClaimNo__c
        2)	LWSSendStatus__c	"기본정보전송" 설정
        */

        inputTData = new IF_KR_SE_LWS_0021.INPUT_T_DATA();

        inputTData.AssetNo          = wc.AssetId__r.BatchNo__c;       // 기대번호
        inputTData.AccountId        = wc.Customer__c;
        inputTData.AccountName      = wc.Customer__r.Name;
        inputTData.DealerId         = wc.Dealer__c;
        inputTData.DealerName       = wc.Dealer__r.ErpName__c;
        inputTData.ErpCode          = wc.fm_DealerErpCode__c;
        inputTData.ProductCode      = wc.fm_ProductCode__c;
        inputTData.ProductType      = wc.ProductId__r.ProductType__c;
        inputTData.WarrantyClaimId  = wc.Id;
        inputTData.ClaimNo          = wc.ClaimNo__c;

        // 적재
        input.request.payload.t_data.add(inputTData);

        // Interface Request 실행
        System.debug('result input : '+ JSON.serialize(input));
        if (!input.request.payload.t_data.isEmpty()) {
            // crashTest
            //IF_Base.crashTest = true;
            result = instance.execute(input);
        }

        System.debug('result : ' + result);
        // Interface Response 처리
        if ('S'.equals(result.response.header.ifResult)) {
            //성공 Succeed to Request

            System.debug('### outputTdata : ' + result.Response.payload.t_data);
            List<IF_KR_SE_LWS_0021.OUTPUT_T_DATA> outputTdata = result.Response.payload.t_data;

            Boolean isGoodResponseData;

            // 배열로 처리 되지만 처리는 한건 처리이다.
            for (IF_KR_SE_LWS_0021.OUTPUT_T_DATA temp : outputTdata) {
                /** ================================================================
                * 정상 Response 데이터 여부
                * ClaimNo, AssetNo 필수 항목
                * ================================================================*/
                System.debug('### warrantyClaims : '+ temp.ClaimNo + '|' + temp.AssetNo);
                isGoodResponseData = string.isNotBlank(temp.ClaimNo)
                                  && string.isNotBlank(temp.AssetNo);

                if (isGoodResponseData == false) {
                    returnMap.put('STATUS', 'N');
                    returnMap.put('MESSAGE', '필수 리턴 값 : ClaimNo IS NULL ');

                    wc.LWSSendStatus__c   = '기본정보전송오류';
                } else {
                    returnMap.put('STATUS', 'Y');
                    returnMap.put('MESSAGE', '');

                    // WarrantyClaim__c 데이터 확인
                    wc.Externalkey__c     = temp.ClaimNo+'|'+temp.AssetNo;
                    wc.ClaimNo__c         = temp.ClaimNo;
                    wc.LWSSendStatus__c   = '기본정보전송';
                }
            }
        } else {
            //실패 Failed to Request
            returnMap.put('STATUS', 'N');
            returnMap.put('MESSAGE', 'Failed to Request : ' + result.response.header.ifFailMsg);

            wc.LWSSendStatus__c = '기본정보전송오류';

            System.debug(System.LoggingLevel.ERROR, '::::: Failed to Request ' + result.response.header.ifFailMsg);
        }
        System.debug('========================================');
        System.debug(JSON.serialize(wc));
        System.debug('========================================');
        update wc;

        return returnMap;
    }


    /**
     * @description : IF_KR_SE_LWS_0022 Warranty 청구 등록 (SE -> ERP)
     *                SE(모바일) 화면에서 입력된 사진 정보를 LWS에 실시간 송신(워런티 청구 임시 저장)
     *                대리점에서 Warranty 청구 요청하는 정보 등록
     *
     * @param assetName : 기대번호
     * @param claimNo  : 클레임 번호
     * @param contentVersionId : ContentVersionId
     * @param seq : ContentVersionId : 사진순번
     * @return
     */
    // LwsService.IF_KR_SE_LWS_0022('a1L1m0000000MMhEAM', '06A1m000000Hg5OEAS');
    public static Map<String, String> IF_KR_SE_LWS_0022(String assetName, String claimNo, String contentVersionId, String seq) {

        Long timeTemp;
        timeTemp = System.currentTimeMillis();
        System.debug(System.LoggingLevel.INFO, '::::: START :::::'+ DateTime.newInstance(timeTemp));

        Map<String, String> returnMap = new Map<String, String>();

        ContentVersion cv = [
                SELECT Id,
                       FileExtension,
                       VersionData
                FROM ContentVersion
                WHERE Id = :contentVersionId
        ];

        IF_KR_SE_LWS_0022 instance = IF_KR_SE_LWS_0022.getInstance();
        IF_KR_SE_LWS_0022.InputDIH input = new IF_KR_SE_LWS_0022.InputDIH();
        IF_KR_SE_LWS_0022.INPUT_T_DATA inputTData;
        IF_KR_SE_LWS_0022.OutputDIH result;
        //System.debug('wcs:::' + wcs.size());

        /*
        -------------------------------------------------------------------- 전송
        Asset__c	        PK	기대번호	            Text	20
        ClaimNo__c	        PK	클레임번호	        Text	20
        ImageTypeName__c		사진유형명 - PNG	    Text	50
        ImageFile__c		    사진 파일(5MB 이내)	Text	6000000
        Seq		                사진 순번	        Text	5
        */
        inputTData = new IF_KR_SE_LWS_0022.INPUT_T_DATA();

        inputTData.AssetNo      = assetName;       // 기대번호
        inputTData.ClaimNo      = claimNo;
        inputTData.ImgTypeName  = cv.FileExtension;
        inputTData.ImgFile      = EncodingUtil.base64Encode(cv.VersionData);    // 파일 내용 Byte Stream
        inputTData.Seq          = seq;

        // 적재
        System.debug(System.LoggingLevel.INFO, 'inputTData : ' + EncodingUtil.base64Encode(cv.VersionData).length());
        input.request.payload.t_data.add(inputTData);

        // Interface Request 실행
        System.debug('result input : '+ JSON.serialize(input));

        if (!input.request.payload.t_data.isEmpty()) {
            // crashTest
            //IF_Base.crashTest = true;
            result = instance.execute(input);
        }

        System.debug('result : ' + result);
        // Interface Response 처리
        if ('S'.equals(result.response.header.ifResult)) {
            //성공 Succeed to Request
            returnMap.put('STATUS', 'Y');
            returnMap.put('MESSAGE', '');
        } else {
            //실패 Failed to Request
            returnMap.put('MESSAGE', 'Failed to Request : ' + result.response.header.ifFailMsg);
            returnMap.put('STATUS', 'N');
            System.debug(System.LoggingLevel.ERROR, '::::: Failed to Request ' + result.response.header.ifFailMsg);
        }

        System.debug(System.LoggingLevel.INFO, '::::: END :::::'+ DateTime.newInstance(System.currentTimeMillis()));
        System.debug(System.LoggingLevel.INFO, '::::: END :::::'+ (System.currentTimeMillis() - timeTemp));

        return returnMap;
    }


    /*public static Map<String, String> IF_KR_SE_LWS_0022(String recordId) {
        Map<String, String> returnMap = new Map<String, String>();

        List<WarrantyClaim__c> wcs = [
                SELECT
                        Id,
                        AssetId__r.Name,
                        ClaimNo__c
                FROM WarrantyClaim__c
                WHERE Id = :recordId
        ];

        // 사진 파일
        List<ContentDocumentLink> cdls = [
                SELECT Id,
                        ContentDocument.LatestPublishedVersion.Id,
                        ContentDocument.Title,
                        ContentDocument.FileType,
                        ContentDocument.ContentSize,
                        ContentDocument.LatestPublishedVersion.VersionData
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId

        ];

        IF_KR_SE_LWS_0022 instance = IF_KR_SE_LWS_0022.getInstance();
        IF_KR_SE_LWS_0022.InputDIH input = new IF_KR_SE_LWS_0022.InputDIH();
        IF_KR_SE_LWS_0022.INPUT_T_DATA inputTData;
        IF_KR_SE_LWS_0022.OutputDIH result;
        //System.debug('wcs:::' + wcs.size());

        for (WarrantyClaim__c wc : wcs) {
            *//*
            -------------------------------------------------------------------- 전송
            Asset__c	        PK	기대번호	            Text	20
            ClaimNo__c	        PK	클레임번호	        Text	20
            ImageTypeName__c		사진유형명 - PNG	    Text	50
            ImageFile__c		    사진 파일(5MB 이내)	Text	6000000
            *//*

            inputTData = new IF_KR_SE_LWS_0022.INPUT_T_DATA();

            inputTData.AssetNo = wc.AssetId__r.Name;       // 기대번호
            inputTData.ClaimNo = wc.ClaimNo__c;

            input.request.payload.ifAggregation = IF_LWS_Base.giveAGGR();

            Integer i = 1;
            for (ContentDocumentLink cdl : cdls) {
                inputTData.ImgTypeName = cdl.ContentDocument.FileType;
                inputTData.ImgFile     = EncodingUtil.base64Encode(cdl.ContentDocument.LatestPublishedVersion.VersionData);    // 파일 내용 Byte Stream

                input.request.payload.ifTotCnt      = String.valueOf(cdls.size());
                input.request.payload.ifSplitCnt    = String.valueOf(cdls.size());
                input.request.payload.ifSplitSeq    = String.valueOf(i);

                // 적재
                input.request.payload.t_data.add(inputTData);

                // Interface Request 실행
                System.debug('result input : '+ JSON.serialize(input));


                if (!input.request.payload.t_data.isEmpty()) {
                    // crashTest
                    //IF_Base.crashTest = true;
                    result = instance.execute(input);
                }

                System.debug('result : ' + result);
                // Interface Response 처리
                if ('S'.equals(result.response.header.ifResult)) {
                    //성공 Succeed to Request
                    returnMap.put('STATUS_'+i, 'Y');
                    returnMap.put('MESSAGE_'+i, '');
                } else {
                    //실패 Failed to Request
                    returnMap.put('MESSAGE_'+i, 'Failed to Request : ' + result.response.header.ifFailMsg);
                    returnMap.put('STATUS_'+i, 'N');
                    System.debug(System.LoggingLevel.ERROR, '::::: Failed to Request ' + result.response.header.ifFailMsg);
                }
                i++;
            }
        }
        System.debug(System.LoggingLevel.INFO, '::::: INFO LOG :::::'+ returnMap);
        return returnMap;
    }*/

}