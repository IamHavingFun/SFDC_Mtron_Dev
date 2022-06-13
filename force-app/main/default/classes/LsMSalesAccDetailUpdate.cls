/****************************************************************************************
  * @filename      : LsMSalesAccDetailUpdate
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-08-28 오후 5:50
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesAccDetailUpdate_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-08-28 오후 5:50     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class LsMSalesAccDetailUpdate {
    @AuraEnabled
    public static Boolean checkDate(String customerDate) {
        Boolean isValid = true;

        if(customerDate != null) {
            List<String> dateList = customerDate.split('-');

            Date targetDt = Date.newInstance(Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]), Integer.valueOf(dateList[2]));

            if(Integer.valueOf(dateList[1]) != targetDt.month()) {
                isValid = false;
            }
        }

        return isValid;
    }
}