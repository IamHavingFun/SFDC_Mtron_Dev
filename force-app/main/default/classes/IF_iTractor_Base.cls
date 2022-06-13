/****************************************************************************************
  * File Name   : IF_iTractor_Base
  * Description : iTractor 기본 연계
  * Author      : namho100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author     Modification
  * ===============================================================
    1.0  2021.10.18  namho100   Create
****************************************************************************************/
public virtual with sharing class IF_iTractor_Base {
    private static IfStaticValue__c staticValue = IfStaticValue__c.getInstance('iTractor');
    private static IF_LOG__c ifLogInfo;
    private static Long timeTemp;
    private static String inputBody;
    private static String outputBody;

    public static boolean forceLogging = null;
    public static boolean crashTest = false;

    public enum EXCEPTION_TYPE {
        DML_EXCEPTION, IF_EXCEPTION, SECURITY_EXCEPTION
    }

    public static String exceptionType;

    public class IFException extends Exception {}

    public static void IfStaticValue(IfStaticValue__c ifValue) {
        staticValue = ifValue;
    }

    /**
     * JSON InputHeader of all request header
     */
    public class InputHeader{
        public String ifId              {get;set;}  // External interface id, created automatically, so need logic
        public String ifSenderGp        {get;set;}  // Source System Group
        public String ifSender          {get;set;}  // Source System Code
        public String ifReceiverGp      {get;set;}  // Target System Group
        public String ifReceiver        {get;set;}  // Target System Code
        public String ifTrackingId      {get;set;}  // This should Unique ID from client system to be used for tracking of transaction from client perspective. GUID for message
        public String ifDateTime        {get;set;}  // interface datetime
        public String ifResult          {get;set;}  // interface result status
        public String ifFailMsg         {get;set;}  // interface result error message
        public String ifFailCode        {get;set;}  // interface result error code

        public InputHeader(){
            // 빈생성자
        }
        public InputHeader(String TaskId){
            this.ifId           = TaskId        ;
            this.ifResult       = ''            ;
            this.ifFailMsg      = ''            ;
            this.ifFailCode     = ''            ;
            genMsg();
        }
        public InputHeader(String TaskId, String IFDateTime){
            this.ifId           = TaskId        ;
            this.ifResult       = ''            ;
            this.ifFailMsg      = ''            ;
            this.ifFailCode     = ''            ;
            this.ifTrackingId   = giveGUID()    ;
            this.ifDateTime     = IFDateTime    ;
        }
        public InputHeader(String TrackingId, String TaskId, String IFDateTime){
            this.ifTrackingId   = TrackingId    ;
            this.ifId           = TaskId        ;
            this.ifDateTime     = IFDateTime    ;
        }
        public InputHeader(String TrackingId, String TaskId, String IFDateTime, String ResultCode, String ErrorMsg, String ErrorCode){
            this.ifTrackingId   = TrackingId    ;
            this.ifId           = TaskId        ;
            this.ifDateTime     = IFDateTime    ;
            this.ifResult       = ResultCode    ;
            this.ifFailMsg      = ErrorMsg      ;
            this.ifFailCode     = ErrorCode     ;
        }
        public void genMsg(){
            this.ifTrackingId   = giveGUID();
            this.ifDateTime     = datetime.now().formatGmt('YYYYMMddHHmmss');
        }
        public String giveGUID(){
            Blob   b    = Crypto.GenerateAESKey(128);
            String h    = EncodingUtil.ConvertTohex(b);
            String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.subString(20);
            return guid;
        }
    }

    public static String giveAGGR(){
        Blob   b    = Crypto.GenerateAESKey(128);
        String h    = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.subString(20);
        return guid;
    }

    public virtual class Header{
        public InputHeader Header {get;set;}
        public Header(){
            Header = new InputHeader();
        }
    }

    public virtual class Headers{
        public InputHeader header {get;set;}
        public Headers(){
            Header = new InputHeader();
        }
    }

    // Oauth Class
    public class Oauth{
        public string access_token;
        public string instance_url;
        public string id;
        public string token_type;
        public string issued_at;
        public string signature;
    }

    public static InputHeader setOutputHeader(InputHeader output, InputHeader input) {
        output.ifTrackingId     = input.ifTrackingId    ;

        output.ifSenderGp       = input.ifReceiverGp    ;
        output.ifSender         = input.ifReceiver      ;
        output.ifReceiverGp     = input.ifSenderGp      ;
        output.ifReceiver       = input.ifSender        ;

        return output;
    }

    public static InputHeader setOutputHeader(InputHeader output, InputHeader input, Exception e) {
        output.ifSenderGp       = input.ifReceiverGp    ;
        output.ifSender         = input.ifReceiver      ;
        output.ifReceiverGp     = input.ifSenderGp      ;
        output.ifReceiver       = input.ifSender        ;

        output.ifResult         = 'E'                   ;
        output.ifFailCode       = e.getTypeName()       ;
        output.ifFailMsg        = IF_Comm.errorText(e)  ;

        return output;
    }


    public static void logInit(String logType) {
        ifLogInfo = new IF_LOG__c();
        timeTemp = System.currentTimeMillis();
        ifLogInfo.Request_to_DIH_Time__c = DateTime.newInstance(timeTemp);
        ifLogInfo.LOG_TYPE__c = logType;
    }

    public static void logStart(InputHeader input) {
        ifLogInfo.MSGGUID__c    = input.ifTrackingId;
        ifLogInfo.IFID__c       = input.ifId;
        ifLogInfo.IFDATE__c     = input.ifDateTime;
    }

    public static void logProcess(String step, String body) {
        if ('STEP1'.equals(step)) {
            inputBody = body;
            ifLogInfo.Request_Processing_Time__c = System.currentTimeMillis() - timeTemp;
            timeTemp = System.currentTimeMillis();
        } else if ('STEP1-1'.equals(step)) {
            outputBody = body;
            ifLogInfo.Response_Processing_Time__c = System.currentTimeMillis() - timeTemp;
            ifLogInfo.Response_from_DIH_Time__c = DateTime.newInstance(System.currentTimeMillis());
            timeTemp = System.currentTimeMillis();
        } else if ('STEP2'.equals(step)) {
            outputBody = body;
            ifLogInfo.Response_Data_Processing_Time__c = System.currentTimeMillis() - timeTemp;
        }
    }

    public static void logEnd(InputHeader output, String ifAggregation, String ifTotCnt, String ifSplitCnt, String ifSplitSeq, String ifRcvCnt, Boolean ifIsSfdc) {
        ifLogInfo.ifIsSfdc__c				= ifIsSfdc;
        ifLogInfo.ifAggregation__c			= ifAggregation;
        ifLogInfo.ifTotCnt__c				= ifTotCnt;
        ifLogInfo.ifSplitCnt__c			    = ifSplitCnt;
        ifLogInfo.ifSplitSeq__c			    = ifSplitSeq;
        ifLogInfo.ifRcvCnt__c				= ifRcvCnt;
        ifLogInfo.OMSGGUID__c   			= output.ifTrackingId;
        ifLogInfo.OIFID__c      			= output.ifId;
        ifLogInfo.OIFDATE__c    			= output.ifDateTime;
        ifLogInfo.OMSGSTATUS__c 			= output.ifResult;
        ifLogInfo.OERRORTEXT__c 			= output.ifFailMsg;
        ifLogInfo.OERRORCODE__c 			= output.ifFailCode;
        ifLogInfo.Processing_End_Time__c 	= DateTime.newInstance(System.currentTimeMillis());

        if(forceLogging == null){
            getIfinfo(ifLogInfo.IFID__c);
        }

        // SUCCESS인 경우 로그 쌓지 않음
        if(output.ifResult != 'S' || forceLogging == true){

            IF_INFO__c ifInfo = getIfinfo(ifLogInfo.IFID__c);
            ifLogInfo.IF_INFO__c = ifInfo.id;

            IF_BaseLogVO restLog = new IF_BaseLogVO(ifLogInfo, inputBody, outputBody);
            String restLogJSON = JSON.serialize(restLog);

            Id jobId = System.enqueueJob(new webCallOutLog_qu(restLogJSON));
        }
    }

    public static void logEnd(InputHeader output) {
        ifLogInfo.OMSGGUID__c   			= output.ifTrackingId	;
        ifLogInfo.OIFID__c      			= output.ifId    		;
        ifLogInfo.OIFDATE__c    			= output.ifDateTime		;
        ifLogInfo.OMSGSTATUS__c 			= output.ifResult		;
        ifLogInfo.OERRORTEXT__c 			= output.ifFailMsg 		;
        ifLogInfo.OERRORCODE__c 			= output.ifFailCode 	;
        ifLogInfo.Processing_End_Time__c 	= DateTime.newInstance(System.currentTimeMillis());

        if(forceLogging == null){
            getIfinfo(ifLogInfo.IFID__c);
        }

        // SUCCESS인 경우 로그 쌓지 않음
        if(output.ifResult != 'S' || forceLogging == true){

            IF_INFO__c ifInfo = getIfinfo(ifLogInfo.IFID__c);
            ifLogInfo.IF_INFO__c = ifInfo.id;

            IF_BaseLogVO restLog = new IF_BaseLogVO(ifLogInfo, inputBody, outputBody);
            String restLogJSON = JSON.serialize(restLog);

            Id jobId = System.enqueueJob(new webCallOutLog_qu(restLogJSON));
        }
    }

    public static String webCallOut(String body, String endpoint, String accessToken){
        system.debug('=================================> Start Request : ' + endpoint);

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        String resBody = null;

        System.debug('requestBody : '+ body);

        httpReq.setMethod('POST');
        httpReq.setBody(body);
        httpReq.setEndpoint(endpoint);
        httpReq.setTimeout(110000);

        httpReq.setHeader('Authorization', 'Bearer ' + accessToken);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Accept', 'application/json');
        httpRes = http.send(httpReq);

        System.debug('response Header Key : ' + httpRes.getHeaderKeys());

        System.debug('response Status Code : ' + httpRes.getStatusCode());
        System.debug('response Status : ' + httpRes.getStatus());

        if (httpRes.getStatusCode() == 200) {
            resBody = httpRes.getBody();
            if (resBody.length() > 1900000) {
                System.debug('responseBody : null');
            } else {
                System.debug('responseBody : '+resBody);
            }
            logProcess('STEP1-1', resBody);
        }

        return resBody;
    }

    // IF_ID로 IF_INFO__c개체 반환
    public static IF_INFO__c getIfinfo(String id){
        return getIfinfo(id,true);
    }

    // IF_ID로 IF_INFO__c개체 반환 대외 url일 경우
    public static IF_INFO__c getIfinfo(String id, Boolean isDih){
        List<IF_INFO__c> ifInfo;
        ifInfo = [SELECT IF_ID__c, URL__c, CYCLE__c, FROM__c, TO__c, TITLE__c, FORCE_LOGGING__c FROM IF_INFO__c WHERE IF_ID__c = :id LIMIT 1];
        System.debug('ifInfo'+ifInfo);


        System.debug('=========================');
        System.debug(JSON.serialize(ifInfo));
        System.debug('=========================');

        if(ifInfo.size() == 0){
            IF_INFO__c iff = new IF_INFO__c();
            return iff;
        }

        if (isDih) {
            ifInfo[0].URL__c = staticValue.dihUrl__c + ifInfo[0].URL__c;
        }

        // 161104 IF_INFO 에서 FORCE_LOGGING check
        if(ifInfo[0].FORCE_LOGGING__c == true){
            forceLogging = true;
        }

        return ifInfo[0];
    }

    @TestVisible private static String authEnc(){
        String algorithm  = staticValue.ENCRYPT_ALGORITHM__c;
        String dihId      = staticValue.dihAuthName__c     ;
        String dihpasswd  = staticValue.dihAuthPwd__c      ;
        String aesKey     = staticValue.dihAesKey__c       ;
        String initVector = staticValue.dihAesInitVector__c;

        String authorization = 'Basic ' + IF_Comm.cryptoEncrypt(algorithm, initVector, aesKey, dihId + ':' + dihpasswd);
        System.debug('AUTHID '+authorization);
        return authorization;
    }

    public static String getITractorToken() {

        String payload = 'username='    + staticValue.dihAuthName__c
                + '&password='          + staticValue.dihAuthPwd__c
                + '&client_id='         + staticValue.dihClientId__c
                + '&client_secret='     + staticValue.dihClientSecret__c
                + '&grant_type='        + staticValue.dihGrantType__c;

        String URL = staticValue.TOKEN_URL__c;

        // Instantiate a new http object
        Http h = new Http();
        String accessToken = '';
        if(Test.isRunningTest() == false) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(URL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody(payload);

            // Send the request, and return a response
            HttpResponse res = h.send(req);

            System.debug('response Header Key : ' + res.getHeaderKeys());

            System.debug('response Status Code : ' + res.getStatusCode());
            System.debug('response Status : ' + res.getStatus());

            Map<String,Object> resMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            accessToken = resMap.get('access_token').toString();
        }
        System.debug('=========================> accessToken : '+ accessToken);
        return accessToken;

    }

    @TestVisible private static String authEncLog(){
        String sessionId = null;
        if(UserInfo.getSessionId() != null){
            sessionId = UserInfo.getSessionId();
        }
        else{
            sessionId = getDIHSessionId();
        }
        return 'OAuth ' + sessionId;
    }

    @TestVisible private static String getDIHSessionId(){
        system.debug('=================================> Start getDIHSessionId Request');
        String preUrl = '';
        if(IF_Comm.isSandbox()){
            preUrl = 'test';
        }else{
            preUrl = 'login';
        }
        String params = 'https://'+preUrl+'.salesforce.com/services/oauth2/token';
        params += '?grant_type='+EncodingUtil.urlEncode('password','UTF-8');
        params += '&client_id='+EncodingUtil.urlEncode(staticValue.oauth_client_id__c,'UTF-8');
        params += '&client_secret='+EncodingUtil.urlEncode(staticValue.oauth_client_secret__c,'UTF-8');
        params += '&format='+EncodingUtil.urlEncode('password','UTF-8');
        params += '&username='+EncodingUtil.urlEncode(staticValue.oauth_username__c,'UTF-8');
        params += '&password='+EncodingUtil.urlEncode(staticValue.oauth_password__c,'UTF-8');
        system.debug('params'+params);

        String accessToken = '';
        if(Test.isRunningTest() == false) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(params);
            req.setMethod('POST');
            Http http = new Http();
            HTTPResponse res = http.send(req);

            IF_iTractor_Base.Oauth oauth = (IF_iTractor_Base.Oauth) JSON.deserialize(res.getBody(), IF_iTractor_Base.Oauth.class);
            accessToken = oauth.access_token;
        }
        return accessToken;
    }

    /**
     *  @description 인터페이스 로그 저장 처리 함수 (future함수 webCallOutLog 대체) Queueable Class
     *               기존 프로세스 : webCallOutLog future함수를 통해 > IF_BaseLogREST API 호출 (Callout 후 로그용 Callout 다시 호출) > LOG 및 Request, Response Attachfile DML 작업
     *  @author shlee
     */
    public with sharing class webCallOutLog_qu implements Queueable {
        public String restLogJSON;

        public webCallOutLog_qu(String restLogJSON) {
            this.restLogJSON = restLogJSON;
            // System.debug('restLogJSON : ' + restLogJSON);
        }

        public void execute(QueueableContext qc){
            //insert log;
            IF_BaseLogVO restLog = (IF_BaseLogVO) JSON.deserialize(this.restLogJSON, IF_BaseLogVO.class);
            insert restLog.log;

            //insert logFile;
            Attachment attSnd = new Attachment(Name ='InputParameter'+'.json',body = restLog.sndJsonBlob, parentId = restLog.log.id);
            Attachment attRcv = new Attachment(Name ='OutputResult'+'.json',body = restLog.rcvJsonBlob, parentId = restLog.log.id);
            insert attSnd;
            insert attRcv;

            System.debug('IF_BaseLogREST log END');
        }
    }
}