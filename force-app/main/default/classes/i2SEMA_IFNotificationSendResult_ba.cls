/****************************************************************************************
  * @filename      : i2SEMA_IFNotificationSendResult_ba
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/22 4:12 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 예약 발송 IF 요청후 상태 업데이트 + 메세지 결과 요청 IF Queuable 호출
  * @tester        : i2SEMA_IFNotificationSendResult_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/22 4:12 PM     i2max_shlee       Create
****************************************************************************************/
global with sharing class i2SEMA_IFNotificationSendResult_ba implements Database.Batchable<sObject>,Database.Stateful {

    /* manual execute code
    i2SEMA_IFNotificationSendResult_ba batch = new i2SEMA_IFNotificationSendResult_ba();
    Database.executeBatch(batch, 2000);
    */

    public Map<String, Map<String, Object>> responseMap = null;

    public i2SEMA_BatchLogger logger;
    public Date ifDate;                // Interface Date

    global i2SEMA_IFNotificationSendResult_ba(Map<String, Map<String, Object>> responseMap) {
        this.responseMap = responseMap;
        System.debug('i2SEMA_IFNotificationSendResult_ba responseMap : '+responseMap);
    }

    /**
     * @description I/F 대상 추출
     * @param bc
     * @return
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        logger = new i2SEMA_BatchLogger(BC.getJobId(), String.valueOf(this));
        logger.start('Start!!');

        String query = 'SELECT Id, Name, '
                + 'NotificationGroup__c, NotificationTemplate__c, NotificationAutomaticSetting__c, TargetId__c, '
                + 'Account__c,Contact__c,Lead__c,User__c, Phone__c, '
                + 'Channel__c, Title__c, Content__c, RawContents__c, '
                + 'IsSendingReservation__c, SendingTime__c, '
                + 'KakaoFriendTalkImage__c, fm_KakaoFriendTalkImageURL__c, '
                + 'BroadCast__c, fm_Label1Usage__c, fm_Label2Usage__c, fm_Label3Usage__c, fm_Label4Usage__c, fm_Label5Usage__c, '
                + 'LABEL1__c, LABEL2__c, LABEL3__c, LABEL4__c, LABEL5__c, '
                + 'msg_status__c, IF_CompletedDate__c, IF_FailedDate__c, IF_RequestedDate__c, '
                + 'ErrorMessage__c, Validity__c, '
                + 'ORGID__c, ORGName__c, '
                + 'SystemModstamp, CreatedById, CreatedDate, '
                + 'LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, '
                + 'IsDeleted '
                + 'FROM Notification__c '
                + 'WHERE IsSendingReservation__c = TRUE '
                + 'AND Validity__c = TRUE ' //Validation 통과
                + 'AND msg_status__c = \'Pending\' ' //Validation 통과
                + 'AND SendingTime__c >= TOMORROW ';
        return Database.getQueryLocator(query);

    }

    /**
     * @description IF 결과 업데이트
     *              1. Notification IF 결과 업데이트
     *              2. Notification Group IF 결과 업데이트
     *              3. Activity Task 생성
     *              4. Notification Log 생성
     * @param bc
     * @param scope
     */
    global void execute(Database.BatchableContext bc, List<Notification__c> scope) {

        try {
            /**----------------------------------------
             * IF 결과 업데이트
             * 1. Notification IF 결과 업데이트
             * 2. Notification Group IF 결과 업데이트
             * 3. Activity Task 생성
             * 4. Notification Log 생성
             ----------------------------------------*/
            Datetime now = Datetime.now();
            //Interface Response 처리
            List<NotificationGroup__c> updateNotificationGroups = new List<NotificationGroup__c>();
            List<Notification__c> updateNotifications = new List<Notification__c>();
            List<Task> createTasks = new List<Task>();
            List<NotificationLog__c> createLogs = new List<NotificationLog__c>();
            NotificationGroup__c ng = null;
            NotificationLog__c log = null;
            Task task = null;

            Map<String, Map<String, Object>> notiGroupMap = new Map<String, Map<String, Object>>();
            Map<String, Object> ifResultMap = null;

            for (Notification__c noti : scope) {
                if(!responseMap.containsKey(noti.Id)) continue;

//                System.debug('noti : '+noti);
                //Boolean
                ifResultMap = responseMap.get(noti.Id);
                notiGroupMap.put(noti.NotificationGroup__c, ifResultMap);

                if(i2SEMA_Util.isEmpty(noti.User__c)) {
                    task                    = new Task();
                    task.Notification__c    = noti.Id;
                    task.Subject            = noti.Title__c;
                    task.Type               = noti.Channel__c;
                    task.Priority = 'Normal';

                    if (i2SEMA_Util.isNotEmpty(noti.Account__c)) {
                        task.WhatId = noti.Account__c;
                    } else if (i2SEMA_Util.isNotEmpty(noti.Contact__c)) {
                        task.WhoId = noti.Contact__c;
                    } else if (i2SEMA_Util.isNotEmpty(noti.Lead__c)) {
                        task.WhoId = noti.Lead__c;
                    }
//                    if (i2SEMA_Util.isNotEmpty(noti.User__c)) {
//                        task.WhatId = noti.User__c;
//                    }

                    if ((Boolean)ifResultMap.get('ifResult')) { //성공
                        task.Status = 'In Progress';
                    } else { //실패
                        task.Status = 'Failed';
                    }
                    System.debug('task : '+task);
                    createTasks.add(task);
                }

                //Log
                log = new NotificationLog__c();
                log.Notification__c = noti.Id;
                log.RequestDateTime__c = now;

                if ((Boolean)ifResultMap.get('ifResult')) { //성공
                    noti.msg_status__c = 'Requested';
                    noti.IF_RequestedDate__c = now;
                    //Log
                    log.Status__c = 'Requested';
                } else { //실패
                    noti.msg_status__c = 'Failed request to send';
                    noti.IF_FailedDate__c = now;
                    //Log
                    log.Status__c = 'Fail';
                    log.ResponseMessage__c = String.valueOf(ifResultMap.get('ifFailMsg'));
                    log.IF_FailCode__c = String.valueOf(ifResultMap.get('ifFailCode'));
                }

                createLogs.add(log);
                updateNotifications.add(noti);
            }

            //Update IF Resutl for Notification Group
            for (Id groupId : notiGroupMap.keySet()) {
                ifResultMap = notiGroupMap.get(groupId);

                //Notification이 없으면, 스킵
                if (ifResultMap.isEmpty()) continue;

                ng = new NotificationGroup__c();
                ng.Id = groupId;
                if ((Boolean)ifResultMap.get('ifResult')) { //성공
                    ng.IF_Status__c = 'Requested';
                    ng.IF_RequestedDate__c = now;
                } else {
                    ng.IF_Status__c = 'Failed request to send';
                    ng.IF_FailedDate__c = now;
                }
                updateNotificationGroups.add(ng);
            }
//            System.debug('createTasks : ' + createTasks);
//            System.debug('createLogs : ' + createLogs);
//            System.debug('updateNotifications : ' + updateNotifications);
//            System.debug('updateNotificationGroups : ' + updateNotificationGroups);
            if (createTasks.size() > 0) insert createTasks;
            if (createLogs.size() > 0) insert createLogs;
            if (updateNotifications.size() > 0) update updateNotifications;
            if (updateNotificationGroups.size() > 0) update updateNotificationGroups;


        } catch (Exception e) {
            System.debug('Error : ' + e.getLineNumber() + ' / ' + e.getMessage());
            logger.log(e.getStackTraceString());
        }
    }

    /**
     * @description Batch 종료
     *                   1. 메세지 결과 로그 요청 IF Queueable 호출
     * @param bc
     */
    global void finish(Database.BatchableContext bc) {
        logger.finish('finish!!');

        //메세지 결과 로그 요청 IF Queueable 호출
        Id jobId = System.enqueueJob(new i2SEMA_IFNotificationLogRequest_qu(Datetime.now()));
        System.debug('i2SEMA_IFNotificationLogRequest_qu : ' + jobId);
    }
}