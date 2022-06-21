/****************************************************************************************
 * @filename      : lsMSalesAccountSearch
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-10 오전 10:12
 * @group         :
 * @group-content :
 * @description   : [모바일] 고객 검색 : 판매기회
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
public with sharing class lsMSalesAccountSearch {
	/**
	 *
	 * init
	 * @param
	 * @return
	 * 고객카드 생성 or 수정
	 */
//	@AuraEnabled
//	public static void init() {
//	}


	/**
	 * 제품 시리즈 구함
	 * @return List<I2ComClass.Option>
	 */
	@AuraEnabled(Cacheable=true)
	public static List<I2ComClass.Option> getSeriesOptions() {
		return I2ComUtil.makePickListOptions('Product2', 'Series__c', false, true);
	}

	/**
	 * 제품 시리즈의 디펜던시 마력을 구함
	 * @param series 제품 시리즈
	 *
	 * @return List<I2ComClass.Option>
	 */
	@AuraEnabled(Cacheable=true)
	public static List<I2ComClass.Option> getHorsePowerStandardOptions(final String series) {
		System.debug(System.LoggingLevel.INFO, 'series :' + series);
		return I2ComDependencyUtil.getDependentPickListOptions('Product2', 'Series__c', 'HorsePowerStandard__c', series,true, true);
	}

	/**
     * 검색
     *
     * @param reqData
     * @param pageSize
     * @param pageNumber
     *
     * @return
     */
	@AuraEnabled
	public static I2ComClass.ResData search(String reqData, Integer pageSize, Integer pageNumber) {

		System.debug(System.LoggingLevel.INFO, reqData);

		String objectName = '';
		String whereClause = '';

		System.debug(reqData);

		Map<String, String> paramMap = I2ComHelper.gfnCheckCondition(reqData);

		whereClause = 'WHERE RecordType.DeveloperName = \'PersonAccount\' AND IsDelete__c = false AND fm_IsUnKnown__c = false';
		if(I2ComHelper.gfnHasCondition(paramMap, 'searchType') && 'Opportunity'.equals(paramMap.get('searchType'))) {
			// 기회 조회(상담)
			whereClause = ' AND Id IN ( SELECT  AccountId  FROM Opportunity WHERE Id != null AND StageName IN (\'상담\', \'견적\', \'계약\') ';
			if(I2ComHelper.gfnHasCondition(paramMap, 'srchName')) {
				whereClause += ' AND Account.Name LIKE \'%' + paramMap.get('srchName') + '%\'' + '\n';
			}
			if(I2ComHelper.gfnHasCondition(paramMap, 'srchDate')) {
				whereClause += ' AND CreatedDate = LAST_N_DAYS:' + paramMap.get('srchDate') + '\n';
			}
			whereClause += ' ) ';
			//else if 사용 여부 질문.
		} else if(I2ComHelper.gfnHasCondition(paramMap, 'searchType') && 'Asset'.equals(paramMap.get('searchType'))) {
			// 자산 조회
			whereClause = ' AND Id IN ( SELECT  Customer__c FROM Asset USING SCOPE team WHERE InventoryType__c = \'실판매\' ';
			if(I2ComHelper.gfnHasCondition(paramMap, 'srchName')) {
				whereClause += ' AND (Customer__r.Name LIKE \'%' + paramMap.get('srchName') + '%\'' + '\n';
				whereClause += ' OR Product2.Name LIKE \'%' + paramMap.get('srchName') + '%\')' + '\n';
			}
			if(I2ComHelper.gfnHasCondition(paramMap, 'srchSeries')) {
				whereClause += ' AND Product2.Series__c = \'' + paramMap.get('srchSeries') + '\' \n';
			}
			if(I2ComHelper.gfnHasCondition(paramMap, 'srchHorsePowerStandard')) {
				whereClause += ' AND Product2.HorsePowerStandard__c = \'' + paramMap.get('srchHorsePowerStandard') + '\' \n';
			}
			if(I2ComHelper.gfnHasCondition(paramMap, 'srchPurchaseDate')) {
				Integer nPurchaseDate = Integer.valueOf(paramMap.get('srchPurchaseDate'));
				//구매년도
				if(nPurchaseDate == 1) {
					whereClause += ' AND SalesDate__c >= LAST_N_YEARS:' + nPurchaseDate + ' \n ';
				} else {
//					whereClause += ' AND SalesDate__c = LAST_N_YEARS:' + nPurchaseDate + ' \n ';
					whereClause += ' AND SalesDate__c = LAST_N_YEARS:' + nPurchaseDate  + ' \n';
					whereClause += ' AND SalesDate__c < LAST_N_YEARS:' + (nPurchaseDate -1)   + ' \n';
				}
			}
			whereClause += ' ) ';
		} else {
			// Account 조회
			if(I2ComHelper.gfnHasCondition(paramMap, 'srchName')) {
				whereClause += ' AND Account.Name LIKE \'%' + paramMap.get('srchName') + '%\'' + '\n';
			}
		}

		whereClause = I2ComHelper.gfnRefineCondition(whereClause);
		System.debug('whereClause : ' + whereClause);

		I2ComClass.ResData resData = I2ComHelper.gfnQuery(
				'Id, Name, LastModifiedDate, PersonMobilePhone, CustomerStatus__c, FarmingForm__c, FarmingArea__c, Fm_Mobile__c, (SELECT Id, Name, Product2.Name, SalesDate__c FROM Assets  ), (SELECT Id, Name FROM Opportunities ) ',
				'Account',
				whereClause,
				'ORDER BY LastModifiedDate DESC, Name ASC ',
				pageSize,
				pageNumber
		);

		return resData;
	}

	/**
	 * search가 아닌 다른 메소드명 호출 테스트
	 * client controller 와 Name이 동일하면 안됨
	 *
	 * @param reqData
	 * @param pageSize
	 * @param pageNumber
	 *
	 * @return
	 */
	@AuraEnabled
	public static I2ComClass.ResData getSearch(String reqData, Integer pageSize, Integer pageNumber){
		return search(reqData, pageSize, pageNumber);
	}
}