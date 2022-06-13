/****************************************************************************************
  * @filename      : WeeklyReportHomeController
  * @projectname   :
  * @author        : jy.kim
  * @date          : 2020-03-25
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : WeeklyReportHomeController_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-03-25         jy.kim          Create
****************************************************************************************/

public with sharing class WeeklyReportHomeController {
    /**
     * 주간보고 데이터(이번주/저번주) 조회
     *
     * @return List<WeeklyReportWrapper>
     */
    @AuraEnabled
    public static List<WeeklyReportWrapper> getWeeklyReportList() {
        Date BaseDate = Date.today();
        Date thisWeekStartDate = BaseDate.toStartOfWeek().addDays(1); // 이번주 월요일
        Date lastWeekStartDate = thisWeekStartDate.addDays(-7);       // 저번주 월요일
        List<WeeklyReportWrapper> wrw_list = new List<WeeklyReportWrapper>();
        Map<String, List<WeeklyReport__c>> weeklyReport_Map = new Map<String, List<WeeklyReport__c>>();
        List<WeeklyReport__c> wpc_List;

        for(WeeklyReport__c wrt_temp : [
                SELECT Id, Name, OwnerId,ThisWeekStartDate__c, toLabel(BusinessOffice__c), Owner.Name
                FROM WeeklyReport__c
                WHERE (ThisWeekStartDate__c = THIS_WEEK or ThisWeekStartDate__c = LAST_WEEK) and MyData__c = TRUE order by BusinessOffice__c,Owner.Name
        ]){
            if(weeklyReport_Map.containsKey(wrt_temp.OwnerId)) wpc_List = weeklyReport_Map.get(wrt_temp.OwnerId);
            else wpc_List = new List<WeeklyReport__c>();

            wpc_List.add(wrt_temp);
            weeklyReport_Map.put(wrt_temp.OwnerId, wpc_List);
        }

        for(String ownerId_temp:weeklyReport_Map.keySet()){
            WeeklyReportWrapper wrw = new WeeklyReportWrapper();
            for(WeeklyReport__c wrt_temp : weeklyReport_Map.get(ownerId_temp)){
                if(thisWeekStartDate == wrt_temp.ThisWeekStartDate__c){ // 이번주
                    wrw.ThisWeeklyReport = wrt_temp;
                }else if(lastWeekStartDate == wrt_temp.ThisWeekStartDate__c){ // 저번주
                    wrw.LastWeeklyReport = wrt_temp;
                }
            }
            wrw_list.add(wrw);
        }
        return wrw_list;
    }
    /**
     * WeeklyReport Wrapper Data Class
    */
    public class WeeklyReportWrapper {
        @AuraEnabled public WeeklyReport__c ThisWeeklyReport { get; set; } // 금주 주간보고
        @AuraEnabled public WeeklyReport__c LastWeeklyReport { get; set; } // 전주 주간보고
    }
}