/****************************************************************************************
  * @filename      : i2SEMA_DummyDelete_ba
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/21 3:32 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : Dummy Object의 레코드들을 Delete 처리한다.
  * @tester        : i2SEMA_DummyDelete_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2019.07.05 3:32 PM     jeongsi       Create
****************************************************************************************/

public with sharing class i2SEMA_DummyDelete_ba implements Database.Batchable<sObject>,Database.Stateful{
/*
i2SEMA_DummyDelete_ba batch = new i2SEMA_DummyDelete_ba('IF_CXP_0225_China_ERP_CXP_DUMMY__c');
Database.executeBatch(batch, 2000);
*/
    public Date         ifDate;				// Interface Date
    public String       SObjectName;        // Dummy Object Name

    public i2SEMA_DummyDelete_ba(String SObjectName) {
        this.SObjectName = SObjectName;
    }
    /**
     * @description 삭제할 Dummy 레코드 추출
     * @param bc
     * @return
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {

        //Interface Date가 없으면 오늘날짜로 셋팅.
        if(ifDate == null) ifDate = Date.today().addDays(-7);

        //TODO: 어떤 범위의 데이터를 삭제할 지 정해지지 않았으므로, 협의가 완료되면 삭제할 더미 범위 설정 필요
        DateTime dt = DateTime.newInstance(ifDate,Time.newInstance(0,0,0,0));
        String deleteDt = dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

        String query ='';
        query += 'SELECT Id';
        query += '  FROM ' + SObjectName;               //Dummy Object Name
        query += ' WHERE CreatedDate >= ' + deleteDt;	//7일 이전 Inteface Date 레코드만 조회

        return Database.getQueryLocator(query);
    }

    /**
     * @description Dummy Object의 데이터를 Delete
     * @param bc
     * @param scope
     */
    public void execute(Database.BatchableContext bc, List<SObject> scope) {

        try {
            delete scope;
            DataBase.emptyRecycleBin(scope);
        } catch(Exception e) {
            system.debug(LoggingLevel.ERROR, 'Error Msg : ' + e.getMessage());
        }
    }

    /**
     * @description Batch 종료
     * @param bc
     */
    public void finish(Database.BatchableContext bc) {
        system.debug(LoggingLevel.ERROR, '--- DummyDelete_ba finish ---');
    }

}