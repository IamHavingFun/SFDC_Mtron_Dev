/**************************************************************************************** 
  * File Name   : IF_BaseLogREST 
  * Description : IF_BaseLogREST
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date        Author    Modification
  * ===============================================================
    1.0  2020.03.09  ldb3100         Create   
****************************************************************************************/
@RestResource(urlMapping='/IF_BaseLogREST/*')
global with sharing class IF_BaseLogREST {
    public static boolean crashTest = false;
    @HttpPost
    global static String log() {
        try {
            System.debug('IF_BaseLogREST log START');
            if(Test.isRunningTest() && crashTest) {  // Purposely crash test.
                throw new DmlException('Dml Exception');
            }
            
            Blob requestBodyBlob = RestContext.request.requestBody;
            if(requestBodyBlob.size() < 6000000) {              
                return insertLogFile(requestBodyBlob);
            } else {
                asyncInsertFile(requestBodyBlob);
                
                return 'success';
            }
            
        } catch(DMLException e){
            System.debug('The following exception has occurred: ' + e.getMessage());
            return 'fail';
        }
    }
    
    private static String insertLogFile(Blob requestBodyBlob) {
        String logJSON = requestBodyBlob.toString();
        //insert log;
        IF_BaseLogVO restLog = (IF_BaseLogVO) JSON.deserialize(logJSON, IF_BaseLogVO.class);
        System.debug('logJSON : ' + logJSON);
        
        insert restLog.log;
        
        //insert logFile;
        Attachment attSnd = new Attachment(Name ='InputParameter'+'.json',body = restLog.sndJsonBlob, parentId = restLog.log.id);
        Attachment attRcv = new Attachment(Name ='OutputResult'+'.json',body = restLog.rcvJsonBlob, parentId = restLog.log.id);
        insert attSnd;
        insert attRcv;
        
        System.debug('IF_BaseLogREST log END');
            
        return 'success LOG_ID:'+restLog.log.id;
    }
    
    @future
    public static void asyncInsertFile(Blob requestBodyBlob) {
        insertLogFile(requestBodyBlob);
    }
}