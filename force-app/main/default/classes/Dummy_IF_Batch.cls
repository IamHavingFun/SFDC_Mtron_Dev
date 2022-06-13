/****************************************************************************************
  * @filename      : Dummy_IF_Batch
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-17
  * @group         : 
  * @group-content : 
  * @description   : Dummy Interface Batch 공통 abstract Class
  * @tester        : Dummy_IF_Batch_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-17      i2max          Create
****************************************************************************************/
public abstract class Dummy_IF_Batch implements Database.Batchable<SObject>, Database.Stateful {

    /**
     * 실행 일자
     */
    protected Datetime exeDatetime = System.now();
    protected Date exeDate = exeDatetime.date();

    /**
     * bad or dml error Dummy Data Ids
     */
    protected List<Id> errorDummyIds = new List<Id>();

    /**
     * 실행 인터페이스 Id
     */
    protected String interfaceId;

    /**
     * 배치 실행 주기 타입
     */
    public enum DUMMY_BATCH_PERIOD_TYPE {
        DAILY, WEEKLY, MONTHLY, YEARLY
    }

    /**
     * 후행 Delete Batch 정보
     */
    @TestVisible
    protected Dummy_IF_Batch.DeleteInfo deleteInfo;

    /**
     * Delete Batch 정보 Wrapper Class
     */
    public class DeleteInfo {
        public String dummySObject {get;set;}
        public String dummyInterfaceId {get;set;}
        public Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE dummyBatchPeriodType {get;set;}
        public Datetime dummyExeDatetime {get;set;}
        public Datetime dummyDeleteBaseDt {
            get {
                switch on this.dummyBatchPeriodType {
                    when DAILY {
                        // 3주전 데이터
//                        this.dummyDeleteBaseDt = this.dummyExeDatetime.addDays(-21);
                        // Note : 2020-10-19    임시용. 추후에 위에 코드로 변경 후 배포.
                        this.dummyDeleteBaseDt = this.dummyExeDatetime.addDays(-2);
                    }
                    when WEEKLY {
                        this.dummyDeleteBaseDt = this.dummyExeDatetime.addDays(-7);
                    }
                    when MONTHLY {
                        // 3개월 전 데이터
                        this.dummyDeleteBaseDt = this.dummyExeDatetime.addMonths(-3);
                    }
                    when YEARLY {

                    }
                }
                return this.dummyDeleteBaseDt;
            }
            set;
        }
        public String fromBatchClass {get;set;}

        public DeleteInfo(  final String dummySObject,
                            final String dummyInterfaceId,
                            final Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE dummyBatchPeriodType,
                            final Datetime dummyExeDatetime
        ) {
            this.dummySObject = dummySObject;
            this.dummyInterfaceId = dummyInterfaceId;
            this.dummyBatchPeriodType = dummyBatchPeriodType;
            this.dummyExeDatetime = dummyExeDatetime;
        }
    }

    /**
     * Start
     *
     * @param BC : BatchableContext
     *
     * @return Database.QueryLocator
     */
    public abstract Database.QueryLocator start(Database.BatchableContext BC);

    /**
     * execute
     *
     * @param BC : BatchableContext
     * @param targetScope : Batch Size 실행 리스트
     */
    public abstract void execute(Database.BatchableContext BC, List<SObject> targetScope);

    /**
     * finish
     * 로직의 순서 중요[유의]
     *
     * @param BC : BatchableContext
     */
    public virtual void finish(Database.BatchableContext BC) {
        //============================================================================
        // 1. Dummy Data 삭제 배치 수행
        //============================================================================
        if(this.deleteInfo != null) {
            if(!Test.isRunningTest()) {
                // 호출하는 클리스명을 담음
                this.deleteInfo.fromBatchClass = String.valueOf(this).split(':')[0];
                Database.executeBatch(new Dummy_IF_KR_ERP_SE_Delete_ba(this.deleteInfo), 2000);
            }
        }

        //============================================================================
        // 2. 정상처리가 안된 Dummy Record 의 Ids 로깅처리
        //============================================================================
        if(this.errorDummyIds.isEmpty() == false) {
            System.debug(System.LoggingLevel.ERROR, '::::: errorDummyids : ' + String.join(this.errorDummyIds, ', '));
        }

    }

}