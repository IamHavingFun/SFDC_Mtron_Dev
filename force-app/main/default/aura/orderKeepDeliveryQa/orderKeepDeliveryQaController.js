({
    /**
     * 초기 거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {'recordId':component.get('v.recordId')}
        ).then(function ({resData, response}) {
            component.set('v.orderKeep', resData.orderKeep);
            component.set('v.isProcess', resData.isProcess);
            component.set('v.validMessage', resData.validMessage);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 출하지시
     * @param component
     * @param event
     * @param helper
     */
    doKeepSave: function (component, event, helper) {
        console.log(JSON.stringify(component.get('v.orderKeep')));
        helper.apex(
            component, 'doKeepSave', 'set0038KeepOut', {'orderKeep' : component.get('v.orderKeep')}
        ).then(({resData, response}) => {
            if(resData.isSuccess === false) {
                helper.gfn_toast(resData.message, 'e');
            } else {
                helper.gfn_toast('출하 지시가 정상적으로 처리되었습니다.', 's');
                helper.gfn_closeQuickActionModal(component);
                helper.gfn_refresh();
            }
        }).catch((error) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },

});