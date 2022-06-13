@IsTest
private class Order_tr_ts {

    @IsTest
    static void testBehavior() {

        Order__c updateOrderForPer = TestDataSalesFactory.orderForPerFarCorp;
        updateOrderForPer.Status__c               = '영업소 주문 확정';
        updateOrderForPer.TransferMachineNo__c    = TestDataSalesFactory.baseAsset.Id;

        update updateOrderForPer;

        updateOrderForPer.Status__c = '종료';
        updateOrderForPer.isOrderCancel__c = true;

        update updateOrderForPer;

        // createOQCAllRecord
        OrderLineitem__c orderLineitem = TestDataSalesFactory.oliForNhGov.clone(false, true);
        orderLineitem.OrderId__c = TestDataSalesFactory.orderForNhGov.Id;

        insert orderLineitem;

        TestDataSalesFactory.orderForNhGov.Status__c = '영업소 주문 확정';

        update TestDataSalesFactory.orderForNhGov;
        update TestDataSalesFactory.orderForNhGov;

        User testUser = TestDataBaseFactory.businessOfficeUser.clone(false, true);

        testUser.Username  = 'testUsr@user.test.kr';
        testUser.ProfileId = TestDataUtilFactory.getProfileId('Korea Sales Users');

        insert testUser;

        Order__c updateOrderForAP = TestDataSalesFactory.orderForPerFarCorp;
        // 승인 관련
        updateOrderForAP.LoanApprovalStatus__c = '승인';
        updateOrderForAP.ErpZLNST__c           = 'A';
        updateOrderForAP.ErpLRESN_T__c         = 'test';
        updateOrderForAP.ErpLPLAN_T__c         = 'test';
        updateOrderForAP.ErpLFDBK_T__c         = 'test';

        updateOrderForAP.LoanApprover1__c      = TestDataBaseFactory.businessOfficeUser.Id;
        updateOrderForAP.LoanApprover1_1__c    = TestDataBaseFactory.businessOfficeUser.Id;

        User loanAppUsr2 = TestDataBaseFactory.businessOfficeUser.clone(false, true);
        loanAppUsr2.Username = 'loanAppUsr2@user.co.kr';

        insert loanAppUsr2;

        updateOrderForAP.LoanApprover2__c      = loanAppUsr2.Id;
        updateOrderForAP.LoanApprover2_1__c    = loanAppUsr2.Id;

        update updateOrderForAP;

        OrderApprover__c orderApprover = new OrderApprover__c(
                OrderSellIn__c = updateOrderForPer.Id,
                ExternalKey__c = 'test'
        );

        insert orderApprover;

        System.runAs(testUser) {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(updateOrderForPer.Id);
            request.setSubmitterId(updateOrderForPer.LoanApprover2__c);
            request.setProcessDefinitionNameOrId('LoanApprovalRequest');
            request.setSkipEntryCriteria(true);

            Approval.ProcessResult result = Approval.process(request);
        }
    }

/*    @IsTest
    static void testBehavior2() {



        Order__c updateOrderForPer = TestDataSalesFactory.orderForPerFarCorp;
        // 승인 관련
        updateOrderForPer.LoanApprovalStatus__c = '승인';
        updateOrderForPer.ErpZLNST__c           = 'A';
        updateOrderForPer.ErpLRESN_T__c         = 'test';
        updateOrderForPer.ErpLPLAN_T__c         = 'test';
        updateOrderForPer.ErpLFDBK_T__c         = 'test';

        updateOrderForPer.LoanApprover1__c      = TestDataBaseFactory.businessOfficeUser.Id;
        updateOrderForPer.LoanApprover1_1__c    = TestDataBaseFactory.businessOfficeUser.Id;

        User loanAppUsr2 = TestDataBaseFactory.businessOfficeUser.clone(false, true);
        loanAppUsr2.Username = 'loanAppUsr2@user.co.kr';

        insert loanAppUsr2;

        updateOrderForPer.LoanApprover2__c      = loanAppUsr2.Id;
        updateOrderForPer.LoanApprover2_1__c    = loanAppUsr2.Id;

        update updateOrderForPer;

        OrderApprover__c orderApprover = new OrderApprover__c(
                OrderSellIn__c = updateOrderForPer.Id,
                ExternalKey__c = 'test'
        );

        insert orderApprover;

        System.runAs(testUser) {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(updateOrderForPer.Id);
            request.setSubmitterId(updateOrderForPer.LoanApprover2__c);
            request.setProcessDefinitionNameOrId('LoanApprovalRequest');
            request.setSkipEntryCriteria(true);

            Approval.ProcessResult result = Approval.process(request);
        }
    }*/
}