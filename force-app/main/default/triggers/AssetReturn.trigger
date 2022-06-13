/**
 * Created by MS on 2021-07-02.
 */

trigger AssetReturn on AssetReturn__c (after update) {
	new AssetReturn_tr().run();
}