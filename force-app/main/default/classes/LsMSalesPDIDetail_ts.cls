/****************************************************************************************
 * @filename      : LsMSalesPDIDetail_ts
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-07-09 오후 02:04
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright ⓒ I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-07-09 오후 02:04      i2max_my.Seo         Create
 ****************************************************************************************/

@IsTest
private class LsMSalesPDIDetail_ts {
    @IsTest
    static void testBehavior() {
        TestDataSalesFactory.init();

        Contract__c contract = TestDataSalesFactory.baseContract;

        Product2 product = TestDataProductFactory.baseProduct2;
        product.Type__c = '본체';
        update product;

        ContractLineItem__c contractLineItem = new ContractLineItem__c(Contract__c = contract.Id, ProductId__c = product.Id);
        insert contractLineItem;

        Asset asset = TestDataSalesFactory.baseAsset;
        asset.Contract__c = contract.Id;
        update asset;

        Contract__c contract2 = [
                SELECT Id, Name, Customer__r.Name, Customer__r.fm_Mobile__c,ContractNumber__c, Opportunity__c,
                (SELECT Id, ProductId__r.Name, ProductId__r.ProductCode, fm_ProductType__c  FROM ContractLineItem__r WHERE fm_Type__c = '본체'),
                (SELECT Id, Name, AccountId, Account.Name, Account.fm_Mobile__c, Product2.Name, InventoryType__c FROM Assets__r ORDER BY CreatedDate ASC LIMIT 1)
                FROM Contract__c WHERE Id = :contract.Id
        ];

        LsMSalesPDIDetail.init(contract.Id);
        PDI__c pdi = TestDataBizFactory.basePDI;
        pdi.Contract__c = contract2.Id;
        update pdi;

        ContentVersion contentVersion = new ContentVersion(
                Title = 'dealerSign.png',
                PathOnClient = 'dealerSign.png',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
        );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = pdi.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        LsMSalesPDIDetail.init(contract.Id);
    }
}