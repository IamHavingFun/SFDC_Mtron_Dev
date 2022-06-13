/**
 * Created by MS on 2021-06-06.
 */

public with sharing class LsMSalesWarrantyClaimCreateVO implements LsMSalesStepVO {
/*
	 * ================================================================
	 * 이 하위는 업무에 맞게 구현함.
	 * 기본 생성자 외 별도 생성자 구현 불가.
	 * 초기화 로직은 업무단 시작의 init 함수에서 할것 : LsMSalesCustomerConsult Class의 init
	 * ================================================================
	 */
	@AuraEnabled public BizData bizData {get;set;}

	/*
     * ================================================================
     * 외부 class의 inner class 가 존재할 경우 client -> server에서 serialize 에러가 발생
     * 따라서 LsMSalesProductVO.ProductOptionVO 는 정보성 이므로 별도 분리
     * ================================================================
     */
	public class BizData {
		/*
		 * ================================================================
		 * 선택을 위한 고객 선택 항목
		 * 비즈니스 로직을 위한 선택항목 변수들
		 * ================================================================
		 */

		@AuraEnabled public String assetName {get;set;}
		@AuraEnabled public Asset asset {get;set;}
		@AuraEnabled public Boolean isUnkwonCustomer {get;set;}

	}
}