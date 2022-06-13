/****************************************************************************************
  * @filename      : I2ComHelper
  * @projectname   : LWC_I2MAX
  * @author        : i2max_ms 
  * @date          : 2020-03-10 오전 7:33
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : I2ComHelper_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-03-10 오전 7:33     i2max_ms            Create
****************************************************************************************/

public with sharing class I2ComHelper {
    /**
     * 페이징 처리
     *
     * @param obj
     * @param fields
     * @param condition
     * @param sortFilter
     * @param pageSize
     * @param pageNumber
     *
     * @return
     */
    public static I2ComClass.ResData gfnQuery(String fields, String obj, String condition, String sortFilter, Integer pageSize, Integer pageNumber){

        String query = ' SELECT ' + fields + '\n';
        query += ' FROM ' + obj + '\n';
        if (String.isNotBlank(condition)) query += ' ' + condition + '\n';
        if (String.isNotBlank(sortFilter)) query += ' ' + sortFilter + '\n';

        // 오프셋
        query += gfnOffset(pageSize, pageNumber);

        // ================================================================================================
        // 총 건수
        // 어차피 5만개가 넘는 이상 카운트를 하는건 그다지 의미가 없다
        // 망한 코드니까 다른 방법을 생각해보자
        // ================================================================================================

        System.debug(System.LoggingLevel.INFO, query);

        return new I2ComClass.ResData(gfnCount(obj, condition), Database.query(query));
    }

    /**
     * 내부적으로 페이징 처리없이 모든 데이터 추출
     *
     * @param fields
     * @param obj
     * @param condition
     * @param sortFilter
     *
     * @return
     */
    public static I2ComClass.ResData gfnQueryNoPaging(String fields, String obj, String condition, String sortFilter){
//        I2ComClass.ResData resData = new I2ComClass.ResData();

        String query = ' SELECT ' + fields + '\n';
        query += ' FROM ' + obj + '\n';
        if (String.isNotBlank(condition)) query += ' ' + condition + '\n';
        if (String.isNotBlank(sortFilter)) query += ' ' + sortFilter + '\n';
        query += ' LIMIT 50000';

        System.debug(System.LoggingLevel.INFO, query);

//        resData.totalSize = 0;
//        resData.recordList = Database.query(query);

        return new I2ComClass.ResData(0, Database.query(query));
    }

    /**
     * 총건수 조회
     *
     * @param obj
     * @param condition
     *
     * @return
     */
    public static Integer gfnCount(String obj, String condition){
        String query = 'SELECT Count() FROM ' + obj + ' ' + (String.isBlank(condition) ? '' : ' ' + condition) + ' LIMIT 50000';
        return Database.countQuery(query);
    }

    /**
     * Paging Offset 구문 설정
     *
     * @param pageSize
     * @param pageNumber
     *
     * @return
     */
    public static String gfnOffset(final Integer pageSize, final Integer pageNumber){
        Integer ps = Integer.valueOf(pageSize);
        Integer pn = Integer.valueOf(pageNumber)-1;
        String offset = String.valueOf(ps * pn);

        String query = ' LIMIT '+ String.valueOf(ps);
        query += ' OFFSET ' + offset;
        return query;
    }

    /**
     * 검색조건의 String을 Map으로 변환
     *
     * @param searchTerm
     *
     * @return
     */
    public static Map<String, String> gfnCheckCondition(final String reqData){
        Map<String, String> paramMap = new Map<String, String>();

        if(String.isNotBlank(reqData)){
            System.debug(System.LoggingLevel.INFO, JSON.serializePretty(paramMap));
            paramMap = (Map<String, String>)JSON.deserialize(reqData, Map<String, String>.class);
        }

        return paramMap;
    }

    /**
     * 검색조건 항목 존재 여부
     *
     * @param paramMap
     * @param cond
     *
     * @return
     */
    public static Boolean gfnHasCondition(final Map<String, String> paramMap, final String cond){
        return String.isNotBlank(paramMap.get(cond));
    }


    public static String gfnRefineCondition(String condition){
        return condition.startsWith(' AND') ? ' WHERE ' + condition.removeStart(' AND') : condition;
    }
}