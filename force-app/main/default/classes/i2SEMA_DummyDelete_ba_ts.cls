/****************************************************************************************
  * @filename      : i2SEMA_DummyDelete_ba_ts
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/21 3:33 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : DummyDelete_ba Test Class
  * @tester        : i2SEMA_DummyDelete_ba_ts_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2019.12.05 3:33 PM     jeongsi       Create
****************************************************************************************/

@isTest
public class i2SEMA_DummyDelete_ba_ts {

    @TestSetup
    static void setData(){
        IF_SEMA_SFDC_Dummy__c dummy = new IF_SEMA_SFDC_Dummy__c();
        dummy.IF_Id__c              = 'IF_SEMA_SFDC_0001';
        dummy.mt_report_code_ib__c  = '-9998';
        dummy.code_message__c       = 'nested exception is org.apache.ibatis.exceptions.TooManyResultsException: Expected one result (or null) to be returned by selectOne(), but found: 2';
        dummy.noti_group_id__c      = 'a0N2w000000VFplEAG';
        dummy.noti_id__c            = 'a0P2w000000y0rAEAQ';
        dummy.SucessYN__c           = 'Y';
        dummy.recipient_num__c      = '01012341234';
        insert dummy;
    }

    static testmethod void init() {

        Test.startTest();

        i2SEMA_DummyDelete_ba batch = new i2SEMA_DummyDelete_ba('IF_SEMA_SFDC_Dummy__c');
        Database.executeBatch(batch, 1);

        Test.stopTest();
    }
}