/****************************************************************************************
  * @filename      : DealerStockLevel_tr
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-22
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : DealerStockLevel_tr_ts
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-07-22             Park HE         Create
****************************************************************************************/
public with sharing class DealerStockLevel_tr extends TriggerHandler{
    public override void beforeInsert() {
        this.insertBusinessOffice(Trigger.new);
    }

    private void insertBusinessOffice(List<DealerStockLevel__c> newList) {

        Map<String, Account> accMap =new Map<String, Account>();
        for(Account acc : [SELECT id, ERPCode__c FROM  Account WHERE ERPCode__c !=NULL AND CustomerType__c='영업소' ]){
            accMap.put(acc.ERPCode__c, acc );
        }

        for (DealerStockLevel__c load : newList) {
            if(accMap.containsKey(load.ErpBusinessOfficeCode__c)){
                load.BusinessOffice__c = accMap.get(load.ErpBusinessOfficeCode__c).Id;
            }else{
                load.addError('영업소 ERP 코드를 확인하세요. 일치하는 영업소가 없습니다.');
            }
        }
    }
}