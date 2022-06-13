/**
** @filename     : AssetManageforAccountQa_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-14 오후 5:15
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
private class AssetManageforAccountQa_ts {
    @IsTest
    static void testBehavior() {
//        TestDataBaseFactory.init();
//        AssetManageforAccountQa.CustomerData customerData = AssetManageforAccountQa.init(TestDataBaseFactory.agencyAccount.Id);
//
//        // 자사 제품인 경우
//        customerData.asset = TestDataBaseFactory.baseAsset;
//        customerData.asset.Brand__c = 'LS';
//        AssetManageforAccountQa.save(customerData);
//
//        // 타사 제품인 경우
//        customerData.asset = TestDataBaseFactory.baseAsset;
//        customerData.asset.Brand__c = '대동';
//        AssetManageforAccountQa.save(customerData);
//
//        // 대리점 유저로 조회
//        System.runAs(TestDataBaseFactory.agencyUser) {
//            AssetManageforAccountQa.getSearch('{"name":"test"}',10,1);
//        }
//    }
        TestDataBaseFactory.init();
        AssetManageforAccountQa.CustomerData customerData = AssetManageforAccountQa.init(TestDataBaseFactory.businessOfficeAccount.Id);

        // 자사 제품인 경우
        customerData.asset = TestDataSalesFactory.baseAsset;
        customerData.asset.Brand__c = 'LS';
        AssetManageforAccountQa.save(customerData);

        // 타사 제품인 경우
        customerData.asset = TestDataSalesFactory.baseAsset;
        customerData.asset.Brand__c = '대동';
        AssetManageforAccountQa.save(customerData);

        // 대리점 유저로 조회
        System.runAs(TestDataBaseFactory.agencyUser) {
            AssetManageforAccountQa.getSearch('{"name":"test"}',10,1);
        }




    }
}