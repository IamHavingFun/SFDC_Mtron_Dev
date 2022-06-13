/****************************************************************************************
  * @filename      : Contract_tr
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-05-06
  * @group         :
  * @group-content :
  * @description   : 계약의 인도기일이 등록되면 기회의 인도기일을 업데이트 한다.
  * @tester        : Contract_tr_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-06         i2max          Create
****************************************************************************************/

public with sharing class Contract_tr extends TriggerHandler {

	public override void afterInsert() {
		this.setOpptyUpdate(Trigger.new, null);
	}

	public override void afterUpdate() {
		this.setOpptyUpdate(Trigger.new, (Map<Id, Contract__c>) Trigger.oldMap);
	}

	private void setOpptyUpdate(List<Contract__c> scope, Map<Id, Contract__c> oldMap) {
		List<Opportunity> updateOpportunities = new List<Opportunity>();
		for(Contract__c r : scope) {
			if(oldMap == null || (oldMap.containsKey(r.Id) && oldMap.get(r.Id).CustomerExpectedDate__c != r.CustomerExpectedDate__c)) {
				if(r.Opportunity__c != null) {
					updateOpportunities.add(
							new Opportunity(
									Id = r.Opportunity__c,
									CustomerExpectedDate__c = r.CustomerExpectedDate__c
							)
					);
				}
			}
		}
		if(updateOpportunities.isEmpty() == false && updateOpportunities.size() > 0) update updateOpportunities;
	}
}