/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0002_BIZ 
  * Description : IF_KR_ERP_SE_0002_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.05.11  ldb3100             Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0002_BIZ {

    private static IF_KR_ERP_SE_0002_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0002_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0002_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0002.InputBody pre(IF_KR_ERP_SE_0002.InputBody inputBody, IF_KR_ERP_SE_0002.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0002.OutputBody post(IF_KR_ERP_SE_0002.InputBody inputBody, IF_KR_ERP_SE_0002.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            START 샘플 CODE
        */
      
        List<IF_KR_ERP_SE_0002.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();       
        if(inputSize > 0) {
            List<IF_KR_ERP_SE_0001__c> dummyList = new List<IF_KR_ERP_SE_0001__c>();
            
            IF_KR_ERP_SE_0001__c dummyObject = null;
            
            for(IF_KR_ERP_SE_0002.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_ERP_SE_0001__c();

                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0002.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);
                
                dummyObject.ERPCode__c                 = inputObject.ERPCode                                       ;
                dummyObject.ErpVKORG__c                = inputObject.ErpVKORG                                      ;
                dummyObject.ErpVTWEG__c                = inputObject.ErpVTWEG                                      ;
                dummyObject.ErpSPART__c                = inputObject.ErpSPART                                      ;
                dummyObject.ErpVKBUR__c                = inputObject.ErpVKBUR                                      ;
                dummyObject.CollateralAmount__c        = IF_Comm.stringToDecimal(inputObject.CollateralAmount)     ;
                dummyObject.CreditLimit__c             = IF_Comm.stringToDecimal(inputObject.CreditLimit)          ;
                dummyObject.LimitUsage__c              = IF_Comm.stringToDecimal(inputObject.LimitUsage)           ;
                dummyObject.CreditRating__c            = inputObject.CreditRating                                  ;
                dummyObject.TotalBonds__c              = IF_Comm.stringToDecimal(inputObject.TotalBonds)           ;
                dummyObject.OverdueBond__c             = IF_Comm.stringToDecimal(inputObject.OverdueBond)          ;
                dummyObject.OverdueRatio__c            = IF_Comm.stringToDecimal(inputObject.OverdueRatio)         ;
                dummyObject.NormalBonds__c             = IF_Comm.stringToDecimal(inputObject.NormalBonds)          ;
                dummyObject.OverdueLessOneMonth__c     = IF_Comm.stringToDecimal(inputObject.OverdueLessOneMonth)  ;
                dummyObject.OverdueOneTwoMonths__c     = IF_Comm.stringToDecimal(inputObject.OverdueOneTwoMonths)  ;
                dummyObject.OverdueTwoThreeMonths__c   = IF_Comm.stringToDecimal(inputObject.OverdueTwoThreeMonths);
                dummyObject.OverdueSixMonths__c        = IF_Comm.stringToDecimal(inputObject.OverdueSixMonths)     ;
                dummyObject.OverdueOneYear__c          = IF_Comm.stringToDecimal(inputObject.OverdueOneYear)       ;
                dummyObject.ErpWAERS__c                = inputObject.ErpWAERS                                      ;
                dummyObject.ErpNAME1__c                = inputObject.ErpNAME1                                      ;
                dummyObject.ErpVKBURT__c               = inputObject.ErpVKBURT                                     ;
                dummyObject.ErpKVGR3__c                = inputObject.ErpKVGR3                                      ;
                dummyObject.ErpBEZEI3__c               = inputObject.ErpBEZEI3                                     ;
     
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