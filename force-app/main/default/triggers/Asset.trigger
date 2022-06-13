/**
 * Created by MS on 2021-04-01.
 */

trigger Asset on Asset (before insert, before update) {
	new Asset_tr().run();
}