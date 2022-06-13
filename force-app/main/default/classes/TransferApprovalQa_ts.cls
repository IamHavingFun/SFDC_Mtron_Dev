/****************************************************************************************
 * @filename      : TransferApprovalQa_ts
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-11-23 오후 2:31
 * @group         :
 * @group-content :
 * @description   : 전배 승인 처리
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-11-23 오후 2:31      SEOKHO LEE          Create
 ****************************************************************************************/

@isTest
private class TransferApprovalQa_ts {
    @isTest
    static void testBehavior() {

        TransferApprovalQa.TransferData transferData = new TransferApprovalQa.TransferData();

        AssetTransferRequest__c testAssetTransferRequest = TestDataSalesFactory.baseAssetTransferRequest.clone(false, true);
        testAssetTransferRequest.Order__r = TestDataSalesFactory.orderForPerFarCorp;
        testAssetTransferRequest.Status__c = '승인';
        testAssetTransferRequest.Contract__c = TestDataSalesFactory.baseContract.Id;
        testAssetTransferRequest.AssetNo__r = TestDataSalesFactory.baseAsset;
        insert testAssetTransferRequest;

        AssetTransferRequest__c testAssetTransferRequest2 = testAssetTransferRequest.clone(false, true);
        testAssetTransferRequest2.Status__c = '거부';
        insert testAssetTransferRequest2;


        transferData.assetTransferRequest = testAssetTransferRequest;
        TransferApprovalQa.init(transferData.assetTransferRequest.Id);
        TransferApprovalQa.save(transferData.assetTransferRequest);

        transferData.assetTransferRequest = testAssetTransferRequest2;
        TransferApprovalQa.save(transferData.assetTransferRequest);

    }
}