/****************************************************************************************
  * @filename      : NoticeMoviePlay_ts
  * @author        : i2max_my.Seo
  * @date          : 2021-01-15 오후 1:53
  * @group         :
  * @group-content :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2021-01-15 오후 1:53     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class NoticeMoviePlay_ts {
    @IsTest
    static void testBehavior() {
        //==============================================================================
        // Data Setting
        //==============================================================================
        NoticeBoard__c testNoticeBoard = new NoticeBoard__c();

        testNoticeBoard.MovieType__c = '링크';
        testNoticeBoard.MovieURL__c = 'test.com';

        NoticeBoard__c testNoticeBoard2 = testNoticeBoard.clone(false, true);
        testNoticeBoard2.MovieType__c = '파일';

        insert new List<NoticeBoard__c>{testNoticeBoard, testNoticeBoard2};

        //==============================================================================
        // Logic Test
        //==============================================================================
        System.assertNotEquals(null, NoticeMoviePlay.init(testNoticeBoard.Id, true));
        System.assertNotEquals(null, NoticeMoviePlay.init(testNoticeBoard2.Id, true));
    }
}