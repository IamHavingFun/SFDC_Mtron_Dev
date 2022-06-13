/****************************************************************************************
 * @filename      : caseEvaluation
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-06-05 오전 11:24
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-05 오전 11:24     SEOKHO LEE          Create
 ****************************************************************************************/

public with sharing class CaseEvaluation {
    /**
    * @description wrapper class for InitData
    */
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public List<I2ComClass.Option> dealerFeedBackList {
            get {
                if (this.dealerFeedBackList == null) {
                    this.dealerFeedBackList = I2ComUtil.makePickListOptions('Case', 'DealerFeedback__c', true);
                }
                return this.dealerFeedBackList;
            }
            set;
        }
        @AuraEnabled public Case caseData{get;set;}

        public InitData() {
        }

        public InitData(final Case caseData) {
            this.caseData = caseData;
        }
}
    /**
     * 초기화
     * @param recordId
     * @return
     */
    @AuraEnabled
    public static InitData init(final String recordId){
        Case newCase = [
                SELECT  Id, Status, DealerFeedback__c
                FROM Case
                WHERE id =:recordId ];
        InitData initData2 = new InitData();
        InitData initData = new InitData(newCase);
        return initData;
    }
    /**
    * 저장
    * @param caseData
    */
    @AuraEnabled
    public static void save(Case caseData) {
        if(caseData.DealerFeedback__c == '만족') {
            caseData.Status = '평가 완료 및 마감';
        } else {
            caseData.Status = '담당부서 검토';
        }

        update caseData;
    }
}