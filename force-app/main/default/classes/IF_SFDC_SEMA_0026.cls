/****************************************************************************************
  * ProjectName : I2SEMA
  * File Name   : IF_SFDC_SEMA_0026
  * Description : IF_SFDC_SEMA_0026 Class - 메시지 결과 전송 요청 - Bulk
  * Copyright   : Copyright © 2020 i2max All Rights Reserved
  * Author      : namho100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author       Modification
  * ===============================================================
    1.0  2020. 02. 27   ldb3100      Create
****************************************************************************************/
public with sharing class IF_SFDC_SEMA_0026 extends IF_BaseNotiforce {
    private static final String IFID = 'IF_SFDC_SEMA_0026'; // External interface id

   private static String IFURL;

   public class INPUT_T_DATA  {
        public String start_date                  ; // 목록 검색 시작 시간 (YYYY-MM-DD hh:mm:ss)
        public String end_date                    ; // 목록 검색 시작 시간 (YYYY-MM-DD hh:mm:ss)
        public String seq                         ; // 메시지 고유 아이디, sequence
        public String per_seq                     ; // 개인 고유 아이디
        public String noti_group_id               ; // SFDC 메시지 아이디
        public String noti_id                     ; // SFDC 개인화 필드 아이디
        public String recipient_num               ; // 수신자 번호
        public String templete_type               ; // SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009     
   }

   public class OUTPUT_T_DATA {  }

   /**
    * inputBody / outputBody innerClass
    */
   public class InputBody {
       public List<INPUT_T_DATA> t_data;
       public InputBody() {
        t_data = new List<INPUT_T_DATA>();
       }
   }
   public class OutputBody {
       public List<OUTPUT_T_DATA> t_data;
       public OutputBody() {
        t_data = new List<OUTPUT_T_DATA>();
       }
   }
   /**
    * Input / Output innerClass
    */
   public class Input extends Headers{
       public InputBody payload;
       public Input(){
           payload = new InputBody();
       }
   }
   public class Output extends Headers{
       public OutputBody payload;
       public Output(){
           payload = new OutputBody();
       }
   }
   /**
    * DIH
    * Input / Output innerClass
    */
   public class InputDIH {
       public Input request;
       public InputDIH(){
           request = new Input();
       }
   }
   public class OutputDIH {
       public Output response;
       public OutputDIH(){
           response = new Output();
       }
   }
   
   /**
    * constructor
    * (endpoint URL setting)
    */
   private IF_SFDC_SEMA_0026() {
       System.debug(IFID+' call');
       Notiforce_IF_INFO__c ifInfo = getIfinfo(IFID);  // DML
       IFURL = ifInfo.URL__c;
       // IFURL = ifInfo.URL__c + '.json';
       System.debug('Original URL : ' + ifInfo.URL__c);
       System.debug(ifInfo.TITLE__c+' call start');
   }

   /**
    * singleton
    */
   private static IF_SFDC_SEMA_0026 sInstance = null;
   public static IF_SFDC_SEMA_0026 getInstance() {
       if (sInstance == null) {
           sInstance = new IF_SFDC_SEMA_0026();
       }
       return sInstance;
   }
   
   /**
    * JSON
    * Schedulable
    */
   public OutputDIH execute(InputDIH inputObj) {
       OutputDIH outputObj = new OutputDIH();

       String req = null;
       String res = null;

       IF_SFDC_SEMA_0026_BIZ bizInstance = null;

       Input  inputReq  = inputObj.Request  ;
       Output outputRes = null              ;
       try {
           // 로그 timeTemp, Request_to_DIH_Time 세팅
           IF_BaseNotiforce.logInit('SND');

           inputReq.Header = new IF_BaseNotiforce.InputHeader(IFID);

           inputReq.Header.ifSenderGp      = 'I2MAX';
           inputReq.Header.ifSender        = 'SFDC';
           inputReq.Header.ifReceiverGp    = 'I2MAX';
           inputReq.Header.ifReceiver      = 'SEMA';

           // 로그 MSGGID, IFID, IFDATE 세팅
           IF_BaseNotiforce.logStart(inputReq.Header);

           bizInstance = IF_SFDC_SEMA_0026_BIZ.getInstance();

           /* 업무 개발자에 의해 변경되어야 하는 부분 시작(선행) */
           inputReq.Payload = bizInstance.pre(inputReq.Payload);
           /* 업무 개발자에 의해 변경되어야 하는 부분 끝(선행) */

           // JSON TO STRING
           req = JSON.serialize(inputObj);

           // 로그 input, Request_Processing_Time 세팅
           IF_BaseNotiforce.logProcess('STEP1', req);

           if(Test.isRunningTest() && IF_BaseNotiforce.crashTest) {  // Purposely crash test.
               throw new DmlException('Dml Exception');
           }
           //system.debug('req='+req);

           // RESPONSE SET
           res = webCallOut(req, IFURL);

           // STRING(JSON) TO OBJECT
           outputObj = (OutputDIH)JSON.deserialize(res, OutputDIH.class);

           outputRes = outputObj.Response;

           /* 업무 개발자에 의해 변경되어야 하는 부분 시작(후행) */
           outputRes.Payload = bizInstance.post(inputReq.Payload, outputRes.Payload);
           /* 업무 개발자에 의해 변경되어야 하는 부분 끝(후행) */

       } catch(Exception e) {
           // 에러내용 debug 출력
           IF_CommNotiforce.errorDebug(e);

           outputRes = outputObj.Response;

           // 내부오류의 경우 ResultCode 'E'로
           outputRes.Header = new IF_BaseNotiforce.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);

           // error header value setup
           outputRes.Header = IF_BaseNotiforce.setOutputHeader(outputRes.Header, inputReq.Header, e);
       }
       // 로그 Response_Processing_Time, Respone_from_DIH_Time 세팅
       IF_BaseNotiforce.logProcess('STEP2', res);
       res = '';
       // 로그 파일 및 row insert
       IF_BaseNotiforce.logEnd(outputRes.Header);

       return outputObj;
   }
}