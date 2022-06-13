/****************************************************************************************
  * @filename      : lsMSalesEFormQaController.js
  * @projectname   : LS_PS
  * @author        : MS
  * @date          : 2020-07-02 14 15
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
    0.1     2020-07-02 14 15       Park He         Create
****************************************************************************************/
({
    //access token, refresh token, user email, contract data 가져오기
    doInit : function(component, event, helper){ //access token
        helper.apex(
            component, 'getServiceExecute', 'getServiceExecute', {
                'recordId' : component.get('v.recordId')
            }
        ).then(function ({resData, response}) {
            component.set('v.resData', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    scriptsLoaded : function(component) {
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
    },

    doSave : function (component, event, helper) {
        const dealerPad = component.get('v.dealerPad');
        const customerPad = component.get('v.customerPad');
        const contract = component.get('v.contract');
        // 법인 고객 여부
        const isCorporationAccount = (component.get('v.resData.Contract.isCorporationAccount') === 'true');

        // 사업자 번호 혹은 주민등록번호 관련 변수
        let socialNo1;
        let socialNo2;
        let bizNo;
        let bizNo2;
        let bizNo3;

        if(!isCorporationAccount) {
            socialNo1 = component.find('socialNo').get('v.value');
            socialNo2 = component.find('socialNo2').get('v.value');
        } else {
            bizNo = component.find('bizNo').get('v.value');
            bizNo2 = component.find('bizNo2').get('v.value');
            bizNo3 = component.find('bizNo3').get('v.value');
        }

        // Validation Check.
        if(!component.find('isCUPI').get('v.checked')){
            helper.gfn_toast('개인정보제공에 동의해주세요.', 'w');
            return;
        }

        if(!isCorporationAccount && (socialNo1.length !== 6 || !/^\d+$/.test(socialNo1) || socialNo2.length !== 7 || !/^\d+$/.test(socialNo2))) {
            helper.gfn_toast('올바른 주민등록번호를 입력해주세요.', 'w');
            return;
        }

        if(isCorporationAccount
            && ((bizNo.length !== 3 || !/^\d+$/.test(bizNo))
            || (bizNo2.length !== 2 || !/^\d+$/.test(bizNo2))
            || (bizNo3.length !== 5 || !/^\d+$/.test(bizNo3)))
        ) {
            helper.gfn_toast('올바른 사업자등록번호를 입력해주세요.', 'w');
            return;
        }

        if(dealerPad.isEmpty() || customerPad.isEmpty()){
            helper.gfn_toast('서명을 완료해 해주세요.', 'w');
            return;
        }

        // Contract Setting.
        contract.Id = component.get('v.recordId');
        contract.eFormsignStatus__c = '계약서생성오류';

        if(!isCorporationAccount) {
            contract.SocialNoIn__c = btoa(socialNo1 + socialNo2);
            contract.VwSocialNo__c = socialNo1 + '-' + socialNo2.substring(0, 1) + '******';
        } else {
            contract.BusinessRegNo__c = bizNo + bizNo2 + bizNo3;
        }

        helper.apex(
            component, 'doSave', 'signSave', {
                recordId: contract.Id,
                dealerSignPng : dealerPad.toDataURL(),
                customerSignPng : customerPad.toDataURL()
            }
        ).then(({resData}) => {
            return helper.apex(component, 'doSave', 'pdfSave', {
                recordId: contract.Id,
            })
        }).then(({resData}) => {
            contract.eFormsignStatus__c = '계약체결';
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        }).finally(() => {
            helper.apex(
                component, 'doSave', 'successSave', {
                    referContract: contract
                }
            ).then(({resData}) => {
                if(resData === 's') {
                    helper.gfn_toast('성공적으로 저장되었습니다.', 's');
                    $A.enqueueAction(component.get('c.doCancel'));
                } else {
                    helper.gfn_toast('계약서 생성 도중, 장애가 발생하였습니다.\n' + '시스템 관리자에게 문의해주세요.', 'e');
                }
            }).catch(({error}) => {
                helper.gfn_ApexErrorHandle(error);
            });
        });
    },


    doCancel : function(component){
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuoteContractList__c"
            },
            "state": {
                "tabName":"Contract"
            }
        });
    },

});