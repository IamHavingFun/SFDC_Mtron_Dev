/****************************************************************************************
 * @filename      : lsMSalesAddGeneralMachineQaHelper.js
 * @author        : I2MAX
 * @date          : 2021-02-18 오후 4:06
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @release       : v1.0.0
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author        description
 * ===============================================================
 0.1     2021-02-18 오후 4:06         I2MAX          Create
 ****************************************************************************************/
({
    fn_initAmt : function (component, quoteWp) {

        quoteWp.quote.LastQuoteAmt__c       = quoteWp.amtWrapper.resultPrice = quoteWp.amtWrapper.totalPrice;
        quoteWp.quote.UsedUndertakingAmt__c = 0;
        quoteWp.amtWrapper.totalDiscount    = quoteWp.amtWrapper.discount;

        component.set('v.quoteWp', quoteWp);
    }
});