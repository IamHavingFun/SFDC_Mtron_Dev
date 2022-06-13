/****************************************************************************************
  * File Name   : IF_SEMA_SFDC_0003
  * Description : IF_SEMA_SFDC_0003 Class - 템플릿 저장 결과 전송(알림톡)
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date          Author          Modification
  * ===============================================================
    1.0  2020. 05. 11  ldb3100         Create
****************************************************************************************/
@RestResource(urlMapping='/IF_SEMA_SFDC_0003/*') // External interface id
global with sharing class IF_SEMA_SFDC_0003 extends IF_BaseNotiforce {
    private static final String IFID = 'IF_SEMA_SFDC_0003'; // External interface id
    
    public class INPUT_T_DATA {          
        public String kakako_noti_templete_code      ; // 알림톡 템플릿 코드
        public String templateName                   ; // 템플릿이름
        public String templateContent                ; // 템플릿내용
        public String inspectionStatus               ; // 검사상태 (TMPLATST01:등록, TMPLATST02:검수요청, TMPLATST03:검수중, TMPLATST04:승인, TMPLATST05: 반려)
        public List<T_KAKAO> t_kakao  = new List<T_KAKAO>()   ;
    }

    public class T_KAKAO {
        public String kakao_btn_type        ; // 버튼 타입(배송조회 : DS, BK : 봇키워드, MD : 메시지 전달 : MD, 웹링크 : WL, 앱링크 : AL)
        public String kakao_btn_name        ; // 버튼 명
        public String kakao_btn_link_1      ; // 버튼 링크 1 - 설명 Sheet 참고
        public String kakao_btn_link_2      ; // 버튼 링크 2
    }
    
    public class OUTPUT_T_DATA {  
    	public String templete_id                    ; // SFDC Seq
    	public String kakako_noti_templete_code      ; // 알림톡 템플릿 코드
    }
    
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

            IF_SEMA_SFDC_0003_BIZ bizInstance = IF_SEMA_SFDC_0003_BIZ.getInstance();

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