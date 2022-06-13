/**************************************************************************************** 
  * ProjectName : I2SEMA
  * File Name   : SEMA_BULK_TEST_0002_BIZ
  * Description : SEMA_BULK_TEST_0002_BIZ Class
  * Copyright   : Copyright © 2020 i2max All Rights Reserved
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date          Author          Modification
  * ===============================================================
    1.0  2019. 02. 28  ldb3100         Create
****************************************************************************************/
public with sharing class SEMA_BULK_TEST_0002_BIZ {

    private static SEMA_BULK_TEST_0002_BIZ sInstance = null;
    public static SEMA_BULK_TEST_0002_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new SEMA_BULK_TEST_0002_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public SEMA_BULK_TEST_0002.InputBody pre(SEMA_BULK_TEST_0002.InputBody inputBody, SEMA_BULK_TEST_0002.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작
        /*
            값할당 샘플
        */          
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return inputBody;
    }
    
    /**
     * post logic
     */
    public SEMA_BULK_TEST_0002.OutputBody post(SEMA_BULK_TEST_0002.InputBody inputBody, SEMA_BULK_TEST_0002.OutputBody outputBody) {
       
        List<SEMA_BULK_TEST_0002.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();       
        if(inputSize > 0) {
            List<BulkTest__c> dummyList = new List<BulkTest__c>();
            
            BulkTest__c dummyObject = null;
            
            for(SEMA_BULK_TEST_0002.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new BulkTest__c();

                dummyObject.ifAggregation__c = inputBody.ifAggregation   ;
                
                dummyObject.mt_pr__c             = inputObject.mt_pr             ; 
                dummyObject.mt_seq__c            = inputObject.mt_seq            ;
                dummyObject.priority__c          = inputObject.priority          ;
                dummyObject.date_client_req__c   = inputObject.date_client_req   ;
                dummyObject.content__c           = inputObject.content           ;
                dummyObject.callback__c          = inputObject.callback          ;
                dummyObject.msg_status__c        = inputObject.msg_status        ;
                dummyObject.recipient_num__c     = inputObject.recipient_num     ;

                if(inputBody.ifTotCnt != null && inputBody.ifTotCnt != '' && Integer.valueOf(inputBody.ifTotCnt) > 200){
                    dummyObject.ifTotCnt__c      = inputBody.ifTotCnt        ;
                    dummyObject.ifSplitCnt__c    = inputBody.ifSplitCnt      ;
                    dummyObject.ifSplitSeq__c    = inputBody.ifSplitSeq      ;  
                }
                
                dummyList.add(dummyObject);
            }

            insert dummyList; 

            // 마지막 seq 일때 object count & ifSplitCnt 일치여부 체크            
            if((inputBody.ifTotCnt != null) && (Integer.valueOf(inputBody.ifTotCnt) > 200)){
                if((inputBody.ifSplitCnt).equals(inputBody.ifSplitSeq)){ 
                    Integer objectCnt = [SELECT count() FROM BulkTest__c WHERE ifAggregation__c =: inputBody.ifAggregation];
                    String totCnt  = inputBody.ifTotCnt;

                    if(objectCnt != Integer.valueOf(totCnt)){ // object 카운트수와 totCnt가 일치하지 않는다면 전체삭제
                        delete [SELECT Id FROM BulkTest__c WHERE ifAggregation__c =: inputBody.ifAggregation]; 
                    }
                }
            }       
            outputBody.ifRcvCnt = String.valueOf(dummyList.size());
            outputBody.ifAggregation = inputBody.ifAggregation;
        }

        return outputBody;
    }

    public static void delBulk (){
        delete [SELECT Id FROM BulkTest__c]; 
    }

    public static void delLog (){
        delete [SELECT Id FROM Notiforce_IF_LOG__c]; 
    }

}