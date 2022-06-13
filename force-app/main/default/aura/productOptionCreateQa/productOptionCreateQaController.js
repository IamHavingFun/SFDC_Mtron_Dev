/****************************************************************************************
 * @filename      : productOptionCreateQaController.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-09-01 오전 10:44
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-09-01 오전 10:44      SEOKHO LEE          Create
 ****************************************************************************************/

({
    doInit : function (component, event, helper) {
        helper.apex(component,'doInit', 'init' ,
            {'recordId' : component.get('v.recordId')}
        ).then(function ({resData,response}) {
            component.set('v.initData', resData);
           if($A.util.isEmpty(resData.productFeaturesList)){
                helper.gfn_toast('작업기 유형이 존재하지 않습니다.','w'); return;
            }
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        })
    },

    doSave : function (component, event, helper) {
        const reqData = component.get('v.reqData');
        const product = component.get('v.initData').product;

        if($A.util.isEmpty(reqData.featureId)){
            helper.gfn_toast('작업기 유형을 선택 해 주세요', 'w'); return;
        }
        if($A.util.isEmpty(reqData.workingMachineId)){
            helper.gfn_toast('작업기를 선택 해 주세요', 'w'); return;
        }
        helper.apex(component, 'doSave', 'save', {
            'reqData': JSON.stringify(reqData),
            'product' : product
        }).then(function ({resData, response}) {
            helper.gfn_toast('정상적으로 저장되었습니다.','s');
            helper.gfn_closeQuickActionModal(component);
            helper.gfn_refresh();
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        })
    }
});