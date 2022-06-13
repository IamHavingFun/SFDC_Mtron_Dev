/****************************************************************************************
 * @filename      : tableauAppConnectorController.js
 * @projectname   : LWC_I2MAX
 * @author        : i2max_my.Seo
 * @date          : 2020-03-10 오전 9:33
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
 0.1     2020-03-10 오전 9:33     i2max_my.Seo          Create
 ****************************************************************************************/
({
    //-------------------------------------------------------------
    // 초기화
    //-------------------------------------------------------------
    doInit : function(component, event, helper){
        helper.apex(
            component, 'doInit', 'init', null
        ).then(function ({resData, response}) {
            let tsname = component.get("v.tsname");
            let signedIdentity = resData;
            let param = JSON.stringify({
                'ts.name' : tsname,
                'ts.trustedTicket.signedIdentity' : signedIdentity
            });
            console.log('-----------------');
            console.log(param);
            console.log('-----------------');
            component.set('v.parameters', param);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
});