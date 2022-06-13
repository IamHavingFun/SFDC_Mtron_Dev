/**
** @filename     : I2ComCustomNotiService_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-21 오후 4:51
* @group         :
* @group-content :
* @description   :
* @tester        :
* @reference     :
* @copyright     : Copyright © I2max. All Rights Reserved.
* @modification Log
* ===============================================================
* ver     date             author              description
* ===============================================================
  0.1                            Create
 */
@IsTest
private class I2ComCustomNotiService_ts {
	@IsTest
	static void testBehavior() {
		TestDataSalesFactory.init();

		I2ComCustomNotiService.send(new I2ComCustomNotiService.NotiVO(
				TestDataSalesFactory.orderForPerFarCorp.Id,
				'테스트..',
				'테스트..테스트..테스트...',
				new Set<String> {UserInfo.getUserId()}
		));

		I2ComCustomNotiService.sendDeliveryNoticeForLMS(new List<I2ComCustomNotiService.NotiVO>{new I2ComCustomNotiService.NotiVO(
				TestDataSalesFactory.orderForPerFarCorp.Id,
				'테스트..',
				'테스트..테스트..테스트...',
				new Set<String> {'01012345678'}
		)});
	}
}