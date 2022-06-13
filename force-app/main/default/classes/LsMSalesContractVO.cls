/****************************************************************************************
  * @filename      : LsMSalesContractVO
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-07-04 오후 3:44
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesContractVO_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-04 오후 3:44     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class LsMSalesContractVO implements LsMSalesStepVO {

    private static Id recordTypeIdForContract = [SELECT Id FROM RecordType WHERE DeveloperName = 'PerFarCorp' AND SobjectType = 'Contract__c'].Id;
    private static Date today = System.today();

    /*
     * ================================================================
     * 이 하위는 업무에 맞게 구현함.
     * 기본 생성자 외 별도 생성자 구현 불가.
     * 초기화 로직은 업무단 시작의 init 함수에서 할것
     * ================================================================
     */
    @AuraEnabled public BizData bizData {get;set;}

    public class BizData {
        @AuraEnabled public Quote__c                    quote       {get;set;}
        @AuraEnabled public List<QuoteLineItem__c>      qliList     {
            get {
                if(this.qliList == null) {
                    this.qliList = this.quote.QuoteLineItems__r;
                }
                return this.qliList;
            }
            private set;
        }
        @AuraEnabled public List<QuoteOtherItem__c>      qoiList     {
            get {
                if(this.qoiList == null) {
                    this.qoiList = this.quote.QuoteOtherItem__r;
                }
                return this.qoiList;
            }
            private set;
        }
        @AuraEnabled public Contract__c                 contract    {
            get {
                if(this.contract ==null) {
                    this.contract = new Contract__c(
                            ContractAmt__c = 0, LoanContractAmt__c =0,
                            SubsidyContractAmt__c = 0, LeaseContractAmt__c =0,
                            SelfPayContractAmt__c = 0, UsedUndertakingAmt__c =0,
                            TotalPrice__c = 0,
                            eFormsignStatus__c = '미요청',
                            RecordTypeId = recordTypeIdForContract
                    );

                }
                return this.contract;
            }
            set;
        }

        @AuraEnabled public String                      tempDetailAddress   {get;set;}
        @AuraEnabled public Boolean                     isCorporationAccount   {get;set;}
    }

    @AuraEnabled public DateData        dateData        {get;set;}
    @AuraEnabled public UnchangedData   unchangedData   {get;set;}

    public class  DateData {
        //==============================================================================
        // 날짜 관련 임시 세팅.
        //==============================================================================

        // 매수자 생년월일 세팅.
        @AuraEnabled public String                      tempYear            {get;set;}
        @AuraEnabled public String                      tempMonth           {get;set;}
        @AuraEnabled public String                      tempDay             {get;set;}
        // 계약 관련 날찌 세팅.
        @AuraEnabled public String                      tempAmtYear         {get;set;}
        @AuraEnabled public String                      tempAmtMonth        {get;set;}
        @AuraEnabled public String                      tempAmtDay          {get;set;}
        // 인도 기일 세팅.
        @AuraEnabled public String                      tempCustomerYear    {get;set;}
        @AuraEnabled public String                      tempCustomerMonth   {get;set;}
        @AuraEnabled public String                      tempCustomerDay     {get;set;}

        @AuraEnabled public List<I2ComClass.Option>     yearAmtList         {
            get {
                if(this.yearAmtList == null) {
                    this.yearAmtList = new List<I2ComClass.Option>();

                    for(Integer i = today.year() ; i <= today.year() + 2 ; i++) {
                        yearAmtList.add(new I2ComClass.Option(String.valueOf(i) , String.valueOf(i)));
                    }
                }
                return this.yearAmtList;
            }
            set;
        }
        @AuraEnabled public List<I2ComClass.Option>     yearList            {
            get {
                if(this.yearList == null) {
                    this.yearList = new List<I2ComClass.Option>();

                    for(Integer i = today.year() ; i >= today.year() - 100 ; i--) {
                        yearList.add(new I2ComClass.Option(String.valueOf(i) , String.valueOf(i)));
                    }
                }
                return this.yearList;
            }
            set;
        }
        @AuraEnabled public List<I2ComClass.Option>     monthList           {
            get {
                if(this.monthList == null) {
                    this.monthList = new List<I2ComClass.Option>();

                    for(Integer i = 1 ; i <= 12 ; i++) {
                        monthList.add(new I2ComClass.Option(String.valueOf(i) , String.valueOf(i)));
                    }
                }
                return this.monthList;
            }
            set;
        }
        @AuraEnabled public List<I2ComClass.Option>     dayList             {
            get {
                if(this.dayList == null) {
                    this.dayList = new List<I2ComClass.Option>();

                    for(Integer i = 1 ; i <= 31 ; i++) {
                        dayList.add(new I2ComClass.Option(String.valueOf(i) , String.valueOf(i)));
                    }
                }
                return this.dayList;
            }
            set;
        }
    }

    public class UnchangedData {
        @AuraEnabled public Contract__c unchangedContract       {get;private set;}
        @AuraEnabled public String      unchangedTempCusYear    {get;private set;}
        @AuraEnabled public String      unchangedTempCusMonth   {get;private set;}
        @AuraEnabled public String      unchangedTempCusDay     {get;private set;}

        public UnchangedData(Contract__c contract, DateData dateData) {
            this.unchangedContract      = contract;
            this.unchangedTempCusYear   = dateData.tempCustomerYear;
            this.unchangedTempCusMonth  = dateData.tempCustomerMonth;
            this.unchangedTempCusDay    = dateData.tempCustomerDay;
        }
    }
}