/****************************************************************************************
  * @filename      : WeeklyReport_sc
  * @projectname   :
  * @author        : jy.kim
  * @date          : 2020-04-24
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : WeeklyReport_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-24         jy.kim          Create
****************************************************************************************/

public class WeeklyReport_sc implements Schedulable {

    public void execute(SchedulableContext SC) {
        WeeklyReport_ba batch = new WeeklyReport_ba();
        database.executeBatch(batch, 2000);
    }
}