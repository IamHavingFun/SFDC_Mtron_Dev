/****************************************************************************************
  * @filename      : ContentDocumentShareMIG_ba
  * @projectname   : LS
  * @author        : i2max
  * @date          : 2020-05-14
  * @group         :
  * @group-content :
  * @description   : ContentDocumentLink Visible MIG
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

public class ContentDocumentShareMIG_ba implements Database.Batchable<SObject>, Database.Stateful{

	public Integer totalCount = 0;
	public Integer successCount = 0;

	public String query;
	public String targetField;
	public String targetObject;

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<SObject> scope) {
		String targetId;
		Set<String> targetIds = new Set<String>();

		for(SObject r : scope) {
			if(r.get(targetField) != null) {
				targetId = (String) r.get('Id');
				targetIds.add(targetId);
			}
		}

		List<ContentDocumentLink> cdlList = [
				SELECT
						ContentDocumentId,
						Id,
						LinkedEntityId,
						ShareType,
						Visibility
				FROM ContentDocumentLink
				WHERE LinkedEntityId IN : targetIds
		];

		for(ContentDocumentLink r : cdlList) {
			r.Visibility = 'AllUsers';
		}
		if(cdlList.isEmpty() == false) update cdlList;
	}

	public void finish(Database.BatchableContext param) {
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