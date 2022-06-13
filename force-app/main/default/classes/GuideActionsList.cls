/****************************************************************************************
  * @filename      : GuideActionsList
  * @projectname   : LS 엠트론
  * @author        : i2max_my.Seo
  * @date          : 2020-03-10 오전 7:28
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : GuideActionsList_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-03-15 오전 7:28     i2max_ms             Create
****************************************************************************************/
public with sharing class GuideActionsList {

    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public Id currentUserId {get;set;}
    }

    /**
     * 초기 거래
     *
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static I2ComClass.InitData init() {
        InitData initData = new InitData();
        initData.currentUserId = UserInfo.getUserId();
        return initData;
    }

    /**
     * Guide Action 리스트 조회
     * 대상 : 개인 Task 정보 조회.
     * 재조회를 해야하기에 Cacheable=true 설정 안함
     * 
     *
     * @param recordId : RecordId
     * @param targetObject : Target SObject명
     *
     * @return List<SObject>
    */
    @AuraEnabled
    public static List<TaskData> getGuideActionList(final String recordId, final String targetObject){
        System.debug('------------------------');
        System.debug(System.LoggingLevel.INFO, 'recordId :' + recordId + ', targetObject : ' + targetObject);
        List<TaskData> guideTasks = new List<TaskData>();
        List<Task> sourceTasks = new List<Task>();
        if(targetObject == 'Home') {
            // Home에서는 볼 수 있는 데이터 전부 처리.
            sourceTasks = [SELECT Id, OwnerId, Subject, Description, Status, ActivityDate, IsClosed FROM Task WHERE Type__c = 'Guide' AND Status = 'Open' AND IsClosed = false AND OwnerId = :UserInfo.getUserId() ORDER BY ActivityDate DESC LIMIT 5];
        } else {
            // 레코드 별인 경우 개인거 처리
            sourceTasks = [SELECT Id, OwnerId, Subject, Description, Status, ActivityDate, IsClosed FROM Task WHERE Type__c = 'Guide' AND Status = 'Open' AND IsClosed = false AND WhatId = :recordId AND OwnerId = :UserInfo.getUserId()  ORDER BY ActivityDate DESC];
        }
        for(Task t : sourceTasks) {
            guideTasks.add(new TaskData(t));
        }
        return guideTasks;
    }

    /**
     *
     * Task update 이후 재조회
     *
     * @param recordId      RecordId
     * @param targetObject  Target SOject명
     * @param task          update task
     *
     * @return List<SObject>
     */
    @AuraEnabled
    public static void saveCompleted(final Task task){
        System.debug(System.LoggingLevel.INFO, 'task :' + task);

        /*
         * ================================================================
         * task.IsClosed true인 경우에만 Completed 설정
         * 아닌 경우에는 별도 에러없이 무시함.
         * ================================================================
         */
        if(task.IsClosed == true) {
            task.Status = 'Completed';
            //============================================================================
            // task.CompletedDateTime 는 writeable이 아님
            //============================================================================
            //task.CompletedDateTime = Datetime.now();
            update task;
        }
    }

    /**
     *
     * Task update 이후 재조회
     *
     * @param recordId      RecordId
     */
    @AuraEnabled
    public static void saveCompletedById(final String recordId){
        System.debug(System.LoggingLevel.INFO, 'taskId :' + recordId);
        /*
         * ================================================================
         * task.IsClosed true인 경우에만 Completed 설정
         * 아닌 경우에는 별도 에러없이 무시함.
         * ================================================================
         */
        Task task = new Task(Id = recordId);
        task.Status = 'Completed';
        update task;

    }

    /**
     * Guide Action 리스트 조회
     * 스크립트 기능
     * @param recordId : RecordId
     * @param targetObject : Target SObject명
     *
     * @return List<SObject>
     */
/*    @AuraEnabled(Cacheable=true)
    public static List<SObject> getGuideActionList(final Id recordId, final String targetObject){
        System.debug(System.LoggingLevel.INFO, 'recordId :' + recordId + ', targetObject : ' + targetObject);
        return GuideActionService.getGuideActions(recordId, targetObject);
    }*/

    public class TaskData {
        @AuraEnabled public Task task { get; set; }
        @AuraEnabled public String content {
            get {
                return String.isEmpty(task.Description) ? '내용없음' : task.Description.replace('\n', '<br/>');
            }
            set;
        }
        public TaskData(Task task) {
            this.task = task;
        }
    }

   /* public static void temp() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }*/
}