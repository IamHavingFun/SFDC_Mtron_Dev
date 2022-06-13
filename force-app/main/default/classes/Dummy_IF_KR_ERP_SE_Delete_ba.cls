/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_Delete_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-24
  * @group         : 
  * @group-content : 
  * @description   : Dummy 데이터 삭제 : 후행 배치
  * @tester        : Dummy_IF_KR_ERP_SE_Delete_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-24         i2max          Create
****************************************************************************************/
public class Dummy_IF_KR_ERP_SE_Delete_ba extends Dummy_IF_Batch {

    /**
     * delete batch 수행 정보
     */
    private Dummy_IF_Batch.DeleteInfo deleteInfo;

    /**
     * 후행으로 수행을 해야하는 delete batch의 정보
     *
     * @param deleteInfo Delete Batch 수행 정보 class
     */
    public Dummy_IF_KR_ERP_SE_Delete_ba(final Dummy_IF_Batch.DeleteInfo deleteInfo) {
        this.deleteInfo = deleteInfo;
    }

    /**
     * Start
     *
     * @param BC : BatchableContext
     *
     * @return Database.QueryLocator
     */
    public override Database.QueryLocator start(Database.BatchableContext BC) {

        String query;

        //============================================================================
        // 로깅처리이므로 지우지 말것
        //============================================================================
        System.debug(System.LoggingLevel.INFO, '::::: Dummy Delete Batch 정보[시작] :::::');
        System.debug(System.LoggingLevel.INFO, '::::: deleteInfo :' + this.deleteInfo);
        System.debug(System.LoggingLevel.INFO, '::::: deleteInfo.dummyDeleteBaseDt :' + this.deleteInfo.dummyDeleteBaseDt);
        System.debug(System.LoggingLevel.INFO, '::::: Dummy Delete Batch 정보[종료] :::::');

        if(     this.deleteInfo != null
            &&  String.isNotBlank(this.deleteInfo.dummySObject)
            && String.isNotBlank(this.deleteInfo.dummyInterfaceId)
            && this.deleteInfo.dummyBatchPeriodType != null
            && this.deleteInfo.dummyDeleteBaseDt != null
        ) {
            query =  'SELECT Id ' + '\n';
            query += 'FROM ' + this.deleteInfo.dummySObject + '\n';
            query += 'WHERE isBatchCompleted__c = TRUE' + '\n';
            query += 'AND   isBatchError__c = FALSE' + '\n';
            query += 'AND   InterfaceId__c = \'' + this.deleteInfo.dummyInterfaceId + '\'' + '\n' ;
            query += 'AND   DAY_ONLY(CreatedDate) < ' + this.deleteInfo.dummyDeleteBaseDt.format('yyyy-MM-dd');
        }

        //============================================================================
        // 로깅처리이므로 지우지 말것
        //============================================================================
        System.debug(System.LoggingLevel.INFO, '::::: query :' + query);

        return Database.getQueryLocator(query);
    }

    /**
     * 수행 로직 구현
     *
     * @param BC : BatchableContext
     * @param targetScope : Batch Size 실행 리스트
     */
    public override void execute(Database.BatchableContext BC, List<SObject> targetScope) {
        delete targetScope;
    }

}