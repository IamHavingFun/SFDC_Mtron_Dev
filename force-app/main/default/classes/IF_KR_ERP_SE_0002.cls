/****************************************************************************************
  * File Name   : IF_KR_ERP_SE_0002 
  * Description : IF_KR_ERP_SE_0002 Class (대리점 여신/채권 잔고)
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author          Modification
  * ===============================================================
    1.0  2020.05.11  ldb3100        Create
****************************************************************************************/
@RestResource(urlMapping='/IF_KR_ERP_SE_0002/*') // External interface id
global with sharing class IF_KR_ERP_SE_0002 extends IF_Base {
    public static final String IFID = 'IF_KR_ERP_SE_0002'; // External interface id
    
    public class INPUT_T_DATA {    
    	public String ERPCode                    ; // Mapping column : ERPCode__c
		public String ErpVKORG                   ; // Mapping column : ErpVKORG__c
		public String ErpVTWEG                   ; // Mapping column : ErpVTWEG__c
		public String ErpSPART                   ; // Mapping column : ErpSPART__c
		public String ErpVKBUR                   ; // Mapping column : ErpVKBUR__c
		public String CollateralAmount           ; // Mapping column : CollateralAmount__c
		public String CreditLimit                ; // Mapping column : CreditLimit__c
		public String LimitUsage                 ; // Mapping column : LimitUsage__c
		public String CreditRating               ; // Mapping column : CreditRating__c
		public String TotalBonds                 ; // Mapping column : TotalBonds__c
		public String OverdueBond                ; // Mapping column : OverdueBond__c
		public String OverdueRatio               ; // Mapping column : OverdueRatio__c
		public String NormalBonds                ; // Mapping column : NormalBonds__c
		public String OverdueLessOneMonth        ; // Mapping column : OverdueLessOneMonth__c
		public String OverdueOneTwoMonths        ; // Mapping column : OverdueOneTwoMonths__c
		public String OverdueTwoThreeMonths      ; // Mapping column : OverdueTwoThreeMonths__c
		public String OverdueSixMonths           ; // Mapping column : OverdueSixMonths__c
		public String OverdueOneYear             ; // Mapping column : OverdueOneYear__c
		public String ErpWAERS                   ; // Mapping column : ErpWAERS__c
		public String ErpNAME1                   ; // Mapping column : ErpNAME1__c
		public String ErpVKBURT                  ; // Mapping column : ErpVKBURT__c
		public String ErpKVGR3                   ; // Mapping column : ErpKVGR3__c
		public String ErpBEZEI3                  ; // Mapping column : ErpBEZEI3__c   	 
    }
    
    public class InputBody {
        public String ifAggregation;
        public String ifTotCnt;
        public String ifSplitCnt;
        public String ifSplitSeq;
        public String ifDateTime;    

        public List<INPUT_T_DATA> t_data;
        public InputBody() {
            t_data = new List<INPUT_T_DATA>();
        }
    }

    public class OutputBody {
        public String ifAggregation;
        public String ifSplitCnt;
        public String ifRcvCnt;
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
            IF_Base.logInit('RCV');

            inputObj = (InputDIH)JSON.deserialize(req, InputDIH.class);

            inputReq  = inputObj.Request  ;

            // 로그 MSGGID, IFID, IFDATE 세팅
            IF_Base.logStart(inputReq.Header);
            // 로그 input, Request_Processing_Time 세팅
            IF_Base.logProcess('STEP1', req);

            outputRes.Header         = new IF_Base.InputHeader(IFID)   ;

            // header value setup
            outputRes.Header = IF_Base.setOutputHeader(outputRes.Header, inputReq.Header);
            
            if (!IFID.equals(inputReq.header.ifid)) {
                throw new IFException('IFID is empty or incorrect.');
            }

            if(Test.isRunningTest() && IF_Base.crashTest) {  // Purposely crash test.
                throw new DmlException('Dml Exception');
            }

            inputReq.payload.ifDateTime = IF_Comm.convertEmpty(inputReq.header.ifDateTime);
            
            IF_KR_ERP_SE_0002_BIZ bizInstance = IF_KR_ERP_SE_0002_BIZ.getInstance();

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
            outputRes.Header = new IF_Base.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);     
            
            // error header value setup
            outputRes.Header = IF_Base.setOutputHeader(outputRes.Header, inputReq.Header, e);
        }
        res = JSON.serialize(outputObj);
        
        // 로그 Response_Processing_Time, Respone_from_DIH_Time 세팅
        IF_Base.logProcess('STEP2', res);
        // 로그 파일 및 row insert 
        // IF_Base.logEnd(outputRes.Header);
        IF_Base.logEnd(outputRes.Header, inputReq.payload.ifAggregation, inputReq.payload.ifTotCnt, inputReq.payload.ifSplitCnt, inputReq.payload.ifSplitSeq, outputRes.payload.ifRcvCnt, true);
        
        return outputObj;
    }
        
}