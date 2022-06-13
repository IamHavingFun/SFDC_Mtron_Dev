/****************************************************************************************
  * @filename      : AccSimpleInfoController_ts
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-09
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-07-09             Park HE         Create
****************************************************************************************/

@IsTest
private class AccSimpleInfoController_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataSalesFactory.init();
        AccSimpleInfoController.getAccSimpleInfo(TestDataBaseFactory.agencyAccount.Id);
    }
}