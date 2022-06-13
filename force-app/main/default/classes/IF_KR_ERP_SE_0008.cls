/****************************************************************************************
  * File Name   : IF_KR_ERP_SE_0008 
  * Description : IF_KR_ERP_SE_0008 Class (추가여신승인문서 삭제)
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author          Modification
  * ===============================================================
    1.0  2020.06.18  ldb3100        Create
****************************************************************************************/
@RestResource(urlMapping='/IF_KR_ERP_SE_0008/*') // External interface id
global with sharing class IF_KR_ERP_SE_0008 extends IF_Base {
    public static final String IFID = 'IF_KR_ERP_SE_0008'; // External interface id
    
    public class INPUT_T_DATA {          
        public String ErpZLNNO                   ; // Mapping column : ErpZLNNO__c
		public String ErpVKORG                   ; // Mapping column : ErpVKORG__c
		public String ErpVTWEG                   ; // Mapping column : ErpVTWEG__c
		public String ErpSPART                   ; // Mapping column : ErpSPART__c
		public String ErpVKBUR                   ; // Mapping column : ErpVKBUR__c
		public String ErpVKGRP                   ; // Mapping column : ErpVKGRP__c
		public String ErpAUART                   ; // Mapping column : ErpAUART__c
		public String ErpKUNNR                   ; // Mapping column : ErpKUNNR__c
		public String ErpPERNR                   ; // Mapping column : ErpPERNR__c
		public String ErpZLNST                   ; // Mapping column : ErpZLNST__c
		public String ErpAPPRV                   ; // Mapping column : ErpAPPRV__c
		public String ErpLAPPR                   ; // Mapping column : ErpLAPPR__c
		public String ErpZGUBUN                  ; // Mapping column : ErpZGUBUN__c
		public String ErpZBESU                   ; // Mapping column : ErpZBESU__c
		public String ErpCRED_GRAD               ; // Mapping column : ErpCRED_GRAD__c
		public String ErpWAERS                   ; // Mapping column : ErpWAERS__c
		public String ErpGUAR_AMNT_C             ; // Mapping column : ErpGUAR_AMNT_C__c
		public String ErpKLIMK_C                 ; // Mapping column : ErpKLIMK_C__c
		public String ErpUSELN_C                 ; // Mapping column : ErpUSELN_C__c
		public String ErpZRATE                   ; // Mapping column : ErpZRATE__c
		public String ErpAPPAM_C                 ; // Mapping column : ErpAPPAM_C__c
		public String ErpLNREQ_C                 ; // Mapping column : ErpLNREQ_C__c
		public String ErpUSELN_F_C               ; // Mapping column : ErpUSELN_F_C__c
		public String ErpZRATE_F                 ; // Mapping column : ErpZRATE_F__c
		public String ErpSUMME_C                 ; // Mapping column : ErpSUMME_C__c
		public String ErpBILIN_C                 ; // Mapping column : ErpBILIN_C__c
		public String ErpARRME_C                 ; // Mapping column : ErpARRME_C__c
		public String ErpARRRT                   ; // Mapping column : ErpARRRT__c
		public String ErpINTVL0_C                ; // Mapping column : ErpINTVL0_C__c
		public String ErpINTVL1_C                ; // Mapping column : ErpINTVL1_C__c
		public String ErpINTVL2_C                ; // Mapping column : ErpINTVL2_C__c
		public String ErpINTVL3_C                ; // Mapping column : ErpINTVL3_C__c
		public String ErpINTVL4_C                ; // Mapping column : ErpINTVL4_C__c
		public String ErpINTVL5_C                ; // Mapping column : ErpINTVL5_C__c
		public String ErpLNREL                   ; // Mapping column : ErpLNREL__c
		public String ErpRELDT                   ; // Mapping column : ErpRELDT__c
		public String ErpLVORM                   ; // Mapping column : ErpLVORM__c
		public String SalesDocNo                 ; // Mapping column : SalesDocNo__c
		public String ErpPOSNR                   ; // Mapping column : ErpPOSNR__c
		public String ErpMATNR                   ; // Mapping column : ErpMATNR__c
		public String ErpMENGE                   ; // Mapping column : ErpMENGE__c
		public String ErpVRKME                   ; // Mapping column : ErpVRKME__c
		public String ErpNETPR_C                 ; // Mapping column : ErpNETPR_C__c
		public String ErpNETWR_C                 ; // Mapping column : ErpNETWR_C__c
		public String ErpSTOCK                   ; // Mapping column : ErpSTOCK__c
		public String ErpRQIND                   ; // Mapping column : ErpRQIND__c
		public String ErpLVORM1                  ; // Mapping column : ErpLVORM1__c
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

            IF_KR_ERP_SE_0008_BIZ bizInstance = IF_KR_ERP_SE_0008_BIZ.getInstance();

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