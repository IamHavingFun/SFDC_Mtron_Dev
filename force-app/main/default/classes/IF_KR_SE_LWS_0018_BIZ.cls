/****************************************************************************************
  * File Name   : IF_KR_SE_LWS_0018_BIZ
  * Description : IF_KR_SE_LWS_0018_BIZ IF BIZ Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2020. 07. 02.  ldb3100    Create
****************************************************************************************/
public with sharing class IF_KR_SE_LWS_0018_BIZ {
    /**
     * singleton
     */
    private static IF_KR_SE_LWS_0018_BIZ sInstance = null;
    public static IF_KR_SE_LWS_0018_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_SE_LWS_0018_BIZ();
        }
        return sInstance;
    }

    /**
     * pre logic
     */
    public IF_KR_SE_LWS_0018.InputBody pre(IF_KR_SE_LWS_0018.InputBody inputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */


        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */

        return inputBody;
    }

    /**
     * post logic
     */
    public IF_KR_SE_LWS_0018.OutputBody post(IF_KR_SE_LWS_0018.InputBody inputBody, IF_KR_SE_LWS_0018.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */


        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return outputBody;
    }


}