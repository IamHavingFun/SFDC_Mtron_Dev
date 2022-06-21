/****************************************************************************************
 * @filename      : lsMSalesAccountDetail
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-10 오전 10:12
 * @group         :
 * @group-content :
 * @description   : [모바일] 고객카드
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-10 오전 10:12     i2max_my.Seo         Create
 0.2     2022-06-20                i2max                ITVOC-2021-07-0404
 ****************************************************************************************/
public with sharing class lsMSalesAccountDetail {
	/**
	 *
	 * init
	 * @param
	 * @return
	 * 고객 정보 조회
	 */
	@AuraEnabled
	public static AccountData init(final String recordId) {

		// 고객 정보 조회
		Account account = [
				SELECT Id, Name, PersonMobilePhone, CustomerStatus__c, FarmingForm__c, FarmingArea__c, Fm_Mobile__c
				FROM Account WHERE Id = :recordId
		];
		// 자산 정보 조회
		List<Asset> assets = [
				SELECT Id, Name, ProductionDate__c, SalesDate__c,
					   Product2.Name, Product2.HorsePowerStandard__c, Product2.Option1__c, Product2.Option2__c, Product2.Option3__c, Product2.Option4__c
				FROM Asset
				WHERE AccountId = :recordId
                ORDER BY LastModifiedDate DESC
		];
		// 기회 정보 조회
		List<Opportunity> opportunities = [
				SELECT Id, InterestModel__r.Name, Name, CloseDate, Amount, StageName, CreatedDate, LastModifiedDate, Campaign.Name
				FROM Opportunity
				WHERE AccountId = :recordId
                ORDER BY LastModifiedDate DESC
		];

		AccountData accountData = new AccountData();
		accountData.account = account;
		accountData.assets = assets;
		accountData.opportunities = opportunities;
		return AccountData;
	}

	/**
	 * WrapperClass
	 * 고객, 자산 목록, 영업기회 목록
	 */
	public class AccountData {
		@AuraEnabled public Account             account         {get;set;}
		@AuraEnabled public List<Asset>         assets          {get;set;}
		@AuraEnabled public List<Opportunity>   opportunities    {get;set;}
	}

	
}