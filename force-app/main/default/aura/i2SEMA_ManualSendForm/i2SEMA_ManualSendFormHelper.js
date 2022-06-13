/****************************************************************************************
 * @filename       : i2SEMA_ManualSendFormHelper.js
 * @projectname    : i2SEMA Core
 * @author         : i2max_byeon.jw
 * @date           : 2020-04-13 오전 9:07
 * @group          :
 * @group-content  :
 * @description    :
 * @copyright      : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                author              description
 * ===============================================================
 0.1     2020-04-13 오전 9:07     i2max_byeon.jw       Create
 ****************************************************************************************/
({
    /**
     * @description 수신자 관련정보 초기화
     */
    fn_receiverInitialize : function(requestData){
        if( requestData != null ){
            requestData.receiverOption      = null;
            requestData.receiverType        = null;
            requestData.referenceField      = null;
            requestData.referenceFieldType  = null;
            requestData.receiverIds         = [];
            requestData.specificReceivers   = [];
        }
        return requestData;
    },
    /**
     * @description 템플릿 관련정보 초기화
     */
    fn_templateInitialize : function(requestData){
        if( requestData != null ){
            requestData.templateId          = null;
            requestData.templateSettings    = [];

            requestData.channel             = null;
            requestData.title               = null;
            requestData.contents            = null;
            requestData.files               = [];
        }
        return requestData;
    },
    /**
     * @description Template Setting 초기화
     */
    fn_templateSettingInitialize : function(requestData){
        if( requestData != null ){
            let selectedTypes = [];

            // 현재 레코드의 Object 타입
            if( !$A.util.isEmpty(requestData.recordType)){
                selectedTypes.push(requestData.recordType)
            }
            // 하위,특정 레코드의 Object Type
            if( !$A.util.isEmpty(requestData.receiverType)){
                selectedTypes.push(requestData.receiverType);
            }
            // 상위 레코드의 Object Type
            if( !$A.util.isEmpty(requestData.referenceFieldType)){
                selectedTypes.push(requestData.referenceFieldType);
            }

            // 전체 Object 목록 중 사용할수 있는 Object 추출
            requestData.templateSettings.forEach(templateSetting => {
                templateSetting.templateOption.availableSObjectTypes = templateSetting.templateOption.wholeSObjectTypes.filter(sObjectTypeOption => {
                    return selectedTypes.includes(sObjectTypeOption.value);
                });

                templateSetting.availableSObjectFields = [];
            });
        }
        return requestData;
    },
    /**
     * @description 제목,본문,파일 관련정보 초기화
     */
    fn_contentInitialize : function(requestData){
        if( requestData != null ){
            requestData.title   = null;
            requestData.content = null;
            requestData.files   = [];
        }
        return requestData;
    },
    /**
     * @description Preview 이벤트
     */
    fn_firePreviewEvent : function(component,event,helper){
        let requestData     = component.get('v.requestData');
        let previewEvent    = component.getEvent('previewEvent');

        let eventFiles = helper.gfn_makeArray(requestData.files).map(function(fileWrapper){
            return {
                fileName        : fileWrapper.fileName,
                versionData     : fileWrapper.blobData,
                fileExtension   : fileWrapper.fileName != null ? fileWrapper.fileName.substring(fileWrapper.fileName.lastIndexOf('.') + 1) : null
            };
        });

        // Event Params
        let previewReferenceData = {
            template    : {
                Channel__c  : requestData.channel,
                Title__c    : requestData.title,
                Content__c  : requestData.content
            },
            files       : eventFiles,
        };

        previewEvent.setParams({
            templateId              : requestData.templateId,
            previewReferenceData    : previewReferenceData
        });
        previewEvent.fire();
    },
});