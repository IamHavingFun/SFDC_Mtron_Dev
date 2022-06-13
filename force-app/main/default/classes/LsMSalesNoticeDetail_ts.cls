/****************************************************************************************
 * @filename      : LsMSalesNoticeDetail_ts
 * @projectname   :
 * @author        : CHOI SEONGWON
 * @date          : 2020-07-07 오후 12:43
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
 0.1     2020-07-07 오후 12:43     CHOI SEONGWON          Create
 ****************************************************************************************/
@IsTest
private class  LsMSalesNoticeDetail_ts{
    @IsTest
    static void testBehavior() {


        NoticeBoard__c noticeBoard = new NoticeBoard__c();
        insert noticeBoard;

        LsMSalesNoticeDetail.init(noticeBoard.Id);



    }
}