/****************************************************************************************
 * @filename      :
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-07-08 오전 09:00
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
 0.1     2020-07-08 오전 09:00     SEOKHO LEE             Create
 ****************************************************************************************/
({
    fn_initSearch : function(component){
        component.set('v.reqData.pageSize', '10');
        component.set('v.reqData.name', '');
    },


    fn_saveCondition : function(component, helper){
/*        const asset = component.get('v.customerData.asset');

        // 해당 자산의 실 고객이 존재하는 경우
        if(asset.Customer__c != null) {
            helper.gfn_toast('해당 기대번호는 이미 실고객이 등록된 자산입니다. 변경이 필요하면 SE 담당자에게 문의 바랍니다.','w');
            return false;
        }
        // 해당 자산의 대리점이 존재하는 경우
        if(asset.Dealer__c != component.get('v.customerData.account.Dealer__c') && asset.Dealer__c != null){
            helper.gfn_toast('해당 기대번호는 이미 다른 대리점에서 관리하고 있는 자산입니다. 변경이 필요하면 SE 담당자에게 문의 바랍니다.','w');
            return false;
        }

        // 대리점재고 & LS / 타 대리점 재고 자산 처리 X
        if(asset.InventoryType__c  == '대리점재고' && asset.Brand__c == 'LS') {
            if(component.get('v.customerData.account.Dealer__c') == asset.Dealer__c){
                return true;
            } else{
                helper.gfn_toast('고객의 대리점과 자산의 대리점을 확인 하세요','w');
            }
        } else{
                helper.gfn_toast('재고 유형 또는 브랜드를 확인하세요','w');
        }

        // 재고유형 = '타브랜드' && 재고유형 = '실판매'
        if((asset.InventoryType__c  == '타브랜드') ||  (asset.InventoryType__c  == '실판매')){
            return true;
        }

        return false;*/

        return true;
    },
})