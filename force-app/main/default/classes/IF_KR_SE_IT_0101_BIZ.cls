/****************************************************************************************
  * File Name   : IF_KR_SE_IT_0101_BIZ
  * Description : IF_KR_SE_IT_0101_BIZ Class 
  * Author      : danbi.lee
  * copyright   : Copyright © I2max. All Rights Reserved.
  * Modification Log
  * ===============================================================
  * Ver   Date         Author       Modification
  * ===============================================================
    1.0   2021-08-18      danbi.lee    Create
***************************************************************************************/
public with sharing class IF_KR_SE_IT_0101_BIZ {
    /**
     * singleton
     */
    private static IF_KR_SE_IT_0101_BIZ sInstance = null;
    public static IF_KR_SE_IT_0101_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_SE_IT_0101_BIZ();
        }
        return sInstance;
    }

    /**
     * pre logic
     */
    public IF_KR_SE_IT_0101.InputBody pre(IF_KR_SE_IT_0101.InputBody inputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */


        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */

        return inputBody;
    }

    /**
     * post logic
     */
    public IF_KR_SE_IT_0101.OutputBody post(IF_KR_SE_IT_0101.InputBody inputBody, IF_KR_SE_IT_0101.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */


        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return outputBody;
    }


}