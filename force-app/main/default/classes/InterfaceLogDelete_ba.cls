/****************************************************************************************
  * @filename      : InterfaceLogDelete_ba
  * @projectname   : LS
  * @author        : ldb3100
  * @date          : 2020-09-03    
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log  
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-09-03              ldb3100         Create
****************************************************************************************/
global without sharing class InterfaceLogDelete_ba implements Database.Batchable<sObject>, Database.Stateful {            //Batch Log
    public Decimal lastDay;

    public database.querylocator start(Database.BatchableContext BC) {
        lastDay = -30;
        String objName = 'IF_LOG__c';
        String day = String.valueOf(Date.today().addDays(Integer.valueOf(lastDay))) + 'T23:59:59.000Z'; //30일이 지나면 삭제
        String query = '';
        query += 'SELECT Id';
        query += ' FROM';
        query += ' ' + objName;
        query += ' WHERE createdDate <= ' + day;
        System.debug('objName :'+objName);
        System.debug('day :'+day);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Sobject> scope) {
        System.debug('-------------------- [Execute] --------------------');
        delete scope;
    }

    global void finish(Database.BatchableContext BC) { }
}