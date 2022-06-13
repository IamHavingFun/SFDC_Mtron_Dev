/****************************************************************************************
  * @filename      : OpptySimpleInfoController_ts
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-09
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-07-09             Park HE         Create
****************************************************************************************/

@IsTest
private class OpptySimpleInfoController_ts {
    @IsTest
    static void testBehavior() {

        Account acc = new Account();
        acc.Name='Test Acc';
        acc.Mobile__c='010-0000-1111';
        acc.Phone='010-0000-1111';
        insert acc;

        Opportunity oppty = new Opportunity(Name = 'Test Oppty', StageName = '1차고객미팅(Discovery)', AccountId = acc.id, CloseDate=System.today());
        insert oppty;

        System.assertNotEquals(OpptySimpleInfoController.getOpptySimpleInfo(oppty.Id), null);
    }
}