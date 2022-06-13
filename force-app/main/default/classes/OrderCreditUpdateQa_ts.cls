/**
** @filename     : OrderCreditUpdateQa_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-09-07 오후 3:17
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
private class OrderCreditUpdateQa_ts {
    @IsTest
    static void testBehavior() {
        Order__c order = new Order__c();
        insert order;

        OrderLineitem__c oli = new OrderLineitem__c();
        oli.OrderId__c = order.Id;
        insert oli;

        OrderCreditUpdateQa.init(order.Id);
        OrderCreditUpdateQa.save(order);


        OrderCreditUpdateQa.call_IF_KR_SE_ERP_0040(order, 'I');


    }
}