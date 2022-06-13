/****************************************************************************************
  * @filename      : OpptyNewQa
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-04-14 오전 10:02
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OpptyNewQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-04-14 오전 10:02     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class OpptyNewQa {

    @AuraEnabled
    public static String save(Opportunity oppty) {
        oppty.Name = LsMSalesQCService.getOpptyName(oppty.Account.LastName, oppty.InterestModel__r.Name, ((Datetime)oppty.CloseDate).format('yyyyMMdd'));
        oppty.StageName = '상담';

        if(oppty != null)   insert oppty;
        
        return oppty.Id;
    }
}