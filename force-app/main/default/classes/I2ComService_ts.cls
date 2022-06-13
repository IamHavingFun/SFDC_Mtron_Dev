/****************************************************************************************
  * @filename      : I2ComService_ts
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-04-27 오후 3:29
  * @group         : 
  * @group-content : 
  * @description   :
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-04-27 오후 3:29     i2max_my.Seo           Create
****************************************************************************************/
@IsTest
private class I2ComService_ts {
    @IsTest
    static void testBehavior() {
        System.assertNotEquals(I2ComService.gfnGetMultiSObjectLabel('Account'), null);
    }
}