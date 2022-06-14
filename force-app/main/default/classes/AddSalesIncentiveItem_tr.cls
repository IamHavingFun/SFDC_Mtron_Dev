/**
 * Created by I2MAX on 2022-04-05.
 */

public with sharing class AddSalesIncentiveItem_tr extends TriggerHandler {
    String exceptType = '반려';
    public override void beforeInsert() {
        this.preAddSalesIncentiveItemCountCheck((List<AddSalesIncentiveItem__c>)Trigger.new);
        this.preAddSalesIncentiveItemCheckInsert((List<AddSalesIncentiveItem__c>)Trigger.new);
    }

    /**
     * 대상 건수 보다 많은지 체크.
     * @param itemList
     */
    private void preAddSalesIncentiveItemCountCheck(List<AddSalesIncentiveItem__c> itemList){
        // Trigger.new 에 formulaField 값이 세팅이 되어 들어와서 따로 Formula.recalculateFormulas 호출하지 않았음....
        Set<String> newAddSalesIncentive = new Set<String>();
        for (AddSalesIncentiveItem__c item : itemList) {
            newAddSalesIncentive.add(item.AddSalesIncentive__c);
        }
        Map<String, Boolean> addSalesIncentiveMap = new Map<String, Boolean>();
        Decimal targetCount;
        for(AddSalesIncentive__c r : [
                SELECT Id, LimitCount__c,
                (SELECT Id FROM AddSalesFeeItems__r)
                FROM AddSalesIncentive__c WHERE Id IN :newAddSalesIncentive ])
        {
            targetCount = 0;
            if(r.AddSalesFeeItems__r.isEmpty() == false) targetCount = r.AddSalesFeeItems__r.size();
            addSalesIncentiveMap.put(r.Id, false);
            // 현재 추가되는 레코드를 위해서 건수 1 증가.
            targetCount++;
            if(r.LimitCount__c < targetCount) {
                addSalesIncentiveMap.put(r.Id, true);
            }
        }
        for(AddSalesIncentiveItem__c item : itemList) {
            if(addSalesIncentiveMap.get(item.AddSalesIncentive__c) == true){
                item.addError('추가판매장려의 대수 이상으로 추가할 수 없습니다.');
            }
        }
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