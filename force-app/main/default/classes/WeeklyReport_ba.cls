/****************************************************************************************
  * @filename      : WeeklyReport_ba
  * @projectname   :
  * @author        : jy.kim
  * @date          : 2020-03-17
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : WeeklyReport_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-03-17         jy.kim          Create
****************************************************************************************/

public class WeeklyReport_ba implements Database.Batchable<sObject>, Database.Stateful{
    private Date BaseDate;           // 기준 날짜(일)
    private Date thisWeekStartDate;  // Batch 기준, 이번주 시작일(월)
    private Date thisWeekEndDate;    // Batch 기준, 이번주 종료일(금)
    private Date nextWeekStartDate;  // Batch 기준, 다음주 시작일(월)
    private Date nextWeekEndDate;    // Batch 기준, 다음주 종료일(금)

    /**
     * 기준 날짜(오늘 기준)
     */
    public WeeklyReport_ba() {
        BaseDate = Date.today();
    }

    /**
     * 기준 날짜 설정
     *
     * @param BaseDateString : 기준날짜(YYYYMMDD)
     */
    public WeeklyReport_ba(final String BaseDateString) {
        BaseDate = Dummy_IF_BatchUtil.getIFDate(BaseDateString);
    }

    /**
     * Start
     *
     * @param BC : BatchableContext
     *
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        query += 'Select Id, toLabel(BusinessOffice__c), fm_BusinessOffice__c, Name ';
        query += ' FROM User';
        query += ' WHERE BusinessOffice__c  != null AND IsActive = true and UserType = \'Standard\'';
        return Database.getQueryLocator(query);
    }

    /**
     * 수행 로직 구현
     *
     * @param BC : BatchableContext
     * @param targetScope : Batch Size 실행 리스트
     */
    public void execute(Database.BatchableContext BC, List<User> scope) {
        set<Id> user_Ids = new set<Id>(); // 영업소 사용자 ID
        set<String> WeeklyReport_Ids = new set<String>(); // 주간보고 Set
        Map<String, List<Activity__c>> lastWeeklySalesMap = new Map<String, List<Activity__c>>(); // 영업활동
        Map<String, List<Case>> thisWeeklyCasesMap = new Map<String, List<Case>>(); // 질문&요청
        Map<String, List<Event>> thisWeeklyEventsMap = new Map<String, List<Event>>(); // Event

        thisWeekStartDate = BaseDate.toStartOfWeek().addDays(1);
        thisWeekEndDate = thisWeekStartDate.addDays(4);
        nextWeekStartDate = thisWeekStartDate.addDays(7);
        nextWeekEndDate = thisWeekEndDate.addDays(7);

        for(User user_temp:scope){
            user_Ids.add(user_temp.Id); // 대상 영업소 사용자 ID
            WeeklyReport_Ids.add(String.valueOf(thisWeekEndDate) + '|' + user_temp.Id); // 기존 주간보고
        }

        Map<String, WeeklyReport__c> weeklyReport_Target = new Map<String, WeeklyReport__c>();
        for(WeeklyReport__c weeklyReport_temp : [
                SELECT Id,Name,BusinessOffice__c,ExternalKey__c,OwnerId,BaseDate__c,LastWeekStartDate__c,LastWeekEndDate__c,ThisWeekStartDate__c,ThisWeekEndDate__c,LastWeekSalesActivity__c,LastWeekStatusMarket__c,ThisWeekSalesActivity__c,LastWeekStatusVOC__c
                FROM WeeklyReport__c
                WHERE ExternalKey__c in :WeeklyReport_Ids
        ]){
            weeklyReport_Target.put(weeklyReport_temp.ExternalKey__c,weeklyReport_temp);
        }

        List<Activity__c> sales_List;
        for(Activity__c act_temp : [
                SELECT Id, Account__c,Account__r.Name, Date__c, Comments__c, Division__c, Subject__c,OwnerId
                FROM Activity__c
                WHERE IsWeeklyReport__c = true AND Date__c >= :thisWeekStartDate and Date__c <= :thisWeekEndDate and OwnerId in :user_Ids order by Date__c
        ]){
            if(lastWeeklySalesMap.containsKey(act_temp.OwnerId)) sales_List = lastWeeklySalesMap.get(act_temp.OwnerId);
            else sales_List = new List<Activity__c>();

            sales_List.add(act_temp);
            lastWeeklySalesMap.put(act_temp.OwnerId, sales_List);
        }

        List<Case> case_List;
        /*
        for(Case case_temp : [
                SELECT Id, BusinessOffice__r.Name, CreatedDate, Description, Subject, ProcessingResult__c, Manager__r.LastName, Type, OwnerId,Account.OwnerId
                FROM Case
                WHERE CreatedDate >= :thisWeekStartDate and CreatedDate <= :thisWeekEndDate and Account.OwnerId in :user_Ids order by CreatedDate
        ]){
            if(thisWeeklyCasesMap.containsKey(case_temp.Account.OwnerId)) case_List = thisWeeklyCasesMap.get(case_temp.Account.OwnerId);
            else case_List = new List<Case>();

            case_List.add(case_temp);
            thisWeeklyCasesMap.put(case_temp.Account.OwnerId, case_List);
        }
         */

        List<Event> event_List;
        for(Event event_temp : [
                SELECT Id, whatId, StartDateTime, Description, what.Name, OwnerId, Subject__c
                FROM Event
                WHERE StartDateTime >= :nextWeekStartDate and StartDateTime <= :nextWeekEndDate and OwnerId in :user_Ids order by StartDateTime
        ]){
            if(thisWeeklyEventsMap.containsKey(event_temp.OwnerId)) event_List = thisWeeklyEventsMap.get(event_temp.OwnerId);
            else event_List = new List<Event>();

            event_List.add(event_temp);
            thisWeeklyEventsMap.put(event_temp.OwnerId, event_List);
        }

        // Task 기존 데이터
        set<String> task_tempSet = new set<String>();
        for(Task taskTemp:[SELECT WhatId,OwnerId,ActivityDate,Status from Task where Subject='주간보고' and Status ='Completed' and ActivityDate = :thisWeekEndDate]){
            task_tempSet.add(String.valueOf(taskTemp.ActivityDate)+'|'+taskTemp.OwnerId);
        }

        List<WeeklyReport__c> weeklyReport_List = new List<WeeklyReport__c>();
        WeeklyReport__c weeklyReport;
        for(User user_temp:scope){
            if(weeklyReport_Target.containsKey(String.valueOf(thisWeekEndDate) + '|' + user_temp.Id)){
                weeklyReport = weeklyReport_Target.get(String.valueOf(thisWeekEndDate) + '|' + user_temp.Id);
            }else{
                weeklyReport = new WeeklyReport__c();
            }
            weeklyReport.Name = user_temp.BusinessOffice__c +'_'+'주간업무보고 ('+String.valueOf(thisWeekStartDate)+ ' ~ '+ String.valueOf(thisWeekEndDate) +')_'+user_temp.Name;
            weeklyReport.BusinessOffice__c = user_temp.fm_BusinessOffice__c;
            weeklyReport.ExternalKey__c = String.valueOf(thisWeekEndDate) + '|' + user_temp.Id;
            weeklyReport.OwnerId = user_temp.Id;
            weeklyReport.BaseDate__c = BaseDate;
            weeklyReport.LastWeekStartDate__c = thisWeekStartDate;
            weeklyReport.LastWeekEndDate__c = thisWeekEndDate;
            weeklyReport.ThisWeekStartDate__c = nextWeekStartDate;
            weeklyReport.ThisWeekEndDate__c = nextWeekEndDate;
            weeklyReport.LastWeekSalesActivity__c = lastWeeklySalesMap.containsKey(user_temp.Id) ? createActivity(lastWeeklySalesMap.get(user_temp.Id),new List<String>{'대리점명','날짜','주제','면담내용'},new List<String>{'15%','13%','15%','57%'}, 'N'):nullData();
            weeklyReport.LastWeekStatusMarket__c = lastWeeklySalesMap.containsKey(user_temp.Id) ? createActivity(lastWeeklySalesMap.get(user_temp.Id),new List<String>{'대리점명','경쟁사구분','내용'},new List<String>{'20%','15%','65%'}, 'T'):nullData();
            weeklyReport.ThisWeekSalesActivity__c = thisWeeklyEventsMap.containsKey(user_temp.Id) ? createEvent(thisWeeklyEventsMap.get(user_temp.Id),new List<String>{'대리점명','날짜','주제','면담내용'},new List<String>{'15%','13%','15%','57%'}):nullData();
            //weeklyReport.LastWeekStatusVOC__c = thisWeeklyCasesMap.containsKey(user_temp.Id) ? createCase(thisWeeklyCasesMap.get(user_temp.Id)):nullData();
            weeklyReport_List.add(weeklyReport);
        }

        System.Savepoint sp;
        try {
            sp = Database.setSavepoint();
            if(weeklyReport_List.size() > 0) upsert weeklyReport_List;

            List<Task> task_targetList = new List<Task>();
            Task tempTask;
            for(WeeklyReport__c weekly_temp:weeklyReport_List){
                if(!task_tempSet.contains(weekly_temp.ExternalKey__c)){
                    tempTask = new Task();
                    tempTask.WhatId = weekly_temp.Id;
                    tempTask.Subject = '[주간보고] 작성 알림';
                    tempTask.Description = '금주 주간보고를 작성 해주세요.';
                    tempTask.Status = 'Completed';
                    tempTask.ActivityDate = thisWeekEndDate;
                    tempTask.OwnerId = weekly_temp.OwnerId;
                    tempTask.CustomAlert__c = true;
                    tempTask.Type__c = 'Guide';
                    task_targetList.add(tempTask);
                }
            }
            if(task_targetList.size() > 0) insert task_targetList;

        }catch(Exception e) {
            Database.rollback(sp);
        }
    }

    /**
    * finish
    *
    * @param BC : BatchableContext
    */
    public void finish(Database.BatchableContext BC) {

    }

    /**
     * 활동 테이블 Html
     *
     * @param act_html : Activity 데이터
     * @param label_list : 라벨 표시 데이터
     * @param width_list : Width 크기 데이터
     * @param type : 시장동향입수 여부 판단을 위한 Type
     *
     * @return String
     */
    private static String createActivity(List<Activity__c> act_html, List<String> label_list, List<String> width_list, String type) {
        String html = createHeader(label_list,width_list);
        Integer count = 0;
        for(Activity__c act_temp:act_html){
            if(type == 'T'){
                if(act_temp.Subject__c == '시장동향입수'){
                    html += '<tr>';
                    html += htmlStr('left', act_temp.Account__r.Name, '', '');
                    html += htmlStr('center', act_temp.Division__c, '', '');
                    html += htmlStr('left', (nvlStr(act_temp.Comments__c)).replaceAll('\n','<br/>'), '', '');
                    html += '</tr>';
                    count++;
                }
            }else{
                if(act_temp.Subject__c != '시장동향입수'){
                    html += '<tr>';
                    html += htmlStr('left', act_temp.Account__r.Name, '', '');
                    html += htmlStr('center', String.valueOf(act_temp.Date__c), '', '');
                    html += htmlStr('center', act_temp.Subject__c, '', '');
                    html += htmlStr('left', (nvlStr(act_temp.Comments__c)).replaceAll('\n','<br/>'), '', '');
                    html += '</tr>';
                    count++;
                }
            }
        }
        html += '   </tbody>';
        html += '</table><br>';

        if(count == 0) return nullData();
        return html;
    }
    /**
     * 공통 Header 테이블 Html
     *
     * @param label_list : 라벨 표시 데이터
     * @param width_list : Width 크기 데이터
     *
     * @return String
     */
    private static String createHeader(List<String> label_list, List<String> width_list) {
        String html = '<table style="border-collapse:collapse; border:1px solid black; width:100%; !important;" border="1" class="ql-table-blob">';
        html += '   <tbody>';
        html += '      <tr>';
        for(Integer i=0;i<label_list.size();i++){
            html += '          <th style="font-family:verdana; font-size:12px; text-align:center; background-color:#DCDCDC; border:1px solid black; !important;" width="'+width_list[i]+'">'+label_list[i]+'</th>';
        }
        html += '      </tr>';
        return html;
    }
    /**
     * 이벤트 테이블 Html
     *
     * @param event_html : Event 데이터
     * @param label_list : 라벨 표시 데이터
     * @param width_list : Width 크기 데이터
     *
     * @return String
     */
    private static String createEvent(List<Event> event_html, List<String> label_list, List<String> width_list) {
        String html = createHeader(label_list,width_list);

        for(Event event_temp:event_html){
            html += '<tr>';
            html += htmlStr('left', event_temp.what.Name, '', '');
            html += htmlStr('center', yyyy_mm_dd(event_temp.StartDateTime), '', '');
            html += htmlStr('center', nvlStr(event_temp.Subject__c), '', '');
            html += htmlStr('left', (nvlStr(event_temp.Description)).replaceAll('\n','<br/>'), '', '');
            html += '</tr>';
        }
        html += '   </tbody>';
        html += '</table><br>';

        return html;
    }

    /**
     * 이벤트 테이블 Html
     *
     * @param textAlign : 정렬
     * @param value : 값
     * @param customCss : CSS
     * @param options : width, colspan 등의 옵션
     *
     * @return String
     */
    private static String htmlStr(String textAlign, String value, String customCss, String options){
        String html ='<td style="font-family:verdana; font-size:12px; border:1px solid black; text-align: ' + textAlign +';' + customCss +' !important;"' + options +'>' + value + '</td>';
        return html;
    }
    /**
     * Case 테이블 Html
     *
     * @param case_html : Case 데이터
     *
     * @return String
     */
/*
    private static String createCase(List<Case> case_html) {
        String html = '';
        Integer count = 0;
        for(Case case_temp:case_html){
            if(count != 0) html += '<div style="height:5px;"></div>';
            html += '<table style="border-collapse:collapse; border:1px solid black; width:100%; !important;" border="1" class="ql-table-blob">';
            html += '   <tbody>';
            html += '      <tr>';
            html +=             htmlStr('center', '대리점명', 'background-color:#DCDCDC; font-weight:bold;', 'width="12.5%"');
            html +=             htmlStr('center', nvlStr(case_temp.BusinessOffice__r.Name), '', 'width="12.5%"');
            html +=             htmlStr('center', '날짜', 'background-color:#DCDCDC; font-weight:bold;', 'width="12.5%"');
            html +=             htmlStr('center', nvlStr(yyyy_mm_dd(case_temp.CreatedDate)), '', 'width="12.5%"');
            html +=             htmlStr('center', '접수자', 'background-color:#DCDCDC; font-weight:bold;', 'width="12.5%"');
            html +=             htmlStr('center', nvlStr(case_temp.Manager__r.LastName), '', 'width="12.5%"');
            html +=             htmlStr('center', '유형', 'background-color:#DCDCDC; font-weight:bold;', 'width="12.5%"');
            html +=             htmlStr('center', nvlStr(case_temp.Type), '', 'width="12.5%"');
            html += '      </tr>';
            html += '      <tr>';
            html +=             htmlStr('center', '제목', 'background-color:#DCDCDC; font-weight:bold;', '');
            html +=             htmlStr('left', nvlStr(case_temp.Subject), '', 'colspan="7"');
            html += '      </tr>';
            html += '      <tr>';
            html +=             htmlStr('center', '상세설명', 'background-color:#DCDCDC; font-weight:bold;', '');
            html +=             htmlStr('left', (nvlStr(case_temp.Description)).replaceAll('\n','<br/>'), '', 'colspan="7"');
            html += '      </tr>';
            html += '      <tr>';
            html +=             htmlStr('center', '처리결과', 'background-color:#DCDCDC; font-weight:bold;', '');
            html +=             htmlStr('left', (nvlStr(case_temp.ProcessingResult__c)).replaceAll('\n','<br/>'), '', 'colspan="7"');
            html += '      </tr>';
            html += '   </tbody>';
            html += '</table>';
            count++;
        }
        return html;
    }
*/
    /**
     * 데이터가 없을때, 메시지
     *
     * @return String
     */
    private static String nullData() {
        String html = '';
        html += '<b>' + System.Label.WeeklyReport_NotDataMsg + '</b>';
        return html;
    }

    /**
     * Datetime to YYYY-MM-DD
     *
     * @param d : Datetime
     *
     * @return String
     */
    private static String yyyy_mm_dd(Datetime d) {
        String result = '';
        if (d != null) {
            String sMonth = String.valueof(d.month());
            String sDay = String.valueof(d.day());
            if (sMonth.length() == 1) {
                sMonth = '0' + sMonth;
            }
            if (sDay.length() == 1) {
                sDay = '0' + sDay;
            }
            result = String.valueof(d.year()) + '-' + sMonth + '-' + sDay ;
        }
        return result;
    }

    /**
     * nvlStr
     *
     * @param o : String Null Check
     *
     * @return String
     */
    private static String nvlStr(String o) {
        String tmp = '';
        if (o == null || ''.equals(o) || o == 'null') {
            tmp = '';
        } else {
            tmp = o;
        }
        return tmp;
    }
}