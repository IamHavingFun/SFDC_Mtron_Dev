/**************************************************************************************** 
  * File Name   : IF_SEMA_SFDC_0006_BIZ 
  * Description : IF_SEMA_SFDC_0006_BIZ list
  * Copyright   : Copyright © 2019 HYUNDAI All Rights Reserved
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date          Author          Modification
  * ===============================================================
    1.0  2019. 02. 28  ldb3100         Create
****************************************************************************************/
public with sharing class IF_SEMA_SFDC_0006_BIZ {

    private static IF_SEMA_SFDC_0006_BIZ sInstance = null;
    public static IF_SEMA_SFDC_0006_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_SEMA_SFDC_0006_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_SEMA_SFDC_0006.InputBody pre(IF_SEMA_SFDC_0006.InputBody inputBody, IF_SEMA_SFDC_0006.OutputBody outputBody) {
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
    public IF_SEMA_SFDC_0006.OutputBody post(IF_SEMA_SFDC_0006.InputBody inputBody, IF_SEMA_SFDC_0006.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */

        System.debug('inputBody : '+inputBody);

        List<Unsubscription__c> upsertBanList = new List<Unsubscription__c>();
        Map<String, String> releaseMap = new Map<String, String>();

        Unsubscription__c ban = null;
        for(IF_SEMA_SFDC_0006.INPUT_T_DATA data : inputBody.t_data) {
            if('I'.equals(data.reg_type))  { // 해제 비활성화 : I 차단해제 전화번호 리스트 수집
                releaseMap.put(data.recipient_ban_num, data.del_date);
            } else { //차단 활성화 : A
                ban = new Unsubscription__c();
                ban.ExtID__c          = data.recipient_ban_num;           //수신 거부 번호
                ban.Phone__c          = data.recipient_ban_num;           //수신 거부 번호
                ban.SpamNumber__c     = data.spam_num;                    //080 번호
                ban.Active__c         = TRUE;                             //상태 (활성화 : A, 비활성화 : I)
                ban.RegiestedDate__c  = Datetime.valueOf(data.reg_date);  //삭제 일시 (YYYY-MM-DD hh:mm:ss)
                upsertBanList.add(ban);
            }
        }
        System.debug('upsertBanList1 : '+upsertBanList);
        //차단 해제 처리 : 수집된 차단해제 번호를 통한 차단해제 처리
        if(releaseMap.size() > 0) {
            for (Unsubscription__c temp : [
                    SELECT Id, ExtID__c, Phone__c, Active__c
                    FROM Unsubscription__c
                    WHERE ExtID__c IN :releaseMap.keySet()
            ]) {
                if(releaseMap.containsKey(temp.Phone__c))
                temp.Active__c          = FALSE;    //상태 (활성화 : A, 비활성화 : I)
                temp.ReleasedDate__c    = Datetime.valueOf(releaseMap.get(temp.Phone__c));  //차닥해제 일시 (YYYY-MM-DD hh:mm:ss)
                upsertBanList.add(temp);
            }
        }
        System.debug('upsertBanList2 : '+upsertBanList);
        if(upsertBanList.size() > 0) upsert upsertBanList ExtID__c;
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return outputBody;
    }
}