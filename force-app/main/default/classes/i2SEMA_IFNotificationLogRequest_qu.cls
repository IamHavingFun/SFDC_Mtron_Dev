/****************************************************************************************
  * @filename      : i2SEMA_IFNotificationLogRequest_qu
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee
  * @date          : 2020/02/27 5:00 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file
  * @description   : IF_SFDC_SEMA_0026 메세지 결과 로그 요청 Interface
  * @tester        : i2SEMA_IFNotificationLogRequest_qu_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/02/27 5:00 PM     i2max_shlee       Create
    0.1     2020/04/13 2:33 PM     i2max_shlee       Rename NotificationLogInterface_qu > i2SEMA_IFNotificationLogRequest_qu
****************************************************************************************/
global with sharing class i2SEMA_IFNotificationLogRequest_qu  implements Queueable, Database.AllowsCallouts {
    Private Datetime startDt;
    Private Datetime endDt;

    /**
     * @description NotificationLogInterface_qu 로그요청 인터페이스 생성자
     * @param datetime [Datetime] 로그 요청 종료시간 (시작시간=종료시간-1일)
     */
    global i2SEMA_IFNotificationLogRequest_qu(Datetime endDt) {
        this.startDt = endDt.addDays(-1);
        this.endDt = endDt;
    }

    global i2SEMA_IFNotificationLogRequest_qu(Datetime startDt, Datetime endDt) {
        this.startDt = startDt;
        this.endDt = endDt;
    }

    /**
     * @description
     * @param QueueableContext
     */
    global void execute(QueueableContext qc) {
        IF_SFDC_SEMA_0026 instance = IF_SFDC_SEMA_0026.getInstance();
        system.debug('------------>> get INSTANCE');
        system.debug(instance);

        //Interface Request 파라미터 설정
        IF_SFDC_SEMA_0026.InputDIH input = new IF_SFDC_SEMA_0026.InputDIH();
        IF_SFDC_SEMA_0026.OutputDIH     result;
        IF_SFDC_SEMA_0026.INPUT_T_DATA  t_data;
        t_data = new IF_SFDC_SEMA_0026.INPUT_T_DATA();
        t_data.start_date       = startDt.formatGmt('YYYY-MM-dd HH:mm:ss'); // 목록 검색 시작 시간 (YYYY-MM-DD hh:mm:ss)
        t_data.end_date         = endDt.formatGmt('YYYY-MM-dd HH:mm:ss');   // 목록 검색 시작 시간 (YYYY-MM-DD hh:mm:ss)
//        t_data.seq              = '';// 메시지 고유 아이디, sequence
//        t_data.per_seq          = '';// 개인 고유 아이디
//        t_data.noti_group_id    = '';// SFDC 메시지 아이디
//        t_data.noti_id          = '';// SFDC 개인화 필드 아이디
//        t_data.recipient_num    = '';// 수신자 번호
//        t_data.templete_type    = '';// SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009
        input.request.payload.T_DATA.add(t_data);
        //Interface Request 실행
        if (!input.request.payload.T_DATA.isEmpty()) {
            result = instance.execute(input);
        }
        //Interface Response 처리
        if ('S'.equals(result.response.header.ifResult)) {
            //성공
            System.debug('Succeed to Request Logs');
        } else {
            //실패
            System.debug('Failed to Request Logs');
        }

    }

}