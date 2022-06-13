/****************************************************************************************
 * @filename      :
 * @projectname   :
 * @author        : i2max_Junseok.Kwon
 * @date          : 2020-03-30 오전 9:30
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * =========================================================================
 * ver     date                    author                    description
 * =========================================================================
 0.1     2020-03-30 오전 9:30     i2max_Junseok.Kwon        Create
 ****************************************************************************************/

({
    //-------------------------------------------------------------
    // 초기화
    //-------------------------------------------------------------
    doInit : function(component, event, helper){
        helper.apex(
            component, 'doInit', 'init', {recordId : component.get('v.recordId')}
        ).then(function ({resData, response}) {
            component.set('v.priceList', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
});