/****************************************************************************************
  * File Name   : IF_KR_SE_ERP_0043
  * Description : IF_KR_SE_ERP_0043 Class (수수료)
  * Author      : namho100
  * copyright   : Copyright © I2max. All Rights Reserved.
  * Modification Log
  * ===============================================================
  * Ver   Date         Author       Modification
  * ===============================================================
    1.0   2022-01-04   namho100    Create
***************************************************************************************/
public with sharing class IF_KR_SE_ERP_0043 extends IF_Base {
    private static final String IFID = 'IF_KR_SE_ERP_0043'; // External interface id

    private static String IFURL;

    public class INPUT_IMPORT {
        public String I_TYPE;
    }

    // 대리점 수수료
    public class INPUT_T_DATA_1 {
        public String VBELN;        // 판매오더
        public String POSNR;        // 판매오더품목
        public String CHRGB;        // 수수료 구분
        public String SEQNO;        // 순번
        public String ZYYMM;        // 정산기준년월
        public String CALYM;        // 산출대상년월
        public String KUNNR;        // 판매처
        public String MATNR;        // 자재 번호
        public String PERNR;        // 사원 번호
        public String ZSFDC;        // SFDC Record ID
        public String VGBEL;        // 트랙터 판매오더
        public String VGPOS;        // 트랙터 판매오더 품목
        public String CHARG;        // 기대번호
        public String SHKZG;        // 반품품목
        public String CRIMG;        // 반품수량
        public String LFIMG;        // 실제수량납품 (판매단위)
        public String MEINS;        // 기본 단위
        public String WAERK;        // 통화
        public String NETPR;        // 공급 가격
        public String PDIEXC;       // PDI 제외
        public String PDIEX;        // PDI 실행
        public String PDIET;        // PDI 등록(%)
        public String PDIEM;        // PDI 등록
        public String NPDIET;       // (미지급) PDI 등록(%)
        public String NPDIEM;       // (미지급) PDI 등록
        public String NESFT;        // 조기안착지원(%)
        public String NESFM;        // 조기안착지원
        public String EPSRT;        // 사전판매장려(%)
        public String EPSAM;        // 사전판매장려
        public String TESRT;        // 시승체험지원(%)
        public String TESAM;        // 시승체험지원
        public String SDSRT;        // 사양차액지원(%)
        public String SDSAM;        // 사양차액지원
        public String SPSRT;        // 특별판촉지원(%)
        public String SPSAM;        // 특별판촉지원
        public String FMSRT;        // 무상적업기지원(%)
        public String FMSAM;        // 무상작업기지원
        public String PIERT;        // Sales I.Q. 달성(%)
        public String PIEAM;        // Sales I.Q. 달성
        public String CSPRT;        // CS수수료 율
        public String CSPAM;        // CS수수료 금액
        public String MASRT;        // 광고선점비 율
        public String MASAM;        // 광고선점비 금액
        public String STMRT;        // 매출할인 율
        public String STMAM;        // 매출할인 금액
        public String CONFM1;       // 수수료 영업그룹 확정 여부
        public String CONFM2;       // 수수료 영업팀 확정 여부
        public String REFLG;        // 수수료 상세구분
        public String LOEKZ;        // 삭제지시자
        public String URL1;         // 사양차액지원 추가판매장려 Record ID
        public String URL2;         // 특별판촉지원 추가판매장려 Record ID
        public String URL3;         // 작업기지원 추가판매장려 Record ID
    }

    // 서비스 위탁 수수료
    public class INPUT_T_DATA_2 {
        public String VBELN;        // 판매오더
        public String POSNR;        // 판매오더품목
        public String CHRGB;        // 수수료 구분
        public String SEQNO;        // 순번
        public String ZYYMM;        // 정산기준년월
        public String CALYM;        // 산출대상년월
        public String KUNNR;        // 판매처
        public String AGENT;        // 농협전문점/위탁점
        public String MATNR;        // 자재 번호
        public String PERNR;        // 사원 번호
        public String ZSFDC;        // SFDC Record ID
        public String CHARG;        // 배치 번호
        public String SHKZG;        // 반품품목
        public String CRIMG;        // 반품수량
        public String LFIMG;        // 실제수량납품 (판매단위)
        public String MEINS;        // 기본 단위
        public String NETPR;        // 단가
        public String WAERK;        // 통화
        public String SPCGB;        // 전문점 구분
        public String GASRT;        // 관납사후봉사(%)
        public String GASAM;        // 관납사후봉사
        public String SVCRT;        // 농협사후봉사(%)
        public String SVCAM;        // 농협사후봉사
        public String BKRRT;        // 중개영업지원(%)
        public String BKRAM;        // 중개영업지원
        public String SCSRT;        // CS 위탁수수료율
        public String SCSAM;        // CS 위탁 수수료 금액
        public String SSLRT;        // 판매수수료율
        public String SSLAM;        // 판매수수료 금액
        public String CONFM1;       // 수수료 영업그룹 확정 여부
        public String CONFM2;       // 수수료 영업팀 확정 여부
        public String REFLG;        // 수수료 상세구분
        public String NGEGB;        // 농협/관납/기타 구분
        public String LOEKZ;        // 삭제지시자
    }

    // 승인정보
    public class INPUT_T_DATA_3 {
        public String VBELN;        // 판매오더
        public String POSNR;        // 판매오더품목
        public String CHRGB;        // 수수료 구분
        public String SEQNO;        // 순번
        public String ZTYPE;        // 수수료유형
        public String ZSFDC;        // SFDC Record ID
        public String CHARG;        // 기대번호
        public String APPRO;        // 승인여부(Y/N)
        public String APPNM;        // 승인 이름
        public String APPDT;        // 승인 일자
        public String APPTM;        // 승인 시간
    }

    /**
     * inputBody / outputBody innerClass
     */
    public class InputBody {
        public String ifAggregation	;
        public String ifTotCnt       ;
        public String ifSplitCnt     ;
        public String ifSplitSeq     ;
        public INPUT_IMPORT t_data_import;
        public List<INPUT_T_DATA_1> t_data_1;
        public List<INPUT_T_DATA_2> t_data_2;
        public List<INPUT_T_DATA_3> t_data_3;
        public InputBody() {
            ifAggregation = IF_Base.giveAGGR();
            ifTotCnt      = '';
            ifSplitCnt    = '';
            ifSplitSeq    = '';
            t_data_1 = new List<INPUT_T_DATA_1>();
            t_data_2 = new List<INPUT_T_DATA_2>();
            t_data_3 = new List<INPUT_T_DATA_3>();
        }
    }
    public class OutputBody {
        public String ifAggregation	 ;
        public String ifSplitCnt      ;
        public String ifRcvCnt        ;
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
    private IF_KR_SE_ERP_0043() {
        System.debug(IFID+' call');
        IF_INFO__c ifInfo = getIfinfo(IFID);  // DML
        IFURL = ifInfo.URL__c;
        System.debug(ifInfo.TITLE__c+' call start');
    }

    /**
     * singleton
     */
    private static IF_KR_SE_ERP_0043 sInstance = null;
    public static IF_KR_SE_ERP_0043 getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_SE_ERP_0043();
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

        IF_KR_SE_ERP_0043_BIZ bizInstance = null;

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

            bizInstance = IF_KR_SE_ERP_0043_BIZ.getInstance();

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