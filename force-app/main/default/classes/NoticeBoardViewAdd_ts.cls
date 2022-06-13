/****************************************************************************************
  * @filename      : NoticeBoardViewAdd_ts
  * @author        : i2max_my.Seo
  * @date          : 2020-09-09 오후 3:55
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-09-09 오후 3:55     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class NoticeBoardViewAdd_ts {
    @IsTest
    static void testBehavior() {
        //==============================================================================
        // test data setting
        //==============================================================================
        NoticeBoard__c noticeBoard = new NoticeBoard__c();
        insert noticeBoard;

        //==============================================================================
        // logic
        //==============================================================================
        System.assertEquals(NoticeBoardViewAdd.init(noticeBoard.Id), true);
    }
}