/**
** @filename     : 
* @projectname   :
* @author        :  CHOI SEONGWON
* @date          : 
* @group         :
* @group-content :
* @description   :
* @tester        :
* @reference     :
* @copyright     : Copyright © I2max. All Rights Reserved.
* @modification Log
* ===============================================================
* ver     date             author              description
* ===============================================================
  0.1                            Create
 */
@IsTest
private class lsMSalesAccountSearch_ts {
    @IsTest
    static void testBehavior() {
        //TestDataBaseFactory.init();
        //TestDataProductFactory.init();

        String reqData;

        // 1. 고객 조회
        reqData = '{"searchType":"Account","srchName":"test","srchSer…Standard":"","srchPurchaseDate":"","srchDate":""}';
        lsMSalesAccountSearch.getSearch(reqData, 10, 1);

        // 2. 자산
        reqData = '{"searchType":"Asset","srchName":"test","srchSeries":"J","srchHorsePowerStandard":"27","srchPurchaseDate":"1","srchDate":""}';
        lsMSalesAccountSearch.getSearch(reqData, 10, 1);

        reqData = '{"searchType":"Asset","srchName":"test","srchSeries":"J","srchHorsePowerStandard":"27","srchPurchaseDate":"7","srchDate":""}';
        lsMSalesAccountSearch.getSearch(reqData, 10, 1);

        // 3. 상담
        reqData = '{"searchType":"Opportunity","srchName":"test","srchSeries":"","srchHorsePowerStandard":"","srchPurchaseDate":"","srchDate":"7"}';
        lsMSalesAccountSearch.getSearch(reqData, 10, 1);

        System.assertNotEquals(lsMSalesAccountSearch.getHorsePowerStandardOptions('LV'), null);

        System.assertNotEquals(lsMSalesAccountSearch.getSeriesOptions(), null);

    }
}