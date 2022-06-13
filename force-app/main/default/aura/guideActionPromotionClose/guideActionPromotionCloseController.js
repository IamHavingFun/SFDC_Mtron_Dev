/****************************************************************************************
  * @filename      : guideActionPromotionCloseController.js
  * @projectname   : LS_PS
  * @author        : MS
  * @date          : 2020-07-15 08 57
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
    0.1     2020-07-15 08 57       Park He         Create
****************************************************************************************/
({
    doInit : function(component, event, helper){
        helper.apex(
            component, 'doinit', 'init', {
                'recordId' : component.get('v.recordId')
            }
        ).then(function ({resData, response}) {
            if(!resData){
                helper.gfn_toast('이미 완료 처리된 프로모션입니다.', 'w');
                component.find("overlayLib").notifyClose();
            }
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doCloseAlert : function(component, event, helper){
        helper.apex(
            component, 'promotionClose', 'setPromotionClose', {
                'recordId' : component.get('v.recordId')
            }
        ).then(function ({resData, response}) {
            if(resData){
                component.find("overlayLib").notifyClose();
                $A.get('e.force:refreshView').fire();
                helper.gfn_toast('정상적으로 프로모션이 완료되었습니다.', 's');
            } else{
                helper.gfn_toast('이미 완료 처리된 프로모션입니다.', 'w');
                component.find("overlayLib").notifyClose();
            }
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doCancel : function(component, event, helper){
        component.find("overlayLib").notifyClose();

    },

});