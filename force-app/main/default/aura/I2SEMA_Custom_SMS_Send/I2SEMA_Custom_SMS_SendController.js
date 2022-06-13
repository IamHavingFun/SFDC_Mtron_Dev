/**
 * Created by MS on 2022-04-12.
 */

({
    /**
     * Init.
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.lacComService = component.find('lacComService');
        helper.apex(
            component, 'doInit', 'init', {}
        ).then(function ({resData, response}) {
            component.set('v.notification', resData.noti);
            component.set('v.targetCount', resData.targetCount);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * save.
     *
     * @param component
     * @param event
     * @param helper
     */
    doSend : function (component, event, helper) {
        const noti = component.get('v.notification');
        helper.apex(
            component, 'doSend', 'send', {
                'templateId':noti.NotificationTemplate__c
            }
        ).then($A.getCallback(function ({resData, response}) {
            component.set('v.notiGroupId', resData.Name);
            helper.gfn_toast('정상 발송 되었습니다.', 's');
        })).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * save.
     *
     * @param component
     * @param event
     * @param helper
     */
    doTestSend : function (component, event, helper) {
        const noti = component.get('v.notification');
        helper.apex(
            component, 'doTestSend', 'testSend', {
                'phoneNumber':component.get('v.phoneNumber'),
                'templateId':noti.NotificationTemplate__c
            }
        ).then($A.getCallback(function ({resData, response}) {
            component.set('v.notiGroupId', resData.Name);
            helper.gfn_toast('정상 발송 되었습니다.', 's');
        })).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

});