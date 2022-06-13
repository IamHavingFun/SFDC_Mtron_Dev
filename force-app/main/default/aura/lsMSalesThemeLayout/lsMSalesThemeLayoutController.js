/****************************************************************************************
 * @filename      : lsMSalesThemeLayoutController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-16 오후 1:29
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
 0.1     2020-06-16 오후 1:29    i2max_my.Seo          Create
 ****************************************************************************************/
({
    doTest : function (component, event, helper) {
        const swiper = new Swiper('.swiper-container', {
            pagination: {
                el: '.swiper-pagination',
                type: 'fraction',
            },
            navigation: {
                nextEl: '.swiper-button-next',
                prevEl: '.swiper-button-prev',
            },
        });
    },
});