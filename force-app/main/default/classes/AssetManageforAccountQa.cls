/**
** @filename     : AssetManageforAccountQa
* @projectname   :
* @author        : Choi SeongWon
* @date          : 2020-05-14 오전 09:06
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
0.1     2020-05-14 오전 09:06     Choi SeongWon          Create
0.2     2020-07-08 오전 09:00     SEOKHO LEE             Modify
 */

public with sharing class AssetManageforAccountQa {

    @AuraEnabled
    public static CustomerData init(String recordId) {
        CustomerData customerData = new CustomerData();
        customerData.account = [
                SELECT ID, Name, LastName, Dealer__c, Dealer__r.Name, CustomerStatus__c, SystemStatus__c
                FROM Account
                WHERE Id = :recordId
        ];
        return customerData;
    }

    /**
     * 검색
     *
     * @param reqData
     * @param pageSize
     * @param pageNumber
     *
     * @return
     */
    @AuraEnabled
    public static I2ComClass.ResData getSearch(String reqData, Integer pageSize, Integer pageNumber){

        String whereClause = '';
        Map<String, String> paramMap = I2ComHelper.gfnCheckCondition(reqData);

        //whereClause += 'WHERE ((Brand__c = \'LS\' AND AccountId = '+ ModelUser.getUserData().AccountId +' AND Customer__c = null) OR (Brand__c != \'LS\' AND Customer__c = null))';
        /*
         * ================================================================
         * 검색 조건이 변경 : 2020.07.16
         * 1. 실소유자가 없음
         * 2. 당사 브랜드 + 재고현황(대리점재고, 실판매) + 자산대리점 과 유저대리점 동일
         * 3. 타사 브래드 모두
         * 4. 자산 검색조건(name)
         * ================================================================
         */
/*        whereClause += 'WHERE Customer__c = null' + '\n';
        whereClause += 'AND (' + '\n';
        whereClause += '    (Brand__c = \'LS\' AND InventoryType__c IN (\'대리점재고\', \'실판매\') AND AccountId = \''+ ModelUser.getUserData().AccountId +'\')' + '\n';
        whereClause += '     OR   Brand__c != \'LS\'' + '\n';
        whereClause += ')' + '\n';*/

        if(I2ComHelper.gfnHasCondition(paramMap, 'name')) {
            final String likeIdioms = '\'%' + String.escapeSingleQuotes(paramMap.get('name')) + '%\'';
            whereClause += ' AND Name LIKE ' + likeIdioms + '\n';
        }
        whereClause = I2ComHelper.gfnRefineCondition(whereClause);

        I2ComClass.ResData resData = I2ComHelper.gfnQuery(
                'Name, Brand__c, Product2.Name, InventoryType__c, Dealer__c, Dealer__r.Name, Customer__c, Customer__r.Name, AccountId',
                'Asset',
                whereClause,
                null,
                pageSize,
                pageNumber
        );

        return resData;
    }

    @AuraEnabled
    public static CustomerData save(CustomerData customerData) {
/*
실소유자 = 고객.id
고객 = 고객.ID
기대정보등록일( AssetRegDate__c) = 당일
브랜드가 LS이면 재고유형 = 실판매
브랜드가 LS이면 전수배 관련 필드 지우기
- 전수배주문 : TransferOrder__c = null
- 전수배대상 여부 : IsSendReceiveItem__c = Null
- 전수배대상 지정일 : SendReceiveSpecifiedDate__c = null
- 전수배제외조건 : CondSendReceiveExcept__c = null
- 전수배제외횟수 : NumSendReceiveExcept__c = null
- 전수배제외신청일 : DateSendReceiveExcept__c = null
 */
        //System.Savepoint sp = Database.setSavepoint();

        customerData.asset.Customer__c = customerData.account.Id;
        customerData.asset.AccountId = customerData.account.Id;
        customerData.asset.AssetRegDate__c = System.today();

        if('LS'.equals(customerData.asset.Brand__c)){
            customerData.asset.InventoryType__c = '실판매';
            customerData.asset.TransferOrder__c = null;
            customerData.asset.IsSendReceiveItem__c = false;
            customerData.asset.SendReceiveSpecifiedDate__c = null;
            customerData.asset.CondSendReceiveExcept__c = null;
            customerData.asset.NumSendReceiveExcept__c = null;
            customerData.asset.DateSendReceiveExcept__c = null;

            update customerData.asset;

            customerData.account = new Account(
                Id = customerData.account.Id,
                CustomerStatus__c = '실고객',
                SystemStatus__c = '실고객',
                IsTractorStatus__c = true,
                AssetId__c = customerData.asset.Id
            );

            update customerData.account;

        }
        else {
            customerData.account = new Account(
                Id = customerData.account.Id,
                IsTractorStatus__c = true,
                AssetId__c = customerData.asset.Id
            );

            update customerData.asset;
            update customerData.account;
        }

        //Database.rollback(sp);
        return customerData;
    }

    public class CustomerData {
        @AuraEnabled public Account account { get; set; }
        @AuraEnabled public Asset asset { get; set; }
    }

}