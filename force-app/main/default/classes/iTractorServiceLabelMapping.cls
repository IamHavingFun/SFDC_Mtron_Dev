/*
 * ----------------------------------------
 * iTractorServiceLabelMapping
 * version:1.0.0
 * 작성일:2021-11-03
 * 작성자:i2max
 * 7가지의 아이트렉터 라벨에 대한 매핑 처리.
 *
 * ----------------------------------------
 */

public with sharing class iTractorServiceLabelMapping {

    //소모품1 : [아이트랙터_소모품]일반_메시지_001
    /*
    LABEL1[고객명]
    LABEL2[모델명, 기대번호]
    LABEL3[코드메시지]
    LABEL4[대리점 명 : 대리점 전화번호]
    */
    public static iTractorlabels Supplies1(Asset ast, String errCode){
        iTractorlabels itlabels = new iTractorlabels();

        System.debug(' 기대번호 '+ast.Name);

        //isNHContact__c 농협고객, 고객, 기타
        if(ast.isNHContact__c =='개인고객'){
            itlabels.Label1 = iTractorServiceUtil.masking_name(ast.Account.Name) ;
            //itlabels.Label1 = iTractorServiceUtil.masking_name(ast.Account.LastName+''+ast.Account.FirstName) ;
            itlabels.Phone  = ast.Account.PersonMobilePhone;
        }
        if(ast.isNHContact__c =='농협고객'){
            itlabels.Label1 = iTractorServiceUtil.masking_name(ast.Customer__r.Name) ;
            //itlabels.Label1 = iTractorServiceUtil.masking_name(ast.Customer__r.LastName+''+ast.Customer__r.FirstName) ;
            itlabels.Phone  =ast.Customer__r.PersonMobilePhone ;
        }
        itlabels.Label2 = ast.Product2.Name +' ' + ast.Name;
        itlabels.Label3 = errCode;
        itlabels.Label4 = ast.Dealer__r.Name+' : '+ ast.Dealer__r.Mobile__c;
        itlabels.accId = ast.id;

        System.debug(ast.isNHContact__c);
        System.debug( ast.Account.PersonMobilePhone +']['+ast.Customer__r.PersonMobilePhone);

        System.debug(itlabels.Phone);


        return itlabels;
    }


    //소모품2 : [아이트랙터_소모품]타입1_메시지_001
    /*
    LABEL1[고객명]
    LABEL2[모델명, 기대번호]
    LABEL3[대리점 명 : 대리점 전화번호]
    */
    public static iTractorlabels Supplies2(Asset ast){
        iTractorlabels itlabels = new iTractorlabels();
        if(ast.isNHContact__c =='개인고객'){
            itlabels.Label1 = iTractorServiceUtil.masking_name(ast.Account.Name) ;
            //itlabels.Label1 = iTractorServiceUtil.masking_name(ast.Account.Name+''+ast.Account.FirstName) ;
            itlabels.Phone  = ast.Account.PersonMobilePhone;
        }
        if(ast.isNHContact__c =='농협고객'){
            itlabels.Label1 = iTractorServiceUtil.masking_name(ast.Customer__r.Name) ;
            //itlabels.Label1 = iTractorServiceUtil.masking_name(ast.Customer__r.LastName+''+ast.Customer__r.FirstName) ;
            itlabels.Phone  =ast.Customer__r.PersonMobilePhone ;
        }

        itlabels.Label2 = ast.Product2.Name +' ' + ast.Name;
        itlabels.Label3 = ast.Dealer__r.Name+' : '+ ast.Dealer__r.Mobile__c;
        itlabels.accId = ast.id;
        return itlabels;
    }

    //소모품3 : [아이트랙터_소모품]타입2_메시지_001
    /*
    LABEL1[고객명]
    LABEL2[모델명, 기대번호]
    LABEL3[코드메시지]
    LABEL4[최초 메시지]
    LABEL5[대리점 명 : 대리점 전화번호]
    */

    public static iTractorlabels Supplies3(Asset ast , String errCode, String firstMsg){
        iTractorlabels itlabels = new iTractorlabels();
        if(ast.isNHContact__c =='개인고객'){
            itlabels.Label1 = iTractorServiceUtil.masking_name(ast.Account.Name) ;
            //itlabels.Label1 = iTractorServiceUtil.masking_name(ast.Account.LastName+''+ast.Account.FirstName) ;
            itlabels.Phone  = ast.Account.PersonMobilePhone;
        }
        if(ast.isNHContact__c =='농협고객'){
            itlabels.Label1 = iTractorServiceUtil.masking_name(ast.Customer__r.Name) ;
            //itlabels.Label1 = iTractorServiceUtil.masking_name(ast.Customer__r.LastName+''+ast.Customer__r.FirstName) ;
            itlabels.Phone  =ast.Customer__r.PersonMobilePhone ;
        }

        itlabels.Label2 = ast.Product2.Name +' ' + ast.Name;
        itlabels.Label3 = errCode;
        itlabels.Label4 = firstMsg;
        itlabels.Label5 = ast.Dealer__r.Name+' : '+ ast.Dealer__r.Mobile__c;
        itlabels.Phone  =(ast.Account.IsPersonAccount)? ast.Account.PersonMobilePhone : ast.Customer__r.PersonMobilePhone ;
        itlabels.accId = ast.id;
        return itlabels;
    }

    //경고1 : [아이트랙터_경고]고객_메시지_001
    /*
    LABEL1[고객명]
    LABEL2[모델명, 기대번호]
    LABEL3[코드메시지]
    LABEL4[대리점 명 : 대리점 전화번호]
    * */
    /*public static iTractorlabels Warning1(String astId){
        iTractorlabels itlabels = new iTractorlabels();
        return itlabels;
    }*/

    //경고2 : [아이트랙터_경고]농협_메시지_001

    /*
    LABEL1[모델명, 기대번호]
    LABEL2[고객명]
    LABEL3[코드메시지]
    LABEL4[농협명]
    */
    /*public static iTractorlabels Warning2(String astId){
        iTractorlabels itlabels = new iTractorlabels();
        return itlabels;
    }*/

    //경고3 : [아이트랙터_경고]대리점_메시지_001
    /*
    LABEL1[모델명, 기대번호]
    LABEL2[고객명]
    LABEL3[코드메시지]
    */
/*    public static iTractorlabels Warning3(String astId){
        iTractorlabels itlabels = new iTractorlabels();
        return itlabels;
    }*/

    //고장1 : [아이트랙터_고장]대리점_메시지_001
    /*
    LABEL1[모델명, 기대번호]
    LABEL2[고객명]
    LABEL3[코드, 코드메시지]
    */
/*    public static iTractorlabels Breakdown1(String astId){
        iTractorlabels itlabels = new iTractorlabels();
        return itlabels;
    }*/

    //고장2 : [아이트랙터_고장]농협_메시지_001
    /*
    LABEL1[모델명, 기대번호]
    LABEL2[고객명]
    LABEL3[코드, 코드메시지]
    LABEL4[농협명]
    */

/*    public static iTractorlabels Breakdown2(String astId){
        iTractorlabels itlabels = new iTractorlabels();
        return itlabels;
    }*/

    public class iTractorlabels {
        public String Label1 {get;set;}
        public String Label2 {get;set;}
        public String Label3 {get;set;}
        public String Label4 {get;set;}
        public String Label5 {get;set;}
        public String Phone {get;set;}
        public String err {get;set;}
        public String accId {get;set;}


        public iTractorlabels(){
            this.Label1=null;
            this.Label2=null;
            this.Label3=null;
            this.Label4=null;
            this.Label5=null;
            this.Phone=null;
            this.err =null;
            this.accId=null;

        }
    }


}