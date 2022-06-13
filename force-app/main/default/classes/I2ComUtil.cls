/****************************************************************************************
  * @filename      : I2ComUtil
  * @projectname   : LWC_I2MAX
  * @author        : i2max_my.Seo
  * @date          : 2020-03-10 오전 7:28
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : I2ComUtil_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-03-10 오전 7:28     i2max_ms             Create
****************************************************************************************/

public with sharing class I2ComUtil {
    /**
     * 선택목록 반환
     *
     * @param obj
     * @param field
     *
     * @return
     */
    public static List<Schema.PicklistEntry> getPickList(final String obj, final String field){
        return (((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType())
                .getDescribe().fields.getMap().get(field).getDescribe().getPickListValues();
    }

    /**
     * SObject의 Field 를 이용한 Select Options 생성
     *
     * @param obj
     * @param field
     *
     * @return
     */
    public static List<I2ComClass.Option> makePickListOptions(final String obj, final String field){
        return makePickListOptions(obj, field, false);
    }

    public static List<I2ComClass.Option> makePickListOptions(final String obj, final String field, final Boolean notBlank){
        return makePickListOptions(obj, field, notBlank, false);
    }

    public static List<I2ComClass.Option> makePickListOptions(final String obj, final String field, final Boolean notBlank, final Boolean isSelectAll){
        return   makePickListOptions(obj, field, notBlank, isSelectAll, null);
    }

    public static List<I2ComClass.Option> makePickListOptions(final String obj, final String field, final Boolean notBlank, final Boolean isSelectAll, final Set<String> excludes){
        List<I2ComClass.Option> tmpList = makeInitOptions( (isSelectAll ? '-- 전체 --' : null), notBlank);
        for(Schema.PicklistEntry pick : getPickList(obj, field)) {
            if(excludes == null) {
                tmpList.add(new I2ComClass.Option(pick.getLabel(), pick.getValue()));
            }
            else {
                if(excludes.contains(pick.getValue()) == false) {
                    tmpList.add(new I2ComClass.Option(pick.getLabel(), pick.getValue()));
                }
            }
        }
        return tmpList;
    }

    /**
     * Select Option의 기본값을 세팅하여 리턴
     *
     * @param selectAllComment 처음 all comment
     *
     * @return List<I2ComClass.Option>
     */
    public static List<I2ComClass.Option> makeInitOptions(final String selectAllComment){
        return makeInitOptions(selectAllComment, false);
    }

    public static List<I2ComClass.Option> makeInitOptions(final String selectAllComment, final Boolean notBlank){
        List<I2ComClass.Option> tmpOptions = new List<I2ComClass.Option>();
        if(notBlank == false) {
            tmpOptions.add(new I2ComClass.Option(String.isNotBlank(selectAllComment) ? selectAllComment : '--None--', ''));
        }
        return tmpOptions;
    }

    /**
     * SObject의 필드 타입을 구하기.
     *
     * @param objectName
     * @param fieldName
     *
     * @return
     */
    public static String getFieldType(final String objectName, final String fieldName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getType().name();
    }

    /**
     * 로그인 org의 Community Site의 pathPrefix를 구함
     * @return String
     */
    public static String getSitePathPrefix() {
        List<String> path = Site.getPathPrefix().split('/');
        return !path.isEmpty() && path.size() > 1 ? path[1] : null;
    }

    /**
     * 특정 SObject의 RecordTypeId를 구함. :developerName 기준
     *
     * @param sobjectType SObject API
     * @param developerName recordType API
     *
     * @return Id
     */
    public static Id getRecordType(String sobjectType, String developerName) {

        Map<String, Map<String, Id>> recordtypesBySObject = new Map<String, Map<String,Id>>();

        for(RecordType rt : [
            SELECT Id, DeveloperName, SobjectType
            FROM RecordType
            WHERE SobjectType = :sobjectType
        ]){
            sobjectType = rt.SobjectType;
            if(recordtypesBySObject.containsKey(sobjectType) == true) {
                recordtypesBySObject.get(sobjectType).put(rt.DeveloperName, rt.Id);
            }
            else {
                recordtypesBySObject.put(sobjectType, new Map<String, Id>{rt.DeveloperName => rt.Id});
            }
        }

        return recordtypesBySObject.get(sobjectType).get(developerName);
    }

}