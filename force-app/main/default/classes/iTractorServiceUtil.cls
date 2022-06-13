/**
 * Created by ms on 2021-11-03.
 */
/*
 * ----------------------------------------
 * iTractorServiceUtil
 * version:1.0.0
 * 작성일:2021-11-03
 * 작성자:i2max
 * ----------------------------------------
 */

public with sharing class iTractorServiceUtil {


    public static String validate(Asset ast){
        // 1. Account가 고객이면 -> 일반고객
        // 2. Account가 농협이면 실고객이 있으면 보내고, 없으면 보내지않는다.(에러)
        // 3. Account 와 Customer가 같으면 일반고객
        // 4. 전화번호가 없으면 에러
        // 5. ast 없으면 에러
        // 6. AccountId 없으면 에러
        // 7. AccountId가 농협이고, Customer__c 없으면 에러
        // 8. Dealer가 없으면 에러

        String msg ='';
        if(ast == null){
            msg='맞는 기대번호가 없습니다.';
        }

        if(ast != null){
            if(ast.isNHContact__c.contains('기타')){
                msg='맞는 고객 정보가 없습니다.';
            }
            else if(ast.isNHContact__c.contains('개인고객')  && ast.AccountID ==null){
                msg='고객 정보가 없습니다.(개인고객)';
            }
            else if(ast.isNHContact__c.contains('농협고객')  && ast.Customer__c ==null){
                msg='고객 정보가 없습니다.(농협고객)';
            }

            else if(ast.isNHContact__c.contains('개인고객')  && ast.Account.PersonMobilePhone ==null){
                msg='고객 전화번호가 없습니다.(개인고객)';
            }
            else if(ast.isNHContact__c.contains('농협고객')  && ast.Customer__r.PersonMobilePhone ==null){
                msg='고객 전화번호가 없습니다.(농협고객)';
            }
            else if(ast.Dealer__c ==null){
                msg='대리점정보가 없습니다.';
            }
        }

        return msg;
    }

    public static String getCodeMsg(String type, String errorCode){
        String codeMsg ='';

        for(iTractorErrorCode__c i :[
                Select
                        id,
                        Name,
                        ErrorMessage__c
                FROM iTractorErrorCode__c
                WHERE ErrorCode__c =: errorCode
                AND ErrorType__c = : type
        ]
        ){
            codeMsg = i.ErrorMessage__c;
        }

        return codeMsg;
    }

    /**
     *
     * @param type : 소모품, 경고,고장 구분
     * @param guestType
     *
     * @return : Map<String,id>
     */
    public static  MAP<String,id> getTemplateMapInfo(String type, String guestType ){

        //쿼리 작업
        List<iTractorTemplateMap__c > iTTMapList= [
                SELECT
                        id,
                        name,
                        Guest_Target__c,        //고객
                        Guest_Template__c,      //고객 탬플릿
                        NH_Target__c,           //농협
                        NH_Template__c,         //농협탬플릿
                        NHGuest_Target__c,      //농협고객
                        NHGuest_Template__c,    //농협고객탬플릿
                        Repairman_Target__c,    //영업기사
                        Repairman_Template__c,  //영업기사 탬플릿
                        Agent_Target__c,        //대리점
                        Agent_Template__c       //대리점 탬플릿
                FROM iTractorTemplateMap__c
                WHERE Product_Type__c =: type
                AND Guest_Type__c =: guestType
        ];
        //쿼리 작업


        System.debug('type' + type);

        System.debug('Guest_Type__c' + guestType);
        MAP<String,id> itMap = new MAP<String,id>();

        for(iTractorTemplateMap__c  t : iTTMapList){
            if(t.Guest_Target__c)       itMap.put('개인고객', t.Guest_Template__c);
            if(t.NH_Target__c)          itMap.put('농협', t.NH_Template__c);
            if(t.NHGuest_Target__c)     itMap.put('농협고객', t.NHGuest_Template__c);
            if(t.Repairman_Target__c)   itMap.put('영업소기사', t.Repairman_Template__c);
            if(t.Agent_Target__c)       itMap.put('대리점', t.Agent_Template__c);
        }

        return itMap;
    }

    public static id getNotiGroup(){
        //Notification그룹생성
        NotificationGroup__c notiGroup = new NotificationGroup__c();
        notiGroup.TargetId__c = null;
        notiGroup.IF_Status__c = 'Pending';
        insert notiGroup;
        System.debug(notiGroup.Id);

        return notiGroup.Id;

    }

    public static Notification__c addNotification(id notiGroupId, iTractorServiceLabelMapping.iTractorlabels labels , NotificationTemplate__c nt){
        //Notification생성
        Notification__c noti = new Notification__c();
        noti.Phone__c = labels.Phone;
        noti.NotificationTemplate__c = nt.id;
        noti.LABEL1__c = (nt.LABEL1__c) ? labels.Label1 :null;
        noti.LABEL2__c = (nt.LABEL2__c) ? labels.Label2 :null;
        noti.LABEL3__c = (nt.LABEL3__c) ? labels.Label3 :null;
        noti.LABEL4__c = (nt.LABEL4__c) ? labels.Label4 :null;
        noti.LABEL5__c = (nt.LABEL5__c) ? labels.Label5 :null;
        noti.IsSendingReservation__c = false;
        noti.SendingTime__c = Datetime.now();
        noti.msg_status__c = null;
        noti.NotificationGroup__c = notiGroupId;
        noti.Channel__c = '3';
        noti.Title__c = nt.Title__c;
        noti.RawContents__c = nt.Content__c;
        noti.Content__c = nt.Content__c;

        return noti;
    }



    public static String masking_name(String val){
        System.debug(val);
        String mask_name = val.replaceAll( ' ','');

        String result ;
        if('' != mask_name){

            System.debug(mask_name.length());
            String a;
            String b;
            Integer c = 0;
            if(3 > mask_name.length()){
                a = mask_name.left(1);
            }else if(4 > mask_name.length()){
                a = mask_name.left(1);
                c = mask_name.length()-2;
                b = mask_name.right(1);
            }else if(5 > mask_name.length()){
                a = mask_name.left(1);
                c = mask_name.length()-2;
                b = mask_name.right(1);
            }else if(6 > mask_name.length()){
                a = mask_name.left(1);
                c = mask_name.length()-2;
                b = mask_name.right(1);
            }else{
                a = mask_name.left(2);
                c = mask_name.length()-4;
                b = mask_name.right(2);
            }

            String d ='*';
            for(Integer i=1; i<c ; i++){
                d += '*';
            }


            if(2 < mask_name.length()){
                result = a+d+b;
            }else{
                result = a+d;
            }
        }else{
            result = '';
        }

        return result;
    }



}