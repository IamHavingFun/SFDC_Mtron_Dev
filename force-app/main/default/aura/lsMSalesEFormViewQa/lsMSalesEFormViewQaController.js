/**
 * Created by MS on 2020-07-08.
 */
/****************************************************************************************
  * @filename      : lsMSalesEFormViewQaController.js
  * @projectname   : LS_PS
  * @author        : MS
  * @date          : 2020-07-08 08 33
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
    0.1     2020-07-08 08 33       Park He         Create
****************************************************************************************/
({
    doInit : function(component, event, helper){
        let partnerUrl = helper.gfn_getSiteUrlFromWindowLocation();
        console.log(partnerUrl);
        helper.apex(
            component, 'doInit', 'init', {
                'recordId' : component.get('v.recordId'),
            }
        ).then(function ({resData, response}) {
            component.set('v.contract', resData);
            let contentType = component.get('v.isDeskTop') ? '' : 'P';
            let viewPage =  partnerUrl+'/apex/ContractPDF?contractid=' + component.get('v.recordId')+'&type='+contentType;

            component.set('v.pdfViewPageUrl', viewPage);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });

    },

    doCancel : function(component, event, helper){
        component.find("overlayLib").notifyClose();
    },

    doDownload : function (component, event, helper) {
        helper.apex(
            component, 'doDownload', 'getContentDocumentLinkId', {
                recordId: component.get('v.recordId')
            }
        ).then(({resData}) => {
            if($A.util.isEmpty(resData)) {
                helper.gfn_toast('계약서 파일이 없습니다.', 'w');
                return;
            }
            component.set('v.contentDocumentId', resData);
            var partnerUrl = helper.gfn_getSiteUrlFromWindowLocation();
            var downloadPage =  partnerUrl+'/sfc/servlet.shepherd/document/download/' + resData;
            component.set('v.pdfDownloadPageUrl', downloadPage);
            component.set('v.isDownload', true);

        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    doConfirm : function (component, event, helper) {
        helper.apex(
            component, 'doConfirm', 'setReview', {
                recordId: component.get('v.recordId')
            }
        ).then(({resData}) => {
            component.set('v.contract', resData);
            helper.gfn_refresh();
            component.find("overlayLib").notifyClose();
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },

});