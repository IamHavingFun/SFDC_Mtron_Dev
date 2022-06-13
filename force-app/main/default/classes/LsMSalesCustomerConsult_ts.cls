@IsTest
private class LsMSalesCustomerConsult_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataProductFactory.init();

        LsMSalesCustomerConsultVO.BizData bizData = ((LsMSalesCustomerConsultVO)LsMSalesCustomerConsult.init()).bizData;

        System.assertNotEquals(bizData, null);

        LsMSalesCustomerConsult.CustomerCardData customerCardData = LsMSalesCustomerConsult.getNewCustomerCardData();
        System.assertNotEquals(customerCardData.newPersonAccount, null);
        System.assertNotEquals(customerCardData.newCUPI, null);


        LsMSalesCustomerConsult.FarmInfo farmInfo = LsMSalesCustomerConsult.getFarmingInfo('논');
        System.assertNotEquals(farmInfo.farmingForm, null);

        System.assertNotEquals(LsMSalesCustomerConsult.getFarmingSizeOptions('논'), null);
        System.assertNotEquals(LsMSalesCustomerConsult.getProductSeriesVOS('{"farmingForm":"논", "farmingSize":"0~1만평"}'), null);
        System.assertNotEquals(LsMSalesCustomerConsult.getProduct(TestDataProductFactory.baseProductSeries), null);
        System.assertNotEquals(LsMSalesCustomerConsult.getProducts(TestDataProductFactory.baseProductSeries), null);
        System.assertNotEquals(LsMSalesCustomerConsult.getProductVO(TestDataProductFactory.ProductTractor), null);

        // 기존고객일 경우
        bizData.customerVO.customer = TestDataBaseFactory.personAccount;
        bizData.customerVO.customer.CustomerStatus__c = '';
        bizData.customerVO.customer.FarmingForm__c = '논';
        bizData.customerVO.customer.FarmingArea__c = '0~1만평';
        update bizData.customerVO.customer;
        LsMSalesCustomerConsult.getCustomerDataForGuidedSellingType(bizData.customerVO.customer.Id);

        bizData.productVO.product = TestDataProductFactory.ProductTractor;
        bizData.strCloseDate = String.valueOf(TestDataUtilFactory.d);
        System.assertNotEquals(LsMSalesCustomerConsult.consultSave(bizData), null);

        // 신규 고객일 경우
        LsMSalesCustomerConsultVO.BizData bizData1 = ((LsMSalesCustomerConsultVO)LsMSalesCustomerConsult.init()).bizData;
        bizData1.customerVO.customer = TestDataBaseFactory.personAccount.clone(false, true);
        bizData1.customerVO.customer.PersonMobilePhone = '010-1111-2222';
        bizData1.productVO.product = TestDataProductFactory.ProductTractor;//TestDataProductFactory.ProductTractor.clone(false, true);
        bizData1.strCloseDate = String.valueOf(TestDataUtilFactory.d);
        System.debug(JSON.serializePretty(bizData1));
        System.assertNotEquals(LsMSalesCustomerConsult.consultSave(bizData1), null);


        LsMSalesCustomerConsult.getDefaultData('논', '', 'A');
    }
}