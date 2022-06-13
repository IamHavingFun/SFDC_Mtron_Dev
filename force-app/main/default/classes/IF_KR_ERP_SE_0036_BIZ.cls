/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0036_BIZ 
  * Description : IF_KR_ERP_SE_0036_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.06.19   ldb3100            Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0036_BIZ {

    private static IF_KR_ERP_SE_0036_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0036_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0036_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0036.InputBody pre(IF_KR_ERP_SE_0036.InputBody inputBody, IF_KR_ERP_SE_0036.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0036.OutputBody post(IF_KR_ERP_SE_0036.InputBody inputBody, IF_KR_ERP_SE_0036.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            START 샘플 CODE
        */

        List<IF_KR_ERP_SE_0036.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();
        if(inputSize > 0) {
            List<IF_KR_ERP_SE_0036__c> dummyList = new List<IF_KR_ERP_SE_0036__c>();
            
            IF_KR_ERP_SE_0036__c dummyObject = null;
            
            for(IF_KR_ERP_SE_0036.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_ERP_SE_0036__c();

                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0036.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);
                
                dummyObject.OrderID__c              = inputObject.OrderID         ;
                dummyObject.OrderLineItemID__c      = inputObject.OrderLineItemID ;
                dummyObject.ErpAUART__c             = inputObject.ErpAUART        ;
                dummyObject.ErpVKORG__c             = inputObject.ErpVKORG        ;
                dummyObject.ErpVTWEG__c             = inputObject.ErpVTWEG        ;
                dummyObject.ErpSPART__c             = inputObject.ErpSPART        ;
                dummyObject.ErpVKBUR__c             = inputObject.ErpVKBUR        ;
                dummyObject.ErpVKGRP__c             = inputObject.ErpVKGRP        ;
                dummyObject.ErpBSTKD__c             = inputObject.ErpBSTKD        ;
                dummyObject.ErpBSTDK__c             = inputObject.ErpBSTDK        ;
                dummyObject.ErpKUNNR__c             = inputObject.ErpKUNNR        ;
                dummyObject.ErpKUNNR2__c            = inputObject.ErpKUNNR2       ;
                dummyObject.ErpKUNNR3__c            = inputObject.ErpKUNNR3       ;
                dummyObject.ErpZTERM__c             = inputObject.ErpZTERM        ;
                dummyObject.ProductCode__c          = inputObject.ProductCode     ;
                dummyObject.Quanitity__c            = IF_Comm.stringToDecimal(inputObject.Quanitity)       ;
                dummyObject.ErpZFLAG__c             = inputObject.ErpZFLAG        ;
                dummyObject.SalesDocNo__c           = inputObject.SalesDocNo      ;
                dummyObject.ErpPOSNR__c             = inputObject.ErpPOSNR        ;
                dummyObject.ErpCMGST__c             = inputObject.ErpCMGST        ;
                dummyObject.ErpABGRU__c             = inputObject.ErpABGRU        ;
                dummyObject.ErpS_RESULT__c          = inputObject.ErpS_RESULT     ;
                dummyObject.ErpS_MESSAGE__c         = inputObject.ErpS_MESSAGE    ;
                
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