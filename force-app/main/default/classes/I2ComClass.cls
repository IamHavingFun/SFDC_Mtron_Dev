/****************************************************************************************
  * @filename      : I2ComClass
  * @projectname   : LWC_I2MAX
  * @author        : i2max_my.Seo
  * @date          : 2020-03-10 오전 7:28
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : I2ComClass_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-03-10 오전 7:28     i2max_ms             Create
****************************************************************************************/

public with sharing class I2ComClass {
    /**
     * 공통 : 초기화 공통 클래스
     */
    abstract public class InitData {
        @AuraEnabled public Map<String, Object> defaultMap = new Map<String, Object>();
    }

    /**
     * 공통 : Select Option 공통 클래스
     */
    public class Option {
        @AuraEnabled public String label 			{get;set;}
        @AuraEnabled public String value 			{get;set;}
        @AuraEnabled public Boolean selected 		{get;set;}

        public Option(String label, String value){
            this.label = label;
            this.value = value;
            this.selected = false;
        }
    }

    /**
     * 공통 : 리스트 조회 결과 클래스
     * 공통으로 사용되는 결과 클래스이므로 이름이 동일해야한다
     */
    virtual public class ResData {
        @AuraEnabled public Integer 		totalSize 		{get;set;}
        @AuraEnabled public List<SObject> 	recordList 		{get;set;}
        @AuraEnabled public Integer 	    recordSize 	{
            get {
                return this.recordList.size();
            }
            set;
        }

        public ResData(final Integer totalSize, List<SObject> recordList) {
            this.totalSize = totalSize > 2000 ? 2000 : totalSize;
            this.recordList = recordList;
        }
    }
}