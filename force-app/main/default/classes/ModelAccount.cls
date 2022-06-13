/****************************************************************************************
  * @filename      : ModelAccount
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-05-08
  * @group         : 
  * @group-content : 
  * @description   : 업무단에서 필요시 wrapper하여 Model Data 구성
  *                : 업무별로 동일한 로직처리 방지. front-end 로직구성 단순화.
  * @tester        : ModelAccount_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-08         i2max          Create
****************************************************************************************/
public with sharing class ModelAccount {

    /*
     * ================================================================
     * User 정보 Properties 구성
     * ================================================================
     */
    @AuraEnabled
    public Account account {get;set;}

    // Person Account 여부
    @AuraEnabled public Boolean isPersonAccount {
        get {
            return this.account.RecordType.DeveloperName == 'PersonAccount';
        }
        set;
    }
    // Business Account(영업소, 대리점, 관납/농협) 여부
    @AuraEnabled public Boolean isBusinessAccount {
        get {
            return !this.isPersonAccount;
        }
        set;
    }
    // 영업소 여부(CustomerType__c 기준)
    @AuraEnabled public Boolean isBusinessOffice {
        get {
            return this.account.CustomerType__c != null ? (this.account.CustomerType__c == '영업소') : false;
        }
        set;
    }
    // 대리점 여부(CustomerType__c 기준)
    @AuraEnabled public Boolean isAgency {
        get {
            return this.account.CustomerType__c != null ? (this.account.CustomerType__c == '대리점') : false;
        }
        set;
    }
    // 관납 여부(CustomerType__c 기준)
    @AuraEnabled public Boolean isGoverment {
        get {
            return this.account.CustomerType__c != null ? (this.account.CustomerType__c == '관납') : false;
        }
        set;
    }
    // 농협 여부(CustomerType__c 기준)
    @AuraEnabled public Boolean isNH {
        get {
            return this.account.CustomerType__c != null ? (this.account.CustomerType__c == '농협') : false;
        }
        set;
    }
    // 개인고객 여부(CustomerType__c 기준)
    @AuraEnabled public Boolean isPerson {
        get {
            return this.account.CustomerType__c != null ? (this.account.CustomerType__c == '개인고객') : false;
        }
        set;
    }

    //============================================================================
    // 필요한 field 속성 get, set
    //============================================================================
    @AuraEnabled public String name {
        get {
            return this.account.Name;
        }
        set;
    }

    // PersonAccount의 경우, 3개의 필드는 필수로 selectClause에 추가 해야 함.
    @AuraEnabled public String email {
        get {
            return this.isPersonAccount ? this.account.PersonEmail : this.account.Email__c;
        }
        set;
    }

    @AuraEnabled public String personContactId {
        get {
            return this.isPersonAccount ? this.account.PersonContactId : null;
        }
        set;
    }

    @AuraEnabled public String phone {
        get {
            return this.isPersonAccount ? this.account.PersonMobilePhone : this.account.Phone;
        }
        set;
    }


    public ModelAccount(Account account) {
        this.account = account;
    }

    public enum ACCOUNT_RECORD_TYPE {
        PERSON, BUSINESS, CORPORATION, PERSONANDCORPORATION
    }

    public enum ACCOUNT_CUSTOMER_TYPE {
        BUSINESSOFFICE, AGENCY, GOVERMENT, NH, PERSON
    }

    /**
     * Account의 기본 필수 필드를 구함
     * 위 Wrapper Class에 비교되는 항목 기준
     *
     * @return String
     */
    public static String getAccountBaseQuery() {
        String query = '';
        //============================================================================
        // Account의 기본 필드
        //============================================================================
        query += 'SELECT Id, Name, ERPCode__c, CustomerType__c, CustomerStatus__c, BusinessOfficeName__c, Email__c, Phone, ' + '\n';
        //============================================================================
        // Person Account의 기본 정보 필드
        //============================================================================
        query += 'PersonMobilePhone, PersonEmail, PersonContactId, ' + '\n';
        return query;
    }

    /**
     * RecordType 기준의 Account Wrapper List
     *
     * @param accountRecordType     recordType
     * @param selectClause          append select fields 구문
     * @param filterClause          append filter 구문
     * @param orderClause           append order by 구문
     *
     * @return List<ModelAccount>
     */
    public static List<ModelAccount>
    getAccounts(ModelAccount.ACCOUNT_RECORD_TYPE accountRecordType, final String selectClause, final String filterClause, final String orderClause) {

        String query = ModelAccount.getAccountBaseQuery();
        query += String.isBlank(selectClause) ? '' : selectClause + '\n';
        query += '      RecordTypeId, RecordType.Name, RecordType.DeveloperName' + '\n';
        query += 'FROM Account' + '\n';
        query += 'WHERE IsDeleted = FALSE' + '\n';

        switch on accountRecordType {
            when PERSON {
                query += 'AND RecordType.DeveloperName = \'PersonAccount\'' + '\n';
            }
            when CORPORATION {
                query += 'AND RecordType.DeveloperName = \'CorporationAccount\'' + '\n';
            }
            when BUSINESS {
                query += 'AND RecordType.DeveloperName != \'PersonAccount\'' + '\n';
            }
            when PERSONANDCORPORATION {
                query += 'AND RecordType.DeveloperName IN (\'PersonAccount\', \'CorporationAccount\') ' + '\n';
            }
        }

        query += String.isBlank(filterClause) ? '' : filterClause + '\n';
        query += String.isBlank(orderClause)  ? '' : orderClause  + '\n';

        System.debug(System.LoggingLevel.INFO, 'query :' + query);

        List<ModelAccount> modelAccounts = new List<ModelAccount>();

        return ModelAccount.makeModelAccounts((List<Account>)Database.query(query));
    }

    /**
     * CustomerType 기준의 Account Wrapper List
     *
     * @param accountCustomerType   CustomerType
     * @param selectClause          append select fields 구문
     * @param filterClause          append filter 구문
     * @param orderClause           append order by 구문
     *
     * @return List<ModelAccount>
     */
    public static List<ModelAccount> getAccounts(ModelAccount.ACCOUNT_CUSTOMER_TYPE accountCustomerType, final String selectClause, final String filterClause, final String orderClause) {

        String query = ModelAccount.getAccountBaseQuery();
        query += String.isBlank(selectClause) ? '' : selectClause + '\n';
        query += '      RecordTypeId, RecordType.Name, RecordType.DeveloperName' + '\n';
        query += 'FROM Account' + '\n';
        query += 'WHERE IsDeleted = FALSE' + '\n';

        switch on accountCustomerType {
            when BUSINESSOFFICE {
                query += 'AND CustomerType__c = \'영업소\'' + '\n';
            }
            when AGENCY {
                query += 'AND CustomerType__c = \'대리점\'' + '\n';
            }
            when GOVERMENT {
                query += 'AND CustomerType__c = \'관납\'' + '\n';
            }
            when NH {
                query += 'AND CustomerType__c = \'농협\'' + '\n';
            }
            when PERSON {
                query += 'AND CustomerType__c = \'개인고객\'' + '\n';
            }
        }

        query += String.isBlank(filterClause) ? '' : filterClause + '\n';
        query += String.isBlank(orderClause)  ? '' : orderClause  + '\n';

        System.debug(System.LoggingLevel.INFO, 'query :' + query);

        return ModelAccount.makeModelAccounts((List<Account>)Database.query(query));
    }

    /**
     * ModelAccount List 구함
     *
     * @param accounts account list
     *
     * @return List<ModelAccount>
     */
    public static List<ModelAccount> makeModelAccounts(List<Account> accounts) {
        List<ModelAccount> modelAccounts = new List<ModelAccount>();
        for(Account account : accounts) {
            modelAccounts.add(new ModelAccount(account));
        }
        return modelAccounts;
    }

}