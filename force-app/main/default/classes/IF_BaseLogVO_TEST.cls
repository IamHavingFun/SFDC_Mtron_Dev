/****************************************************************************************
  * ProjectName : i2sema
  * File Name   : IF_BaseLogVO_TEST
  * Description : IF_BaseLogVO_TEST Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author       Modification
  * ===============================================================
    1.0  2020. 04. 21.  ldb3100      Create
****************************************************************************************/
@IsTest
private class IF_BaseLogVO_TEST {
	  static testMethod void myUnitTest() {	
    	IF_LOG__c ifLogInfo;
    	String inputBody = '';
    	String outputBody = '';
	 	
	 	IF_BaseLogVO restLog = new IF_BaseLogVO(ifLogInfo, inputBody, outputBody);
	 	IF_BaseLogVO restLog_2 = new IF_BaseLogVO(ifLogInfo, null, null);
	 }
}