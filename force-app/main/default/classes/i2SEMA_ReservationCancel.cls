/****************************************************************************************
  * @filename      : i2SEMA_ReservationCancel
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/14 11:24 AM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : i2SEMA_ReservationCancel_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
  * 0.1     2020-03-13 오전 9:33     i2max_ys.seo       Create
    0.1     2020/04/14 11:24 AM     i2max_shlee       Rename NotificationReservationCancel -> i2SEMA_ReservationCancel
****************************************************************************************/
public with sharing class i2SEMA_ReservationCancel {
    /**
     * @description Notification Reservation Cancel
     *                해당 Notification Id, Notification Group Id일 때 Notification Template을 가져와서 I/F호출
     * @param param {Map<String,Object>} 전체 Parameter Wrapper
     * @return {Util_ComponentResponse} 통신 결과 Wrapper
     */
    @AuraEnabled
    public static i2SEMA_ComponentResponse initialize(String recordId) {
        i2SEMA_ComponentResponse response = new i2SEMA_ComponentResponse();

        /*
         * Validation : Is the record Available ?
         */
        if(i2SEMA_Util.isEmpty(recordId)) {
            throw new AuraHandledException(LABEL.i2SEMA_MSG_INVALID_RECORDID);
        }
        System.debug('recordId : '+recordId);
        String idPrefix = recordId.left(3);
        if( !(Schema.SObjectType.Notification__c.getKeyPrefix().equals(idPrefix)
            || Schema.SObjectType.NotificationGroup__c.getKeyPrefix().equals(idPrefix))) {
            throw new AuraHandledException(LABEL.i2SEMA_MSG_INVALID_NOTI_OR_NOTIGROUP_ID);
        }

        //Notification Id일 경우 (Notification 상세화면에서 Retry 버튼 누를 때)
        if(Schema.SObjectType.Notification__c.getKeyPrefix().equals(idPrefix)){
            Notification__c notification = [
                    SELECT Id, NotificationTemplate__c, Validity__c, msg_status__c, ErrorMessage__c
                    FROM Notification__c
                    WHERE Id = :recordId
                    AND msg_status__c = 'Requested'
                    AND Validity__c = TRUE
            ];
            System.debug('notification : '+notification);
            if(!'Requested'.equals(notification.msg_status__c)) {
                throw new AuraHandledException(LABEL.i2SEMA_MSG_CANCEL_INVALID_NOTI_STATUS+notification.ErrorMessage__c);
            }

            Id jobId = System.enqueueJob(new i2SEMA_IFNotificationCancel_qu(notification));

        //NotificationGroup Id일 경우 (Notification Group 상세화면에서 Retry 버튼 누를 때)
        } else if(Schema.SObjectType.NotificationGroup__c.getKeyPrefix().equals(idPrefix)){
            List<Notification__c> notifications = [SELECT Id, NotificationGroup__c, NotificationGroup__r.IF_Status__c
                    , NotificationTemplate__c, Validity__c, msg_status__c, ErrorMessage__c
            FROM Notification__c
            WHERE NotificationGroup__c = :recordId
            AND Validity__c = TRUE
            AND NotificationGroup__r.IF_Status__c = 'Requested'];
//                                                    AND NotificationGroup__r.IF_Status__c IN ('Canceled', 'Failed','Failed request to send','Failed request to cancel')];
            System.debug('notifications : '+notifications);

            if(notifications.isEmpty() && !'Requested'.equals(notifications[0].NotificationGroup__r.IF_Status__c)) {
                throw new AuraHandledException(LABEL.i2SEMA_MSG_CANCEL_INVALID_NOTI_STATUS+notifications[0].NotificationGroup__r.IF_Status__c);
            }

            Integer retryCnt = 0;
            Integer errCnt = 0;
            String errMSG = null;
            for(Notification__c noti : notifications) {
                if(noti.Validity__c) retryCnt++;
                else {
                    errCnt++;
                    errMSG = noti.ErrorMessage__c;
                }
            }

            Id jobId = System.enqueueJob(new i2SEMA_IFNotificationCancel_qu(notifications));
        }

        return response;
    }
}