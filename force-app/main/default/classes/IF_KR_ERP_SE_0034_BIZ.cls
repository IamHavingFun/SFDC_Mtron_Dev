/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0034_BIZ 
  * Description : IF_KR_ERP_SE_0034_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.06.30  ldb3100             Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0034_BIZ {

    private static IF_KR_ERP_SE_0034_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0034_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0034_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0034.InputBody pre(IF_KR_ERP_SE_0034.InputBody inputBody, IF_KR_ERP_SE_0034.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0034.OutputBody post(IF_KR_ERP_SE_0034.InputBody inputBody, IF_KR_ERP_SE_0034.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            START 샘플 CODE
        */
      
        List<IF_KR_ERP_SE_0034.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();       
        if(inputSize > 0) {
            List<IF_KR_ERP_SE_0001__c> dummyList = new List<IF_KR_ERP_SE_0001__c>();
            
            IF_KR_ERP_SE_0001__c dummyObject = null;
            
            for(IF_KR_ERP_SE_0034.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_ERP_SE_0001__c();

                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0034.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);
                
                dummyObject.ErpBUKRS__c                = inputObject.ErpBUKRS;
                dummyObject.ERPCode__c                 = inputObject.ERPCode;
                dummyObject.ErpName__c                 = inputObject.ErpName;
                dummyObject.BlacklistWarning__c        = inputObject.BlacklistWarning;
                dummyObject.BlacklistErpDelivery__c    = inputObject.BlacklistErpDelivery;
                dummyObject.Blacklist30Days__c         = inputObject.Blacklist30Days;
                dummyObject.BlacklistReason__c         = inputObject.BlacklistReason;
                dummyObject.DeliveryStopDate__c        = inputObject.DeliveryStopDate;
                
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