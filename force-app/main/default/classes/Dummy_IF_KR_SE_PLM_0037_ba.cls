/****************************************************************************************
  * @filename      : Dummy_IF_KR_SE_PLM_0037_ba
  * @projectname   : 
  * @author        : i2max 
  * @date          : 2020-07-06
  * @group         : 
  * @group-content : 
  * @description   : [PLM 호출]
  *                : PLM 설계변경내역 헤더, 부품목록, 모델목록 의 정보 전송.
  *
  * @tester        : Dummy_IF_KR_SE_PLM_0037_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-06               i2max                  Create
*************a***************************************************************************/
public with sharing class Dummy_IF_KR_SE_PLM_0037_ba extends Dummy_IF_Batch implements Database.AllowsCallouts {

    public override Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id FROM User WHERE Id = :UserInfo.getUserId()
        ]);
    }

    public override void execute(Database.BatchableContext BC, List<SObject> targetScope) {
        // IF Call
        call();
    }

    @TestVisible
    private static void call() {
        IF_KR_SE_PLM_0037 instance = IF_KR_SE_PLM_0037.getInstance();
        IF_KR_SE_PLM_0037.InputDIH input = new IF_KR_SE_PLM_0037.InputDIH();
        IF_KR_SE_PLM_0037.T_DATA tData = new IF_KR_SE_PLM_0037.T_DATA();
        tData.PLANT_ID         = '3602';
        tData.EAI_SFRESULT     = 'N';
        //tData.RELEASED_STATUS  = 'PP RELEASED';
        tData.RELEASED_STATUS = 'PP Released';

        // 적재
        input.request.payload.t_data.add(tData);

        // Interface Request 실행
        System.debug('result input : '+ JSON.serialize(input));

        IF_KR_SE_PLM_0037.OutputDIH result = instance.execute(input);
        System.debug('result : '+result);

        // Interface Response 처리
        if ('S'.equals(result.response.header.ifResult)) {
            //성공 Succeed to Request
        } else {
            //실패 Failed to Request
            System.debug('[Dummy_IF_KR_SE_PLM_0037_ba] Error Message : ' + result.response.header.ifFailMsg);
        }
    }
}