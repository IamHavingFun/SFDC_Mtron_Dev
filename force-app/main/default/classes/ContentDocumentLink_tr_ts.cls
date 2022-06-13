/****************************************************************************************
  * @filename      : ContentDocumentLink_tr_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-17 오후 3:03
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-17 오후 3:03     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class ContentDocumentLink_tr_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataBizFactory.init();

        ContentVersion contentVersion = [SELECT ContentDocumentId FROM ContentVersion];

        ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId   = contentVersion.ContentDocumentId,
                LinkedEntityId      = TestDataBaseFactory.baseCase.Id,
                ShareType           = 'V'
        );

        insert cdl;
    }
}