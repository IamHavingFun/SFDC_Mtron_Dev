/**
 * Created by MS on 2020-07-22.
 */
/****************************************************************************************
  * @filename      : GuideActionDealerStockLevelExceed_ba
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-22
  * @group         :
  * @group-content :
  * @description   : 적정유통 재고 체크 알림. : 영업소별로 한건씩 처리 한다.
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-07-22             Park HE         Create
****************************************************************************************/
public with sharing class GuideActionDealerStockLevelExceed_ba implements Database.Batchable<SObject>, Database.Stateful{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, OwnerId, Owner.Name, ERPCode__c FROM Account ';
        query += 'WHERE CustomerType__c = \'영업소\' ';
        query += 'AND IsDelete__c = false ';
        System.debug('start ::: ' + query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext param1, List<Account> scope) {
        Task newTask;
        List<Task> taskList = new List<Task>();
        Map<String, AggregateResult> assetStockMap = new Map<String, AggregateResult>();
        Account targetAccount = scope[0];       // 대상 영업소를 지정.

        // 영업소 사원 조회
        Set<Id> targetUsers = new Set<Id>();
        for(User r : [SELECT Id, Name
                        FROM User
                        WHERE BusinessOffice__c = :targetAccount.ERPCode__c
                        AND IsActive = TRUE
        ]) {
            targetUsers.add(r.Id);
        }

        // 사무국 직원들..
        for(GroupMember gm : [
                SELECT
                        UserOrGroupId
                FROM GroupMember
                WHERE Group.Type = 'Queue' AND Group.DeveloperName = 'SeRep'
        ]) {
            if(((String)gm.UserOrGroupId).startsWith('00G')) continue;
            targetUsers.add(gm.UserOrGroupId);
        }

        Map<String, Id> activeUserMap = new Map<String, Id>();
        for(User r : [SELECT Id FROM User WHERE IsActive = TRUE]) {
            activeUserMap.put(r.Id, r.Id);
        }
        /**
         * 영업소별 대리점의 대리점 재고 현황
        */
        List<AggregateResult> assetAggregateResults = [
                SELECT Product2.Segment__c segment, COUNT(Id) counting
                FROM Asset
                WHERE InventoryType__c = '대리점재고'
                AND BusinessOffice__c = :targetAccount.Id
                GROUP BY Product2.Segment__c
        ];
        for(AggregateResult ar : assetAggregateResults) {
            assetStockMap.put((String)ar.get('segment'), ar);
        }

        /**
         *  당월 적정 유통 재고 현황 조회 
        */
        List<DealerStockLevel__c> dealerStockLevels = [
                SELECT Id, Segment__c, Qty__c, fm_DealerStockLevel__c, BusinessOffice__c, BusinessOffice__r.OwnerId,  BusinessOffice__r.Name
                FROM DealerStockLevel__c
                WHERE BaseYearMonth__c = THIS_MONTH
                AND BusinessOffice__c = :targetAccount.Id
        ];
        AggregateResult ar;
        String ownerId;
        List<String> overSegments = new List<String>();     // 사무국에게 보낼 때 사용
        Map<String, List<String>> overOwnerNotiMap = new Map<String, List<String>>();
        for (DealerStockLevel__c dsl : dealerStockLevels) {
             if(assetStockMap.containsKey(dsl.Segment__c)) {
                 ar = assetStockMap.get(dsl.Segment__c);
                 // 적정 재고 보단 영업소 전체의 재고가 더 많은 경우 처리.
                 if(dsl.fm_DealerStockLevel__c < Integer.valueOf(ar.get('counting'))) {
                     // 영업소 담당자
                     for(Id uId : targetUsers) {
                         newTask = new Task();
                         newTask.OwnerId = uId;
                         newTask.ActivityDate = System.today();
                         newTask.Type__c = 'Guide';
                         newTask.WhatId = dsl.Id;
                         newTask.Subject = '[적정유통재고 초과] ' + targetAccount.Name;
                         newTask.Description = targetAccount.Name + '의 \'' + dsl.Segment__c + '\'유통 재고가 적정 유통재고를 초과합니다.\n 실판매 독려 혹은 전수배 협의 필요합니다.';
                         newTask.CustomAlert__c = true;
                         if(activeUserMap.containsKey(ownerId)) taskList.add(newTask);
                     }
                 }
                 overSegments.add(dsl.Segment__c);
             }
        }
        // 작업 Insert
        if(taskList.isEmpty() == false) insert taskList;
    }

    public void finish(Database.BatchableContext param1) {
    }

}