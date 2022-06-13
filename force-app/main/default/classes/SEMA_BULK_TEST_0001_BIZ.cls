/****************************************************************************************
  * ProjectName : I2SEMA
  * File Name   : SEMA_BULK_TEST_0001_BIZ
  * Description : SEMA_BULK_TEST_0001_BIZ Class
  * Copyright   : Copyright © 2020 i2max All Rights Reserved
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author       Modification
  * ===============================================================
    1.0  2020. 02. 28   ldb3100      Create
****************************************************************************************/
public with sharing class SEMA_BULK_TEST_0001_BIZ {

    /**
     * singleton
     */
    private static SEMA_BULK_TEST_0001_BIZ sInstance = null;
    public static SEMA_BULK_TEST_0001_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new SEMA_BULK_TEST_0001_BIZ();
        }
        return sInstance;
    }

    /**
     * pre logic
     */
    public SEMA_BULK_TEST_0001.InputBody pre(SEMA_BULK_TEST_0001.InputBody inputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */


        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return inputBody;
    }

    /**
     * post logic
     */
    public SEMA_BULK_TEST_0001.OutputBody post(SEMA_BULK_TEST_0001.InputBody inputBody, SEMA_BULK_TEST_0001.OutputBody outputBody) {

        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return outputBody;
    }
}