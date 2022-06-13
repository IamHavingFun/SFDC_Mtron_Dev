/**
** @filename     : 
* @projectname   :
* @author        : 
* @date          : 
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
private class  LsMSalesNotice_ts{
    @IsTest
    static void testBehavior() {

        LsMSalesNotice.getsearch('{"PostDate__c":"0000-00-00"}', 5, 1);


    }
}