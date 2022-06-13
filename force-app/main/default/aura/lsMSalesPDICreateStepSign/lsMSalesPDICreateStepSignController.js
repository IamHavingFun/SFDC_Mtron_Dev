/**
 * Created by MS on 2020-06-24.
 */
/****************************************************************************************
  * @filename      : lsMSalesPDICreateStepSignController.js
  * @projectname   : LS_PS
  * @author        : MS
  * @date          : 2020-06-24 15 07
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-06-24 15 07       Park He         Create
****************************************************************************************/
({
    doInit : function(component, event, helper){
    },

    /**
     * PDI 등록 처리.
     * @param component
     * @param event
     * @param helper
     * @returns {boolean}
     */
    doCreatePdi : function(component, event, helper){
        const dealerPad = component.get('v.dealerPad');
        const customerPad = component.get('v.customerPad');
        if(dealerPad.isEmpty() || customerPad.isEmpty()){
            helper.gfn_toast('서명을 완료해 해주세요', 'w');
            return false;
        }else{
            component.set('v.dealerSign', dealerPad.toDataURL());
            component.set('v.customerSign', customerPad.toDataURL());
        }

        helper.apex(
            component, 'fnSendERPIF', 'savePDI', {
                'pdiData': component.get('v.mobileStepVO'),
                'dealerSignPng' : component.get('v.dealerSign'),
                'customerSignPng' : component.get('v.customerSign')
            }
        ).then(function ({resData, response}) {
            if(resData.bizData.pdi.IFStatus__c === 'Complete') {
                component.set('v.mobileStepVO',resData);
                helper.gfn_toast($A.get("{!$Label.c.lsMSalesPDICreateStepSign_SaveMsg}"),'s');
                $A.enqueueAction(component.get('c.doNext'));
            } else {
                helper.gfn_toast('[I/F 오류] '+ resData.bizData.pdi.IFMessage__c,'w');
            }
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
/*
    2021-08-23 : 원본 소스
    doCreatePdi : function(component, event, helper){
        const dealerPad = component.get('v.dealerPad');
        const customerPad = component.get('v.customerPad');
        if(dealerPad.isEmpty() || customerPad.isEmpty()){
            helper.gfn_toast('서명을 완료해 해주세요', 'w');
            return false;
        }else{
            component.set('v.dealerSign', dealerPad.toDataURL());
            component.set('v.customerSign', customerPad.toDataURL());
        }

        helper.apex(
            component, 'doCreatePdi', 'save', {
                'pdiData': component.get('v.mobileStepVO'),
                'dealerSignPng' : component.get('v.dealerSign'),
                'customerSignPng' : component.get('v.customerSign')
            }
        ).then(function ({resData, response}) {
            return helper.apex(
                component, 'fnPdiPDF', 'getPdiPDF', {
                    'pdiData': resData
                }
            );
        }).then(function ({resData, response}) {
            return helper.apex(
                component, 'fncallIF', 'callIF', {
                    'pdiData': resData
                }
            );
        }).then(function ({resData, response}) {
            component.set('v.mobileStepVO',resData);
            helper.gfn_toast($A.get("{!$Label.c.lsMSalesPDICreateStepSign_SaveMsg}"),'s');
            $A.enqueueAction(component.get('c.doNext'));
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
 */
    // ============================================
    // 초기 액션
    // ============================================
    scriptsLoaded : function(component, event, helper) {
        const canvasSize = component.find('sizeCanvas').getElement();

        const plusWidth = 0; // 추가 Width
        const offsetWidth = (canvasSize.offsetWidth + plusWidth);
        const offsetHeight = canvasSize.offsetWidth / 3.5;

        // =========================
        // dealerCanvas
        const dealerCanvas = component.find('dealerCanvas').getElement();
        dealerCanvas.width = offsetWidth;
        dealerCanvas.height = offsetHeight;
        let signatureDealerPad = new SignaturePad(dealerCanvas, {
            backgroundColor: 'rgba(255, 255, 255, 255)',
            penColor: 'rgb(0, 0, 0)'
        });
        component.set('v.dealerPad', signatureDealerPad);
        // =========================
        // Canvas2
        const customerCanvas = component.find('customerCanvas').getElement();
        customerCanvas.width = offsetWidth;
        customerCanvas.height = offsetHeight;
        let signatureCustomerPad = new SignaturePad(customerCanvas, {
            backgroundColor: 'rgba(255, 255, 255, 255)',
            penColor: 'rgb(0, 0, 0)'
        });
        component.set("v.customerPad", signatureCustomerPad);

        /*
        const customerCanvas = component.find('customerCanvas').getElement();
        let signatureCustomerPad = new SignaturePad(customerCanvas, {
            backgroundColor: 'rgba(255, 255, 255, 255)',
            penColor: 'rgb(0, 0, 0)'
        });
        component.set('v.customerPad', signatureCustomerPad);
        */
     },
     doPreSelf: function (component, event, helper) {
         component.find('lacComService').doNaviService({
             "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
             "attributes": {
                 "name": "lsMSalesContractRegister__c"
             },
             "state": {
                 "recordId": component.get("v.mobileStepVO.bizData.contract.Id")
             }
         });
    },
});