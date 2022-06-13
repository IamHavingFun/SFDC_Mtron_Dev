/****************************************************************************************
 * @filename      : lsMSalesLeaseInspectionReportCreate2Controller.js
 * @author        : I2MAX
 * @date          : 2021-03-29
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @release       : v1.0.0
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author         description
 * ===============================================================
 1.0     2021-03-29         I2MAX            Create
 ****************************************************************************************/
({
    // ============================================
    // 초기 액션
    // ============================================
    scriptsLoaded : function(component, event, helper) {
        const canvasSize = component.find('sizeCanvas').getElement();

        const plusWidth = 0; // 추가 Width
        const offsetWidth = (canvasSize.offsetWidth + plusWidth);
        const offsetHeight = canvasSize.offsetWidth / 3.5;

        // =========================
        // inspectorCanvas
        const inspectorCanvas = component.find('inspectorCanvas').getElement();
        inspectorCanvas.width = offsetWidth;
        inspectorCanvas.height = offsetHeight;
        let signatureInspectorPad = new SignaturePad(inspectorCanvas, {
            backgroundColor: 'rgba(255, 255, 255, 255)',
            penColor: 'rgb(0, 0, 0)',
            // 선의 굵기 option
            minWidth: 5,
            maxWidth: 7
        });
        component.set('v.inspectorPad', signatureInspectorPad);
    },

    doSave : function (component, event, helper) {
        const inspectorPad = component.get('v.inspectorPad');

        if(inspectorPad.isEmpty()){
            helper.gfn_toast('서명을 완료해 해주세요', 'w');
            return;
        } else {
            component.set('v.inspectorSign', inspectorPad.toDataURL());
        }

        helper.apex(
            component, 'doSave', 'save', {
                bizData: component.get('v.mobileStepVO.bizData'),
                inspectorSign: component.get('v.inspectorSign')
            }
        ).then(({resData}) => {
            component.set('v.mobileStepVO.bizData', resData);
            return helper.apex(
                component, 'doSave', 'savePDF', {leaseInspectionReportId: resData.leaseInspectionReport.Id}
            );
        }).then(({resData}) => {
            helper.gfn_toast('성공적으로 저장되었습니다.', 's');
            // helper.fn_close(component);
            $A.enqueueAction(component.get('c.doNext'));
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });
    }
});