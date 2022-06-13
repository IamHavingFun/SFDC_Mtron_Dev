/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0001_BIZ 
  * Description : IF_KR_ERP_SE_0001_BIZ list
  * Author      : namho100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.04.06   namho100           Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0001_BIZ {

    private static IF_KR_ERP_SE_0001_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0001_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0001_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0001.InputBody pre(IF_KR_ERP_SE_0001.InputBody inputBody, IF_KR_ERP_SE_0001.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0001.OutputBody post(IF_KR_ERP_SE_0001.InputBody inputBody, IF_KR_ERP_SE_0001.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
      
        List<IF_KR_ERP_SE_0001.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();       
        if(inputSize > 0) {
            List<IF_KR_ERP_SE_0001__c> dummyList = new List<IF_KR_ERP_SE_0001__c>();
            
            IF_KR_ERP_SE_0001__c dummyObject = null;
            
            for(IF_KR_ERP_SE_0001.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_ERP_SE_0001__c();
                
                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0001.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);

                dummyObject.ERPCode__c             = inputObject.ERPCode               ;
                dummyObject.CustomerName__c        = inputObject.CustomerName          ;
                dummyObject.isDelete__c            = inputObject.isDelete              ;
                dummyObject.ErpVKBUR__c            = inputObject.ErpVKBUR              ;
                dummyObject.ErpKVGR2__c            = inputObject.ErpKVGR2              ;
                dummyObject.CustomerType__c        = inputObject.CustomerType          ;
                dummyObject.BusinessOffice__c      = inputObject.BusinessOffice        ;
                dummyObject.ErpBEZEI3__c           = inputObject.ErpBEZEI3             ;
                dummyObject.Phone__c               = inputObject.Phone                 ;
                dummyObject.Mobile__c              = inputObject.Mobile                ;
                dummyObject.Fax__c                 = inputObject.Fax                   ;
                dummyObject.ErpAddr__c             = inputObject.ErpAddr               ;
                dummyObject.BillingPostalCode__c   = inputObject.BillingPostalCode     ;
                dummyObject.BillingCountry__c      = inputObject.BillingCountry        ;
                dummyObject.Representative__c      = inputObject.Representative        ;
                dummyObject.BizRegNo__c            = inputObject.BizRegNo              ;
                dummyObject.ErpPriceType__c        = inputObject.ErpPriceType          ;

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