/****************************************************************************************
  * @filename      : LsMSalesProductSearchTractor
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-06-19
  * @group         : 
  * @group-content : 
  * @description   : [모바일]제품검색 - 트랙터(Step업무)
  * @tester        : LsMSalesProductSearchTractor_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-19         i2max          Create
****************************************************************************************/
public with sharing class LsMSalesProductSearchTractor {

    /**
     * [모바일-step업무] 제품검색 - 트랙터
     * 리턴은 LsMSalesStepVO 타입으로 리턴할 것
     *
     * @return LsMSalesStepVO
     */
    @AuraEnabled
    public static LsMSalesStepVO init() {
        LsMSalesProductSearchTractorVO lsMSalesProductSearchTractorVO = new LsMSalesProductSearchTractorVO();
        //============================================================================
        // 필요에 따라서는 초기화 함.
        //============================================================================
        // 1. 업무용
        lsMSalesProductSearchTractorVO.bizData = new LsMSalesProductSearchTractorVO.BizData();
        // 2. 조회용
        lsMSalesProductSearchTractorVO.infoData = new LsMSalesProductSearchTractorVO.InfoData();

        return (LsMSalesStepVO)lsMSalesProductSearchTractorVO;
    }

    /**
     * productType 해당하는 제품시리즈 VO 리스트를 구함
     *
     * @param reqData : produtType 정보
     *
     * @return List<LsMSalesProductSeriesVO>
     */
    @AuraEnabled
    public static List<LsMSalesProductSeriesVO> getProductSeriesVOSForType(final String reqData) {

        System.debug(System.LoggingLevel.INFO, reqData);
        Map<String, String> paramMap = I2ComHelper.gfnCheckCondition(reqData);

        final String productType = (String)paramMap.get('productType');

        return LsMSalesProductService.getProductSeriesVOSForType(productType, '제품사진');
    }

    /**
     * 제품을 구함
     *
     * @deprecated : 단일제품이 아닌 제품리스트 조회로 삭제
     * @param searchProductSeries 조회용 제품시리즈
     *
     * @return Product2
     */
    @AuraEnabled
    public static Product2 getProduct(final ProductSeries__c searchProductSeries) {
        System.debug(System.LoggingLevel.INFO, 'searchProductSeries :' + searchProductSeries);
        return LsMSalesProductService.getProduct(searchProductSeries);
    }

    /**
     * 해달 시리즈의 제품리스트
     *
     * @param searchProductSeries 조회용 제품시리즈
     *
     * @return List<Product2>
     */
    @AuraEnabled
    public static List<Product2> getProducts(final ProductSeries__c searchProductSeries) {
        System.debug(System.LoggingLevel.INFO, 'searchProductSeries :' + searchProductSeries);
        return LsMSalesProductService.getProducts(searchProductSeries);
    }
}