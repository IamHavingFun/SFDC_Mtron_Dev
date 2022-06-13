/****************************************************************************************
  * @filename      : PartnerProfileInfo
  * @projectname   : LS
  * @author        : i2max
  * @date          : 2020-05-08
  * @group         :
  * @group-content :
  * @description   : 파트너홈 프로필 정보
  *                     업무단에서 필요시 wrapper하여 Model Data 구성
  *                     업무별로 동일한 로직처리 방지. front-end 로직구성 단순화.
  * @tester        : PartnerProfileInfo_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-08         i2max          Create
****************************************************************************************/
public with sharing class PartnerHomeNoticeBoardList {

    /**
     * 초기 거래 데이터
     */
    public class InitData extends I2ComClass.InitData {
    }

    @AuraEnabled
    public static I2ComClass.InitData init() {
        InitData initData = new InitData();
        return initData;
    }


    /**
     * 공지사항 홈 리스트 조회
     *
     * @return List<SObject>
    */
    @AuraEnabled
    public static List<NoticeBoard__c> getNoticeBoardList(){
        List<NoticeBoard__c> boardLists = new List<NoticeBoard__c>();
        boardLists = [
                SELECT Id, Name, CreatedDate, Content__c, Overview__c
                FROM NoticeBoard__c
                WHERE PostDate__c <= TODAY
                ORDER BY CreatedDate DESC
                LIMIT 2
        ];
        return boardLists;
    }
}