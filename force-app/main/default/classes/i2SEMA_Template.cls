/****************************************************************************************
  * @filename      : i2SEMA_Template
  * @projectname   : i2SEMA Core
  * @author        : i2max_ys.seo
  * @date          : 2020-04-08 오후 2:47
  * @group         : Notification Template
  * @group-content : i2SEMA_Template
  * @description   : Tempate 페이지 APEX Class
  * @tester        : i2SEMA_Template_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author              description
  * ===============================================================
    0.1     2020-04-08 오후 2:47    i2max_ys.seo        Create
    0.2     2020/04/28 11:31 AM     i2max_shlee         Rename i2SEMA_NotificationTemplate -> i2SEMA_Template
    0.3     2020/04/28 11:31 AM     i2max_shlee         Type:광고성,정보성, 수신거부 080번호 디폴트값으로 취득 표시 : TODO 서버로부터 목록 받아서 선택하게 변경되어야 함
****************************************************************************************/
public with sharing class i2SEMA_Template {

    /**
     * @description 1.Validation
     *              2.Read/Edit/New
     *              3.Notification Template 저장
     *              4.MMS 일 때 ContentVersion, ContentDocument 저장
     ** @param pmap
     *
     * @return {i2SEMA_ComponentResponse}
     */
    @AuraEnabled
    public static i2SEMA_ComponentResponse initialize(String recordId, String isScreen) {
        i2SEMA_ComponentResponse response = new i2SEMA_ComponentResponse();
        ReferenceData referenceData = new ReferenceData();

        System.debug('initialize recordId : ' + recordId);
        System.debug('initialize isScreen : ' + isScreen);

        //recordId 있으면 recordId 기준으로 Notification Template 조회
        if (i2SEMA_Util.isNotEmpty(recordId)) {
            if( !Schema.SObjectType.NotificationTemplate__c.getKeyPrefix().equals(recordId.left(3))){
                throw new AuraHandledException(LABEL.i2SEMA_MSG_INVALID_TEMPLATE_ID);
            }

            NotificationTemplate__c template = [
                    SELECT
                            Id, Name, Channel__c, Type__c, Ars080Phone__c,
                            Title__c, Content__c, LABEL1__c, LABEL2__c, LABEL3__c, LABEL4__c, LABEL5__c, ContentLength__c,
                            fm_LABELCount__c, fm_OrganizationId__c,
                            IF_Status__c, IF_CompletedDate__c, IF_FailedDate__c, IF_RequestedDate__c,
                            IsActive__c, IsDeleted,
                            KakaoNotiTempleteCode__c, KakaoFriendTalkImage__c, KakaoImgUrl__c, KakaoImgLink__c
//                            OwnerId, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, SystemModstamp
                    FROM NotificationTemplate__c
                    WHERE Id = :recordId
                    LIMIT 1
            ];
            if( i2SEMA_Util.isEmpty(template) ){
                throw new AuraHandledException(LABEL.i2SEMA_MSG_INVALID_TEMPLATE_ID2+recordId);
            }

            //****************************
            /* 수정불가 Validation
            ****************************/
            if ('Edit'.equals(isScreen)) {

                system.debug('notificationTemplate.Channel__c = ' + template.Channel__c);
                if ('1008'.equals(template.Channel__c)) {
                    throw new AuraHandledException(Label.i2SEMA_MSG_UNMODIFICATOIN_NOTIFICATION_TALK);     //Msg : Duplicate template name exists. change the name for the template.
                }

                //템플릿 사용한 발송된 메세지 존재시 수정불가
                List<Notification__c> notiList = [
                        SELECT Id, Name, msg_status__c
                        FROM Notification__c
                        WHERE NotificationTemplate__c = :template.Id
//                        AND msg_status__c = 'Completad'
                ];

                if (notiList.size() > 0) {
                    throw new AuraHandledException(Label.i2SEMA_MSG_TEMPLATE_ALREADY_USED);     //Msg : The template used to send the message cannot be modified.
                }

                //자동화 발송 설정(Notification Event Setting)에 사용한 템플릿은 수정불가
                List<NotificationAutomaticSetting__c> nesList = [
                        SELECT Id, Name
                        FROM NotificationAutomaticSetting__c
                        WHERE NotificationTemplate__c = :template.Id
                ];
                if (nesList.size() > 0) {
                    throw new AuraHandledException(Label.i2SEMA_MSG_NOTIFICATION_EVENT_SETTING_ALREADY_SET);     //Msg : Template used for automatic sending. Unable to modify.
                }

            }

            //set ReferenceData
            //200721 shlee 080번호 디폴트값으로 취득 표시 : TODO 서버로부터 목록 받아서 선택하게 변경되어야 함
            template.Ars080Phone__c = i2SEMA_Base.get080ARSNumber();
            referenceData.template =  template;
            System.debug('referenceData.template : ' + referenceData.template);
            //채널이 카카오 친구톡이거나 카카오 알림톡일 때
            if (referenceData.isKakao)   {
                List<KakaoTalkButton__c> ktbList = [
                        SELECT Id, NotificationTemplates__c, Name, Button_Type__c, ButtonLink1__c, ButtonLink2__c
                        FROM KakaoTalkButton__c
                        WHERE NotificationTemplates__c = :recordId
                        ORDER BY CreatedDate ASC
                ];
                referenceData.kakaoButtons = ktbList;
                System.debug('referenceData.kakaoButtons : ' + referenceData.kakaoButtons);
            }
            //MMS AttachFile : Content Version Data
            if (referenceData.isMMS) {
                ContentDocumentLink[] cdlList = [
                        SELECT Id, ContentDocumentId, LinkedEntityId
                        FROM ContentDocumentLink
                        WHERE LinkedEntityId = :recordId
                        ORDER BY SystemModstamp
                ];
                System.debug('cdlList : ' + cdlList);
                if (cdlList.size() > 0) {
                    ContentVersion[] cvList = [
                            SELECT Id, ContentDocumentId, Title, VersionData
                            FROM ContentVersion
                            WHERE ContentDocumentId = :cdlList[0].ContentDocumentId
                    ];
                    System.debug('cvList : ' + cvList);
                    if (cvList.size() > 0) {
                        ContentVersionData contentVersionData = new ContentVersionData();
                        contentVersionData.fileName = cvList[0].Title;                                                                      //파일 이름
                        contentVersionData.versionData = EncodingUtil.base64Encode(cvList[0].VersionData);                                  //Version Data
                        contentVersionData.fileExtension = (cvList[0].Title).substringAfter('.');                                           //파일 확장자
                        referenceData.files.add(contentVersionData);
                    }
                }
                System.debug('referenceData.files : ' + referenceData.files);
            }
        } else {
            NotificationTemplate__c template = new NotificationTemplate__c();
            template.Ars080Phone__c = i2SEMA_Base.get080ARSNumber();
            referenceData.template  =  template;
        }
        response.setData('referenceData', referenceData);

        System.debug('response : ' + response);
        return response;

    }

    /**
     * @description Kakao Friend Image Id로 Kakao Friend Image URL 취득
     *
     * @param kakaoImgId Kakao Friend Image Id
     *
     * @return {i2SEMA_ComponentResponse}
     */
    @AuraEnabled
    public static i2SEMA_ComponentResponse getKakaoImgUrl(String kakaoImgId) {
        i2SEMA_ComponentResponse response = new i2SEMA_ComponentResponse();
        system.debug('getKakaoImgUrl kakaoImgId : ' + kakaoImgId);

        List<KakaoFriendTalkImage__c> friendTalkImgList = [SELECT Id, ImageURL__c FROM KakaoFriendTalkImage__c WHERE Id = :kakaoImgId];
        system.debug('friendTalkImgList : ' + friendTalkImgList);

        //Kakao FriendTalk Image 가 없으면 오류처리, 있으면 데이터를 가져오고, 성공처리
        if (friendTalkImgList.isEmpty() && i2SEMA_Util.isEmpty(friendTalkImgList[0])) {
            throw new AuraHandledException(Label.i2SEMA_MSG_EMPTY_FRIENDTALK_IMAGE);     //Msg : There is no Kakao friend talk image. Please select the kakao freind image.
        } else {
            response.setData('friendTalkImage', friendTalkImgList[0]);
        }

        return response;
    }


    /**
     * @description Notification Template 저장
     *
     * @param notificationSetting {template} 대상
     * @return {i2SEMA_ComponentResponse} 처리결과
     */
    @AuraEnabled
    public static i2SEMA_ComponentResponse saveNotificationTemplate(String recordId, Object rData) {
        i2SEMA_ComponentResponse response = new i2SEMA_ComponentResponse();

        system.debug('saveNotificationTemplate Start');

        //NotificationTemplateData wrapper object로 받기
        ReferenceData referenceData = (ReferenceData)JSON.deserialize(JSON.serialize(rData), ReferenceData.class);
        system.debug('referenceData: ' + referenceData);
        system.debug('recordId : ' + recordId);
        NotificationTemplate__c nt;

        /*--------------------------------------------
         * Template Validation
         --------------------------------------------*/
        //개인화 라벨 정규식
        if(referenceData.template.Content__c != null){
            String regex = '\\%\\%\\b(?:(?!LABEL[1-5])\\w)+\\b\\%\\%';
            String content = referenceData.template.Content__c;
            Pattern regexPattern = Pattern.compile(regex);
            Matcher regexMatcher = regexPattern.matcher(content);

            if(regexMatcher.find()){
                system.debug('regular exception');
                throw new AuraHandledException(Label.i2SEMA_MSG_VALIDATION_LABEL);   //Msg : There are invalid personalization labels. Only (%LABEL1%) to (%LABEL5%) personalization labels are allowed.
            }
        }
        //템플릿 이름을 입력하지 않으면 에러 처리
        if(String.isEmpty(referenceData.template.Name)){
            throw new AuraHandledException(Label.i2SEMA_NT_MSG_REQUIRED_TEMPLATE_NAME); //Msg : Please enter a name for the template.
        }
        //템플릿 채널을 입력하지 않으면 에러 처리
        if(referenceData.template.Channel__c == '' || String.isEmpty(referenceData.template.Channel__c)){
            throw new AuraHandledException(Label.i2SEMA_NT_MSG_REQUIRED_TEMPLATE_CHANNEL);  //Msg : Please enter a channel for the template.
        }
        //템플릿 제목을 입력하지 않으면 에러 처리
        if(referenceData.template.Channel__c != '0' && String.isEmpty(referenceData.template.Title__c)){
            throw new AuraHandledException(Label.i2SEMA_NT_MSG_REQUIRED_TEMPLATE_TITLE);    //Msg : Please enter a title for the template.
        }
        //템플릿 내용을 입력하지 않으면 에러 처리
        if(String.isEmpty(referenceData.template.Content__c)){
            throw new AuraHandledException(Label.i2SEMA_NT_MSG_REQUIRED_TEMPLATE_CONTENT);  //Msg : Please enter a contents for the template.
        }

        //Controller 에서 Validation
//        if(referenceData.template.Channel__c == '0' && referenceData.template.ContentLength__c > 80) {
//            throw new AuraHandledException(Label.i2SEMA_MSG_LIMIT_80);  //Msg : Please enter less than 80 byte.
//        } else if(referenceData.template.Channel__c != '0' && referenceData.template.ContentLength__c > 2000) {
//            throw new AuraHandledException(Label.i2SEMA_NT_MSG_REQUIRED_TEMPLATE_CONTENT);  //글 길이 2000자 오버 에러
//        }

        //채널이 MMS이고 파일이 없을 때,
        if('2'.equals(referenceData.template.Channel__c) && referenceData.files.size() < 1) {
            throw new AuraHandledException(Label.i2SEMA_MSG_BLANK_IMG); //Msg : File is required for MMS channel. Please upload the file.
        }
        //채널이 알림톡이면 수정 불가
        if ('1008'.equals(referenceData.template.Channel__c)) {
            throw new AuraHandledException(Label.i2SEMA_MSG_DUPLICATE_TEMPLATE);    //Msg : Duplicate template name exists. change the name for the template.
        }
        //채널이 카카오친구톡이고 이미지가 없을 때,
//        if(!referenceData.hasKaokaoFriendTalkImage){
//            throw new AuraHandledException(Label.i2SEMA_MSG_KAKAO_IMAGE_EMPTY);
//        }
        //채널이 카카오친구톡이고, 이미지 클릭 링크 없을치
        if('1009'.equals(referenceData.template.Channel__c) && (String.isNotEmpty(referenceData.template.KakaoImgLink__c) && i2SEMA_Util.isEmpty(referenceData.template.KakaoFriendTalkImage__c))){
            throw new AuraHandledException(Label.i2SEMA_MSG_KAKAO_IMAGE_EMPTY);     //Msg : There is no Kakao friend image in Kakao friend talk. Please select an image.
        }

        //upsert an NotificationTemplate__c
        nt = new NotificationTemplate__c();
        String content = referenceData.template.Content__c;

        if('1'.equals(referenceData.template.Type__c)) {
            String ARS_080 = '\n'+Label.i2SEMA_LAB_ARS080_FREE+' '+referenceData.template.Ars080Phone__c;
            System.debug('Type__c : '+referenceData.template.Type__c+ ' / ARS_080 :'+ARS_080);
            //광고성 무료수신거부 안내가 없을경우, 에러
            if(!content.contains(ARS_080)) {
                throw new AuraHandledException(Label.i2SEMA_MSG_INCORRECT_ARS080);  //Msg : The 080 number does not exist. Please enter the correct number.
            }
        }

        if(i2SEMA_Util.isNotEmpty(recordId)) nt.Id = recordId;          //ID
        nt.Name         = referenceData.template.Name;                  //템플릿 이름
        nt.Title__c     = referenceData.template.Title__c;              //채널이 SMS가 아니면 제목 표시
        nt.Channel__c   = referenceData.template.Channel__c;            //채널(SNS, LMS, MMS, Kakao..)
        nt.Type__c      = referenceData.template.Type__c;               //1:광고성, 2:정보성
        nt.Ars080Phone__c   = referenceData.template.Ars080Phone__c;    //무료수신거부 080번호
        nt.Content__c   = content;
        nt.ContentLength__c = referenceData.template.ContentLength__c;  //내용 길이
        nt.IsActive__c  = referenceData.template.isActive__c == null ? false : referenceData.template.isActive__c;    //템플릿 활성 유무
        nt.LABEL1__c    = content.contains('%%LABEL1%%') ? true : false;    //LABEL 1 포함
        nt.LABEL2__c    = content.contains('%%LABEL2%%') ? true : false;    //LABEL 2 포함
        nt.LABEL3__c    = content.contains('%%LABEL3%%') ? true : false;    //LABEL 3 포함
        nt.LABEL4__c    = content.contains('%%LABEL4%%') ? true : false;    //LABEL 4 포함
        nt.LABEL5__c    = content.contains('%%LABEL5%%') ? true : false;    //LABEL 5 포함

        //카카오 친구톡 일경우
        if (referenceData.hasKaokaoFriendTalkImage) {
            KakaoFriendTalkImage__c friendTalkImage = [SELECT Id, ImageURL__c FROM KakaoFriendTalkImage__c WHERE Id = :referenceData.template.KakaoFriendTalkImage__c];
            system.debug('friendTalkImage : ' + friendTalkImage);
            referenceData.template.KakaoImgUrl__c = friendTalkImage.ImageURL__c;   //카카오 친구톡 이미지 경로
            nt.KakaoFriendTalkImage__c = friendTalkImage.Id;                       //카카오 친구톡 이미지 Id Lookup
            nt.KakaoImgUrl__c = referenceData.template.KakaoImgUrl__c;             //카카오 친구톡 이미지 경로
            nt.KakaoImgLink__c = referenceData.template.KakaoImgLink__c;           //카카오 친구톡 이미지 클릭시 링크
//            response.setData('friendTalkImage', friendTalkImage);
        }

        system.debug('notificationTemplate : ' + nt);
        upsert nt;

        //카카오 친구톡일 때 카카오 버튼 링크 저장
        if (i2SEMA_Util.isNotEmpty(referenceData.kakaoButtons) && referenceData.kakaoButtons.size() > 0) {
            List<KakaoTalkbutton__c> ktbList = referenceData.kakaoButtons;
            System.debug('ktbList : '+ktbList);
            //삭제 대상 추출
            Set<Id> existKtbIds = new Set<Id>();
            for(KakaoTalkbutton__c newKtb : ktbList) {
                newKtb.NotificationTemplates__c = nt.Id;
                if(i2SEMA_Util.isNotEmpty(newKtb.Id)) existKtbIds.add(newKtb.Id);
            }

            Set<Id> delIds = new SEt<Id>();
            for(KakaoTalkbutton__c oldKtb :[SELECT Id, Name, Button_Type__c, ButtonLink1__c, ButtonLink2__c
            FROM KakaoTalkButton__c
            WHERE NotificationTemplates__c =:nt.Id ]) {
                if(!existKtbIds.contains(oldKtb.Id)) {
                    //없음 삭제
                    delIds.add(oldKtb.Id);
                }
            }

            System.debug('delIds : '+delIds);

            //이중포문? 비교 있는애 없는애
            if (delIds.size() > 0)  delete [SELECT Id FROM KakaoTalkButton__c WHERE NotificationTemplates__c =:nt.Id AND Id IN :delIds];
            if (ktbList.size() > 0) upsert ktbList;
        }

        referenceData.template = nt;
        response.setData('referenceData', referenceData);

        //파일 저장전, Content Version 존재시 일단 삭제, 중복 저장 됨(동일 파일 비교어려움 바이트 비교뿐)
        List<ContentDocumentLink> exCdlList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :nt.Id];
        if(exCdlList.size() > 0) {
            Set<String> cdIds = new Set<String>();
            for(ContentDocumentLink cdl : exCdlList) {
                cdIds.add(cdl.ContentDocumentId);
            }

            List<ContentDocument> exCdList = [SELECT Id FROM ContentDocument WHERE Id IN :cdIds];
            delete exCdList;
        }

        if (referenceData.isMMS) {
            if (!referenceData.hasMMSFiles) { //MMS채널인데, 파일없으면 에러처리
                throw new AuraHandledException(Label.i2SEMA_MSG_BLANK_IMG);         //Msg : File is required for MMS channel. Please upload the file.
            }

            system.debug('referenceData.files :' + referenceData.files);
            List<ContentVersion> cvList = new List<ContentVersion>();
            ContentVersion cv = null;
            String templateFileName = null;
            for (ContentVersionData fileData : referenceData.files) {
                cv = new ContentVersion();
                templateFileName = nt.Id+ '.'+fileData.fileExtension;
                cv.Title = templateFileName;                                        //File Name
                cv.PathOnClient = templateFileName;                                 //File Name
                cv.VersionDAta = EncodingUtil.base64Decode(fileData.versionData);   //Version Data
                cvList.add(cv);
                //reference file name 변경
                fileData.fileName = templateFileName;
            }

            system.debug('contentVersionList : ' + cvList);
            //cvList 저장할 파일이 없으면..에러
            if (cvList.isEmpty()) {
                throw new AuraHandledException(Label.i2SEMA_MSG_BLANK_IMG);     //Msg : File is required for MMS channel. Please upload the file.
            }
            insert cvList;

            // Content Document Link 저장
            Set<String> cvIds = new Set<String>();
            for (ContentVersion tcv : cvList) {
                cvIds.add(tcv.Id);
            }
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            ContentDocumentLink cdl = null;
            for (ContentVersion tcv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :cvIds]) {
                cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = tcv.ContentDocumentId;
                cdl.LinkedEntityId = nt.Id;
                cdlList.add(cdl);
            }

            system.debug('documentLinkList : ' + cdlList);
            insert cdlList;

        }
//        else if (!referenceData.isMMS) { //TODO MMS 채널이 아닐 경우 파일 삭제 불가 DML operation Delete not allowed on List<ContentVersion>
//            Set<Id> cdIds = new Set<Id>();
//            List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :nt.Id];
//            for (ContentDocumentLink cdl : cdlList) {
//                cdIds.add(cdl.ContentDocumentId);
//            }
//            List<ContentVersion> cvList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :cdIds];
//            if(cvList.size() > 0) delete cvList;
//            if(cdlList.size() > 0) delete cdlList;
//        }


        /*-------------------------------------------------------
         * Notification Template I/F 호출
         -------------------------------------------------------*/
        if (i2SEMA_Util.isNotEmpty(nt)) {
            system.debug('>>>>>>>>> 01.Notification Template I/F Request');
            Id jobId = System.enqueueJob(new i2SEMA_IFTemplateSave_qu(nt));
            system.debug('>>>>>>>>> 02.Notification Template I/F Response');
        }

        system.debug('response : ' + response);
        return response;

    }

    public class ReferenceData {
        @AuraEnabled public NotificationTemplate__c template {get; set;}           // Notification Template
        @AuraEnabled public List<ContentVersionData> files {get; set;}             // MMS 동봉파일
        @AuraEnabled public List<KakaoTalkbutton__c> kakaoButtons {get; set;}      // Kakao Talk Button List

        public ReferenceData() {
            this.files = new List<ContentVersionData>();
            this.kakaoButtons = new List<KakaoTalkbutton__c>();
        }

        /**
         * 채널 라벨 취득
         */
        @AuraEnabled public String getChannelLabel {
            get {
                String channelLabel = 'SMS';
                switch on template.Channel__c {
                    when '0'    { channelLabel = 'SMS'; }
                    when '2'    { channelLabel = 'MMS'; }
                    when '3'    { channelLabel = 'LMS'; }
                    when '1008' { channelLabel = 'Kakao Notification Talk'; }
                    when '1009' { channelLabel = 'Kakao Friend Talk'; }
                    when '10'   { channelLabel = 'Chatter'; }
                    when else   { channelLabel = ''; }
                }
                return channelLabel;
            }
            set;
        }

        /* 채널이 SMS 이면 true, 아니면 false 반화 */
        @AuraEnabled public Boolean isSMS {
            get {
                return ('0'.equals(template.Channel__c)) ? true : false;
            }
            set;
        }
        /* 채널이 MMS 이면 true, 아니면 false 반화 */
        @AuraEnabled public Boolean isMMS {
            get {
                return ('2'.equals(template.Channel__c)) ? true : false;
            }
            set;
        }
        /* 채널이 카카오 이면 true, 아니면 false 반화 */
        @AuraEnabled public Boolean isKakao {
            get {
                return ('1008'.equals(template.Channel__c) || '1009'.equals(template.Channel__c)) ? true : false;
            }
            set;
        }
        /* 채널이 카카오알림톡 이면 true, 아니면 false 반화 */
        @AuraEnabled public Boolean isKakaoNotiTalk {
            get {
                return ('1008'.equals(template.Channel__c)) ? true : false;
            }
            set;
        }
        /* 채널이 카카오친구톡 이면 true, 아니면 false 반화 */
        @AuraEnabled public Boolean isKakaoFriendTalk {
            get {
                return ('1009'.equals(template.Channel__c)) ? true : false;
            }
            set;
        }
        /* 채널이 카카오친구톡이고, 친구톡 이미지가 존재하면 true, 아니면 false 반화 */
        @AuraEnabled public Boolean hasKaokaoFriendTalkImage {
            get {
                return (isKakaoFriendTalk && i2SEMA_Util.isNotEmpty(template.KakaoImgUrl__c)) ? true : false;
            }
            set;
        }
        /* 채널이 SMS 이면 true, 아니면 false 반화 */
        @AuraEnabled public Boolean isNone {
            get {
                return (isSMS || isMMS || isKakao) ? false : true;
            }
            set;
        }
        /* 채널이 MMS 이고 첨부파일 존재하면 true, 아니면 false 반화 */
        @AuraEnabled public Boolean hasMMSFiles {
            get {
                return (isMMS && files.size() > 0) ? true : false;
            }
            set;
        }
        /* 채널이 카카오 이고 카카오 버튼 존재하면 true, 아니면 false 반화 */
        @AuraEnabled public Boolean hasKaokaoButtons {
            get {
                return (isKakao && kakaoButtons.size() > 0) ? true : false;
            }
            set;
        }
    }

    /**
    * 첨부파일 wrapper class
    */
    public class ContentVersionData {
        @AuraEnabled public String fileName         {get; set;} //ContentVersion - File Name
        @AuraEnabled public String versionData      {get; set;} //ContentVersion - Version Data
        @AuraEnabled public String fileExtension    {get; set;} //ContentVersion - File Extension
    }


}