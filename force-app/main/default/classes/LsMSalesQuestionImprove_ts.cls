/****************************************************************************************
 * @filename      : LsMSalesQuestionImprove_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-07-07 오전 11:18
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
 0.1     2020-07-07 오전 11:18        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class LsMSalesQuestionImprove_ts {
    @isTest
    static void testBehavior() {
        String reqData = '{"searchStatus":"Progress"}';
        LsMSalesQuestionImprove.getSearch(reqData,1,1);
        reqData = '{"searchStatus":"Completed"}';
        LsMSalesQuestionImprove.getSearch(reqData,1,1);
    }
}