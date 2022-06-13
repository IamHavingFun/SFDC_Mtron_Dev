/****************************************************************************************
  * @filename      : AssetSendReceiveSpecifiedDate_sc_ts
  * @projectname   : LS
  * @author        : Park JW
  * @date          : 2020-07-20 오후 3:27
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                      author          description
  * ===============================================================
    0.1     2020-07-20 오후 3:27           Park JW         Create
****************************************************************************************/

@IsTest
private class AssetSendReceiveSpecifiedDate_sc_ts {
    @IsTest
    static void testBehavior() {
        AssetSendReceiveSpecifiedDate_sc.runSchedule();
        AssetSendReceiveSpecifiedDate_sc.abortSchedule();
    }
}