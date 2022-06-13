/****************************************************************************************
  * File Name   : IF_KR_SE_ERP_0038_BIZ
  * Description : IF_KR_SE_ERP_0038_BIZ IF BIZ Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2020. 11. 24.  ldb3100    Create
****************************************************************************************/
public with sharing class IF_KR_SE_ERP_0038_BIZ {
    /**
     * singleton
     */
    private static IF_KR_SE_ERP_0038_BIZ sInstance = null;
    public static IF_KR_SE_ERP_0038_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_SE_ERP_0038_BIZ();
        }
        return sInstance;
    }

    /**
     * pre logic
     */
    public IF_KR_SE_ERP_0038.InputBody pre(IF_KR_SE_ERP_0038.InputBody inputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */


        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */

        return inputBody;
    }

    /**
     * post logic
     */
    public IF_KR_SE_ERP_0038.OutputBody post(IF_KR_SE_ERP_0038.InputBody inputBody, IF_KR_SE_ERP_0038.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */


        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return outputBody;
    }


}