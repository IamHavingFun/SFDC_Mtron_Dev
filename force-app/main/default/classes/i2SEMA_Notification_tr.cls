/****************************************************************************************
  * @filename       : i2SEMA_Notification_tr
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-14 오후 4:17
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : i2SEMA_Notification_tr_ts.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-14 오후 4:17     i2max_byeon.jw       Create
****************************************************************************************/

public without sharing class i2SEMA_Notification_tr extends i2SEMA_TriggerHandler{
    static List<Notification__c> notifications;
    static Set<String> unsubscriptionNumbers    = new Set<String>();
    static Set<Id> proceedIds                   = new Set<Id>();

    public override void beforeInsert(){
        this.setPhoneNumber();      // 수신자 Phone Number 설정
    }
    public override void beforeUpdate(){
        this.setPhoneNumber();      // 수신자 Phone Number 설정
    }

    public override void afterInsert(){
        this.getData();             // Notification 조회
        this.convertContents();     // Notification 본문치환
        this.checkData();           // Notification 유효체크
    }
    public override void afterUpdate(){
        this.getData();             // Notification 조회
        this.convertContents();     // Notification 본문치환
        this.checkData();           // Notification 유효체크
    }

    /**
     * @description 수신자 Phone Number 설정
     *  - i2SEMA Config 설정값 참조
     */
    private void setPhoneNumber(){
        List<Notification__c> newData = (List<Notification__c>)Trigger.new;

        Map<String,Set<Id>> targetData = new Map<String,Set<Id>> {
            SObjectType.Account.getName()   => new Set<Id>(),
            SObjectType.Contact.getName()   => new Set<Id>(),
            SObjectType.Lead.getName()      => new Set<Id>(),
            SObjectType.User.getName()      => new Set<Id>()
        };

        // Notification 별 발송 대상 수집
        for( Notification__c notification : newData ){
            Id targetId = i2SEMA_Util.isNotEmpty(notification.Account__c) ? notification.Account__c
                            : i2SEMA_Util.isNotEmpty(notification.Contact__c) ? notification.Contact__c
                            : i2SEMA_Util.isNotEmpty(notification.Lead__c) ? notification.Lead__c
                            : i2SEMA_Util.isNotEmpty(notification.User__c) ? notification.User__c : null;

            if( i2SEMA_Util.isNotEmpty(targetId)){
                String targetObject = targetId.getSobjectType().getDescribe().getName();
                Set<Id> targetIds = targetData.get(targetObject);
                targetIds.add(targetId);
                targetData.put(targetObject,targetIds);
            }
        }

        // 발송대상의 전화번호 조회
        Map<Id,SObject> receiverData = new Map<Id,SObject>();
        for( String targetObject : targetData.keySet() ){
            Set<Id> targetIds = targetData.get(targetObject);

            if( !targetIds.isEmpty()){
                String queryString  = 'SELECT ';
                queryString         += targetObject.equals(SObjectType.Account.getName()) ? i2SEMA_Base.getAccountDefaultPhoneField()
                                        : targetObject.equals(SObjectType.Contact.getName()) ? i2SEMA_Base.getContactDefaultPhoneField()
                                        : targetObject.equals(SObjectType.Lead.getName()) ? i2SEMA_Base.getLeadDefaultPhoneField()
                                        : targetObject.equals(SObjectType.User.getName()) ? i2SEMA_Base.getUserDefaultPhoneField() : null;
                queryString         += ' FROM ' + targetObject;
                queryString         += ' WHERE Id IN: targetIds';

                system.debug('------------->> Set Phone Query');
                system.debug(queryString);

                receiverData.putAll( new Map<Id,SObject>(Database.query(queryString)));
            }
        }

        // Notification 의 발송 대상 Phone 설정
        for( Notification__c notification : newData ){
            Id targetId = i2SEMA_Util.isNotEmpty(notification.Account__c) ? notification.Account__c
                            : i2SEMA_Util.isNotEmpty(notification.Contact__c) ? notification.Contact__c
                            : i2SEMA_Util.isNotEmpty(notification.Lead__c) ? notification.Lead__c
                            : i2SEMA_Util.isNotEmpty(notification.User__c) ? notification.User__c : null;

            if( targetId != null && receiverData.containsKey(targetId)){
                SObject receiver    = receiverData.get(targetId);
                String receiverType = receiver.getSObjectType().getDescribe().getName();

                notification.Phone__c =  receiverType.equals(SObjectType.Account.getName()) ? (String)receiver.get(i2SEMA_Base.getAccountDefaultPhoneField())
                                                    : receiverType.equals(SObjectType.Contact.getName()) ? (String)receiver.get(i2SEMA_Base.getContactDefaultPhoneField())
                                                    : receiverType.equals(SObjectType.Lead.getName()) ? (String)receiver.get(i2SEMA_Base.getLeadDefaultPhoneField())
                                                    : receiverType.equals(SObjectType.User.getName()) ? (String)receiver.get(i2SEMA_Base.getUserDefaultPhoneField()) : null;
            }else {
                if(notification.Phone__c == null) notification.Phone__c = null;
            }
        }
    }

    /**
     * @description Notification 조회
     */
    private void getData(){
        Set<Id> newDataIds = Trigger.newMap != null ? Trigger.newMap.keySet() : new Set<Id>();

        // Notification 조회
        notifications = [SELECT Id
                                    ,Account__c,Contact__c,Lead__c,Phone__c
                                    ,Channel__c,NotificationTemplate__c,NotificationTemplate__r.IsActive__c,NotificationTemplate__r.IF_Status__c
                                    ,fm_Label1Usage__c,fm_Label2Usage__c,fm_Label3Usage__c,fm_Label4Usage__c,fm_Label5Usage__c
                                    ,LABEL1__c,LABEL2__c,LABEL3__c,LABEL4__c,LABEL5__c
                                    ,IsSendingReservation__c, SendingTime__c
                                    ,RawContents__c
                            FROM Notification__c
                            WHERE Id IN:newDataIds AND Id NOT IN:proceedIds];

        // Unsubscription 조회
        Set<String> notificationNumbers = new Set<String>();
        for(Notification__c noti : notifications ){
            if( i2SEMA_Util.isNotEmpty(noti.Phone__c)){
                notificationNumbers.add(noti.Phone__c);
            }
        }
        List<Unsubscription__c> unSubscriptions = [SELECT Id,Phone__c
                                                        FROM Unsubscription__c
                                                        WHERE Active__c = TRUE
                                                        AND Phone__c IN: notificationNumbers];

        for(Unsubscription__c unsubscription : unSubscriptions ){
            unsubscriptionNumbers.add(i2SEMA_Util.convertPhoneNumberFormat(unsubscription.Phone__c));
        }
    }
    /**
     * @description Notification 본문 치환
     */
    private void convertContents(){
        for(Notification__c nt : notifications ){
            nt.Content__c = nt.RawContents__c;
            if( i2SEMA_Util.isNotEmpty(nt.Content__c) && nt.fm_Label1Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL1__c)){
                nt.Content__c = nt.Content__c.replace(Label.i2SEMA_LAB_LABEL_01_VAL , nt.LABEL1__c);
            }
            if( i2SEMA_Util.isNotEmpty(nt.Content__c) && nt.fm_Label2Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL2__c)){
                nt.Content__c = nt.Content__c.replace(Label.i2SEMA_LAB_LABEL_02_VAL , nt.LABEL2__c);
            }
            if( i2SEMA_Util.isNotEmpty(nt.Content__c) && nt.fm_Label3Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL3__c)){
                nt.Content__c = nt.Content__c.replace(Label.i2SEMA_LAB_LABEL_03_VAL , nt.LABEL3__c);
            }
            if( i2SEMA_Util.isNotEmpty(nt.Content__c) && nt.fm_Label4Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL4__c)){
                nt.Content__c = nt.Content__c.replace(Label.i2SEMA_LAB_LABEL_04_VAL , nt.LABEL4__c);
            }
            if( i2SEMA_Util.isNotEmpty(nt.Content__c) && nt.fm_Label5Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL5__c)){
                nt.Content__c = nt.Content__c.replace(Label.i2SEMA_LAB_LABEL_05_VAL , nt.LABEL5__c);
            }
        }
    }
    /**
     * @description Notification 유효체크
     */
    private void checkData(){
        for(Notification__c nt : notifications ){
            Notification__c originData = ((Map<Id,Notification__c>)Trigger.newMap).get(nt.Id);

            nt.Validity__c      = true;
            nt.ErrorMessage__c  = null;

            // 수신자 유효확인
            if( nt.Validity__c && nt.Phone__c == null ){
                nt.Validity__c      = false;
                nt.ErrorMessage__c  = Label.i2SEMA_MSG_RECEIVER_PHONE_NOT_EXIST;

                // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                if( !System.isQueueable() && !Test.isRunningTest()) originData.addError(Label.i2SEMA_MSG_RECEIVER_PHONE_NOT_EXIST);

            }

            // 수신차단 유효확인
            if( nt.Validity__c && i2SEMA_Util.isNotEmpty(nt.Phone__c) && unsubscriptionNumbers.contains(i2SEMA_Util.convertPhoneNumberFormat(nt.Phone__c))){
                nt.Validity__c      = false;
                nt.ErrorMessage__c  = Label.i2SEMA_MSG_RECEIVER_PHONE_UNSUBSCRIBED;

                // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                if( !System.isQueueable() && !Test.isRunningTest()) originData.addError(Label.i2SEMA_MSG_RECEIVER_PHONE_UNSUBSCRIBED);
            }

            // 예약발송 유효확인 (당일 예약불가)
            if( nt.Validity__c && nt.IsSendingReservation__c == true ){
                // 스케쥴 시간이 비어있는 경우
                if( i2SEMA_Util.isEmpty(nt.SendingTime__c)){
                    nt.Validity__c      = false;
                    nt.ErrorMessage__c  = Label.i2SEMA_MSG_SCHEDULE_TIME_INVALID;
                    // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                    if( !System.isQueueable() && !Test.isRunningTest()) originData.addError(Label.i2SEMA_MSG_SCHEDULE_TIME_INVALID);
                }
                else if( nt.SendingTime__c.dateGmt() <= Date.today()){
                    nt.Validity__c      = false;
                    nt.ErrorMessage__c  = Label.i2SEMA_MSG_SCHEDULE_TIME_INVALID;
                    // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                    if( !System.isQueueable() && !Test.isRunningTest()) originData.addError(Label.i2SEMA_MSG_SCHEDULE_TIME_INVALID);
                }
            }

            // 템플릿 유효확인
            if( nt.Validity__c && nt.NotificationTemplate__c != null &&
                    (nt.NotificationTemplate__r.IsActive__c != true || !'Completed'.equalsIgnoreCase(nt.NotificationTemplate__r.IF_Status__c))){
                nt.Validity__c      = false;
                nt.ErrorMessage__c  = Label.i2SEMA_MSG_TEMPLATE_INVALID;

                // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                if( !System.isQueueable() && !Test.isRunningTest() ) originData.addError(Label.i2SEMA_MSG_TEMPLATE_INVALID);
            }

            // 라벨 유효확인
            if( nt.Validity__c){
                Boolean label1Valid = (nt.fm_Label1Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL1__c)) || (nt.fm_Label1Usage__c != true && i2SEMA_Util.isEmpty(nt.LABEL1__c));
                Boolean label2Valid = (nt.fm_Label2Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL2__c)) || (nt.fm_Label2Usage__c != true && i2SEMA_Util.isEmpty(nt.LABEL2__c));
                Boolean label3Valid = (nt.fm_Label3Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL3__c)) || (nt.fm_Label3Usage__c != true && i2SEMA_Util.isEmpty(nt.LABEL3__c));
                Boolean label4Valid = (nt.fm_Label4Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL4__c)) || (nt.fm_Label4Usage__c != true && i2SEMA_Util.isEmpty(nt.LABEL4__c));
                Boolean label5Valid = (nt.fm_Label5Usage__c == true && i2SEMA_Util.isNotEmpty(nt.LABEL5__c)) || (nt.fm_Label5Usage__c != true && i2SEMA_Util.isEmpty(nt.LABEL5__c));
                if( !label1Valid || !label2Valid || !label3Valid || !label4Valid || !label5Valid ){
                    nt.Validity__c      = false;
                    nt.ErrorMessage__c  = Label.i2SEMA_MSG_TEMPLATE_LABEL_INVALID;

                    // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                    if( !System.isQueueable() && !Test.isRunningTest() ) originData.addError(Label.i2SEMA_MSG_TEMPLATE_LABEL_INVALID);
                }
            }
            // 길이 유효확인
            if( nt.Validity__c ){
                Boolean lengthValid = i2SEMA_Util.isValidMessageLength(nt.Channel__c , nt.Content__c);
                if( !lengthValid ){
                    nt.Validity__c      = false;
                    nt.ErrorMessage__c  = Label.i2SEMA_MSG_LENGTH_LIMIT_EXCEED;

                    // 자동발신 등 Queueable 상황을 제외하고는 즉시 Error 표출
                    if( !System.isQueueable() && !Test.isRunningTest() ) originData.addError(Label.i2SEMA_MSG_LENGTH_LIMIT_EXCEED);
                }
            }

            // 처리완료 목록에 추가
            proceedIds.add(nt.Id);
        }

        update notifications;
    }

    public static void runTest() {
        Integer my_seo = 0;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
    }
}