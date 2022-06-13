/**
 * Created by MS on 2021-07-26.
 */

({
    fn_send : function (component, event, helper) {
        const recordId = component.get('v.recordId');
        const isTransferOrder = component.get('v.isTransferOrder');

/*
        let order = component.get('v.order');
        order.VSTEL__c = component.find("VSTEL").get('v.value');
        order.DeliveryComment__c = component.find("DeliveryComment").get('v.value');
*/

        console.log('ffff');
        if(component.get('v.isSending') === true) return;
        component.set('v.isSending', true);
        this.apex(
            component, 'doSend', 'sendERPNew', {
                'recordId': recordId,
                'isTransferOrder': isTransferOrder,
            }
        ).then(function ({resData, response}) {
            component.set('v.isSending', false);
            if(resData.STATUS == 'Y') {
                helper.gfn_toast('ERP 주문 신청이 정상적으로 처리 되었습니다.','s');
/*                var btt = component.find('btnSend');
                btt.set('v.disabled',true);*/
                helper.gfn_closeQuickActionModal(component);
                helper.gfn_refresh();
            } else {
                helper.gfn_toast(resData.MESSAGE);
            }
        }).catch(function (error) {
            console.log(error);
            component.set('v.isSending', false);
            helper.gfn_toast('ERP 통신중 오류 발생, 잠시후에 다시 진행 해주세요.');
        });
/*
        this.apex(
            component, 'doSave', 'save', {
                'order': order,
            }
        ).then(function ({resData, response}) {
            return helper.apex(
                component, 'doSend', 'sendERPNew', {
                    'recordId': recordId,
                    'isTransferOrder': isTransferOrder,
                }
            );
        }).then(function ({resData, response}) {
            component.set('v.isSending', false);
            if(resData.STATUS == 'Y') {
                helper.gfn_toast('ERP 주문 신청이 정상적으로 처리 되었습니다.','s');
                var btt = component.find('btnSend');
                btt.set('v.disabled',true);
                helper.gfn_closeQuickActionModal(component);
                helper.gfn_refresh();
            } else {
                helper.gfn_toast(resData.MESSAGE);
            }
        }).catch(function (error) {
            console.log(error);
            component.set('v.isSending', false);
            helper.gfn_toast('ERP 통신중 오류 발생, 잠시후에 다시 진행 해주세요.');
        });
*/
    },
});