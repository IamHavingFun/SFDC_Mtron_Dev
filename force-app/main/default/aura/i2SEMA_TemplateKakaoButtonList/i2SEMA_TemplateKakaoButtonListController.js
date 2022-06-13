/****************************************************************************************
  * @filename      : i2SEMA_TemplateKakaoButtonListController.js
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/24 1:51 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author              description
  * ===============================================================
    0.1     2020-04-16 오후 2:45     i2max_ys.seo        Create
    0.1     2020/04/24 1:51 PM      i2max_shlee         Modified
****************************************************************************************/
({
    //팝업 창 초기화
    doOpen: function (component, event, helper) {
        // Initialize
        let args = event.getParam('arguments'); // arguments is keyword, You cannot use the 'arguments' keyword. Component is not display if it's used.
        if (args != null && args.param != null) {
            let parameter = args.param;
            component.set('v.isOpen', true);
            component.set('v.recordId', parameter.recordId);
            component.set('v.referenceData', parameter.referenceData);

            // Base Initialize
            helper.gfn_baseInitialize(component,['KakaoTalkButton__c'])
                .then((returnData,response) => {
                    // Component Initialize
                })
                .catch((error,response) => {
                    helper.gfn_ApexErrorHandle(error, response);
                });
        }
    },
    /**
     * @description handleKakaoButton? 어디서 사용?
     */
//    handleKakaoButton : function(component,event,helper){
//        helper.gfn_log(component,'handleKakaoButton','Called handleKakaoButton');
//        var referenceData       = component.get('v.referenceData');
//        var kakaoButtonEvent    = component.getEvent('kakaoButtonEvent');
////        var referenceData = component.get('v.referenceData');
//        previewEvent.setParams({
//            referenceData : referenceData,
//        });
//        kakaoButtonEvent.fire();
//    },
    /**
     * @description 카카오 버튼 신규 입력 행 추가
     */
    doAddRow : function(component,event,helper){
        helper.gfn_log(component,'doAdd','Called doAdd');

        let recordId = component.get('v.recordId');
        let referenceData = component.get('v.referenceData');
        //신규
        if(referenceData == undefined){
            referenceData.kakaoButtons = {"kakaoButtons": []};
        }
        helper.gfn_log(component,'doAdd',referenceData.kakaoButtons);
        console.log(referenceData.kakaoButtons.length);
        if(referenceData.kakaoButtons.length >= 5) {
            helper.gfn_toast('카카오 버튼은 5개까지 생성이 가능합니다.','w');
            return;
        } else {
            referenceData.kakaoButtons.push({NotificationTemplates__c:recordId ,Button_Type__c : 'WL'});
        }

        component.set('v.referenceData', referenceData);
    },
    /**
    * @description 카카오 버튼 선택 행 삭제
    */
    doRemoveRow : function(component,event,helper){
//        let removeIndex = event.getSource().get("v.value");
        let removeIndex = event.getSource().get("v.title");

        let referenceData = component.get('v.referenceData');
        helper.gfn_log(component,'removeKakaoButton removeIndex',removeIndex);
        referenceData.kakaoButtons.splice(removeIndex,1);
        component.set('v.referenceData',referenceData);
    },
    /**
     * @description 카카오 수정 팝업 창 닫기 (초기화)
     */
    doCancel : function(component,event,helper){
        helper.gfn_log(component,'doCancel','Called doCancel');

        //Validation SOQL 저장값으로 초기화
        let recordId = component.get('v.recordId');
        helper.apex(
            component,'doCancel','initialize' ,{
            recordId : recordId,
        }).then((returnData,response) => {
            const data = returnData.data;
            helper.gfn_log(component,'doCancel data',data);
            let referenceData = component.get('v.referenceData');
            referenceData.kakaoButtons = data.requestData.kakaoButtons;
            component.set('v.referenceData', referenceData);

            component.set("v.isOpen", false); //팝업창 닫기
            helper.fn_firePreviewEvent(component,event,helper); //미리보기 갱신
        }).catch((error,response) => {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    /**
     * @description 카카오 수정내용 저장 팝업 창 닫기
     */
    doSave : function(component,event,helper){
        helper.gfn_log(component,'doSave','Called doSave');

        //Validation 필수값 입력 확인
        let isAllValid = component.find('field').reduce(function(isValidSoFar, inputCmp){
            //display the error messages
            inputCmp.reportValidity();
            helper.gfn_log(component,'doSave isValidSoFar',isValidSoFar);
            helper.gfn_log(component,'doSave inputCmp',inputCmp);
            //check if the validity condition are met or not.
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        helper.gfn_log(component,'doSave isAllValid',isAllValid);

        let referenceData = component.get('v.referenceData');
        component.set('v.referenceData', referenceData);
        helper.gfn_log(component,'doSave for',referenceData.kakaoButtons);
        if(isAllValid) {
            component.set("v.isOpen", false); //팝업창 닫기
            helper.fn_firePreviewEvent(component,event,helper); //미리보기 갱신
        }


    }
})