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
            component.set('v.deliveryRecord', resData.delivery);
            component.set('v.order', resData.order);
            component.set('v.orderKeep', resData.orderKeep);
            component.set('v.transferOrder', resData.transferOrder);
            component.set('v.isProcess', resData.isProcess);
            component.set('v.validMessage', resData.validMessage);
            component.set('v.notiTargetOrders', resData.notiTargetOrders);
            component.set('v.isCustomNoti', resData.isCustomNoti);

    	}).catch(function ({error, response}) {
    		helper.gfn_ApexErrorHandle(error, response);
    	});
    },

    /**
     * 전수배 출하
     * @param component
     * @param event
     * @param helper
     */
    doTransSave: function (component, event, helper) {
        helper.apex(
            component, 'doSave', 'set0038In', {
                'order': component.get('v.order'),
                'transferOrder' : component.get('v.transferOrder')
            }
        ).then(({resData, response}) => {
            component.set('v.order', resData.order);
            if(resData.isSuccess === false) {
                throw resData.message;
            } else {
                return helper.apex(
                    component, 'doSave', 'set0038Out', {'order': component.get('v.order')}
                );
            }
        }).catch(function (error) {
            helper.gfn_toast(error, 'e');
        }).then(({resData, response}) => {
            component.set('v.order', resData.order);
            if(resData.isSuccess === false) {
                throw resData.message;
            } else {
                helper.gfn_toast('전수배 출하 지시가 정상적으로 처리되었습니다.', 's');
                helper.gfn_closeQuickActionModal(component);
                helper.gfn_refresh();
            }
        }).catch((error) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    /**
     * 출하지시
     * @param component
     * @param event
     * @param helper
     */
    doSave: function (component, event, helper) {
        helper.apex(
            component, 'doSave', 'set0038OutNormal', {
                'order': component.get('v.order'),
                'notiTargetOrders' : component.get('v.notiTargetOrders')
            }
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

    /**
     * 출하지시
     * @param component
     * @param event
     * @param helper
     */
    doKeepSave: function (component, event, helper) {
        helper.apex(
            component, 'doKeepSave', 'set0038KeepOut', {'order': component.get('v.order'), 'orderKeep' : component.get('v.orderKeep')}
        ).then(({resData, response}) => {
            if(resData.isSuccess === false) {
                helper.gfn_toast(resData.message, 'e');
            } else {
                helper.gfn_toast('출고 지시가 정상적으로 처리되었습니다.', 's');
                helper.gfn_refresh();
                helper.gfn_closeQuickActionModal(component);
            }
        }).catch((error) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },


});