/****************************************************************************************
 * @filename      : LsMSalesAccountSearch_ts
 * @projectname   :
 * @author        : CHOI SEONGWON
 * @date          : 2020-07-07 오전 11:27
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
 0.1     2020-07-07 오전 11:27      CHOI SEONGWON          Create
 ****************************************************************************************/

@IsTest
private class  lsMSalesAccountDetail_ts{
@IsTest
static void testBehavior() {
    TestDataBaseFactory.init();
    lsMSalesAccountDetail.init(TestDataBaseFactory.businessOfficeAccount.Id);
}
}