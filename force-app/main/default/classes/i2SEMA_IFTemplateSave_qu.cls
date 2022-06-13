/****************************************************************************************
  * @filename      : i2SEMA_IFTemplateSave_qu
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee
  * @date          : 2020/01/29 5:36 PM
  * @group         : Notification
  * @group-content : i2SEMA Package
  * @description   : Queueable Template 저장 IF
  * @tester        : i2SEMA_IFTemplateSave_qu_ts.cls
  *                  multiple NotificationGroup [t_data]
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                   author            description
  * ===============================================================
    1.0     2020/01/29 5:36 PM     i2max_shlee       Create
    1.1     2020/04/13 2:25 PM     i2max_shlee       Rename NotificationTemplateInterface_qu >  i2SEMA_IFTemplateSave_qu
****************************************************************************************/
global with sharing class i2SEMA_IFTemplateSave_qu implements Queueable, Database.AllowsCallouts {
    private List<NotificationTemplate__c> templates;

    /**
     * @description
     * @param QueueableContext
     */
    global void execute(QueueableContext qc) {
        IF_SFDC_SEMA_0009 instance = IF_SFDC_SEMA_0009.getInstance();
        system.debug('------------>> get INSTANCE');
        system.debug(instance);

        Set<Id> tempIds = new Set<Id>();
        for(NotificationTemplate__c temp : templates) {
            tempIds.add(temp.Id);
        }
        templates = [
                SELECT Id, Title__c, Content__c, Channel__c, fm_LABELCount__c, Type__c, Ars080Phone__c
                    , KakaoNotiTempleteCode__c, KakaoImgUrl__c, KakaoImgLink__c
                FROM NotificationTemplate__c
                WHERE Id IN :tempIds
        ];

        /*--------------------------------------------------------------
         * MMS Template의 Content[File] 정보 및 카카오친구톡의 카카오 버튼 취득
         --------------------------------------------------------------*/
        Map<Id, Id> cdlMap = new Map<Id, Id>();
        Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>();
        Map<Id, List<KakaoTalkButton__c>> kbMap = new Map<Id, List<KakaoTalkButton__c>>();
        List<KakaoTalkButton__c> kbList = null;
        for (NotificationTemplate__c template : templates) {
            if('2'.equals(template.Channel__c))               cdlMap.put(template.Id, null);  //MMS
            if('1009'.equals(template.Channel__c)) kbMap.put(template.Id, null);   //Kakao Friend Talk
        }

        //MMS Template의 Content[File] 정보 취득
        System.debug('cdlMap : '+cdlMap);
        if( cdlMap.size() > 0) {
            for (ContentDocumentLink cdl : [
                    SELECT Id, ContentDocumentId, LinkedEntityId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :cdlMap.keySet()
            ]) {
                cdlMap.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
            }

            for (ContentVersion cv : [
                    SELECT Id, ContentDocumentId, Title, VersionData, ContentUrl, FileExtension, FileType, ContentSize, Description
                    FROM ContentVersion
                    WHERE ContentDocumentId = :cdlMap.values()
            ]) {
                cvMap.put(cv.ContentDocumentId, cv);
            }
        }
        //카카오친구톡의 카카오 버튼 취득
        if ( kbMap.size() > 0) {
            for(KakaoTalkButton__c kb : [SELECT Id, Name, NotificationTemplates__c, Button_Type__c, ButtonLink1__c, ButtonLink2__c
            FROM KakaoTalkButton__c
            WHERE NotificationTemplates__c IN :kbMap.keySet() ]) {

                kbList = kbMap.containsKey(kb.NotificationTemplates__c) && kbMap.get(kb.NotificationTemplates__c) != null ? kbMap.get(kb.NotificationTemplates__c) : new List<KakaoTalkButton__c>();
                kbList.add(kb);
                kbMap.put(kb.NotificationTemplates__c, kbList);
            }
        }
        System.debug('kbMap : '+kbMap);

        //Interface Request 파라미터 설정
        IF_SFDC_SEMA_0009.InputDIH input = new IF_SFDC_SEMA_0009.InputDIH();
        IF_SFDC_SEMA_0009.OutputDIH     result;
        IF_SFDC_SEMA_0009.INPUT_T_DATA  t_data;
        IF_SFDC_SEMA_0009.T_FILE        t_file;
        IF_SFDC_SEMA_0009.T_KAKAO       t_kakao;
        ContentVersion                  cv;
        for (NotificationTemplate__c template : templates) {
            t_data = new IF_SFDC_SEMA_0009.INPUT_T_DATA();
            t_data.templete_id      = template.Id;              // i2sema 템플릿 코드
            t_data.subject          = template.title__c;        // 제목 (SMS 일 경우 제외)
            t_data.content          = template.Content__c;      // 내용 (SMS : 90 Byte, MMS : 2000 Byte)
            t_data.templete_type    = template.Channel__c;      //템플릿 타입 (SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009)
            t_data.msg_cl_type      = template.Type__c;         //1:광고성, 2:정보
            t_data.ars_080_num      = template.Ars080Phone__c;  //message_type 이 1일 경우 필수. 무료수신거부 080번호
            switch on template.Channel__c {
                when '0' {  //SMS
                    t_data.kakao_chennel_id = null; // 카카오 비즈 아이디
                    t_data.kakao_img_url    = null; // 친구톡 이미지 경로
                    t_data.kakao_img_link   = null; // 친구톡 이미지 클릭시 링크
                }
                when '2' {  //MMS File 이 첨부되지 않은경우, 에러
                    t_data.kakao_chennel_id = null; // 카카오 비즈 아이디
                    t_data.kakao_img_url    = null; // 친구톡 이미지 경로
                    t_data.kakao_img_link   = null; // 친구톡 이미지 클릭시 링크
                }
                when '3' {  //LMS
                    t_data.kakao_chennel_id = null; // 카카오 비즈 아이디
                    t_data.kakao_img_url    = null; // 친구톡 이미지 경로
                    t_data.kakao_img_link   = null; // 친구톡 이미지 클릭시 링크
                }
                when '1008' {   //카카오 알림톡
                    t_data.kakao_chennel_id = I2SEMA_Base.getKakaoBizId();  // 카카오 비즈 아이디
                    t_data.kakao_img_url    = null; // 친구톡 이미지 경로
                    t_data.kakao_img_link   = null; // 친구톡 이미지 클릭시 링크
                }
                when '1009' {   //카카오 친구톡
                    t_data.kakao_chennel_id = I2SEMA_Base.getKakaoBizId();  // 카카오 비즈 아이디
                    t_data.kakao_img_url    = template.KakaoImgUrl__c;      // 친구톡 이미지 경로
                    t_data.kakao_img_link   = template.KakaoImgLink__c;     // 친구톡 이미지 클릭시 링크
                }

            }
            t_data.change_word_count        = String.valueOf(template.fm_LABELCount__c);    // 개별화 필드 갯수(수신자 번호 제외)
            t_data.kakao_noti_templete_code = template.KakaoNotiTempleteCode__c;            // 알림톡 템플릿 코드 - 기 등록된 템플릿 코드 이용(InfoBank에 등록된 코드만 사용가능)



            //MMS용 파일첨부, content Map 이 있으면 파일 전송 처리
            if('2'.equals(template.Channel__c) && cdlMap.size() > 0  && cvMap.size() > 0) {
                cv = cvMap.get(cdlMap.get(template.Id));
                t_file = new IF_SFDC_SEMA_0009.T_FILE();
                t_file.attach_id        = cv.Id;       // SFDC File ID
                t_file.file_id          = '';                                       // 파일 아이디
                t_file.file_status      = I2SEMA_Base.getIFFileStatus();            // 파일 상태 (URL, FILE)
                t_file.file_name        = cv.Title;                                 // 파일 이름 (ORG명_파일이름)
                if('URL'.equals(I2SEMA_Base.getIFFileStatus())) {
                    t_file.file_content = cv.ContentUrl;    // 파일 내용 URL
                } else {
                    t_file.file_content = EncodingUtil.base64Encode(cv.VersionData);    // 파일 내용 Byte Stream
                }
                t_file.file_size        = String.valueOf(cv.ContentSize);      // Content Size
                t_file.file_description = cv.Description;  // 퍼일 설명
                if(cv.FileExtension.containsIgnoreCase('png') || cv.FileExtension.containsIgnoreCase('jpg')) {
                    t_file.file_width   = '';                                       // 파일 너비
                    t_file.file_heigjt  = '';                                       // 파일 높이
                } else {
                    t_file.file_width   = '';                                       // 파일 너비
                    t_file.file_heigjt  = '';                                       // 파일 높이
                }
                t_data.T_FILE.add(t_file);
            }
            //카카오 알림톡은 전송 하지 않음.
            if('1009'.equals(template.Channel__c)
                    && !kbMap.isEmpty()
                    && kbMap.containsKey(template.Id) && kbMap.get(template.Id) != null) {
                kbList = kbMap.get(template.Id);
                for(KakaoTalkButton__c kb : kbList) {
                    t_kakao = new IF_SFDC_SEMA_0009.T_KAKAO();
                    t_kakao.kakao_btn_name = kb.Name;
                    t_kakao.kakao_btn_type = kb.Button_Type__c;
                    t_kakao.kakao_btn_link_1 = kb.ButtonLink1__c;
                    t_kakao.kakao_btn_link_2 = kb.ButtonLink2__c;
                    t_data.T_KAKAO.add(t_kakao);
                }
            }

            input.request.payload.T_DATA.add(t_data);
        }
        //Interface Request 실행
        if (!input.request.payload.T_DATA.isEmpty()) {
            result = instance.execute(input);
        }
        //Interface Response 처리
        if ('S'.equals(result.response.header.ifResult)) {
            //성공
        } else {
            //실패
        }

        /**----------------------------------------
         * IF 결과 업데이트
         * 1. NotificationTemplate IF 결과 업데이트
         * 2. Notification Group IF 결과 업데이트
         * 3. Activity Task 생성
         * 4. Notification Log 생성
         ----------------------------------------*/
        Datetime now = Datetime.now();
        //Interface Response 처리
        for (NotificationTemplate__c template : templates) {
            if ('S'.equals(result.response.header.ifResult)) { //성공
                template.IF_Status__c = 'Completed';
                template.IF_RequestedDate__c = now;
            } else { //실패
                template.IF_Status__c = 'Failed';
                template.IF_FailedDate__c = now;
            }
        }

        System.debug('templates : '+templates);
        if(templates.size() > 0) update templates;

    }
    /**
     * @description NotificationTemplateInterface_qu 생성자
     * @param templates Set<NotificationTemplate__c.Id> 템플릿 리스트
     */
    global i2SEMA_IFTemplateSave_qu(List<NotificationTemplate__c> templates) {
        this.templates = templates;
    }

    /**
     * @description NotificationTemplateInterface_qu 생성자
     * @param templates NotificationTemplate__c.Id 템플릿 레코드
     */
    global i2SEMA_IFTemplateSave_qu(NotificationTemplate__c template) {
        List<NotificationTemplate__c> temps = new List<NotificationTemplate__c>();
        temps.add(template);
        this.templates = temps;
    }

}