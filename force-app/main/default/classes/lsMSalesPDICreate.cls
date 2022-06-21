/****************************************************************************************
  * @filename      : LsMSalesPDICreate
  * @projectname   : LS
  * @author        : i2max.seo
  * @date          : 2020-06-19 오후 2:11
  * @group         :
  * @group-content :
  * @description   : PDI 등록 및 조회
  * @tester        : LsMSalesPDICreate_ts
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                      author          description
  * ===============================================================
    0.1     2020-06-19 오후 2:11      i2max.seo       Create
****************************************************************************************/
public without sharing class lsMSalesPDICreate {
	/**
	 * @param assetName : Asset Name
	 *
	 * @return LsMSalesStepVO
	 */
	@AuraEnabled
	public static LsMSalesStepVO init(String assetName) {
		return getPDIData(assetName);
	}

    /**
     * 초기 init 시점과 자산 이름으로 검색 시 사용되는 method.
     *
	 * @param assetName : Asset Name
	 *
	 * @return LsMSalesStepVO
	 */
    @AuraEnabled
    public static LsMSalesStepVO getPDIData(String assetName) {
        LsMSalesPDIVO lsMSalesPDIVO = new LsMSalesPDIVO();
        lsMSalesPDIVO.bizData = new lsMSalesPDIVO.BizData();
        lsMSalesPDIVO.bizData.isViewMode = false;

        User UserLoginAcc = [select id, Contact.AccountId from User where Id =:UserInfo.getUserId()]; // 로그인 사용자
        List<Asset> assets = [
		        SELECT Id, Name, BatchNo__c, Dealer__c, AccountId, Account.CustomerType__c, Customer__c, Customer__r.Name, Customer__r.fm_Mobile__c, Account.Name, Account.fm_Mobile__c,
				        OwnerId, Product2Id, Product2.Name, Product2.ProductCode, InventoryType__c,
				        Product2.WarrantyRange__c,
		                (select Id,SalePrice__c from Asset_Price__r)
		        FROM Asset
		        WHERE (Name = :assetName OR BatchNo__c = :assetName) LIMIT 1
        ];
        if(assets.isEmpty()) {
            lsMSalesPDIVO.bizData.asset = new Asset();
            lsMSalesPDIVO.bizData.assetMessage = System.Label.LsMSalesPDICreate_NotFoundMsg;
            return lsMSalesPDIVO;
        } else {
            lsMSalesPDIVO.bizData.asset = assets[0];
            if(!lsMSalesPDIVO.bizData.asset.Asset_Price__r.isEmpty()) lsMSalesPDIVO.bizData.assetPrice = lsMSalesPDIVO.bizData.asset.Asset_Price__r[0];
            if(lsMSalesPDIVO.bizData.asset.InventoryType__c != '대리점재고'){
                lsMSalesPDIVO.bizData.assetMessage = System.Label.LsMSalesPDICreate_InventoryTypeMsg;
                return lsMSalesPDIVO;
            }else if(lsMSalesPDIVO.bizData.asset.Customer__c != null){
                lsMSalesPDIVO.bizData.assetMessage = System.Label.LsMSalesPDICreate_CustomerMsg;
                return lsMSalesPDIVO;
            }
        }

        List<Contract__c> targetContracts = new List<Contract__c>();

	    // TODO : 자산의 고객 정보로 계약을 찾자..
        for(Contract__c tempContract:[
		        SELECT Id, Name, Customer__c, Customer__r.CustomerType__c, Customer__r.Name, Customer__r.fm_Mobile__c,ContractNumber__c, Opportunity__c,Opportunity__r.CampaignId,eFormsignDate__c,ContractStartDate__c,
				        Dealer__c, Dealer__r.ERPCode__c, Dealer__r.DealerOwner__c,
                    (
		                    SELECT Id, ProductId__r.Name, ProductId__r.ProductCode, fm_ProductType__c,NetPrice__c,UnitPrice__c
                            FROM ContractLineItem__r
		                    WHERE fm_Type__c = '본체'
		                    AND ProductId__c = :lsMSalesPDIVO.bizData.asset.Product2Id
                    )
		        FROM Contract__c
		        WHERE isLWSRegistration__c = FALSE // LWS 등록
		        AND fm_IsLossOppty__c = FALSE
		        AND eFormsignStatus__c = '계약체결'
		        AND Dealer__c = :UserLoginAcc.Contact.AccountId // 대리점
		        AND Id IN (SELECT Contract__c FROM ContractLineItem__c WHERE fm_Type__c = '본체' AND ProductId__c = :lsMSalesPDIVO.bizData.asset.Product2Id)
		        ORDER BY CreatedDate
        ]){
	        if(lsMSalesPDIVO.bizData.asset.Account.CustomerType__c == '농협' || lsMSalesPDIVO.bizData.asset.Account.CustomerType__c == '관납') {
		        // 자산의 고객의 고객 유형이 농협/관납이면 : 계약의 고객과 자산의 고객이 같아야 함.
		        // 2022-01-05
		        if(tempContract.Customer__c == lsMSalesPDIVO.bizData.asset.AccountId) {
			        if(!tempContract.ContractLineItem__r.isEmpty()) targetContracts.add(tempContract);
		        }
	        } else {
		        // 자산의 고객의 고객 유형이 대리점이면 : 계약의 고객이 농협/관납이 아니어야 함.
		        // 2022-01-05
		        if(!(tempContract.Customer__r.CustomerType__c == '농협' || tempContract.Customer__r.CustomerType__c == '관납')) {
			        if(!tempContract.ContractLineItem__r.isEmpty()) targetContracts.add(tempContract);
		        }
	        }
        }

        lsMSalesPDIVO.bizData.targetContracts = targetContracts;
        lsMSalesPDIVO.bizData.contract = new Contract__c();
        lsMSalesPDIVO.bizData.contractItem = new ContractLineItem__c();
        lsMSalesPDIVO.bizData.dealerSignPng = '';
        lsMSalesPDIVO.bizData.customerSignPng = '';
        lsMSalesPDIVO.bizData.pdi = new PDI__c();
        if(lsMSalesPDIVO.bizData.asset.Id != null) lsMSalesPDIVO.bizData.pdi.Asset__c = lsMSalesPDIVO.bizData.asset.Id;
        // 로그인사용자와 자산의 동일 대리점여부 체크
        //lsMSalesPDIVO.bizData.isSameDealer = (lsMSalesPDIVO.bizData.asset.Dealer__c == ModelUser.getUserData().AccountId);
	    /**
	     * ITVOC-2021-07-0426 수정 요청
	     * 요청자 : 최희웅
	     * 또한, 현재 PDI 등록 Logic이 자신이 대리점인 경우 PDI 등록이 가능한 것으로 되어있는 듯 한데,
	     * 자신이 Owner이고, 재고유형이 대리점재고인 경우에 한해서만 PDI 등록이 가능하도록 Logic 개선 요청
		*/
	    lsMSalesPDIVO.bizData.isSameDealer = (lsMSalesPDIVO.bizData.asset.OwnerId == ModelUser.getUserData().Id);
        if(!lsMSalesPDIVO.bizData.isSameDealer) {
            lsMSalesPDIVO.bizData.assetMessage = System.Label.LsMSalesPDICreate_NotSameDealer;
        }

        return lsMSalesPDIVO;
    }

	/**
	 * @param pdiData
	 * @param dealerSignPng
	 * @param customerSignPng
	 *
	 * @return
	 */
	@AuraEnabled
	public static LsMSalesPDIVO save(LsMSalesPDIVO pdiData, String dealerSignPng, String customerSignPng) {

		//서명 저장 처리
		List<ContentVersion> cvs = new List<ContentVersion>();
		ContentVersion cv;
		cv = new ContentVersion();
		cv.Title = 'dealerSign.png';
		cv.VersionData = EncodingUtil.base64Decode(dealerSignPng.split(',')[1]);
		cv.PathOnClient = 'dealerSign.png';
		cvs.add(cv);

		cv = new ContentVersion();
		cv.Title = 'customerSign.png';
		cv.VersionData = EncodingUtil.base64Decode(customerSignPng.split(',')[1]);
		cv.PathOnClient = 'customerSign.png';
		cvs.add(cv);

		insert cvs;

		pdiData.bizData.pdi.Consumer__c = pdiData.bizData.contract.Customer__c;
		pdiData.bizData.pdi.Contract__c = pdiData.bizData.contract.Id;
		pdiData.bizData.pdi.Opportunity__c = pdiData.bizData.contract.Opportunity__c;
//		pdiData.bizData.pdi.HandoverDate__c = (pdiData.bizData.contract.eFormsignDate__c != null ? pdiData.bizData.contract.eFormsignDate__c:pdiData.bizData.contract.ContractStartDate__c);
		pdiData.bizData.pdi.HandoverDate__c = System.today();
		pdiData.bizData.pdi.CheckerSignatureApex__c = cvs[0].Id;
		pdiData.bizData.pdi.CustomerSignatureApex__c = cvs[1].Id;
		pdiData.bizData.pdi.isActualCustomer__c = true; // 실 고객 여부
		insert pdiData.bizData.pdi;

		// 고객 업데이트
		Account acc = new Account(Id = pdiData.bizData.contract.Customer__c);
		acc.CustomerStatus__c = '실고객';
		acc.IsTractorStatus__c   = true;
		acc.AssetId__c           = pdiData.bizData.asset.Id;
		update acc;

		// 기회 업데이트
		Opportunity opportunity = new Opportunity(Id = pdiData.bizData.contract.Opportunity__c);
		opportunity.StageName = '인도';
		opportunity.SystemStatus__c = '인도';
		update opportunity;

		// 계약 업데이트
		Contract__c contract = new Contract__c(Id = pdiData.bizData.contract.Id);
		contract.Status__c = '워런티 진행 중';  // 상태
		contract.SystemStatus__c = '워런티 진행 중';
		contract.isLWSRegistration__c = true; // LWS 등록
		contract.DeliveryDate__c = System.today() ; // 고객인도일
		update contract;

		// 자산 가격 업데이트
		if(pdiData.bizData.contractItem != null && pdiData.bizData.assetPrice != null){
			AssetPrice__c asp = new AssetPrice__c(Id = pdiData.bizData.assetPrice.Id, SalePrice__c = pdiData.bizData.contractItem.NetPrice__c); // 계약 제품(본체).판매가
			update asp;
		}
		// 프로모션 실적 처리
		if(pdiData.bizData.contract.Opportunity__r.CampaignId != null){
			Campaign cam = [
                    SELECT Id,
                           ExpectedRevenue__c,
                           ProductId__r.DealerListPrice__c
                    FROM Campaign
                    WHERE Id =:pdiData.bizData.contract.Opportunity__r.CampaignId
            ];

			if(cam.ExpectedRevenue__c == null) cam.ExpectedRevenue__c = 0;
			cam.ExpectedRevenue__c += (cam.ProductId__r.DealerListPrice__c == null ? 0 : cam.ProductId__r.DealerListPrice__c); // 계약 제품(본체).대리점가

			update cam;
		}

		Map<Id,ContentVersion> temp = new Map<Id,ContentVersion>(cvs);
		List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
		ContentDocumentLink cdl;

		for(ContentVersion cv_temp:[SELECT ContentDocumentId, CreatedDate FROM ContentVersion WHERE id =: temp.keySet()]){
			cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = cv_temp.ContentDocumentId;
			cdl.LinkedEntityId = pdiData.bizData.pdi.Id;
			cdl.ShareType = 'V';
			cdls.add(cdl);
		}
		insert cdls;

		// 자산 업데이트
		Integer warrantRange = 5;
		warrantRange = pdiData.bizData.asset.Product2.WarrantyRange__c == null ? 5 : Integer.valueOf(pdiData.bizData.asset.Product2.WarrantyRange__c);
		Asset asset = new Asset(Id = pdiData.bizData.asset.Id);
		asset.InventoryType__c                   = '실판매'; // 재고유형
		asset.Customer__c                        = pdiData.bizData.pdi.Consumer__c; // 실소유자
		asset.AccountId                          = pdiData.bizData.pdi.Consumer__c; // 실소유자
		asset.PDI__c                             = pdiData.bizData.pdi.Id; // PDI 연결
		asset.Contract__c                        = pdiData.bizData.pdi.Contract__c; // 계약 연결
/*		asset.IsSendReceiveItem__c               = false;
		asset.SendReceiveSpecifiedDate__c        = null;
		asset.DateSendReceiveExcept__c           = null;
		asset.CondSendReceiveExcept__c           = '';
		asset.NumSendReceiveExcept__c            = 0;*/
		asset.SalesDate__c                       = Date.today();        // 판매일자.
		asset.WtyStartDate__c                    = Date.today();        // 처리일자.
		asset.WtyEndDate__c                      = asset.WtyStartDate__c.addYears(warrantRange);
		// Dealer__c, Dealer__r.ERPCode__c, Dealer__r.DealerOwner__c,
		update asset;

		List<Task> tasks = new List<Task>();
		try {
			Task tmpTask = new Task();
			tmpTask.WhatId = asset.Id;
			tmpTask.Subject = '고객인도';
			tmpTask.Status = 'Completed';
			tmpTask.ActivityDate = pdiData.bizData.pdi.HandoverDate__c;
			tmpTask.OwnerId = pdiData.bizData.asset.OwnerId;
			tasks.add(tmpTask);

			Task newTask = new Task();
			newTask.OwnerId = pdiData.bizData.asset.OwnerId;
			newTask.ActivityDate = System.today();
			newTask.Type__c = 'Guide';
			newTask.WhatId = pdiData.bizData.pdi.Id;
			newTask.Subject = '[LWS 등록]';
			newTask.Description = pdiData.bizData.contract.Customer__r.Name + ' 고객의 기대 정보가 LWS에 등록 되었습니다.(' + pdiData.bizData.asset.Name + ')';
			newTask.CustomAlert__c = true;
			newTask.Status = 'Completed';
			tasks.add(newTask);
			System.debug(JSON.serializePretty(tasks));
			insert tasks;
		} catch (Exception e) {
			// 알림 오류는 무시 ..
		}

		return pdiData;
	}

	/**
	 * @TODO : PDF 생성
	 * @param pdiId
	 *
	 * @return
	 */
	@Future
	public static void getPdiPDF(String recordId) {
		PageReference pdf;
		String pdfformUrl = '/apex/InspectionConfirmationPdf?pdiId='+recordId;
		pdf = new PageReference(pdfformUrl);

		ContentVersion cv = new ContentVersion();
		cv.Title = 'PDI.pdf';
		cv.VersionData = !Test.isRunningTest() ? pdf.getContent() : Blob.valueOf('testData');
		cv.PathOnClient = 'PDI.pdf';
		insert cv;

		ContentDocumentLink cd = new ContentDocumentLink();
		for(ContentVersion cv_temp:[SELECT Id, ContentDocumentId FROM ContentVersion where id=:cv.Id]){
			cd.ContentDocumentId = cv_temp.ContentDocumentId;
			cd.LinkedEntityId = recordId;
			cd.ShareType = 'V';
		}
		insert cd;

		//pdiData.bizData.pdfContentVersionId = cv.Id;
		//return pdiData;
	}


/*
//	 * @TODO : I/F 호출
//	 * @param pdiData
//	 *
//	 * @return
//	 *
	@AuraEnabled
	public static LsMSalesPDIVO callIF(LsMSalesPDIVO pdiData) {
		Map<String, String> returnMap = LwsService.IF_KR_SE_LWS_0018(pdiData.bizData.pdi.ID, pdiData.bizData.pdfContentVersionId);
		if(returnMap.get('STATUS') == 'Y'){
			pdiData.bizData.pdi.IFStatus__c = 'Complete'; // IF 처리 상태(Apex)
		}else{
			pdiData.bizData.pdi.IFStatus__c = 'Error'; // IF 처리 상태(Apex)
			pdiData.bizData.pdi.IFMessage__c = returnMap.get('MESSAGE'); // IF 처리 내용(Apex)
		}
		update pdiData.bizData.pdi;

		return pdiData;
	}
*/

	/**
	 * ERP I/F 호출
	 * @DESCRIPTION ERP I/F 정상적이어야만 데이터 저장 처리.
	 * @param pdiData
	 *
	 * @return
	 */
	@AuraEnabled
	public static LsMSalesPDIVO savePDI(LsMSalesPDIVO pdiData, String dealerSignPng, String customerSignPng) {
		pdiData = PDIService.sendPDI(pdiData);
		if(pdiData.bizData.pdi.IFStatus__c == 'Complete') {
			pdiData = save(pdiData, dealerSignPng, customerSignPng);
			//getPdiPDF(pdiData.bizData.pdi.Id);
		}
		return pdiData;
	}
}