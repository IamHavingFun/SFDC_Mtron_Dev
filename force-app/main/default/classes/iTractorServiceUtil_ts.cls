/****************************************************************************************
  * @filename      : iTractorServiceUtil_ts
  * @projectname   :
  * @author        : i2max_sira
  * @date          : 2021-11-12
  * @group         :
  * @group-content :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2021-11-12 오전 10:24     i2max_my.Seo           Create
****************************************************************************************/
@IsTest
private class iTractorServiceUtil_ts {
    @IsTest
    static void testBehavior1() {
        TriggerHandler.bypass('Account_tr');
        TriggerHandler.bypass('Asset_tr');
        TriggerHandler.bypass('i2SEMA_AutomaticNotification_tr');

        TestDataBaseFactory.init();
        //TestDataDummyBatchFactory.init();
        TestDataSalesFactory.init();

        Account pa = TestDataBaseFactory.personAccount.clone(false, true);
        pa.PersonMobilePhone = '010-1111-2222';
        pa.RecordTypeId = TestDataUtilFactory.getRecordTypeId('Account', 'PersonAccount');
        System.debug(pa);
        insert pa;

        Asset testAsset = null;
        iTractorServiceUtil.validate(testAsset);

        testAsset = TestDataSalesFactory.baseAsset.clone(false, true);
        testAsset.Name = '96991542222';
        testAsset.AccountId = pa.id;
        testAsset.InventoryType__c = '실판매';
        insert testAsset;

        Asset soqlAst = [SELECT id, name, Customer__c, AccountID,isNHContact__c, Dealer__c, Account.PersonMobilePhone, Customer__r.PersonMobilePhone FROM Asset WHERE id = :testAsset.id];

        System.debug(soqlAst);
        iTractorServiceUtil.validate(soqlAst);

        iTractorServiceUtil.getNotiGroup();

        iTractorServiceUtil.masking_name('');
        iTractorServiceUtil.masking_name('농협');
        iTractorServiceUtil.masking_name('김농협');
        iTractorServiceUtil.masking_name('김 농협');
        iTractorServiceUtil.masking_name('김 농농협');
        iTractorServiceUtil.masking_name('김 농농농협');

        TriggerHandler.clearAllBypasses();
    }

    @IsTest
    static void testBehavior2() {
        iTractorErrorCode__c err = new iTractorErrorCode__c();
        err.ErrorCode__c = 'SM123';
        err.ErrorType__c = '소모품';
        err.ErrorMessage__c = '소모품 확인 부탁드립니다.';
        insert err;

        iTractorServiceUtil.getCodeMsg('SM123', '소모품');
    }

    @IsTest
    static void testBehavior3() {
        iTractorTemplateMap__c itm = new iTractorTemplateMap__c();
        itm.Product_Type__c = '소모품';
        itm.Guest_Type__c = '타입2';
        itm.Guest_Target__c = true;
        itm.Guest_Template__c = null;


        iTractorServiceUtil.getTemplateMapInfo('소모품', '타입2');
    }


    @IsTest
    static void testBehavior4() {

        iTractorServiceLabelMapping.iTractorlabels labels = new iTractorServiceLabelMapping.iTractorlabels();
        labels.Label1 = 'a';
        labels.Label2 = 'a';
        labels.Label3 = 'a';
        labels.Label4 = 'a';
        labels.Label5 = 'a';
        labels.Phone = '0900000000';

        NotificationTemplate__c testNT = new NotificationTemplate__c();
        testNT.Channel__c = '1009';
        testNT.Title__c = 'Test 템플릿1';
        testNT.Content__c = 'TEST 버전입니다.\n' +
                '#{label1}님께서 신청하신 #{label2} 코엑서 컨벤션센터에서 개최되는 #{label3}에 사전등록 신청해 주셔서 감사드립니다.\n' +
                '참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.';
        testNT.IsActive__c = true;
        insert testNT;

        iTractorServiceUtil.addNotification(iTractorServiceUtil.getNotiGroup(), labels, testNT);


    }
}