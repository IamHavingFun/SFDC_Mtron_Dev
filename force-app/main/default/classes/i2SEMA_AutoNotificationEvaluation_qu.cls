/****************************************************************************************
  * @filename       : i2SEMA_AutoNotificationEvaluation_qu
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-23 오전 8:47
  * @group          : 
  * @group-content  : 
  * @description    : 자동발송 결과판정, Notification 발송
  * @tester         : i2SEMA_AutoNotificationEvaluation_qu_ts.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-23 오전 8:47     i2max_byeon.jw       Create
****************************************************************************************/

public without sharing class i2SEMA_AutoNotificationEvaluation_qu implements Queueable {
    private Map<SObject,Map<NotificationAutomaticSetting__c,Map<String,Boolean>>> recordEventSettingAliasMap;

    /**
     * @description 레코드별 자동규칙,상세조건 결과를 입력받아 처리
     *
     * @param recordEventSettingAliasMap 레코트 단위별 판정하는 자동화 규칙과 그 하위 상세조건의 Alias
     */
    public i2SEMA_AutoNotificationEvaluation_qu(Map<SObject,Map<NotificationAutomaticSetting__c,Map<String,Boolean>>> recordEventSettingAliasMap){
        this.recordEventSettingAliasMap = recordEventSettingAliasMap;
    }

    public void execute(QueueableContext qc){
        /*------------------------------------------------------------------
         * 발송대상 판정
            1. 자동발신의 필드조건이 없고 Expression  이 없는 경우 > 발송 대상
            2. 자동발신의 필드조건이 있고 Expression 일치하는 경우 > 발송 대상
         ------------------------------------------------------------------*/
        Map<NotificationAutomaticSetting__c,List<SObject>> validTargets = new Map<NotificationAutomaticSetting__c,List<SObject>>();

        System.debug('i2SEMA_AutoNotificationEvaluation_qu] 발신 조건 개별 판정 :' + recordEventSettingAliasMap);

        // Loop 1 : Trigger Record
        for( SObject record : this.recordEventSettingAliasMap.keySet()){
            // Record 에 걸린 자동화 조건의 필드조건 True,False 값
            Map<NotificationAutomaticSetting__c,Map<String,Boolean>> eventAliasResult = recordEventSettingAliasMap.get(record);

            // Loop 2 : Record 의 자동발신 조건
            for( NotificationAutomaticSetting__c notificationSetting : eventAliasResult.keySet() ){
                String expression                   = notificationSetting.LogicalExpression__c;
                Map<String,Boolean> aliasResults    = eventAliasResult.get(notificationSetting);

                // 발송대상 판정
                Boolean isValid = (i2SEMA_Util.isEmpty(expression) && aliasResults.keySet().isEmpty())
                        || ( 1 == new RT_Expression(expression, aliasResults).eval());

                system.debug('[i2SEMA_AutoNotificationEvaluation_qu] 발신 대상판정 결과 : ' + record.get('Id') + ' - ' + notificationSetting.Id + ' >> ' + isValid  );

                if( isValid ){
                    List<SObject> targetRecords = validTargets.containsKey(notificationSetting) ? validTargets.get(notificationSetting) : new List<SObject>();
                    targetRecords.add(record);
                    validTargets.put(notificationSetting,targetRecords);
                }
            }
        }
        /*------------------------------------------------------------------
         * Notification Group, Notification
            : 자동화 규칙 1건당 1개의 그룹 생성
         ------------------------------------------------------------------*/
        // Notification Group
        Map<NotificationAutomaticSetting__c,NotificationGroup__c> notificationGroupMap = new Map<NotificationAutomaticSetting__c,NotificationGroup__c>();
        for( NotificationAutomaticSetting__c notificationSetting : validTargets.keySet() ){
            NotificationGroup__c notificationGroup = new NotificationGroup__c();
            notificationGroup.IF_Status__c = notificationSetting.IsSchedule__c == true ? 'Pending' : null;
            notificationGroupMap.put(notificationSetting,notificationGroup);
        }
        insert notificationGroupMap.values();

        // Notification
        List<Notification__c> notifications = new List<Notification__c>();
        Datetime currentGMTTime = Datetime.newInstanceGmt(Datetime.now().date(),Datetime.now().time());

        for( NotificationAutomaticSetting__c notificationSetting : validTargets.keySet() ){
            NotificationGroup__c notificationGroup  = notificationGroupMap.get(notificationSetting);
            List<SObject> targetRecords                     = validTargets.get(notificationSetting);

            for( SObject record : targetRecords ){
                Notification__c notification = new Notification__c();

                notification.NotificationGroup__c   = notificationGroup.Id;
                notification.NotificationAutomaticSetting__c = notificationSetting.Id;
                notification.TargetId__c            = record.Id;

                // 예약발신
                notification.IsSendingReservation__c = notificationSetting.IsSchedule__c;
                if( 'Rule Triggered Time'.equalsIgnoreCase(notificationSetting.ScheduleBasedOn__c) && i2SEMA_Util.isNotEmpty(notificationSetting.ScheduleTime__c)){
                    notification.SendingTime__c = currentGMTTime.addMinutes((Integer)(notificationSetting.ScheduleTime__c * 60));
                }
                else if( 'Record Datetime Field'.equalsIgnoreCase(notificationSetting.ScheduleBasedOn__c) && i2SEMA_Util.isNotEmpty(notificationSetting.FieldForSchedule__c)){
                    notification.SendingTime__c = Datetime.valueOf(record.get(notificationSetting.FieldForSchedule__c)).addMinutes((Integer)(notificationSetting.ScheduleTime__c * 60));
                }
                notification.msg_status__c          = notificationSetting.IsSchedule__c == true ? 'Pending' : null;

                // 채널
                notification.Channel__c             = notificationSetting.NotificationTemplate__r.Channel__c;

                // 템플릿
                notification.NotificationTemplate__c    = notificationSetting.NotificationTemplate__c;
                notification.Title__c                   = notificationSetting.NotificationTemplate__r.Title__c;
                notification.RawContents__c             = notificationSetting.NotificationTemplate__r.Content__c;

                // 수신자 & 개인화
                String recipientFieldValue  = (String)record.get(notificationSetting.RecipientField__c);
                String recipientValuePrefix = recipientFieldValue != null ? recipientFieldValue.left(3) : null;
                if( Schema.SObjectType.Account.getKeyPrefix().equals(recipientValuePrefix)){
                    notification.Account__c = recipientFieldValue;
                }
                else if( Schema.SObjectType.Contact.getKeyPrefix().equals(recipientValuePrefix)){
                    notification.Contact__c = recipientFieldValue;
                }
                else if( Schema.SObjectType.Lead.getKeyPrefix().equals(recipientValuePrefix)){
                    notification.Lead__c = recipientFieldValue;
                }
                else if( Schema.SObjectType.User.getKeyPrefix().equals(recipientValuePrefix)){
                    notification.User__c = recipientFieldValue;
                }

                notification.LABEL1__c = i2SEMA_Util.isNotEmpty(notificationSetting.Label1FieldAPI__c)
                                            ? record.get(notificationSetting.Label1FieldAPI__c) instanceof Datetime
                                            ? Datetime.valueOfGmt(String.valueOf(record.get(notificationSetting.Label1FieldAPI__c))).format()
                                            : String.valueOf(record.get(notificationSetting.Label1FieldAPI__c)) : null;
                notification.LABEL2__c = i2SEMA_Util.isNotEmpty(notificationSetting.Label2FieldAPI__c)
                                            ? record.get(notificationSetting.Label2FieldAPI__c) instanceof Datetime
                                            ? Datetime.valueOfGmt(String.valueOf(record.get(notificationSetting.Label2FieldAPI__c))).format()
                                            : String.valueOf(record.get(notificationSetting.Label2FieldAPI__c)) : null;
                notification.LABEL3__c = i2SEMA_Util.isNotEmpty(notificationSetting.Label3FieldAPI__c)
                                            ? record.get(notificationSetting.Label3FieldAPI__c) instanceof Datetime
                                            ? Datetime.valueOfGmt(String.valueOf(record.get(notificationSetting.Label3FieldAPI__c))).format()
                                            : String.valueOf(record.get(notificationSetting.Label3FieldAPI__c)) : null;
                notification.LABEL4__c = i2SEMA_Util.isNotEmpty(notificationSetting.Label4FieldAPI__c)
                                            ? record.get(notificationSetting.Label4FieldAPI__c) instanceof Datetime
                                            ? Datetime.valueOfGmt(String.valueOf(record.get(notificationSetting.Label4FieldAPI__c))).format()
                                            : String.valueOf(record.get(notificationSetting.Label4FieldAPI__c)) : null;
                notification.LABEL5__c = i2SEMA_Util.isNotEmpty(notificationSetting.Label5FieldAPI__c)
                                            ? record.get(notificationSetting.Label5FieldAPI__c) instanceof Datetime
                                            ? Datetime.valueOfGmt(String.valueOf(record.get(notificationSetting.Label5FieldAPI__c))).format()
                                            : String.valueOf(record.get(notificationSetting.Label5FieldAPI__c)) : null;

                notifications.add(notification);
            }
        }

        insert notifications;
        system.debug('[i2SEMA_AutoNotificationEvaluation_qu] 생성된 Notification 건수 : ' + notifications.size());

        // 예약 발신 제외하고 발송 IF 호출
        List<Notification__c> sendNotifications = new List<Notification__c>();
        for(Notification__c notification : notifications ){
            if( notification.IsSendingReservation__c != true ){
                sendNotifications.add(notification);
            }
        }

        // Notification 발송 IF 호출, 테스트 케이스에서 Queueable 체인수행 불가.
        if( !sendNotifications.isEmpty() && !Test.isRunningTest()){
            i2SEMA_IFNotificationSend_qu messageQueue = new i2SEMA_IFNotificationSend_qu(sendNotifications);
            System.enqueueJob(messageQueue);
        }
    }
}