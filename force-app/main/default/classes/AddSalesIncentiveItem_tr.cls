/**
 * Created by I2MAX on 2022-04-05.
 */

public with sharing class AddSalesIncentiveItem_tr extends TriggerHandler {
    String exceptType = '반려';
    public override void beforeInsert() {
        this.preAddSalesIncentiveItemCheckInsert((List<AddSalesIncentiveItem__c>)Trigger.new);
    }

    private void preAddSalesIncentiveItemCheckInsert(List<AddSalesIncentiveItem__c> itemList){
        // Trigger.new 에 formulaField 값이 세팅이 되어 들어와서 따로 Formula.recalculateFormulas 호출하지 않았음....
        Set<String> newTypeAsset = new Set<String>();
        for (AddSalesIncentiveItem__c item : itemList) {
            newTypeAsset.add(String.valueof(item.fm_TypeAsset__c));
        }
        List<AddSalesIncentiveItem__c> currentList = [SELECT fm_TypeAsset__c FROM AddSalesIncentiveItem__c WHERE fm_TypeAsset__c IN :newTypeAsset AND AddSalesIncentive__r.ApprovalStatus__c != :exceptType];
        Set<String> usedTypeAsset = new Set<String>();
        for(AddSalesIncentiveItem__c tmpItem : currentList){
            usedTypeAsset.add(tmpItem.fm_TypeAsset__c);
        }
        for(AddSalesIncentiveItem__c item : itemList) {
            if(usedTypeAsset.contains(item.fm_TypeAsset__c)){
                item.addError('이미 판매장려 대상으로 등록된 기대번호입니다.');
            }
        }
    }
}