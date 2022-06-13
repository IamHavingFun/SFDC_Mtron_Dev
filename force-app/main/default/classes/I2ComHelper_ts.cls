/****************************************************************************************
  * @filename      : I2ComHelper_ts
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-03-13 오전 7:57
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
    0.1     2020-03-13 오전 7:57     i2max_my.Seo            Create
****************************************************************************************/
@IsTest
private class I2ComHelper_ts {
    @IsTest
    static void testBehavior() {
        I2ComClass.ResData resData = I2ComHelper.gfnQuery(
                'Id, Name',
                'Account',
                'WHERE Name = \'' + 'aaa'  + '\'',
                '',
                1,
                1
        );
        System.assertNotEquals(resData, null);

        I2ComClass.ResData resData2 = I2ComHelper.gfnQueryNoPaging(
                'Id, Name',
                'Account',
                'WHERE Name = \'' + 'aaa'  + '\'',
                ''
        );
        System.assertNotEquals(resData2, null);

        Map<String, String> tmpMap = I2ComHelper.gfnCheckCondition(JSON.serialize(new Map<String, String>{'111'=>'111'}));
        System.assertNotEquals(tmpMap, null);

        System.assertNotEquals(I2ComHelper.gfnHasCondition(tmpMap, '111'), null);
        System.assertNotEquals(I2ComHelper.gfnRefineCondition(' AND '), null);
    }
}