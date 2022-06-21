/****************************************************************************************
  * @filename      : lsMSalesInventoryStatusQa
  * @projectname   : LS
  * @author        : Park JW
  * @date          : 2020-06-19 오후 2:11
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                      author          description
  * ===============================================================
    0.1     2020-06-19 오후 2:11           Park JW         Create
****************************************************************************************/
public with sharing class lsMSalesInventoryStatusQa {

    /**
     * 제품의 재고현황 조회
     * @param targetProduct 재고현황 검색 제품
     *
     * @return List<AggregateResult>
     */
    @AuraEnabled
    public static List<InventoryStatusClass> init(final Product2 targetProduct) {

        System.debug(System.LoggingLevel.INFO, 'targetProduct :' + targetProduct);

        List<AggregateResult> factoryInventoryStatus = new List<AggregateResult>([
                SELECT InventoryType__c, COUNT(Id) assetCount
                FROM Asset
                WHERE InventoryType__c = '공장재고(가용)'
                AND Product2.Id = :targetProduct.Id
                GROUP BY InventoryType__c
        ]);

        List<AggregateResult> dealerInventoryStatus = new List<AggregateResult>([
                SELECT BusinessOffice__r.Name officeName, COUNT(Id) assetCount
                FROM Asset
                WHERE InventoryType__c = '대리점재고'
                AND Product2.Id = :targetProduct.Id
                AND BusinessOffice__c != null
                GROUP BY BusinessOffice__r.Name
        ]);

        List<InventoryStatusClass> resultList = new List<InventoryStatusClass>();

        for(AggregateResult ar : factoryInventoryStatus) {
            InventoryStatusClass isc = new InventoryStatusClass();
            isc.officeName = '공장재고';
            isc.assetCount = (Integer)ar.get('assetCount');
            resultList.add(isc);
        }

        for(AggregateResult ar : dealerInventoryStatus) {
            InventoryStatusClass isc = new InventoryStatusClass();
            isc.officeName = (String)ar.get('officeName');
            isc.assetCount = (Integer)ar.get('assetCount');
            resultList.add(isc);
        }

        return resultList;
    }

    public class InventoryStatusClass {
        @AuraEnabled public String officeName {get; set;}
        @AuraEnabled public Integer assetCount {get; set;}
    }
}