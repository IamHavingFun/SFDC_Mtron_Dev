/****************************************************************************************
  * @filename      : LsMSalesPDIVO
  * @projectname   :
  * @author        : i2max.seo
  * @date          : 2020-06-05
  * @group         :
  * @group-content :
  * @description   : [모바일] PDI VO
  * @tester        : LsMSalesPDIVO_ts
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-05         i2max          Create
****************************************************************************************/
public with sharing class LsMSalesPDIVO implements LsMSalesStepVO {
	/*
     * ================================================================
     * 이 하위는 업무에 맞게 구현함.
     * 기본 생성자 외 별도 생성자 구현 불가.
     * 초기화 로직은 업무단 시작의 init 함수에서 할것 : LsMSalesCustomerConsult Class의 init
     * ================================================================
     */
	@AuraEnabled public BizData bizData {get;set;}

	public class BizData {
		// PDI 생성 여부
		@AuraEnabled public Boolean isPDI {get;set;}
		// 보기 모드 여부
		@AuraEnabled public Boolean isViewMode {get;set;}
		// Asset 정보
		@AuraEnabled public Asset asset {get;set;}
		// Asset Price 정보
		@AuraEnabled public AssetPrice__c assetPrice {get;set;}
		// Contract 대상 정보
		@AuraEnabled public List<Contract__c> targetContracts {get;set;}
		// Contract 정보
		@AuraEnabled public Contract__c contract {get;set;}
		// Contract Line Item 정보
		@AuraEnabled public ContractLineItem__c contractItem {get;set;}
		// PDI 정보
		@AuraEnabled public PDI__c pdi 					{get;set;}
		// PDI 정보
		@AuraEnabled public AttachedContentDocument dealerSign 					{get;set;}
		// PDI 정보
		@AuraEnabled public AttachedContentDocument customerSign    			{get;set;}
		// File 정보
		@AuraEnabled public String dealerSignPng 		{get;set;}
		@AuraEnabled public String customerSignPng 		{get;set;}
		@AuraEnabled public String pdfContentVersionId 		{get;set;}
		// Asset 메시지
		@AuraEnabled public String assetMessage 		{get;set;}
		// 로그인사용자와 자산의 동일 대리점여부
		@AuraEnabled public Boolean isSameDealer 		{get;set;}
	}
}