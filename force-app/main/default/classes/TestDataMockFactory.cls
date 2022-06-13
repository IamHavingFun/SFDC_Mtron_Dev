/****************************************************************************************
  * @filename      : TestDataMockFactory
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-07-15 오후 5:22
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : TestDataMockFactory_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-15 오후 5:22     i2max_my.Seo           Create
****************************************************************************************/
@IsTest
public class TestDataMockFactory {

    /**
     * 성공한 Mock Class return.
     *
     * @param body : 해당 Response Body.
     *
     * @return CalloutMock
     */
    public static CalloutMock createSuccessCalloutMock(String body) {

        return new CalloutMock(200, 'OK', body, new Map<String,String>());
    }

    /**
     * 실패한 Mock Class return.
     *
     * @param body : 해당 Response Body.
     *
     * @return CalloutMock
     */
    public static CalloutMock createErrorCalloutMock(String body) {

        return new CalloutMock(500, 'Error', body, new Map<String,String>());
    }

    /**
     * HttpCallout Mock Class
     */
    public class CalloutMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;
        protected Map<String, String> responseHeaders;

        public CalloutMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.body = body;
            this.responseHeaders = responseHeaders;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            for (String key : this.responseHeaders.keySet()) {
                res.setHeader(key, this.responseHeaders.get(key));
            }
            res.setBody(this.body);
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            return res;
        }
    }
}