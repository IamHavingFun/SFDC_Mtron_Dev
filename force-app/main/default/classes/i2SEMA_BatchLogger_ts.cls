/****************************************************************************************
  * @filename      : i2SEMA_BatchLogger_ts
  * @projectname   : i2SEMA Core
  * @author        : snowChoi
  * @date          : 2020/04/21 9:26 AM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : BatchLogger Test Class
  * @tester        : i2SEMA_BatchLogger_ts_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2019.08.26 9:26 AM      snowChoi        Create
****************************************************************************************/
@isTest
private class i2SEMA_BatchLogger_ts {
    @testSetup
    static void setData() {
        List<IF_SEMA_SFDC_Dummy__c> dummies = TestDataFactory.createSObjectList('IF_SEMA_SFDC_Dummy__c', 10);
        i2SEMA_DummyDelete_ba batch = new i2SEMA_DummyDelete_ba('IF_SEMA_SFDC_Dummy__c');
        Database.executeBatch(batch,2000);
    }

    static testmethod void test1() {

        List<AsyncApexJob> jobList = [SELECT CreatedById, JobItemsProcessed,Status,TotalJobItems,ApexClass.name FROM AsyncApexJob LIMIT 1];
        String jobId = jobList[0].Id;
        String log = '0123456789';
        for(Integer i=0; i<15; i++) {
            log += log;
        }

        Test.startTest();

        i2SEMA_BatchLogger logger = new i2SEMA_BatchLogger(jobId, 'i2SEMA_DummyDelete_ba:');
        logger.start();
        logger.finish();
        logger.finish(10, 10);
        logger.log(log);
        logger.log(log);
        logger.error(log);
        logger.error(log);
        logger.getError();

        Test.stopTest();
    }
}