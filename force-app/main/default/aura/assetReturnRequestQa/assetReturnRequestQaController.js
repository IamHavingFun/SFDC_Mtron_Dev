/**
 * Created by MS on 2021-06-29.
 */

({
    doInit: function(component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {recordId : component.get('v.recordId')}
        ).then(({resData}) => {
            component.set('v.asset', resData.asset);
            component.set('v.assetReturn', resData.assetReturn);
            component.set('v.isTarget', resData.isTarget);
            component.set('v.isAssetReturns', resData.isAssetReturns);
            if(resData.isTarget === false) {
                helper.gfn_toast('본 자산의 자산유형이 판매자산이 아니거나, 이미 반환 신청이 진행중인 자산입니다.', 'w', '');
            }
        }).catch((error) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    doSave : function(component, event, helper){

        const returnType = component.get('v.assetReturn.ReturnType__c');
        const returnComment = component.get('v.assetReturn.ReturnComment__c');

        if($A.util.isEmpty(returnType)) {
            helper.gfn_toast('반환 유형을 선택해주세요.');
            return;
        }

        if(returnType === '품질 문제' && $A.util.isEmpty(returnComment)) {
            helper.gfn_toast('품질 문제인 경우는 주요 사유를 입력 해주세요.');
            return;
        }
console.log('ddddddddddddddddddddddddd');
        console.log(JSON.stringify(component.get('v.assetReturn')));
        console.log('ddddddddddddddddddddddddd');
        helper.apex(
            component, 'doSave', 'submitForApproval', {
                recordId : component.get('v.recordId'),
                asset : component.get('v.asset'),
                assetReturn : component.get('v.assetReturn')
            }
        ).then(({resData}) => {
            helper.gfn_toast('반환승인 요청이 처리 되었습니다.', 's');
            helper.gfn_refresh();
            helper.gfn_closeQuickAction();
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });

    },

    doStageChange : function(component, event, helper){

    },

});