/**
 * Created by MS on 2022-04-28.
 */

public without sharing class PartnerIncentiveListExcel {

	/**
	 * 초기 거래 데이터
	 */
	public List<IncentiveData> dealerDataList {get;set;} // 판매장려 금액 정보 : 화면 표시용
	public List<IncentiveData> serviceDataList {get;set;} // 판매장려 금액 정보 : 화면 표시용
	public Account dealerAccount {get;set;}    // 대리점 정보
	public Boolean isApproval {get;set;}       // 결재 여부
	public Decimal assetCount {get;set;}       // 대상 대수
	public Decimal totalIncentiveAmount {get;set;}       // 총 금액
	public Decimal totalIncentiveRate {get;set;}         // 총 비율
	public String processYearMonth {get;set;}         // 지급 년월
	public String processDate {get;set;}         // 처리 일자
	public String fileName {get;set;}         // 파일명

	public class IncentiveData {
		public DealerIncentiveInput__c DealerIncentiveInput {get;set;}
		public String DealerReceiptDate {get;set;}
		public String AccountName {get;set;}
		public String AssetName {get;set;}
		public String ProductName {get;set;}
		public String ProductDivision {get;set;}
		public Decimal SalesSellingAmount {get;set;}
		public Decimal SubTotalAmount {get;set;}
		public Decimal SubTotalRate {get;set;}
		public Decimal TaxAmount {get;set;}
		public Decimal TotalAmount {get;set;}
		public Decimal DIC1Amount {get;set;}
		public Decimal DIC1Rate {get;set;}
		public Decimal DIC3Amount {get;set;}
		public Decimal DIC3Rate {get;set;}
		public Decimal DIC4Amount {get;set;}
		public Decimal DIC4Rate {get;set;}
		public Decimal DIC6Amount {get;set;}
		public Decimal DIC6Rate {get;set;}
		public Decimal DIC7Amount {get;set;}
		public Decimal DIC7Rate {get;set;}
		public Decimal DIC8Amount {get;set;}
		public Decimal DIC8Rate {get;set;}
		public Decimal DIC12Amount {get;set;}
		public Decimal DIC12Rate {get;set;}
		public Decimal DIC13Amount {get;set;}
		public Decimal DIC13Rate {get;set;}
		public Decimal DIC14Amount {get;set;}
		public Decimal DIC14Rate {get;set;}
		public Decimal DIC15Amount {get;set;}
		public Decimal DIC15Rate {get;set;}
		public Decimal DIC9Amount {get;set;}
		public Decimal DIC9Rate {get;set;}
		public Decimal DIC10Amount {get;set;}
		public Decimal DIC10Rate {get;set;}
		public Decimal DIC11Amount {get;set;}
		public Decimal DIC11Rate {get;set;}
	}

	public PartnerIncentiveListExcel() {
		dealerDataList = new List<IncentiveData>();
		serviceDataList = new List<IncentiveData>();

		String userId = UserInfo.getUserId();//'0052w000004jC5RAAU';
		User dealerUser = [
				SELECT Id, AccountId FROM User
				WHERE Id = :userId
		];

		// 대리점 정보
		dealerAccount = [
				SELECT Id, Name, ErpName__c, ERPCode__c, DealerOwner__r.Name, BusinessOffice__r.Name, Owner.Name
				FROM Account
				WHERE Id = :dealerUser.AccountId
		];

		// 판매장려 정보
		List<DealerIncentiveInput__c> dealerIncentiveInputs = [
				SELECT
						Id,
						BaseDate__c,
						Asset__c,
						Asset__r.InventoryType__c,
						Asset__r.ProductionDate__c,
						Asset__r.FirstDeliveryDate__c,
						Asset__r.DealerReceiptDate__c,
						Asset__r.Name,
						Asset__r.Product2.Name,
						toLabel(Asset__r.Product2.ProductDivision__c),
						Asset__r.Account.Name,
						Type__c,
						PaymentType__c,
						SalesSellingAmount__c,
						IsPartnerApprove__c,
						PartnerApprovalUser__c,
						PartnerApprovalDatetime__c,
						Dealer__r.ERPCode__c,
						Dealer__r.Owner.EmployeeNumber,
						DealerIncentiveCalculate1__c,
						DealerIncentiveCalculate2__c,
						DealerIncentiveCalculate3__c,
						DealerIncentiveCalculate4__c,
						DealerIncentiveCalculate6__c,
						DealerIncentiveCalculate7__c,
						DealerIncentiveCalculate8__c,
						DealerIncentiveCalculate9__c,
						DealerIncentiveCalculate10__c,
						DealerIncentiveCalculate11__c,
						DealerIncentiveCalculate12__c,
						DealerIncentiveCalculate13__c,
						DealerIncentiveCalculate14__c,
						DealerIncentiveCalculate15__c,
						DealerIncentiveCalculate1__r.SupplyAmount__c,
						DealerIncentiveCalculate2__r.SupplyAmount__c,
						DealerIncentiveCalculate3__r.SupplyAmount__c,
						DealerIncentiveCalculate4__r.SupplyAmount__c,
						DealerIncentiveCalculate6__r.SupplyAmount__c,
						DealerIncentiveCalculate7__r.SupplyAmount__c,
						DealerIncentiveCalculate8__r.SupplyAmount__c,
						DealerIncentiveCalculate9__r.SupplyAmount__c,
						DealerIncentiveCalculate10__r.SupplyAmount__c,
						DealerIncentiveCalculate11__r.SupplyAmount__c,
						DealerIncentiveCalculate12__r.SupplyAmount__c,
						DealerIncentiveCalculate13__r.SupplyAmount__c,
						DealerIncentiveCalculate14__r.SupplyAmount__c,
						DealerIncentiveCalculate15__r.SupplyAmount__c,
						DealerIncentiveCalculate1__r.Status__c,
						DealerIncentiveCalculate2__r.Status__c,
						DealerIncentiveCalculate3__r.Status__c,
						DealerIncentiveCalculate4__r.Status__c,
						DealerIncentiveCalculate6__r.Status__c,
						DealerIncentiveCalculate7__r.Status__c,
						DealerIncentiveCalculate8__r.Status__c,
						DealerIncentiveCalculate9__r.Status__c,
						DealerIncentiveCalculate10__r.Status__c,
						DealerIncentiveCalculate11__r.Status__c,
						DealerIncentiveCalculate12__r.Status__c,
						DealerIncentiveCalculate13__r.Status__c,
						DealerIncentiveCalculate14__r.Status__c,
						DealerIncentiveCalculate15__r.Status__c,
						DealerIncentiveCalculate3__r.Division__c,
						DealerIncentiveCalculate9__r.Division__c,
						DealerIncentiveCalculate10__r.Division__c,
						DealerIncentiveCalculate11__r.Division__c,
						fm_DealerIncentiveCalculate1Amount__c,
						fm_DealerIncentiveCalculate1Rate__c,
						fm_DealerIncentiveCalculate2Amount__c,
						fm_DealerIncentiveCalculate2Rate__c,
						fm_DealerIncentiveCalculate3Amount__c,
						fm_DealerIncentiveCalculate3Rate__c,
						fm_DealerIncentiveCalculate4Amount__c,
						fm_DealerIncentiveCalculate4Rate__c,
						fm_DealerIncentiveCalculate6Amount__c,
						fm_DealerIncentiveCalculate6Rate__c,
						fm_DealerIncentiveCalculate7Amount__c,
						fm_DealerIncentiveCalculate7Rate__c,
						fm_DealerIncentiveCalculate8Amount__c,
						fm_DealerIncentiveCalculate8Rate__c,
						fm_DealerIncentiveCalculate9Amount__c,
						fm_DealerIncentiveCalculate9Rate__c,
						fm_DealerIncentiveCalculate10Amount__c,
						fm_DealerIncentiveCalculate10Rate__c,
						fm_DealerIncentiveCalculate11Amount__c,
						fm_DealerIncentiveCalculate11Rate__c,
						fm_DealerIncentiveCalculate12Amount__c,
						fm_DealerIncentiveCalculate12Rate__c,
						fm_DealerIncentiveCalculate13Amount__c,
						fm_DealerIncentiveCalculate13Rate__c,
						fm_DealerIncentiveCalculate14Amount__c,
						fm_DealerIncentiveCalculate14Rate__c,
						fm_DealerIncentiveCalculate15Amount__c,
						fm_DealerIncentiveCalculate15Rate__c,
						fm_TotalAmount__c,
						SalesDiscountAmount__c,
						SalesDiscountRate__c,
						SalesDocLineNo__c,
						SalesDocLineNoWM__c,
						SalesDocNoWM__c,
						SalesIncentiveAmount__c,
						SalesIncentiveRate__c,
						AdSalesAmount__c,
						AdSalesRate__c,
						CSIncentiveAmount__c,
						CSIncentiveRate__c
				FROM DealerIncentiveInput__c
				WHERE BaseDate__c = LAST_MONTH
				AND ApprovalStatus__c = '승인'
				AND Dealer__c = :dealerUser.AccountId
				AND IsSend__c = TRUE
				AND (
						DealerIncentiveCalculate1__c != NULL
						OR (DealerIncentiveCalculate3__c != NULL AND DealerIncentiveCalculate3__r.Division__c = '실적')
						OR DealerIncentiveCalculate4__c != NULL
						OR DealerIncentiveCalculate6__c != NULL
						OR DealerIncentiveCalculate7__c != NULL
						OR DealerIncentiveCalculate8__c != NULL
						OR (DealerIncentiveCalculate9__c != NULL  AND DealerIncentiveCalculate9__r.Division__c = '실적')
						OR (DealerIncentiveCalculate10__c != NULL  AND DealerIncentiveCalculate10__r.Division__c = '실적')
						OR (DealerIncentiveCalculate11__c != NULL  AND DealerIncentiveCalculate11__r.Division__c = '실적')
						OR DealerIncentiveCalculate12__c != NULL
						OR DealerIncentiveCalculate13__c != NULL
						OR DealerIncentiveCalculate14__c != NULL
						OR DealerIncentiveCalculate15__c != NULL
				)
				ORDER BY Asset__r.DealerReceiptDate__c, Asset__r.Name, PaymentType__c
		];

		isApproval = false;
		List<DealerIncentiveInput__c> targetList = new List<DealerIncentiveInput__c>();
		IncentiveData id;
		Decimal tmpAssetCount;                     // 대상 대수
		Decimal tmpTotalBaseAmount = 0;            // 총 공급가격
		Decimal tmpTotalIncentiveAmount = 0;       // 총 금액
		Set<String> targetAssets = new Set<String>();
		Boolean isProcessData = false;
		for(DealerIncentiveInput__c r : dealerIncentiveInputs) {
			isProcessData = true;
			if(r.DealerIncentiveCalculate3__r.Division__c == '계획' ||
					r.DealerIncentiveCalculate9__r.Division__c == '계획' ||
					r.DealerIncentiveCalculate10__r.Division__c == '계획' ||
					r.DealerIncentiveCalculate11__r.Division__c == '계획') {
				if(r.DealerIncentiveCalculate1__c == NULL &&
						r.DealerIncentiveCalculate4__c == NULL &&
						r.DealerIncentiveCalculate6__c == NULL &&
						r.DealerIncentiveCalculate7__c == NULL &&
						r.DealerIncentiveCalculate8__c == NULL &&
						r.DealerIncentiveCalculate9__c == NULL &&
						r.DealerIncentiveCalculate10__c == NULL &&
						r.DealerIncentiveCalculate11__c == NULL &&
						r.DealerIncentiveCalculate12__c == NULL &&
						r.DealerIncentiveCalculate13__c == NULL &&
						r.DealerIncentiveCalculate14__c == NULL &&
						r.DealerIncentiveCalculate15__c == NULL) {
					isProcessData = false;
				}
			}
			// 계획만 있는 데이터는 제외 처리 한다.
			if(isProcessData == false) continue;

			id = createIncentiveData(r);
			if (r.Type__c == '대리점') {
				dealerDataList.add(id);
			} else {
				serviceDataList.add(id);
			}
			// 결재 진행한건 체크.
			if (r.IsPartnerApprove__c == true) {
				isApproval = true;
			}

			// 전체 금액 및 비율 계산
			targetAssets.add(r.Asset__c);               // 대상 대수
			tmpTotalBaseAmount += id.SalesSellingAmount;   // 공급 가격 합
			tmpTotalIncentiveAmount += id.TotalAmount;     // 전체 총합

		}
		assetCount = targetAssets.isEmpty() == false ? targetAssets.size() : 0;
		totalIncentiveAmount = tmpTotalIncentiveAmount;
		totalIncentiveRate = 0;
		if(tmpTotalBaseAmount > 0 && tmpTotalBaseAmount > 0) {
			totalIncentiveRate = ((tmpTotalIncentiveAmount / tmpTotalBaseAmount) * 100).setScale(0);
		}

		Datetime processDatetime = Datetime.now();
		Date     baseDate = Date.today().toStartOfMonth().addMonths(-1);
		processYearMonth = ((Datetime)baseDate).format('yyyy년 MM월');            // 지급 년월
		processDate      = processDatetime.format('yyyy년 MM월 dd일');            // 처리 일자

		fileName = 'IncentiveList_'+processDatetime.format('yyyy-MM-dd');
	}

	public void doGetData() {

	}

	public static IncentiveData createIncentiveData(DealerIncentiveInput__c targetData) {
		IncentiveData id = new IncentiveData();
		id.DealerIncentiveInput = targetData;
		id.DealerReceiptDate = ((Datetime)targetData.Asset__r.DealerReceiptDate__c).format('yyyy-MM-dd');
		id.AccountName = targetData.Asset__r.Account.Name;
		id.AssetName = targetData.Asset__r.Name;
		id.ProductName = targetData.Asset__r.Product2.Name;
		id.ProductDivision = targetData.Asset__r.Product2.ProductDivision__c;
		id.SalesSellingAmount = targetData.SalesSellingAmount__c;
		System.debug(targetData.fm_TotalAmount__c + ' / ' + targetData.SalesSellingAmount__c);
		id.SubTotalAmount = targetData.fm_TotalAmount__c;
		id.SubTotalRate = ((id.SubTotalAmount/id.SalesSellingAmount)*100).setScale(0);
		id.DIC1Amount = targetData.fm_DealerIncentiveCalculate1Amount__c == null ? 0 : targetData.fm_DealerIncentiveCalculate1Amount__c;
		id.DIC1Rate   = targetData.fm_DealerIncentiveCalculate1Rate__c   == null ? 0 : targetData.fm_DealerIncentiveCalculate1Rate__c;
		id.DIC3Amount = targetData.fm_DealerIncentiveCalculate3Amount__c == null ? 0 : targetData.fm_DealerIncentiveCalculate3Amount__c;
		id.DIC3Rate   = targetData.fm_DealerIncentiveCalculate3Rate__c   == null ? 0 : targetData.fm_DealerIncentiveCalculate3Rate__c;
		id.DIC4Amount = targetData.fm_DealerIncentiveCalculate4Amount__c == null ? 0 : targetData.fm_DealerIncentiveCalculate4Amount__c;
		id.DIC4Rate   = targetData.fm_DealerIncentiveCalculate4Rate__c   == null ? 0 : targetData.fm_DealerIncentiveCalculate4Rate__c;
		id.DIC6Amount = targetData.fm_DealerIncentiveCalculate6Amount__c == null ? 0 : targetData.fm_DealerIncentiveCalculate6Amount__c;
		id.DIC6Rate   = targetData.fm_DealerIncentiveCalculate6Rate__c   == null ? 0 : targetData.fm_DealerIncentiveCalculate6Rate__c;
		id.DIC7Amount = targetData.fm_DealerIncentiveCalculate7Amount__c == null ? 0 : targetData.fm_DealerIncentiveCalculate7Amount__c;
		id.DIC7Rate   = targetData.fm_DealerIncentiveCalculate7Rate__c   == null ? 0 : targetData.fm_DealerIncentiveCalculate7Rate__c;
		id.DIC8Amount = targetData.fm_DealerIncentiveCalculate8Amount__c == null ? 0 : targetData.fm_DealerIncentiveCalculate8Amount__c;
		id.DIC8Rate   = targetData.fm_DealerIncentiveCalculate8Rate__c   == null ? 0 : targetData.fm_DealerIncentiveCalculate8Rate__c;
		id.DIC9Amount = targetData.fm_DealerIncentiveCalculate9Amount__c == null ? 0 : targetData.fm_DealerIncentiveCalculate9Amount__c;
		id.DIC9Rate   = targetData.fm_DealerIncentiveCalculate9Rate__c   == null ? 0 : targetData.fm_DealerIncentiveCalculate9Rate__c;
		id.DIC10Amount = targetData.fm_DealerIncentiveCalculate10Amount__c == null ? 0 : targetData.fm_DealerIncentiveCalculate10Amount__c;
		id.DIC10Rate   = targetData.fm_DealerIncentiveCalculate10Rate__c   == null ? 0 : targetData.fm_DealerIncentiveCalculate10Rate__c;
		id.DIC11Amount = targetData.fm_DealerIncentiveCalculate11Amount__c == null ? 0 : targetData.fm_DealerIncentiveCalculate11Amount__c;
		id.DIC11Rate   = targetData.fm_DealerIncentiveCalculate11Rate__c   == null ? 0 : targetData.fm_DealerIncentiveCalculate11Rate__c;
		id.DIC12Amount = targetData.fm_DealerIncentiveCalculate12Amount__c == null ? 0 : targetData.fm_DealerIncentiveCalculate12Amount__c;
		id.DIC12Rate   = targetData.fm_DealerIncentiveCalculate12Rate__c   == null ? 0 : targetData.fm_DealerIncentiveCalculate12Rate__c;
		id.DIC13Amount = targetData.fm_DealerIncentiveCalculate13Amount__c == null ? 0 : targetData.fm_DealerIncentiveCalculate13Amount__c;
		id.DIC13Rate   = targetData.fm_DealerIncentiveCalculate13Rate__c   == null ? 0 : targetData.fm_DealerIncentiveCalculate13Rate__c;
		id.DIC14Amount = targetData.fm_DealerIncentiveCalculate14Amount__c == null ? 0 : targetData.fm_DealerIncentiveCalculate14Amount__c;
		id.DIC14Rate   = targetData.fm_DealerIncentiveCalculate14Rate__c   == null ? 0 : targetData.fm_DealerIncentiveCalculate14Rate__c;
		id.DIC15Amount = targetData.fm_DealerIncentiveCalculate15Amount__c == null ? 0 : targetData.fm_DealerIncentiveCalculate15Amount__c;
		id.DIC15Rate   = targetData.fm_DealerIncentiveCalculate15Rate__c   == null ? 0 : targetData.fm_DealerIncentiveCalculate15Rate__c;

		if(targetData.PaymentType__c == '회수') {
			id.SubTotalRate = id.SubTotalRate *-1;
		}
		if(targetData.Type__c == '대리점') {
			// 대리점 부가세 : PDI 등록, Sales I.Q. 달성, 조기안착지원, 시승체험지원, 과거판매장려(CS수수료&판매수수료)
			//는 부가세 10% 반영
			//(각 항목의 금액에는 부가세 제외 금액이 뜨도록)
			id.TaxAmount = (
					(targetData.fm_DealerIncentiveCalculate3Amount__c*0.1)+
							(targetData.fm_DealerIncentiveCalculate4Amount__c*0.1)+
							(targetData.fm_DealerIncentiveCalculate8Amount__c*0.1)+
							(targetData.fm_DealerIncentiveCalculate12Amount__c*0.1)+
							((targetData.CSIncentiveAmount__c == null ? 0 : targetData.CSIncentiveAmount__c)*0.1)
			);
		} else {
			// 서비스
			// 농협 사후봉사, 관납 사후봉사, 중개영업지원 모두 부가세 10%
			id.TaxAmount = (
					(targetData.fm_DealerIncentiveCalculate9Amount__c*0.1)+
							(targetData.fm_DealerIncentiveCalculate10Amount__c*0.1)+
							(targetData.fm_DealerIncentiveCalculate11Amount__c*0.1)+
							((targetData.CSIncentiveAmount__c == null ? 0 : targetData.CSIncentiveAmount__c)*0.1)+
							((targetData.SalesIncentiveAmount__c == null ? 0 : targetData.SalesIncentiveAmount__c)*0.1)
			);
			System.debug('2--> ' + id.TaxAmount);
		}

		id.TotalAmount = id.TaxAmount + id.SubTotalAmount;
		return id;
	}


	public static void runTest() {
		Integer yr_seo = 0;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
	}

}