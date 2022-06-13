/****************************************************************************************
  * @filename      : NoticeBoardPartnerShareController
  * @projectname   :
  * @author        : jy.kim
  * @date          : 2020-06-05
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : NoticeBoardPartnerShareController_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-05         jy.kim          Create
****************************************************************************************/

public with sharing class NoticeBoardPartnerShareController {
    /**
    * wrapper class for InitData (영엽소 리스트)
    */
    public class InitData extends I2ComClass.InitData {
        // 전체 영업소 리스트
        @AuraEnabled public List<Account> businessOfficeList {
            get{
                if(this.businessOfficeList == null) {
                    this.businessOfficeList = [SELECT Id, Name,ERPCode__c FROM Account WHERE CustomerType__c = '영업소' AND ERPCode__c NOT IN (NULL,'100000') order by Name];
                }
                return this.businessOfficeList;
            }
            set;
        }
    }

    /**
     * init method
     *
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static I2ComClass.InitData init() {
        InitData initData = new InitData();
        return initData;
    }

    /**
     * 공개 범위 데이터 조회
     *
     * @param recordId       레코드 ID
     * @param sObjectName    Object API
     *
     * @return ResData
     */
    @AuraEnabled
    public static ResData getShareSettingItems(String recordId, String sObjectName) {
        ResData resData = new ResData();
        String whereCon = (sObjectName == 'NoticeBoard__c' ? 'NoticeBoard__c' : 'Campaign__c');
        String query =  'SELECT Id,DealerApex__c,BusinessOfficeApex__c,Account__r.Name,Account__c,Account__r.BusinessOffice__r.Name,CreatedDate,Campaign__c from ShareSetting__c where ' + whereCon +'= :recordId order by Account__r.BusinessOffice__r.Name,Account__r.Name';

        List<ShareSetting__c> ShareSetting_List = Database.query(query);
        for(ShareSetting__c shareSetting_temp:ShareSetting_List){
            shareSetting_temp.DealerApex__c = shareSetting_temp.Account__r.Name;
            shareSetting_temp.BusinessOfficeApex__c = shareSetting_temp.Account__r.BusinessOffice__r.Name;
        }
        resData.ShareSetting_List = ShareSetting_List;
        return resData;
    }

    /**
     * 공개 범위 데이터 조회
     *
     * @param bId        영업소(지역) Record Id
     * @param resData    공개 범위 데이터 Wrapper
     *
     * @return List<SearchData>
     */
    @AuraEnabled
    public static List<SearchData> getSearch(String bId, ResData resData) {
        List<SearchData> searchDataList = new List<SearchData>();
        SearchData searchData = null;

        Set<String> selectDealerId = new Set<String>();
        for (ShareSetting__c resData_Temp:resData.ShareSetting_List){
            selectDealerId.add(resData_Temp.Account__c);
        }

        for (Account acc : [select Id, Name,ERPCode__c,BusinessOffice__c,BusinessOffice__r.Name from Account where CustomerType__c = '대리점' AND IsDelete__c = false AND ERPCode__c != NULL AND BusinessOffice__r.CustomerType__c = '영업소' AND BusinessOffice__c = :bId order by Name]){
            searchData = new searchData();
            searchData.dealerList = acc;
            if(selectDealerId.contains(acc.Id)) searchData.dealerCheck = true;
            searchDataList.add(searchData);
        }
        return searchDataList;
    }

    /**
     * 체크된 내역에 따른, 공개 범위 데이터 Wrapper 추가/제거
     *
     * @param resData     공개 범위 데이터 Wrapper
     * @param searchData  영업소(지역) 기준, 검색된 대리점 Wrapper
     * @param AllCheck    전체 체크, 전체 체크해제 여부
     *
     * @return ResData
     */
    @AuraEnabled
    public static ResData getAllCheckShareSettingItems(ResData resData,List<SearchData> searchData, boolean AllCheck) {

        Map<String,ShareSetting__c> shareSetting_Map = new Map<String,ShareSetting__c>();
        for(ShareSetting__c shareSetting_temp:resData.ShareSetting_List){
            shareSetting_Map.put(shareSetting_temp.Account__c,shareSetting_temp);
        }

        ShareSetting__c shareSetting;
        if(AllCheck){
            for(searchData searchData_temp:searchData){
                if(!shareSetting_Map.containsKey(searchData_temp.dealerList.Id)){
                    shareSetting = new ShareSetting__c();
                    shareSetting.DealerApex__c = searchData_temp.dealerList.Name;
                    shareSetting.BusinessOfficeApex__c = searchData_temp.dealerList.BusinessOffice__r.Name;
                    shareSetting.Account__c = searchData_temp.dealerList.Id;
                    shareSetting_Map.put(searchData_temp.dealerList.Id,shareSetting);
                }
            }
        }else{
            for(searchData searchData_temp:searchData){
                if(shareSetting_Map.containsKey(searchData_temp.dealerList.Id)) shareSetting_Map.remove(searchData_temp.dealerList.Id);
            }
        }

        resData.ShareSetting_List = shareSetting_Map.values();
        return resData;
    }

    /**
     * 공개 범위 저장
     *
     * @param resData     공개 범위 데이터 Wrapper
     * @param sObjectName Object API
     * @param recordId    레코드 ID
     *
     */
    @AuraEnabled
    public static void doSave(ResData resData, String sObjectName, String recordId) {
        String whereCon = (sObjectName == 'NoticeBoard__c' ? 'NoticeBoard__c' : 'Campaign__c');
        String query =  'SELECT Id from ShareSetting__c where ' + whereCon +'= :recordId';
        List<String> accountIdSet = new List<String>();
        List<ShareSetting__c> ShareSetting_List = Database.query(query);
        if(ShareSetting_List.size() > 0) delete ShareSetting_List;

        for(ShareSetting__c shareSetting_temp:resData.ShareSetting_List){
            accountIdSet.add(shareSetting_temp.Account__c);
            shareSetting_temp.Id = null;
            if(sObjectName == 'NoticeBoard__c'){
                shareSetting_temp.NoticeBoard__c = recordId;
            }else if(sObjectName == 'Campaign'){
                shareSetting_temp.Campaign__c = recordId;
            }
        }

        getRecordShare(recordId,sObjectName,accountIdSet,'');
        if(resData.ShareSetting_List.size() > 0){
            List<ShareSetting__c> ShareSetting_SList = resData.ShareSetting_List;
            insert ShareSetting_SList;
        }
    }

    /**
     * 즉시 삭제
     *
     * @param recordId    레코드 ID
     * @param shareId     공개 범위 레코드 ID
     * @param sObjectName Object API
     *
     */
    @AuraEnabled
    public static void getShareSettingDelete(String recordId, String shareId, String sObjectName) {
        List<String> accountIdSet = new List<String>();
        ShareSetting__c ShareSetting = [SELECT Id,Account__c from ShareSetting__c where id = :shareId];
        accountIdSet.add(ShareSetting.Account__c);

        getRecordShare(recordId,sObjectName,accountIdSet,'D');
        delete ShareSetting;
    }

    /**
     * 공유 설정
     *
     * @param recordId    레코드 ID
     * @param sObjectName Object API
     * @param accountIdSet 대상 대리점 Account ID
     * @param type 삭제 전용 Flag
     */
    @AuraEnabled
    public static void getRecordShare(String recordId, String sObjectName,List<String> accountIdSet,String type) {
        Set<String> userRoleSet = new Set<String>();
        Set<String> groupSet = new Set<String>();

        for(UserRole userRole_temp:[SELECT PortalAccountId,DeveloperName FROM UserRole WHERE PortalAccountId = :accountIdSet]){
            userRoleSet.add(userRole_temp.DeveloperName);
        }
        for(Group group_temp:[SELECT Id,DeveloperName FROM Group WHERE DeveloperName = :userRoleSet and Type = 'RoleAndSubordinates']){
            groupSet.add(group_temp.Id);
        }

        String deleteQuery = 'SELECT Id from '+(sObjectName == 'NoticeBoard__c' ? 'NoticeBoard__Share where ParentId =:recordId':'CampaignShare where CampaignId =:recordId')+ ' and RowCause = \'Manual\'';
        deleteQuery += (type == 'D' ?' and UserOrGroupId = :groupSet':'');
        List<sObject> del_ShareList = Database.query(deleteQuery);
        if(del_ShareList.size() > 0) delete del_ShareList;

        if(type != 'D'){
            List<sObject> shareSave_List = new List<sObject>();
            NoticeBoard__Share ns;
            CampaignShare cs;
            for(String shareGroupId:groupSet){
                if(sObjectName == 'NoticeBoard__c'){
                    ns = new NoticeBoard__Share();
                    ns.ParentId = recordId;
                    ns.AccessLevel = 'Read';
                    ns.RowCause = 'Manual';
                    ns.UserOrGroupId = shareGroupId;
                    shareSave_List.add(ns);
                }else if(sObjectName == 'Campaign'){
                    cs = new CampaignShare();
                    cs.CampaignId = recordId;
                    cs.CampaignAccessLevel = 'Read';
                    cs.RowCause = 'Manual';
                    cs.UserOrGroupId = shareGroupId;
                    shareSave_List.add(cs);
                }
            }
            if(shareSave_List.size() > 0) insert shareSave_List;
        }
    }

    /**
     * SearchData Wrapper Data Class
     * 영업소(지역) 기준, 검색된 대리점 리스트
    */
    public class SearchData {
        @AuraEnabled public Account dealerList {get;set;}
        @AuraEnabled public Boolean dealerCheck {get;set;}
    }

    /**
     * ResData Wrapper Data Class
     * 공개 범위 리스트
    */
    public class ResData {
        @AuraEnabled public List<ShareSetting__c> ShareSetting_List {get;set;}
    }
}