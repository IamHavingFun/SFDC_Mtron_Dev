/****************************************************************************************
  * @filename      : LsMSalesCustomerConsultAuthQa
  * @author        : I2MAX
  * @date          : 2021-05-10
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesCustomerConsultAuthQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author        description
  * ===============================================================
    1.0     2021-05-06          I2MAX           Create
****************************************************************************************/
public with sharing class LsMSalesCustomerConsultAuthQa {

    /**
     * random 4자리 숫자 해당 전화번호로 보낸 뒤, return
     *
     * @param phoneNumber String
     *
     * @return String
     */
    @AuraEnabled
    public static String sendSms(String phoneNumber) {
        // random 4 digit
        String authCode = getAuthCode(phoneNumber);

        if(authCode != 'XXXX' || Test.isRunningTest()) {
            // TODO : 2021-05-12 발송 로직
            sendAuthSMS(phoneNumber, authCode);
        }

        return authCode;
    }

    /**
     * 랜덤 권한 코드
     *
     * @return String
     */
    public static String getAuthCode(String phoneNumber) {
        String authCode = getRandomFourDigitString();

        User user = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId()];

        String checkPhoneNumber = '';
        for(Account acc : [SELECT Id, PersonMobilePhone FROM Account WHERE Dealer__c = :user.AccountId]) {
            if (acc.PersonMobilePhone != null) checkPhoneNumber = acc.PersonMobilePhone;
            checkPhoneNumber = checkPhoneNumber.replaceAll('-', '');
            checkPhoneNumber = checkPhoneNumber.replaceAll(' ', '');
            if (phoneNumber == checkPhoneNumber) {
                authCode = 'XXXX';
                break;
            }
        }
        return authCode;
    }

    /**
     * random 4자리 숫자 String으로 return (중복 제거 x)
     *
     * @return String
     */
    private static String getRandomFourDigitString() {
        return String.valueOf(Integer.valueOf(Math.floor(Math.random() * 9000))).leftPad(4,'0');
    }

    private static void sendAuthSMS(String phoneNumber, String authCode) {
        NotificationGroup__c notiGroup = new NotificationGroup__c();
        notiGroup.TargetId__c = null;
        notiGroup.IF_Status__c = 'Pending';
        insert notiGroup;
        System.debug(notiGroup.Id);

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
        noti.Channel__c = '0';
        noti.Title__c = '[LS엠트론] 휴대전화';
        noti.RawContents__c = '[LS엠트론] 휴대전화 인증번호: ['+authCode+']';
        noti.Content__c = '[LS엠트론] 휴대전화 인증번호: ['+authCode+']';
        insert noti;
        System.debug(noti.id);

        System.enqueueJob(new i2SEMA_IFNotificationSend_qu(new List<Notification__c>{noti}));
    }
}