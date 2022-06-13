/****************************************************************************************
  * @filename      : i2SEMA_NotificationKakaoButtonLink
  * @projectname   : i2SEMA Core
  * @author        : i2max_ys.seo
  * @date          : 2020-04-16 오후 1:45
  * @group         : Notification Template
  * @group-content : e.g)view file
  * @description   : 템플릿 카카오 버튼 리스트 및 수정
  * @tester        : i2SEMA_NotificationKakaoButtonLink_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author              description
  * ===============================================================
    0.1     2020-04-16 오후 1:45     i2max_ys.seo         Create
    0.2     2020/04/28 11:31 AM     i2max_shlee          Rename i2SEMA_NotificationKakaoButtonLink ->i2SEMA_TemplateKakaoButton
****************************************************************************************/
public with sharing class i2SEMA_TemplateKakaoButton {
    /**
         * @description NotificationKakaoButton 취소 버튼 클릭시 카카오버튼 리스트 초기화용 서버 저장 값을 불러와서 전달
         *                해당 recordId(TemplateId) 기준으로 카카오버튼링크 리스트 조회
         * @param param {String} 해당 Template record Id
         * @return {i2SEMA_ComponentResponse} 통신 결과 Wrapper
         */
    @AuraEnabled
    public static i2SEMA_ComponentResponse initialize(String recordId) {
        i2SEMA_ComponentResponse response = new i2SEMA_ComponentResponse();

        System.debug('recordId : '+recordId);
        RequestData requestData = new RequestData();
        if(i2SEMA_Util.isNotEmpty(recordId)){
            List<KakaoTalkButton__c> ktbList = [
                    SELECT Id, Name, NotificationTemplates__c, Button_Type__c, ButtonLink1__c, ButtonLink2__c, NotificationTemplates__r.Name
                    FROM KakaoTalkButton__c
                    WHERE NotificationTemplates__c = :recordId
            ];
            requestData.kakaoButtons = ktbList;
        }

        response.setData('requestData', requestData);
        system.debug('requestData : ' + requestData);

        return response;
    }

    public class RequestData {
        @AuraEnabled public List<KakaoTalkButton__c> kakaoButtons {get; set;}
        public RequestData(){
            this.kakaoButtons    = new List<KakaoTalkButton__c>();
        }
    }

}