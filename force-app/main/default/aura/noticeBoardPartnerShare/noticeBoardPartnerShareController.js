({
    /**
     * doBusinessOfficeSelectId 영업소(지역) 선택
     *
     * @param component
     * @param event
     * @param helper
     */
    doBusinessOfficeSelectId : function (component, event, helper) {
        const bid = event.currentTarget.dataset.bid;
        component.set('v.bId', bid);

        var myCheckList = component.find('myCheckAll');
            myCheckList = $A.util.isArray(myCheckList) === true ? myCheckList : [myCheckList];
            myCheckList.forEach(function(checkbox){
              checkbox.set('v.checked', false);
         });

        $A.enqueueAction(component.get('c.doDealerSearch'));
    },
    /**
     * doDealerSearch 영업소(지역) 선택 기준으로 대리점 검색
     *
     * @param component
     * @param event
     * @param helper
     */
    doDealerSearch: function (component, event, helper) {
        helper.apex(
            component, 'getSearch', 'getSearch', {
                 'bId': component.get('v.bId'),
                 'resData': component.get('v.resShareData')
             }
        ).then(function ({resData, response}) {
            component.set('v.dealerList', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    /**
     * doInit 초기호출
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {}
        ).then(function ({resData, response}) {
            component.set('v.businessOfficeList', resData.businessOfficeList);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
        $A.enqueueAction(component.get('c.doGetShareSettingItems'));
    },
    /**
     * doGetShareSettingItems 공개 범위 데이터 조회
     *
     * @param component
     * @param event
     * @param helper
     */
    doGetShareSettingItems: function (component, event, helper) {
        helper.apex(
            component, 'getShareSettingItems', 'getShareSettingItems', {
                'recordId': component.get('v.recordId'),
                'sObjectName': component.get('v.sObjectName')
            }
        ).then(function ({resData, response}) {
            component.set('v.resShareData', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    /**
     * doCheck 대리점 체크
     *
     * @param component
     * @param event
     * @param helper
     */
    doCheck : function(component, event, helper){
       const dealer = event.getSource().get("v.value");
       const dealerChecked = event.getSource().get("v.checked");
       var resShareData = component.get('v.resShareData');

       if(dealerChecked == true){
           resShareData.ShareSetting_List.push({'DealerApex__c':dealer.Name,'BusinessOfficeApex__c':dealer.BusinessOffice__r.Name,'Account__c':dealer.Id});
       }else{
           for (var i = 0; i < resShareData.ShareSetting_List.length; i++) {
              if(resShareData.ShareSetting_List[i].Account__c == dealer.Id) resShareData.ShareSetting_List.splice(i, 1);
          }
       }
       component.set('v.resShareData',resShareData);
    },
    /**
     * doAllCheck 전체 대리점 체크
     *
     * @param component
     * @param event
     * @param helper
     */
    doAllCheck : function(component, event, helper){
       const AllChecked = event.getSource().get("v.checked");

        helper.apex(
            component, 'getAllCheckShareSettingItems', 'getAllCheckShareSettingItems', {
                'resData': component.get('v.resShareData'),
                'searchData': component.get('v.dealerList'),
                'AllCheck': AllChecked
            }
        ).then(function ({resData, response}) {
            component.set('v.resShareData', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });

        var myCheckList = component.find('myCheck');
            myCheckList = $A.util.isArray(myCheckList) === true ? myCheckList : [myCheckList];
            if (myCheckList.length != 1 && typeof(myCheckList[0]) != "undefined") {
                myCheckList.forEach(function (checkbox) {
                    checkbox.set('v.checked', AllChecked);
                });
            }
    },
    /**
     * doDelete 공개 범위 삭제
     *
     * @param component
     * @param event
     * @param helper
     */
    doDelete : function(component, event, helper){
         const dealerId = event.getSource().get("v.value");
         var resShareData = component.get('v.resShareData');
         var dealerList = component.get('v.dealerList');

         for (var i = 0; i < resShareData.ShareSetting_List.length; i++) {
            if(resShareData.ShareSetting_List[i].Account__c == dealerId) resShareData.ShareSetting_List.splice(i, 1);
         }

         for (var i = 0; i < dealerList.length; i++) {
            if(dealerList[i].dealerList.Id == dealerId) dealerList[i].dealerCheck  = false;
         }
         component.set('v.resShareData',resShareData);
         component.set('v.dealerList',dealerList);
    },
    /**
     * doCancel 닫기
     *
     * @param component
     * @param event
     * @param helper
     */
    doCancel : function (component, event, helper) {
        helper.gfn_closeQuickActionModal(component);
    },
    /**
     * doSetSave 저장
     *
     * @param component
     * @param event
     * @param helper
     */
    doSetSave : function (component, event, helper) {
        helper.apex(
            component, 'doSave', 'doSave', {
                'resData': component.get('v.resShareData'),
                'sObjectName': component.get('v.sObjectName'),
                'recordId': component.get('v.recordId')
            }
        ).then(function ({resData, response}) {
            helper.gfn_toast($A.get("{!$Label.c.quoteCustomLineEditorSuccessSaveMsg}"),'s');
            $A.get("e.force:refreshView").fire();
            $A.enqueueAction(component.get('c.doCancel'));
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    }
});