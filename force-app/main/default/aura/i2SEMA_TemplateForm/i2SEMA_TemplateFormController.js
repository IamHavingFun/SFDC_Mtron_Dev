/****************************************************************************************
 * @filename      : i2SEMA_TemplateFormController.js
 * @projectname   : i2SEMA Core
 * @author        : i2max_shlee
 * @date          : 2020/04/17 6:58 PM
 * @group         : e.g)tab name
 * @group-content : e.g)view file
 * @description   :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                author              description
 * ===============================================================
 0.1     2020/04/17 6:58 PM     i2max_shlee       Create
 ****************************************************************************************/
({
    /**
     * @description 컴포넌트 초기화
     */
    doInit : function(component,event,helper){
        let currentURL = window.location.toString();

        //Detail page confirm
        if(currentURL.includes('new')){
            component.set('v.isScreen', 'New');
            component.set('v.isDisable', false);
        } else if(currentURL.includes('view')){
            component.set('v.isScreen', 'Read');
            component.set('v.isDisable', true);
        } else {
            component.set('v.isScreen', 'Edit');
            component.set('v.isDisable', false);
        }

        // Base Initialize
        helper.gfn_baseInitialize(component,['NotificationTemplate__c'])
            .then((returnData) => {
                console.log(JSON.stringify(component.get('v.objectType')));
                // Component Initialize
                let recordId = component.get('v.recordId');
                let isScreen = component.get('v.isScreen');
                let isPopup = component.get('v.isPopup');

                helper.apex(
                    component,'doInit','initialize' ,{
                        recordId : recordId,
                        isScreen : isScreen,
                    }).then((returnData,response) => {
                    const data = returnData.data;
                    component.set('v.referenceData', data.referenceData);
                    helper.gfn_log(component,'doInit',data);
                    if(isScreen != 'New') {
                        helper.fn_firePreviewEvent(component,event,helper);     // Preview init
                    }
                }).catch((error,response) => {
                    helper.gfn_ApexErrorHandle(error, response);

                    //Edit Initialize 일경우 에러, 이전 화면으로 이동처리
                    if(isScreen == 'Edit') {
                        if(isPopup) {
                            $A.get("e.force:closeQuickAction").fire();
                        } else {
                            let navigateEvent = $A.get("e.force:navigateToURL");
                            navigateEvent.setParams({ "url": '/'+recordId });
                            navigateEvent.fire();
                        }
                    }

                })

            })
            .catch((error,response) => {
                helper.gfn_ApexErrorHandle(error, response);
            });

        //helper.gfn_log(component,'doInit',component.get('v.referenceData').files);
    },
    /**
     * @description Type 입력
     */
    changeType: function (component, event, helper) {
        let type = component.find("Type__c").get("v.value");
        let content = component.get('v.referenceData.template.Content__c');
        let ars080 = component.get('v.referenceData.template.Ars080Phone__c');
        helper.gfn_log(component,'changeType',type);
        helper.gfn_log(component,'changeType',content);
        helper.gfn_log(component,'changeType',ars080);

        if(type == '1' && $A.util.isEmpty(ars080)){
            helper.gfn_toast($A.get('$Label.c.i2SEMA_MSG_NOT_EXIST_ARS080'), 'Error');
            return;
        }

        let ars080_text = '\n'+$A.get('$Label.c.i2SEMA_LAB_ARS080_FREE') +' '+ ars080;
        if($A.util.isEmpty(content)) content = '';
//        console.log('content.includes(ars080_text) :'+content.includes(ars080_text));
        //080 번호 표시
        if(type == '1' && !content.includes(ars080_text)) {
            content = content + ars080_text;
        } else {
            content = content.replace(ars080_text,'');
        }

        //한글 바이트 변환
        let korea = /[가-힣]/;
        let contentLength = content.split(korea).join('aa').length;

        component.set('v.referenceData.template.Type__c', type);
        component.set('v.referenceData.template.Content__c', content);
        component.set('v.referenceData.template.ContentLength__c', contentLength);

        //무료수신거부 : 080******** 정보 밑에 추가 처리?
        helper.fn_firePreviewEvent(component,event,helper);     // Preview
    },
    /**
     * @description 무료수신거부 080번호 변경
     * TODO 080 번호 선택 가능시..발신 수신거부 번호 IF 및 선택가능...
     */
    changeArs080: function (component, event, helper) {

    },
    /**
     * @description 채널 입력
     */
    changeChannel: function (component, event, helper) {
        let referenceData = component.get('v.referenceData');
        let channel = component.find("channel").get("v.value");
        helper.gfn_log(component,'changeChannel',channel);

        component.set('v.referenceData.template.Channel__c', channel);
        helper.fn_firePreviewEvent(component,event,helper);     // Preview
    },
    /**
     * @description 카카오 친구톡 이미지 입력
     */
    changeKakaoImg: function (component, event, helper) {
        let kakaoImgId = component.get("v.referenceData.template.KakaoFriendTalkImage__c");
        if(kakaoImgId == undefined || kakaoImgId == '') return;

        helper.gfn_log(component,'changeKakaoImg',kakaoImgId);

        let referenceData = component.get('v.referenceData');

        helper.apex(
            component,'changeKakaoImg','getKakaoImgUrl' ,{
                kakaoImgId : kakaoImgId[0]
            }).then((returnData,response) => {
            const componentResponse = returnData;
            let friendTalkImage = returnData.data.friendTalkImage;
//            helper.gfn_log(component,'changeKakaoImg friendTalkImage',friendTalkImage);
            referenceData.template.KakaoImgUrl__c = friendTalkImage.ImageURL__c;
            component.set("v.referenceData", referenceData);
//            helper.gfn_log(component,'changeKakaoImg referenceData',component.get('v.referenceData'));
            helper.fn_firePreviewEvent(component,event,helper);     // Preview
        }).catch((error,response) => {
            helper.gfn_ApexErrorHandle(error, response);
        });

    },
    /**
     * @description contents 메세지 입력
     */
    contentInput: function(component, event, helper){
        const config = component.get('v.config');
        let channel = component.get('v.referenceData.template.Channel__c');
        let content = component.get('v.referenceData.template.Content__c');
        let type = component.find("Type__c").get("v.value");
        let ars080 = component.get('v.referenceData.template.Ars080Phone__c');

        helper.gfn_log(component,'contentInput channel',channel);
        if(channel == '' || channel == undefined) {
            component.set('v.referenceData.template.Content__c','');
            helper.gfn_toast($A.get("$Label.c.i2SEMA_NT_MSG_REQUIRED_TEMPLATE_CHANNEL"), 'e');
            return;
        }

        //개인화 라벨  길이 리밋 제외
        content= content.replace('%%LABEL1%%', '');
        content= content.replace('%%LABEL2%%', '');
        content= content.replace('%%LABEL3%%', '');
        content= content.replace('%%LABEL4%%', '');
        content= content.replace('%%LABEL5%%', '');
        //한글 바이트 변환
        let korea = /[가-힣]/;
        let contentLength = content.split(korea).join('aa').length;

        //메세지 초과 validation
        if(channel === '0' && contentLength > config.SMSTextLimit__c) {
            component.set('v.isExceededByteLimit', true);
        } else if((channel === '2' || channel === '3') && contentLength > config.MMSTextLimit__c ) {
            component.set('v.isExceededByteLimit', true);
        } else if((channel === '1008' || channel === '1009') && contentLength > config.KakaoFriendTalkTextLimit__c ) {
            component.set('v.isExceededByteLimit', true);
        } else {
            component.set('v.isExceededByteLimit', false);
        }
        component.set('v.referenceData.template.ContentLength__c', contentLength);

        helper.gfn_log(component,'contentInput contentLength',contentLength);
        helper.fn_firePreviewEvent(component,event,helper);     // Preview

    },
    /**
     * @description 개인화 라벨
     */
    addLabel: function(component, event, helper) {
        let channel = component.get('v.referenceData.template.Channel__c');
        let label = event.currentTarget.getAttribute('data-value');
        let personalField = '';

        if(label == 'LABEL1'){
            personalField = ' %%LABEL1%% ';
        }else if(label =='LABEL2'){
            personalField = ' %%LABEL2%% ';
        }else if(label =='LABEL3'){
            personalField = ' %%LABEL3%% ';
        }else if(label =='LABEL4'){
            personalField = ' %%LABEL4%% ';
        }else if(label =='LABEL5'){
            personalField = ' %%LABEL5%% ';
        }
        let content = component.get('v.referenceData.template.Content__c');
        if(content != undefined){
            content =  personalField + content;
        }else{
            content =  personalField;
        }
        component.set('v.referenceData.template.Content__c', content);
        let korea = /[가-힣]/;
        let contentLength = content.split(korea).join('aa').length;
        component.set('v.referenceData.template.ContentLength__c', contentLength);
        // component.find("content").focus();   // Aura:id='field' 를 의미??
        helper.fn_firePreviewEvent(component,event,helper);     // Preview
    },
    /**
     * @description MMS 파일 업로드
     */
    changeFile: function(component, event, helper) {
        const FILE_COUNT = 1;
        const BYTE_LIMIT = 102400;
        let referenceData = component.get('v.referenceData');
        let inputFiles  = event.getSource().get("v.files");
        // Request Initialize
        referenceData.files = [];
        if( inputFiles.length > 0){
            // Spinner ON
            helper.gfn_showSpinner(component);
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
                    let fileExtension   = inputFileName.slice(inputFileName.lastIndexOf(".") + 1).toLowerCase();
                    fileContents = fileContents.substring(dataStart);
                    // Limit
                    let countValid  = referenceData.files.length < FILE_COUNT;
                    let sizeValid   = fileContents.length * 0.75  < BYTE_LIMIT;
                    if( !countValid ){
//                        helper.g_event.toastError('Error','You can\'t upload more than ' + helper.g_const.LIMIT.FILE_UPLOAD.FILE_COUNT + ' file.');
                        helper.gfn_toast('You can\'t upload more than ' + FILE_COUNT + ' file.', 'Error');
                        helper.gfn_hideSpinner(component);
                        return;
                    }
                    if( !sizeValid ){
//                        helper.g_event.toastError('Error','The file cannot be larger than ' + helper.g_const.LIMIT.FILE_UPLOAD.BYTE_LIMIT + ' Bytes');
                        helper.gfn_toast('The file cannot be larger than ' + BYTE_LIMIT + ' Bytes', 'Error');
                        helper.gfn_hideSpinner(component);
                        return;
                    }
                    // Component Property
                    if( countValid && sizeValid ){
                        let contentVersionData = {
                            fileName    : inputFileName,
                            versionData    : fileContents,
                            fileExtension : fileExtension
                        }
                        referenceData.files.push(contentVersionData);
                        component.set('v.referenceData', referenceData);
                        helper.gfn_log(component,'changeFile',referenceData);
                        helper.fn_firePreviewEvent(component,event,helper);     // Preview
                        helper.gfn_hideSpinner(component);
                    }
                })
                fileReader.readAsDataURL(inputFile);    // fileReader Callback 수행
            });
        } else{
            component.set('v.contentVersionData', null);
            helper.fn_firePreviewEvent(component,event,helper);     // Preview
        }
    },
    /**
     * @description MMS 업로드 파일 삭제
     */
    removeFile : function(component,event,helper){
        let referenceData = component.get('v.referenceData');
        referenceData.files = [];
        component.set('v.referenceData', referenceData);
        helper.fn_firePreviewEvent(component,event,helper);     // Preview
    },
    /**
     * @description Active 활성화 필드 입력
     */
    doCheckBox: function (component, event, helper) {
        let chkBox = component.find('activeCheckBox');
        component.set('v.referenceData.template.IsActive__c', chkBox.get('v.checked'));
    },
    /**
     * @description 템플릿 저장
     */
    doSave: function (component, event, helper) {

        let channel = component.get('v.referenceData.template.Channel__c');
        let recordId = component.get('v.recordId');
        let referenceData = component.get('v.referenceData');
        if(component.find('btnLinkView') != undefined) {
            let kakaoBtnData = component.find('btnLinkView').get('v.referenceData');
            referenceData.kakaoButtons = kakaoBtnData.kakaoButtons;
        }

        helper.gfn_log(component,'doSave',referenceData);

        const config        = component.get('v.config');
        let isExceeded      = component.get('v.isExceededByteLimit');
        let contentLength   = component.get('v.referenceData.template.ContentLength__c');
        let limit = (channel === '0')? config.SMSTextLimit__c:(channel === '1008' || channel === '1009')?config.KakaoFriendTalkTextLimit__c:config.MMSTextLimit__c;
        //Validation 필수값 입력 확인

        if(isExceeded) {
            helper.gfn_toast($A.get("$Label.c.i2SEMA_NT_MSG_LIMIT")+' ('+ contentLength+ '/'+limit+')', 'e');
            return;
        }
        let isAllValid = component.find('field').reduce(function(isValidSoFar, inputCmp){
            //display the error messages
            inputCmp.reportValidity();
            helper.gfn_log(component,'doSave isValidSoFar',isValidSoFar);
            helper.gfn_log(component,'doSave inputCmp',inputCmp);
            //check if the validity condition are met or not.
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        helper.gfn_log(component,'doSave isAllValid',isAllValid);

        if(isAllValid) {
            helper.apex(
                component,'doSave','saveNotificationTemplate' ,{
                    recordId :recordId,
                    rData :referenceData,
                }).then((returnData,response) => {
                const data = returnData.data;
                component.set('v.recordId', data.referenceData.template.Id);
                helper.gfn_log(component,'doSave','returnData '+data.referenceData.template.Name);
                //저장 페이지 이동
                let recordId = component.get('v.recordId');
                let navigateEvent = $A.get("e.force:navigateToURL");
                navigateEvent.setParams({ "url": '/'+recordId });
                navigateEvent.fire();

            }).catch((error,response) => {
                helper.gfn_ApexErrorHandle(error, response);
            });
        }

    },
    /**
     * @description 취소 버튼 : 팝업 화면 닫기 혹은 이전 페이지 이동
     */
    doCancel: function (component, event, helper) {
        let recordId = component.get('v.recordId');
        let isScreen = component.get('v.isScreen');
        let isPopup = component.get('v.isPopup');
//        helper.gfn_log(component,'doCancel recordId',recordId);
//        helper.gfn_log(component,'doCancel isScreen',isScreen);
//        helper.gfn_log(component,'doCancel isPopup',isPopup);

        if(isScreen == 'New') {
            let navigateEvent = $A.get("e.force:navigateToURL");
            navigateEvent.setParams({ "url": '/lightning/o/NotificationTemplate__c/home' });
            navigateEvent.fire();
        } else { //Read, Edit
            let navigateEvent = $A.get("e.force:navigateToURL");
            navigateEvent.setParams({ "url": '/'+recordId });
            navigateEvent.fire();
        }
    },
    /**
     * @description 미리보기 이벤트
     */
    firePreviewEvent : function(component,event,helper){
        helper.fn_firePreviewEvent(component,event,helper);
    }
});