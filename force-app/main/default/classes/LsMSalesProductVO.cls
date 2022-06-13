/****************************************************************************************
  * @filename      : LsMSalesProductVO
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-06-18
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesProductVO_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-18         i2max          Create
****************************************************************************************/
public with sharing class LsMSalesProductVO {

    private static String SITE_PATH_PREFIX;

    static {
        SITE_PATH_PREFIX = I2ComUtil.getSitePathPrefix();
    }

    @AuraEnabled public String sitePathPrefix {
        get {
            return SITE_PATH_PREFIX;
        }
        set;
    }

    @AuraEnabled public Product2 product {get;set;}
    @AuraEnabled public List<ProductContentsData> productContentsDataList {get;set;}
    @AuraEnabled public List<ProductContentsData> productContentsCatalogueDataList {get;set;}
    @AuraEnabled public List<ProductContentsData> productContentsVideoDataList {get;set;}
    @AuraEnabled public List<ProductContentsData> productContentsSalesTalkDataList {get;set;}

    /**
     * 제품 컨텐츠 정보
     */
    public class ProductContentsData {
        @AuraEnabled public ProductContents__c productContents {get;set;}
        @AuraEnabled public List<ContentVersion> contentVersions {get;set;}

        public ProductContentsData(final ProductContents__c productContents, final List<ContentVersion> contentVersions) {
            this.productContents = productContents;
            this.contentVersions= contentVersions;
        }
    }

}