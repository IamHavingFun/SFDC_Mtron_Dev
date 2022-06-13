/****************************************************************************************
  * ProjectName : I2SEMA
  * File Name   : IF_SFDC_SEMA_0002
  * Description : IF_SFDC_SEMA_0002 Class - 메시지 전송
  * Copyright   : Copyright © 2020 i2max All Rights Reserved
  * Author      : namho100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author       Modification
  * ===============================================================
    1.0  2020. 01. 20   namho100      Create
****************************************************************************************/
public with sharing class IF_SFDC_SEMA_0002 extends IF_BaseNotiforce {
	 private static final String IFID = 'IF_SFDC_SEMA_0002'; // External interface id

    private static String IFURL;

    public class INPUT_T_DATA  {
        public	String date_client_req;
        public	String content;
        public	String callback;
        public	String service_type;
        public	String broadcast_yn;
        public	String recipient_num;
        public	String attach_file_name;
        public	String priority;
        public	String mt_refkey;
        public	String template_code;
        public	String msg_type;
        public	String img_url;
        public	String img_link;
    }

    public class OUTPUT_T_DATA { }

    /**
     * inputBody / outputBody innerClass
     */
    public class InputBody {
        public List<INPUT_T_DATA> T_DATA;
        public InputBody() {
            T_DATA = new List<INPUT_T_DATA>();
        }
    }
    public class OutputBody {
    	public List<OUTPUT_T_DATA> T_DATA;
        public OutputBody() {
            T_DATA = new List<OUTPUT_T_DATA>();
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
    private IF_SFDC_SEMA_0002() {
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
    private static IF_SFDC_SEMA_0002 sInstance = null;
    public static IF_SFDC_SEMA_0002 getInstance() {
        if (sInstance == null) {
            sInstance = new IF_SFDC_SEMA_0002();
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

        IF_SFDC_SEMA_0002_BIZ bizInstance = null;

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

            bizInstance = IF_SFDC_SEMA_0002_BIZ.getInstance();

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