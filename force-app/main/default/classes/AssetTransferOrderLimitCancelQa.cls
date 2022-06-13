/****************************************************************************************
  * @filename      : AssetTransferOrderLimitCancelQa
  * @author        : I2MAX
  * @date          : 2021-03-24
  * @group         : 
  * @group-content : 
  * @description   : 전수배 제한 해제 요청
  *                  승인 처리 기준
                     ISPICKVAL(InventoryType__c, "대리점재고"),
                     ISPICKVAL(AdditionalReuqestStatus__c ,""),
                     TransferCount__c = 1
  * @tester        : AssetTransferOrderLimitCancelQa_ts.cls
  * @reference     : 
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author        description
  * ===============================================================
    1.0     2021-03-24          I2MAX           Create
****************************************************************************************/
public with sharing class AssetTransferOrderLimitCancelQa {

    @AuraEnabled
    public static Asset init(final Id recordId) {
        Asset asset = [
                SELECT Id, InventoryType__c, AdditionalReuqestStatus__c, TransferCount__c, LimitCancelComment__c
                FROM Asset
                WHERE Id = :recordId
        ];
        return asset;
    }


    /**
     * asset update 후, approval process 태운다.
     *
     * @param asset {Asset}
     */
    @AuraEnabled
    public static void save(final Asset asset) {
        update asset;

        Approval.ProcessSubmitRequest reqApproval = new Approval.ProcessSubmitRequest();
        reqApproval.setComments(asset.LimitCancelComment__c);
        reqApproval.setObjectId(asset.Id);

        // Submit on behalf of a specific submitter
        reqApproval.setSubmitterId(UserInfo.getUserId());
        if(!Test.isRunningTest()) Approval.ProcessResult result = Approval.process(reqApproval);
    }

}