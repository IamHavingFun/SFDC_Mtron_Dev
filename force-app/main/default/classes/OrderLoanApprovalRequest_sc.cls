/**
 * Created by MS on 2021-09-01.
 */

global without sharing class OrderLoanApprovalRequest_sc implements Schedulable {

	global static String targetRecordId;

	global void execute( SchedulableContext sc ){
		System.debug(sc.getTriggerId());

		CronTrigger job =  [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger where Id = :sc.getTriggerId()];
		System.debug('Job Name : ' + job.CronJobDetail.Name);

		String jobName = job.CronJobDetail.Name;
		String recordId = jobName.split('=')[1];
		runApprovalRequest(recordId);
		System.abortJob(sc.getTriggerId());
	}

	global static void runSchedule(String recordId) {
		String jobName = 'OrderLoanApprovalRequest='+recordId;
		Datetime now = Datetime.now().addMinutes(1);
		String cronExp = now.second() + ' ' + now.minute() + ' ' + now.hour() + ' * * ? *';
		System.schedule(jobName, cronExp, new OrderLoanApprovalRequest_sc());
	}

	private void runApprovalRequest(String recordId) {
		Order__c order = [SELECT Id, Name, BusinessOfficeRep__c FROM Order__c WHERE Id = :recordId];

		Approval.ProcessSubmitRequest req1;
		Approval.ProcessResult result;

		req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('승인 요청 드립니다.');
		req1.setObjectId(order.Id);

		req1.setSubmitterId(order.BusinessOfficeRep__c);
		String message;
		try {
			result = Approval.process(req1);
			message =  order.Name + '에 대한 여신승인요청 기안 처리 되었습니다.';
			I2ComCustomNotiService.send(new I2ComCustomNotiService.NotiVO(
					order.Id,
					'[추가여신승인 알림] 주문번호 : ' + order.Name,
					message,
					new Set<String>{
							order.BusinessOfficeRep__c
					}
			));
		} catch (Exception e) {

		}
	}
}