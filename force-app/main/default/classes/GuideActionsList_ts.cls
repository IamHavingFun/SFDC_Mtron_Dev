/****************************************************************************************
  * @filename      : GuideActionsList_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-04-29 오후 1:57
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-04-29 오후 1:57     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class GuideActionsList_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        Task t = new Task();
        t.Type__c = 'Guide';
        t.Status = 'Completed';
        insert t;

        GuideActionsList.TaskData data = new GuideActionsList.TaskData(t);
        GuideActionsList.init();
        System.assertNotEquals(data.Task, null);
        System.assertNotEquals(data.content, null);

        GuideActionsList.getGuideActionList(t.Id,'Home');
        GuideActionsList.getGuideActionList(t.Id,'');

        Task newTask = [
                SELECT IsClosed
                FROM Task
                WHERE Id = :t.Id
        ];
        GuideActionsList.saveCompleted(newTask);
    }
}