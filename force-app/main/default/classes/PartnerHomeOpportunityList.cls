/****************************************************************************************
  * @filename      : PartnerHomeOpportunityList
  * @projectname   : LS
  * @author        : i2max
  * @date          : 2020-05-08
  * @group         :
  * @group-content :
  * @description   : 파트너홈 최근 상담 조회 : 최대 4건.
  * @tester        : PartnerHomeOpportunityList_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-08         i2max          Create
****************************************************************************************/
public with sharing class PartnerHomeOpportunityList {

	/**
	 * 초기 거래 데이터
	 */
	public class InitData extends I2ComClass.InitData {
	}

	@AuraEnabled
	public static I2ComClass.InitData init() {
		InitData initData = new InitData();
		return initData;
	}


	/**
	 * 공지사항 홈 리스트 조회
	 *
	 * @return List<SObject>
	*/
	@AuraEnabled
	public static Map<String, List<Opportunity>> getOpportunityList(){
		// 기회 정보 조회
		List<Opportunity> opportunities = [
				SELECT Id, Account.Name, InterestModel__r.Name, Name, CloseDate, Amount, StageName, LastModifiedDate, Campaign.Name
				FROM Opportunity
				ORDER BY LastModifiedDate DESC
				LIMIT 4
		];
		Map<String, List<Opportunity>> resultData = new Map<String, List<Opportunity>>();
		Integer idx = 0;
		List<Opportunity> opptys1 = new List<Opportunity>();
		List<Opportunity> opptys2 = new List<Opportunity>();
		for(Opportunity r : opportunities) {
			if(idx < 2) opptys1.add(r);
			else        opptys2.add(r);
			idx++;
		}
		resultData.put('list1', opptys1);
		resultData.put('list2', opptys2);
		return resultData;
	}
}