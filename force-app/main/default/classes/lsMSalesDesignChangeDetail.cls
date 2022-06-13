/****************************************************************************************
  * @filename      : lsMSalesDesignChangeDetail
  * @projectname   : LS
  * @author        : Park JW
  * @date          : 2020-07-03 오전 9:50
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                      author          description
  * ===============================================================
    0.1     2020-07-03 오전 9:50           Park JW         Create
****************************************************************************************/

/****************************************************************************************
  * @filename      : lsMSalesDesignChangeQa
  * @projectname   : LS
  * @author        : Park JW
  * @date          : 2020-06-29 오전 9:04
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                      author          description
  * ===============================================================
    0.1     2020-06-29 오전 9:04           Park JW         Create
****************************************************************************************/

public with sharing class lsMSalesDesignChangeDetail {
    /**
     * Qa 초기 데이터로드
     *
     * @param recordId
     *
     * @return
     */
    @AuraEnabled
    public static ProductChange__c init(String recordId) {
        ProductChange__c pc = [
                SELECT Id, Name, PECN_NAME__c , PDESC__c, PREGISTRATION_DATE__c ,PAPPLY_DATE__c, PUNITEFFECTIVITY__c,
                (SELECT PECN_ID__c,
                        PLANT_ID__c,
                        PSEQ__c,
                        fm_PModel__c,
                        Name,
                        ProductId__c
                FROM ProductChange2__r)
                FROM ProductChange__c
                WHERE Id = :recordId
        ];
        return pc;
    }
}