/****************************************************************************************
  * @filename      : LsMSalesContractAmtQa
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-07-16 오전 8:13
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesContractAmtQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-16 오전 8:13     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class LsMSalesContractAmtQa {

    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public String                  tempYear     {get;set;}
        @AuraEnabled public String                  tempMonth    {get;set;}
        @AuraEnabled public String                  tempDay      {get;set;}
        @AuraEnabled public List<I2ComClass.Option> yearList     {
            get {
                if(this.yearList == null) {
                    this.yearList = new List<I2ComClass.Option>();

                    for(Integer i = System.today().year() ; i >= 1980  ; i--) {
                        yearList.add(new I2ComClass.Option(String.valueOf(i) , String.valueOf(i)));
                    }
                }

                return this.yearList;
            }
            private set;
        }
    }

    /**
     * @description init method
     *
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static I2ComClass.InitData init(Contract__c contract, String amtType) {
        InitData initData = new InitData();
        Date tempDate;

        switch on amtType{
            when '계약금' {
                if(contract.ContractAmtCollectDueDate__c != null)   tempDate = contract.ContractAmtCollectDueDate__c;
            }
            when '융자금' {
                if(contract.LoanApplyDate__c != null)               tempDate = contract.LoanApplyDate__c;
            }
            when '보조금' {
                if(contract.SubsidyCollectDueDate__c != null)       tempDate = contract.SubsidyCollectDueDate__c;
            }
            when '리스' {
                if(contract.LeaseApplyDate__c != null)              tempDate = contract.LeaseApplyDate__c;
            }
            when '자부담' {
                if(contract.SelfPayCollectDueDate__c != null)       tempDate = contract.SelfPayCollectDueDate__c;
            }
            when else {}
        }

        if(tempDate != null) {
            initData.tempYear = String.valueOf(tempDate.year());
            initData.tempMonth = String.valueOf(tempDate.month());
            initData.tempDay = String.valueOf(tempDate.day());

        }

        return initData;
    }

    @AuraEnabled
    public static Contract__c setContractDate(Contract__c contract, String tempDate, String amtType) {
        Date resultDate;

        System.debug('@@@@@@@@@@@@@ tempDate : ' + tempDate);

        if(String.isNotEmpty(tempDate)) {
            LsMSalesQCService.checkValidDate(tempDate);

            resultDate = Date.valueOf(tempDate);

            if(notValidForDate(resultDate)) {
                throw new AuraHandledException('오늘 날짜 이후의 날짜를 선택해 주세요.');
            }

            switch on amtType {
                when '계약금' {
                    contract.ContractAmtCollectDueDate__c = resultDate;
                }
                when '융자금' {
                    contract.LoanApplyDate__c = resultDate;
                }
                when '보조금' {
                    contract.SubsidyCollectDueDate__c = resultDate;
                }
                when '리스' {
                    contract.LeaseApplyDate__c = resultDate;
                }
                when '자부담' {
                    contract.SelfPayCollectDueDate__c = resultDate;
                }
            }
        }
        else {
            switch on amtType {
                when '계약금' {
                    contract.ContractAmtCollectDueDate__c = null;
                }
                when '융자금' {
                    contract.LoanApplyDate__c = null;
                }
                when '보조금' {
                    contract.SubsidyCollectDueDate__c = null;
                }
                when '리스' {
                    contract.LeaseApplyDate__c = null;
                }
                when '자부담' {
                    contract.SelfPayCollectDueDate__c = null;
                }
            }
        }

        return contract;
    }

    /**
     * @param targetDate : Date
     *
     * @return Boolean
     */
    private static Boolean notValidForDate(Date targetDate) {
        return (targetDate < System.today()) ? true : false;
    }
}