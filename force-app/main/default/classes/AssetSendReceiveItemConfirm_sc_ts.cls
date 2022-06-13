/****************************************************************************************
  * @filename      : AssetSendReceiveItemConfirm_sc_ts
  * @projectname   : LS
  * @author        : Park JW
  * @date          : 2020-07-20 오후 2:49
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
    0.1     2020-07-20 오후 2:49           Park JW         Create
****************************************************************************************/

@IsTest
private class AssetSendReceiveItemConfirm_sc_ts {
    @IsTest
    static void testBehavior() {
        AssetSendReceiveItemConfirm_sc.runSchedule();
        AssetSendReceiveItemConfirm_sc.abortSchedule();
        //============================================================================
        // 혹시 실행이 되지 않을 경우 원소스로 재실행함.
        //============================================================================
        System.schedule('AssetAssetSendReceiveItemConfirm', '0 0 8 * * ?', new AssetSendReceiveItemConfirm_sc());
    }
}