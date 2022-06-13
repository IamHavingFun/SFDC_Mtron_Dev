/****************************************************************************************
  * ProjectName : I2SEMA
  * File Name   : IF_SFDC_SEMA_0007
  * Description : IF_SFDC_SEMA_0007 Class - 템플릿 목록
  * Copyright   : Copyright © 2020 i2max All Rights Reserved
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author       Modification
  * ===============================================================
    1.0  2020. 02. 06   ldb3100      Create
    1.1  2020. 02. 13   ldb3100      API Ver 0.2
****************************************************************************************/
public with sharing class IF_SFDC_SEMA_0007 extends IF_BaseNotiforce {
	 private static final String IFID = 'IF_SFDC_SEMA_0007'; // External interface id

    private static String IFURL;

    public class INPUT_T_DATA  {
    	public String start_de                              ;  // 목록 검색 시작 시간
    	public String end_de                                ;  // 목록 검색 종료 시간
    	public String record_limit                          ;  // 레코드 제한 수 (defalut : 50, 최대 : 2000)  
    	public String templete_type                         ;  // 메시지 타입 (SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009)
    }
    
    public class OUTPUT_T_DATA { 
        public String templete_type                         ;  // SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009
    	public String seq                                   ;  // 메시지 고유 아이디, sequence
    	public String subject                               ;  // 제목 (SMS 일 경우 제외)
        public String content                               ;  // 내용 (SMS : 90 Byte, MMS : 2000 Byte)
        public String service_type                          ;  // 메시지 타입 (SMS : 0, MMS : 2, LMS : 3, 알림톡 : 1008, 친구톡 : 1009)
        public String broadcast_yn                          ;  // 동보메세지 여부 (Y, N)
        public String change_word_count                     ;  // 개별화 필드 갯수(수신자 번호 제외)
        public String msg_type                              ;  // 카카오톡 비즈 메시지 타입 (알림톡 : 1008, 친구톡 : 1009)
        public String kakao_noti_templete_code              ;  // 알림톡 템플릿 코드 - 기 등록된 템플릿 코드 이용(InfoBank에 등록된 코드만 사용가능)
        public String kakao_chennel_id                      ;  // 카카오 비즈 아이디
        public String kakao_img_url                         ;  // 친구톡 이미지 경로
        public String kakao_img_link                        ;  // 친구톡 이미지 클릭시 링크
        public String templete_id                           ;  // SFDC 템플릿 아이디     
        public String msg_cl_type                           ;   // 1 : 광고성, 2 : 정보성
        public String ars_080_num                           ;   // message_type 이 1일 경우 필수. 080
    }
    
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
    private IF_SFDC_SEMA_0007() {
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
    private static IF_SFDC_SEMA_0007 sInstance = null;
    public static IF_SFDC_SEMA_0007 getInstance() {
        if (sInstance == null) {
            sInstance = new IF_SFDC_SEMA_0007();
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

        IF_SFDC_SEMA_0007_BIZ bizInstance = null;

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

            bizInstance = IF_SFDC_SEMA_0007_BIZ.getInstance();

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