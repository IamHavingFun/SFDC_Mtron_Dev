/****************************************************************************************
  * @filename       : i2SEMA_Base_ts
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-21 오전 11:21
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : i2SEMA_Base_ts.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-21 오전 11:21     i2max_byeon.jw       Create
****************************************************************************************/

@IsTest
private class i2SEMA_Base_ts {

    /**
     * @description Config 조회
     */
    @IsTest static void testCase01(){
        i2SEMA_Base.getSenderNumber();
        i2SEMA_Base.getKakaoBizId();
        i2SEMA_Base.getIFFileStatus();
        i2SEMA_Base.getBaseOrgUrl();
        i2SEMA_Base.getSMSByteLimit();
        i2SEMA_Base.getMMSByteLmit();
        i2SEMA_Base.getLMSByteLimit();
        i2SEMA_Base.getKakaoFriendTalkByteLimit();
        i2SEMA_Base.getKakaoNotificationTalkByteLimit();
        i2SEMA_Base.getChatterByteLimit();
        i2SEMA_Base.getEventExecuteLimit();
        i2SEMA_Base.getReservationMinTime();
        i2SEMA_Base.getReservationMaxTime();
        i2SEMA_Base.getClientSideLogFlag();
        i2SEMA_Base.checkChatterEnabled();
        i2SEMA_Base.getComponentBaseData();
        i2SEMA_Base.getAttachmentURL('sampleAttachId');
        i2SEMA_Base.getContentDocumentURL('sampleContentId','sampleVersionId','sampleType');
    }
}