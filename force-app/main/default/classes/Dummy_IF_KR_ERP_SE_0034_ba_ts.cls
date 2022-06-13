@IsTest
public with sharing class Dummy_IF_KR_ERP_SE_0034_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
        //============================================================================
        // 필요시 Dummy 데이터 변경 및 추가
        //============================================================================
        // 정상 Data
        IF_KR_ERP_SE_0001__c erpSe0034s = TestDataDummyBatchFactory.erpSe0001dummyDataBase.clone(false, true);
        erpSe0034s.InterfaceId__c = 'IF_KR_ERP_SE_0034';
        erpSe0034s.BlacklistWarning__c = 'Y';
        erpSe0034s.BlacklistErpDelivery__c = 'Y';
        erpSe0034s.Blacklist30Days__c = 'Y';
        erpSe0034s.DeliveryStopDate__c = '20200220';
        erpSe0034s.BlacklistReason__c = '사유1. 사유2. ';
        insert erpSe0034s;

        // 비정상 Data
        IF_KR_ERP_SE_0001__c erpSe0034s2 = erpSe0034s.clone(false, true);
        erpSe0034s2.ERPCode__c   = '----';
        erpSe0034s2.BlacklistWarning__c = 'Y';
        erpSe0034s2.BlacklistErpDelivery__c = 'Y';
        erpSe0034s2.Blacklist30Days__c = 'Y';
        erpSe0034s2.DeliveryStopDate__c = '20200220';
        erpSe0034s2.BlacklistReason__c = '사유1. 사유2. ';
        //erpSe0034s2.DeliveryStopDate__c = '----'
        insert erpSe0034s2;

        //============================================================================
        // 배치 실행
        //============================================================================\
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0034_ba(), 200);
    }
}