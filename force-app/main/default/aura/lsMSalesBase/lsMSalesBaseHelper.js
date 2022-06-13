/****************************************************************************************
 * @filename      : lsMSalesBaseHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-07-02 오후 12:58
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
 0.1     2020-07-02 오후 12:58    i2max_my.Seo          Create
 ****************************************************************************************/
({

    fn_getUrlParams : function () {
        const params = {};
        window.location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(str, key, value) { params[key] = value; });
        return params;
    },

    /**
     * 공백제거
     * @param component
     * @param event
     * @param helper
     */
    mfn_removeWhiteSpace: function (component, event, helper) {
        const val = event.getSource().get('v.value');
        event.getSource().set('v.value', val.replace(/\s/gi, ''));
        event.stopPropagation();
    },

    /**
     * 숫자만 여부 체크
     * @param val
     * @returns {boolean}
     */
    mfn_isOnlyNumber: function (val) {
        return /^[0-9]*$/.test(val);
    }

});