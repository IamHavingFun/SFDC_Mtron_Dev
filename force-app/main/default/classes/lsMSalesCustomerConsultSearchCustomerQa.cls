/****************************************************************************************
  * @filename      : LsMSalesCustomerConsultSearchCustomerQa
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-06-29
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesCustomerConsultSearchCustomerQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-29         i2max          Create
****************************************************************************************/
public with sharing class lsMSalesCustomerConsultSearchCustomerQa {

    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public Account account { get; set; }
    }

    @AuraEnabled(Cacheable=true)
    public static InitData init() {
        InitData initData = new InitData();
        return initData;
    }

    /**
     * 검색
     *
     * @param reqData 요청 데이터 JSON Stringify
     *
     * @return List<ModelAccount>
     */
    @AuraEnabled
    public static List<ModelAccount> search(String reqData){

        System.debug(System.LoggingLevel.INFO, reqData);

        Map<String, String> paramMap = I2ComHelper.gfnCheckCondition(reqData);

        //============================================================================
        // 로그인 사용자(대리점)의 개인 고객 리스트 조회
        // Role 관계에 의해 대리점 영업사원 소속 대리점 Account에 종속된 개인고객 Account만 대상건
        //============================================================================
        String filterClause = '';
        String recordTypeDeveloperName = '';
        List<ModelAccount> customers;

        final String likeName = '\'%' + String.escapeSingleQuotes(paramMap.get('name')) + '%\'';

        if(I2ComHelper.gfnHasCondition(paramMap, 'name')) {
            filterClause += ' AND Name LIKE ' + likeName + '\n';
            filterClause += ' AND IsDelete__c = false \n';
        }
        if(I2ComHelper.gfnHasCondition(paramMap, 'accountRecordTypeId')) {
            recordTypeDeveloperName = [
                    SELECT DeveloperName
                    FROM RecordType
                    WHERE SobjectType = 'Account'
                    AND Id = :paramMap.get('accountRecordTypeId')
            ].DeveloperName;
        }

        //============================================================================
        // Account는 ModelAccount를 이용하여 Wrapper 처리함
        //============================================================================
        switch on recordTypeDeveloperName {
            when 'CorporationAccount' {
                customers = ModelAccount.getAccounts(
                        ModelAccount.ACCOUNT_RECORD_TYPE.CORPORATION,
                        'fm_CorporationDuplicateCheck__c, FarmingForm__c, FarmingArea__c, (\n' +
                                   '        SELECT Id, LastName, Phone, MobilePhone, IsPhoneCheck__c \n' +
                                   '        FROM Contacts \n' +
                                   '        WHERE IsRepresentative__c = true \n' +
                                   ')',
                        filterClause,
                        null
                );
            }
            when 'PersonAccount' {
                customers = ModelAccount.getAccounts(
                        ModelAccount.ACCOUNT_RECORD_TYPE.PERSON,
                        'LastName, IsPhoneCheck__pc, CUPIInitialStartDate__pc, fm_PersonDuplicateCheck__c, FarmingForm__c, FarmingArea__c, IsCUPI__pc,  ',
                        filterClause,
                        null
                );
            }
            // 기본이 개인고객, 법인고객 조회
            when else {
                customers = ModelAccount.getAccounts(
                        ModelAccount.ACCOUNT_RECORD_TYPE.PERSONANDCORPORATION,
                        'LastName, IsPhoneCheck__pc, fm_PersonDuplicateCheck__c, fm_CorporationDuplicateCheck__c, FarmingForm__c, FarmingArea__c, Mobile__c, ',
                        filterClause,
                        null
                );
            }
        }

        return customers;
    }
}