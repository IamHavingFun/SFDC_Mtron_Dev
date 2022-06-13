/**
** @filename     : orderLoanApprovalRequestQa_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-21 오후 4:51
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
private class orderLoanApprovalRequestQa_ts {
    @IsTest
    static void testBehavior() {
        TestDataSalesFactory.init();

        orderLoanApprovalRequestQa.InitData initData = orderLoanApprovalRequestQa.init(TestDataSalesFactory.orderForPerFarCorp.Id);

        System.assertNotEquals(initData.isApprovalRequest,null);

        orderLoanApprovalRequestQa.submitForApproval(TestDataSalesFactory.orderForNhGov.Id);
    }
}