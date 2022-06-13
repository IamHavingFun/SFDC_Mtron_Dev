/****************************************************************************************
 * @filename      : LsMSalesQuestionImproveRegister
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-06-11 오전 11:22
 * @group         :
 * @group-content :
 * @description   : [모바일] 질문/개선 신규 등록
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1    2020-06-11 오전 11:22      SEOKHO LEE          Create
 ****************************************************************************************/

public with sharing class LsMSalesQuestionImproveRegister {

    /**
     *
     * init
     * @return
     */
    @AuraEnabled
    public static CaseCreateData init(String recordId) {
        CaseCreateData caseCreateData = new CaseCreateData();
        caseCreateData.caseData = new Case();

        if(String.isNotEmpty(recordId)) {
            caseCreateData.caseData = [
                    SELECT Id, Type,Status, Subject, CreatedDate, Description, DealerFeedback__c, ProcessingResult__c, AccountId, AssetId, Asset.Name,
                            (SELECT Id, ContentDocumentId, Title, FileExtension FROM AttachedContentDocuments)
                    FROM Case
                    WHERE Id = :recordId
            ];
            caseCreateData.assetName = caseCreateData.caseData.Asset.Name;
        }

        return caseCreateData;
    }

    /**
     *
     * Save(Create & Edit)
     * @param caseCreateData
     *
     * @return
     */
    @AuraEnabled
    public static Case save(CaseCreateData caseCreateData) {

        if(String.isNotBlank(caseCreateData.assetName)) {
            List<Asset> asset = [
                    SELECT Id
                    FROM Asset
                    WHERE Name = :caseCreateData.assetName
            ];
            if(asset.isEmpty()){
                throw new DmlException('해당 기대번호를 찾을 수 없습니다. 기대번호를 다시 확인 해주세요.');
            }
            caseCreateData.caseData.AssetId = asset[0].Id;
        }
        // 레코드 아이디가 존재 하지 않으면 insert
        if(String.isEmpty(caseCreateData.caseData.Id)){
            caseCreateData.caseData.AccountId = ModelUser.getUserData().AccountId;
            caseCreateData.caseData.Status = '접수';
            insert caseCreateData.caseData;
        // 레코드 아이디가 존재하면 update
        } else{
            update caseCreateData.caseData;
        }
        return caseCreateData.caseData;
    }
    /**
    * @WrapperClass
    * Case picklist , 질문/개선
    */
    public class CaseCreateData extends I2ComClass.InitData {
        @AuraEnabled public List<I2ComClass.Option> typeList {
            get {
                if (this.typeList == null) {
                    this.typeList = I2ComUtil.makePickListOptions('Case', 'Type', true);
                }
                return this.typeList;
            }
            private set;
        }
        @AuraEnabled public Case            caseData      {get;set;}
        @AuraEnabled public String          assetName {get; set;}
    }
}