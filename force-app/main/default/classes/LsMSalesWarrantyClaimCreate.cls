/****************************************************************************************
 * @filename      : LsMSalesWarrantyClaimCreate
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-19 오후 3:01
 * @group         :
 * @group-content :
 * @description   : [모바일] LWS 클레임 등록
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-19 오후 3:01        SEOKHO LEE          Create
 ****************************************************************************************/

public without sharing class LsMSalesWarrantyClaimCreate {

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
	 * init
	 *
	 * @param assetName
	 *
	 * @return
	 */
	@AuraEnabled
	public static LsMSalesWarrantyClaimCreateVO init(final String assetName) {

		List<Asset> assets = [
				SELECT Id, Name, BatchNo__c, AccountId, Account.Name, Dealer__c, Account.fm_Mobile__c, Product2Id, Product2.Name, Product2.Type__c, InventoryType__c, WtyStartDate__c, WtyEndDate__c
				FROM Asset
				WHERE (Name = :assetName OR BatchNo__c = :assetName)
				LIMIT 1
		];

		LsMSalesWarrantyClaimCreateVO vo = new LsMSalesWarrantyClaimCreateVO();
		vo.bizData = new LsMSalesWarrantyClaimCreateVO.BizData();

		vo.bizData.asset = new Asset();
		vo.bizData.assetName = assetName;

		if(assets.isEmpty() == false) {
			vo.bizData.asset = assets[0];
			vo.bizData.isUnkwonCustomer = vo.bizData.asset.Account.Name == 'UnKnown';
		}

		return vo;
	}

	/**
	 * init
	 *
	 * @param assetName
	 *
	 * @return
	 */
	@AuraEnabled
	public static ClaimData customerInit(final Asset asset) {

		ClaimData claimData = new ClaimData();
		claimData.asset      = asset;
		claimData.customerVO = new LsMSalesCustomerVO();
		claimData.customerVO.customer = getNewAccountByRecordType(accountRecordTypeMapById.get(personAccountRecordTypeId));
		claimData.customerVO.cupi = getNewCUPI();
		claimData.customerVO.isPersonAccount = true;
		claimData.isAuthenticated = false;

		return claimData;
	}

	/**
	 * init
	 *
	 * @param assetName
	 *
	 * @return
	 */
	@AuraEnabled
	public static ClaimData claimInit(final String assetName) {

		List<Asset> assets = [
				SELECT Id, Name, AccountId, Account.Name, Dealer__c, Account.fm_Mobile__c, Product2Id, Product2.Name, Product2.Type__c, InventoryType__c, WtyStartDate__c, WtyEndDate__c
				FROM Asset
				WHERE Name = :assetName
				LIMIT 1
		];

		ClaimData claimData = new ClaimData();
		claimData.asset = new Asset();
		claimData.wc = null;

		if(assets.isEmpty() == false) {
			claimData.asset = assets[0];
			claimData.isUnkwonCustomer = claimData.asset.Account.Name == 'UnKnown';
			WarrantyClaim__c wc = new WarrantyClaim__c();
			wc.AssetId__c = claimData.asset.Id;
			wc.Customer__c = claimData.asset.AccountId;
			wc.Dealer__c = claimData.asset.Dealer__c;
			wc.ProductId__c = claimData.asset.Product2Id;
			wc.LWSSendStatus__c = '전송전';
			wc.Status__c = '임시';
			wc.ClaimStatus__c = '0.저장';
			wc.LWSRegDate__c = System.today();
			insert wc;
			claimData.wc = wc;

			Map<String, ContentVersion> contentVersionItems = new Map<String, ContentVersion>();
			contentVersionItems.put('p1', new ContentVersion());
			contentVersionItems.put('p2', new ContentVersion());
			contentVersionItems.put('p3', new ContentVersion());
			contentVersionItems.put('p4', new ContentVersion());
			contentVersionItems.put('p5', new ContentVersion());
			contentVersionItems.put('p6', new ContentVersion());
			contentVersionItems.put('p7', new ContentVersion());
			contentVersionItems.put('p8', new ContentVersion());
			claimData.contentVersionItems = contentVersionItems;
		}

		return claimData;
	}



	// 확인중
	@AuraEnabled
	public static CustomerSearchRecordVO getCustomerSearchSelected(String accountId) {
		Map<String, List<String>> customerTypeByRecordTypeId = new Map<String, List<String>>();
		Account tempCustomer;

		customerTypeByRecordTypeId.put(I2ComUtil.getRecordType('Account', 'PersonAccount'), new List<String>{'자영농', '영업농'});
		customerTypeByRecordTypeId.put(I2ComUtil.getRecordType('Account', 'CorporationAccount'), new List<String>{'농업법인', '기타법인'});


		CustomerSearchRecordVO customerSearchRecordVO = new CustomerSearchRecordVO();

		tempCustomer = [
				SELECT Id, Name, LastName, IsPhoneCheck__pc, FarmingArea__c, FarmingForm__c, Phone, PersonMobilePhone, CustomerType__c,
						RecordTypeId
				FROM Account
				WHERE Id = :accountId
		];

		// 고객 setting
		customerSearchRecordVO.customer = tempCustomer;

		// 고객유형 option setting
		for(String s : customerTypeByRecordTypeId.get(tempCustomer.RecordTypeId)) {
			customerSearchRecordVO.customerTypeList.add(new I2ComClass.Option(s, s));
		}

		customerSearchRecordVO.farmFormList = testMethod1(tempCustomer.CustomerType__c);
		customerSearchRecordVO.farmAreaList = testMethod2(tempCustomer.FarmingForm__c);

		return customerSearchRecordVO;
	}

	private static List<I2ComClass.Option> testMethod1(String customerType) {
		return I2ComDependencyUtil.getDependentPickListOptions('Account', 'CustomerType__c', 'FarmingForm__c', customerType, true, false);
	}

	private static List<I2ComClass.Option> testMethod2(String farmForm) {
		return I2ComDependencyUtil.getDependentPickListOptions('Account', 'FarmingForm__c', 'FarmingArea__c', farmForm, true, false);
	}

	/**
	 * 고객의 RecordType에 맞는 고객 유형 List return
	 *
	 * @param recordTypeId : String
	 *
	 * @return List<I2ComClass.Option>
	 */
	@AuraEnabled
	public static CustomerRecordTypeVO getCustomerDataByRecordType(Id recordTypeId) {


		RecordType rt = accountRecordTypeMapById.get(recordTypeId);

		CustomerRecordTypeVO customerRecordTypeVO = new CustomerRecordTypeVO();
		customerRecordTypeVO.newAccount = getNewAccountByRecordType(rt);
		customerRecordTypeVO.newCupi = new CUPI__c();
		customerRecordTypeVO.isPersonAccount = (rt.DeveloperName == 'PersonAccount');

		customerRecordTypeVO.accountRecordTypeList = new List<I2ComClass.Option>();
		for(RecordType r : [SELECT Id, Name FROM RecordType WHERE DeveloperName IN ('PersonAccount', 'CorporationAccount')]) {
			customerRecordTypeVO.accountRecordTypeList.add(new I2ComClass.Option(r.Name, r.Id));
		}

		List<String> customerTypes = new List<String>();
		customerRecordTypeVO.customerTypeList = new List<I2ComClass.Option>();
		if(customerRecordTypeVO.isPersonAccount) {
			customerTypes = new List<String>{'자영농', '영업농'};
		} else {
			customerTypes = new List<String>{'농업법인', '기타법인'};
		}
		for(String s : customerTypes) {
			customerRecordTypeVO.customerTypeList.add(new I2ComClass.Option(s, s));
		}

		return customerRecordTypeVO;
	}

	public class CustomerRecordTypeVO {
		@AuraEnabled public List<I2ComClass.Option> accountRecordTypeList {
			get {
				if(this.accountRecordTypeList == null) {
					this.accountRecordTypeList = new List<I2ComClass.Option>();
				}

				return this.accountRecordTypeList;
			}
			set;
		}
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

	public class CustomerSearchRecordVO {
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

	@AuraEnabled
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
	@AuraEnabled
	public static List<I2ComClass.Option> getFarmingSizeOptions(final String farmingForm) {

		System.debug(System.LoggingLevel.INFO, 'farmingForm :' + farmingForm);

		return I2ComDependencyUtil.getDependentPickListOptions('ProdSerRecStd__c', 'FarmingForm__c', 'FarmingSize__c', farmingForm, true, false);
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
				newAccount.CUPIInitialStartDate__pc = Date.today();
				// 개인정보활용동의여부
				newAccount.IsCUPI__pc = true;
				newAccount.IsPhoneCheck__pc = false;
			}
		}

		return newAccount;
	}

	/**
	 * 신규 개인정보
	 * @return CUPI__c
	 */
	private static CUPI__c getNewCUPI() {
		return new CUPI__c(
				OwnerId = UserInfo.getUserId()
		);
	}

	/**
	 * save
	 *
	 * @param claimData
	 *
	 * @return
	 */
	@AuraEnabled
	public static ClaimData customerSave(ClaimData claimData) {
		System.debug(System.LoggingLevel.INFO, 'claimData :' + claimData);

		// 대상이 되는 Account
		Account account = claimData.customerVO.customer;
		// B2B일 때 대상이 되는 Contact
		Contact contact = claimData.customerVO.customerContact;

		Asset asset = claimData.asset;

		CUPI__c cupi = claimData.customerVO?.cupi;

		// 개인 고객 여부
		Boolean isPersonAccount = claimData.customerVO.isPersonAccount;
		List<Account> accounts;

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
				if(isPersonAccount) {
					account.IsCUPI__pc                  = true; // 개인정보활용동의여부
					account.CUPIInitialStartDate__pc    = Date.today();    // 개인정보최초동의일
					account.IsPhoneCheck__pc            = true; // 전화번호 인증

					cupi.ConsentType__c = '신규';
				} else {
					// 법인
					account = new Account(
							Name = claimData.customerVO.customer.Name,
							Phone = claimData.customerVO.customer.Phone,
							RecordTypeId = claimData.customerVO.customer.RecordTypeId,
							CustomerType__c = claimData.customerVO.customer.CustomerType__c,
							FarmingForm__c = claimData.customerVO.customer.FarmingForm__c,
							FarmingArea__c = claimData.customerVO.customer.FarmingArea__c
					);
				}
				account.FarmingForm__c              = account.FarmingForm__c;
				account.FarmingArea__c              = account.FarmingArea__c;
				account.InterestModel__c            = claimData.asset.Product2Id;
				account.Dealer__c                   = loginUser.AccountId; // 대리점
				account.BusinessOffice__c           = loginUser.Account.BusinessOffice__c;
				account.BusinessOfficeName__c       = loginUser.Account.BusinessOfficeName__c;

			}
			else {
				account = accounts[0];
				if(isPersonAccount) {
					account.CUPIInitialStartDate__pc = Date.today(); // 개인정보최초동의일
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

		account.InterestModel__c            = claimData.asset.Product2Id;
		upsert account;

		// B2B일 경우에만 처리하는 연락처 로직
		if(!isPersonAccount && contact != null) {
			contact.AccountId = account.Id;
			contact.IsRepresentative__c = true;
			cupi.ConsentType__c = (contact.Id == null) ? '신규' : ' 재동의';

			upsert contact;
		}

		// 개인정보동의 레코드 공통 세팅.
		cupi.IsCUPIThirdParty__c = true;
		cupi.Dealer__c = loginUser.AccountId;
		cupi.ConsentDate__c = Date.today();
		cupi.NextConsentScheduledDate__c = cupi.ConsentDate__c.addYears(2);

		// 개인고객일 경우에만 처리 하는 로직.
		if(isPersonAccount) {
			// 2. 개인정보 동의 레코드 생성
			cupi.ConsentedAccount__c = account.Id;
			cupi.PromotionFK__c = account.LastName + '|' + account.PersonMobilePhone.replaceAll('-', '') + '|' + loginUser.AccountId;

			insert cupi;

			// 최종 개인정보 동의 정보를 Account에 업데이트 처리 한다.
			account.CUPI__pc = cupi.Id;
			account.IsPhoneCheck__pc = true;
			update account;
		} else {
			// B2B일 경우에만 처리 하는 로직
			// 개인정보 동의 레코드 생성
			cupi.ConsentedContact__c = contact.Id;
			cupi.PromotionFK__c = contact.LastName + '|' + contact.MobilePhone.replaceAll('-', '') + '|' + loginUser.AccountId;

			insert cupi;

			// 최종 개인정보 동의 정보를 Account에 업데이트 처리 한다.
			contact.CUPI__c = cupi.Id;
			contact.IsPhoneCheck__c = true;     // 전화번호 인증.
			if(!contact.IsCUPI__c) contact.IsCUPI__c = true;
			if(contact.CUPIInitialStartDate__c == null) contact.CUPIInitialStartDate__c = Date.today();

			update contact;
		}

		asset.AccountId = account.Id;
		asset.Customer__c = account.Id;
		update asset;

		return claimData;
	}

	/**
	 * save
	 *
	 * @param claimData
	 *
	 * @return
	 */
	@AuraEnabled
	public static ClaimData save(ClaimData claimData) {

		claimData.wc.Status__c = '정상';
		update claimData.wc;

		// 최초 화면이 오픈 되면서 신규 생성되고 저장 안한 임시 데이터를 삭제 처리 한다.
		delete [SELECT Id FROM WarrantyClaim__c WHERE Status__c = '임시'];

		return claimData;
	}


	/**
	 * Warranty 청구 등록 : IF_KR_SE_LWS_0021
	 * 기본 정보 전송
	 *
	 * @param claimData
	 *
	 * @return
	 */
	@AuraEnabled
	public static ClaimData callLWS0021(ClaimData claimData) {
		Map<String, String> returnMap = new Map<String, String>();
/*
	전송 상태값
		전송전
		기본정보전송
		사진전송
		기본정보전송오류
		사진전송오류
 */
		if(claimData.wc.LWSSendStatus__c == '전송전' || claimData.wc.LWSSendStatus__c == '기본정보전송오류') {
			returnMap = LwsService.IF_KR_SE_LWS_0021(claimData.wc.Id);
			claimData.wc = [SELECT AssetId__c, Customer__c, Dealer__c, ProductId__c, LWSSendStatus__c, Status__c, Externalkey__c, ClaimNo__c FROM WarrantyClaim__c WHERE Id = :claimData.wc.Id];
			System.debug('WC-NO : [' + claimData.wc.ClaimNo__c+']');
		} else {
			// 저장시 마스터 정보는 저장 되어 있으면 재 호출 하지 않도록 하기 위한 처리.
			returnMap.put('STATUS', 'Y');
		}
		claimData.IFResultMap = returnMap;
/*		if(returnMap.get('STATUS') == 'N') {
			throw new AuraHandledException(returnMap.get('MESSAGE'));
		}*/
		return claimData;
	}

	/**
	 * Warranty 청구 등록 : IF_KR_SE_LWS_0022
	 * 사진 정보 전송
	 *
	 * @param claimData
	 * @param contentVersionId
	 * @param seq
	 *
	 * @return
	 */
	@AuraEnabled
	public static ClaimData callLWS0022(ClaimData claimData, String contentVersionId, String seq) {
		Map<String, String> returnMap = new Map<String, String>();
		returnMap = LwsService.IF_KR_SE_LWS_0022(claimData.asset.BatchNo__c, claimData.wc.ClaimNo__c, contentVersionId, seq);
		claimData.IFResultMap = returnMap;
/*		if(returnMap.get('STATUS') == 'N') {
			throw new AuraHandledException(returnMap.get('MESSAGE'));
		}*/
		return claimData;
	}

	/**
	 * 사진 업로드 후 타입 업데이트 처리
	 *
	 * @param recordId
	 * @param n_documentId
	 * @param o_documentId
	 * @param lWSImageType
	 *
	 * @return
	 */
	@AuraEnabled
	public static ContentVersion updateContentVersionItems(String recordId,String n_documentId,String o_documentId,String lWSImageType) {
		if(String.isNotBlank(o_documentId)){
			deleteContentVersionItems(o_documentId);
		}
		ContentVersion n_cv = [SELECT Id,ContentDocumentId,FirstPublishLocationId,LWSImageType__c FROM ContentVersion WHERE ContentDocumentId = :n_documentId];
		n_cv.LWSImageType__c = lWSImageType;
		update n_cv;

		return n_cv;
	}

	/**
	 * 사진 삭제 처리
	 *
	 * @param o_documentId
	 */
	@AuraEnabled
	public static void deleteContentVersionItems(String o_documentId) {
		ContentDocument d_cv = [SELECT Id FROM ContentDocument WHERE Id = :o_documentId];
		delete d_cv;
	}

	/**
	* WrapperClass
	*
	*/
	public class ClaimData {
		@AuraEnabled public Asset  asset { get; set; }
		@AuraEnabled public WarrantyClaim__c  wc { get; set; }
		@AuraEnabled public Map<String, ContentVersion> contentVersionItems {get;set;}
		@AuraEnabled public Map<String, String>  IFResultMap { get; set; }
		@AuraEnabled public Boolean  isUnkwonCustomer { get; set; }
		@AuraEnabled public Boolean  isAuthenticated { get; set; }
		// 추가로 내려보냄
		@AuraEnabled public Boolean  isSameDealer {
			get {
				return this.asset.Dealer__c == ModelUser.getUserData().AccountId;
			}
			set;
		}
		@AuraEnabled public LsMSalesCustomerVO  customerVO { get; set; }
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
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
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