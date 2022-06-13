/****************************************************************************************
  * @filename      : InterfaceLogDelete_ts
  * @projectname   : LS
  * @author        : ldb3100
  * @date          : 2020-09-03    
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log  
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-09-03              ldb3100         Create
****************************************************************************************/
@isTest
private class InterfaceLogDelete_ts {

	@isTest
	static void testLogSchedule() {
		InterfaceLogDelete_sc.runSchedule();
		InterfaceLogDelete_sc.abortSchedule();
	}

	@isTest
	static void testLogBatch() {
		InterfaceLogDelete_ba ba = new InterfaceLogDelete_ba();
		Database.executeBatch(ba, 1);
	}
}