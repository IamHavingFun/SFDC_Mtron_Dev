/****************************************************************************************
  * @filename      : i2SEMA_IFNotificationCancel_qu
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/03/17 9:38 AM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 예약발송 취소 Interface
  * @tester        : i2SEMA_IFNotificationCancel_qu_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/03/17 9:38 AM     i2max_shlee       Create
    0.2     2020/04/13 2:35 PM     i2max_shlee       Rename NotificationCancelInterface_qu > i2SEMA_IFNotificationCancel_qu
****************************************************************************************/
global with sharing class i2SEMA_IFNotificationCancel_qu  implements Queueable, Database.AllowsCallouts {
    private List<Notification__c> notifications;
    private NotificationGroup__c notificationGroup;
    /**
     * @description 메세지 전송 실행, Template에 속한 파일은 전달하지 않음 > Template IF에서 사전 전송했으므로 제외
     * @param QueueableContext
     */
    global void execute(QueueableContext qc){
        system.debug('===========>> Queueable Execute');
        system.debug(this.notifications);

        Map<Id,List<Notification__c>> groupNotificationMap = new Map<Id,List<Notification__c>>();
        if(notifications == null && notifications.isEmpty()) { //NotificationGroup 관련 예약발송 전부 취소
            groupNotificationMap.put(notificationGroup.Id, null);
        } else { //notigroup 개별 취소
            Set<Id> notificationIds = new Set<Id>();
            for( Notification__c noti : this.notifications ){
                notificationIds.add(noti.Id);
            }
            Map<Id,Notification__c> notificationMap = new Map<Id,Notification__c>([SELECT Id
                    ,NotificationGroup__c
                    ,NotificationTemplate__c
                    ,IsSendingReservation__c
                    ,SendingTime__c
                    ,Title__c
                    ,Content__c
                    ,Channel__c
                    ,Phone__c
                    ,LABEL1__c
                    ,LABEL2__c
                    ,LABEL3__c
                    ,LABEL4__c
                    ,LABEL5__c
            FROM Notification__c
            WHERE Id IN:notificationIds ]);

            // Gruop 별 Notification 목록
            List<Notification__c> groupNotifications = null;
            for( Notification__c noti : notificationMap.values() ){
                groupNotifications = groupNotificationMap.containsKey(noti.NotificationGroup__c) ? groupNotificationMap.get(noti.NotificationGroup__c) : new List<Notification__c>();
                groupNotifications.add(noti);
                groupNotificationMap.put( noti.NotificationGroup__c , groupNotifications );
            }
        }


        system.debug('========>> Group Notifications');
        system.debug(groupNotificationMap);

        /*-----------------------------------------------
         * 02.20 변준우 수정
            - 템플릿,파일로 인해 Group 별로 발송
        -------------------------------------------------*/
        // Group 별 발송처리
        // TODO : 이벤트성으로 호출되는 Noti 들은 그룹 별 IF 호출이 필요한데, Chain Job 으로 구성해야할지?
        IF_SFDC_SEMA_0006               instance = IF_SFDC_SEMA_0006.getInstance();
        IF_SFDC_SEMA_0006.InputDIH      input   = new IF_SFDC_SEMA_0006.InputDIH();
        IF_SFDC_SEMA_0006.OutputDIH     result;
        IF_SFDC_SEMA_0006.INPUT_T_DATA  t_data;
        IF_SFDC_SEMA_0006.T_PER         t_per;
        Datetime                        now;

        List<Notification__c> groupNotifications = null;
        Notification__c noti = null;
        for( Id groupId : groupNotificationMap.keySet() ){
            groupNotifications = groupNotificationMap.get(groupId);

            t_data = new IF_SFDC_SEMA_0006.INPUT_T_DATA();

            if(i2SEMA_Util.isEmpty(groupNotifications) || groupNotifications.isEmpty()) { //NotiGroupId 기준 예약취소
                /*---------------------------------------
                 * NotiGroupId 기준 예약발송 취소
                 ---------------------------------------*/
                t_data.noti_group_id = groupId;  // SFDC 메시지 그룹 아이디
            } else { //개별 Notification 예약발송 취소
                system.debug('------------->> Cancel Notifications');
                system.debug(groupNotifications);
                /*---------------------------------------
                 * 개별 NotificationId 기준 예약발송 취소
                 ---------------------------------------*/
                noti = groupNotifications[0];
                t_data = new IF_SFDC_SEMA_0006.INPUT_T_DATA();
                t_data.noti_group_id = groupId;       // SFDC 메시지 그룹 아이디

                // 건별 처리
                t_data.t_per = new List<IF_SFDC_SEMA_0006.T_PER>();
                for( Notification__c eachNoti : groupNotifications ){
                    /*---------------------------------------
                     * 개인화 필드 정보
                     ---------------------------------------*/
                    t_per = new IF_SFDC_SEMA_0006.T_PER();
                    t_per.noti_id       =  noti.Id;                            // SFDC 개인화 필드 아이디
                    t_data.t_per.add(t_per);
                }
            }
            //적재
            input.request.payload.t_data.add(t_data);
        }
        System.debug('input.request.payload.t_data : '+input.request.payload.t_data);
        //Interface Request 실행
        if(!input.request.payload.t_data.isEmpty()){
            result = instance.execute(input);
        }
        //업데이트 시간 취득
        now = Datetime.now();
        //Interface Response 처리
        List<NotificationGroup__c> updateNotificationGroups = new List<NotificationGroup__c>();
        NotificationGroup__c ng = null;
        List<Notification__c> updateNotifications = new List<Notification__c>();
        for( Id groupId : groupNotificationMap.keySet() ){
            groupNotifications = groupNotificationMap.get(groupId);

            if (!groupNotifications.isEmpty()) {
                for (Notification__c eachNoti : groupNotifications) {
                    if ('S'.equals(result.response.header.ifResult)) { //성공
                        eachNoti.msg_status__c = 'Canceled';
                        eachNoti.IF_RequestedDate__c = now;
                    } else { //실패
                        eachNoti.msg_status__c = 'Failed request to cancel';
                        eachNoti.IF_FailedDate__c = now;
                    }
                    updateNotifications.add(eachNoti);
                }
            }

            ng = new NotificationGroup__c();
            ng.Id = groupId;
            if ('S'.equals(result.response.header.ifResult)) {
                ng.IF_Status__c = 'Canceled';
                ng.IF_RequestedDate__c = now;
            } else {
                ng.IF_Status__c = 'Failed request to cancel';
                ng.IF_FailedDate__c = now;
            }
            updateNotificationGroups.add(ng);
        }

        if(updateNotifications.size() > 0)      update updateNotifications;
        if(updateNotificationGroups.size() > 0) update updateNotificationGroups;
    }

    /**
     * @description 메세지 예약취소 인터페이스 실행 Queueable 클래스 생성자 호출
     * @param notifications {List<Notification__c>} 전송대상 메세지 List
     */
    global i2SEMA_IFNotificationCancel_qu (NotificationGroup__c notificationGroup){
        this.notificationGroup = notificationGroup;
    }

    /**
     * @description 메세지 예약취소 인터페이스 실행 Queueable 클래스 생성자 호출
     * @param notifications {List<Notification__c>} 전송대상 메세지 List
     */
    global i2SEMA_IFNotificationCancel_qu (List<Notification__c> notifications){
        this.notifications = notifications;
    }

    /**
     * @description 메세지 예약취소 인터페이스 실행 Queueable 클래스 생성자 호출
     * @param notifications {Notification__c} 전송대상 메세지 List
     */
    global i2SEMA_IFNotificationCancel_qu (Notification__c notification){
        this.notifications = new List<Notification__c>();
        notifications.add(notification);
    }
}