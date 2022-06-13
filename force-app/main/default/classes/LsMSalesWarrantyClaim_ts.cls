/****************************************************************************************
 * @filename      : LsMSalesWarrantyClaim_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-07-07 오전 11:20
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
 0.1     2020-07-07 오전 11:20        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class LsMSalesWarrantyClaim_ts {
    @isTest
    static void testBehavior() {
        String reqData = '{"searchBox":""}';
        LsMSalesWarrantyClaim.getSearch(reqData,1,1);
        reqData = '{"searchBox":"11"}';
        LsMSalesWarrantyClaim.getSearch(reqData,1,1);
    }
}