/****************************************************************************************
  * @filename      : I2ComClass_ts
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-03-13 오전 7:42
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
    0.1     2020-03-13 오전 7:42     i2max_my.Seo            Create
****************************************************************************************/
@IsTest
private class I2ComClass_ts {
    class InitData extends I2ComClass.InitData {
    }

    @IsTest
    static void testBehavior() {
        InitData initData = new InitData();
        System.assertNotEquals(initData, null);
        System.assertNotEquals(new I2ComClass.Option('label', 'value'), null);

        I2ComClass.ResData resData = new I2ComClass.ResData(1000, new List<SObject>{new Account(Name='test')});
        System.assertNotEquals(resData, null);
        System.assertNotEquals(resData.recordSize, 0);
    }
}