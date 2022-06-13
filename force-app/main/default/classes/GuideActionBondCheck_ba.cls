/****************************************************************************************
  * @filename      : GuideActionBondCheck_ba
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-07-14
  * @group         :
  * @group-content :
  * @description   : 채권/채무 확인서 확인 전(매월 D+4 오전 6시)
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-06-08             Park HE         Create
****************************************************************************************/

public with sharing class GuideActionBondCheck_ba implements Database.Batchable<sObject>, Database.Stateful{

    public String query ;
    public Boolean isNextBatch = true;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isEmpty(query)){
            query = 'Select Id, toLabel(BusinessOffice__c), fm_BusinessOffice__c, Name ';
            query += ' FROM User';
            query += ' WHERE BusinessOffice__c  != null AND IsActive = true and UserType = \'Standard\'';
        }
            return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<User> scope) {
        List<Task> taskList = new List<Task>();
        Task newTask;

        for(User user_temp:scope){
            newTask = new Task();
            newTask.OwnerId = user_temp.Id;
            newTask.Type__c = 'Guide';
            newTask.ActivityDate = System.today();
            newTask.Status = 'Completed';
            newTask.Subject = '[채권/채무확인 준비]';
            newTask.Description = '채권/채무확인서 준비 기간입니다. 담당하시는 대리점에 대시보드 등을 참고해 주시기 바랍니다.';
            newTask.CustomAlert__c = true;
            taskList.add(newTask);
        }
        // 작업 Insert
        if(taskList.size() > 0) insert taskList;
    }
    public void finish(Database.BatchableContext param1) {
       
    }
}