/****************************************************************************************
  * @filename      : LsMSalesProductSearchTractorVO
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-06-19
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesProductSearchTractorVO_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-19         i2max          Create
****************************************************************************************/
public with sharing class LsMSalesProductSearchTractorVO implements LsMSalesStepVO {

    @AuraEnabled public InfoData infoData {get;set;}

    /*
     * ================================================================
     * 이 하위는 업무에 맞게 구현함.
     * 정보성 데이터는 여기에 구현할 것
     * 최종 저장과는 관련이 없는 단순 정보성 데이터 구조
     * ================================================================
     */
    public class InfoData {
        /*
         * ================================================================
         * 선택을 위한 고정값
         * ================================================================
         */
        // 제품 조회용
        @AuraEnabled public ProductSeries__c searchProductSeries {get;set;}
    }

    /*
     * ================================================================
     * 이 하위는 업무에 맞게 구현함.
     * 기본 생성자 외 별도 생성자 구현 불가.
     * 초기화 로직은 업무단 시작의 init 함수에서 할것 : LsMSalesCustomerConsult Class의 init
     * ================================================================
     */
    @AuraEnabled public BizData bizData {get;set;}

    public class BizData {
        // 제품선택 ProductType
        @AuraEnabled public String productType {get;set;}
        // 선택 제품시리즈 VO
        @AuraEnabled public LsMSalesProductSeriesVO productSeriesVO {get;set;}
        // 선택 제품 VO
        @AuraEnabled public LsMSalesProductVO productVO {get;set;}
    }
}