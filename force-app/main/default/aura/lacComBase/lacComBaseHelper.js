({
    /* =============================================================================
    === 기본 Global 변수
    ============================================================================= */

    default_page_size : 20,     // 페이지의 기본 사이즈
    default_page_number : 1,    // 페이지의 기본 번호
    // ContentVersion의 Download Servlet Url
    contentVersion_servlet_downlaod : '/sfc/servlet.shepherd/version/download/',

    /* =============================================================================
    === Component and Biz
    ============================================================================= */

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
            action.setCallback(this, (response) => {

                if($A.util.isEmpty(isNotWorkSpinner) || !isNotWorkSpinner) {
                    self.gfn_hideSpinner(component, localSpinner);
                }

                const state = response.getState();

                if (state === "SUCCESS") {
                    let resData = response.getReturnValue();
                    self.gfn_log(component, method + '(server) -> ' + actionName , {'resData': resData});

                    /*
                     * ================================================================
                     * ES6 방식으로 처리하여 response가 필요할 경우 대비
                     * response 가 필요한 경우
                     *  function ({resData, response}) {
                            component.set('v.guideActionData', resData.guideActionData);
                        }
                     * resData만 필요한 경우
                     * function ({resData}) {
                            component.set('v.guideActionData', resData.guideActionData);
                       }
                     * ================================================================
                     */
                    //resolve(resData, response);
                    resolve({resData, response});
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    const errors = response.getError();
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
                        /*
                         * ================================================================
                         * reject 전달 파라미터 {} 처리 : ES6 버전식 처리
                         * ================================================================
                         */
                        reject({'error':errorMessage, 'response':response});
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
     * checkbox cmp list와 결과를 받을 list의 형태를 넘겨주면
     * checkbox cmp의 value값을 resultList에 중복값을 제거하여 return.
     *
     * @param targetList
     * @param resultList
     * @param isToastDefault
     * @returns {*[]}
     */
    gfn_getInputCheckedList: function(targetList) {
        //-------------------------------------------------------------------------------
        // 체크박스의 체크된 항목리스트를 구함
        //-------------------------------------------------------------------------------
        let _checkedList = this.gfn_makeArray(targetList)
            .filter(myCheck => myCheck.get('v.checked'))
            .map(myCheck => myCheck.get('v.value'));

        return _checkedList;
    },

    gfn_noInputCheckedMessage : function (checkedList) {
        //-------------------------------------------------------------------------------
        // 체크된 항목이 없다고 경고 메시지
        //-------------------------------------------------------------------------------
        ($A.util.isEmpty(checkedList)) && this.gfn_toast('No checked items found.', 'w');
    },

    gfn_createComponent :  function(component, componentName, param, cssClass, targetCmp=null, isShowCloseBtn=true) {
        const self = this;
        const componentParam = $A.util.isEmpty(param) ? {} : param;
        let modalHeader, modalContent, modalFooter;

        return new Promise((resolve, reject) => {
            $A.createComponents([
                [
                    "c:"+componentName
                    , componentParam
                ]
            ],
            $A.getCallback((components, status, errorMessage) => {
                    if (status === "SUCCESS") {
                        // QuickAction
                        if($A.util.isEmpty(targetCmp)) {
                            modalContent = components[0];
                            /*
                            * showCustomModal, showCustomPopover 은 promise 객체를 리턴한다.
                            */
                            const modalPromise = component.find('overlayLib').showCustomModal({
                                body: modalContent,
                                showCloseButton: isShowCloseBtn,
                                cssClass: cssClass,
                                closeCallback: function () {

                                }
                            }).then(function (overlay) {

                            });
                        }
                        // Component
                        else {
                            const currCmp = components[0];

                            // targetCmp.set('v.body', currCmp);
                            resolve({targetCmp, currCmp});
                        }
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
            ));
        });
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
     * 공통 에러처리
     * apex 호출외 callback 처리시 및 기본 js 에러 처리
     * @param error
     */
    gfn_ApexErrorHandle : function(error) {
        let errors = Array.isArray(error) || [error];
        let errorMessages = errors.filter(error => !!error).map(function(error) {
            // UI API read errors
            if (Array.isArray(error.body)) {
                return error.body.map(function(e) { return e.message; });
            }
            // UI API DML, Apex and network errors
            else if (error.body && typeof error.body.message === 'string') {
                return error.body.message;
            }
            // JS errors
            else if (typeof error.message === 'string') { return error.message; }
            // Unknown error shape so try HTTP status text
            return error.statusText || error;
        }).filter(function(message) { return  !!message; });

        let toastErrorMessage = errorMessages.join(', ');

        //============================================================================
        // log 처리와 toast 처리
        //============================================================================
        console.error(toastErrorMessage);
        this.gfn_toast(toastErrorMessage, 'e');
    },

    // =========================================================
    // 파라미터 설정
    // =========================================================
    gfn_param : function(component, pageSize, pageNumber, tableId){

        // table의 auraId 구함
        const tableAuraId = $A.util.isEmpty(tableId) ? 'table' : tableId;

        if(pageSize !== this.default_page_size){
            component.find(tableAuraId).set('v.pageSize', pageSize);
        }

        component.find('table').set('v.pageSize', pageSize);

        // 공통은 reqData로 요청데이터 작성
        const reqData = component.get('v.reqData');

        // table은 searchTerm 을 그대로 변수로 사용
        component.find(tableAuraId).set('v.searchTerm', reqData);

        return {
            'reqData' : JSON.stringify(reqData),
            'pageSize' : $A.util.isEmpty(pageSize) ? this.default_page_size : pageSize,
            'pageNumber' : $A.util.isEmpty(pageNumber) ? this.default_page_number : pageNumber
        };
    },

    // ==========================================================
    // 기본 tableFrame aura:id
    // ==========================================================
    defaultTableId : 'table',

    // ==========================================================
    // 검색 수행
    // ==========================================================
    gfn_search : function(component, pageSize, pageNumber, tableId, apexCallMethodName){
        const self = this;
        const _tableId = $A.util.isEmpty(tableId) ? this.defaultTableId : tableId;

        //console.log('component.find(defaultTableId).get(v.apexCallMethodName) : ', component.find(_tableId).get('v.apexCallMethodName'));

        const _apexCallMethodName = $A.util.isEmpty(apexCallMethodName) ? component.find(_tableId).get('v.apexCallMethodName') : apexCallMethodName;

        this.apex(
            component, 'gfn_search', _apexCallMethodName, self.gfn_param(component, pageSize, pageNumber, _tableId)
        ).then(function ({resData, response}) {
            // 전체 데이터 resData 세팅
            component.set("v.resData", resData);
            // lacComBase에 선언되어있는 recordList 활용
            component.set("v.recordList", resData.recordList);
            $A.util.isEmpty(resData.recordList) && self.gfn_toast(component.get('v.noDataFound'), 'w');
            // ===============================================
            // 페이징 처리를 위해서 이벤트를 호출한다
            // ===============================================
            self.gfn_callPageFrame(component, resData.recordList, resData.totalSize, _tableId);
        }).catch(function (error) {
            self.gfn_ApexErrorHandle(error);
        });
    },

    /**
     * Table 관련 리스트 데이터 및 페이징 처리
     * @param component
     * @param result
     * @param size
     */
    gfn_callPageFrame : function(component, result, size, tableId) {
        this.gfn_log(component, 'ComBase.callPageFrame' , {'설명' : 'table의 sortData 메소드 호출'});
        const tableAuraId = $A.util.isEmpty(tableId) ? this.defaultTableId : tableId;
        const table = component.find(tableAuraId);
        table.set('v.totalSize', $A.util.isEmpty(result) ? 0 : size);
        table.sortData(result);
    },

    /**
     * tableFrame의 pageNumber 등을 초기화한후 처리를 위한 promise
     * @param component
     * @param tableId
     * @returns {Promise}
     */
    gfn_pageFrameReset : function (component, tableId, apexCallMethodName) {
        const _tableId = $A.util.isEmpty(tableId) ? 'table' : tableId;
        const tableFrame = component.find(_tableId);
        tableFrame.reSet();
        if(!$A.util.isEmpty(apexCallMethodName)) {
            tableFrame.set('v.apexCallMethodName', apexCallMethodName);
        }

        console.log('tableFrame _tableId : ', _tableId);
        console.log('tableFrame apexCallMethodName : ', tableFrame.get('v.apexCallMethodName'));

        return new Promise($A.getCallback((resolve, reject) => {
            if(resolve) {
                //resolve(_tableId, tableFrame.get('v.apexCallMethodName'));
                resolve({tableId: _tableId, apexCallMethodName: tableFrame.get('v.apexCallMethodName')});
            }
            if(reject) {
                reject();
            }
        }));
    },

    /* =============================================================================
    === Message and toast
    ============================================================================= */

    gfn_toast : function(msg, type, mode){
        const toastEvent = $A.get("e.force:showToast");
        $A.get("e.force:showToast").setParams({
            "mode" : $A.util.isEmpty(mode) ? 'dismissible' : mode,
            "message": msg,
            "type": type === 's' ? 'success' : (type === 'w' ? 'warning' : 'error')
        }).fire();
    },

    /* =============================================================================
    // 각각의 localSpinner를 사용할 경우 show / hide
    // aura:id 를 localSpinner 로 설정할 것
    ============================================================================= */
    gfn_localSpinnerHide : function (component) {
        $A.util.addClass(component.find("localSpinner"), "slds-hide");
    },

    gfn_localSpinnerShow : function (component) {
        $A.util.removeClass(component.find("localSpinner"), "slds-hide");
    },

    /* =============================================================================
    // * Navigation
    // 여기는 다시 정리할 필요가 있음(아래 3개의 경우를 처리) -> 주로 3번으로 변경할 것
    // 1. newTab 으로 이동 : window.open
    // 2. Detail Page로 이동 : e.force:navigateToURL
    // 3. <lightning:navigation aura:id="navService"/> 을 이용한 이동
    ============================================================================= */

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
    // gfn_naviService : function(component, event, pageReference) {
    //     event.preventDefault();
    //     component.find("naviService").navigate(pageReference);
    // },

    /**
     * New Tab 으로 이동 : window.open
     * @param id
     * @param param
     * @param sobject
     */
    gfn_newTab : function(id, param, sobject){
        if(this.gfn_isCommunitySite() === true) {
            window.open(self.gfn_getSiteUrlFromWindowLocation()+'/s/' + ($A.util.isEmpty(param) ? 'detail' : param) + '/' + id, '_blank');
        }
            //-------------------------------------------------------------
            // 인터널인 경우
        //-------------------------------------------------------------
        else{
            const url = 'https://' + window.location.hostname + '/lightning/r/' + sobject + '/' + id + '/view';
            //console.log('url', url);
            window.open(url, '_blank');

            /*
                        const url = 'https://' + window.location.hostname + '/' + id;
                        window.open(url, '_blank');
            */
        }
    },

    /* =============================================================================
    === URL
    ============================================================================= */

    /**
     * /s/를 제외한 이전 full url 구함
     * @returns {string}
     */
    gfn_getSiteUrlFromWindowLocation : function() {
        const tlocation = window.location.toString();
        const url = tlocation.substr(0,tlocation.indexOf('/s/'));
        return url;
    },

    /**
     * 커뮤니티 사이트 여부
     * @returns {boolean}
     */
    gfn_isCommunitySite : function() {
        return new RegExp("/s/").test(window.location.toString());
     },

    /**
     * QuickAction에서 메인 페이지의 url을 재호출할 경우 사용
     */
    gfn_refresh : function(){
        $A.get('e.force:refreshView').fire();
    },

    /* =============================================================================
    === Util
    ============================================================================= */

    /**
     * 로그 유틸
     * @param component
     * @param functionName
     * @param log
     * @param display
     */
    gfn_log : function(component, functionName, log, display){
        const isShow = $A.util.isEmpty(display) ? true : display;

        if(isShow){
            console.group('%c======================= ' + component.getName(), 'color:green');
            console.group('%cfunction : ' + functionName, 'color:blue');

            console.info('%ctype', 'color:red', component.getType());

            for (let key in log) {
                console.info('%c'+key, 'color:red', log[key]);
            }

            console.groupEnd();
            console.groupEnd();
        }
    },

// =======================================================================================
// CSV 관련
// =======================================================================================

    /**
     * csv 파일의 데이터를 JSON 형태로 변환
     *
     * @param component
     * @param csv
     * @returns {string}
     */
    gfn_convertCSV2JSON: function (component, csv, lineNumber) {
        let keyLineNumber = $A.util.isEmpty(lineNumber) ? 1 : lineNumber;
        let arr = csv.split('\n');
        arr.pop();
        let jsonObj = [];
        let headers = arr[keyLineNumber].split(',');
        let data = [];
        let obj = {};

        for(let i=1+keyLineNumber,len=arr.length; i<len; i++) {
            data = arr[i].split(',');
            obj = {};
            for(let j=0, dlen=data.length; j<dlen; j++) {
                obj[headers[j].trim()] = data[j].trim();
            }
            jsonObj.push(obj);
        }

        return JSON.stringify(jsonObj);
    },


    // =============================================
    // CSV 다운로드
    // =============================================
    gfn_CsvDownload : function(component, fileName, headerArray, dataArray, localSpinner){
        let self = this;

        self.gfn_showSpinner(component, localSpinner);

        let csvContentArray = [];
        // ===========================================
        // 헤더 처리
        csvContentArray.push("");       // 한줄을 안주면 타이틀이 한칸 밀린다.
        csvContentArray.push(headerArray.join(","));

        dataArray.forEach(function(item, idx){
            csvContentArray.push(item.join(","));
        });

        let csvContent = csvContentArray.join("\r\n");

        // UNICODE 적용
        let BOM = '%EF%BB%BF';
        let uri = 'data:application/csv;charset=utf-8,'+BOM+','+encodeURIComponent(csvContent);

        if (navigator.msSaveBlob) { // IE 10+
            let blob = new Blob([csvContent],{type: "text/csv;charset=utf-8;"});
            navigator.msSaveBlob(blob, fileName);
        }else{
            let link = document.createElement("a");
            link.setAttribute('download',fileName+'.csv');
            link.href = uri;
            link.style = "visibility:hidden";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        self.gfn_log(component, 'ComBase.util_CsvDownload', {
            'Brower' : navigator.msSaveBlob ? 'IE 10+' : 'Not IE',
            'FileName' : fileName,
            'uri' : uri,
        });

        self.gfn_hideSpinner(component, localSpinner);
    },


// =======================================================================================
// 날짜 관련
// =======================================================================================

    // ================================
    // 날짜를 YYYY-MM-DD 형태로 반환
    // ================================
    gfn_date : function(days){
        const self = this;
        if($A.util.isEmpty(days)){
            return $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        }else{
            let dt = self.gfn_makeTwo(days);
            return $A.localizationService.formatDate(new Date(), "YYYY-MM") + '-' + dt;
        }
    },

    // ================================
    // 1일 날짜를 YYYY-MM-DD 형태로 반환
    // ================================
    gfn_startDate : function(){
        const util_startDate = $A.localizationService.formatDate(new Date(), "YYYY-MM")+'-01';
        return util_startDate;
    },

    // ================================
    // 말일 날짜를 YYYY-MM-DD 형태로 반환
    // ================================
    gfn_endDate : function(){
        let today = new Date();
        let lastDayOfMonth = new Date(today.getFullYear(), today.getMonth()+1, 0);
        let util_endDate = $A.localizationService.formatDate(lastDayOfMonth, "YYYY-MM-DD");
        return util_startDate;
    },

    // ==========================================
    // 한 자리 숫자를 두 자리로 변환한 String으로 리턴
    // ==========================================
    gfn_makeTwo : function(num){
        if(num.isInteger){
            return num < 10 ? '0'+num : num.toString();
        }else{
            return num.length < 1 ? '0'+num : num;
        }
    },

    // ===================================================================
    // String으로 넘어온 Datetime을 Long 타입으로 변환하여 리턴
    // Salesforce내에서 long.valueOf()로 변환해서 사용 할 수 있게 한다
    // "2018-12-18T10:00:00+09:00" -> Tue Dec 18 2018 10:00:00 GMT+0900 (한국 표준시) -> 1545094800000
    // ===================================================================
    gfn_StrToDateTime : function(dateTimeStr) {
        const dateTime = $A.util.isEmpty(dateTimeStr) ? new Date() : new Date(dateTimeStr);
        return dateTime.getTime();
    },

    /**
     * window.location의 queryString을 map으로 변환
     * @returns {URLSearchParams}
     */
    gfn_getQueryStringMap : function () {
        return (new URL(window.location)).searchParams;
    },

    /**
     * QueryString에서 원하는 key의 값을 구함
     * @param key
     * @returns {string}
     */
    gfn_getQueryStringValue : function (key) {
        return this.gfn_getQueryStringMap().get(key);
    },

    //-------------------------------------------------------------
    // Browser
    //-------------------------------------------------------------

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

    /**
     * console.log 대용
     * 전체적으로 운영에서 console log를 제어하기 위한 wrapper function
     * using : helper.log(component, ...args);
     *       : helper.log(component, 'hello', object);
     * @param component
     */
    log: function (component) {
        if(component.get('v.isLogging')) {
            const realArgs = Array.from(arguments).slice(1);
            console.log(...realArgs);
        }
    }

})