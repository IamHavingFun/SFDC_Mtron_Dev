/****************************************************************************************
  * @filename      : OverdueInterest_tr_ts
  * @author        : I2MAX
  * @date          : 2021-03-11
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author         description
  * ===============================================================
    1.0     2021-03-11           I2MAX           Create
****************************************************************************************/
@IsTest
private class OverdueInterest_tr_ts {
    @IsTest
    static void testBehavior() {
        //==============================================================================
        // Data Setting
        //==============================================================================
        TestDataBaseFactory.init();
        TestDataProductFactory.init();

        OverdueInterest__c overdueInterest = new OverdueInterest__c();

        overdueInterest.DealerCode__c = '001';
        overdueInterest.SerialNo__c = '00000001';
        overdueInterest.BondBillNo__c = '123045958';

        //==============================================================================
        // Logic Test
        //==============================================================================
        Test.startTest();

        insert overdueInterest;

        overdueInterest.DealerCode__c = '002';

        update overdueInterest;

        Test.stopTest();
    }
}