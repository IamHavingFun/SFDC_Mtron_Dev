/****************************************************************************************
  * @filename      : OrderDeliverySeqUpdate_sc_ts
  * @author        : I2MAX
  * @date          : 2021-11-15
  * @group         : 
  * @group-content : 
  * @description   : 
  * @reference     : 
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author        description
  * ===============================================================
    1.0     2021-11-15                  I2MAX.YR        Create
****************************************************************************************/


@IsTest
private class OrderDeliverySeqUpdate_sc_ts {
    @IsTest
    static void testBehavior() {
        OrderDeliverySeqUpdate_sc.runSchedule();
        OrderDeliverySeqUpdate_sc.abortSchedule();
    }
}