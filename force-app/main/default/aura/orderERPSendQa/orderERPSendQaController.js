/****************************************************************************************
 * @filename      : orderERPSendQa.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-04-14 오전 10:15
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
 0.1     2020-04-14 오전 10:15    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * init.
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {'recordId':component.get('v.recordId')}
        ).then(function ({resData, response}) {
            component.set('v.order', resData.order);
            component.set('v.defaultVSTEL', resData.defaultVSTEL);
            component.set('v.isOrderSend', resData.isOrderSend);
            component.set('v.isTransferOrder', resData.isTransferOrder);
            component.set('v.validMessage', resData.validMessage);

            // component.find("VSTEL").set('v.value', resData.defaultVSTEL);
        }).catch(function (error) {
            helper.gfn_ApexErrorHandle(error);
        });
    },
    handleLoad: function(component, event, helper) {
        component.find("VSTEL").set("v.value", component.get('v.defaultVSTEL'));
    },
    handleSubmit: function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');
        var vstel = component.find("VSTEL").get('v.value');
        var deliveryComment = component.find("DeliveryComment").get('v.value');
        if($A.util.isEmpty(vstel)) {
            helper.gfn_toast('출하 위치를 선택 해주세요', 'e', '');
            return;
        }
        if($A.util.isEmpty(deliveryComment) === false && deliveryComment.length > 25) {
            helper.gfn_toast('출하전달사항은 25자 이내로 기입 해주세요', 'e', '');
            return;
        }
        const regExp = new RegExp("[&$^#@]");
        if($A.util.isEmpty(deliveryComment) === false && regExp.test(deliveryComment)) {
            helper.gfn_toast('출하 전달 사항은 특수문자를 입력할 수 없습니다.', 'w');
            return false;
        }

        component.find('OrderForm').submit(fields);
    },
    handleSuccess: function(component, event, helper) {
        /*var updatedRecord = JSON.parse(JSON.stringify(event.getParams()));
        console.log('onsuccess: ', updatedRecord.id);*/

        helper.fn_send(component, event, helper);

    },

    /**
     * 주문 ERP 전송
     *
     * @param component
     * @param event
     * @param helper
     */
    doSend : function (component, event, helper) {
        var vstel = component.find("VSTEL").get('v.value');
        var deliveryComment = component.find("DeliveryComment").get('v.value');
        if($A.util.isEmpty(vstel)) {
            helper.gfn_toast('출하 위치를 선택 해주세요', 'e', '');
            return;
        }

        if($A.util.isEmpty(deliveryComment) === false && deliveryComment.length > 10) {
            helper.gfn_toast('10자 이내로 기입 해주세요', 'e', '');
            return;
        }

        helper.fn_send(component, event, helper);
    },
});