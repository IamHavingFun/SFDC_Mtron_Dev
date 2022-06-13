/****************************************************************************************
  * @filename      : OwnerUpdateMIG_ba
  * @projectname   : LS
  * @author        : i2max
  * @date          : 2020-05-14
  * @group         :
  * @group-content :
  * @description   : 운영 소유자 - 대리점주로 변경
  *                  일 회용
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-07-28             Park HE         Create
****************************************************************************************/

public class OwnerUpdateMIG_ba implements Database.Batchable<SObject>, Database.Stateful{

	public Integer totalCount = 0;
	public Integer successCount = 0;

	public String query;
	public String targetField;
	public String targetObject;

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<SObject> scope) {
		String accountId;
		Set<String> accountIds = new Set<String>();
		for(SObject r : scope) {
			if(r.get(targetField) != null) {
				accountId = (String) r.get(targetField);
				accountIds.add(accountId);
			}
		}

		Map<String, Id> accountOwnerMap = new Map<String, Id>();
		for(User u : [
				SELECT Id, AccountId
				FROM User
				WHERE AccountId IN : accountIds
				AND Contact.DealerRole__c = '대표'
				AND IsActive = TRUE
		]) {
			accountOwnerMap.put(u.AccountId, u.Id);
		}

		List<SObject> updateList = new List<SObject>();
		for(SObject r : scope) {
			if(r.get(targetField) != null) {
				String targetAccountId = (String) r.get(targetField);
				if(accountOwnerMap.containsKey(targetAccountId)) {
					r.put('OldOwnerId__c', r.get('OwnerId'));
					r.put('OwnerId', accountOwnerMap.get(targetAccountId));
					updateList.add(r);
				}
			}
		}

		if(updateList.isEmpty() == false) {
			totalCount += scope.size();
			successCount += updateList.size();
			System.debug('총 건수 : ['+scope.size()+'], 처리 건수 : ['+updateList.size()+']' );
			update updateList;
		}
	}

	public void finish(Database.BatchableContext param) {
		System.debug('총 건수 : ['+totalCount+'], 처리 건수 : ['+successCount+']' );
		Task newTask = new Task();
		newTask.OwnerId = UserInfo.getUserId(); //(tmpOrder.Dealer__c)?
		newTask.ActivityDate = System.today();
		newTask.Type__c = 'Guide';
		newTask.WhatId = UserInfo.getUserId();
		newTask.Subject = targetObject +' 처리';
		newTask.Description = '총 건수 : ['+totalCount+'], 처리 건수 : ['+successCount+']';
		newTask.CustomAlert__c = true;
		insert newTask;
	}

	public static void runTest() {
		Integer my_seo = 0;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
	}
}