/****************************************************************************************
  * File Name   : IF_SEMA_SFDC_0002
  * Description : IF_SEMA_SFDC_0002 Class - 발송번호 결과 전송
  * Author      : CWH
  * Modification Log
  * ===============================================================
  * Ver  Date          Author          Modification
  * ===============================================================
    1.0  2020. 06. 04  CWH             Create
****************************************************************************************/
@RestResource(urlMapping='/IF_SEMA_SFDC_0002/*') // External interface id
global with sharing class IF_SEMA_SFDC_0002 extends IF_BaseNotiforce {
    private static final String IFID = 'IF_SEMA_SFDC_0002'; // External interface id
    
    public class INPUT_T_DATA {          
      private String start_date       ; // 목록 검색 시작 시간 (YYYY-MM-DD hh:mm:ss)
      private String end_date         ; // 목록 검색 시작 시간 (YYYY-MM-DD hh:mm:ss)
      private String propos           ; // 용도
      private String status           ; // 상태 (ARSST01 : 대기, ARSST02 : 정상, ARSST03 : 정지)
      private String use_at           ; // 사용 여부
      private String reg_date         ; // 등록 일시 (YYYY-MM-DD hh:mm:ss)
      private String dsptch_id        ; // 발신번호 고유 아이
      private String dsptch_num       ; // 발신번호 
    }

    public class InputBody {
        public List<INPUT_T_DATA> t_data;
        public InputBody() {
            t_data = new List<INPUT_T_DATA>();
        }
    }
    
    public class OutputBody {
        public String       ifRcvCnt;
    }
    
    /**
     * Input / Output innerClass
     */
    global class Input extends Headers{
        public InputBody payload;
        public Input(){
            payload = new InputBody();
        }
    }
    global class Output extends Headers{
        public OutputBody payload;
        public Output(){
            payload = new OutputBody();
        }
    }   
    /**
     * DIH 
     * Input / Output innerClass
     */
    global class InputDIH {
        public Input request;
        public InputDIH(){
            request = new Input();
        }
    }
    global class OutputDIH {
        public Output response;
        public OutputDIH(){
            response = new Output();
        }
    }
    
    /**
     * doPost
     * interface call
     */
    @HttpPost
    global static OutputDIH doPost() {
        RestRequest restReq = RestContext.request;
        String req = restReq.requestBody.toString();
        String res = null;
        
        InputDIH  inputObj  = new InputDIH() ; 
        OutputDIH outputObj = new OutputDIH();

        Input  inputReq  = null              ;
        Output outputRes = outputObj.Response;
        try {           
            // 로그 timeTemp, Request_to_DIH_Time 세팅
            IF_BaseNotiforce.logInit('RCV');

            inputObj = (InputDIH)JSON.deserialize(req, InputDIH.class);

            inputReq  = inputObj.Request  ;

            // 로그 MSGGID, IFID, IFDATE 세팅
            IF_BaseNotiforce.logStart(inputReq.Header);
            // 로그 input, Request_Processing_Time 세팅
            IF_BaseNotiforce.logProcess('STEP1', req);

            outputRes.Header         = new IF_BaseNotiforce.InputHeader(IFID)   ;

            // header value setup
            outputRes.Header = IF_BaseNotiforce.setOutputHeader(outputRes.Header, inputReq.Header);

            if(Test.isRunningTest() && IF_BaseNotiforce.crashTest) {  // Purposely crash test.
                throw new DmlException('Dml Exception');
            }

            IF_SEMA_SFDC_0002_BIZ bizInstance = IF_SEMA_SFDC_0002_BIZ.getInstance();

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(선행) */
            inputReq.Payload = bizInstance.pre(inputReq.Payload, outputRes.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(선행) */

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(후행) */
            outputRes.Payload = bizInstance.post(inputReq.Payload, outputRes.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(후행) */

            outputRes.Header.ifResult       = 'S';
            outputRes.Header.ifFailMsg      = '';
            outputRes.Header.ifFailCode     = '';

        } catch (Exception e) {
            // 에러내용 debug 출력
            IF_CommNotiforce.errorDebug(e);
            
            inputReq  = inputObj.Request;

            // 내부오류의 경우 ResultCode 'E'로
            outputRes.Header = new IF_BaseNotiforce.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);     
            
            // error header value setup
            outputRes.Header = IF_BaseNotiforce.setOutputHeader(outputRes.Header, inputReq.Header, e);
        }
        res = JSON.serialize(outputObj);
        
        // 로그 Response_Processing_Time, Respone_from_DIH_Time 세팅
        IF_BaseNotiforce.logProcess('STEP2', res);
        // 로그 파일 및 row insert 
        IF_BaseNotiforce.logEnd(outputRes.Header);
        
        return outputObj;
    }
        
}