/****************************************************************************************
  * @filename      : LsMSalesProductService
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-06-10
  * @group         : 
  * @group-content : 
  * @description   : [모바일]제품 서비스
  * @tester        : lsMSalesProductService_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-10         i2max          Create
****************************************************************************************/
public without sharing class LsMSalesProductService {

    /**
     * 제품시리즈 VO 리스트 구함 : 제품컨텐츠 추천의 영농정보
     *
     * @param farmingForm 영농형태
     * @param farmingSize 영농규모
     *
     * @return List<LsMSalesProductSeriesVO>
     */
    @AuraEnabled
    public static List<LsMSalesProductSeriesVO> getProductSeriesVOS(final String farmingForm, final String farmingSize) {

        System.debug(System.LoggingLevel.INFO, 'farmingForm :' + farmingForm);
        System.debug(System.LoggingLevel.INFO, 'farmingSize :' + farmingSize);
        
        String query = 'SELECT Id, Name,' + '\n';
        query += 'Series__c, ProductType__c, HorsePower__c, Weight__c, Length__c, HorsePowerList__c, Option1__c, Option2__c, Option3__c, Option4__c, ' + '\n';
        query += '(' + '\n';
        query += '  SELECT Id' + '\n';
        query += '  FROM ProductContents__r' + '\n';
        query += '  WHERE ContentsType__c = \'제품사진\'' + '\n';
        query += '  ORDER BY SrialNo__c ASC' + '\n';
        query += '  LIMIT 1' + '\n';
        query += ')' + '\n';
        query += 'FROM ProductSeries__c' + '\n';
        query += 'WHERE Id IN (' + '\n';
        query += '  SELECT ProductSeries__c' + '\n';
        query += '  FROM ProdSerRecStd__c' + '\n';
        query += '  WHERE FarmingForm__c = :farmingForm' + '\n';
        query +=    (String.isNotBlank(farmingSize) ? 'AND   FarmingSize__c = :farmingSize' : '') + '\n';
        query += ')' + '\n';
        query += 'ORDER BY Name' + '\n';

        System.debug(System.LoggingLevel.INFO, 'query :' + query);
        
        Map<Id, ProductSeries__c> productSeriesMapByIds = new Map<Id, ProductSeries__c>((List<ProductSeries__c>)Database.query(query));

        return LsMSalesProductService.getProductSeriesVOS(productSeriesMapByIds);
    }

    /**
     * 제품시리즈 VO 리스트 구함 : 제품타입, 컨텐츠타입 기준
     *
     * @param productType 제품타입
     * @param contentsType 컨텐츠타입
     *
     * @return List<LsMSalesProductSeriesVO>
     */
    @AuraEnabled
    public static List<LsMSalesProductSeriesVO> getProductSeriesVOSForType(final String productType, final String contentsType) {

        Map<Id, ProductSeries__c> productSeriesMapByIds = new Map<Id, ProductSeries__c>([
            SELECT Id, Name,
                Series__c, ProductType__c, HorsePower__c, Weight__c, Length__c, HorsePowerList__c, Option1__c, Option2__c, Option3__c, Option4__c,
                (
                    SELECT Id
                    FROM ProductContents__r
                    WHERE ContentsType__c = :contentsType
                    ORDER BY SrialNo__c ASC
                    LIMIT 1
                )
            FROM ProductSeries__c
            WHERE ProductType__c = :productType
            ORDER BY Name
        ]);

        return LsMSalesProductService.getProductSeriesVOS(productSeriesMapByIds);
    }


    /**
     * 제품시리즈 VO 리스트 구함 : 제품시리즈ID, 컨텐츠타입 기준
     *
     * @param productSeriesId 제품시리즈 Id
     * @param contentsType 제품컨텐츠 타입
     *
     * @return List<LsMSalesProductSeriesVO>
     */
    @AuraEnabled
    public static List<LsMSalesProductSeriesVO> getProductSeriesVOSForId(final Id productSeriesId, final String contentsType) {

        System.debug(System.LoggingLevel.INFO, 'productSeriesId :' + productSeriesId);
        System.debug(System.LoggingLevel.INFO, 'contentsType :' + contentsType);

        Map<Id, ProductSeries__c> productSeriesMapByIds = new Map<Id, ProductSeries__c>([
            SELECT Id, Name,
                Series__c, ProductType__c, HorsePower__c, Weight__c, Length__c, HorsePowerList__c,
            (
                SELECT Id
                FROM ProductContents__r
                WHERE ContentsType__c = :contentsType
                ORDER BY SrialNo__c ASC
                LIMIT 1
            )
            FROM ProductSeries__c
            WHERE Id = :productSeriesId
        ]);

        return LsMSalesProductService.getProductSeriesVOS(productSeriesMapByIds);
    }

    /**
     * 제품시리즈에서 추가정보가 포함된 ProductSeriesVO 리스트를 반환
     *
     * @param productSeriesMapByIds 제품시리즈 맵
     *
     * @return List<LsMSalesProductSeriesVO>
     */
    private static List<LsMSalesProductSeriesVO> getProductSeriesVOS(Map<Id, ProductSeries__c> productSeriesMapByIds) {

        //============================================================================
        // 제품시리즈에서 제품사진 제품컨텐의 Id를 구함
        //============================================================================
        Set<Id> productContentsIds = new Set<Id>();
        for (ProductSeries__c productSeries : productSeriesMapByIds.values()) {
            if (productSeries.ProductContents__r != null && !productSeries.ProductContents__r.isEmpty()) {
                productContentsIds.add(productSeries.ProductContents__r[0].Id);
            }
        }

        //============================================================================
        // 제품컨텐츠의 첨부파일 객체를 구함
        //============================================================================
        Map<Id, ProductContents__c> productContentsMapByIds = new Map<Id, ProductContents__c>([
            SELECT Id, (SELECT Id, ContentDocumentId FROM AttachedContentDocuments)
            FROM ProductContents__c
            WHERE Id IN :productContentsIds
        ]);

        //============================================================================
        // 제품시리즈와 제품사진의 컨텐츠의 wrapper class 리스트 구함(첨부파일 객체 포함)
        //============================================================================
        List<LsMSalesProductSeriesVO> productSeriesVOS = new List<LsMSalesProductSeriesVO>();
        Set<Id> contentDocumentIds = new Set<Id>();
        ProductContents__c productContents;

        for (ProductSeries__c productSeries : productSeriesMapByIds.values()) {
            productContents = (productSeries.ProductContents__r != null && !productSeries.ProductContents__r.isEmpty() ? productContentsMapByIds.get(productSeries.ProductContents__r[0].Id) : null);

            if (productContents != null && productContents.AttachedContentDocuments != null && !productContents.AttachedContentDocuments.isEmpty()) {
                contentDocumentIds.add(productContents.AttachedContentDocuments[0].ContentDocumentId);
            }
        }

        //============================================================================
        // 첨부파일의 contentVersion 을 구함
        //============================================================================
        Map<Id, ContentVersion> contentVersionsByDocumentIds = new Map<Id, ContentVersion>();
        for (ContentVersion contentVersion : [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
            AND IsLatest = TRUE
        ]) {
            contentVersionsByDocumentIds.put(contentVersion.ContentDocumentId, contentVersion);
        }

        //============================================================================
        // 최종 ProductSeriesVO 데이터를 담음
        //============================================================================
        LsMSalesProductSeriesVO productSeriesVO;

        for (ProductSeries__c productSeries : productSeriesMapByIds.values()) {
            productSeriesVOS.add(productSeriesVO = new LsMSalesProductSeriesVO());
            productSeriesVO.productSeries = productSeries;
            productSeriesVO.productContents = (productSeries.ProductContents__r != null && !productSeries.ProductContents__r.isEmpty() ? productContentsMapByIds.get(productSeries.ProductContents__r[0].Id) : null);
            productSeriesVO.contentVersion = (productSeriesVO.productContents != null && productSeriesVO.productContents.AttachedContentDocuments != null && !productSeriesVO.productContents.AttachedContentDocuments.isEmpty())
                ? contentVersionsByDocumentIds.get(productSeriesVO.productContents.AttachedContentDocuments[0].ContentDocumentId)
                : null;
        }

        return productSeriesVOS;
    }

    /**
     * 제품 : 제품시리즈를 통한 단 하나의 제품
     * 아래의 filter 조건으로 조회시 단 하나의 제품이 나온게끔 설계됨.
     *
     * @param searchProductSeries 조회용 제품시리즈
     *
     * @return Product2
     */
    public static Product2 getProduct(final ProductSeries__c searchProductSeries) {
        List<LsMSalesProductVO> lsMSalesProductVOS = new List<LsMSalesProductVO>();

        System.debug(System.LoggingLevel.INFO, '선택된 제품시리즈 productSeries :' + searchProductSeries);

        List<Product2> products = [
            SELECT  Id, Name,
                    Option1__c,Option2__c,Option3__c,Option4__c,
                    ProductCode, ProductType__c, Segment__c, Series__c, Type__c, HorsePowerStandard__c
            FROM Product2
            WHERE Type__c               = '본체'
            AND isSalesAvl__c           = TRUE
            AND Series__c               = :searchProductSeries.Series__c
            AND HorsePowerStandard__c   = :searchProductSeries.HorsePower__c
            AND Option1__c              = :searchProductSeries.Option1__c
            AND Option2__c              = :searchProductSeries.Option2__c
            AND Option3__c              = :searchProductSeries.Option3__c
            AND Option4__c              = :searchProductSeries.Option4__c
            ORDER BY ProductCode DESC
        ];

        if(products.size() == 0){
            throw new AuraHandledException('선택한 제품시리즈에 해당하는 제품이 존재하지 않습니다.');
        }

        return products[0];
    }

    /**
     * 제품 리스트 조회
     * 제품시리즈와 마력 조건의 제품리스트를 조회
     *
     * @param searchProductSeries 조회용 제품시리즈
     *
     * @return List<Product2>
     */
    public static List<Product2> getProducts(final ProductSeries__c searchProductSeries) {
        List<LsMSalesProductVO> lsMSalesProductVOS = new List<LsMSalesProductVO>();

        System.debug(System.LoggingLevel.INFO, '선택된 제품시리즈 productSeries :' + searchProductSeries);

        List<Product2> products = [
            SELECT  Id, Name,
                Option1__c,Option2__c,Option3__c,Option4__c,
                ProductCode, ProductType__c, Segment__c, Series__c, Type__c, HorsePowerStandard__c,
                ListPrice__c
            FROM Product2
            WHERE Type__c               = '본체'
            AND isSalesAvl__c           = TRUE
            AND Series__c               = :searchProductSeries.Series__c
            AND HorsePowerStandard__c   = :searchProductSeries.HorsePower__c
            ORDER BY ProductCode DESC
        ];

        return products;
    }

    /**
     * 제품 레코드 Id로 제품을 구함
     *
     * @param productRecordId 제품 레코드 Id
     * @param contentsTypeList 컨텐츠타입 리스트
     *
     * @return List<LsMSalesProductVO>
     */
    public static LsMSalesProductVO getProductVO(final Id productRecordId, final List<String> contentsTypeList) {
        List<LsMSalesProductVO> lsMSalesProductVOS = new List<LsMSalesProductVO>();

        System.debug(System.LoggingLevel.INFO, 'productRecordId :' + productRecordId);

        List<Product2> products = [
            SELECT  Id, Name,
                    Option1__c,Option2__c,Option3__c,Option4__c,
                    ProductCode, ProductType__c, Segment__c, Series__c, Type__c, HorsePowerStandard__c
            FROM Product2
            WHERE Id = :productRecordId
        ];

        return LsMSalesProductService.getProductVO(products[0], contentsTypeList);
    }

    /**
     * carousel 용도의 contentsTypeList
     */
    public static List<String> carouselContentsTypeList = new List<String>{
        '동영상', '세일즈토크', '카탈로그'
    };

    /**
     * 제품을 통한 제품 VO를 구함
     * 제품컨텐츠와 contentDocuemnt와 연동되는 이미지 파일들의 contentVersion 연동 데이터 구조
     * @param product 제품
     * @param contentsTypeList 컨텐츠타입 리스트
     *
     * @return LsMSalesProductVO
     */
    public static LsMSalesProductVO getProductVO(final Product2 product, final List<String> contentsTypeList) {

        //============================================================================
        // 제품컨텐츠의 첨부파일 객체를 구함
        //============================================================================
        Map<Id, ProductContents__c> productContentsMapByIds = new Map<Id, ProductContents__c>([
            SELECT  Id, Name, HeadTitle__c, Description__c, ContentsType__c, MovieURL__c, SrialNo__c,
                    (SELECT Id, ContentDocumentId FROM AttachedContentDocuments)
            FROM ProductContents__c
            WHERE Id IN (
                SELECT ProductContents__c
                FROM ProductContentsModel__c
                WHERE Product__c = :product.Id
            )
            AND ContentsType__c IN :contentsTypeList
            ORDER BY ProductContents__c.SrialNo__c ASC
        ]);

        //============================================================================
        // 제품시리즈와 제품사진의 컨텐츠의 wrapper class 리스트 구함(첨부파일 객체 포함)
        //============================================================================
        Set<Id> contentDocumentIds = new Set<Id>();

        for (ProductContents__c productContents : productContentsMapByIds.values()) {
            if (productContents != null && productContents.AttachedContentDocuments != null && !productContents.AttachedContentDocuments.isEmpty()) {
                for(AttachedContentDocument attachedContentDocument : productContents.AttachedContentDocuments) {
                    contentDocumentIds.add(attachedContentDocument.ContentDocumentId);
                }
            }
        }

        //============================================================================
        // 첨부파일의 contentVersion 을 구함
        //============================================================================
        Map<Id, ContentVersion> contentVersionsByDocumentIds = new Map<Id, ContentVersion>();
        for (ContentVersion contentVersion : [
            SELECT Id, ContentDocumentId, Description
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
            AND IsLatest = TRUE
        ]) {
            contentVersionsByDocumentIds.put(contentVersion.ContentDocumentId, contentVersion);
        }

        List<LsMSalesProductVO.ProductContentsData> productContentsDataList = new List<LsMSalesProductVO.ProductContentsData>();
        List<LsMSalesProductVO.ProductContentsData> productContentsCatalogueDataList = new List<LsMSalesProductVO.ProductContentsData>();
        List<LsMSalesProductVO.ProductContentsData> productContentsVideoDataList = new List<LsMSalesProductVO.ProductContentsData>();
        List<LsMSalesProductVO.ProductContentsData> productContentsSalesTalkDataList = new List<LsMSalesProductVO.ProductContentsData>();
        List<ContentVersion> tmpContentVersions;
        LsMSalesProductVO.ProductContentsData productContentsData;

        for (ProductContents__c productContents : productContentsMapByIds.values()) {
            tmpContentVersions = new List<ContentVersion>();

            if (productContents != null && productContents.AttachedContentDocuments != null && !productContents.AttachedContentDocuments.isEmpty()) {
                for(AttachedContentDocument attachedContentDocument : productContents.AttachedContentDocuments) {
                    tmpContentVersions.add(contentVersionsByDocumentIds.get(attachedContentDocument.ContentDocumentId));
                }
            }

            productContentsData = new LsMSalesProductVO.ProductContentsData(productContents, tmpContentVersions);
            productContentsDataList.add(productContentsData);

            switch on productContents.ContentsType__c {
                when '동영상' {
                    productContentsVideoDataList.add(productContentsData);
                }
                when '세일즈토크' {
                    productContentsSalesTalkDataList.add(productContentsData);
                }
                when '카탈로그' {
                    productContentsCatalogueDataList.add(productContentsData);
                }
            }
        }

        LsMSalesProductVO lsMSalesProductVO = new LsMSalesProductVO();
        lsMSalesProductVO.product = product;
        lsMSalesProductVO.productContentsDataList = productContentsDataList;
        lsMSalesProductVO.productContentsVideoDataList = productContentsVideoDataList;
        lsMSalesProductVO.productContentsSalesTalkDataList = productContentsSalesTalkDataList;
        lsMSalesProductVO.productContentsCatalogueDataList = productContentsCatalogueDataList;

        return lsMSalesProductVO;
    }

}