/****************************************************************************************
  * @filename      : LsMSalesCustomerConsultAuthQa_ts
  * @author        : I2MAX
  * @date          : 2021-05-12
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
    1.0     2021-05-12          I2MAX           Create
****************************************************************************************/


@IsTest
private class LsMSalesCustomerConsultAuthQa_ts {
    @IsTest
    static void testBehavior() {
        System.assertNotEquals(null, LsMSalesCustomerConsultAuthQa.sendSms('010-0000-0000'));
    }
}