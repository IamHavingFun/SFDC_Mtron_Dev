/****************************************************************************************
  * @filename      : PromotionController
  * @projectname   :
  * @author        : jy.kim
  * @date          : 2020-06-24
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : PromotionController_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-24         jy.kim          Create
****************************************************************************************/

public without sharing class PromotionController {
    public String campaignId {get;set;}
    public Campaign targetCampaign{get;set;}
    public String infoName {get;set;} // 고객명
    public String infoTel {get;set;} // 전화번호
    public String infoTel1 {get;set;} // 전화번호1
    public String infoTel2 {get;set;} // 전화번호2
    public String infoTel3 {get;set;} // 전화번호3
    public boolean infoCUPI_T {get;set;} // 개인정보수집동의(True)
    public boolean infoReceiveSM_T {get;set;} // 개인정보활용동의(True)
    public boolean infoCUPIThirdParty_T {get;set;} // 제3자제공동의(True)
    public List<DealerArea__c> dealerAreas {get;set;} // 대리점관리지역
    public List<SelectOption>  soState {get;set;} // 도 선택목록
    public List<SelectOption>  soArea {get;set;} // 시군
    public List<SelectOption>  soDealer	{get;set;} // 대리점
    public List<SelectOption>  dateRanage	{get;set;} // 시승 신청일자
    public List<SelectOption>  timeRanage	{get;set;} // 시승 신청시간
    public String soStateV {get;set;}
    public String soAreaV {get;set;}
    public String soDealerV {get;set;}
    public String soDealerAddressV {get;set;}
    public String soRequestDate {get;set;}
    public String soRequestTime {get;set;}
    public String nullString = '선택';
    public boolean valid {get;set;}
    public boolean imagevalid {get;set;}
    public Date BaseDate {get;set;}
    public boolean Savevalid {get;set;}

    /**
     * init method(생성자)
     *
     */
    public PromotionController(){
        campaignId = ApexPages.currentPage().getParameters().get('campaignId');
        this.soState = new List<SelectOption>();
        this.soArea = new List<SelectOption>();
        this.soDealer = new List<SelectOption>();
        valid = false;
        imagevalid = false;
        Savevalid = false;
        BaseDate = Date.today();
        promotionSearch();
    }

    /**
     * 프로모션 검색(공개범위, 대리점관리지역)
     *
     */
    public void promotionSearch(){
        Set<String> dearler_Set = new Set<String>();
        List<Campaign> targetCampaignList = [select id,Name,ProductId__c,PublicYn__c,StartDate, EndDate, TestDriveStartTime__c, recordtype.developerName,IsActive,TestDriveDueDate__c,Status,(select id,Account__c,Account__r.Name from Campaign__r),(SELECT Id, ContentDocumentId, Title FROM AttachedContentDocuments)
        from Campaign where id = :campaignId];

        if(targetCampaignList.size() == 1){
            targetCampaign = targetCampaignList[0];

            // 시승 Valid 체크
            if(targetCampaign.recordtype.developerName == 'TestDrive' && (targetCampaign.IsActive == false || targetCampaign.TestDriveDueDate__c < BaseDate || targetCampaign.Status == '종료')){
                valid = false;
                // 프로모션 Valid 체크
            }else if(targetCampaign.recordtype.developerName == 'Promotion' && (targetCampaign.IsActive == false || targetCampaign.EndDate < BaseDate || targetCampaign.Status == '프로모션 완료')) {
                valid = false;
            }else{
                valid = true;
            }

            // 유효 체크
            if(valid){
                if(targetCampaign.PublicYn__c){
                    dealerAreas = [SELECT id,State__c,Area__c,Dealer__c,Dealer__r.Name,DealerAddress__c from DealerArea__c];
                }else{
                    for(ShareSetting__c ss_temp:targetCampaign.Campaign__r){
                        dearler_Set.add(ss_temp.Account__c);
                    }
                    dealerAreas = [SELECT id,State__c,Area__c,Dealer__c,Dealer__r.Name,DealerAddress__c from DealerArea__c where Dealer__c = :dearler_Set];
                }

                Set<String> state_Set = new Set<String>();
                for(DealerArea__c da_tetmp:dealerAreas){
                    state_Set.add(da_tetmp.State__c);
                }

                soState.add(new SelectOption('', nullString));
                for(String s : state_Set){
                    soState.add(new SelectOption(s, s));
                }
                soArea.add(new SelectOption('', nullString));
                soDealer.add(new SelectOption('', nullString));

                // 캠폐인 기간 만큰 옵션을 만들자.
                dateRanage = new List<SelectOption>();
                dateRanage.add(new SelectOption('', nullString));
                Integer i=0;

                while (true) {
                    if(targetCampaign.StartDate.addDays(i) > targetCampaign.EndDate) {
                        break;
                    }
                    dateRanage.add(new SelectOption(targetCampaign.StartDate.addDays(i).format(), targetCampaign.StartDate.addDays(i).format()));
                    i++;
                }

                // 시간 설정
                if(targetCampaign.recordType.developerName == 'TestDrive') {
                    Date startDate = Date.today();
                    String tmpTime = targetCampaign.TestDriveStartTime__c == null ? '09:00' : targetCampaign.TestDriveStartTime__c;
                    List<String> tmpTimes = tmpTime.split(':');
                    Time startTime = Time.newInstance(Integer.valueOf(tmpTimes[0]), Integer.valueOf(tmpTimes[1]), 0, 0);
                    Time endTime = Time.newInstance(18, 0, 0, 0);
                    Datetime baseDate = Datetime.newInstance(startDate, startTime);
                    Datetime checkDate = Datetime.newInstance(startDate, endTime);

                    timeRanage = new List<SelectOption>();
                    timeRanage.add(new SelectOption('', nullString));
                    while (true) {
                        if (baseDate == checkDate) {
                            break;
                        }
                        timeRanage.add(new SelectOption(baseDate.format('HH:mm'), baseDate.format('HH:mm')));
                        baseDate = baseDate.addMinutes(30);
                    }
                }
            }
        }else{
            targetCampaign = new Campaign();
        }

    }

    /**
     * 도 변경 로직
     *
     */
    public void doChangeState(){
        soArea.clear();
        soAreaV = '';
        soDealer.clear();
        soDealerV = '';
        soDealerAddressV = '';

        Set<String> area_Set = new Set<String>();
        for(DealerArea__c da_tetmp:dealerAreas){
            if(soStateV == da_tetmp.State__c){
                area_Set.add(da_tetmp.Area__c);
            }
        }

        soArea.add(new SelectOption('', nullString));
        for(String s : area_Set){
            soArea.add(new SelectOption(s, s));
        }

        soDealer.add(new SelectOption('', nullString));
    }

    /**
     * 시 변경 로직
     *
     */
    public void doChangeArea(){
        soDealer.clear();
        soDealerV = '';
        soDealerAddressV = '';

        soDealer.add(new SelectOption('', nullString));
        for(DealerArea__c da_tetmp:dealerAreas){
            if(soAreaV == da_tetmp.Area__c){
                soDealer.add(new SelectOption(da_tetmp.Dealer__c, da_tetmp.Dealer__r.Name));
            }
        }
    }

    /**
     * 대리점 변경 로직
     *
     */
    public void doChangeDealer(){
        if(soDealerV == nullString){
            soDealerAddressV = '';
        }else{
            for(DealerArea__c da_tetmp:dealerAreas){
                if(soDealerV == da_tetmp.Dealer__c){
                    soDealerAddressV = da_tetmp.DealerAddress__c;
                    break;
                }
            }
        }
    }

    /**
     * Lead 저장
     *
     */
    public void  promotionSave(){
        Id recordTypeId = [SELECT  Id FROM RecordType WHERE SobjectType = 'Lead' AND IsActive = TRUE AND DeveloperName = :targetCampaign.recordtype.developerName].Id;
        Lead lead = new Lead(LastName = infoName,
                MobilePhone     = infoTel1 + '-' + infoTel2 + '-' + infoTel3,
                Dealer__c       = soDealerV,WebApex__c=true,
                RecordtypeId    = recordTypeId,
                CampaignId__c   = campaignId,
                ProductId__c    = targetCampaign.ProductId__c,
                State__c        = soStateV,
                Area__c         = soAreaV
        );
        // 시승일때만 시간 처리.
        if(targetCampaign.recordType.developerName == 'TestDrive') {
            System.debug('soRequestDate : ' + soRequestDate);
            System.debug('soRequestTime : ' + soRequestTime);

            List<String> tmpDates = soRequestDate.replace(' ', '').split('\\.');
            List<String> tmpTimes = soRequestTime.split(':');

            Date myDate = Date.newInstance(Integer.valueOf(tmpDates[0]), Integer.valueOf(tmpDates[1]), Integer.valueOf(tmpDates[2]));
            Time myTime = Time.newInstance(Integer.valueOf(tmpTimes[0]), Integer.valueOf(tmpTimes[1]), 0, 0);
            Datetime TestDriveDate = Datetime.newInstance(myDate, myTime);

            lead.TestDriveDate__c = TestDriveDate;
        }
        insert lead;
        Savevalid = true;

    }
}