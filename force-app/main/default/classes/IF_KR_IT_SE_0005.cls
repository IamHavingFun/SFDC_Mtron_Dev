/****************************************************************************************
  * File Name   : IF_KR_IT_SE_0005
  * Description : IF_KR_IT_SE_0005 Class
  * Author      : namho100
  * copyright   : Copyright © I2max. All Rights Reserved.
  * Modification Log
  * ===============================================================
  * Ver   Date         Author       Modification
  * ===============================================================
    1.0   2021-10-18   namho100     Create
***************************************************************************************/
@RestResource(urlMapping='/IF_KR_IT_SE_0005/*')
global with sharing class IF_KR_IT_SE_0005 extends IF_iTractor_Base {
    public static final String IFID = 'IF_KR_IT_SE_0005'; // External interface id

    public class INPUT_T_DATA {
        public String tractor_id;       // 기대번호
        public String code_type;        // 00 : 고장, 01 : 경고
        public String code;             // 고장, 경고 코드
        public String customer_use_yn;  // 고객 알람 전송여부 (Y: 알람사용 , N: 알람미사용)
        public String nonghyup_use_yn;  // 농협 알람 전송여부 (Y: 알람사용 , N: 알람미사용)
        public String agency_use_yn;    // 대리점 알람 전송여부 (Y: 알람사용 , N: 알람미사용)
        public String office_use_yn;    // 영업소 알람 전송여부 (Y: 알람사용 , N: 알람미사용)
    }

    public class OUTPUT_T_DATA {
        public String message_result;       // 메시지 전송 시도 결과(Success : S, Failed : F)
        public String message_result_desc;  // 메시지 전송 시도 결과 Failed 경우
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
            IF_iTractor_Base.logInit('RCV');

            inputObj = (InputDIH)JSON.deserialize(req, InputDIH.class);

            inputReq  = inputObj.Request  ;

            // 로그 MSGGID, IFID, IFDATE 세팅
            IF_iTractor_Base.logStart(inputReq.Header);
            // 로그 input, Request_Processing_Time 세팅
            IF_iTractor_Base.logProcess('STEP1', req);

            outputRes.Header         = new IF_iTractor_Base.InputHeader(IFID)   ;

            // header value setup
            outputRes.Header = IF_iTractor_Base.setOutputHeader(outputRes.Header, inputReq.Header);

            if (!IFID.equals(inputReq.header.ifid)) {
                throw new IFException('IFID is empty or incorrect.');
            }

            if(Test.isRunningTest() && IF_iTractor_Base.crashTest) {  // Purposely crash test.
                throw new DmlException('Dml Exception');
            }

            IF_KR_IT_SE_0005_BIZ bizInstance = IF_KR_IT_SE_0005_BIZ.getInstance();

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
            IF_Comm.errorDebug(e);

            inputReq  = inputObj.Request;

            // 내부오류의 경우 ResultCode 'E'로
            outputRes.Header = new IF_iTractor_Base.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);

            // error header value setup
            outputRes.Header = IF_iTractor_Base.setOutputHeader(outputRes.Header, inputReq.Header, e);
        }
        res = JSON.serialize(outputObj);

        // 로그 Response_Processing_Time, Respone_from_DIH_Time 세팅
        IF_iTractor_Base.logProcess('STEP2', res);
        // 로그 파일 및 row insert
        if(!test.isRunningTest())   IF_iTractor_Base.logEnd(outputRes.Header);

        return outputObj;
    }

}