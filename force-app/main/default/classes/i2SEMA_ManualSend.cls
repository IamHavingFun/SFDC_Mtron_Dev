/****************************************************************************************
  * @filename       : i2SEMA_ManualSend
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-08 오후 2:12
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         :
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-08 오후 2:12     i2max_byeon.jw       Create
****************************************************************************************/

public with sharing class i2SEMA_ManualSend extends i2SEMA_Base {

    static Set<String> ReceiverPrefix = new Set<String>{
            Schema.SObjectType.Account.getKeyPrefix(),
            Schema.SObjectType.Contact.getKeyPrefix(),
            Schema.SObjectType.Lead.getKeyPrefix(),
            Schema.SObjectType.User.getKeyPrefix()
    };

    /**
     * @description 컴포넌트 초기화
     *  Data 거래를 위한 초기 Wrapper 클래스 생성, UI 참조정보 설정
     *
     * @param recordId {String} UI Record ID
     * @return {i2SEMA_ComponentResponse}
     */
    @AuraEnabled
    public static i2SEMA_ComponentResponse initialize(String recordId){
        system.debug('[i2SEMA_ManualSend] - initialize');
        i2SEMA_ComponentResponse response = new i2SEMA_ComponentResponse();

        // Ref, Req Data
        ReferenceData refData   = new ReferenceData(recordId);
        RequestData reqData     = new RequestData(recordId);

        // 채널 선택목록
        {
            Boolean chatterEnabled = i2SEMA_Base.checkChatterEnabled();
            Map<String,String> channelMap = i2SEMA_Util.getPicklistValue('Notification__c','Channel__c');

            for(String value : channelMap.keySet()){
                // Chatter 기능 누락
                // Kakao Talk 관련 채널은 선택목록에서 제외
                if( '10'.equalsIgnoreCase(value) || '1008'.equalsIgnoreCase(value) || '1009'.equalsIgnoreCase(value)){
                    continue;
                }

                refData.channelOptions.add(new Option(channelMap.get(value),value));
            }
        }

        // 타입 선택목록
        {
            Map<String,String> typeMap = i2SEMA_Util.getPicklistValue('Notification__c','Type__c');

            for( String value : typeMap.keySet()){
                refData.typeOptions.add( new Option(typeMap.get(value),value));
            }
        }

        // 수신자로 선택가능한 목록
        {
            if(i2SEMA_Util.isNotEmpty(recordId) && ReceiverPrefix.contains(recordId.left(3))){
                refData.receiverOptions.add(new Option(Label.i2SEMA_LAB_CURRENT_RECORD,Label.i2SEMA_LAB_CURRENT_RECORD));
            }
            if(i2SEMA_Util.isNotEmpty(recordId)){
                refData.receiverOptions.add(new Option(Label.i2SEMA_LAB_REFERENCE_FIELD,Label.i2SEMA_LAB_REFERENCE_FIELD));
                refData.receiverOptions.add(new Option(Label.i2SEMA_LAB_RELATED_RECORD,Label.i2SEMA_LAB_RELATED_RECORD));
            }
            refData.receiverOptions.add(new Option(Label.i2SEMA_LAB_SPECIFIC_RECORD,Label.i2SEMA_LAB_SPECIFIC_RECORD));
        }

        // 현재 레코드의 참조필드(Look-up) 을 수신자로 설정하기 위한 옵션
        List<Option> referenceFieldOptions      = new List<Option>();
        Map<String,String> referenceFieldTypes  = new Map<String,String>();
        {
            if(i2SEMA_Util.isNotEmpty(recordId)){

                Map<String,SObjectField> fieldMap = Schema.describeSObjects(new List<String>{refData.recordType}).get(0).fields.getMap();

                for( SObjectField field : fieldMap.values() ){
                    DescribeFieldResult fieldDesc = field.getDescribe();

                    // Reference Type 인 경우 (Account,Contact,Lead)
                    if( fieldDesc.getType() == Schema.DisplayType.REFERENCE ){
                        Set<String> refTypes = new Set<String>();
                        String uniqueType;
                        for( SObjectType referenceType : fieldDesc.getReferenceTo()){
                            refTypes.add(referenceType.getDescribe().getName());
                            uniqueType = referenceType.getDescribe().getName();
                        }

                        // 수신자 설정 가능한 타입을 목록에 추가
                        if( refTypes.size() == 1 && (refTypes.contains(SObjectType.Account.getName()) || refTypes.contains(SObjectType.Contact.getName())
                                || refTypes.contains(SObjectType.Lead.getName()) || refTypes.contains(SObjectType.User.getName()))){

                            referenceFieldOptions.add(new Option( '[' + String.join(new List<String>(refTypes),'/')+ '] ' +fieldDesc.getLabel(), fieldDesc.getName()));
                            referenceFieldTypes.put(fieldDesc.getName(),uniqueType);
                        }
                    }
                }
                refData.referenceFieldOptions   = referenceFieldOptions;
                refData.referenceFieldTypes     = referenceFieldTypes;
            }
        }

        // 현재 레코드의 하위 Object 를 수신자로 설정하기 위한 옵션
        Map<String,String> relatedObjects = new Map<String,String>();
        {
            if(i2SEMA_Util.isNotEmpty(recordId)){
                // Account,Contact,Lead,User,Campaign Member 가 페이지의 레코드 오브젝트 타입을 Reference 하고 있는지 확인
                List<String> receiverObjectTypes = new List<String>{SObjectType.Account.getName(),SObjectType.Contact.getName()
                        ,SObjectType.Lead.getName(),SObjectType.User.getName(),SObjectType.CampaignMember.getName()};

                List<DescribeSObjectResult> objectDescribes = Schema.describeSObjects(receiverObjectTypes);
                for( DescribeSObjectResult dsr : objectDescribes ){
                    Map<String,SObjectField> fieldMap = dsr.fields.getMap();
                    for( SObjectField field : fieldMap.values()){
                        DescribeFieldResult dfr = field.getDescribe();

                        // Field 타입이 Reference 이며, 참조하는 Object 가 현재 Record 와 동일한 경우에 관련목록에 추가
                        if((dfr.getType() == Schema.DisplayType.REFERENCE)){
                            Set<String> referenceTypes = new Set<String>();
                            for( SObjectType referenceType : dfr.getReferenceTo()){
                                referenceTypes.add(referenceType.getDescribe().getName());
                            }
                            if( referenceTypes.contains( refData.recordType )){
                                // 옵션 중복 회피를 위해 별도 보관
                                relatedObjects.put(dsr.getName(),dsr.getLabel());
                            }
                        }
                    }
                }
            }
            for( String relatedObjectName : relatedObjects.keySet()){
                String relatedObjectLabel = relatedObjects.get(relatedObjectName);
                refData.receiverTypeOptions.add(new Option(relatedObjectLabel,relatedObjectName));
            }
        }

        // 특정 레코드를 수신자로 설정하기 위한 옵션
        List<Option> specificTypeOptions = new List<Option>();
        {
            specificTypeOptions.add(new Option(SObjectType.Account.getLabel(),SObjectType.Account.getName()));
            specificTypeOptions.add(new Option(SObjectType.Contact.getLabel(),SObjectType.Contact.getName()));
            specificTypeOptions.add(new Option(SObjectType.Lead.getLabel(),SObjectType.Lead.getName()));
            specificTypeOptions.add(new Option(SObjectType.User.getLabel(),SObjectType.User.getName()));

            refData.specificTypeOptions = specificTypeOptions;
        }

        // Template Label 변환을 위한 전체 가용 SObject 의 필드목록 조회
        TemplateOption templateOption = new TemplateOption();
        {
            // 조회할 관련 Object 타입 선별
            Set<String> wholeSObjectTypes = new Set<String>{SObjectType.Account.getName(),SObjectType.Contact.getName(),SObjectType.Lead.getName(),SObjectType.User.getName(),SObjectType.CampaignMember.getName()};
            if(i2SEMA_Util.isNotEmpty(refData.recordType)){
                wholeSObjectTypes.add(refData.recordType);
            }

            // Template Option 생성
            List<DescribeSObjectResult> objectDescribes = Schema.describeSObjects(new List<String>(wholeSObjectTypes));
            List<Option> fieldOptions;

            for( DescribeSObjectResult dsr : objectDescribes ){
                templateOption.wholeSObjectTypes.add(new Option(dsr.getLabel(),dsr.getName()));
                fieldOptions = new List<Option>();

                Map<String,SObjectField> fieldMap = dsr.fields.getMap();
                for( SObjectField field : fieldMap.values()){
                    fieldOptions.add(new Option(field.getDescribe().getLabel(),field.getDescribe().getName()));
                }
                templateOption.wholeSObjectFields.put(dsr.getName(),fieldOptions);
            }
            refData.templateOption = templateOption;
        }

        reqData.arsPhone = i2SEMA_Base.get080ARSNumber();

        response.setData('refData',refData);
        response.setData('reqData',reqData);

        return response;
    }
    /**
     * @description Template 정보 조회
     *
     * @param refData {Object} ReferenceData Object - Managed Package 에서 Inner Class 타입으로 자동캐스팅 X
     * @param reqData {Object} Request Object - Managed Package 에서 Inner Class 타입으로 자동캐스팅 X
     */
    @AuraEnabled
    public static i2SEMA_ComponentResponse getTemplateData(Object refData, Object reqData){
        i2SEMA_ComponentResponse response = new i2SEMA_ComponentResponse();

        ReferenceData referenceData = (ReferenceData)JSON.deserialize(JSON.serialize(refData),ReferenceData.class);
        RequestData requestData     = (RequestData)JSON.deserialize(JSON.serialize(reqData),RequestData.class);


        if(i2SEMA_Util.isNotEmpty(requestData.templateId)){

            List<NotificationTemplate__c> templates = [SELECT Id
                    ,Channel__c
                    ,Title__c
                    ,Content__c
                    ,LABEL1__c
                    ,LABEL2__c
                    ,LABEL3__c
                    ,LABEL4__c
                    ,LABEL5__c
                    // [20.07.27] 광고,정보성 구분 및 080 번호 추가
                    ,Type__c
                    ,Ars080Phone__c
            FROM NotificationTemplate__c
            WHERE Id =:requestData.templateId
            AND IsActive__c = TRUE];

            NotificationTemplate__c template = !templates.isEmpty() ? templates[0] : null;

            if( template != null ){
                referenceData.template = template;

                requestData.channel = template.Channel__c;
                requestData.title   = template.Title__c;
                requestData.content = template.Content__c;

                if( template.LABEL1__c == true ) requestData.templateSettings.add( new TemplateSetting(Label.i2SEMA_LAB_LABEL_01_VAL,referenceData.templateOption));
                if( template.LABEL2__c == true ) requestData.templateSettings.add( new TemplateSetting(Label.i2SEMA_LAB_LABEL_02_VAL,referenceData.templateOption));
                if( template.LABEL3__c == true ) requestData.templateSettings.add( new TemplateSetting(Label.i2SEMA_LAB_LABEL_03_VAL,referenceData.templateOption));
                if( template.LABEL4__c == true ) requestData.templateSettings.add( new TemplateSetting(Label.i2SEMA_LAB_LABEL_04_VAL,referenceData.templateOption));
                if( template.LABEL5__c == true ) requestData.templateSettings.add( new TemplateSetting(Label.i2SEMA_LAB_LABEL_05_VAL,referenceData.templateOption));

                requestData.type        = template.Type__c;
                requestData.arsPhone    = template.Ars080Phone__c;
            }
        }
        response.setData('referenceData',referenceData);
        response.setData('requestData',requestData);

        return response;
    }
    /**
     * @description Notification 저장
     */
    @AuraEnabled
    public static i2SEMA_ComponentResponse saveRequest(Object reqData){
        i2SEMA_ComponentResponse response = new i2SEMA_ComponentResponse();

        RequestData requestData     = (RequestData)JSON.deserialize(JSON.serialize(reqData),RequestData.class);

        // 유효확인
        i2SEMA_ManualSend.checkRequestValidity(requestData);

        // 수신자 ID 목록 획득 : 수신자 타입별 처리
        Set<String> receiverIds = new Set<String>();    // 수신자들의 Record ID
        String receiverType;                            // 수신자들의 SObject Type
        {
            // 1. 현재 레코드에게 발송
            if( requestData.receiverOption == Label.i2SEMA_LAB_CURRENT_RECORD ){
                receiverIds.add(requestData.recordId);
                receiverType = requestData.recordType;
            }
            // 2. Look-up 레코드에게 발송
            else if( requestData.receiverOption == Label.i2SEMA_LAB_REFERENCE_FIELD ){
                String selectStatement  = ' SELECT ' + requestData.referenceField;
                String fromStatement    = ' FROM ' + requestData.recordType;
                String whereStatement   = ' WHERE Id = \'' + requestData.recordId + '\'';

                system.debug(selectStatement + fromStatement + whereStatement);
                List<SObject> results = Database.query(selectStatement + fromStatement + whereStatement);

                if( results.size() == 1 && results[0].get(requestData.referenceField) != null ){
                    receiverIds.add( String.valueOf(results[0].get(requestData.referenceField)));
                }

                receiverType = requestData.referenceFieldType;
            }
            // 3. 하위 레코드에게 발송
            else if( requestData.receiverOption == Label.i2SEMA_LAB_RELATED_RECORD ){
                receiverIds.addAll(requestData.receiverIds);
                receiverType = requestData.receiverType;
            }
            // 4. 특정 레코드에게 발송
            else if( requestData.receiverOption == Label.i2SEMA_LAB_SPECIFIC_RECORD ){
                for( Receiver specificReceiver : requestData.specificReceivers ){
                    if( i2SEMA_Util.isNotEmpty(specificReceiver.Id)){
                        receiverIds.add(specificReceiver.Id);
                    }
                    receiverType = requestData.receiverType;
                }
            }
        }

        // Campaign Member 가 수신타겟일 경우, Campaign Member 레코드의 Contact 또는 Lead 레코드를 수신자 정보 둔다.
        Map<String,String> campaignMemberContactTarget = new Map<String,String>();
        Map<String,String> campaignMemberLeadTarget = new Map<String,String>();
        if( Schema.SObjectType.CampaignMember.getName().equals(receiverType) && !receiverIds.isEmpty()){
            List<CampaignMember> campaignMembers = [SELECT Id,ContactId,LeadId FROM CampaignMember WHERE Id IN:receiverIds ];
            for( CampaignMember campaignMember : campaignMembers ){
                if( i2SEMA_Util.isNotEmpty(campaignMember.ContactId)){
                    campaignMemberContactTarget.put( campaignMember.Id , campaignMember.ContactId );
                }
                else if( i2SEMA_Util.isNotEmpty(campaignMember.LeadId)){
                    campaignMemberLeadTarget.put( campaignMember.Id , campaignMember.LeadId);
                }
            }
        }

        // [Exception] 수신자 ID 가 확인되지 않는경우 Exception, 유효하지 않은 수신자 타입도 에러
        Set<String> validReceiverType = new Set<String>{SObjectType.Account.getName(),SObjectType.Contact.getName(),SObjectType.Lead.getName(),SObjectType.User.getName(),SObjectType.CampaignMember.getName()};
        if( receiverIds.isEmpty()){
            throw new AuraHandledException(Label.i2SEMA_MSG_RECEIVER_NOT_FOUND);
        }
        else if( !validReceiverType.contains(receiverType)){
            throw new AuraHandledException(Label.i2SEMA_MSG_RECEIVER_TYPE_INVALID + ' : ' + receiverType);
        }



        // Template 사용시, 변환되는 수신자 ID 별 Label <> Value 추출
        Map<String,Map<String,String>> receiverLabelValues = new Map<String,Map<String,String>>();
        Map<String,String> labelValues;
        {
            if( i2SEMA_Util.isNotEmpty(requestData.templateId)){

                // 조회할 Object 별 필드 분리
                Map<String,Set<String>> objectQueryFields = new Map<String,Set<String>>();
                for( TemplateSetting templateSetting : requestData.templateSettings ){
                    if( i2SEMA_Util.isNotEmpty(templateSetting.sObjectType) && i2SEMA_Util.isNotEmpty(templateSetting.sObjectField)){
                        Set<String> fields = objectQueryFields.containsKey(templateSetting.sObjectType) ? objectQueryFields.get(templateSetting.sObjectType) : new Set<String>{};
                        fields.add(templateSetting.sObjectField);
                        objectQueryFields.put( templateSetting.sObjectType , fields );
                    }
                }

                // 현재 레코드 조회
                SObject sourceRecordData;
                if( i2SEMA_Util.isNotEmpty(requestData.recordId)){
                    Set<String> fields = objectQueryFields.get(requestData.recordType);

                    if( fields != null && !fields.isEmpty()){
                        String selectStatement  = ' SELECT ' + String.join(new List<String>(fields),',');
                        String fromStatement    = ' FROM ' + requestData.recordType;
                        String whereStatement   = ' WHERE Id = \'' + requestData.recordId + '\'';

                        system.debug(selectStatement + fromStatement + whereStatement);

                        Map<Id,SObject> sourceRecordDataMap = new Map<Id,SObject>(Database.query( selectStatement + fromStatement + whereStatement ));
                        sourceRecordData = sourceRecordDataMap.get(requestData.recordId);
                    }
                }

                // 수신자 레코드 조회
                Map<Id,SObject> receiverRecordData;
                if( !receiverIds.isEmpty() ){
                    Set<String> fields = objectQueryFields.get(receiverType);

                    if( fields != null && !fields.isEmpty()){
                        String selectStatement  = ' SELECT ' + String.join(new List<String>(fields),',');
                        String fromStatement    = ' FROM ' + receiverType;
                        String whereStatement   = ' WHERE Id IN: receiverIds';

                        system.debug(selectStatement + fromStatement + whereStatement);

                        receiverRecordData = new Map<Id,SObject>(Database.query( selectStatement + fromStatement + whereStatement ));
                    }
                }

                // 수신자 별 Label 치환값 분리
                for( TemplateSetting templateSetting : requestData.templateSettings ){
                    // 현재 레코드를 참조하는 Label 처리
                    if( templateSetting.sObjectType == requestData.recordType ){
                        for( String receiverId : receiverIds ){
                            labelValues = receiverLabelValues.containsKey(receiverId) ? receiverLabelValues.get(receiverId) : new Map<String,String>();
                            labelValues.put( templateSetting.label , String.valueOf(sourceRecordData.get(templateSetting.sObjectField)));
                            receiverLabelValues.put(receiverId , labelValues);
                        }
                    }
                    // 수신자 레코드를 참조하는 Label 처리
                    else if( templateSetting.sObjectType == receiverType ){
                        for( String receiverId : receiverIds ){
                            SObject receiverRecord = receiverRecordData.get(receiverId);
                            labelValues = receiverLabelValues.containsKey(receiverId) ? receiverLabelValues.get(receiverId) : new Map<String,String>();
                            labelValues.put( templateSetting.label , String.valueOf(receiverRecord.get(templateSetting.sObjectField)));
                            receiverLabelValues.put(receiverId , labelValues);
                        }
                    }
                }
            }
        }

        // Notification Group & Notification 생성
        NotificationGroup__c ntGroup        = new NotificationGroup__c();
        List<Notification__c> notifications = new List<Notification__c>();
        Notification__c nt;
        {
            ntGroup.IF_Status__c    = requestData.scheduled == true ? 'Pending' : null;
            ntGroup.TargetId__c     = requestData.recordId;
            insert ntGroup;

            for( String receiverId : receiverIds ){
                nt = new Notification__c();

                nt.NotificationGroup__c     = ntGroup.Id;

                // 수신자 ID
                //  - Campaign Member 타입은 연결된 Contact 또는 Lead 를 Mapping 한다.
                nt.Account__c               = 'Account'.equalsIgnoreCase(receiverType) ? receiverId : null;
                nt.Contact__c               = 'Contact'.equalsIgnoreCase(receiverType) ? receiverId : 'CampaignMember'.equalsIgnoreCase(receiverType) ? campaignMemberContactTarget.get(receiverId) : null;
                nt.Lead__c                  = 'Lead'.equalsIgnoreCase(receiverType) ? receiverId : 'CampaignMember'.equalsIgnoreCase(receiverType) ? campaignMemberLeadTarget.get(receiverId) : null;
                nt.User__c                  = 'User'.equalsIgnoreCase(receiverType) ? receiverId : null;

                nt.Type__c                  = requestData.type;
                nt.ARS_080_Phone__c         = requestData.arsPhone;

                nt.Channel__c               = requestData.channel;
                nt.TargetId__c              = requestData.recordId;
                nt.NotificationTemplate__c  = requestData.templateId;
                nt.Title__c                 = requestData.title;
                nt.RawContents__c           = requestData.content;

                if( i2SEMA_Util.isNotEmpty(requestData.templateId)){
                    Map<String,String> labelValueMap = receiverLabelValues.containsKey(receiverId) ? receiverLabelValues.get(receiverId) : new Map<String,String>();
                    nt.LABEL1__c = labelValueMap.get(Label.i2SEMA_LAB_LABEL_01_VAL);
                    nt.LABEL2__c = labelValueMap.get(Label.i2SEMA_LAB_LABEL_02_VAL);
                    nt.LABEL3__c = labelValueMap.get(Label.i2SEMA_LAB_LABEL_03_VAL);
                    nt.LABEL4__c = labelValueMap.get(Label.i2SEMA_LAB_LABEL_04_VAL);
                    nt.LABEL5__c = labelValueMap.get(Label.i2SEMA_LAB_LABEL_05_VAL);
                }

                nt.IsSendingReservation__c  = requestData.scheduled == true;
                nt.SendingTime__c           = requestData.scheduled == true ? Datetime.newInstanceGmt(requestData.scheduledTime.date(),requestData.scheduledTime.time()) : null;
                nt.msg_status__c            = requestData.scheduled == true ? 'Pending' : null;

                notifications.add(nt);
            }
            insert notifications;
        }


        // File 처리
        List<ContentVersion> contentVersions;               // 신규 생성된 Content Version
        Map<String,String> versionDocumentIds;              // Template 을 사용하지 않는 Notification 의 첨부파일 Document ID
        List<ContentDocumentLink> groupTemplateFileLinks;   // Template 을 사용하는 Notification 의 첨부파일 Link
        ContentVersion cv;
        {
            // 템플릿을 사용하지 않으며 첨부한 파일이 있는 경우, Notification Group 에 첨부한 파일의 Link 를 추가
            if( i2SEMA_Util.isEmpty(requestData.templateId) && !requestData.files.isEmpty()){
                // Content Version
                contentVersions = new List<ContentVersion>();
                for( FileData fileData : requestData.files ){
                    String fileName = fileData.fileName;
                    Blob fileBody   = EncodingUtil.base64Decode(fileData.blobData);

                    cv              = new ContentVersion();
                    cv.Title        = fileName;
                    cv.VersionData  = fileBody;
                    cv.PathOnClient = fileName;

                    contentVersions.add(cv);
                }
                insert contentVersions;

                // Content Document Link
                versionDocumentIds = new Map<String,String>();
                for( ContentVersion cvData : contentVersions ){
                    versionDocumentIds.put(cvData.Id,null);
                }
                for( ContentVersion cvData : [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN:versionDocumentIds.keySet()]){
                    versionDocumentIds.put(cvData.Id, cvData.ContentDocumentId);
                }
                List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
                for( String contentVersionId : versionDocumentIds.keySet() ){
                    String contentDocumentId = versionDocumentIds.get(contentVersionId);

                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId   = contentDocumentId;
                    cdl.LinkedEntityId      = ntGroup.Id;

                    documentLinks.add(cdl);
                }
                insert documentLinks;
            }
            // 템플릿을 사용할 경우, 템플릿에 정의된 첨부파일의 Link 를 Notification Group 에 추가
            else if( i2SEMA_Util.isNotEmpty(requestData.templateId) ){
                List<ContentDocumentLink> templateFileLinks = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:requestData.templateId];

                groupTemplateFileLinks = new List<ContentDocumentLink>();
                for( ContentDocumentLink templateFileLink : templateFileLinks ){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId   = templateFileLink.ContentDocumentId;
                    cdl.LinkedEntityId      = ntGroup.Id;

                    groupTemplateFileLinks.add(cdl);
                }
                insert groupTemplateFileLinks;
            }
        }

        // Interface 호출 : 예약 발신은 스케쥴러를 통해 발송
        if(requestData.scheduled != true){
            i2SEMA_IFNotificationSend_qu messageQueue = new i2SEMA_IFNotificationSend_qu(notifications);
            Id messageJobId = System.enqueueJob(messageQueue);

        }

        return response;
    }

    /**
     * @description 유효성 체크
     *  - 유형별 필수항목
     *  - 기능상 확인항목
     */
    public static void checkRequestValidity(RequestData reqData){

        // 누락항목 ( 수신자는 발송단계에서 체크 )
        if( reqData.hasEmptyProperty() ){
            throw new AuraHandledException(Label.i2SEMA_MSG_REQUIRED_FIELD_EMPTY);
        }

        // 예약시간
        else if( reqData.scheduled == true){
            Datetime now = Datetime.now();

            if( now.addMinutes(i2SEMA_Base.getReservationMinTime()) > reqData.scheduledTime || now.addMonths(i2SEMA_Base.getReservationMaxTime()) < reqData.scheduledTime ){
                throw new AuraHandledException(Label.i2SEMA_MSG_SCHEDULE_TIME_INVALID + ' (' + i2SEMA_Base.getReservationMinTime()+'Minutes - ' + i2SEMA_Base.getReservationMaxTime()+'Month)');
            }
        }
        // Template 을 사용하는 경우
        else if( i2SEMA_Util.isNotEmpty(reqData.templateId)){
            // Template 유효성 체크
            NotificationTemplate__c template = [SELECT Id,IsActive__c,IF_Status__c FROM NotificationTemplate__c WHERE Id =:reqData.templateId];
            if( template.IsActive__c != true || !'Completed'.equalsIgnoreCase(template.IF_Status__c)){
                throw new AuraHandledException(Label.i2SEMA_MSG_TEMPLATE_INVALID);
            }

            // Template Label 항목 확인
            for( TemplateSetting templateSetting : reqData.templateSettings ){
                if( i2SEMA_Util.isEmpty(templateSetting.sObjectType) || i2SEMA_Util.isEmpty(templateSetting.sObjectField)) {
                    throw new AuraHandledException(Label.i2SEMA_MSG_TEMPLATE_LABEL_INVALID);
                }
            }
        }
        //광고성일 경우, 무료수신거부 메세지 포함
        else if('1'.equals(reqData.type)) {
            String ARS_080 = '\n'+Label.i2SEMA_LAB_ARS080_FREE+' '+reqData.arsPhone;
            System.debug('Type__c : '+reqData.type+ ' / ARS_080 :'+ARS_080);
            //광고성 무료수신거부 안내가 없을경우, 에러
            if(!reqData.content.contains(ARS_080)) {
                throw new AuraHandledException(Label.i2SEMA_MSG_INCORRECT_ARS080);  //Msg : The 080 number does not exist. Please enter the correct number.
            }
        }
        // Message 길이 확인
        else if( !i2SEMA_Util.isValidMessageLength(reqData.channel , reqData.content)){
            throw new AuraHandledException(Label.i2SEMA_MSG_LENGTH_LIMIT_EXCEED);
        }
    }


    public class ReferenceData {
        @AuraEnabled public String recordId                             {get;set;}      // Record ID
        @AuraEnabled public String recordType                           {get;set;}      // Record SObject Type
        @AuraEnabled public List<Option> channelOptions                 {get;set;}      // 채널 선택목록
        // 수신자 관련 참조정보
        @AuraEnabled public List<Option> receiverOptions                {get;set;}      // 수신자 선택목록
        @AuraEnabled public List<Option> referenceFieldOptions          {get;set;}      // Look-up 필드 목록
        @AuraEnabled public Map<String,String> referenceFieldTypes      {get;set;}      // Look-up 필드의 SObject Type
        @AuraEnabled public List<Option> receiverTypeOptions            {get;set;}      // Child SObject 목록
        @AuraEnabled public List<Option> specificTypeOptions            {get;set;}      // 특정타입 수신자 선택목록
        // 템플릿 관련 참조정보
        @AuraEnabled public NotificationTemplate__c template            {get;set;}      // 선택한 Template 상세정보
        @AuraEnabled public TemplateOption templateOption               {get;set;}      // 템플릿 Label 가용정보
        @AuraEnabled public List<Option> typeOptions                    {get;set;}      // 타입(광고성,정보성) 선택목록

        public ReferenceData(){
            this.channelOptions         = new List<Option>();
            this.receiverOptions        = new List<Option>();
            this.receiverTypeOptions    = new List<Option>();
            this.typeOptions            = new List<Option>();
            this.templateOption         = new TemplateOption();
        }
        public ReferenceData(String recordId){
            if( i2SEMA_Util.isNotEmpty(recordId)){
                this.recordId       = recordId;
                this.recordType     = Id.valueOf(recordId).getSobjectType().getDescribe().getName();
            }
            this.channelOptions         = new List<Option>();
            this.receiverOptions        = new List<Option>();
            this.receiverTypeOptions    = new List<Option>();
            this.typeOptions            = new List<Option>();
            this.templateOption         = new TemplateOption();
        }
    }
    public class RequestData {
        @AuraEnabled public String recordId                             {get;set;}      // Record ID
        @AuraEnabled public String recordType                           {get;set;}      // Record SObject Type
        @AuraEnabled public String channel                              {get;set;}      // Channel
        // 수신자 관련
        @AuraEnabled public String receiverOption                       {get;set;}      // 수신자 옵션
        @AuraEnabled public String receiverType                         {get;set;}      // (하위,특정) 레코드 Object Type
        @AuraEnabled public List<String> receiverIds                    {get;set;}      // (하위) 수신자 ID 목록
        @AuraEnabled public List<Receiver> specificReceivers            {get;set;}      // (특정) 수신자 목록
        @AuraEnabled public String referenceField                       {get;set;}      // (상위) Look-up 필드
        @AuraEnabled public String referenceFieldType                   {get;set;}      // (상위) Look-up 필드의 Object Type
        // 템플릿 관련
        @AuraEnabled public String templateId                           {get;set;}
        @AuraEnabled public List<TemplateSetting> templateSettings      {get;set;}
        @AuraEnabled public String type                                 {get;set;}      // 1: 광고성 , 2: 정보성
        @AuraEnabled public String arsPhone                             {get;set;}      // 080 수신거부 번호
        // 본문 관련
        @AuraEnabled public String title                                {get;set;}
        @AuraEnabled public String content                              {get;set;}
        @AuraEnabled public List<FileData> files                        {get;set;}
        @AuraEnabled public Boolean scheduled                           {get;set;}
        @AuraEnabled public Datetime scheduledTime                      {get;set;}

        public RequestData(){
            this.receiverIds        = new List<String>();
            this.templateSettings   = new List<TemplateSetting>();
            this.files              = new List<FileData>();
            this.specificReceivers  = new List<Receiver>();
        }
        public RequestData(String recordId){
            if( i2SEMA_Util.isNotEmpty(recordId)){
                this.recordId       = recordId;
                this.recordType     = Id.valueOf(recordId).getSobjectType().getDescribe().getName();
            }
            this.receiverIds        = new List<String>();
            this.templateSettings   = new List<TemplateSetting>();
            this.files              = new List<FileData>();
            this.specificReceivers  = new List<Receiver>();
        }

        public Boolean hasEmptyProperty(){
            Boolean requiredFieldEmpty = i2SEMA_Util.isEmpty(this.channel) || i2SEMA_Util.isEmpty(this.receiverOption) || i2SEMA_Util.isEmpty(this.content)
                    || (i2SEMA_Util.isEmpty(this.type) || ('1'.equals(this.type) && i2SEMA_Util.isEmpty(this.arsPhone)))
                    || (this.scheduled == true && i2SEMA_Util.isEmpty(this.scheduledTime));
            Boolean receiverFieldEmpty = (this.receiverOption == Label.i2SEMA_LAB_CURRENT_RECORD && i2SEMA_Util.isEmpty(this.recordId))
                    || (this.receiverOption == Label.i2SEMA_LAB_RELATED_RECORD && i2SEMA_Util.isEmpty(this.receiverType))
                    || (this.receiverOption == Label.i2SEMA_LAB_REFERENCE_FIELD && i2SEMA_Util.isEmpty(this.referenceField))
                    || (this.receiverOption == Label.i2SEMA_LAB_SPECIFIC_RECORD && i2SEMA_Util.isEmpty(this.specificReceivers));

            return requiredFieldEmpty || receiverFieldEmpty;
        }

    }

    public class Receiver {
        @AuraEnabled public String Id               {get;set;}
    }

    public class TemplateOption {
        @AuraEnabled public List<Option> wholeSObjectTypes                  {get;set;}      // 현재 레코드와 모든 수신자 SObject 타입
        @AuraEnabled public List<Option> availableSObjectTypes              {get;set;}      // 현재 레코드 + 선택된 수신자 SObject 타입
        @AuraEnabled public Map<String,List<Option>> wholeSObjectFields     {get;set;}      // SObject 타입별 필드목록 (현재 Record, 수신자 타입 > Template Label 설정용도)
        @AuraEnabled public List<Option> availableSObjectFields             {get;set;}      // 선택된 SObject 의 필드목록

        public TemplateOption(){
            this.wholeSObjectTypes      = new List<Option>();
            this.availableSObjectTypes  = new List<Option>();
            this.wholeSObjectFields     = new Map<String,List<Option>>();
            this.availableSObjectFields = new List<Option>();
        }
    }

    public class TemplateSetting {
        @AuraEnabled public String label                    {get;set;}
        @AuraEnabled public String sObjectType              {get;set;}
        @AuraEnabled public String sObjectField             {get;set;}
        @AuraEnabled public TemplateOption templateOption   {get;set;}

        public TemplateSetting(){}
        public TemplateSetting(String label, TemplateOption templateOption){
            this.label          = label;
            this.templateOption = templateOption;
        }
    }

    public class FileData {
        @AuraEnabled public String fileName         {get;set;}
        @AuraEnabled public String blobData         {get;set;}
    }
    public class Option {
        @AuraEnabled public String label            {get;set;}
        @AuraEnabled public String value            {get;set;}

        public Option(){}
        public Option( String label, String value ){
            this.label = label;
            this.value = value;
        }
    }
}