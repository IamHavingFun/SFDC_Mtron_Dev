/**
 * Created by MS on 2020-09-01.
 */

public with sharing class MobileAppVersionCheck {
	public String appVersionJsonString {get;set;}
	public MobileAppVersionCheck() {
		IfStaticValue__c staticValue = IfStaticValue__c.getInstance('LSMTRON');
		String appVersion = Test.isRunningTest() ? '1' : staticValue.APP_VERSION__c;
		Map<String, String> appMap = new Map<String, String>();
		appMap.put('VERSION', appVersion);
		appMap.put('CURRENT_TIME', System.now().format());

		appVersionJsonString = JSON.serialize(appMap);
	}
}