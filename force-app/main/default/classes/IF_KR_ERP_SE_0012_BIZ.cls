/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0012_BIZ 
  * Description : IF_KR_ERP_SE_0012_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.04.14   ldb3100            Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0012_BIZ {

    private static IF_KR_ERP_SE_0012_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0012_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0012_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0012.InputBody pre(IF_KR_ERP_SE_0012.InputBody inputBody, IF_KR_ERP_SE_0012.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0012.OutputBody post(IF_KR_ERP_SE_0012.InputBody inputBody, IF_KR_ERP_SE_0012.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */

        List<IF_KR_ERP_SE_0012.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();       
        if(inputSize > 0) {
            List<IF_KR_ERP_SE_0012__c> dummyList = new List<IF_KR_ERP_SE_0012__c>();
            
            IF_KR_ERP_SE_0012__c dummyObject = null;
            
            for(IF_KR_ERP_SE_0012.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_ERP_SE_0012__c();
                  
                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0012.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);

                dummyObject.ErpIV_NO__c              = inputObject.ErpIV_NO              ;
                dummyObject.ErpIV_SEQ__c             = inputObject.ErpIV_SEQ             ;
                dummyObject.ErpIV_TYPE__c            = inputObject.ErpIV_TYPE            ;
                dummyObject.ErpOUT_YN__c             = inputObject.ErpOUT_YN             ;
                dummyObject.ErpOUT_DATE__c           = IF_Comm.replaceHyphen(inputObject.ErpOUT_DATE)     ;
                dummyObject.ErpOUT_TIME__c           = IF_Comm.replaceColon(inputObject.ErpOUT_TIME)      ;
                dummyObject.ErpCANCEL_DATE__c        = IF_Comm.replaceHyphen(inputObject.ErpCANCEL_DATE)  ;
                dummyObject.ErpCANCEL_TIME__c        = IF_Comm.replaceColon(inputObject.ErpCANCEL_TIME)   ;
                dummyObject.DealerCode__c            = inputObject.DealerCode            ;
                dummyObject.DeliveryCode__c          = inputObject.DeliveryCode          ;
                dummyObject.BusinessOffice__c        = inputObject.BusinessOffice        ;
                dummyObject.BusinessOfficeName__c    = inputObject.BusinessOfficeName    ;
                dummyObject.ProductCode__c           = inputObject.ProductCode           ;
                dummyObject.ErpMAKTX__c              = inputObject.ErpMAKTX              ;
                dummyObject.Asset__c                 = inputObject.Asset                 ;
                dummyObject.CarNumber__c             = inputObject.CarNumber             ;
                dummyObject.CarrierName__c           = inputObject.CarrierName           ;
                dummyObject.CarrierContact__c        = inputObject.CarrierContact        ;
                dummyObject.DeliveryDocNo__c         = inputObject.DeliveryDocNo         ;
                dummyObject.DeliveryDocItem__c       = inputObject.DeliveryDocItem       ;
                dummyObject.SalesDocNo__c            = inputObject.SalesDocNo            ;
                dummyObject.SalesDocItem__c          = inputObject.SalesDocItem          ;
                dummyObject.DeliveryType__c          = inputObject.DeliveryType          ;

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