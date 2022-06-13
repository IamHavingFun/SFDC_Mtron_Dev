/****************************************************************************************
 * @filename       : i2SEMA_BaseHelper.js
 * @projectname    : i2sema
 * @author         : i2max_byeon.jw
 * @date           : 2020-04-07 오전 11:24
 * @group          :
 * @group-content  :
 * @description    :
 * @copyright      : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                author              description
 * ===============================================================
 0.1     2020-04-07 오전 11:24     i2max_byeon.jw       Create
 ****************************************************************************************/
({
    /**
     * @description 컴포넌트 초기정보 조회
     * @return {Promise} 호출부 Chain 을 위해 Promise 반환
     */
    gfn_baseInitialize : function(component,sobjectTypes){
        let self = this;
        /* 초기거래 정상 처리여부 Promise 반환 */
        return new Promise($A.getCallback(function(resolve,reject){
            /* 초기정보 거래 시작 */
            self.apex(component
                ,'gfn_baseInitialize'
                ,'getComponentBaseData'
                , { typeStrings : self.gfn_makeArray(sobjectTypes)}
            )
                .then((returnData,response) => {
                    component.set('v.config',returnData.data.config);
                    component.set('v.objectType',returnData.data.objectType);

                    self.gfn_log(component,'gfn_baseInitialize',returnData);
                    resolve(returnData,response);  // 호출부 Resolve 처리
                })
                .catch((error,response) => {
                    self.gfn_ApexErrorHandle(error, response);
                    reject(error,response);   // 호출부 Reject 처리
                });
             /* 초기정보 거래 종료 */
        }));
    },
    /**
     * @description 공통 로그처리 Override
     *  - Custom Setting 설정정보 참조
     */
    gfn_log : function(component, functionName, contents ){
        const config = component.get('v.config');

        if( config != null && config.Notiforce__ClientSideLog__c ){
            console.group('%c' + component.getName(), 'color:green');
            console.group('%cfunction : ' + functionName, 'color:blue');
            if( $A.util.isEmpty(contents)){
                console.log(contents);
            }else{
                console.log(JSON.parse(JSON.stringify(contents)));
            }
            console.groupEnd();
            console.groupEnd();
        }
    },
    /**
     * Server Apex Call
     * @param component
     * @param actionName
     * @param method
     * @param params
     * @param localSpinner
     * @param isNotWorkSpinner
     * @returns {Promise}
     */
    apex: function(component, actionName, method, params, localSpinner, isNotWorkSpinner) {
        const self = this;
        //-------------------------------------------------------------
        // $A.getCallback 처리를 하여 속도 개선 : 중요
        //-------------------------------------------------------------

        return new Promise($A.getCallback(function (resolve, reject) {

            self.gfn_log(component, actionName + ' -> ' + method +'(server)' , {'params': params});

            const action = component.get("c." + method);

            if($A.util.isEmpty(params) === false) {
                action.setParams(params);
            }

            // 일단 임시로 세팅
            //action.setBackground();

            //-------------------------------------------------------------
            // Apex Server Call
            //-------------------------------------------------------------
            action.setCallback(self, (response) => {

                if($A.util.isEmpty(isNotWorkSpinner) || !isNotWorkSpinner) {
                    self.gfn_hideSpinner(component, localSpinner);
                }

                const state = response.getState();

                if (state === "SUCCESS") {
                    let resData = response.getReturnValue();
                    self.gfn_log(component, method + '(server) -> ' + actionName , {'resData': resData});
                    resolve(resData, response);
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    const errors = response.getError();

                    console.error(errors);

                    if (    ($A.util.isEmpty(errors) === false)
                        &&  ($A.util.isEmpty(errors[0]) === false)  ) {

                        let errorMessage;

                        //-------------------------------------------------------------
                        // 에러처리는 기본적으로 errors의 0 index만 노출
                        //-------------------------------------------------------------

                        //----------------------------------------------------
                        // basic error
                        //----------------------------------------------------
                        if ($A.util.isEmpty(errors[0].message) === false){
                            errorMessage = errors[0].message;
                        }
                            //----------------------------------------------------
                            // page error
                        //----------------------------------------------------
                        else if ($A.util.isEmpty(errors[0].pageErrors[0]) === false){
                            errorMessage = errors[0].pageErrors[0].message;
                        }
                            //----------------------------------------------------
                            // field error
                        //----------------------------------------------------
                        else if ($A.util.isEmpty(errors[0].fieldErrors) === false){
                            for(let fieldError in errors[0].fieldErrors) {
                                let thisFieldError = errors[0].fieldErrors[fieldError];
                                errorMessage = thisFieldError[0].message;
                            }
                        }
                        //----------------------------------------------------
                        // duplication error
                        //----------------------------------------------------

                        //----------------------------------------------------
                        // 공통 처리
                        //----------------------------------------------------
                        self.gfn_log(component, method + '(server) -> '+actionName , {'error' : errorMessage});
                        reject(errorMessage, response);
                    }
                    else{
                        console.error("Unknown error");
                        reject("Unknown error", response);
                    }
                }
            });

            if($A.util.isEmpty(isNotWorkSpinner) || !isNotWorkSpinner) {
                self.gfn_showSpinner(component, localSpinner);
            }

            $A.enqueueAction(action);
        }));
    },

    /**
     * spinner 보임
     * @param component
     * @param localSpinner
     */
    gfn_showSpinner : function(component, localSpinner){
        $A.util.isEmpty(localSpinner) && component.set('v.isSpinner', true);
    },

    /**
     * spinner 숨김
     * @param component
     * @param localSpinner
     */
    gfn_hideSpinner : function(component, localSpinner){
        $A.util.isEmpty(localSpinner) && component.set('v.isSpinner', false);
    },

    /**
     * targetList 가 배열이 아닌 경우 배열로 변경하여 리턴
     * @param targetList
     */
    gfn_makeArray: function(targetList) {
        return ($A.util.isEmpty(targetList) === false) ? ($A.util.isArray(targetList) ? targetList : [targetList]) : [];
    },
    /**
     * 동적 컴포넌트 생성
     * @param component
     * @param componentName
     * @param param
     * @param cssClass
     */
    gfn_createComponent :  function(component, componentName, param, cssClass) {
        const self = this;
        let componentParam = $A.util.isEmpty(param) ? {} : param;
        let modalHeader, modalContent, modalFooter;
        $A.createComponents([
                [
                    "c:"+componentName
                    , componentParam
                ]
            ],
            (components, status, errorMessage) => {
                if (status === "SUCCESS") {
                    modalContent = components[0];
                    /*
                    * showCustomModal, showCustomPopover 은 promise 객체를 리턴한다.
                    */
                    const modalPromise = component.find('overlayLib').showCustomModal({
                        body: modalContent,
                        showCloseButton: true,
                        cssClass: cssClass,
                        closeCallback: function () {

                        }
                    }).then(function (overlay) {

                    });
                }
                else {
                    if (status === "INCOMPLETE") {
                        console.error("No response from server or client is offline.");
                    }
                    else if (status === "ERROR") {
                        console.log(JSON.stringify(errorMessage));
                        console.error("Error: " + errorMessage);
                    }
                }
            }
        );
    },
    /**
     * QuickAction 닫음 : Detail 의 버튼에서 생성되는 QuickAction을 닫음
     * 일반화면에서 생성되는 QuickAction 과는 분리되어야 함
     * (Com_QuickAction 컴포넌트에 닫기 Controller 별도 구현되어 있음)
     */
    gfn_closeQuickAction: function(){
        $A.get("e.force:closeQuickAction").fire();
    },

    gfn_closeQuickActionModal : function (component) {
        component.find("overlayLib").notifyClose();
    },

    /**
     * 공통 서버호출 에러 핸들러 : 기본적으로 toast
     * apex 호출시 Promise의 reject 핸들러가 구현이 안되었을 경우에 공통 에러
     * @param error
     * @param response
     */
    gfn_ApexErrorHandle : function(error) {
        //this.gfn_toast('System Error.', 'e');
        const self = this;
        self.gfn_toast(error, 'e');
    },
    gfn_toast : function(msg, type, mode){
        const toastEvent = $A.get("e.force:showToast");
        $A.get("e.force:showToast").setParams({
            "mode" : $A.util.isEmpty(mode) ? 'dismissible' : mode,
            "message": msg,
            "type": type === 's' ? 'success' : (type === 'w' ? 'warning' : 'error')
        }).fire();
    },

    /**
     * Detail Page 이동 : e.force:navigateToURL
     * 주로 아래의 gfn_naviService를 사용할 것
     * @param id
     * @param param
     */
    gfn_navigate : function(id, param){
        $A.get('e.force:navigateToURL').setParams({
            "url": (new RegExp('/s/').test(window.location.toString()) ? '/' + ($A.util.isEmpty(param) ? 'detail' : param) + '/' : '/') + id
        }).fire();
    },

    /**
     * navigation 이동 : lightning:navigation
     * pageReference 를 이용한 페이지 이동(주로 사용할 것)
     * 관련 사이트 : https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_navigation_page_definitions.htm
     * @param component
     * @param event
     * @param pageReference
     */
    gfn_naviService : function(component, event, pageReference) {
        event.preventDefault();
        component.find("naviService").navigate(pageReference);
    },

    /**
     * Browser tyep check
     */
    gfn_checkBrowser: function () {
        let browserType = navigator.sayswho = (function () {
            let ua = navigator.userAgent, tem,
                M = ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
            if (/trident/i.test(M[1])) {
                tem = /\brv[ :]+(\d+)/g.exec(ua) || [];
                return 'IE ' + (tem[1] || '');
            }
            if (M[1] === 'Chrome') {
                tem = ua.match(/\b(OPR|Edge)\/(\d+)/);
                if (tem != null) return tem.slice(1).join(' ').replace('OPR', 'Opera');
            }
            M = M[2] ? [M[1], M[2]] : [navigator.appName, navigator.appVersion, '-?'];
            if ((tem = ua.match(/version\/(\d+)/i)) != null) M.splice(1, 1, tem[1]);
            return M.join(' ');
        })();
        return browserType;
    },

    /**
     * IE 브라우저 여부
     * @returns {*}
     */
    gfn_isIEBrowser :function() {
        return this.gfn_checkBrowser().startsWith("IE");
    },
    gfn_refresh : function(){
        $A.get('e.force:refreshView').fire();
    },
    gfn_isValidURL : function(str) {
        var pattern = new RegExp('^(https?:\\/\\/)?'+ // protocol
        '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ // domain name
        '((\\d{1,3}\\.){3}\\d{1,3}))'+ // OR ip (v4) address
        '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ // port and path
        '(\\?[;&a-z\\d%_.~+=-]*)?'+ // query string
        '(\\#[-a-z\\d_]*)?$','i'); // fragment locator
        return !!pattern.test(str);
    },
});