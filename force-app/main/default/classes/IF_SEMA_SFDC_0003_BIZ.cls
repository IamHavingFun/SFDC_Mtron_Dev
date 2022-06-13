/**************************************************************************************** 
  * File Name   : IF_SEMA_SFDC_0003_BIZ 
  * Description : IF_SEMA_SFDC_0003_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date          Author          Modification
  * ===============================================================
    1.0  2020. 05. 11  ldb3100          Create
    1.0  2020. 05. 14  i2max_shlee      Modified : 카카오 알림톡 저장 처리 : 유니크 외래키  kakako_noti_templete_code
****************************************************************************************/
public with sharing class IF_SEMA_SFDC_0003_BIZ {

    private static IF_SEMA_SFDC_0003_BIZ sInstance = null;
    public static IF_SEMA_SFDC_0003_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_SEMA_SFDC_0003_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_SEMA_SFDC_0003.InputBody pre(IF_SEMA_SFDC_0003.InputBody inputBody, IF_SEMA_SFDC_0003.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작
        /*
            값할당 샘플
        */
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return inputBody;
    }
    
    /**
     * post logic
     */
    public IF_SEMA_SFDC_0003.OutputBody post(IF_SEMA_SFDC_0003.InputBody inputBody, IF_SEMA_SFDC_0003.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */

        //Validation : 카카오 템플릿 코드 중복 제거
        Map<String, Boolean> isDuplicatedMap = New Map<String, Boolean>();
        for(IF_SEMA_SFDC_0003.INPUT_T_DATA i_data : inputBody.t_data) {
            isDuplicatedMap.put(i_data.kakako_noti_templete_code, FALSE);
        }
        //중복 여부 검색
        for(NotificationTemplate__c template : [
                SELECT Id, KakaoNotiTempleteCode__c
                FROM NotificationTemplate__c
                WHERE Channel__c = '1008' AND KakaoNotiTempleteCode__c IN :isDuplicatedMap.keySet()]) {
            //검색된 코드 값이 없으면, 중복 아님
            if(!isDuplicatedMap.containsKey(template.KakaoNotiTempleteCode__c)) continue;
            //검색된 코드값 존재시, 중복 코드
            isDuplicatedMap.put(template.KakaoNotiTempleteCode__c, TRUE);
        }
        //NotificationTemplate__c 및 KakaoTalkButton__c 저장 레코드 생성
        List<NotificationTemplate__c> insertTemplates = new List<NotificationTemplate__c>();
        NotificationTemplate__c nt = null;
        List<KakaoTalkButton__c> inserKtButtons = new List<KakaoTalkButton__c>();
        KakaoTalkButton__c kb = null;
        for(IF_SEMA_SFDC_0003.INPUT_T_DATA i_data : inputBody.t_data) {
            //Validation : 중복 카카오 템플릿 코드 저장 리스트 제외
            if(isDuplicatedMap.get(i_data.kakako_noti_templete_code)) continue;

            System.debug('i_data : '+i_data);
            nt = new NotificationTemplate__c();
            nt.Name         = i_data.templateName;
            nt.KakaoNotiTempleteCode__c = i_data.kakako_noti_templete_code;
            nt.Channel__c   = '1008';
            nt.Title__c     = i_data.templateName;
            nt.Content__c   = i_data.templateContent;
            nt.ContentLength__c = i_data.templateContent.length();  //내용 길이 TODO 수정필요 확인
            nt.LABEL1__c    = i_data.templateContent.contains('%%LABEL1%%') ? true : false;    //LABEL 1 포함
            nt.LABEL2__c    = i_data.templateContent.contains('%%LABEL2%%') ? true : false;    //LABEL 2 포함
            nt.LABEL3__c    = i_data.templateContent.contains('%%LABEL3%%') ? true : false;    //LABEL 3 포함
            nt.LABEL4__c    = i_data.templateContent.contains('%%LABEL4%%') ? true : false;    //LABEL 4 포함
            nt.LABEL5__c    = i_data.templateContent.contains('%%LABEL5%%') ? true : false;    //LABEL 5 포함
            nt.Type__c      = '2'; //1:광고성, 2:정보성 알림톡은 무조건 2번
//            nt.Ars080Phone__c   = i_data.ars_080_num; //광고성일 경우, 무료수신거부 080번호
            nt.IsActive__c  = true;
            insertTemplates.add(nt);
            if(!i_data.t_kakao.isEmpty()) {
                for(IF_SEMA_SFDC_0003.T_KAKAO button: i_data.t_kakao) {
                    kb = new KakaoTalkButton__c();
                    kb.ExternalId__c    = i_data.kakako_noti_templete_code;
                    kb.Name             = button.kakao_btn_name;
                    kb.Button_Type__c   = button.kakao_btn_type;
                    kb.ButtonLink1__c   = button.kakao_btn_link_1;
                    kb.ButtonLink2__c   = button.kakao_btn_link_2;
                    inserKtButtons.add(kb);
                }
            }
        }

        //upsert NotificationTemplate template
        if(!insertTemplates.isEmpty()) {
            insert insertTemplates;

            //1. templateMap 생성  outputBody 생성
            Map<String, NotificationTemplate__c> templateMap = new Map<String, NotificationTemplate__c>();
            IF_SEMA_SFDC_0003.OUTPUT_T_DATA o_data= null;

            for(NotificationTemplate__c template : insertTemplates) {
                templateMap.put(template.KakaoNotiTempleteCode__c, template);
                o_data = new IF_SEMA_SFDC_0003.OUTPUT_T_DATA();
                o_data.kakako_noti_templete_code = template.KakaoNotiTempleteCode__c;
                o_data.templete_id  = template.Id;
                outputBody.t_data.add(o_data);
            }
            //kakao button
            if(!inserKtButtons.isEmpty()) {
                for (KakaoTalkButton__c button : inserKtButtons) {
                    nt = templateMap.get(button.ExternalId__c);
                    button.NotificationTemplates__c = nt.Id;
                }
                insert inserKtButtons;
            }
        }

        System.debug('outputBody : '+outputBody);
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return outputBody;
    }
}