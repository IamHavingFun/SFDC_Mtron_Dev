/****************************************************************************************
 * @filename      : lsMSalesAddressSearchQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-30 오후 5:13
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author              description
 * ===============================================================
 0.1     2020-06-30 오후 5:13    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * doInit : 최초 호출
     **/
    doInit : function(component, event, helper) {
        component.set('v.isLastPage', true);
    },

    /**
     * doSearch : 주소 검색
     **/
    doSearch : function(component, event, helper) {
        component.set('v.pageNumber', 1);
        helper.getAddress(component, helper, component.get("v.pageSize").toString(), 1, component.find('address').get('v.value'));
    },

    /**
     * handleKeyUp : 입력 영역에 엔터키가 들어왔을 경우 주소 검색
     **/
    handleKeyUp : function(component, event, helper) {
        var isEnterKey = event.keyCode === 13;

        if (isEnterKey) {
            var action = component.get('c.doSearch');
            $A.enqueueAction(action);
        }
    },

    /**
     * navigate : 주소 검색 결과 페이징 처리
     **/
    navigate: function(component, event, helper) {
        //Check if the page is select or not, Default 1
        var pageNumber = component.get("v.pageNumber") || 1;
        // get the button's label
        var direction = event.getSource().get("v.label");
        // set the current page
        pageNumber = direction === "Prev" ? (pageNumber - 1) : (pageNumber + 1);

        component.set("v.pageNumber", pageNumber);

        helper.getAddress(component, helper, component.get("v.pageSize").toString(), component.get("v.pageNumber"), component.find('address').get('v.value'));
        // call the function
        //var search = component.get("c.doSearch");
        //$A.enqueueAction(search);
    },

    /**
     * doSelect : 주소를 선택한 경우
     **/
    doSelect : function(component, event, helper) {

        // dataset은 대문자없이 전부 소문자로 인식
        var postcode = event.currentTarget.dataset.postcode;
        var address = event.currentTarget.dataset.address;

        helper.gfn_log(component, 'doSelect', {
            'postcode' : postcode,
            'address' : address,
        });

        // 주소 결과 목록 창을 숨긴다 ======================================
        var addressList = component.find('addressList').getElement();
        addressList.className = 'slds-hide';

        // 주소 입력 창을 표시한다 =====================================
        var inputAddress = component.find('inputAddress').getElement();
        inputAddress.className = 'slds-show';

        // 값을 할당
        component.set("v.postcode", postcode);
        component.set("v.address1", address);
        component.set("v.isSearch", false);

        // 선택 버튼 표시
        component.set("v.showSaveButton", true);
    },


    /**
     * doSave : 주소 검색
     **/
    doSave : function(component, event, helper){
        const mobileStepVO = component.get('v.mobileStepVO');
        let account = mobileStepVO.bizData.quote.CustomerName__r
        const fullAdress = component.get('v.address1').split(' ');

        account.BillingPostalCode = component.get('v.postcode');

        /* 특별시 또는 광역시인 경우와 그 외 구분 */
        if(fullAdress[0].match(/특별시/) || fullAdress[0].match(/광역시/)){
            account.BillingState = fullAdress[0];  // 특별시/광역시/도
            account.BillingCity =  fullAdress[1];   // 군/구
            account.BillingStreet = component.get('v.address1').replace(fullAdress[0] + ' ' + fullAdress[1] + ' ', '');
            mobileStepVO.bizData.tempDetailAddress = ($A.util.isEmpty(component.get('v.address2')) ? '' : component.get('v.address2'));
        }else{
            account.BillingState  = fullAdress[0];
            account.BillingCity   = fullAdress[1];
            account.BillingStreet = component.get('v.address1').substr(fullAdress[0].length + fullAdress[1].length + 1);
            mobileStepVO.bizData.tempDetailAddress = ($A.util.isEmpty(component.get('v.address2')) ? '' : component.get('v.address2'));
        }

        component.set('v.mobileStepVO', mobileStepVO);

        $A.enqueueAction(component.get('c.doCancel'));
    },

    /**
     * doCancel : 취소 버튼을 누른 경우
     **/
    doCancel : function(component, event, helper) {
        helper.gfn_closeQuickActionModal(component);
    },
});