/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0016_BIZ 
  * Description : IF_KR_ERP_SE_0016_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.04.20   ldb3100            Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0016_BIZ {

    private static IF_KR_ERP_SE_0016_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0016_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0016_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0016.InputBody pre(IF_KR_ERP_SE_0016.InputBody inputBody, IF_KR_ERP_SE_0016.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0016.OutputBody post(IF_KR_ERP_SE_0016.InputBody inputBody, IF_KR_ERP_SE_0016.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            START 샘플 CODE
        */
      
        List<IF_KR_ERP_SE_0016.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();       
        if(inputSize > 0) {
            List<IF_KR_ERP_SE_0006__c> dummyList = new List<IF_KR_ERP_SE_0006__c>();
            
            IF_KR_ERP_SE_0006__c dummyObject = null;
            
            for(IF_KR_ERP_SE_0016.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_ERP_SE_0006__c();

                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0016.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);
                
                dummyObject.QueryDate__c                     = inputObject.QueryDate                  ;
                dummyObject.ErpVKORG__c                      = inputObject.ErpVKORG                   ;
                dummyObject.DistributionChannel__c           = inputObject.DistributionChannel        ;
                dummyObject.ErpSPART__c                      = inputObject.ErpSPART                   ;
                dummyObject.SalesTeam__c                     = inputObject.SalesTeam                  ;
                dummyObject.SalesGroupCode__c                = inputObject.SalesGroupCode             ;
                dummyObject.BillingDocNo__c                  = inputObject.BillingDocNo               ;
                dummyObject.BillingDocItem__c                = inputObject.BillingDocItem             ;
                dummyObject.BillingType__c                   = inputObject.BillingType                ;
                dummyObject.SalesDocNo__c                    = inputObject.SalesDocNo                 ;
                dummyObject.SalesDocItem__c                  = inputObject.SalesDocItem               ;
                dummyObject.ErpOrderType__c                  = inputObject.ErpOrderType               ;
                dummyObject.BusinessOfficeCode__c            = inputObject.BusinessOfficeCode         ;
                dummyObject.BusinessOfficeName__c            = inputObject.BusinessOfficeName         ;
                dummyObject.CustomerCode__c                  = inputObject.CustomerCode               ;
                dummyObject.CustomerName__c                  = inputObject.CustomerName               ;
                dummyObject.ProductCode__c                   = inputObject.ProductCode                ;
                dummyObject.ProductName__c                   = inputObject.ProductName                ;
                dummyObject.OrderQuantity__c                 = IF_Comm.stringToDecimal(inputObject.OrderQuantity);
                dummyObject.ErpVRKME__c                      = inputObject.ErpVRKME                   ;
                dummyObject.CurrencyName__c                  = inputObject.CurrencyName               ;
                dummyObject.SalesAmount__c                   = IF_Comm.stringToDecimal(inputObject.SalesAmount);
                dummyObject.MachineNo__c                     = inputObject.MachineNo                  ;
                dummyObject.BillingDay__c                    = IF_Comm.replaceHyphen(inputObject.BillingDay)                 ;
                dummyObject.ErpSFAKN__c                      = inputObject.ErpSFAKN                   ;
                dummyObject.ErpFKSTO__c                      = inputObject.ErpFKSTO                   ;
                dummyObject.SalesTeamName__c                 = inputObject.SalesTeamName              ;
                dummyObject.SalesGroupName__c                = inputObject.SalesGroupName             ;
                         
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