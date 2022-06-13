/****************************************************************************************
 * @filename      : PartnerHomeProductChangeList_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-08-06 오전 8:32
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
 0.1     2020-08-06 오전 8:32        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class PartnerHomeProductChangeList_ts {
    @isTest
    static void testBehavior() {
        PartnerHomeProductChangeList.init();

        ProductChange__c pc = new ProductChange__c(
                DELETE_FLAG__c = false,
                Name = 'testProductChange',
                PECN_NAME__c = 'testProductChange',
                PDESC__c = 'test',
                PREGISTRATION_DATE__c = TestDataUtilFactory.d,
                PAPPLY_DATE__c = 'test data',
                PUNITEFFECTIVITY__c = 'test',
                SetDealerPublic__c = '공개'
        );
        insert pc;
        PartnerHomeProductChangeList.getList();
    }
}