/****************************************************************************************
 * @filename      : lsMSalesQuestionImproveDetailHelper.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-29 오전 10:30
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
 0.1     2020-06-29 오전 10:30      SEOKHO LEE          Create
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

})