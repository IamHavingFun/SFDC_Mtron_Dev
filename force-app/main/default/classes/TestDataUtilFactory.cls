/****************************************************************************************
  * @filename      : TestDataUtilFactory
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-16 오후 1:27
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-16 오후 1:27     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
public class TestDataUtilFactory {
    final public static Datetime dt = System.now();
    final public static Date d = dt.date();

    final public static Map<String, Id> profiles = new Map<String, Id>();
    final public static Map<String, Map<String, Id>> recordTypesBySObject = new Map<String, Map<String,Id>>();

    static {
        //-------------------------------------------------------  -----------------------
        //  모든 프로필 세팅
        //------------------------------------------------------------------------------
        for(Profile pf : [SELECT Id, Name FROM Profile]) {
            profiles.put(pf.Name, pf.Id);
        }
        //------------------------------------------------------------------------------
        //  각 SObject별 RecordType Map을 세팅
        //------------------------------------------------------------------------------
        String sobjectType;
        for(RecordType rt : [SELECT Id, DeveloperName, SobjectType FROM RecordType]){
            sobjectType = rt.SobjectType;
            if(recordTypesBySObject.containsKey(sobjectType) == true) {
                recordTypesBySObject.get(sobjectType).put(rt.DeveloperName, rt.Id);
            }
            else {
                recordTypesBySObject.put(sobjectType, new Map<String, Id>{rt.DeveloperName => rt.Id});
            }
        }
    }

    public static Id getProfileId(String pfName) {
        return profiles.get(pfName);
    }

    public static Id getRecordTypeId (String sojectName, String devName) {
        return recordTypesBySObject.get(sojectName).get(devName);
    }
}