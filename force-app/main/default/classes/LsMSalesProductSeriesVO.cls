/****************************************************************************************
  * @filename      : LsMSalesProductSeriesVO
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-06-22
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesProductSeriesVO_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-22         i2max          Create
****************************************************************************************/
public with sharing class LsMSalesProductSeriesVO {

    private static String SITE_PATH_PREFIX;
    static {
        SITE_PATH_PREFIX = I2ComUtil.getSitePathPrefix();
    }

    /**
     * 제품 시리즈 VO : 제품시리즈 정보 Wrapper VO
     * 1. 제품 시리즈
     * 2. '제품사진' 연결 제품 컨텐츠
     * 3. 제품 컨텐츠 연결 ContentDocument의 ContentVersion
     */

    @AuraEnabled public String sitePathPrefix {
        get {
            return SITE_PATH_PREFIX;
        }
        set;
    }
    @AuraEnabled public ProductSeries__c productSeries {get;set;}
    @AuraEnabled public ProductContents__c productContents {get;set;}
    @AuraEnabled public ContentVersion contentVersion {get;set;}

}