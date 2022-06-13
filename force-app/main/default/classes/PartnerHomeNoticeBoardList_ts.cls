/****************************************************************************************
 * @filename      : PartnerHomeNoticeBoardList_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-07-21 오후 12:17
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
 0.1     2020-07-21 오후 12:17        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class PartnerHomeNoticeBoardList_ts {
    @isTest
    static void testBehavior() {
        PartnerHomeNoticeBoardList boardList = new PartnerHomeNoticeBoardList();
        NoticeBoard__c board = new NoticeBoard__c();
        insert board;
        PartnerHomeNoticeBoardList.init();
        PartnerHomeNoticeBoardList.getNoticeBoardList();
    }
}