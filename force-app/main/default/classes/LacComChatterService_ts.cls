/****************************************************************************************
  * @filename      : LacComChatterService_ts
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-07-07 오후 2:32
  * @group         : 
  * @group-content : 
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-07 오후 2:32     i2max_my.Seo           Create
****************************************************************************************/
@IsTest
private class LacComChatterService_ts {
    @IsTest
    static void testBehavior() {
        String targetRecordId = UserInfo.getUserId();

        LacComChatterService.simpleChatterFeed(null, targetRecordId, 'test', new Set<String>{targetRecordId});
        LacComChatterService.simpleChatterFeed(null, new Set<String>{targetRecordId}, 'test');
    }
}