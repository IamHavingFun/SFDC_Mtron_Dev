/**
 * Created by MS on 2020-07-01.
 */

public with sharing class lsMSalesQuoteList {

	@AuraEnabled
	public static I2ComClass.ResData search(String reqData, Integer pageSize, Integer pageNumber) {
        String whereClause = '';
        Map<String, String> paramMap = I2ComHelper.gfnCheckCondition(reqData);

        whereClause = ' AND Opportunity__r.StageName = \'견적\' ' + '\n';

		if (I2ComHelper.gfnHasCondition(paramMap, 'name')) {
            final String likeIdioms = '\'%' + String.escapeSingleQuotes(paramMap.get('name')) + '%\'';
			whereClause += ' AND CustomerName__r.Name LIKE ' + likeIdioms + '\n' ;
		}
		whereClause += ' AND fm_IsLossOppty__c = FALSE ';

		whereClause = I2ComHelper.gfnRefineCondition(whereClause);

        I2ComClass.ResData resData = I2ComHelper.gfnQuery(
				'Id, Name, CustomerName__r.Name, CustomerName__r.PersonMobilePhone, Opportunity__r.StageName, LastModifiedDate, ' +
						' (SELECT Product__c, Product__r.Name, Quantity__c, TotalPrice__c, Type__c, UnitPrice__c FROM QuoteLineItems__r WHERE Type__c = \'본체\')  ',
				'Quote__c',
				whereClause,
				'ORDER BY LastModifiedDate DESC',
				pageSize,
				pageNumber
		);
		return resData;
	}
}