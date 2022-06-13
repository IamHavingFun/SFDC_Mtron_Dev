/****************************************************************************************
  * @filename      : I2ComCustomNotiService
  * @author        : I2MAX
  * @date          : 2020-12-29 오후 5:19
  * @group         :
  * @group-content :
  * @description   : 커스텀 노티 전송..
  *                  사용법.
					I2ComCustomNotiService.send(new I2ComCustomNotiService.NotiVO(
							'a0W0w000000mEEsEAM',
							'테스트..',
							'테스트..테스트..테스트...',
							new Set<String> {UserInfo.getUserId()}
					));
  * @tester        : I2ComCustomNotiService_ts.cls
  * @reference     :
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-12-29 오후 5:19      I2MAX               Create
****************************************************************************************/
public with sharing class I2ComCustomNotiService {
	public static CustomNotificationType customNotificationType {get;set;}
	static {
		customNotificationType = [
				SELECT Id, DeveloperName
				FROM CustomNotificationType
				WHERE DeveloperName='Custom_Notification'
		];
	}

	/**
	 * Custom Notification 발송.
	 * @param noti
	 */
	public static void send(NotiVO noti) {
		Messaging.CustomNotification notification = new Messaging.CustomNotification();
		notification.setTitle(noti.title);
		String body = noti.body;

		notification.setBody(body);
		notification.setNotificationTypeId(customNotificationType.Id);
		notification.setTargetId(noti.targetId);

		// Notification 전송
		try {
			if(noti.recipientsIds != null) notification.send(noti.recipientsIds);
		} catch(Exception e) {
			System.debug(e.getStackTraceString());
		}
	}

	/**
	 * 내 출하건보다 먼저 출하 되면 알림.
	 * @param targetList
	 */
	public static void sendDeliveryNoticeForLMS(List<NotiVO> targetList) {
		NotificationGroup__c notiGroup = new NotificationGroup__c();
		notiGroup.TargetId__c = null;
		notiGroup.SendType__c = '출하지연알림';
		notiGroup.IF_Status__c = 'Pending';
		insert notiGroup;
		System.debug(notiGroup.Id);

		List<Notification__c> notifications = new List<Notification__c>();
		for(NotiVO target : targetList) {
			for(String phoneNumber : target.recipientsIds) {
				Notification__c noti = new Notification__c();
				noti.TargetId__c = null;
				noti.Phone__c = phoneNumber;
				noti.NotificationTemplate__c = null;
				noti.Lead__c = null;
				noti.Account__c = null;
				noti.User__c = null;
				noti.Contact__c = null;
				noti.LABEL1__c = null;
				noti.LABEL2__c = null;
				noti.LABEL3__c = null;
				noti.LABEL4__c = null;
				noti.LABEL5__c = null;
				noti.IsSendingReservation__c = false;
				noti.SendingTime__c = Datetime.now();
				noti.msg_status__c = null;
				noti.NotificationGroup__c = notiGroup.Id;
				noti.Channel__c = '3';  // LMS
				noti.Title__c = target.title;
				noti.RawContents__c = target.body;
				noti.Content__c = target.body;
				notifications.add(noti);
			}
		}
		insert notifications;
		System.enqueueJob(new i2SEMA_IFNotificationSend_qu(notifications));
	}

	/**
	 * Noti VO
	 */
	public class NotiVO {
		public String targetId {get;set;}
		public String title {get;set;}
		public String body {get;set;}
		public Set<String> recipientsIds {get;set;}

		public NotiVO (String targetId, String title, String body, Set<String> recipientsIds) {
			this.targetId       = targetId;
			this.title          = title;
			this.body           = body;
			this.recipientsIds  = recipientsIds;
		}
	}

}