/**
 * Created by MS on 2020-07-02.
 */
public with sharing class LsMSalesCaseEvaluationQa {

    /**
     *
     * init
     * @return
     */
    @AuraEnabled
    public static CustomizedCase__c init(String recordId) {
        CustomizedCase__c caseRec = new CustomizedCase__c(Id=recordId);
        caseRec.DealerFeedback__c = '만족';
        return caseRec;
    }
    /**
     * @param caseRec
     *
     * @return
     */
    @AuraEnabled
    public static CustomizedCase__c save(CustomizedCase__c caseRec) {
        update caseRec;
        return caseRec;
    }
/*
    @AuraEnabled
    public static Case init(String recordId) {
        Case caseRec = new Case(Id=recordId);
        caseRec.DealerFeedback__c = '만족';
        return caseRec;
    }

    @AuraEnabled
    public static Case save(Case caseRec) {
        caseRec.Status = '완료';
        update caseRec;
        return caseRec;
    }
*/
}