/****************************************************************************************
  * @filename      : SupplyPriceDisplayController_ts
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-10
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-07-10             Park HE         Create
****************************************************************************************/

@IsTest
private class SupplyPriceDisplayController_ts {
    @IsTest
    static void testBehavior() {
        Order__c order = new Order__c(PODate__c = System.today());
        insert order;

        System.assertNotEquals(SupplyPriceDisplayController.getSupplyPrice(order.Id), null);
    }
}