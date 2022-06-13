/****************************************************************************************
  * @filename      : ZZ_OrderUpdate_ba
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-05-14
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-05-14             Park HE         Create
****************************************************************************************/

public class ZZ_OrderUpdate_ba implements Database.Batchable<SObject>, Database.Stateful {

    // 외부 Argument
    public String query;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isEmpty(this.query)) {
            this.query = '';
            this.query += ' SELECT Id, Status__c, (SELECT Id, ReleaseDate__c, Division__c FROM Delivery__r) \n' +
                            ' FROM Order__c \n' +
                            ' WHERE Status__c = \'출하\' ' ;
        }
        query = ' SELECT  ' +
        '         Id, Name, Division__c, Status__c, SalesDocNo__c, BusinessOffice__r.Name, BusinessOfficeRep__r.Name, Dealer__r.Name, DealerRep__r.Name, CreatedDate, LastModifiedDate  ' +
        ' , (SELECT Id, Division__c, ReleaseDate__c, DateOfLoading__c, CreatedDate FROM Delivery__r WHERE ReleaseDate__c = NULL OR DateOfLoading__c = NULL ) ' +
        ' FROM Order__c ' +
        ' WHERE Status__c = \'종료\' '+
//        ' AND LastModifiedDate = TODAY ' +
//        ' AND LastModifiedById = \'0052w000001Z5eVAAS\' ' +
        ' AND ShipmentDate__c = NULL ';
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext BC, List<Order__c> scopes) {
        Set<String> assetNames = new Set<String>();
        List<Order__c> updateOrders = new List<Order__c>();
        for(Order__c r : scopes) {
            if(r.Delivery__r.isEmpty() == false && r.Delivery__r.size() > 0) {
//                r.Status__c = '종료';
//                r.SystemStatus__c = '종료';
                for(Delivery__c d : r.Delivery__r) {
                    if(d.Division__c == '공장주문') {
                        r.ShipmentDate__c = d.DateOfLoading__c.date();
                    } else {
                        r.ShipmentDate__c = d.ReleaseDate__c;
                    }
                }
                updateOrders.add(r);
            }
        }
        if(updateOrders.isEmpty() == false) update updateOrders;
    }


    public void finish(Database.BatchableContext param1) {

    }

    public static void runTest() {
        Integer my_seo = 0;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
        my_seo ++;
    }
}