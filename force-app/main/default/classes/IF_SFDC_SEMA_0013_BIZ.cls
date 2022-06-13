/****************************************************************************************
  * ProjectName : I2SEMA
  * File Name   : IF_SFDC_SEMA_0013_BIZ
  * Description : IF_SFDC_SEMA_0013_BIZ Class
  * Copyright   : Copyright © 2020 i2max All Rights Reserved
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author       Modification
  * ===============================================================
    1.0  2020. 03. 02   ldb3100      Create
****************************************************************************************/
public with sharing class IF_SFDC_SEMA_0013_BIZ {

    /**
     * singleton
     */
    private static IF_SFDC_SEMA_0013_BIZ sInstance = null;
    public static IF_SFDC_SEMA_0013_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_SFDC_SEMA_0013_BIZ();
        }
        return sInstance;
    }

    /**
     * pre logic
     */
    public IF_SFDC_SEMA_0013.InputBody pre(IF_SFDC_SEMA_0013.InputBody inputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */


        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return inputBody;
    }

    /**
     * post logic
     */
    public IF_SFDC_SEMA_0013.OutputBody post(IF_SFDC_SEMA_0013.InputBody inputBody, IF_SFDC_SEMA_0013.OutputBody outputBody) {

        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return outputBody;
    }
}