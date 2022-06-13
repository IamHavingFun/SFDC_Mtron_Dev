/**************************************************************************************** 
  * File Name   : IF_SEMA_SFDC_0002_BIZ 
  * Description : IF_SEMA_SFDC_0002_BIZ list
  * Author      : CWH
  * Modification Log
  * =============================================================== 
  * Ver  Date          Author          Modification
  * ===============================================================
    1.0  2020. 06. 04  CWH             Create
****************************************************************************************/
public with sharing class IF_SEMA_SFDC_0002_BIZ {

    private static IF_SEMA_SFDC_0002_BIZ sInstance = null;
    public static IF_SEMA_SFDC_0002_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_SEMA_SFDC_0002_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_SEMA_SFDC_0002.InputBody pre(IF_SEMA_SFDC_0002.InputBody inputBody, IF_SEMA_SFDC_0002.OutputBody outputBody) {
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
    public IF_SEMA_SFDC_0002.OutputBody post(IF_SEMA_SFDC_0002.InputBody inputBody, IF_SEMA_SFDC_0002.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
 
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return outputBody;
    }
}