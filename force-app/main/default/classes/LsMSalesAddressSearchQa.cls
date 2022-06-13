/****************************************************************************************
  * @filename      : LsMSalesAddressSearchQa
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-06-30 오후 5:14
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesAddressSearchQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-06-30 오후 5:14     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class LsMSalesAddressSearchQa {
    private static final String KEY = System.Label.AddressSearch_ApiKeySet;
    // url
    private static final String URL = System.Label.AddressSearch_ApiUrlSet;
    // 데이터 반환 타입
    private static final String RETURN_TYPE = 'json';

    /**
    * init : 최초호출(주소 검색 쿼리)
    * @param recordId : 레코드 ID
    * @return
    */
    @AuraEnabled
    public static AddressInfoWrapper init(){
//        String sObjectName = findObjectNameFromRecordIdPrefix(recordId);
        List<String> sobjectTypeKeys = new List<String>{'Account'};
        AddressInfoWrapper bw = new AddressInfoWrapper(); // Aura Return Wrapper

//        bw.sObjectName = sObjectName;
        bw.sObjectName = 'Account';
        bw.sobjectTypeLabelMap = getLabels(sobjectTypeKeys, true, '\\(.*\\)');

        return bw;
    }

    /**
    * search : 주소검색
    * @param pageSize : 출력 할 페이지의 사이즈
    * @param pageNumber : 페이지 번호
    * @param searchTerm : 검색어
    * @return Object
    */
    @AuraEnabled
    public static Object search(Integer pageSize, Integer pageNumber, String searchTerm){
        return call(pageSize, pageNumber, searchTerm);
    }

    /**
    * call : API 호출
    * @param pageSize : 출력 할 페이지의 사이즈
    * @param pageNumber : 페이지 번호
    * @param searchTerm : 검색어
    * @return Object
    */
    private static Object call(Integer pageSize, Integer pageNumber, String searchTerm){
        String pSize = String.valueOf(Integer.valueOf(pageSize));
        String pNumber = String.valueOf(Integer.valueOf(pageNumber));
        String result;
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(makeUrl(pSize, pNumber, searchTerm));
            req.setMethod('GET');
            req.setHeader('Accept', '*/*');
            HTTPResponse res = http.send(req);
            result = res.getBody();
            System.debug('@@@@@@@@@@@@@ result : ' + result);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.deserializeUntyped(result);
    }

    /**
    * makeUrl : 최종 URL을 생성한다
    * @param pageSize : 출력 할 페이지의 사이즈
    * @param pageNumber : 페이지 번호
    * @param searchTerm : 검색어
    * @return String
    */
    private static String makeUrl(String pageSize, String pageNumber, String searchTerm){
        String resultUrl = URL + 'currentPage=' + pageNumber + '&countPerPage='+pageSize+'&keyword='+EncodingUtil.urlEncode(searchTerm,'UTF-8')+'&confmKey='+EncodingUtil.urlEncode(KEY,'UTF-8')+'&resultType='+RETURN_TYPE;
        return resultUrl;
    }

    /**
    * findObjectNameFromRecordIdPrefix : Record ID로 Object명 조회
    * @param recordIdOrPrefix : Record ID
    * @return String
    */
//    private static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
//        String objectName = '';
//        try{
//            //Get prefix from record ID
//            //This assumes that you have passed at least 3 characters
//            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
//
//            //Get schema information
//            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();
//
//            //Loop through all the sObject types returned by Schema
//            for(Schema.SObjectType stype : gd.values()){
//                //if (!sObj.contains('__')) to exclude managed package objects
//                Schema.DescribeSObjectResult r = stype.getDescribe();
//                String prefix = r.getKeyPrefix();
//                System.debug('Prefix is ' + prefix);
//
//                //Check if the prefix matches with requested prefix
//                if(prefix!=null && prefix.equals(myIdPrefix)){
//                    objectName = r.getName();
//                    //System.debug('Object Name! ' + objectName);
//                    break;
//                }
//            }
//        }catch(Exception e){
//            System.debug(e);
//        }
//        return objectName;
//    }

    /**
    * getLabels : Object & Field Label 가져오기
    * @param sobjectTypeKeys : Object API Name(List<String>)
    * @param patternYn : Replace Pattern 적용 여부
    * @param patternType : Replace Pattern 정규식
    * @return Map
    */
    private static Map<String, Object> getLabels(List<String> sobjectTypeKeys, boolean patternYn, String patternType) {
        Map<String, SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType sobjType;
        Map<String, SObjectField> fieldMap;
        Map<String, String> fieldLabelMap = new Map<String, String>();
        Map<String, Object> sobjectTypeLabelMap = new Map<String, Object>();
        Pattern nonWordChar = Pattern.compile(patternType);

        for(Object key : sobjectTypeKeys) {
            sobjType = schemaMap.get((String)key);
            System.debug('@@@@@@@@@@@@@sobjType : ' + sobjType);
            fieldMap = sobjType.getDescribe().fields.getMap();
            for (String fieldName: fieldMap.keySet()) {
                System.debug((String)key+':'+fieldName+':'+nonWordChar.matcher(fieldMap.get(fieldName).getDescribe().getLabel()).replaceAll(''));
                if(patternYn) fieldLabelMap.put(fieldName,nonWordChar.matcher(fieldMap.get(fieldName).getDescribe().getLabel()).replaceAll(''));
                else fieldLabelMap.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
            }
            sobjectTypeLabelMap.put((String)key, fieldLabelMap);
        }
        return sobjectTypeLabelMap;
    }

    /**
    * AddressInfoWrapper : Object Name, Record, Label Map
    */
    public class AddressInfoWrapper {
        @AuraEnabled public String sObjectName {get;set;}
//        @AuraEnabled public SObject data {get;set;}
        @AuraEnabled public Map<String, Object> sobjectTypeLabelMap  {get;set;}
    }
}