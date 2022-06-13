/****************************************************************************************
  * @filename      : LsMSalesContract
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-07-04 오후 3:49
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesContract_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-04 오후 3:49     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class LsMSalesContract {

    /**
     * 계약 생성 시 Method.
     *
     * @param quoteId : Quote__c Id
     *
     * @return LsMSalesStepVO
     */
    @AuraEnabled
    public static LsMSalesStepVO getDataForNewContract(String quoteId) {
        LsMSalesContractVO lsMSalesContractVO = new LsMSalesContractVO();

        lsMSalesContractVO.bizData = new LsMSalesContractVO.BizData();
        lsMSalesContractVO.dateData = new LsMSalesContractVO.DateData();

        lsMSalesContractVO.bizData.quote = LsMSalesQCService.getQuoteById(quoteId);
        lsMSalesContractVO.bizData.isCorporationAccount = (lsMSalesContractVO.bizData.quote.CustomerName__r.RecordType.DeveloperName == 'CorporationAccount');

        lsMSalesContractVO.bizData.contract.TotalPrice__c           = lsMSalesContractVO.bizData.quote.LastQuoteAmt__c;
        lsMSalesContractVO.bizData.contract.UsedUndertakingAmt__c   = (lsMSalesContractVO.bizData.quote.UsedUndertakingAmt__c != null) ? lsMSalesContractVO.bizData.quote.UsedUndertakingAmt__c : 0;

        if(lsMSalesContractVO.bizData.quote.CustomerName__r.PersonBirthdate != null) {
            lsMSalesContractVO.dateData.tempYear     = String.valueOf(lsMSalesContractVO.bizData.quote.CustomerName__r.PersonBirthdate.year());
            lsMSalesContractVO.dateData.tempMonth    = String.valueOf(lsMSalesContractVO.bizData.quote.CustomerName__r.PersonBirthdate.month());
            lsMSalesContractVO.dateData.tempDay      = String.valueOf(lsMSalesContractVO.bizData.quote.CustomerName__r.PersonBirthdate.day());
        }

        return (LsMSalesStepVO)lsMSalesContractVO;
    }
}