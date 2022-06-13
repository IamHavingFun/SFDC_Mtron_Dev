/****************************************************************************************
  * @filename      : i2SEMA_ComponentResponse_ts
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/21 9:26 AM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : i2SEMA_ComponentResponse_ts_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/21 9:26 AM     i2max_shlee       Create
****************************************************************************************/
@IsTest
public with sharing class i2SEMA_ComponentResponse_ts {

    @TestSetup static void setData() {
        i2SEMA_TestDataUtil.getAccount();
    }

    static testmethod void testCase01() {
        i2SEMA_ComponentResponse response = new i2SEMA_ComponentResponse();
        response.setData('result','SUCCESS');

        i2SEMA_TestDataUtil.getAccount();
        response.setData('acc',i2SEMA_TestDataUtil.acc);
        response.getData('acc');

        Map<String, String> testMap = new Map<String,String>();
        testMap.put('testMap','testMap');
        response.setData(testMap);

        System.assertEquals(response.getData('acc'), i2SEMA_TestDataUtil.acc);
        System.assertEquals(response.getData('result'), 'SUCCESS');
        System.assertEquals(response.getData('testMap'), 'testMap');

    }
}