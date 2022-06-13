/**
** @filename     : OrderAssetDisplayQa_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-20 오후 2:58
* @group         :
* @group-content :
* @description   :
* @tester        :
* @reference     :
* @copyright     : Copyright © I2max. All Rights Reserved.
* @modification Log
* ===============================================================
* ver     date             author              description
* ===============================================================
  0.1                            Create
 */
@IsTest
private class OrderAssetDisplayQa_ts {

    @IsTest
    static void testBehavior() {

        OrderAssetDisplayQa.InitData initData = new OrderAssetDisplayQa.InitData();
        System.assertNotEquals(initData.productTypeList,null);
        System.assertNotEquals(initData.seriesList,null);


        System.assertNotEquals(OrderAssetDisplayQa.init(),null);
        System.assertNotEquals(OrderAssetDisplayQa.getSearch('{"name":"test","productType":"test","series":"test"}',10,1),null);







    }
}