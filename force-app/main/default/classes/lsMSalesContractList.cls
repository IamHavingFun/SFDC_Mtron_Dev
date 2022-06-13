/**
 * Created by MS on 2020-07-01.
 */

public with sharing class lsMSalesContractList {

	@AuraEnabled
	public static I2ComClass.ResData search(String reqData, Integer pageSize, Integer pageNumber) {
        String whereClause = '';
        Map<String, String> paramMap = I2ComHelper.gfnCheckCondition(reqData);

		whereClause = ' AND Opportunity__r.StageName = \'계약\' ' + '\n';
        if (I2ComHelper.gfnHasCondition(paramMap, 'name')) {
            final String likeIdioms = '\'%' + String.escapeSingleQuotes(paramMap.get('name')) + '%\'';
            whereClause += ' AND Customer__r.Name LIKE ' + likeIdioms + '\n' ;
        }
		whereClause += ' AND fm_IsLossOppty__c = FALSE ';
        whereClause = I2ComHelper.gfnRefineCondition(whereClause);
        I2ComClass.ResData resData = I2ComHelper.gfnQuery(
				'Id, LastModifiedDate, Customer__r.Name, Customer__r.PersonMobilePhone, Customer__r.PersonContact.Birthdate, Customer__r.Gender__pc, Quote__c, ' +
				'Opportunity__r.StageName, ' +
				'eFormsignStatus__c ,' +
				'(SELECT ProductId__c, ProductId__r.Name, Quanitity__c, TotalPrice__c, fm_Type__c, UnitPrice__c FROM ContractLineItem__r WHERE fm_Type__c = \'본체\' )  ',
				'Contract__c',
				whereClause,
				'ORDER BY LastModifiedDate DESC',
				pageSize,
				pageNumber
		);

		return resData;
	}
}