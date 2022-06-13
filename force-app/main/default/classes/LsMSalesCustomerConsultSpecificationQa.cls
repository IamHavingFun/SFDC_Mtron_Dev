/****************************************************************************************
  * @filename      : LsMSalesCustomerConsultSpecificationQa
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-06-30
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesCustomerConsultSpecificationQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-30         i2max          Create
****************************************************************************************/
public with sharing class LsMSalesCustomerConsultSpecificationQa {

    /**
     * 제품시리즈ID 로 제품제원표의 제품컨텐츠를 구함
     * @param productSeriesId 제품시리즈ID
     *
     * @return LsMSalesProductSeriesVO
     */
    @AuraEnabled
    public static LsMSalesProductSeriesVO getProductSeriesVOSSpecifications(Id productSeriesId) {
        return LsMSalesProductService.getProductSeriesVOSForId(productSeriesId, '제품제원표')[0];
    }
}