/****************************************************************************************
  * @filename      : i2SEMA_IFUnsubscriptionRequest_qu
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee
  * @date          : 2020/03/02 8:58 AM
  * @group         : e.g)tab name
  * @group-content : e.g)view file
  * @description   :
  * @tester        : NotificationUnsubscriptionInterface_qu_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/03/02 8:58 AM     i2max_shlee       Create
    0.2     2020/04/13 3:39 PM     i2max_shlee       Rename NotificationUnsubscriptionInterface_qu > i2SEMA_IFUnsubscriptionRequest_qu
****************************************************************************************/
global with sharing class i2SEMA_IFUnsubscriptionRequest_qu  implements Queueable, Database.AllowsCallouts {
    Private Datetime startDt;
    Private Datetime endDt;

    /**
     * @description NotificationLogInterface_qu 로그요청 인터페이스 생성자
     * @param datetime [Datetime] 로그 요청 종료시간 (시작시간=종료시간-1일)
     */
    global i2SEMA_IFUnsubscriptionRequest_qu(Datetime endDt) {
        this.endDt = endDt;
        this.startDt = endDt.addDays(-1);
    }

    global i2SEMA_IFUnsubscriptionRequest_qu(Datetime startDt, Datetime endDt) {
        this.startDt = startDt;
        this.endDt = endDt;
    }

    /**
     * @description
     * @param QueueableContext
     */
    global void execute(QueueableContext qc) {
        IF_SFDC_SEMA_0011 instance = IF_SFDC_SEMA_0011.getInstance();
        system.debug('------------>> get INSTANCE');
        system.debug(instance);

        //Interface Request 파라미터 설정
        IF_SFDC_SEMA_0011.InputDIH input = new IF_SFDC_SEMA_0011.InputDIH();
        IF_SFDC_SEMA_0011.OutputDIH result;
        IF_SFDC_SEMA_0011.INPUT_T_DATA t_data;
        t_data = new IF_SFDC_SEMA_0011.INPUT_T_DATA();
        t_data.start_date       = startDt.formatGmt('YYYY-MM-dd HH:mm:ss'); // 목록 검색 시작 시간 (YYYY-MM-DD hh:mm:ss)
        t_data.end_date         = endDt.formatGmt('YYYY-MM-dd HH:mm:ss');   // 목록 검색 시작 시간 (YYYY-MM-DD hh:mm:ss)
        t_data.spam_num         = 'ALL';// 080 번호 (전체 : ALL)
        t_data.reg_type         = 'ALL';// 상태 (전체 : ALL, 활성화 : A, 비활성화 : I)
        input.request.payload.T_DATA.add(t_data);
        //Interface Request 실행
        if (!input.request.payload.T_DATA.isEmpty()) {
            result = instance.execute(input);
        }
        //Interface Response 처리
        if ('S'.equals(result.response.header.ifResult)) {
            //성공
        } else {
            //실패
        }

    }
}