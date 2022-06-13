/**
 * Created by MS on 2021-05-10.
 */

({
    doSendSms : function (component, event, helper) {
        const phoneNumber = component.get('v.phoneNumber');
        helper.apex(
            component, 'doSendSms', 'sendSms', {
                phoneNumber: phoneNumber
            }
        ).then(({resData}) => {
            component.set('v.authNumber', resData);
            if(resData === 'XXXX') {
                helper.gfn_toast('이미 등록된 휴대전화번호입니다.', 'w');
            } else {
                helper.gfn_toast('입력하신 휴대전화번호 ['+phoneNumber+']로 인증번호 4자리가 발송되었습니다. 상담 고객과 확인하시어 발송된 4자리 인증번호를 아래에 입력하신 뒤, [인증]을 진행 바랍니다.', 's');
            }
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    doAuth : function (component, event, helper) {
        const insertedAuthNumber = component.find('insertedAuthNumber').get('v.value');
        const phoneNumber = component.get('v.phoneNumber');
        if(insertedAuthNumber === component.get('v.authNumber')) {
            component.set('v.isAuthenticated', true);
            helper.gfn_toast('입력하신 휴대전화번호 ['+phoneNumber+']에 대해서 인증 완료 되었습니다.', 's');
            helper.gfn_closeQuickActionModal(component);
        } else {
            helper.gfn_toast('인증번호가 일치 하지 않습니다. 지속적으로 인증번호가 맞지 않으면 재 발송하여 진행 해주십시오.', 'e');
        }
    },

    doCancel : function (component, event, helper) {
        helper.gfn_closeQuickActionModal(component);
    }
});