/**************************************************************************************** 
  * File Name   : IF_SEMA_SFDC_0001_BIZ 
  * Description : IF_SEMA_SFDC_0001_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date          Author          Modification
  * ===============================================================
    1.0  2019. 02. 27  ldb3100         Create
****************************************************************************************/
public with sharing class IF_SEMA_SFDC_0001_BIZ {

    private static IF_SEMA_SFDC_0001_BIZ sInstance = null;
    public static IF_SEMA_SFDC_0001_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_SEMA_SFDC_0001_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_SEMA_SFDC_0001.InputBody pre(IF_SEMA_SFDC_0001.InputBody inputBody, IF_SEMA_SFDC_0001.OutputBody outputBody) {
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
    public IF_SEMA_SFDC_0001.OutputBody post(IF_SEMA_SFDC_0001.InputBody inputBody, IF_SEMA_SFDC_0001.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */


        List<IF_SEMA_SFDC_0001.T_LOG> logList = new List<IF_SEMA_SFDC_0001.T_LOG>();
        for(IF_SEMA_SFDC_0001.INPUT_T_DATA data : inputBody.t_data) {
            logList.addAll(data.t_err);
        }

        //전체 건수 Dummy 저장
        List<IF_SEMA_SFDC_Dummy__c> dummys = new List<IF_SEMA_SFDC_Dummy__c>();
        IF_SEMA_SFDC_Dummy__c dummy = null;
        if(logList.size() > 0) { // 에러리스트가 존재시
            for(IF_SEMA_SFDC_0001.T_LOG log : logList) {
                dummy = new IF_SEMA_SFDC_Dummy__c();

                dummy.IF_Id__c              = 'IF_SEMA_SFDC_0001';
                if(i2SEMA_Util.isEmpty(log.noti_id)) { //개별 notificationId Log
                    dummy.noti_group_id__c      = log.noti_group_id;
                    dummy.noti_id__c            = log.noti_id;
                } else { //개별 NotificationGroupId List
                    dummy.noti_group_id__c      = log.noti_group_id;
                }
                dummy.SucessYN__c           = log.success_yn;
                dummy.recipient_num__c      = log.recipient_num;
                dummy.mt_report_code_ib__c  = log.mt_report_code_ib;
                dummy.code_message__c       = log.code_message;
                dummys.add(dummy);
            }

            if(dummys.size() > 0)insert dummys;
        }

        //메세지 전송 성공업데이트 >>>>>>>> 성공로그 전달 방법 수정 필요> SEMA 서버에서 협의해서 전달예
//        NotificationLog_ba batch = new NotificationLog_ba(notiGroupIds, notiErrIds);
//        database.executebatch(batch, 2000);

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝정 */
        
        return outputBody;
    }
}