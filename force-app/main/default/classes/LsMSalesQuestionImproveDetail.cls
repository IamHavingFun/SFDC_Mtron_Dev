/****************************************************************************************
 * @filename      : LsMSalesQuestionImproveDetail
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-06-18 오후 3:24
 * @group         :
 * @group-content :
 * @description   : [모바일] 질문/개선 상세조회
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-18 오후 3:24        SEOKHO LEE          Create
 ****************************************************************************************/

public with sharing class LsMSalesQuestionImproveDetail {

    /**
     * @param recordId
     *
     * @return
     */
    @AuraEnabled
    public static WrapperData init(String recordId) {
        WrapperData wrapperData = new WrapperData();

        wrapperData.caseData = [
                SELECT Id, Subject, Asset.Name, CreatedDate, Type, Status, Description, ProcessingResult__c, DealerFeedback__c,
                (SELECT Id, ContentDocumentId, Title, FileExtension FROM AttachedContentDocuments)
                FROM Case
                WHERE Id = :recordId
        ];
        return wrapperData;
    }

    /*@AuraEnabled
    public static void save(WrapperData wrapperData) {

        if(wrapperData != null){
            Case newCase = new Case(
                    Id = wrapperData.caseData.Id,
                    Subject = wrapperData.caseData.Subject,
                    Type = wrapperData.caseData.Type,
                    Description = wrapperData.caseData.Description
            );
            update newCase;
        }
    }*/

    public class WrapperData {
        @AuraEnabled public List<I2ComClass.Option> typeList {
            get {
                if (this.typeList == null) {
                    this.typeList = I2ComUtil.makePickListOptions('Case', 'Type', true);
                }
                return this.typeList;
            }
            private set;
        }

        @AuraEnabled public Case caseData {get;set;}
        @AuraEnabled public String sitePathPrefix {
            get{
                return I2ComUtil.getSitePathPrefix();
            }
            set;
        }
    }
}