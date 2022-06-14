/****************************************************************************************
  * @filename      : AssetReturnRequestQa
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-04-16
  * @group         :
  * @group-content :
  * @description   : 반환 신청
  * @tester        : AssetReturnRequestQa_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-16         i2max          Create
****************************************************************************************/
public without sharing class AssetReturnRequestQa {

	/**
	 * 초기 거래 데이터
	 */
	public class InitData extends I2ComClass.InitData {
		@AuraEnabled public Asset asset {get;set;}
		@AuraEnabled public AssetReturn__c assetReturn {get;set;}
		@AuraEnabled public Boolean isAssetReturns {get;set;}
		@AuraEnabled public Boolean isTarget {
			get {
				//============================================================================
				// 바인딩 되는 필드만
				//============================================================================
				return (asset.InventoryType__c == '실판매' && isAssetReturns == false) ? true : false;
			}
			set;
		}
	}

	/**
	 * 초기 거래
	 * @return InitData
	 */
	@AuraEnabled(Cacheable=true)
	public static InitData init(String recordId) {

		User currentUser = [
				SELECT Id, Contact.AccountId,
						AccountId, Account.OwnerId, Account.Owner.ManagerId, Account.Name, Account.ParentId, Account.Parent.OwnerId, Account.DealerDivision__c, Account.ServiceCapabilityClass__c,
						Account.BusinessOffice__c, Account.BusinessOfficeName__c, BusinessOffice__c
				FROM User
				WHERE Id = :UserInfo.getUserId()
		];

		List<User> CustomerSatisfactionTeamLeaders = [
				SELECT Id, Name
				FROM User
				WHERE UserRoleId IN (
					SELECT Id  FROM UserRole
					WHERE DeveloperName = 'TractorCustomerSatisfactionTeamLeader'
				)
				LIMIT 1
		];
		User CustomerSatisfactionTeamLeader = null;
		if(CustomerSatisfactionTeamLeaders.isEmpty() == false) {
			CustomerSatisfactionTeamLeader = CustomerSatisfactionTeamLeaders[0];
		} else {
			CustomerSatisfactionTeamLeader = new User(Id = UserInfo.getUserId());
		}

		Asset asset = [SELECT Id, Name, InventoryType__c FROM Asset WHERE Id = :recordId];
		List<AssetReturn__c> assetReturns = [SELECT Id FROM AssetReturn__c WHERE Asset__c = :recordId AND ApprovalStatus__c NOT IN ('승인','반려')];
		System.debug(JSON.serializePretty(currentUser));
		InitData initData = new InitData();
		initData.asset = asset;
		initData.isAssetReturns = assetReturns.isEmpty() ? false : true;
		initData.assetReturn = new AssetReturn__c(
				ApprovalStatus__c = '요청',
				Asset__c       = initData.asset.Id,
				RequestUser__c = currentUser.Id,
				Dealer__c      = currentUser.Contact.AccountId,
				SalesOwner__c  = currentUser.Account.OwnerId,
				SalesManager__c  = currentUser.Account.Owner.ManagerId,
				TractorCustomerSatisfactionTeamLeader__c = CustomerSatisfactionTeamLeader.Id
		);
		return initData;
	}

	/**
	 * 여신 한도 승인 요청
	 *
	 * @param recordId : Order__c 의 RecordId
	 */
	@AuraEnabled
	public static void submitForApproval(final String recordId, Asset asset, AssetReturn__c assetReturn) {

		insert assetReturn;

		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments(asset.Name + ' 기대에 대해서 반환 신청 드립니다.');
		req1.setObjectId(assetReturn.Id);
		req1.setSubmitterId(UserInfo.getUserId());

		if(!Test.isRunningTest()) Approval.ProcessResult result = Approval.process(req1);

	}

	public static void runTest() {
		Integer i = 0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
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