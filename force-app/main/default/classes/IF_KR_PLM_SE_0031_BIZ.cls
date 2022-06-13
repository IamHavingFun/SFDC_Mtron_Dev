/**************************************************************************************** 
  * File Name   : IF_KR_PLM_SE_0031_BIZ 
  * Description : IF_KR_PLM_SE_0031_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.06.30  ldb3100             Create
****************************************************************************************/
public with sharing class IF_KR_PLM_SE_0031_BIZ {

    private static IF_KR_PLM_SE_0031_BIZ sInstance = null;
    public static IF_KR_PLM_SE_0031_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_PLM_SE_0031_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_PLM_SE_0031.InputBody pre(IF_KR_PLM_SE_0031.InputBody inputBody, IF_KR_PLM_SE_0031.OutputBody outputBody) {
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
    public IF_KR_PLM_SE_0031.OutputBody post(IF_KR_PLM_SE_0031.InputBody inputBody, IF_KR_PLM_SE_0031.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            START 샘플 CODE
        */
      
        List<IF_KR_PLM_SE_0031.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();       
        if(inputSize > 0) {
            List<IF_KR_PLM_SE_0029__c> dummyList = new List<IF_KR_PLM_SE_0029__c>();
            
            IF_KR_PLM_SE_0029__c dummyObject = null;
            
            for(IF_KR_PLM_SE_0031.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_PLM_SE_0029__c();

                dummyObject.InterfaceId__c      = IF_KR_PLM_SE_0031.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);
                
                dummyObject.PECN_ID__c              = inputObject.PECN_ID       ;
                dummyObject.PLANT_ID__c             = inputObject.PLANT_ID      ;
                dummyObject.PSEQ__c                 = inputObject.PSEQ          ;
                dummyObject.PMODEL_ID__c            = IF_Comm.strLeftPad(inputObject.PMODEL_ID)     ;
                dummyObject.EAI_SFRESULT__c         = inputObject.EAI_SFRESULT  ;
                dummyObject.EAI_SFUPDATE__c         = IF_Comm.replaceDateToStr(inputObject.EAI_SFUPDATE)  ;
               
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