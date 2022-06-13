/****************************************************************************************
 * @filename      : NoticeBoardPartnerShareController_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-07-23 오전 10:31
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
 0.1     2020-07-23 오전 10:31        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class NoticeBoardPartnerShareController_ts {
    @isTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        Account bAccount = TestDataBaseFactory.businessOfficeAccount.clone(false, true);
        bAccount.CustomerType__c = '영업소';
        insert bAccount;


       Account acc = TestDataBaseFactory.agencyAccount.clone(false, true);
        acc.BusinessOffice__c = bAccount.Id;
        acc.ERPCode__c = '1234';
        acc.CustomerType__c = '대리점';
        acc.IsDelete__c = false;
        insert acc;

        NoticeBoard__c noticeBoard = new NoticeBoard__c();
        insert noticeBoard;



        ShareSetting__c setting1 = new ShareSetting__c();
        setting1.Account__c = TestDataBaseFactory.agencyUser.AccountId;
        //setting1.Account__c = acc.Id;
        setting1.DealerApex__c = '';
        setting1.BusinessOfficeApex__c = '';
        setting1.NoticeBoard__c = noticeBoard.Id;

        ShareSetting__c setting2 = setting1.clone(false, true);
        setting2.Account__c = TestDataBaseFactory.agencyUser.AccountId;
        //setting2.Account__c = acc.Id;
        setting2.NoticeBoard__c = null;
        insert new List<ShareSetting__c>{
            setting1, setting2
        };


        NoticeBoardPartnerShareController.InitData initData = new NoticeBoardPartnerShareController.InitData();
        System.assertNotEquals(initData.businessOfficeList, null);
        NoticeBoardPartnerShareController.init();
        NoticeBoardPartnerShareController.getSearch(acc.BusinessOffice__c, NoticeBoardPartnerShareController.getShareSettingItems(noticeBoard.Id,'NoticeBoard__c'));
        NoticeBoardPartnerShareController.getAllCheckShareSettingItems(
                NoticeBoardPartnerShareController.getShareSettingItems(noticeBoard.Id,'NoticeBoard__c'),
                NoticeBoardPartnerShareController.getSearch(acc.BusinessOffice__c, NoticeBoardPartnerShareController.getShareSettingItems(noticeBoard.Id,'NoticeBoard__c')),
                false
        );
        NoticeBoardPartnerShareController.getAllCheckShareSettingItems(
                NoticeBoardPartnerShareController.getShareSettingItems(noticeBoard.Id,'NoticeBoard__c'),
                NoticeBoardPartnerShareController.getSearch(acc.BusinessOffice__c, NoticeBoardPartnerShareController.getShareSettingItems(noticeBoard.Id,'NoticeBoard__c')),
                true
        );
        NoticeBoardPartnerShareController.doSave(
                NoticeBoardPartnerShareController.getShareSettingItems(noticeBoard.Id,'NoticeBoard__c'),
                'NoticeBoard__c',
                noticeBoard.Id
        );
        NoticeBoardPartnerShareController.getShareSettingDelete(acc.Id, setting2.Id, 'NoticeBoard__c');
        }
}