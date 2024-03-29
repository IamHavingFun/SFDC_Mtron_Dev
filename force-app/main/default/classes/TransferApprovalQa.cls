/****************************************************************************************
 * @filename      : TransferApprovalQa
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-11-19 오전 11:11
 * @group         :
 * @group-content :
 * @description   : 전배 승인 처리
                     주문한 대리점(수배 대리점)은 전수배 주문에 승인하였고, 영업사원이 전배 대상 기대를 선택해서 전배 대리점에 승인/거부 요청을 보냈을 때,

                    1. 전배 대리점의 대답이;
                     - 승인은 바로 누를 수 있음. → 승인 → 전수배 주문 진행
                     - 거부를 누르려면... → 아래 프로세스 체크

                    2. 해당 기대가 전배 대상 OX?
                     - 전배 대상 X → 자유롭게 거부 할 수 있음.
                     - 전배 대상 O → 3번으로

                    3. 전배 요청을 받은 기대와 동일한 모델에 대한, 고객 인도기일이 오늘 기준으로 30일 이하로만 남은 계약이 있는가?
                     - 계약 O → 계약 첨부해서 거부 가능하나, 그 계약에 대한 Tracking 진행
                    ※전배 요청 거부에 근거한 계약은 기재된 고객 인도기일 前 반드시 PDI 등록이 완료되어야 하며, 만약 등록되지 않을 경우 Sales IQ 30점이 차감됩니다.
                     - 계약 X → 4번으로

                    4. 해당 기대에 대해 전배 요청을 거부한 적이 있는가?
                     - 거부 이력 O → 거부 불가
                    ※고객과의 계약을 근거로 전배를 거부한 이력이 있으나 이후 판매가 진행되지 않은 기대이기에, 전배 요청을 거부할 수 없습니다.
                     - 거부 이력 X → 거부 가능
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-11-19 오전 11:11      SEOKHO LEE          Create
 ****************************************************************************************/

public without sharing class TransferApprovalQa {

    /**
     * 전배 승인 처리 초기 데이터 세팅
     * @param recordId
     *
     * @return {TransferData}
     */
    @AuraEnabled
    public static TransferData init(final String recordId) {
        TransferData transferData = new TransferData();
        transferData.assetTransferRequest = [
                SELECT AssetNo__r.Name, Model__r.Name, WantedDealer__r.Name, Status__c, TransferDealer__c, Order__c, Contract__c,
                        Order__r.TransferMachineNo__c, Order__r.TransferBusinessOffice__c, Order__r.TransferProcessStatus__c,
                        Contract__r.Status__c, Contract__r.ContractNumber__c, Contract__r.CustomerExpectedDate__c
                FROM AssetTransferRequest__c
                WHERE Id = :recordId
        ];
        transferData.contracts = [
                SELECT Name, ContractNumber__c, CustomerExpectedDate__c, Status__c, fm_CustomerExpectedDateOfDue30__c, fm_CustomerName__c
                FROM Contract__c
                WHERE Id IN (
                    SELECT Contract__c
                    FROM ContractLineItem__c
                    WHERE Contract__r.Dealer__c = :transferData.assetTransferRequest.TransferDealer__c
                    AND ProductId__c = :transferData.assetTransferRequest.Model__c
                    AND Contract__r.CustomerExpectedDate__c = LAST_N_DAYS:30
                    AND Contract__r.Status__c != '워런티 진행 중'
                )
        ];

        /*
            4. 해당 기대에 대해 전배 요청을 거부한 적이 있는가? 있는데
             - 거부 이력 O → 거부 불가
            ※고객과의 계약을 근거로 전배를 거부한 이력이 있으나 이후 판매가 진행되지 않은 기대이기에, 전배 요청을 거부할 수 없습니다.
             - 거부 이력 X → 거부 가능
        */
        List<AssetTransferRequest__c> checkRejectAssets = [
                SELECT Id
                FROM AssetTransferRequest__c
                WHERE AssetNo__c = :transferData.assetTransferRequest.AssetNo__c
        ];

        transferData.isProcessed      = false;
        transferData.isRejectGrant    = true;   // 거부 권한이 있는가 체크.
        transferData.isTargetContract = false;   // 고객 인도기일이 오늘 기준으로 30일 이하로만 남은 계약이 있는가?
        transferData.isSendReceiveItem = false;
        transferData.notiMessage      = '';

        if(transferData.assetTransferRequest.Status__c != '요청') {
            transferData.isProcessed = true;
            transferData.notiMessage = '해당건의 전배 요청에 대해서 ['+transferData.assetTransferRequest.Status__c+'] 처리 한건입니다.';
        }


        return transferData;
    }

    /**
     * 전배 승인 처리 / 승인 or 거부
     * @param assetTransferRequest
     */
    @AuraEnabled
    public static void save(AssetTransferRequest__c assetTransferRequest) {

        switch on assetTransferRequest.Status__c {
            when '승인' {
                // 해당 Order__c 상태 승인, 영업소, 전배 기대번호, 주문 구분 업데이트
                assetTransferRequest.Order__r.TransferProcessStatus__c = '승인';
                assetTransferRequest.Order__r.TransferBusinessOffice__c = assetTransferRequest.TransferDealer__c;
                assetTransferRequest.Order__r.TransferMachineNo__c = assetTransferRequest.AssetNo__c;
                assetTransferRequest.Order__r.Division__c = '전수배';

                // 해당 Asset 업데이트
                update assetTransferRequest.AssetNo__r;

                // 해당 OrderLineItem 업데이트
                OrderLineitem__c oli = [
                        SELECT TransferAsset__c
                        FROM OrderLineitem__c
                        WHERE OrderId__c = :assetTransferRequest.Order__c
                        LIMIT 1
                ];
                oli.TransferAsset__c = assetTransferRequest.AssetNo__c;
                update oli;
            }
            when '거부' {
                // 해당 Order__c 상태 거부
                assetTransferRequest.Order__r.TransferProcessStatus__c = '거부';
            }
        }
        update assetTransferRequest.Order__r;
        assetTransferRequest.Order__r = null;

        update assetTransferRequest;
    }

    /**
     * 전배 Wrapper Data
     */
    public class TransferData {
        @AuraEnabled public AssetTransferRequest__c assetTransferRequest { get; set; }
        @AuraEnabled public List<Contract__c> contracts { get; set; }
        // 전배 승인 처리 여부 : true : 승인 OR 거부 / false : 요청
        @AuraEnabled public Boolean isProcessed      { get; set; }
        @AuraEnabled public Boolean isRejectGrant    { get; set; }   // 거부 권한이 있는가 체크.
        @AuraEnabled public Boolean isTargetContract { get; set; }   // 고객 인도기일이 오늘 기준으로 30일 이하로만 남은 계약이 있는가?
        @AuraEnabled public Boolean isSendReceiveItem { get; set; }  // 전수배 대상
        @AuraEnabled public String  notiMessage      { get; set; }
    }
}