/****************************************************************************************
  * @filename      : PartnerHomeProductChangeList
  * @projectname   : LS
  * @author        : i2max
  * @date          : 2020-05-08
  * @group         :
  * @group-content :
  * @description   : 파트너홈 최근 설계변경 : 최대 2건.
  * @tester        : PartnerHomeProductChangeList_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-08         i2max          Create
****************************************************************************************/
public with sharing class PartnerHomeProductChangeList {

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
	 * 설계변경 홈 리스트 조회
	 *
	 * @return List<SObject>
	*/
	@AuraEnabled
	public static List<ProductChange__c> getList(){
		// 기회 정보 조회
		List<ProductChange__c> dataList = [
				SELECT Id, PECN_NAME__c, PMODEL_ID__c, PAPPLY_DATE__c
				FROM ProductChange__c
				WHERE SetDealerPublic__c = '공개'
				ORDER BY LastModifiedDate DESC
				LIMIT 2
		];
		return dataList;
	}
}