/****************************************************************************************
  * @filename      : I2ComUtil_ts
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-03-13 오전 7:51
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
    0.1     2020-03-13 오전 7:51     i2max_my.Seo            Create
****************************************************************************************/
@IsTest
private class I2ComUtil_ts {
    @IsTest
    static void testBehavior() {
        System.assertNotEquals(I2ComUtil.getPickList('Account', 'Industry'), null);
        System.assertNotEquals(I2ComUtil.makePickListOptions('Account', 'Industry'), null);
        System.assertNotEquals(I2ComUtil.makePickListOptions('Account', 'Industry', true, true, new Set<String>{'test'}), null);
        System.assertNotEquals(I2ComUtil.getFieldType('Account', 'Industry'), null);
        System.assertNotEquals(I2ComUtil.makeInitOptions('All'), null);
        System.assertEquals(I2ComUtil.getSitePathPrefix(), null);
        System.assertNotEquals(I2ComUtil.getRecordType('Account', 'PersonAccount'), null);
    }
}