/****************************************************************************************
 * @filename      : LsMSalesQuestionImprove
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-06-17 오후 4:00
 * @group         :
 * @group-content :
 * @description   : [모바일] 질문/개선
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-17 오후 4:00        SEOKHO LEE          Create
 ****************************************************************************************/

public with sharing class LsMSalesQuestionImprove {

    /**
     * 검색
     *
     * @param reqData
     * @param pageSize
     * @param pageNumber
     *
     * @return
     */
    @AuraEnabled
    public static I2ComClass.ResData search(String reqData, Integer pageSize, Integer pageNumber) {

        String whereClause = '';
        Map<String, String> paramMap = I2ComHelper.gfnCheckCondition(reqData);

        String searchStatus = paramMap.get('searchStatus');

        if (I2ComHelper.gfnHasCondition(paramMap, 'searchStatus')) {
            if('Progress'.equals(searchStatus)) {
                whereClause += ' AND Status != \'완료\' \n';
            } else if('Completed'.equals(searchStatus)) {
                whereClause += ' AND Status = \'완료\' \n';
            } else {
                // All - 전체 검색
                // Do not thing
            }

        }

        whereClause = I2ComHelper.gfnRefineCondition(whereClause);
        System.debug('whereClause : ' + whereClause);

        I2ComClass.ResData resData = I2ComHelper.gfnQuery(
                'Id, Subject, Status, CreatedDate, fm_Date__c',
                'Case',
                whereClause,
                'ORDER BY LastModifiedDate DESC ',
                pageSize,
                pageNumber
        );
        return resData;

    }

    /**
     * search가 아닌 다른 메소드명 호출 테스트
     * client controller 와 Name이 동일하면 안됨
     *
     * @param reqData
     * @param pageSize
     * @param pageNumber
     *
     * @return
     */
    @AuraEnabled
    public static I2ComClass.ResData getSearch(String reqData, Integer pageSize, Integer pageNumber) {
        return search(reqData, pageSize, pageNumber);
    }

}