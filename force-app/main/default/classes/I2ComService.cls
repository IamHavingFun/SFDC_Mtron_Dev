/****************************************************************************************
  * @filename      : I2ComService
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-03-26 오후 2:05
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : I2ComService_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-03-26 오후 2:05     i2max_my.Seo           Create
****************************************************************************************/

public with sharing class I2ComService {
    /**
     * 단건 처리
     *
     * @param targetObject
     *
     * @return
     */
    public static Map<String, Map<String, String>> gfnGetMultiSObjectLabel(String targetObject) {
        return gfnGetMultiSObjectLabel(new List<String>{targetObject});
    }

    /**
     * 멀티건 처리
     * flag describe 객체 or label
     *
     * @param targetObjectList
     *
     * @return
     */
    public static Map<String, Map<String, String>> gfnGetMultiSObjectLabel(List<String> targetObjectList) {
        Map<String, Map<String, String>> multiFieldResultMap = new Map<String, Map<String, String>>();

        Map<String, Schema.SObjectField> fieldMap;
        System.debug('targetObjectList : ' + targetObjectList);


        List<Schema.DescribeSObjectResult> results = I2ComMetaUtil.getDescribeSObjectResults(targetObjectList);

        Schema.DescribeFieldResult fieldResult;
        String sobjectName;
        String label;

        for(Schema.DescribeSObjectResult result : results) {
            sobjectName = result.getName();
            fieldMap = result.fields.getMap();

            for(String fieldName : fieldMap.keySet()) {
                fieldResult = fieldMap.get(fieldName).getDescribe();
                label = fieldResult.getLabel();

                if(!multiFieldResultMap.containsKey(sobjectName)) {
                    multiFieldResultMap.put(sobjectName, new Map<String, String>{fieldName => label});
                }
                else {
                    multiFieldResultMap.get(sobjectName).put(fieldName, label);
                }
            }
        }

        return multiFieldResultMap;
    }
}