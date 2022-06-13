/****************************************************************************************
  * @filename      : GuideActionPromotionClose
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-15
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
    0.1     2020-07-15             Park HE         Create
****************************************************************************************/
public with sharing class GuideActionPromotionClose {


    @AuraEnabled
    public static Boolean setPromotionClose (String recordId) {
        System.debug('============ setPromotionClose');
        //Campaign campaign = new Campaign(Id = recordId,Status = '프로모션 완료',EndDate = System.today());
        Campaign campaign = [SELECT Id, Status, EndDate FROM Campaign WHERE Id =: recordId AND IsActive = TRUE];
        campaign.Status = '프로모션 완료';
        //프로모션 조기 종료 시, 종료일을 오늘 날짜로 업데이트
        if(campaign.EndDate >  System.today())
            campaign.EndDate = System.today();
        update campaign;

        Database.executeBatch(new GuideActionPromotionClose_ba(recordId), 500);
        return true;
    }

    @AuraEnabled
    public static Boolean init (String recordId) {
        Campaign campaign = [SELECT Id, Status, EndDate FROM Campaign WHERE Id =: recordId];
        if(campaign.Status == '프로모션 완료')
            return false;
        return true;
    }
}