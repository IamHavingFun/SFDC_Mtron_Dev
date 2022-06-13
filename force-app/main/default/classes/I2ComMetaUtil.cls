/****************************************************************************************
  * @filename      : I2ComMetaUtil
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-03-26 오후 2:05
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : I2ComMetaUtil_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-03-26 오후 2:05     i2max_my.Seo           Create
****************************************************************************************/

public with sharing class I2ComMetaUtil {
    /**
     * @description SObject 명에 해당 하는 field 정보를 return. (다국어 지원을 위한 용도)
     *
     * @param targetObject Account
     *
     * @return List<Schema.DescribeSobjectResult>
     */
    public static List<Schema.DescribeSObjectResult> getDescribeSObjectResults(String targetObject) {
        return getDescribeSObjectResults(new List<String>{targetObject});
    }

    /**
     * @description SObject List에 해당 하는 field 정보를 return. (다국어 지원을 위한 용도)
     *
     * @param targetObjectList ['Account', 'Contact']
     *
     * @return List<Schema.DescribeSobjectResult>
     */
    public static List<Schema.DescribeSObjectResult> getDescribeSObjectResults(List<String> targetObjectList) {
        List<Schema.DescribeSObjectResult> results = Schema.describeSObjects(targetObjectList);

        return results;
    }
}