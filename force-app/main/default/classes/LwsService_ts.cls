/****************************************************************************************
 * @filename      : LwsService_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-07-22 오전 11:15
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
 0.1     2020-07-22 오전 11:15        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class LwsService_ts {
    @TestSetup
    static void setup() {

        List<IF_INFO__c> ifInfos = new List<IF_INFO__c>();

        IF_INFO__c ifInfo18 = TestDataIFCalloutFactory.createIFInfo();
        ifInfo18.IF_ID__c = 'IF_KR_SE_LWS_0018';
        ifInfo18.URL__c = '/api/dev/IF_KR_SE_LWS_0018.json';
        ifInfos.add(ifInfo18);

        IF_INFO__c ifInfo21 = TestDataIFCalloutFactory.createIFInfo();
        ifInfo21.IF_ID__c = 'IF_KR_SE_LWS_0021';
        ifInfo18.URL__c = '/api/dev/IF_KR_SE_LWS_0021.json';
        ifInfos.add(ifInfo21);

        IF_INFO__c ifInfo22 = TestDataIFCalloutFactory.createIFInfo();
        ifInfo22.IF_ID__c = 'IF_KR_SE_LWS_0022';
        ifInfo18.URL__c = '/api/dev/IF_KR_SE_LWS_0022.json';
        ifInfos.add(ifInfo22);

        insert ifInfos;

    }

    @IsTest static void testBehavior()  {

        IfStaticValue__c ifStaticValue = TestDataIFCalloutFactory.createIfStaticValue();
        IF_LWS_Base.IfStaticValue(ifStaticValue);

        IF_KR_SE_LWS_0018.OUTPUT_T_DATA t1 = new IF_KR_SE_LWS_0018.OUTPUT_T_DATA();
        t1.LwsNo = '1';
        t1.AssetNo = TestDataSalesFactory.baseAsset.Name;

        List<IF_KR_SE_LWS_0018.OUTPUT_T_DATA> outputTData = new List<IF_KR_SE_LWS_0018.OUTPUT_T_DATA>{
            new IF_KR_SE_LWS_0018.OUTPUT_T_DATA(), t1
        };

        String outputTDataString = JSON.serialize(outputTData);

        // Mock 객체 세팅
        Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock(
            '{"token":"test111", "Response":{"Header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_LWS_0018","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","ifResult":"S", "IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"Payload":{"TOTAL_RECORD_CNT":"2","t_data":' + outputTDataString + '}}}'
        ));

        PDI__c testPdi = TestDataBizFactory.basePDI.clone(false, true);
        testPdi.Asset__c = TestDataSalesFactory.baseAsset.Id;
        testPdi.Consumer__c = TestDataBaseFactory.agencyAccount.Id;
        insert testPdi;

        final Id pdiId = testPdi.Id;
        final Id cvId = TestDataBizFactory.baseCV.Id;

        Test.startTest();
            LwsService.IF_KR_SE_LWS_0018(pdiId, cvId);
        Test.stopTest();

    }

    @IsTest static void testBehavior2()  {
        IfStaticValue__c ifStaticValue = TestDataIFCalloutFactory.createIfStaticValue();
        IF_LWS_Base.IfStaticValue(ifStaticValue);

        IF_KR_SE_LWS_0021.OUTPUT_T_DATA t1 = new IF_KR_SE_LWS_0021.OUTPUT_T_DATA();
        t1.ClaimNo = '1';
        t1.AssetNo = TestDataSalesFactory.baseAsset.Name;

        List<IF_KR_SE_LWS_0021.OUTPUT_T_DATA> outputTData = new List<IF_KR_SE_LWS_0021.OUTPUT_T_DATA>{
            new IF_KR_SE_LWS_0021.OUTPUT_T_DATA(), t1
        };

        String outputTDataString = JSON.serialize(outputTData);

        // Mock 객체 세팅
        Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock(
            '{"token":"test111", "Response":{"Header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_LWS_0018","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","ifResult":"S", "IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"Payload":{"TOTAL_RECORD_CNT":"2","t_data":' + outputTDataString + '}}}'
        ));

        WarrantyClaim__c wc = new WarrantyClaim__c();
        insert wc;

        final Id wcId = wc.Id;

        Test.startTest();
        LwsService.IF_KR_SE_LWS_0021(wcId);
        Test.stopTest();
    }

    @IsTest static void testBehavior3()  {
        IfStaticValue__c ifStaticValue = TestDataIFCalloutFactory.createIfStaticValue();
        IF_LWS_Base.IfStaticValue(ifStaticValue);

        // Mock 객체 세팅
        Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock(
            '{"token":"test111", "Response":{"Header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_LWS_0018","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","ifResult":"S", "IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"Payload":{"TOTAL_RECORD_CNT":"2","t_data":[]}}}'
        ));

        WarrantyClaim__c wc = new WarrantyClaim__c();
        insert wc;

        final String assetName = TestDataSalesFactory.baseAsset.Name;
        final String claimNo = wc.ClaimNo__c;
        final Id cvId = TestDataBizFactory.baseCV.Id;

        Test.startTest();
        LwsService.IF_KR_SE_LWS_0022(assetName, claimNo, cvId, '1');
        Test.stopTest();
    }
}