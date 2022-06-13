/****************************************************************************************
  * @filename      : LsMSalesCustomerConsultVO
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-06-05
  * @group         : 
  * @group-content : 
  * @description   : [모바일]고객상담 VO
  * @tester        : LsMSalesCustomerConsultVO_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-05         i2max          Create
****************************************************************************************/
public with sharing class LsMSalesCustomerConsultVO implements LsMSalesStepVO {

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
        // target search 제품
        // 제품 조회용
        @AuraEnabled public ProductSeries__c searchProductSeries {get;set;}
        @AuraEnabled public List<I2ComClass.Option> accountRecordTypeList {get;set;}
        @AuraEnabled public List<I2ComClass.Option> accountCustomerTypeList {get;set;}
    }

    /*
     * ================================================================
     * 이 하위는 업무에 맞게 구현함.
     * 기본 생성자 외 별도 생성자 구현 불가.
     * 초기화 로직은 업무단 시작의 init 함수에서 할것 : LsMSalesCustomerConsult Class의 init
     * ================================================================
     */
    @AuraEnabled public BizData bizData {get;set;}

    /*
     * ================================================================
     * 외부 class의 inner class 가 존재할 경우 client -> server에서 serialize 에러가 발생
     * 따라서 LsMSalesProductVO.ProductOptionVO 는 정보성 이므로 별도 분리
     * ================================================================
     */
    public class BizData {
        /*
         * ================================================================
         * 선택을 위한 고객 선택 항목
         * 비즈니스 로직을 위한 선택항목 변수들
         * ================================================================
         */
        // 가이드 선택 유형
        @AuraEnabled public String guidedSellingType {get;set;}
        // 선택 제품시리즈 추천
        @AuraEnabled public ProdSerRecStd__c prodSerRecStd {get;set;}
        // 선택 제품시리즈 VO
        @AuraEnabled public LsMSalesProductSeriesVO productSeriesVO {get;set;}
        // 선택 제품 VO
        @AuraEnabled public LsMSalesProductVO productVO {get;set;}
        // 선택 고객 VO
        @AuraEnabled public LsMSalesCustomerVO customerVO {get;set;}
        // 희망 구매일
        @AuraEnabled public String strCloseDate {get;set;}
        // 핸드폰 인증 완료 여부
        @AuraEnabled public Boolean isAuthenticated {get;set;}
    }

}