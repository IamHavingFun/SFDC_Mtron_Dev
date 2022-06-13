/****************************************************************************************
  * @filename      : i2SEMA_IFTemplateDelete_qu
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/03/17 10:34 AM
  * @group         : i2SEMA Package
  * @group-content : e.g)view file  
  * @description   : Template 삭제 Interface
  * @tester        : i2SEMA_IFTemplateDelete_qu_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/03/17 10:34 AM     i2max_shlee       Create
    0.2     2020/04/13 2:28 PM      i2max_shlee       Rename NotificationTemplateDeleteInterface_qu > i2SEMA_IFTemplateDelete_qu
****************************************************************************************/
global with sharing class i2SEMA_IFTemplateDelete_qu  implements Queueable, Database.AllowsCallouts {
    private List<NotificationTemplate__c> templates;

    /**
     * @description
     * @param QueueableContext
     */
    global void execute(QueueableContext qc) {

        IF_SFDC_SEMA_0010 instance = IF_SFDC_SEMA_0010.getInstance();
        system.debug('------------>> get INSTANCE');
        system.debug(instance);
        //Interface Request 파라미터 설정
        IF_SFDC_SEMA_0010.InputDIH input = new IF_SFDC_SEMA_0010.InputDIH();
        IF_SFDC_SEMA_0010.OutputDIH result;
        IF_SFDC_SEMA_0010.INPUT_T_DATA t_data;

        ContentVersion cv;
        for (NotificationTemplate__c template : templates) {
            t_data = new IF_SFDC_SEMA_0010.INPUT_T_DATA();
            t_data.templete_id = template.Id;                  // i2sema 템플릿 코드
            input.request.payload.T_DATA.add(t_data);
        }
        /*---------------------------
         * Interface Request 실행
         ---------------------------*/
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
    /**
     * @description NotificationTemplateDeleteInterface_qu 생성자
     * @param templates {List<NotificationTemplate__c>} 템플릿 리스트
     */
    global i2SEMA_IFTemplateDelete_qu(List<NotificationTemplate__c> templates) {
        this.templates = templates;
    }

    /**
     * @description NotificationTemplateDeleteInterface_qu 생성자
     * @param templates {NotificationTemplate__c} 템플릿 레코드
     */
    global i2SEMA_IFTemplateDelete_qu(NotificationTemplate__c template) {
        this.templates = (List<NotificationTemplate__c>) new List<NotificationTemplate__c>().add(template);
    }
}