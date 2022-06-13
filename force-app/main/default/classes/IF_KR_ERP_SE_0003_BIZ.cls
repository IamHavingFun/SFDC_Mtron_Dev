/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0003_BIZ 
  * Description : IF_KR_ERP_SE_0003_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.05.08  ldb3100             Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0003_BIZ {

    private static IF_KR_ERP_SE_0003_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0003_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0003_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0003.InputBody pre(IF_KR_ERP_SE_0003.InputBody inputBody, IF_KR_ERP_SE_0003.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0003.OutputBody post(IF_KR_ERP_SE_0003.InputBody inputBody, IF_KR_ERP_SE_0003.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            START 샘플 CODE
        */
      
        List<IF_KR_ERP_SE_0003.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();       
        if(inputSize > 0) {
            List<IF_KR_ERP_SE_0003__c> dummyList = new List<IF_KR_ERP_SE_0003__c>();
            
            IF_KR_ERP_SE_0003__c dummyObject = null;
            
            for(IF_KR_ERP_SE_0003.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_ERP_SE_0003__c();

                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0003.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);
                
                dummyObject.ErpVKORG__c         = inputObject.ErpVKORG      ;
                dummyObject.ErpVTWEG__c         = inputObject.ErpVTWEG      ;
                dummyObject.ErpSPART__c         = inputObject.ErpSPART      ;
                dummyObject.ProductCode__c      = inputObject.ProductCode   ;
                dummyObject.ErpPriceType__c     = inputObject.ErpPriceType  ;
                dummyObject.UnitPrice__c        = IF_Comm.stringToDecimal(inputObject.UnitPrice)     ;
                dummyObject.WAERK__c            = inputObject.WAERK         ;
                dummyObject.KMEIN__c            = inputObject.KMEIN         ;
                dummyObject.DATAB__c            = IF_Comm.replaceHyphen(inputObject.DATAB)         ;
                dummyObject.DATBI__c            = IF_Comm.replaceHyphen(inputObject.DATBI)         ;
                
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