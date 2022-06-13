/**
 * Created by MS on 2020-08-26.
 */

public with sharing class SFDCHealthCheck {

	public Datetime currentDatetime {get;set;}
	public SFDCHealthCheck() {
		currentDatetime = Datetime.now();
	}
}