/****************************************************************************************
  * @filename      : ContentDocumentLink_tr
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-05-06
  * @group         :
  * @group-content :
  * @description   : 제품 컨텐츠들을 파트너 사용자에게도 공개 하기 위해서 Visibility를 AllUser로 지정 한다.
  * @tester        : ContentDocumentLink_tr_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-06         i2max          Create
****************************************************************************************/

public with sharing class ContentDocumentLink_tr extends TriggerHandler {

	private Set<String> checkObjects = new Set<String>{
			'ProductContents__c', 'Product2', 'Case', 'PDI__c', 'WarrantyClaim__c', 'Campaign'
	};

	public override void beforeInsert() {
		this.setDocumentLinkShare(Trigger.new);
	}

	private void setDocumentLinkShare(List<ContentDocumentLink> scope) {
		for(ContentDocumentLink r : scope) {
			if(checkObjects.contains(String.valueOf(r.LinkedEntityId.getSobjectType()))) {
				r.Visibility = 'AllUsers';
			}
		}
	}
}