/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0006_BIZ 
  * Description : IF_KR_ERP_SE_0006_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.04.14   ldb3100            Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0006_BIZ {

    private static IF_KR_ERP_SE_0006_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0006_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0006_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0006.InputBody pre(IF_KR_ERP_SE_0006.InputBody inputBody, IF_KR_ERP_SE_0006.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0006.OutputBody post(IF_KR_ERP_SE_0006.InputBody inputBody, IF_KR_ERP_SE_0006.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            START 샘플 CODE
        */
        
        List<IF_KR_ERP_SE_0006.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();       
        if(inputSize > 0) {
            List<IF_KR_ERP_SE_0006__c> dummyList = new List<IF_KR_ERP_SE_0006__c>();
            
            IF_KR_ERP_SE_0006__c dummyObject = null;
            
            for(IF_KR_ERP_SE_0006.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_ERP_SE_0006__c();

                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0006.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);
                  
                dummyObject.DataType__c               = inputObject.DataType                              ;
                dummyObject.QueryDate__c              = inputObject.QueryDate                             ;
                dummyObject.ErpCode__c                = inputObject.ErpCode                               ;
                dummyObject.ProductCode__c            = inputObject.ProductCode                           ;
                dummyObject.MachineNo__c              = inputObject.MachineNo                             ;
                dummyObject.ErpBizOffice__c           = inputObject.ErpBizOffice                          ;
                dummyObject.ErpBizOfficeName__c       = inputObject.ErpBizOfficeName                      ;
                dummyObject.ErpName__c                = inputObject.ErpName                               ;
                dummyObject.ErpMAKTX__c               = inputObject.ErpMAKTX                              ;
                dummyObject.Qty__c                    = IF_Comm.stringToDecimal(inputObject.Qty)          ;
                dummyObject.StockInDate__c            = IF_Comm.replaceHyphen(inputObject.StockInDate)    ;
                dummyObject.ProductionDate__c         = inputObject.ProductionDate                        ;
                dummyObject.CustomerName__c           = inputObject.CustomerName                          ;
                dummyObject.SalesDate__c              = inputObject.SalesDate                             ;
                dummyObject.SalesDocNo__c             = inputObject.SalesDocNo                            ;
                dummyObject.SalesDocItem__c           = inputObject.SalesDocItem                          ;
                dummyObject.OrderDivision__c          = inputObject.OrderDivision                         ;
                dummyObject.Price__c                  = IF_Comm.stringToDecimal(inputObject.Price)        ;
                dummyObject.FirstDeliveryDate__c      = IF_Comm.replaceHyphen(inputObject.FirstDeliveryDate)    ;
                dummyObject.ElapsedDayOut__c          = IF_Comm.stringToDecimal(inputObject.ElapsedDayOut)      ;
                dummyObject.ElapsedDayIn__c           = IF_Comm.stringToDecimal(inputObject.ElapsedDayIn)       ;
                dummyObject.ActualSalesDayOut__c      = IF_Comm.stringToDecimal(inputObject.ActualSalesDayOut)  ;
                dummyObject.ActualSalesDayIn__c       = IF_Comm.stringToDecimal(inputObject.ActualSalesDayIn)   ;
                
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