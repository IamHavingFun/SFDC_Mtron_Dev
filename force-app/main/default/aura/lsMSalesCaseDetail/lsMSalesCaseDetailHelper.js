/****************************************************************************************
 * @filename      : lsMSalesCaseDetailHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-11-26 오후 5:01
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author              description
 * ===============================================================
 0.1     2020-11-26 오후 5:01    i2max_my.Seo          Create
 ****************************************************************************************/
({
    fn_doMoveList : function(component){
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuestionImprove__c"
            }
        })
    },
});