/**************************************************************************************** 
  * File Name   : IF_KR_ERP_SE_0028_BIZ 
  * Description : IF_KR_ERP_SE_0028_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.05.07  ldb3100             Create
****************************************************************************************/
public with sharing class IF_KR_ERP_SE_0028_BIZ {

    private static IF_KR_ERP_SE_0028_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0028_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0028_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0028.InputBody pre(IF_KR_ERP_SE_0028.InputBody inputBody, IF_KR_ERP_SE_0028.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0028.OutputBody post(IF_KR_ERP_SE_0028.InputBody inputBody, IF_KR_ERP_SE_0028.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            START 샘플 CODE
        */
      
        List<IF_KR_ERP_SE_0028.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();

        List<IF_KR_ERP_SE_0028.INPUT_T_DATA2> inputList2 = inputBody.t_data2;
        Integer inputSize2 = inputList2.size();

        if(inputSize > 0) {
            List<IF_KR_ERP_SE_0003__c> dummyList = new List<IF_KR_ERP_SE_0003__c>();
            
            IF_KR_ERP_SE_0003__c dummyObject = null;
            
            for(IF_KR_ERP_SE_0028.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_ERP_SE_0003__c();

                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0028.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);
                
                dummyObject.ErpVKORG__c         = inputObject.ErpVKORG;
                dummyObject.ErpVTWEG__c         = inputObject.ErpVTWEG;
                dummyObject.ErpWERKS__c         = inputObject.ErpWERKS;
                dummyObject.ProductCode__c      = inputObject.ProductCode;
                dummyObject.ErpMAKTX__c         = inputObject.ErpMAKTX;
                dummyObject.ErpMTART__c         = inputObject.ErpMTART;
                dummyObject.MATGR__c            = inputObject.MATGR;
                  
                dummyList.add(dummyObject);
            }
            
            insert dummyList;
        }

        if(inputSize2 > 0) {
            List<IF_KR_ERP_SE_0003__c> dummyList = new List<IF_KR_ERP_SE_0003__c>();

            IF_KR_ERP_SE_0003__c dummyObject = null;

            for(IF_KR_ERP_SE_0028.INPUT_T_DATA2 inputObject : inputList2) {
                dummyObject = new IF_KR_ERP_SE_0003__c();

                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0028.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);

                dummyObject.MA_NORMAL_YN__c     = 'Y';
                dummyObject.MATNR__c            = inputObject.MATNR;
                dummyObject.TABIX__c            = inputObject.TABIX;
                dummyObject.POSNR__c            = inputObject.POSNR;
                dummyObject.ATNAM__c            = inputObject.ATNAM;
                dummyObject.SMBEZ__c            = inputObject.SMBEZ;
                dummyObject.AUSP1__c            = inputObject.AUSP1;
                dummyObject.AUSP2__c            = inputObject.AUSP2;


                dummyList.add(dummyObject);
            }

            insert dummyList;

        }

        if((inputSize+inputSize2) > 0){
            outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
            outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
            outputBody.ifRcvCnt         = String.valueOf(inputSize+inputSize2);
        }

        /*
            END 샘플 CODE
        */
        
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return outputBody;
    }
}