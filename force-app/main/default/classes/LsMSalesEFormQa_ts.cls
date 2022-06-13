/****************************************************************************************
 * @filename      : LsMSalesEFormQa_ts
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-07-09 오후 02:04
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright ⓒ I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-07-09 오후 02:04      i2max_my.Seo         Create
 0.2     2020-08-04 오후 02:55      Park_JW              리스부분 업데이트
 ****************************************************************************************/

@IsTest
private class LsMSalesEFormQa_ts {

    @TestSetup
    static void setup() {
        /*
         * ================================================================
         * 필요시 IF_INFO__c 객체의 데이터를 변경하여 insert 할것
         * one transaction 처리 때문에 TestSetup 에서 insert 할것
         * ================================================================
         */
        IF_INFO__c ifInfo = TestDataIFCalloutFactory.createIFInfo();
        ifInfo.IF_ID__c     = 'IF_KR_SE_eform_0024';
        ifInfo.URL__c       = '/api/dev/IF_KR_SE_eform_0024.json';

        insert ifInfo;
    }
    @IsTest
    static void testBehavior() {
        IfStaticValue__c ifStaticValue = TestDataIFCalloutFactory.createIfStaticValue();
        ifStaticValue.Name                  = 'LSMTRON';
        ifStaticValue.ENCRYPT_ALGORITHM__c  = 'AES128';
        ifStaticValue.dihAesKey__c          = '1234567890123456';
        ifStaticValue.dihAesInitVector__c   = '1234567890123456';

        insert ifStaticValue;

        Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock(
            '{"response":{"payload":{"ifAggregation":"Test Request","ifSplitSeq":"","ifSplitCnt":"","ifTotCnt":"","t_data":[{"API_URL":"https://kr-api.eformsign.com","ACCESS_TOKEN":"eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJlZm9ybXNpZ24uaWFtIiwiY29udGV4dCI6eyJjbGllbnRJZCI6IjY4MDk0ZWVhMjVhZjRhNjI5ZTI4ZGU5Y2ZlYzRlYmZjIiwiY2xpZW50S2V5IjoiZTNiM2IzZTUtMGEzMS00NTE1LWE5NzEtN2M4Y2FlNDI4NzZmIiwibWFuYWdlbWVudElkIjoiMzRhYWI4MDBjMmEwNDQwNThmZDRlZjc5OGFlY2RlY2EiLCJzY29wZXMiOiJzbWFydF9lZm9ybV9zY29wZSIsInR5cGUiOiJ1c2VyIiwidXNlck5hbWUiOiI3YmY4NTQ5MS03N2Q1LTRlMTEtYTdlMS1lNjRjMDY4ZjQxOWMiLCJ1c2VySWQiOiJkZGVkYzU5NDI5MmM0OTQwOWJlNjZmMGUzM2M1NjIxNiIsInJlZnJlc2hUb2tlbiI6ImI5MDIzZDE4LTAyYjctNDA5Yi04ZjJlLWU3M2MwY2MxMTM5YyJ9LCJjbGFpbSI6eyJjb21wYW55X2lkIjoiMzI4NTgzY2FmYWU2NDZlNWEzZTZiZjliMjUwNDFkMzIiLCJhY2Nlc3Nfa2V5IjoiN2JmODU0OTEtNzdkNS00ZTExLWE3ZTEtZTY0YzA2OGY0MTljIn0sImV4cCI6MTU5NDA4Nzk2OCwiaWF0IjoxNTk0MDg0MzY4fQ.BjIp0KGIw48ejQcenVDk9t0wEYHOBfxTBOmZFX0-Drk33IHmdYsEd9Ywvt7PArlKDt9vaQXtjQID7Inj6GcFHriPNobPVcsJs7b2Z4aaVpTLy4IrFng4gnzji4ZveVv9TaFx421HUqtCBdbPo5JCq7xHfsuQHKS7pYTk7gP_ybE","REFRESH_TOKEN":"b9023d18-02b7-409b-8f2e-e73c0cc1139c"}]},"header":{"ifDateTime":"20200609034311","ifReceiverGp":"LSMTRON","ifResult":"S","ifTrackingId":"","ifReceiver":"SE","ifId":"IF_KR_SE_eform_0024","ifFailCode":"","ifSenderGp":"LSMTRON","ifFailMsg":"","ifSender":"eform"}}}')
        );

        //============================================================================
        // TestDataSalesFactory static 변수 생성시 dml 작업이 들어가기에
        // 모든 항목들은 로컬 변수로 별도 할당하여 처리하고
        // 실제 callout 부분은 Test.startTest(); 사이에 로직 수행처리함.
        //============================================================================
        Contract__c baseContract = TestDataSalesFactory.baseContract;
        baseContract.eFormsignStatus__c = '계약체결';
        final Id contractId = TestDataSalesFactory.baseContract.Id;
        String dealerSignPng = 'dealerSignPng,dealerSignPng';
        String customerSignPng = 'customerSignPng,customerSignPng';
        Test.startTest();
            LsMSalesEFormQa.init(contractId);
            LsMSalesEFormQa.getServiceExecute(contractId);
            LsMSalesEFormQa.setReview(contractId);
            LsMSalesEFormQa.signSave(contractId, dealerSignPng, customerSignPng);
            LsMSalesEFormQa.pdfSave(contractId);
        Test.stopTest();

        ContractLineItem__c cli = TestDataSalesFactory.baseCli;
        cli.ProductId__c = TestDataProductFactory.baseProduct2.Id;
        update cli;
        LsMSalesEFormQa.successSave(baseContract);
    }

}