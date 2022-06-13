/****************************************************************************************
 * @filename      : lsMSalesWarrantyClaimDetailController.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-19 오후 3:01
 * @group         :
 * @group-content :
 * @description   : [모바일] LWS 클레임 상세 조회
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-19 오후 3:01      SEOKHO LEE          Create
 ****************************************************************************************/
({
    /**
     * Init
     * @param component
     * @param event
     * @param helper
     */
    doInit : function(component, event, helper) {
        helper.lacComService = component.find('lacComService');
        helper.lacComService.doGetSobjectData('WarrantyClaim__c', function(resData) {
            component.set('v.labelMap', resData);
        });
        helper.apex(
            component, 'doInit', 'init', {
                'recordId': component.get('v.recordId')
            }
        ).then(function ({resData, response}) {
            component.set('v.detailData', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 저장
     * @param component
     * @param event
     * @param helper
     */
    doSave : function(component, event, helper) {
        component.set('v.editFlag', true);
    },

    /**
     *  파일 업로드
     * @param component
     * @param event
     * @param helper
     */
    handleUploadFinished: function (component, event, helper) {
        const uploadedFile = event.getParam("files")[0];
        const source = event.getSource();
        helper.apex(
            component, 'updateContentVersionItems', 'updateContentVersionItems', {
                'recordId': '',
                'n_documentId': uploadedFile.documentId,
                'o_documentId': source.get("v.class"),
                'lWSImageType': source.get("v.title").split('/')[1]
            }
        ).then(function ({resData, response}) {
            const idx = source.get("v.title").split('/')[0]-1;
            console.log('idx : ' + idx);
            component.set('v.detailData.contentVersions[' + idx + ']', resData);
            const seq = source.get("v.title").split('/')[0];
            const contentVersionId = source.get("v.title").split('/')[2];
            const detailData = component.get('v.detailData');
            console.log('-------------------> '+ detailData.warrantyClaim.AssetId__r.Name);
            console.log('-------------------> '+ detailData.warrantyClaim.ClaimNo__c);
            console.log('-------------------> '+ resData.Id);
            return helper.apex(
                component, 'handleUploadFinished', 'callLWS0022', {
                    'assetName': detailData.warrantyClaim.AssetId__r.Name,
                    'claimNo' : detailData.warrantyClaim.ClaimNo__c,
                    'contentVersionId' : resData.Id,
                    'seq' : seq
                }
            );
        }).then(function ({resData, response}) {
            helper.gfn_toast('사진 정보가 정상적으로 업데이트 되었습니다.', 's');
            console.log('--------------');
            console.log(resData);
            console.log('--------------');
        }).catch(function ({error, response}) {
            helper.log(component, 'ERROR --------------------------');
            helper.log(component, error);
            helper.log(component, 'ERROR --------------------------');
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 취소(목록 이동)
     * @param component
     * @param event
     * @param helper
     */
    doCancel : function (component, event, helper) {
        if(component.get('v.editFlag')) {
            component.set('v.editFlag', false);
        }
        else {
            helper.fn_doMoveList(component);
        }
    },
})