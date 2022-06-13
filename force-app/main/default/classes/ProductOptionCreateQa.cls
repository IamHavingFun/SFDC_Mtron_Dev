/****************************************************************************************
 * @filename      : ProductOptionCreateQa
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-09-01 오전 10:44
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-09-01 오전 10:44        SEOKHO LEE          Create
 ****************************************************************************************/

public with sharing class ProductOptionCreateQa {

    @AuraEnabled
    public static InitData init(final String recordId) {
        InitData initData = new InitData();
        initData.product = getProduct(recordId);
        initData.productFeaturesList = getProductFeaturesList(recordId);
        return initData;
    }

    @AuraEnabled
    public static void save(final String reqData, final Product2 product) {
        Map<String, String> productData = I2ComHelper.gfnCheckCondition(reqData);

        final String featureId = productData.get('featureId');
        final String workingMachineId = productData.get('workingMachineId');

        Product2 workingMachine = getProduct(workingMachineId);

        if(workingMachine.Type__c == '본체'){
            throw new AuraHandledException('본체 유형을 선택할 수 없습니다.');
        }

        ProductFeature__c productFeature = [
            SELECT Name
            FROM ProductFeature__c
            WHERE Product__c = :product.Id AND Id = :featureId
        ];

        if(productFeature.Name != workingMachine.Segment__c) {
            throw new AuraHandledException('작업기 유형이 동일 해야 합니다.');
        }

        ProductOption__c po = new ProductOption__c();
        po.Name = product.Name + ' | ' + workingMachine.Name;
        po.Product__c = product.Id;
        po.Feature__c = featureId;
        po.OptionalProduct__c = workingMachineId;

        // 본체 Id, 작업기 Id
        if(duplicateCheck(po.Product__c, po.OptionalProduct__c) > 0){
            throw new AuraHandledException('작업기는 중복해서 입력할 수 없습니다.');
        }
        insert po;
    }

    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public Product2 product {get; set;}
        @AuraEnabled public List<I2ComClass.Option> productFeaturesList {
            get{
                if(this.productFeaturesList == null) {
                    this.productFeaturesList = new List<I2ComClass.Option>();
                }
                return this.productFeaturesList;
            }
            set;
        }
    }

    private static Product2 getProduct(final String recordId){
        return [
                SELECT Id, Name, Type__c, Segment__c
                FROM Product2
                WHERE Id = :recordId
        ];
    }

    private static List<I2ComClass.Option> getProductFeaturesList(final String prodId){
        List<I2ComClass.Option> optionList =  new List<I2ComClass.Option>();
        for(ProductFeature__c pf : [
                SELECT Id, Name
                FROM ProductFeature__c
                WHERE Product__c = :prodId
        ]) {
            optionList.add(new I2ComClass.Option(pf.Name, pf.Id));
        }
        return optionList;
    }

    private static Integer duplicateCheck(final String prodId, final String workMachineId){
        return [
                SELECT Count()
                FROM ProductOption__c
                WHERE OptionalProduct__c = :workMachineId
                AND Product__c = :prodId
        ];
    }

}