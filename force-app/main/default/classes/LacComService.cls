/****************************************************************************************
  * @filename      : LacComService
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-03-26 오후 2:07
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LacComService_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-03-26 오후 2:07     i2max_my.Seo           Create
****************************************************************************************/

public with sharing class LacComService {
    
    @AuraEnabled
    public static Map<String, Map<String, String>> getSobjectData(List<String> targetObjectList) {
        System.debug('targetObjectList : ' + targetObjectList);
        Map<String, Map<String, String>> resultFieldLabelMap = new Map<String, Map<String, String>>();

        resultFieldLabelMap = I2ComService.gfnGetMultiSObjectLabel(targetObjectList);
        System.debug('resultFieldLabelMap : ' + JSON.serializePretty(resultFieldLabelMap));
        return resultFieldLabelMap;
    }
}