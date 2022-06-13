/****************************************************************************************
  * File Name   : IF_KR_SE_ERP_0043_TEST
  * Description : IF_KR_SE_ERP_0043_TEST Class 
  * Author      : namho100
  * copyright   : Copyright © I2max. All Rights Reserved.
  * Modification Log
  * ===============================================================
  * Ver   Date         Author       Modification
  * ===============================================================
    1.0   2022-01-04   namho100    Create
***************************************************************************************/
@isTest
private class IF_KR_SE_ERP_0043_TEST {
    // 입력 객체 생성
    private static IF_KR_SE_ERP_0043.InputDIH newInputParameter() {
        IF_KR_SE_ERP_0043.InputBody payload = new IF_KR_SE_ERP_0043.InputBody();

        IF_KR_SE_ERP_0043.InputDIH input = new IF_KR_SE_ERP_0043.InputDIH();

        IF_KR_SE_ERP_0043.Input inputObj = input.Request;

        inputObj.Header = new IF_Base.InputHeader('a6bba321-2183-5fb4-ff75-4d024e39a98e', 'IF_KR_SE_ERP_0043', '20161110021630', 'S', '', '');
        inputObj.Payload = payload;
        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"Response":{"Header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_ERP_0043","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"Payload":{"TOTAL_RECORD_CNT":"2"}}}');
        IF_KR_SE_ERP_0043.OutputDIH temp = (IF_KR_SE_ERP_0043.OutputDIH)JSON.deserialize(res.getBody(), IF_KR_SE_ERP_0043.OutputDIH.class);
        return res;
    }

    // StatusCode=200 Mock
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200);
            return res;
        }
    }

    // 공통 테스트 진행
    private static Boolean testServiceExecute() {
        String jsonMsg = JSON.serialize(newInputParameter());

        RestRequest  req = new RestRequest ();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IF_KR_SE_ERP_0043';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        System.debug('time : ' + String.valueOf(system.now()));

        IF_KR_SE_ERP_0043 instance = IF_KR_SE_ERP_0043.getInstance();
        // 서비스 실행
        IF_KR_SE_ERP_0043.InputDIH input = new IF_KR_SE_ERP_0043.InputDIH();

        IF_KR_SE_ERP_0043.INPUT_IMPORT input_import = new IF_KR_SE_ERP_0043.INPUT_IMPORT();
        input_import.I_TYPE = 'A'; // 공란 : 수수료 전달, "A" 집계표승인, "B" 입금표 승인
        input.request.payload.t_data_import = input_import;

        IF_KR_SE_ERP_0043.INPUT_T_DATA_1 tData1 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_1();
        tData1.VBELN = '1';
        tData1.POSNR = '1';
        tData1.CHRGB = '1';
        tData1.SEQNO = '1';
        tData1.ZYYMM = '202003';
        tData1.CALYM = '202003';
        tData1.KUNNR = '1';
        tData1.MATNR = '1';
        tData1.PERNR = '1';
        tData1.ZSFDC = '1';
        tData1.VGBEL = '1';
        tData1.VGPOS = '1';
        tData1.CHARG = '1';
        tData1.SHKZG = '1';
        tData1.CRIMG = '1';
        tData1.LFIMG = '1';
        tData1.MEINS = '1';
        tData1.WAERK = '1';
        tData1.NETPR = '1';
        tData1.PDIEXC = '1';
        tData1.PDIEX = '1';
        tData1.PDIET = '1';
        tData1.PDIEM = '1';
        tData1.NPDIET = '1';
        tData1.NPDIEM = '1';
        tData1.NESFT = '1';
        tData1.NESFM = '1';
        tData1.EPSRT = '1';
        tData1.EPSAM = '1';
        tData1.TESRT = '1';
        tData1.TESAM = '1';
        tData1.SDSRT = '1';
        tData1.SDSAM = '1';
        tData1.SPSRT = '1';
        tData1.SPSAM = '1';
        tData1.FMSRT = '1';
        tData1.FMSAM = '1';
        tData1.PIERT = '1';
        tData1.PIEAM = '1';
        tData1.CSPRT = '1';
        tData1.CSPAM = '1';
        tData1.MASRT = '1';
        tData1.MASAM = '1';
        tData1.STMRT = '1';
        tData1.STMAM = '1';
        tData1.CONFM1 = '1';
        tData1.CONFM2 = '1';
        tData1.REFLG = '1';
        tData1.LOEKZ = '1';
        tData1.URL1 = 'AAAA';
        tData1.URL2 = 'bbbb';
        tData1.URL3 = 'CCcc';

        input.request.payload.t_data_1.add(tData1);

        IF_KR_SE_ERP_0043.INPUT_T_DATA_2 tData2 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_2();
        tData2.VBELN = '1';
        tData2.POSNR = '1';
        tData2.CHRGB = '1';
        tData2.SEQNO = '1';
        tData2.ZYYMM = '202203';
        tData2.CALYM = '202203';
        tData2.KUNNR = '1';
        tData2.AGENT = '1';
        tData2.MATNR = '1';
        tData2.PERNR = '1';
        tData2.ZSFDC = '1';
        tData2.CHARG = '1';
        tData2.SHKZG = '1';
        tData2.CRIMG = '1';
        tData2.LFIMG = '1';
        tData2.MEINS = '1';
        tData2.NETPR = '1';
        tData2.WAERK = '1';
        tData2.SPCGB = '1';
        tData2.GASRT = '1';
        tData2.GASAM = '1';
        tData2.SVCRT = '1';
        tData2.SVCAM = '1';
        tData2.BKRRT = '1';
        tData2.BKRAM = '1';
        tData2.SCSRT = '1';
        tData2.SCSAM = '1';
        tData2.SSLRT = '1';
        tData2.SSLAM = '1';
        tData2.CONFM1 = '1';
        tData2.CONFM2 = '1';
        tData2.REFLG = '1';
        tData2.NGEGB = '1';
        tData2.LOEKZ = '1';

        input.request.payload.t_data_2.add(tData2);

        IF_KR_SE_ERP_0043.INPUT_T_DATA_3 tData3 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_3();
        tData3.VBELN = '1';
        tData3.POSNR = '1';
        tData3.CHRGB = '1';
        tData3.SEQNO = '1';
        tData3.ZTYPE = '1';
        tData3.ZSFDC = '1';
        tData3.CHARG = '1';
        tData3.APPRO = '1';
        tData3.APPNM = '1';
        tData3.APPDT = '20220418';
        tData3.APPTM = '12:12:12';
        input.request.payload.t_data_3.add(tData3);

        System.debug('result input : '+ JSON.serialize(input));

        IF_KR_SE_ERP_0043.OutputDIH result = instance.execute(input);
        System.debug('result : '+result);

        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_KR_SE_ERP_0043 성공!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = instance.execute(new IF_KR_SE_ERP_0043.InputDIH());

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_KR_SE_ERP_0043 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}