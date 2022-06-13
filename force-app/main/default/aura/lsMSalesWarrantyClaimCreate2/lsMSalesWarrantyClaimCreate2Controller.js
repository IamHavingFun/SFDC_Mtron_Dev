/**
 * Created by MS on 2020-07-03.
 */

({
    doInit : function(component, event, helper){
        const assetName = helper.gfn_getQueryStringValue('name');
        //const assetName = component.get('mobileStepVO.bizData.asset.Name');
        helper.apex(
            component, 'doInit', 'claimInit', {
                'assetName': assetName
            }
        ).then(function ({resData, response}) {
            component.set("v.claimData", resData);

            //============================================================================
            // 로그인 사용자의 AccountId와 자산의 대리점이 상이한 경우 메시지 처리 및 기능 막음
            // 2020.08.27 수정
            //============================================================================
            let isSameDealer = resData.isSameDealer || false;
            component.set('v.isSameDealer', isSameDealer);

            if(!isSameDealer) {
                helper.gfn_toast('타 대리점의 실판매 기대입니다. \n변경이 필요한 경우 시스템관리자에게 문의하십시오.');
                return;
            }

            if(resData.asset.InventoryType__c != '실판매') {
                component.set('v.isSameDealer', false);
                helper.gfn_toast('실판매 자산이 아닙니다. PDI등록 처리가 필요합니다. \n추가 사항은 시스템관리자에게 문의 하십시오.','w','sticky');
                return;
            }

            if(resData.asset.WtyEndDate__c != null && resData.asset.WtyEndDate__c < $A.localizationService.formatDate(new Date(), "YYYY-MM-DD")){
                helper.gfn_toast('워런티 기간이 종료되었습니다. 영업소 당담자와 확인 바랍니다.','w','sticky');
            }

        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    handleUploadFinished: function (component, event, helper) {
        var uploadedFile = event.getParam("files")[0];
        var source = event.getSource();
        helper.apex(
            component, 'updateContentVersionItems', 'updateContentVersionItems', {
                'recordId': component.get('v.recordId'),
                'n_documentId': uploadedFile.documentId,
                'o_documentId': source.get("v.class"),
                'lWSImageType': source.get("v.label")
            }
        ).then(function ({resData, response}) {
            component.set('v.claimData.contentVersionItems.'+source.get("v.name"), resData);
            console.log('--------------');
            //console.log(JSON.stringify(component.get('v.claimData')));
            console.log('--------------');
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doSave: function (component, event, helper) {
        helper.apex(
            component, 'doSave', 'save', {
                'claimData': component.get('v.claimData')
            }
        ).then(function ({resData, response}) {
            helper.log(component, 'callLWS0021');
            return helper.apex(
                component, 'doSave', 'callLWS0021', {
                    'claimData': component.get('v.claimData')
                }
            );
        }).then(function ({resData, response}) {
            component.set('v.claimData', resData);
            helper.log(component, 'callLWS0022-1');
            if($A.util.isEmpty(component.get('v.claimData.contentVersionItems.p1.Id'))) return {};
            return helper.apex(
                component, 'doSave', 'callLWS0022', {
                    'claimData': component.get('v.claimData'),
                    'contentVersionId' : component.get('v.claimData.contentVersionItems.p1.Id'),
                    'seq': '1'
                }
            );
        }).then(function ({resData, response}) {
            helper.log(component, 'callLWS0022-2');
            if($A.util.isEmpty(component.get('v.claimData.contentVersionItems.p2.Id'))) return {};
            return helper.apex(
                component, 'doSave', 'callLWS0022', {
                    'claimData': component.get('v.claimData'),
                    'contentVersionId' : component.get('v.claimData.contentVersionItems.p2.Id'),
                    'seq': '2'
                }
            );
        }).then(function ({resData, response}) {
            helper.log(component, 'callLWS0022-3');
            if($A.util.isEmpty(component.get('v.claimData.contentVersionItems.p3.Id'))) return {};
            return helper.apex(
                component, 'doSave', 'callLWS0022', {
                    'claimData': component.get('v.claimData'),
                    'contentVersionId' : component.get('v.claimData.contentVersionItems.p3.Id'),
                    'seq': '3'
                }
            );
        }).then(function ({resData, response}) {
            helper.log(component, 'callLWS0022-4');
            if($A.util.isEmpty(component.get('v.claimData.contentVersionItems.p4.Id'))) return {};
            return helper.apex(
                component, 'doSave', 'callLWS0022', {
                    'claimData': component.get('v.claimData'),
                    'contentVersionId' : component.get('v.claimData.contentVersionItems.p4.Id'),
                    'seq': '4'
                }
            );
        }).then(function ({resData, response}) {
            helper.log(component, 'callLWS0022-5');
            if($A.util.isEmpty(component.get('v.claimData.contentVersionItems.p5.Id'))) return {};
            return helper.apex(
                component, 'doSave', 'callLWS0022', {
                    'claimData': component.get('v.claimData'),
                    'contentVersionId' : component.get('v.claimData.contentVersionItems.p5.Id'),
                    'seq': '5'
                }
            );
        }).then(function ({resData, response}) {
            helper.log(component, 'callLWS0022-6');
            if($A.util.isEmpty(component.get('v.claimData.contentVersionItems.p6.Id'))) return {};
            return helper.apex(
                component, 'doSave', 'callLWS0022', {
                    'claimData': component.get('v.claimData'),
                    'contentVersionId' : component.get('v.claimData.contentVersionItems.p6.Id'),
                    'seq': '6'
                }
            );
        }).then(function ({resData, response}) {
            helper.log(component, 'callLWS0022-7');
            if($A.util.isEmpty(component.get('v.claimData.contentVersionItems.p7.Id'))) return {};
            return helper.apex(
                component, 'doSave', 'callLWS0022', {
                    'claimData': component.get('v.claimData'),
                    'contentVersionId' : component.get('v.claimData.contentVersionItems.p7.Id'),
                    'seq': '7'
                }
            );
        }).then(function ({resData, response}) {
            helper.log(component, 'callLWS0022-8');
            if($A.util.isEmpty(component.get('v.claimData.contentVersionItems.p8.Id'))) return {};
            return helper.apex(
                component, 'doSave', 'callLWS0022', {
                    'claimData': component.get('v.claimData'),
                    'contentVersionId' : component.get('v.claimData.contentVersionItems.p8.Id'),
                    'seq' : '8'
                }
            );
        }).then(function ({resData, response}) {
            helper.log(component, 'end');
            const recordId = component.get('v.claimData').wc.Id;
            console.log('recordId ==> ' + recordId);
            component.find('lacComService').doNaviService({
                "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
                "attributes": {
                    "name": "lsMSalesWarrantyClaimDetail__c"
                },
                "state": {
                    "recordId": recordId
                }
            });
        }).catch(function ({error, response}) {
            helper.log(component, 'ERROR --------------------------');
            helper.log(component, error);
            helper.log(component, 'ERROR --------------------------');
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doCancel : function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesHome__c"
            },
        });
    }

});