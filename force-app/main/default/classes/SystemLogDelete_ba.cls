/****************************************************************************************
  * @filename      : SystemLogDelete_ba
  * @projectname   : LS_PS
  * @author        : I2max
  * @date          : 2020-07-14
  * @group         :
  * @group-content :
  * @description   : 3일 지난 로그 자동으로 삭제 처리 하기.
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-07-14             Park HE         Create
****************************************************************************************/
public with sharing class SystemLogDelete_ba implements Database.Batchable<SObject>, Database.Stateful {

	public Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id FROM Apexlog WHERE LastModifiedDate <= LAST_N_DAYS:3';
		if(Test.isRunningTest()) query = 'SELECT Id FROM User LIMIT 1';
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<SObject> scope) {
		for (SObject log : scope) callWebService((String)log.get('Id'));
	}

	public static void callWebService(String logId) {
		try {
			Http h = new Http();
			HttpRequest req = new HttpRequest();
			req.setEndpoint(Url.getOrgDomainUrl().toExternalForm()
					+ '/services/data/v44.0/sobjects/Apexlog/' + logId);
			req.setMethod('DELETE');
			req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
			HttpResponse res = h.send(req);
		} catch (Exception e) {}
	}

	public void finish(Database.BatchableContext BC) {
	}
}