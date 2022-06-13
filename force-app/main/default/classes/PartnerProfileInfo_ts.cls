/****************************************************************************************
 * @filename      : PartnerProfileInfo_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-07-21 오전 10:22
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
 0.1     2020-07-21 오전 10:22        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class PartnerProfileInfo_ts {
    @isTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        Account acc = TestDataBaseFactory.agencyAccount;
        acc.ServiceCapabilityClass__c = 'S';
        update acc;
        PartnerProfileInfo.UserProfile userProfile  = new PartnerProfileInfo.UserProfile(TestDataBaseFactory.agencyUser, acc, 0, 0);

        System.assertEquals(userProfile.smallPhotoUrl, null);
        System.assertEquals(userProfile.mediumPhotoUrl, null);
        System.assertEquals(userProfile.fullPhotoUrl, null);
        
        System.runAs(TestDataBaseFactory.agencyUser){
            PartnerProfileInfo.init();
        }
    }
}