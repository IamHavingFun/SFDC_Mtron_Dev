/****************************************************************************************
  * @filename      : i2SEMA_IFNotificationSend_qu
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee
  * @date          : 2020/01/29 5:36 PM
  * @group         : Notification
  * @group-content :
  * @description   : Notification 실시간 발송 IF
  * @tester        : i2SEMA_IFNotificationSend_qu_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                   author            description
  * ===============================================================
    0.1     2020/01/29 5:36 PM     i2max_shlee       Create
    0.2     2020/02/20 12:30 PM    i2max_byeon.jw    Modify (Attachment > ContentDocument 변경)
    0.3     2020/02/24 09:30 AM    i2max_byeon.jw    Modify (Notificatino Group 단위처리 추가)
    0.4     2020/04/13 1:19 PM     i2max_shlee       Rename 0.1     i2SEMA_IFNotificationSend_qu
****************************************************************************************/
global without sharing class i2SEMA_IFNotificationSend_qu implements Queueable, Database.AllowsCallouts { 
    private List<Notification__c> notifications;

    /**
     * @description bulk 메세지 인터페이스 실행 Queueable 클래스 생성자 호출
     * @param notifications {List<Notification__c>} 전송대상 메세지 List
     */
    global i2SEMA_IFNotificationSend_qu (List<Notification__c> notifications){
        this.notifications = notifications;
    }

    /**
     * @description 단일건의 메세지 인터페이스 실행 Queueable 클래스 생성자 호출
     * @param notifications {Notification__c} 전송대상 메세지 List
     */
    global i2SEMA_IFNotificationSend_qu (Notification__c notification){
        this.notifications = new List<Notification__c>();
        notifications.add(notification);
    }


    /**
     * @description 메세지 전송 실행, Template에 속한 파일은 전달하지 않음 > Template IF에서 사전 전송했으므로 제외
     * @param QueueableContext
     */
    global void execute(QueueableContext qc){
        system.debug('===========>> Queueable Execute');
        //system.debug('notifications : '+this.notifications);
        /*-----------------------------------------------
         * 02.20 변준우 추가 (MMS 조건 추가)
            - IF 매핑 컬럼 재조회 NotificationGroup으로 Grouping
        -------------------------------------------------*/
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
                ,LABEL1__c, LABEL2__c, LABEL3__c, LABEL4__c, LABEL5__c
                ,Account__c, Contact__c, Lead__c, User__c
                ,Type__c
                ,ARS_080_Phone__c
        FROM Notification__c
        WHERE Id IN:notificationIds
        AND Validity__c = TRUE]);

        Set<Id> templateUnUsedGroupIds                      = new Set<Id>();                        // 템플릿을 사용하지 않은 Notification Group ID 집합
        // Gruop 별 Notification 목록
        Map<Id,List<Notification__c>> groupNotificationMap = new Map<Id,List<Notification__c>>();
        List<Notification__c> groupNotifications = null;
        for( Notification__c noti : notificationMap.values() ){
            groupNotifications = groupNotificationMap.containsKey(noti.NotificationGroup__c) ? groupNotificationMap.get(noti.NotificationGroup__c) : new List<Notification__c>();
            groupNotifications.add(noti);
            groupNotificationMap.put( noti.NotificationGroup__c , groupNotifications );

            if( '2'.equals(noti.Channel__c) && i2SEMA_Util.isEmpty(noti.NotificationTemplate__c) ){ //MMS && no template
                templateUnUsedGroupIds.add(noti.NotificationGroup__c);
            }
        }


        system.debug('========>> Group Notifications');
        system.debug(groupNotificationMap);

        /*-----------------------------------------------
         * 02.20 변준우 추가
            - Group 별 첨부파일 목록 획득 : MMS이고, 템플릿을 사용하지 않는
        -------------------------------------------------*/

        Map<Id,List<ContentVersion>> groupContentVersionMap = new Map<Id,List<ContentVersion>>();   // 템플릿을 사용하지 않은 Notification Group 에 첨부된 ContentVersion 목록

        // Template 사용하지 않은 Notification Group 이 있을시
        if( !templateUnUsedGroupIds.isEmpty()){
            Set<Id> contentDocumentIds                      = new Set<Id>();
            List<ContentDocumentLink> manualDocumentLinks   = [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:templateUnUsedGroupIds];

            // Manual 등록된 첨부파일이 있을시
            if( !manualDocumentLinks.isEmpty()){
                for( ContentDocumentLink link : manualDocumentLinks ){
                    contentDocumentIds.add(link.ContentDocumentId);
                }
                // Content Document Version 획득
                Map<Id,ContentVersion> documentLatestVersionMap = new Map<Id,ContentVersion>();
                for( ContentVersion version : [SELECT Id,Title,VersionData,ContentSize,FileExtension,ContentDocumentId,Description
                                                FROM ContentVersion
                                                WHERE ContentDocumentId IN:contentDocumentIds AND IsLatest = TRUE]) {
                    documentLatestVersionMap.put( version.ContentDocumentId , version );
                }

                ContentVersion documentContentVersion = null;
                List<ContentVersion> groupContentVersions = null;
                // Group 별 첨부파일 목록 획득
                for( ContentDocumentLink link : manualDocumentLinks ){
                    Id notificationGroupId  = link.LinkedEntityId;
                    Id contentDocumentId    = link.ContentDocumentId;

                    documentContentVersion  = documentLatestVersionMap.get(contentDocumentId);
                    groupContentVersions    = groupContentVersionMap.containsKey(notificationGroupId) ? groupContentVersionMap.get(notificationGroupId) : new List<ContentVersion>();
                    groupContentVersions.add(documentContentVersion);

                    groupContentVersionMap.put( notificationGroupId , groupContentVersions );
                }
            }
        }

        system.debug('=========>> Template Used Group / Group Contents Version');
        //system.debug(templateUnUsedGroupIds);
        //system.debug(groupContentVersionMap);

        /*-----------------------------------------------
         * 02.20 변준우 수정
            - 템플릿,파일로 인해 Group 별로 발송
        -------------------------------------------------*/
        // Group 별 발송처리
        // TODO : 이벤트성으로 호출되는 Noti 들은 그룹 별 IF 호출이 필요한데, Chain Job 으로 구성해야할지?
        IF_SFDC_SEMA_0005               instance = IF_SFDC_SEMA_0005.getInstance();
        IF_SFDC_SEMA_0005.InputDIH      input   = new IF_SFDC_SEMA_0005.InputDIH();
        IF_SFDC_SEMA_0005.OutputDIH     result;
        IF_SFDC_SEMA_0005.INPUT_T_DATA  t_data;
        IF_SFDC_SEMA_0005.T_FILE        t_file;
        IF_SFDC_SEMA_0005.T_PER         t_per;
        Datetime                        now;
        groupNotifications              = null;
        Boolean hasManualFile           = false;
        Notification__c noti            = null;
        List<ContentVersion> groupContentVersions = null;
        for( Id groupId : groupNotificationMap.keySet() ){
            groupNotifications = groupNotificationMap.get(groupId);

            system.debug('------------->> Detail Notifications');
            //system.debug(groupNotifications);

            //Notification이 없으면, 스킵
            if(groupNotifications.isEmpty()) continue;
            /*---------------------------------------
             * 발송 기본정보 : 동일 NotiGroup은 메세지 공통
             ---------------------------------------*/
            t_data = new IF_SFDC_SEMA_0005.INPUT_T_DATA();
            noti = groupNotifications[0];
            hasManualFile = groupContentVersionMap.containsKey(groupId);

            //예약 발송 여부
            if(noti.IsSendingReservation__c && i2SEMA_Util.isNotEmpty(noti.SendingTime__c)) {
                t_data.tmp_book_yn          = 'Y';                                                              // 예약발송 여부
                t_data.date_client_req      = noti.SendingTime__c.format('yyyy-MM-dd hh:mm:ss');        // 시간 '2020-02-25 16:20:00';
            } else {
                t_data.tmp_book_yn          = 'N';                                                              // 예약발송 여부
                t_data.date_client_req      = String.valueOf(system.now());                                     // 시간
            }
            if(i2SEMA_Util.isNotEmpty(noti.NotificationTemplate__c)) { //템플릿 통한 발송
                t_data.templete_id          = noti.NotificationTemplate__c;    // i2sema 템플릿 코드
                t_data.sema_templete_code   = '';                                                                   // Template Code
                t_data.subject              = null;                                                                 // 제목 (SMS 일 경우 제외)
                t_data.content              = null;                                                                 // 내용 (SMS : 90 Byte, MMS : 2000 Byte)
                t_data.templete_type        = null;                                                                 // 메시지 타입 (SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009)

            } else {    //템플릿 없을경우
                t_data.templete_id          = null;                                                                 // i2sema 템플릿 코드
                t_data.subject              = noti.Title__c;     // 제목 (SMS 일 경우 제외)
                t_data.content              = noti.Content__c;   // 내용 (SMS : 90 Byte, MMS : 2000 Byte)
                switch on noti.Channel__c {
                    when '2' { //MMS
                        if( hasManualFile ){
                            t_data.templete_type = '2';   // 메시지 타입 (SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009)
                        } else{ // File 이 첨부되지 않은경우, LMS 로 발신
                            t_data.templete_type = '3';  // 메시지 타입 (SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009)
                        }
                    }
                    when else {
                        t_data.templete_type = noti.Channel__c;   // 메시지 타입 (SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009)
                    }
                }
                /*---------------------------------------
                 * 카카오 친구톡 이미지 URL 정보 : 서버 진행예정
                 ---------------------------------------*/
//                    t_data.kakao_chennel_id               = I2SEMA_Base.getKakaoBizId();  // 카카오 비즈 아이디
//                    t_data.kakao_img_url                  = noti.fm_KakaoImgUrl__c;       // 친구톡 이미지 경로
//                    t_data.kakao_img_link                 = noti.KakaoImgLink__c;         // 친구톡 이미지 클릭시 링크
//
                /*---------------------------------------spsㄴㄴㄴ
                 * MMS File 정보
                 ---------------------------------------*/
                if( hasManualFile ){
                    t_data.t_file = new List<IF_SFDC_SEMA_0005.T_FILE>();

                    groupContentVersions = groupContentVersionMap.get(groupId);
                    for( ContentVersion cv : groupContentVersions ){
                        t_file = new IF_SFDC_SEMA_0005.T_FILE();

                        t_file.file_id          = '';                                  // File ID
                        t_file.attach_id        = cv.Id;                               // SFDC File ID
                        t_file.file_name        = cv.Title + '.' + cv.FileExtension;   // File Name
                        t_file.file_status      = I2SEMA_Base.getIFFileStatus();       // File 상태값
                        if('URL'.equals(I2SEMA_Base.getIFFileStatus())) {
                            t_file.file_content = cv.ContentUrl;    // 파일 내용 URL
                        } else {
                            t_file.file_content = EncodingUtil.base64Encode(cv.VersionData);    // 파일 내용 Byte Stream
                        }
                        t_file.file_description = cv.Description;                      // Description
                        t_file.file_size        = String.valueOf(cv.ContentSize);      // Content Size
                        t_file.file_width       = '';
                        t_file.file_height      = '';

                        t_data.t_file.add(t_file);
                    }
                }

            }

            t_data.callback             = i2SEMA_Util.convertPhoneNumberFormat(I2SEMA_Base.getSenderNumber());  // 발신자 번호
            t_data.priority             = 'S';                                                                  // 우선순위(S - Slow (default)), F - Fast, VF - Very Fast)
            t_data.mt_refkey            = '';                                                                   // 부서코드 - 참조
            t_data.noti_group_id        = noti.NotificationGroup__c;       // SFDC 메시지 그룹 아이디
            //200721 추가 광고성,정보성, 수신거부번호
            t_data.msg_cl_type          = noti.Type__c;                     //1 : 광고성, 2 : 정보성
            t_data.ars_080_num          = i2SEMA_Util.convertPhoneNumberFormat(noti.ARS_080_Phone__c);          //message_type 이 1일 경우 필수. 무료수신거부 080번호 


            // 건별 처리
            t_data.t_per = new List<IF_SFDC_SEMA_0005.T_PER>();
            for( Notification__c eachNoti : groupNotifications ){
                /*---------------------------------------
                 * 개인화 필드 정보
                 ---------------------------------------*/
                t_per = new IF_SFDC_SEMA_0005.T_PER();
                t_per.noti_id       =  eachNoti.Id;                    // SFDC 개인화 필드 아이디
                t_per.recipient_num =  i2SEMA_Util.convertPhoneNumberFormat(eachNoti.Phone__c);     // 수신자 번호
                t_per.label1        =  eachNoti.LABEL1__c;             // 개인화 필드 1
                t_per.label2        =  eachNoti.LABEL2__c;             // 개인화 필드 2
                t_per.label3        =  eachNoti.LABEL3__c;             // 개인화 필드 3
                t_per.label4        =  eachNoti.LABEL4__c;             // 개인화 필드 4
                t_per.label5        =  eachNoti.LABEL5__c;             // 개인화 필드 5
                t_data.t_per.add(t_per);
            }

            // Group 발송정보 적재
            input.request.payload.t_data.add(t_data);

        }
        System.debug('input.request.payload.t_data : '+input.request.payload.t_data);
        //Interface Request 실행
        if(!input.request.payload.t_data.isEmpty()){
            result = instance.execute(input);
        }
        /**----------------------------------------
         * IF 결과 업데이트
         * 1. Notification IF 결과 업데이트
         * 2. Notification Group IF 결과 업데이트
         * 3. Activity Task 생성
         * 4. Notification Log 생성
         ----------------------------------------*/
        now = Datetime.now();
        //Interface Response 처리
        List<NotificationGroup__c> updateNotificationGroups = new List<NotificationGroup__c>();
        List<Notification__c> updateNotifications = new List<Notification__c>();
        List<Task> createTasks = new List<Task>();
        List<NotificationLog__c> createLogs = new List<NotificationLog__c>();
        NotificationGroup__c ng = null;
        NotificationLog__c log = null;
        Task task = null;
        groupNotifications = null;
        for( Id groupId : groupNotificationMap.keySet() ) {
            groupNotifications = groupNotificationMap.get(groupId);

            //Notification이 없으면, 스킵
            if(groupNotifications.isEmpty()) continue;

            for (Notification__c eachNoti : groupNotifications) {
                //Activity Task
                if(i2SEMA_Util.isEmpty(noti.User__c)) {
                    task = new Task();
                    task.Notification__c = eachNoti.Id;
                    task.Subject = '0'.equals(eachNoti.Channel__c)? eachNoti.Content__c:eachNoti.Title__c;
                    task.Type = eachNoti.Channel__c;
                    task.Priority = 'Normal';

                    if (i2SEMA_Util.isNotEmpty(eachNoti.Account__c)) {
                        task.WhatId = eachNoti.Account__c;
                    } else if (i2SEMA_Util.isNotEmpty(eachNoti.Contact__c)) {
                        task.WhoId = eachNoti.Contact__c;
                    } else if (i2SEMA_Util.isNotEmpty(eachNoti.Lead__c)) {
                        task.WhoId = eachNoti.Lead__c;
                    }
                    //  if(i2SEMA_Util.isNotEmpty(eachNoti.User__c)) { //유저는 태스크 등록 불가
                    //      task.WhatId = eachNoti.User__c;
                    //  }
                    if ('S'.equals(result.response.header.ifResult)) { //성공
                        task.Status = 'In Progress';
                    } else { //실패
                        task.Status = 'Failed';
                    }
                    createTasks.add(task);
                }
                //Log
                log = new NotificationLog__c();
                log.Notification__c = eachNoti.Id;
                log.RequestDateTime__c = now;
                if ('S'.equals(result.response.header.ifResult)) { //성공
                    log.Status__c = 'Requested';
                } else { //실패
                    log.Status__c = 'Fail';
                    log.ResponseMessage__c = result.response.header.ifFailMsg.left(255);
                    log.IF_FailCode__c = result.response.header.ifFailCode.left(50);
                }
                createLogs.add(log);

                if ('S'.equals(result.response.header.ifResult)) { //성공
                    eachNoti.msg_status__c = 'Requested';
                    eachNoti.IF_RequestedDate__c = now;
                } else { //실패
                    eachNoti.msg_status__c = 'Failed request to send';
                    eachNoti.IF_FailedDate__c = now;
                }
                updateNotifications.add(eachNoti);
            }

            ng = new NotificationGroup__c();
            ng.Id = groupId;
            if ('S'.equals(result.response.header.ifResult)) {
                ng.IF_Status__c = 'Requested';
                ng.IF_RequestedDate__c = now;
            } else {
                ng.IF_Status__c = 'Failed request to send';
                ng.IF_FailedDate__c = now;
            }
            updateNotificationGroups.add(ng);
        }

        System.debug('createTasks : '+createTasks);
        System.debug('createLogs : '+createLogs);
        System.debug('updateNotifications : '+updateNotifications);
        System.debug('updateNotificationGroups : '+updateNotificationGroups);
        if(createTasks.size() > 0)              insert createTasks;
        if(createLogs.size() > 0)               insert createLogs;
        if(updateNotifications.size() > 0)      update updateNotifications;
        if(updateNotificationGroups.size() > 0) update updateNotificationGroups;
    }
}