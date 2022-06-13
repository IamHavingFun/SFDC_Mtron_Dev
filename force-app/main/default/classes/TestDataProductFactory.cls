/****************************************************************************************
  * @filename      : TestDataProductFactory
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-10 오전 10:07
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-10 오전 10:07     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
public class TestDataProductFactory {

    public static void init(){}

    /**
     * 제품 생성
     * 본체 : 이앙기 기본
     *
     * @param isInsert : insert 여부
     *
     * @return Product2
     */
    public static Product2 createProduct2(final Boolean isInsert) {
        Product2 product2 = new Product2();
        //============================================================================
        // 변경 필드
        //============================================================================
        product2.Name                   = 'LV83DB';
        product2.ProductCode            = '00000001';
        product2.Description            = '';
        product2.ExternalId__c          = '00000001';
        product2.Type__c                = '본체';
        product2.ProductDivision__c     = '이앙기';
        product2.Segment__c             = '이앙기';
//        product2.Series__c              = '이앙기상품';
        product2.ListPrice__c           = 1000000;
        product2.isSalesAvl__c          = true;
        // ProductType__c, Series__c, HorsePowerStandard__c : dependency
        product2.ProductType__c         = '이앙기';
        product2.Series__c              = 'LV';
        product2.HorsePowerStandard__c  = '6조';
        //============================================================================
        // 변경 고려 필드
        //============================================================================
        product2.GovFeeRate__c          = 0;
        product2.GovListPrice__c        = 100000;
        product2.NhFeeAmt__c            = 0;
        product2.NhListPrice__c         = 200000;
        product2.ProductDivFeeRate__c   = 0;
        product2.IsActive               = true;
        //product2.DefaultQuantity__c = 1;
        //product2.QuantityEditable__c = true;

        if(isInsert) insert product2;

        return product2;
    }

    // 본체 이앙기 제품
    public static Product2 baseProduct2              {get;set;}
    public static Product2 ProductWorkingMachine     {get;set;}

    static {
        if(baseProduct2 == null) {
            baseProduct2 = createProduct2(true);
        }
        if(ProductWorkingMachine == null) {
            ProductWorkingMachine                    = baseProduct2.clone(false, true);
            ProductWorkingMachine.Name               = 'LV83DC';
            ProductWorkingMachine.ProductCode        = '00000002';
            ProductWorkingMachine.Description        = '';
            ProductWorkingMachine.ExternalId__c      = '00000002';
            ProductWorkingMachine.Type__c            = '작업기';
            ProductWorkingMachine.ListPrice__c       = null;

            insert ProductWorkingMachine;
        }
    }

    // 본체 : 트랙터
    public static Product2 ProductTractor     {get;set;}
    // 본체 : 콤바인
    public static Product2 ProductCombine     {get;set;}
    // 본체 : 이앙기
    public static Product2 ProductRiceTransplanter     {get;set;}

    static {
        if(ProductTractor == null) {
            ProductTractor                    = baseProduct2.clone(false, true);
            ProductTractor.Name               = 'LV83DC';
            ProductTractor.ProductCode        = '00000012';
            ProductTractor.Description        = '';
            ProductTractor.ExternalId__c      = '00000012';
            ProductTractor.Type__c            = '본체';
            ProductTractor.ListPrice__c       = null;
            // 제품시리즈와 pk 관계 6개 필드
            ProductTractor.ProductType__c     = '트랙터';
            ProductTractor.HorsePowerStandard__c = '58';
            ProductTractor.Option1__c         = '프레임';
            ProductTractor.Option2__c         = '기계식';
            ProductTractor.Option3__c         = '일반';
            ProductTractor.Option4__c         = '기계식';
            // ProductType__c : Dependency
            ProductTractor.Series__c          = 'MT3';

            insert ProductTractor;
        }

        if(ProductCombine == null) {
            ProductCombine                    = baseProduct2.clone(false, true);
            ProductCombine.Name               = 'LV83DC';
            ProductCombine.ProductCode        = '00000022';
            ProductCombine.Description        = '';
            ProductCombine.ExternalId__c      = '00000022';
            ProductCombine.Type__c            = '본체';
            ProductCombine.ListPrice__c       = null;
            // ProductType__c, Series__c : dependency 관계
            ProductCombine.ProductType__c     = '콤바인';
            ProductCombine.Series__c          = '자탈형';
            ProductCombine.HorsePowerStandard__c = '';




            insert ProductCombine;
        }

        if(ProductRiceTransplanter == null) {
            ProductRiceTransplanter           = baseProduct2.clone(false, true);

            insert ProductRiceTransplanter;
        }
    }

    /**
     * 제품시리즈 생성 : 기본 트랙터 제품
     *
     * @param isInsert : Boolean
     *
     * @return ProductSeries__c
     */
    public static ProductSeries__c createProductSeries(final Boolean isInsert) {
        ProductSeries__c productSeries = new ProductSeries__c();

        productSeries.Name = ProductTractor.Series__c;
        productSeries.ProductType__c = ProductTractor.ProductType__c;
        productSeries.Series__c = ProductTractor.Series__c;
        productSeries.HorsePower__c = ProductTractor.HorsePowerStandard__c;
        productSeries.Weight__c = '10000';
        productSeries.Length__c = '19700';
        productSeries.HorsePowerList__c = '47;52;58;45;50';
        productSeries.Option1__c = ProductTractor.Option1__c;
        productSeries.Option2__c = ProductTractor.Option2__c;
        productSeries.Option3__c = ProductTractor.Option3__c;
        productSeries.Option4__c = ProductTractor.Option4__c;

        if(isInsert)    insert productSeries;

        return productSeries;
    }

    // 제품시리즈
    public static ProductSeries__c baseProductSeries {get;set;}
    static {
        if(baseProductSeries == null)   baseProductSeries = createProductSeries(true);
    }

    /**
     * 제품시리즈 추천
     *
     * @param isInsert : Boolean
     *
     * @return ProdSerRecStd__c
     */
    public static ProdSerRecStd__c createProdSerRecStd(final Boolean isInsert) {
        ProdSerRecStd__c prodSerRecStd = new ProdSerRecStd__c();
        prodSerRecStd.FarmingForm__c = '밭';
        prodSerRecStd.FarmingSize__c = '0~1만평';
        prodSerRecStd.ProductSeries__c = baseProductSeries.Id;

        if(isInsert)    insert prodSerRecStd;

        return prodSerRecStd;
    }

    // 제품추천
    public static ProdSerRecStd__c baseProdSerRecStd {get;set;}
    static {
        if(baseProdSerRecStd == null)   baseProdSerRecStd = createProdSerRecStd(true);
    }

    /**
     * 제품컨텐츠 생성
     *
     * @param isInsert : Boolean
     *
     * @return ProductContents__c
     */
    public static ProductContents__c createProductContents(final Boolean isInsert) {
        ProductContents__c productContents = new ProductContents__c();

        productContents.ContentsType__c = '제품사진';
        productContents.ProductSeries__c = baseProductSeries.Id;

        if(isInsert)    insert productContents;

        return productContents;
    }

    // 제품컨텐츠 리스트
    public static List<ProductContents__c> baseProductContentsList {get;set;}
    static {
        if(baseProductContentsList == null || baseProductContentsList.isEmpty()) {
            baseProductContentsList = new List<ProductContents__c>();
            ProductContents__c productContentsPhoto = createProductContents(false);
            ProductContents__c productContentsMovie = productContentsPhoto.clone(false, true);
            productContentsMovie.ContentsType__c = '동영상';
            ProductContents__c productContentsCata = productContentsPhoto.clone(false, true);
            productContentsCata.ContentsType__c = '카탈로그';

            baseProductContentsList.add(productContentsPhoto);
            baseProductContentsList.add(productContentsMovie);
            baseProductContentsList.add(productContentsCata);

            insert baseProductContentsList;
        }
    }

    /**
     * 제품컨텐츠 모델 생성
     * @param isInsert : Boolean
     *
     * @return ProductContentsModel__c
     */
    public static ProductContentsModel__c createProductContentsModel(final Boolean isInsert) {
        ProductContentsModel__c productContentsModel = new ProductContentsModel__c();

        productContentsModel.Product__c = ProductTractor.Id;

        if(isInsert)    insert productContentsModel;

        return productContentsModel;
    }

    // 제품 컨텐츠 모델 리스트
    public static List<ProductContentsModel__c> baseProductContentsModels {get;set;}
    static {
        if(baseProductContentsModels == null || baseProductContentsModels.isEmpty()) {
            baseProductContentsModels = new List<ProductContentsModel__c>();
            ProductContentsModel__c productContentsModelPhoto = createProductContentsModel(false);
            productContentsModelPhoto.ProductContents__c = baseProductContentsList[0].Id;
            ProductContentsModel__c productContentsModelMovie = createProductContentsModel(false);
            productContentsModelMovie.ProductContents__c = baseProductContentsList[1].Id;
            ProductContentsModel__c productContentsModelCata = createProductContentsModel(false);
            productContentsModelCata.ProductContents__c = baseProductContentsList[2].Id;
            baseProductContentsModels.add(productContentsModelPhoto);
            baseProductContentsModels.add(productContentsModelMovie);
            baseProductContentsModels.add(productContentsModelCata);

            insert baseProductContentsModels;
        }
    }

    /**
     * @description ProductFeature__c Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return ProductFeature__c
     */
    public static ProductFeature__c createProductFeature(final Boolean isInsert) {
        ProductFeature__c productFeature = new ProductFeature__c();

        productFeature.Product__c = baseProduct2.Id;
        productFeature.Number__c  = 1;

        if(isInsert) insert productFeature;

        return productFeature;
    }

    public static ProductFeature__c baseProductFeature {get;set;}

    static {
        if(baseProductFeature == null) {
            baseProductFeature = createProductFeature(true);
        }
    }

    /**
     * @description ProductOption__c Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return ProductOption__c
     */
    public static ProductOption__c createProductOption(final Boolean isInsert) {
        ProductOption__c productOption = new ProductOption__c();

        productOption.Product__c            = baseProduct2.Id;
        productOption.Name                  = 'test';
        productOption.Number__c             = 1;
        productOption.Feature__c            = TestDataProductFactory.baseProductFeature.Id;
        productOption.Type__c               = 'Accessory';
        productOption.OptionalProduct__c    = ProductWorkingMachine.Id;

        if(isInsert) insert productOption;

        return productOption;
    }

    public static ProductOption__c baseProductOption {get;set;}

    static {
        if(baseProductOption == null) {
            baseProductOption = createProductOption(true);
        }
    }

    /**
     * @description ProductPrice__c Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return ProductPrice__c
     */
    public static ProductPrice__c createProductPrice(final Boolean isInsert) {
        ProductPrice__c productPrice = new ProductPrice__c();

        productPrice.Product__c             = baseProduct2.Id;
        productPrice.Dealer__c              = TestDataBaseFactory.agencyAccount.Id;
        productPrice.DealerSupplyAmt__c     = 100000;

        if(isInsert) insert productPrice;

        return productPrice;
    }

    public static ProductPrice__c baseProductPrice {get;set;}

    static {
        if(baseProductPrice == null) {
            baseProductPrice = createProductPrice(true);
        }
    }

}