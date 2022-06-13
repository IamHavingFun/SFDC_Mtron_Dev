/****************************************************************************************
 * @filename       : i2SEMA_ManualSendFormController.js
 * @projectname    : i2SEMA Core
 * @author         : i2max_byeon.jw
 * @date           : 2020-04-09 오후 1:11
 * @group          :
 * @group-content  :
 * @description    :
 * @copyright      : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                author              description
 * ===============================================================
 0.1     2020-04-09 오후 1:11     i2max_byeon.jw       Create
 ****************************************************************************************/
({
    /**
     * @description 컴포넌트 초기화
     */
    doInit : function(component,event,helper){
        // Base Initialize
        helper.gfn_baseInitialize(component,['Notification__c'])
            .then((returnData,response) => {
                // Component Initialize
                helper.apex(component
                    ,'doInit'
                    ,'initialize'
                    ,{ recordId : component.get('v.recordId' )}
                )
                    .then((returnData,response) => {
                        const data = returnData.data;

                        component.set('v.referenceData',data.refData);
                        component.set('v.requestData',data.reqData);
                    })
                    .catch((error,response) => {
                        helper.gfn_ApexErrorHandle(error, response);
                    })
            })
            .catch((error,response) => {
                helper.gfn_ApexErrorHandle(error, response);
            });
    },
    /**
     * @description 채널변경
     *  - Preview 이벤트
     */
    changeChannelHandle : function(component,event,helper){
        helper.fn_firePreviewEvent(component,event,helper);
    },
    /**
     * @description Type 입력
     */
    changeType: function (component, event, helper) {
        let type = component.find("Type__c").get("v.value");
        let content = component.get('v.requestData.content');
        let ars080 = component.get('v.requestData.arsPhone');
        helper.gfn_log(component,'changeType',type);
        helper.gfn_log(component,'changeType',content);
        helper.gfn_log(component,'changeType',ars080);

        if(type === '1' && $A.util.isEmpty(ars080)){
            helper.gfn_toast($A.get('$Label.c.i2SEMA_MSG_NOT_EXIST_ARS080'), 'Error');
            return;
        }

        let ars080_text = '\n'+$A.get('$Label.c.i2SEMA_LAB_ARS080_FREE') +' '+ ars080;
        if($A.util.isEmpty(content)) content = '';
        //080 번호 표시
        if(type === '1' && !content.includes(ars080_text)) {
            content = content + ars080_text;
        } else {
            content = content.replace(ars080_text,'');
        }

        //한글 바이트 변환
        let korea = /[가-힣]/;
        let contentLength = content.split(korea).join('aa').length;
        component.set('v.requestData.type', type);
        component.set('v.requestData.content', content);

        //무료수신거부 : 080******** 정보 밑에 추가 처리?
        helper.fn_firePreviewEvent(component,event,helper);     // Preview
    },
    /**
     * @description 수신자 변경
     */
    changeReceiverOptionHandle : function(component,event,helper){
        let requestData = component.get('v.requestData');
        const receiverOption = requestData.receiverOption;

        requestData = helper.fn_receiverInitialize(requestData);        // 수신자 관련정보 초기화
        requestData = helper.fn_templateSettingInitialize(requestData); // 템플릿 설정정보 초기화

        requestData.receiverOption = receiverOption;
        component.set('v.requestData',requestData);
    },
    /**
     * @description (하위,특정) 수신자 SObject 타입 변경
     */
    changeReceiverTypeHandle : function(component,event,helper){
        let requestData = component.get('v.requestData');
        const receiverOption    = requestData.receiverOption;
        const receiverType      = requestData.receiverType;

        requestData = helper.fn_receiverInitialize(requestData);        // 수신자 관련정보 초기화

        requestData.receiverOption  = receiverOption;
        requestData.receiverType    = receiverType;

        requestData = helper.fn_templateSettingInitialize(requestData); // 템플릿 설정정보 초기화

        component.set('v.requestData',requestData);

        // 하위 레코드 검색 컴포넌트 생성
        if( receiverOption === $A.get('$Label.c.i2SEMA_LAB_RELATED_RECORD') && !$A.util.isEmpty(receiverType)){
            $A.createComponent(
                'c:i2SEMA_ManualSendReceiverSearch'
                , {
                    requestData : {
                        recordId            : component.get('v.recordId'),
                        searchObjectType    : receiverType,
                        selectedIds         : []
                    }
                }, function(newCmp, status, errorMessage ){
                    if( status === 'SUCCESS' ){
                        let body = [newCmp];
                        component.set('v.body',body);
                        component.set('v.receiverDialogOpen',true);
                    }else{
                        // 예외처리
                    }
                })
        }
        // 특정 레코드 선택란 생성
        else if( receiverOption === $A.get('$Label.c.i2SEMA_LAB_SPECIFIC_RECORD') && !$A.util.isEmpty(receiverType)){
            requestData.specificReceivers.push({Id:null});
            component.set('v.requestData',requestData);
        }
    },
    /**
     * @description 관련 수신자 수정
     */
    editRelatedReceiver : function(component,event,helper){
        component.set('v.receiverDialogOpen',true);
    },
    /**
     * @description 수신자 조회 컴포넌트의 이벤트 처리
     */
    HandleReceiverEvent : function(component,event,helper){
        let selectedIds = event.getParam('selectedIds');

        let requestData = component.get('v.requestData');
        requestData.receiverIds = selectedIds;

        component.set('v.requestData',requestData);
        component.set('v.receiverDialogOpen',false);
    },
    /**
     * @description 수신자 추가
     */
    addReceiver : function(component,event,helper){
        let requestData = component.get('v.requestData');
        requestData.specificReceivers.push({Id:null});
        component.set('v.requestData',requestData);
    },
    /**
     * @description 수신자 제거
     */
    removeReceiver : function(component,event,helper){
        let removeIndex = event.currentTarget.id;
        let requestData = component.get('v.requestData');

        requestData.specificReceivers.splice(removeIndex,1);
        component.set('v.requestData',requestData);
    },
    /**
     * @description 참조필드 설정
     */
    changeReferenceFieldHandle : function(component,event,helper){
        let referenceData   = component.get('v.referenceData');
        let requestData     = component.get('v.requestData');

        let receiverOption  = requestData.receiverOption;
        let referenceField  = requestData.referenceField;

        requestData = helper.fn_receiverInitialize(requestData);        // 수신자 관련정보 초기화

        requestData.receiverOption      = receiverOption;
        requestData.referenceField      = referenceField;
        requestData.referenceFieldType  = referenceData.referenceFieldTypes[referenceField];

        requestData = helper.fn_templateSettingInitialize(requestData); // 템플릿 설정정보 초기화
        component.set('v.requestData',requestData);
    },
    /**
     * @description 템플릿 변경
     */
    changeTemplateHandle : function(component,event,helper){
        let requestData     = component.get('v.requestData');
        let templateValue   = Array.isArray(requestData.templateId) ? requestData.templateId.length > 0 ? requestData.templateId[0] : null : requestData.templateId;

        requestData = helper.fn_templateInitialize(requestData);

        requestData.templateId = templateValue;
        component.set('v.requestData',requestData);

        // Template 조회
        if( !$A.util.isEmpty(templateValue)){
            helper.apex(component
                ,'Template Change'
                ,'getTemplateData'
                ,{
                    refData : component.get('v.referenceData') ,
                    reqData : component.get('v.requestData')
                }
            )
                .then((returnData,response) => {
                    const data = returnData.data;

                    const server_referenceData  = data.referenceData;
                    const server_requestData    = data.requestData;

                    let component_referenceData = component.get('v.referenceData');
                    let component_requestData   = component.get('v.requestData');

                    component_referenceData.template        = server_referenceData.template;

                    component_requestData.channel           = server_requestData.channel;
                    component_requestData.title             = server_requestData.title;
                    component_requestData.content           = server_requestData.content;
                    component_requestData.type              = server_requestData.type;
                    component_requestData.arsPhone          = server_requestData.arsPhone;
                    component_requestData.templateSettings  = server_requestData.templateSettings;

                    component_requestData = helper.fn_templateSettingInitialize(component_requestData); // Template Label 초기화

                    component.set('v.referenceData',component_referenceData);
                    component.set('v.requestData',component_requestData);
                })
                .catch((error,response) => {
                    helper.gfn_ApexErrorHandle(error);
                });
        }

        helper.fn_firePreviewEvent(component,event,helper);
    },
    /**
     * @description Template SObject 타입 변경
     */
    changeTemplateObjectHandle : function(component,event,helper){
        let eventIndex  = event.currentTarget.id;
        let requestData = component.get('v.requestData');

        let templateSetting = requestData.templateSettings[eventIndex];
        let sObjectType = templateSetting.sObjectType;

        templateSetting.templateOption.availableSObjectFields = sObjectType != null ? templateSetting.templateOption.wholeSObjectFields[sObjectType] : [];

        component.set('v.requestData',requestData);
    },
    /**
     * @description 파일 변경
     */
    changeFileHandle : function(component,event,helper){
        const config    = component.get('v.config');
        let requestData = component.get('v.requestData');
        let inputFiles  = event.getSource().get("v.files");

        // Request Initialize
        requestData.files = [];

        if( inputFiles.length > 0){
            // Spinner ON
            Array.prototype.forEach.call(inputFiles,function(inputFile){
                /*-----------------------------------------------
                 * File Reader
                    - File Reader 의 CallBack 정의후
                    - readAsDataURL 함수를 통해 Callback 수행
                 -----------------------------------------------*/
                let fileReader = new FileReader();
                fileReader.onload = $A.getCallback(function(){
                    // Name
                    let inputFileName   = inputFile['name'];
                    // Contents
                    let fileContents    = fileReader.result;
                    let base64          = 'base64,';
                    let dataStart       = fileContents.indexOf(base64) + base64.length;
                    fileContents = fileContents.substring(dataStart);

                    // Limit
                    let countValid  = requestData.files.length < config.FileUploadCountLimit__c;
                    let sizeValid   = fileContents.length * 0.75  < config.FileUploadSizeLimit__c;

                    if( !countValid ){
                        helper.gfn_toast('You can\'t upload more than ' + config.FileUploadCountLimit__c + ' file.','e');
                        return;
                    }
                    if( !sizeValid ){
                        helper.gfn_toast('You can\'t upload more than ' + 'The file cannot be larger than ' + config.FileUploadSizeLimit__c + ' Bytes' + ' file.','e');
                        return;
                    }
                    // Component Property
                    if( countValid && sizeValid ){
                        let fileData = {
                            fileName    : inputFileName,
                            blobData    : fileContents
                        };
                        requestData.files.push(fileData);

                        component.set('v.requestData',requestData);
                        helper.fn_firePreviewEvent(component,event,helper);     // Preview
                    }
                });
                fileReader.readAsDataURL(inputFile);    // fileReader Callback 수행
            });
        }
        else{
            component.set('v.requestData',requestData);
            helper.fn_firePreviewEvent(component,event,helper);     // Preview
        }
    },
    /**
     * @description 파일 삭제
     */
    removeFileHandle : function(component,event,helper){
        let requestData = component.get('v.requestData');
        requestData.files = [];

        component.set('v.requestData',requestData);
        helper.fn_firePreviewEvent(component,event,helper);     // Preview
    },
    /**
     * @description 메세지 발송
     *  : Quick Action 등 외부 컴포넌트에서 Aura:Method 호출시, 후속처리를 위해 Promise 반환
     */
    doSave : function(component,event,helper){

        let isAllValid = component.find('field').reduce(function(isValidSoFar, inputCmp){
            //display the error messages
            inputCmp.reportValidity();
            //check if the validity condition are met or not.
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        helper.gfn_log(component,'doSave isAllValid',isAllValid);

        if(isAllValid) {
            helper.apex(component
                ,'doSave'
                ,'saveRequest'
                ,{
                    reqData : component.get('v.requestData')
                })
                .then((returnData,response) => {
                    helper.gfn_toast('Successfully requested','s');
                    helper.gfn_refresh();
                    $A.get('e.force:closeQuickAction').fire();
                })
                .catch((error,response) => {
                    helper.gfn_ApexErrorHandle(error);
                });
        }

    },
    /**
     * @description 미리보기 이벤트
     */
    firePreviewEvent : function(component,event,helper){
        helper.fn_firePreviewEvent(component,event,helper);
    }
});