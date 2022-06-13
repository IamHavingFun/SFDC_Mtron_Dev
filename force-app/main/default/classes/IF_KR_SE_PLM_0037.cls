/****************************************************************************************
  * File Name   : IF_KR_SE_PLM_0037
  * Description : IF_KR_SE_PLM_0037 IF Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2020. 06. 29.  ldb3100    Create
    ***************************************************************************************/
public with sharing class IF_KR_SE_PLM_0037 extends IF_Base {
    private static final String IFID = 'IF_KR_SE_PLM_0037'; // External interface id

    private static String IFURL;

    public class T_DATA  {
        public String PLANT_ID               ; // 플랜트 구분 , default : 3602
        public String EAI_SFRESULT           ; // SFDC I/F 완료 여부(Y / N) , default : N
        public String RELEASED_STATUS        ; // 결재 완료여부("PP RELEASED" or NULL), default : PP RELEASED
   }

   /**
    * inputBody / outputBody innerClass
    */
   public class InputBody {
       public String ifAggregation	;
       public String ifTotCnt       ;
       public String ifSplitCnt     ;
       public String ifSplitSeq     ;
       public List<T_DATA> t_data;
    public InputBody() {
        ifAggregation = IF_Base.giveAGGR();
        ifTotCnt      = '';
        ifSplitCnt    = '';
        ifSplitSeq    = '';
        t_data = new List<T_DATA>(); 
    }
   }
   public class OutputBody {
       public String ifAggregation	 ;
       public String ifSplitCnt      ;
       public String ifRcvCnt        ;
       public List<T_DATA> t_data;
   }    /**
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
    private IF_KR_SE_PLM_0037() {
        System.debug(IFID+' call');
        IF_INFO__c ifInfo = getIfinfo(IFID);  // DML
        IFURL = ifInfo.URL__c;
        System.debug(ifInfo.TITLE__c+' call start');
    }

    /**
     * singleton
     */
    private static IF_KR_SE_PLM_0037 sInstance = null;
    public static IF_KR_SE_PLM_0037 getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_SE_PLM_0037();
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

        IF_KR_SE_PLM_0037_BIZ bizInstance = null;

        Input  inputReq  = inputObj.Request  ;
        Output outputRes = null              ;
        try {
            // 로그 timeTemp, Request_to_DIH_Time 세팅
            IF_Base.logInit('SND');

            inputReq.Header = new IF_Base.InputHeader(IFID);

            inputReq.Header.ifSenderGp      = 'LSMTRON';
            inputReq.Header.ifSender        = 'SE';
            inputReq.Header.ifReceiverGp    = 'LSMTRON';
            inputReq.Header.ifReceiver      = 'PLM';

            // 로그 MSGGID, IFID, IFDATE 세팅
            IF_Base.logStart(inputReq.Header);

            bizInstance = IF_KR_SE_PLM_0037_BIZ.getInstance();

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(선행) */
            inputReq.Payload = bizInstance.pre(inputReq.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(선행) */

            // JSON TO STRING
            req = JSON.serialize(inputObj);

            // 로그 input, Request_Processing_Time 세팅
            IF_Base.logProcess('STEP1', req);

            if(Test.isRunningTest() && IF_Base.crashTest) {  // Purposely crash test.
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
            IF_Comm.errorDebug(e);

            outputRes = outputObj.Response;

            // 내부오류의 경우 ResultCode 'E'로
            outputRes.Header = new IF_Base.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);

            // error header value setup
            outputRes.Header = IF_Base.setOutputHeader(outputRes.Header, inputReq.Header, e);
        }
        // 로그 Response_Processing_Time, Respone_from_DIH_Time 세팅
        IF_Base.logProcess('STEP2', res);
        res = '';
        // 로그 파일 및 row insert
        // IF_Base.logEnd(outputRes.Header);
        IF_Base.logEnd(outputRes.Header, inputReq.payload.ifAggregation, inputReq.payload.ifTotCnt, inputReq.payload.ifSplitCnt, inputReq.payload.ifSplitSeq, outputRes.payload.ifRcvCnt, true);

        return outputObj;
    }

  
}