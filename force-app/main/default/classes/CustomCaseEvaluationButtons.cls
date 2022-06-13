/****************************************************************************************
 * @filename      : CustomCaseEvaluationButtons
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-05 오전 11:24
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
 0.1     2020-06-05 오전 11:24     SEOKHO LEE          Create
 ****************************************************************************************/

public with sharing class CustomCaseEvaluationButtons {

	/**
	 * 초기화
	 * @param recordId
	 * @return
	 */
	@AuraEnabled
	public static Boolean init(final String recordId){
		CustomizedCase__c newCase = [
				SELECT  Id, Status__c
				FROM CustomizedCase__c
				WHERE Id =:recordId
		];
		Boolean isEvaluationProcess = false;
		// 평가 대기 상태에서만 버튼이 나오게 처리.
		if(newCase.Status__c == '답변 완료 및 평가 대기') isEvaluationProcess = true;
		return isEvaluationProcess;
	}

}