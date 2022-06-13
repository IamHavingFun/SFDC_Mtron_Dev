/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0004_BIZ 
  * Description : IF_KR_ERP_SE_0004_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.04.14   ldb3100            Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0004_BIZ {

    private static IF_KR_ERP_SE_0004_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0004_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0004_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0004.InputBody pre(IF_KR_ERP_SE_0004.InputBody inputBody, IF_KR_ERP_SE_0004.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0004.OutputBody post(IF_KR_ERP_SE_0004.InputBody inputBody, IF_KR_ERP_SE_0004.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */

        List<IF_KR_ERP_SE_0004.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();       
        if(inputSize > 0) {
            List<IF_KR_ERP_SE_0004__c> dummyList = new List<IF_KR_ERP_SE_0004__c>();
            
            IF_KR_ERP_SE_0004__c dummyObject = null;
            
            for(IF_KR_ERP_SE_0004.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_ERP_SE_0004__c();

                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0004.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);

                dummyObject.ErpWERKS__c        = inputObject.ErpWERKS           ;
                dummyObject.ErpLGORT__c        = inputObject.ErpLGORT           ;
                dummyObject.ProductCode__c     = inputObject.ProductCode        ;
                dummyObject.MachineNo__c       = inputObject.Name               ;
                dummyObject.SerialNo__c        = inputObject.SerialNo           ;
                dummyObject.Stock__c           = IF_Comm.stringToDecimal(inputObject.Stock)            ;
                dummyObject.QiStock__c         = IF_Comm.stringToDecimal(inputObject.QiStock)          ;
                dummyObject.ProductionDate__c  = IF_Comm.replaceHyphen(inputObject.ProductionDate)     ;

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