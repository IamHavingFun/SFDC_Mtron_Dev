/****************************************************************************************
  * @filename       : i2SEMA_ManualSendReceiverSearch_ts
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-21 오전 9:52
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : i2SEMA_ManualSendReceiverSearch_ts_ts.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-21 오전 9:52     i2max_byeon.jw       Create
****************************************************************************************/

@IsTest
private class i2SEMA_ManualSendReceiverSearch_ts {

    static Id accountId;
    static Id contactId;

    /**
     * @description Test Data 생성
     */
    @TestSetup
    static void setup(){
        // Account & Contact 생성
        i2SEMA_TestDataUtil.getContact();
    }

    static void getData(){
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        if( !accounts.isEmpty()){
            accountId = accounts[0].Id;
        }

        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        if( !contacts.isEmpty()){
            contactId = contacts[0].Id;
        }
    }
    /**
     * @description Account 하위 Contact 수신자 조회
     */
    @IsTest static void testCase01(){
        if(i2SEMA_Util.isEmpty(accountId)){
            getData();
        }

        // Param
        i2SEMA_ManualSendReceiverSearch.RequestData requestData = new i2SEMA_ManualSendReceiverSearch.RequestData();
        requestData.recordId            = String.valueOf(accountId);
        requestData.searchObjectType    = 'Contact';
        requestData.selectedIds         = new List<String>{contactId};

        // Apex Response
        i2SEMA_ComponentResponse response = i2SEMA_ManualSendReceiverSearch.initialize(requestData);
        i2SEMA_ManualSendReceiverSearch.ReferenceData referenceData = (i2SEMA_ManualSendReceiverSearch.ReferenceData)JSON.deserialize(JSON.serialize(response.getData('referenceData')),i2SEMA_ManualSendReceiverSearch.ReferenceData.class);

        // Assert Equal
        System.assertEquals( true , referenceData != null );                // 응답값은 항상 존재
        System.assertEquals( 1 , referenceData.records.size());             // 테스트 데이터로 생성한 Account 하위 Contact 1건 존재
        System.assertEquals( true , referenceData.records[0].selected);     // 요청정보에 Record 는 selected 처리
    }
}