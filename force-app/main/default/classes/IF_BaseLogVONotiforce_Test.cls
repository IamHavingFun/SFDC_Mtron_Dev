/****************************************************************************************
  * @filename      : IF_BaseLogVONotiforce_Test
  * @projectname   : Notiforce PD3 Unmanaged
  * @author        : i2max_H2005109 
  * @date          : 2020-07-13 오전 9:00
  * @group         : e.g)tab name
  * @description   : 
  * @reference     : 
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-07-13 오전 9:00     i2max_H2005109       Create
****************************************************************************************/
@IsTest
private class IF_BaseLogVONotiforce_Test {
	  static testMethod void myUnitTest() {	
    	Notiforce_IF_LOG__c ifLogInfo;
    	String inputBody = '';
    	String outputBody = '';
	 	
	 	IF_BaseLogVONotiforce restLog = new IF_BaseLogVONotiforce(ifLogInfo, inputBody, outputBody);
	 	IF_BaseLogVONotiforce restLog_2 = new IF_BaseLogVONotiforce(ifLogInfo, null, null);
	 	
	 }
    
}