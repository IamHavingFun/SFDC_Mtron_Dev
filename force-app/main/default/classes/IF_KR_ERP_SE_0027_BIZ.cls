/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0027_BIZ 
  * Description : IF_KR_ERP_SE_0027_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.05.06  ldb3100             Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0027_BIZ {

    private static IF_KR_ERP_SE_0027_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0027_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0027_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0027.InputBody pre(IF_KR_ERP_SE_0027.InputBody inputBody, IF_KR_ERP_SE_0027.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0027.OutputBody post(IF_KR_ERP_SE_0027.InputBody inputBody, IF_KR_ERP_SE_0027.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            START 샘플 CODE
        */
      
        List<IF_KR_ERP_SE_0027.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();       
        if(inputSize > 0) {
            List<IF_KR_ERP_SE_0001__c> dummyList = new List<IF_KR_ERP_SE_0001__c>();
            
            IF_KR_ERP_SE_0001__c dummyObject = null;
            
            for(IF_KR_ERP_SE_0027.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_ERP_SE_0001__c();

                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0027.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);
                
                dummyObject.ErpKUNNR__c         = inputObject.ErpKUNNR;
                dummyObject.ErpVKORG__c         = inputObject.ErpVKORG;
                dummyObject.ErpVTWEG__c         = inputObject.ErpVTWEG;
                dummyObject.ErpSPART__c         = inputObject.ErpSPART;
                dummyObject.ErpPARVW__c         = inputObject.ErpPARVW;
                dummyObject.ErpPARZA__c         = inputObject.ErpPARZA;
                dummyObject.ErpKUNN2__c         = inputObject.ErpKUNN2;
                
                dummyList.add(dummyObject);
            }
            
            insert dummyList; 
            
            outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
            outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
            outputBody.ifRcvCnt         = String.valueOf(inputSize);
        }

        /*
            END 샘플 CODE
        */
        
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return outputBody;
    }
}