/****************************************************************************************
  * File Name   : IF_KR_ERP_SE_0039_BIZ
  * Description : IF_KR_ERP_SE_0039_BIZ Class 
  * Author      : danbi.lee
  * copyright   : Copyright © I2max. All Rights Reserved.
  * Modification Log
  * ===============================================================
  * Ver   Date         Author       Modification
  * ===============================================================
    1.0   2021-05-31      danbi.lee    Create
***************************************************************************************/
public with sharing class IF_KR_ERP_SE_0039_BIZ {

    private static IF_KR_ERP_SE_0039_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0039_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0039_BIZ();
        }
        return sInstance;
    }

    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0039.InputBody pre(IF_KR_ERP_SE_0039.InputBody inputBody, IF_KR_ERP_SE_0039.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0039.OutputBody post(IF_KR_ERP_SE_0039.InputBody inputBody, IF_KR_ERP_SE_0039.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            START 샘플 CODE
        */

        List<IF_KR_ERP_SE_0039.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();
        if(inputSize > 0) {
            List<IF_KR_ERP_SE_0039__c> dummyList = new List<IF_KR_ERP_SE_0039__c>();

            IF_KR_ERP_SE_0039__c dummyObject = null;

            for(IF_KR_ERP_SE_0039.INPUT_T_DATA inputObject : inputList) {
                dummyObject = new IF_KR_ERP_SE_0039__c();

                dummyObject.InterfaceId__c      = IF_KR_ERP_SE_0039.IFID;

                dummyObject.ifAggregation__c    = IF_Comm.convertEmpty(inputBody.ifAggregation);
                dummyObject.ifTotCnt__c         = IF_Comm.convertEmpty(inputBody.ifTotCnt);
                dummyObject.ifSplitCnt__c       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
                dummyObject.ifSplitSeq__c       = IF_Comm.convertEmpty(inputBody.ifSplitSeq);
                dummyObject.ifDateTime__c       = IF_Comm.convertEmpty(inputBody.ifDateTime);

                dummyObject.SPMON__c            = IF_Comm.replaceHyphen(inputObject.SPMON);
                dummyObject.BUKRS__c            = inputObject.BUKRS;
                dummyObject.GJAHR__c            = inputObject.GJAHR;
                dummyObject.BELNR__c            = inputObject.BELNR;
                dummyObject.VBUDAT__c           = IF_Comm.replaceHyphen(inputObject.VBUDAT);
                dummyObject.KUNNR__c            = inputObject.KUNNR;
                dummyObject.KTEXT__c            = inputObject.KTEXT;
                dummyObject.ZUONR__c            = inputObject.ZUONR;
                dummyObject.VBELNR__c           = inputObject.VBELNR;
                dummyObject.VKBUR__c            = inputObject.VKBUR;
                dummyObject.VKGRP__c            = inputObject.VKGRP;
                dummyObject.PREAMT__c           = inputObject.PREAMT;
                dummyObject.ACTAMT__c           = inputObject.ACTAMT;
                dummyObject.PAYAMT__c           = inputObject.PAYAMT;
                dummyObject.STAMT__c            = inputObject.STAMT;
                dummyObject.REMAMT__c           = inputObject.REMAMT;

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