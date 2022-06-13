/****************************************************************************************
  * @filename      : i2SEMA_IFNotificationSend_ba
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee
  * @date          : 2020/01/30 3:25 PM
  * @group         : Notification
  * @group-content :
  * @description   : Notification Batch IF 예약메세지 발송 대상 대량 인터페이스 + 차단목록 요청 IF Queuable 호출
  * @tester        : NotificationInterface_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                   author            description
  * ===============================================================
    0.1     2020/01/30 3:25 PM     i2max_shlee       Create
    0.2     2020/04/13 3:14 PM     i2max_shlee       Rename NotificationInterface_ba > i2SEMA_IFNotificationSend_ba
    0.3     2020/07/21 3:14 PM     i2max_shlee       광고성/정보성 관련 추가
****************************************************************************************/
global with sharing class i2SEMA_IFNotificationSend_ba implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {

    /* manual execute code
    i2SEMA_IFNotificationSend_ba batch = new i2SEMA_IFNotificationSend_ba();
    Database.executeBatch(batch, 2000);
    */
    public Map<String, Map<String, Object>> responseMap = null;
    public i2SEMA_BatchLogger  logger;
    public Date         ifDate;				// Interface Date

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
                            + 'Channel__c, Title__c, Content__c, RawContents__c, Type__c, ARS_080_Phone__c ,'
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
                        + 'FROM Notification__c ';

        if (!Test.isRunningTest()) query += ' WHERE IsSendingReservation__c = TRUE ';
        if (!Test.isRunningTest()) query += ' AND Validity__c = TRUE ';                //Validation 통과
        if (!Test.isRunningTest()) query += ' AND msg_status__c = \'Pending\' ';       //Validation 통과
        if (!Test.isRunningTest()) query += ' AND SendingTime__c >= TOMORROW ';

        return Database.getQueryLocator(query);
    }

    /**
     * @description I/F Data를
     * @param bc
     * @param scope
     */
    global void execute(Database.BatchableContext bc, List<Notification__c> scope) {

        try {

            Set<Id> templateUnUsedGroupIds                      = new Set<Id>();                        // 템플릿을 사용하지 않은 Notification Group ID 집합
            Map<Id,List<Notification__c>> groupNotificationMap  = new Map<Id,List<Notification__c>>();  // Gruop 별 Notification 목록
            List<Notification__c> groupNotifications =  null;

            for( Notification__c noti : scope ){
                system.debug('noti : '+noti);
                if( '2'.equals(noti.Channel__c) && i2SEMA_Util.isEmpty(noti.NotificationTemplate__c) ){ //MMS && no template
                    templateUnUsedGroupIds.add(noti.NotificationGroup__c);
                }
                //set groupNotificationMap :  NotificationGroup Id 그룹핑
                groupNotifications = groupNotificationMap.containsKey(noti.NotificationGroup__c) ? groupNotificationMap.get(noti.NotificationGroup__c) : new List<Notification__c>();
                groupNotifications.add(noti);
                groupNotificationMap.put( noti.NotificationGroup__c , groupNotifications );
            }

            system.debug('========>> Group Notifications');
            system.debug('templateUnUsedGroupIds : '+templateUnUsedGroupIds);
            system.debug('groupNotificationMap : ' + groupNotificationMap);

            /*-----------------------------------------------
             *  수동발송 첨부파일 목록 획득 : MMS Channel, No Template
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

                    // Group 별 첨부파일 목록 획득
                    ContentVersion documentContentVersion = null;
                    List<ContentVersion> groupContentVersions = null;
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

                groupNotifications  = groupNotificationMap.get(groupId);

                //Notification이 없으면, 스킵
                if(groupNotifications.isEmpty()) continue;

                /*---------------------------------------
                 * 발송 기본정보 : 매새지 파라미터 적재
                 ---------------------------------------*/
                //동일 NotificationGroup은 다 같은 메세지 임
                noti            = groupNotifications[0]; //동일 메세지 내용, 다중 수신자는 밑에서 설정
                hasManualFile   = groupContentVersionMap.containsKey(groupId);
                t_data          = new IF_SFDC_SEMA_0005.INPUT_T_DATA();

                //예약 발송 여부
                if(noti.IsSendingReservation__c && i2SEMA_Util.isNotEmpty(noti.SendingTime__c)) {
                    t_data.tmp_book_yn          = 'Y';                                                  // 예약발송 여부
                    t_data.date_client_req      = noti.SendingTime__c.format('yyyy-MM-dd hh:mm:ss');    // 시간 '2020-02-25 16:20:00';
                } else {
                    t_data.tmp_book_yn          = 'N';                                                  // 예약발송 여부
                    t_data.date_client_req      = String.valueOf(system.now());                         // 시간
                }
                if(i2SEMA_Util.isNotEmpty(noti.NotificationTemplate__c)) { //템플릿 통한 발송
                    t_data.templete_id          = noti.NotificationTemplate__c;    // i2sema 템플릿 코드
                    t_data.sema_templete_code   = '';                              // Template Code
                    t_data.subject              = null;                            // 제목 (SMS 일 경우 제외)
                    t_data.content              = null;                            // 내용 (SMS : 90 Byte, MMS : 2000 Byte)
                    t_data.templete_type        = null;                            // 메시지 타입 (SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009)
                    //200721 추가 광고성,정보성, 수신거부번호
                    t_data.msg_cl_type          = null;                            //1 : 광고성, 2 : 정보성
                    t_data.ars_080_num          = null;                            //message_type 이 1일 경우 필수. 무료수신거부 080번호
                } else {    //템플릿 없을경우, 수동발송
                    t_data.templete_id          = null;                             // i2sema 템플릿 코드
                    t_data.subject              = noti.Title__c;                    // 제목 (SMS 일 경우 제외)
                    t_data.content              = noti.Content__c;                  // 내용 (SMS : 90 Byte, MMS : 2000 Byte)
                    t_data.templete_type        = noti.Channel__c;                  // 메시지 타입 (SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009)
                    //200721 추가 광고성,정보성, 수신거부번호
                    t_data.msg_cl_type          = noti.Type__c;                     //1 : 광고성, 2 : 정보성
                    t_data.ars_080_num          = noti.ARS_080_Phone__c;            //message_type 이 1일 경우 필수. 무료수신거부 080번호
                    switch on noti.Channel__c {
                        when '2' { //MMS
                            if( hasManualFile ){
                                t_data.templete_type    = '2';  // 메시지 타입 (SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009)
                            } else{ // File 이 첨부되지 않은경우, LMS 로 발신
                                t_data.templete_type    = '3';  // 메시지 타입 (SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009)
                            }
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


                // 건별 처리
                t_data.t_per = new List<IF_SFDC_SEMA_0005.T_PER>();
                for( Notification__c eachNoti : groupNotifications ){
                    /*---------------------------------------
                     * 개인화 필드 정보
                     ---------------------------------------*/
                    t_per = new IF_SFDC_SEMA_0005.T_PER();
                    t_per.noti_id       =  eachNoti.Id;                            // SFDC 개인화 필드 아이디
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
             * IF 결과 업데이트용 Map 체인 Batch에 전달값 responseMap <noti.Id, ifResultMap>
             ----------------------------------------*/
            responseMap = new Map<String, Map<String, Object>>();
            Map<String, Object> ifResultMap = null;
            for( Id groupId : groupNotificationMap.keySet() ) {
                groupNotifications = groupNotificationMap.get(groupId);

                //Notification이 없으면, 스킵
                if (groupNotifications.isEmpty()) continue;

                for (Notification__c eachNoti : groupNotifications) {
                    ifResultMap = new Map<String, Object>();
                    if ('S'.equals(result.response.header.ifResult)) { //성공
                        ifResultMap.put('ifResult', TRUE);
                    } else { //실패
                        ifResultMap.put('ifResult', FALSE);
                        ifResultMap.put('ifFailMsg', result.response.header.ifFailMsg);
                        ifResultMap.put('ifFailCode', result.response.header.ifFailCode);
                    }
                    responseMap.put(eachNoti.Id, ifResultMap);
                }
            }

        } catch (Exception e) {
            System.debug('Error : ' + e.getLineNumber() + ' / ' + e.getMessage());
            logger.log(e.getStackTraceString());
        }
    }

    /**
     * @description Batch 종료
     *              1. 메세지 발송 후, 상태값 업데이트 + Task 등록 체인 배치 호출
     *              2. 차단목록 요청 IF Queuable 호출
     * @param bc
     */
    global void finish(Database.BatchableContext bc) {
        logger.finish('finish!!');

//        System.debug('responseMap : '+responseMap);
        //메세지 발송 후, 상태값 업데이트 + Task 등록 배치
        i2SEMA_IFNotificationSendResult_ba batch = new i2SEMA_IFNotificationSendResult_ba(responseMap);
        Database.executeBatch(batch, 2000);

        //차단목록 요청 IF Queuable 호출
        Id jobId = System.enqueueJob(new i2SEMA_IFUnsubscriptionRequest_qu(Datetime.now()));
        System.debug('i2SEMA_IFUnsubscriptionRequest_qu : ' + jobId);

    }



}