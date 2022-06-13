/****************************************************************************************
  * @filename       : i2SEMA_BatchLogger
  * @projectname    : i2sema
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-06 오후 3:28
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : i2SEMA_BatchLogger_ts.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-06 오후 3:28     i2max_byeon.jw       Create
****************************************************************************************/

public inherited sharing class i2SEMA_BatchLogger {
    private BatchLog__c bl;
    private String sLog;
    private String sError;

    public i2SEMA_BatchLogger(String jobId, String cls) {
        bl = new BatchLog__c();
        bl.cronID__c    = jobId;                                //Job ID
        bl.Name         = cls.substring(0,cls.indexOf(':'));    //Class Name
        sLog = '';
        sError = '';
    }

    public void start() {
        start('Start!!');
    }
    public void start(String log) {
        bl.startTime__c = System.now();
        log(log, bl.cronID__c);
    }

    public void finish() {
        finish('Finish!!');
    }
    public void finish(Integer gCnt, Integer tCnt) {
        finish('Finish!!', gCnt, tCnt);
    }
    public void finish(String log) {
        bl.EndTime__c = System.now();
        log(log, bl.cronID__c);
    }
    public void finish(String log, Integer gCnt, Integer tCnt) {
        bl.EndTime__c = System.now();
        bl.guessCnt__c  = gCnt;
        bl.totalCnt__c  = tCnt;
        log(log, bl.cronID__c);
    }
    public void log(String log, String cronId) {
        //system.debug('============== log ['+cronId+']');
        List<AsyncApexJob> apexJobs = [SELECT CreatedById, JobItemsProcessed,Status,TotalJobItems,ApexClass.name FROM AsyncApexJob WHERE Id = :cronId];
        if( !apexJobs.isEmpty() ) {
            AsyncApexJob apexJob = apexJobs[0];

            sLog += '[' + apexJob.Status + '] : [' + String.valueOf(System.now()) + '] (No : '+ apexJob.JobItemsProcessed + '/' + apexJob.TotalJobItems +') <br>';
            sLog += 'Debug Log : ' + log + '<br>';
            sLog += '=================================================================<br>';
            bl.Status__c = apexJob.Status;
            bl.log__c = sLog;
            bl.Error__c = sError;
            bl.User__c = apexJob.CreatedById;
            bl.guessSize__c = apexJob.TotalJobItems;
            bl.totalSize__c = apexJob.JobItemsProcessed;

            upsert bl;
        }
    }

    public void log(String log) {
        if(sLog.length()>130000) {
            if(!sLog.endsWith('.....')) {
                sLog += '.....';
            }
            return;
        }
        sLog += '[' + String.valueOf(System.now()) + '] <br>';
        sLog += 'Debug Log : ' + log + '<br>';
        sLog += '=================================================================<br>';
    }
    public void error(String log) {
        if(sError.length()>130000) {
            if(!sError.endsWith('.....')) {
                sError += '.....';
            }
            return;
        }
        sError += '[' + String.valueOf(System.now()) + '] <br>';
        sError += 'Error Log : ' + log+' <br>';
        sError += '=================================================================<br>';
    }
    public String getError() {
        return sError;
    }
}