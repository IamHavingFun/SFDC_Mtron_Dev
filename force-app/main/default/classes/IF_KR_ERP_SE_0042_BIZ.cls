/****************************************************************************************
  * File Name   : IF_KR_ERP_SE_0042_BIZ
  * Description : IF_KR_ERP_SE_0042_BIZ Class 
  * Author      : danbi.lee
  * copyright   : Copyright © I2max. All Rights Reserved.
  * Modification Log
  * ===============================================================
  * Ver   Date         Author       Modification
  * ===============================================================
    1.0   2021-12-08      danbi.lee    Create
***************************************************************************************/
public with sharing class IF_KR_ERP_SE_0042_BIZ {

    private static IF_KR_ERP_SE_0042_BIZ sInstance = null;
    public static IF_KR_ERP_SE_0042_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_ERP_SE_0042_BIZ();
        }
        return sInstance;
    }

    /**
     * pre logic
     */
    public IF_KR_ERP_SE_0042.InputBody pre(IF_KR_ERP_SE_0042.InputBody inputBody, IF_KR_ERP_SE_0042.OutputBody outputBody) {
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
    public IF_KR_ERP_SE_0042.OutputBody post(IF_KR_ERP_SE_0042.InputBody inputBody, IF_KR_ERP_SE_0042.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
            START 샘플 CODE
        */

        List<IF_KR_ERP_SE_0042.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();

        if(inputSize > 0) {

            IF_KR_ERP_SE_0042_Service.createDeliveryRecords(inputList);

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