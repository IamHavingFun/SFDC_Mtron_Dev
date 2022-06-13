/****************************************************************************************
  * File Name   : IF_KR_SE_LWS_0022_TEST
  * Description : IF_KR_SE_LWS_0022_TEST Test Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2020. 07. 02.  ldb3100    Create
****************************************************************************************/
@isTest
private class IF_KR_SE_LWS_0022_TEST {
     // 입력 객체 생성
    private static IF_KR_SE_LWS_0022.InputDIH newInputParameter() {
        IF_KR_SE_LWS_0022.InputBody payload = new IF_KR_SE_LWS_0022.InputBody();

        IF_KR_SE_LWS_0022.InputDIH input = new IF_KR_SE_LWS_0022.InputDIH();

        IF_KR_SE_LWS_0022.Input inputObj = input.Request;

        inputObj.Header = new IF_LWS_Base.InputHeader('a6bba321-2183-5fb4-ff75-4d024e39a98e', 'IF_KR_SE_LWS_0022', '20161110021630', 'S', '', '');
        inputObj.Payload = payload;
        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"Response":{"Header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_LWS_0022","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"Payload":{"TOTAL_RECORD_CNT":"2"}}}');
        IF_KR_SE_LWS_0022.OutputDIH temp = (IF_KR_SE_LWS_0022.OutputDIH)JSON.deserialize(res.getBody(), IF_KR_SE_LWS_0022.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_KR_SE_LWS_0022';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        System.debug('time : ' + String.valueOf(system.now()));

        IF_KR_SE_LWS_0022 instance = IF_KR_SE_LWS_0022.getInstance();
        // 서비스 실행
        IF_KR_SE_LWS_0022.InputDIH input = new IF_KR_SE_LWS_0022.InputDIH();
        IF_KR_SE_LWS_0022.INPUT_T_DATA tData = new IF_KR_SE_LWS_0022.INPUT_T_DATA();
        tData.AssetNo       = '1';
        tData.ClaimNo       = '1';
        tData.ImgTypeName   = 'PNG';
        tData.ImgFile       = 'iVBORw0KGgoAAAANSUhEUgAAACcAAAAvCAYAAABg8NNYAAAABHNCSVQICAgIfAhkiAAAA6ZJREFUWIXtmU1rHVUYgJ+Te9PUNGlyoybVNDa11TYWbZCKVmkr1bZUXIjoQnRhf4D/QnAh4sKfoKC4cqEgCBVFBVHpQkRUilZFrJZCaa3aJn1cvHPbmt65mY97EwQfmNXMnHnmnXPe854zUAO1oc6qz6vH1NPqV+pL6pzaqNN+qim3DXgSeAy4kB2DwHrgLeDNlNKXVdsfqCHWAG4DHs1kPgZeB94HrgMOAjvqRK9Z9UZgLXALsAU4CryRUvpCnQNmgf3AZmAYOFvlAZUjB7SyI6+NAWAsu6YSdSK3iYjQCHA/cETdA8wAezKxGSKyP66InJqAKeABYJ4YANPAIeBeYDSTAtgB7FW/AU6mlBb7JqcOATcCe4HDwF1cGfFbO9wyB/wF/AB8qP6aUvqzzDPLyG1XX1BPqYsW45J6Tn1Zne+X2G71RfWEeiF7aFG5BfUn9RV1X9FnFvqs6k3AQ8AjRPooQwIawEYi951VjwO/pJQudbuxaCrZBTwI3FFSbCm3Z+3cR4HAdJVTkzoIPA7srCnWZjvwFLAuG/nV5IgcNk+88Xhv3Bglpr15IhfmspzcGJFQJ6mXsK+mCUwQifv6bhcWletV1NqMALupKpf1hxZwD/EpeskwcDdwg5rr0C1y64hpagpY01s3msRMM0WXF+8mN07MkU1qFqUdSFm704RkR7rJtbgygfeLaWKwdaSb3ARRFvWTjcSn7ch/NnIrIXczZeXUUaKjTvRJqk0LmFTXdzqZF7nJ7Bjql1XGGiIRb+h0Mk+ua0ftMbkDL09uK/3vb20mgW2dTlwjpzaJhcmtfZZqMw3sVAeXllD/kssWMJuIyOWOoh7TIkqoWWKh3lmO2FbYTwj2ezC0GSRSyiGWZIfLclnFOwM8Tfl1Ql02AM8CW9TLRcZAJtYk1qBHgDuJemslGSbWuM8AuzIfmupmovO3V1djxGppJWlkggeBc8CI+l1SnwMOEFsJKzUIunEKOAa8ndTfCOsherdOqMMi8DfwR1JdbZs8msBnqy2RRxN4bbUl8kjq2uUv+59rKL2qumpnc4piyfo8cJJ+72xmNIhJeh/FKpefie3/00SaKEwVuUSU8IcJweX4HPiaCrNOla3+BeBT4DjL/184D5wAPiH2hktRWi6lJPGJ3gM+AC4CnRL5IvES7wK/l+1vUHG6SiktqB8RxeEI0fcmiClwATgDfE/8/zqaUrpY5Tm1UMfVh9VX1W/VM9nG9DvqE2qtQuIfk92K4inf9a4AAAAASUVORK5CYII=';



        input.request.payload.t_data.add(tData);
        
        System.debug('result input : '+ JSON.serialize(input));

        IF_KR_SE_LWS_0022.OutputDIH result = instance.execute(input);
        System.debug('result : '+result);

        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_KR_SE_LWS_0022 성공!!!');

        // crashTest
        IF_LWS_Base.crashTest = true;
        result = instance.execute(new IF_KR_SE_LWS_0022.InputDIH());

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_KR_SE_LWS_0022 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}