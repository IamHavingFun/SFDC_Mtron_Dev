/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0015_BIZ 
  * Description : IF_KR_ERP_SE_0015_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.04.17   ldb3100            Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0015_BIZ {

    private static IF_KR_ERP_SE_0015_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0015_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0015_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0015.InputBody pre(IF_KR_ERP_SE_0015.InputBody inputBody, IF_KR_ERP_SE_0015.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0015.OutputBody post(IF_KR_ERP_SE_0015.InputBody inputBody, IF_KR_ERP_SE_0015.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
 
        List<IF_KR_ERP_SE_0015.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();       
        if(inputSize > 0) {
            List<IF_KR_ERP_SE_0006__c> dummyList = new List<IF_KR_ERP_SE_0006__c>();
            
            IF_KR_ERP_SE_0006__c dummyObject = null;
            
            for(IF_KR_ERP_SE_0015.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_ERP_SE_0006__c();
                
                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0015.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);

                dummyObject.ErpBUKRS__c                    = inputObject.ErpBUKRS                   ;
                dummyObject.ArStatement__c                 = inputObject.ArStatement                ;
                dummyObject.FiscalYear__c                  = inputObject.FiscalYear                 ;
                dummyObject.ArStatementItem__c             = inputObject.ArStatementItem            ;
                dummyObject.CollectMoneyDocNo__c           = inputObject.CollectMoneyDocNo          ;
                dummyObject.ErpGJAHS__c                    = inputObject.ErpGJAHS                   ;
                dummyObject.CollectMoneyDocItem__c         = inputObject.CollectMoneyDocItem        ;
                dummyObject.QueryDate__c                   = inputObject.QueryDate                  ;
                dummyObject.ErpVKORG__c                    = inputObject.ErpVKORG                   ;
                dummyObject.DistributionChannel__c         = inputObject.DistributionChannel        ;
                dummyObject.ErpSPART__c                    = inputObject.ErpSPART                   ;
                dummyObject.SalesTeam__c                   = inputObject.SalesTeam                  ;
                dummyObject.SGrp__c                        = inputObject.SGrp                       ;
                dummyObject.CustomerCode__c                = inputObject.CustomerCode               ;
                dummyObject.Type__c                        = inputObject.Type                       ;
                dummyObject.CurrencyName__c                = inputObject.CurrencyName               ;
                dummyObject.ArAmtKRW__c                    = IF_Comm.stringToDecimal(inputObject.ArAmtKRW);
                dummyObject.DateOfSales__c                 = IF_Comm.replaceHyphen(inputObject.DateOfSales);
                dummyObject.ErpBLARST__c                   = inputObject.ErpBLARST                  ;
                dummyObject.CollectMoneyStatementType__c   = inputObject.CollectMoneyStatementType  ;
                dummyObject.ErpWAERK__c                    = inputObject.ErpWAERK                   ;
                dummyObject.CollectMoneyKRW__c             = IF_Comm.stringToDecimal(inputObject.CollectMoneyKRW);
                dummyObject.RealCollectMoneyDay__c         = IF_Comm.replaceHyphen(inputObject.RealCollectMoneyDay);
                dummyObject.ErpHKONT__c                    = inputObject.ErpHKONT                   ;
                dummyObject.GlName__c                      = inputObject.GlName                     ;
                dummyObject.BillingDocNo__c                = inputObject.BillingDocNo               ;
                dummyObject.SalesTeamName__c               = inputObject.SalesTeamName              ;
                dummyObject.SalesGroupName__c              = inputObject.SalesGroupName             ;
                dummyObject.CustomerName__c                = inputObject.CustomerName               ;
                dummyObject.BusinessOfficeCode__c          = inputObject.BusinessOfficeCode         ;
                dummyObject.BusinessOfficeName__c          = inputObject.BusinessOfficeName         ;
                dummyObject.ErpZUONR__c                    = inputObject.ErpZUONR                   ;
                                  
                dummyList.add(dummyObject);
            }
            
            insert dummyList; 
            
            outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
            outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
            outputBody.ifRcvCnt         = String.valueOf(inputSize);
        }
    
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return outputBody;
    }
}