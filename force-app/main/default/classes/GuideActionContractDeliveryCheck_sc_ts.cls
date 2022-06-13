/****************************************************************************************
 * @filename      : GuideActionContractDeliveryCheck_sc_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-08-18 오후 5:17
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
 0.1     2020-08-18 오후 5:17        SEOKHO LEE          Create
 ****************************************************************************************/

@isTest
private class GuideActionContractDeliveryCheck_sc_ts
{
    @isTest
    static void testBehavior() {
        GuideActionContractDeliveryCheck_sc.runSchedule();
        GuideActionContractDeliveryCheck_sc.abortSchedule();
    }
}