/****************************************************************************************
  * File Name   : IF_KR_SE_ERP_0007
  * Description : IF_KR_SE_ERP_0007 IF Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2020. 06. 01.  ldb3100    Create
    ***************************************************************************************/
public with sharing class IF_KR_SE_ERP_0007 extends IF_Base {
    private static final String IFID = 'IF_KR_SE_ERP_0007'; // External interface id

    private static String IFURL;

    public class T_DATA  {
        public String OrderID                ; // 세일즈포스 채번 주문ID
        public String OrderLineItemID        ; // 세일즈포스 주문 아이템 ID
        public String ErpAUART               ; // 영업문서 유형
        public String ErpVKORG               ; // 영업조직
        public String ErpVTWEG               ; // 유통경로
        public String ErpSPART               ; // 제품군
        public String ErpVKBUR               ; // 영업팀
        public String ErpVKGRP               ; // 영업그룹
        public String ErpBSTKD               ; // PO 번호
        public String ErpBSTDK               ; // PO 일자
        public String ErpKUNNR               ; // 판매처
        public String ErpKUNNR2              ; // 지급처
        public String ErpKUNNR3              ; // 납품처
        public String ErpZTERM               ; // 지급조건
        public String ProductCode            ; // 제품코드
        public String Quanitity              ; // 주문수량
        public String CHARG                  ; // 기대번호
        public String VSTEL                  ; // 출하지점
        public String LGORT                  ; // 저장위치
        public String ErpZFLAG               ; // 주문Flag(Create: C 설정)
        public String SalesDocNo             ; // 판매문서번호
        public String ErpPOSNR               ; // 판매문서품목번호
        public String ErpCMGST               ; // ERP 여신상태
        public String ErpABGRU               ; // ERP 거부사유
        public String KEDAT                  ; // 납품요청일
        public String DLTXT                  ; // 출하전달사항
        public String NETWR1_C               ; // 기준 가격    (2021.10.15 추가)
        public String NETWR2_C               ; // 가격 변경    (2021.10.15 추가)
        public String NETWR3_C               ; // 공급 가격    (2021.10.15 추가)
        public String RESERVE01              ; // 예비1       (2021.10.15 추가)
        public String RESERVE02              ; // 예비2       (2021.10.15 추가)
        public String RESERVE03              ; // 예비3       (2021.10.15 추가)
        public String RESERVE04              ; // 예비4       (2021.10.15 추가)
        public String RESERVE05              ; // 예비5       (2021.10.15 추가)
        public String ErpS_RESULT            ; // ERP 처리결과
        public String ErpS_MESSAGE           ; // ERP 메시지
        public String PRSDT                  ; // 가격결정일   (2022.01.13 추가)
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
    private IF_KR_SE_ERP_0007() {
        System.debug(IFID+' call');
        IF_INFO__c ifInfo = getIfinfo(IFID);  // DML
        IFURL = ifInfo.URL__c;
        System.debug(ifInfo.TITLE__c+' call start');
    }

    /**
     * singleton
     */
    private static IF_KR_SE_ERP_0007 sInstance = null;
    public static IF_KR_SE_ERP_0007 getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_SE_ERP_0007();
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

        IF_KR_SE_ERP_0007_BIZ bizInstance = null;

        Input  inputReq  = inputObj.Request  ;
        Output outputRes = null              ;
        try {
            // 로그 timeTemp, Request_to_DIH_Time 세팅
            IF_Base.logInit('SND');

            inputReq.Header = new IF_Base.InputHeader(IFID);

            inputReq.Header.ifSenderGp      = 'LSMTRON';
            inputReq.Header.ifSender        = 'SE';
            inputReq.Header.ifReceiverGp    = 'LSMTRON';
            inputReq.Header.ifReceiver      = 'SAP';

            // 로그 MSGGID, IFID, IFDATE 세팅
            IF_Base.logStart(inputReq.Header);

            bizInstance = IF_KR_SE_ERP_0007_BIZ.getInstance();

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