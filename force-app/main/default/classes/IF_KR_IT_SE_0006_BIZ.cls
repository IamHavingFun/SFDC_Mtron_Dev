/****************************************************************************************
  * File Name   : IF_KR_IT_SE_0006_BIZ
  * Description : IF_KR_IT_SE_0006_BIZ Class 
  * Author      : namho100
  * copyright   : Copyright © I2max. All Rights Reserved.
  * Modification Log
  * ===============================================================
  * Ver   Date         Author       Modification
  * ===============================================================
    1.0   2021-10-18   namho100     Create
***************************************************************************************/ 
public with sharing class IF_KR_IT_SE_0006_BIZ {
    private static String sendType = '소모품';
    private static String exceptionString ='UnKnown';
    private static IF_KR_IT_SE_0006_BIZ sInstance = null;
    public static IF_KR_IT_SE_0006_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_IT_SE_0006_BIZ();
        }
        return sInstance;
    }

    /**
     * pre logic
     */
    public IF_KR_IT_SE_0006.InputBody pre(IF_KR_IT_SE_0006.InputBody inputBody, IF_KR_IT_SE_0006.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return inputBody;
    }

    /**
     * post logic
     */
    public IF_KR_IT_SE_0006.OutputBody post(IF_KR_IT_SE_0006.InputBody inputBody, IF_KR_IT_SE_0006.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */

        IF_KR_IT_SE_0006.OUTPUT_T_DATA output_t_data = new IF_KR_IT_SE_0006.OUTPUT_T_DATA();

        /* IF에서 사용할 변수 선언 부 */
        String tractor_id;              // 기대번호
        String maintenance_type;        // 소모품 일반 : 00, 타입1 : 01, 타입2 : 02
        String maintenance_msg;         // 타입2 일 경우 메시지 조합 후 전송
        String maintenance_code;        // 소모품 코드
        String rtError = '';            // 결과값 리턴 에러 메세지
        String rtCode = '';             //결과값 코드

        //정상
        Boolean validate = true;

        if (inputBody.t_data.size() == 1) {
            IF_KR_IT_SE_0006.INPUT_T_DATA tdata = inputBody.t_data[0];

            if(String.isEmpty(tdata.tractor_id)||String.isBlank(tdata.tractor_id)){
                validate= false;
                rtError='기대번호가 일치하는 자산이 없습니다.';
                rtCode ='F';
            }

            if(String.isEmpty(tdata.maintenance_type)||String.isBlank(tdata.maintenance_type)){
                validate= false;
                rtError='소모품타입정보가 없습니다.';
                rtCode ='F';
            }

            if(String.isEmpty(tdata.maintenance_code)||String.isBlank(tdata.maintenance_code)){
                validate= false;
                rtError= '소모품코드 정보가 없습니다.';
                rtCode ='F';
            }

            if(tdata.maintenance_type == '02' && String.isBlank(tdata.maintenance_msg)){
                validate= false;
                rtCode='F';
                rtError = 'maintenance_msg가 없습니다.';
            }


            if(tdata.maintenance_type != '00' && tdata.maintenance_type != '01' && tdata.maintenance_type != '02'){
                validate= false;
                rtCode='F';
                rtError = '소모품타입 정보가 틀립니다.';
            }

            if(validate){
                tractor_id =tdata.tractor_id;
                maintenance_type=tdata.maintenance_type;
                maintenance_msg=tdata.maintenance_msg;
                maintenance_code=tdata.maintenance_code;
            }

        } else if (inputBody.t_data.size() > 1){
            validate = false;
            rtError= '비정상 정보입니다.';
            rtCode ='F';

        } else {
            validate = false;
            rtError= '입력 정보가 없습니다.';
            rtCode ='F';
        }

        //따로 빼낼 예정??
        if(validate){
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //1. 탬플릿
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            String errMsg ='';
            String mType =  (maintenance_type.contains('00'))?'일반':
                    (maintenance_type.contains('01'))?'타입1':(maintenance_type.contains('02'))?'타입2':'에러';

            //탬플릿 정보
            MAP<String,id> templateNameMap = iTractorServiceUtil.getTemplateMapInfo(sendType, mType);

            //실제 탬플릿 할당을위한 템플릿 정보
            Map<Id, NotificationTemplate__c> templateMap = new Map<Id, NotificationTemplate__c>(
                [ SELECT id, name,
                        LABEL1__c,
                        LABEL2__c,
                        LABEL3__c,
                        LABEL4__c,
                        LABEL5__c,
                        Content__c,
                        Title__c
                FROM NotificationTemplate__c
                WHERE id in : templateNameMap.values()]);

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //2. Asset
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            //문자발송시 참조되는 자산 Obj조회
            Asset ast = [
                 SELECT Id, Name,
                        BatchNo__c,
                        AccountId,
                        Account.Name,
                        Account.LastName,
                        Account.FirstName,
                        Account.PersonMobilePhone,
                        Customer__c,
                        Customer__r.Name,
                        Customer__r.LastName,
                        Customer__r.FirstName,
                        Customer__r.Mobile__c,
                        Customer__r.PersonMobilePhone,
                        Product2.Name,
                        Dealer__r.Name,
                        Dealer__r.Mobile__c,
                        Account.IsPersonAccount,
                        isNHContact__c
                FROM Asset WHERE BatchNo__c =:tractor_id
            ];


            if(ast != null){

                if(ast.Customer__r.Name !=null){
                    if(exceptionString.contains(ast.Customer__r.Name)){
                        rtCode='F';
                        rtError = 'UnKnown유저분에게는 메세지 발송 불가합니다.';
                    }
                }

                if(ast.Dealer__r.Name !=null){
                    if(exceptionString.contains(ast.Dealer__r.Name)){
                        rtCode='F';
                        rtError = 'UnKnown유저분에게는 메세지 발송 불가합니다.';
                    }
                }

                if(ast.Account.Name !=null){
                    if(exceptionString.contains(ast.Account.Name)){
                        rtCode='F';
                        rtError = 'UnKnown유저분에게는 메세지 발송 불가합니다.';
                    }
                }
                //추가 로직 UnKnown인경우 발송 예외 처리 2021-12-07
                /*if(exceptionString.contains(ast.Customer__r.Name) ||       exceptionString.contains(ast.Dealer__r.Name) ||       exceptionString.contains(ast.Account.Name)){
                    rtCode='F';
                    rtError = 'UnKnown유저분에게는 메세지 발송 불가합니다.';
                }*/
            }
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\
            //3. 에러코드
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //error코드값
            errMsg = iTractorServiceUtil.getCodeMsg(sendType,maintenance_code);
            iTractorServiceLabelMapping.iTractorlabels labels = new  iTractorServiceLabelMapping.iTractorlabels();

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\
            //실작업 처리  시작
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\

            System.debug('templateNameMap.size() ' + templateNameMap.size());
            if(templateNameMap.size() != 0){
                if(!rtCode.contains('F')){
                    String msg = iTractorServiceUtil.validate(ast);
                    if( msg==''){
                        rtCode='S';
                        rtError = '메세지 전송 요청이 정상적으로 완료 되었습니다.';
                        //두 고객중 한고객만 선택
                        if(ast.isNHContact__c.contains('농협고객'))       templateNameMap.remove('개인고객');
                        else if(ast.isNHContact__c.contains('개인고객'))      templateNameMap.remove('농협고객');

                        //notiGroup id
                        id notiId = null;
                        List<Notification__c> notiLists = new List<Notification__c>();

                        for(id  tmpId :templateNameMap.values()){
                            notiId = iTractorServiceUtil.getNotiGroup();
                            labels = new  iTractorServiceLabelMapping.iTractorlabels();
                            if(maintenance_type.contains('00'))     labels = iTractorServiceLabelMapping.Supplies1(ast,errMsg);
                            if(maintenance_type.contains('01'))     labels = iTractorServiceLabelMapping.Supplies2(ast);
                            if(maintenance_type.contains('02'))     labels = iTractorServiceLabelMapping.Supplies3(ast,errMsg, maintenance_msg);

                            notiLists.add(iTractorServiceUtil.addNotification(notiId, labels, templateMap.get(tmpId)));
                        }

                        if(notiLists.size()> 0) insert notiLists;
                        if(notiLists.size()> 0) System.enqueueJob(new i2SEMA_IFNotificationSend_qu(notiLists));
                    }else{
                        rtCode='F';
                        rtError = msg;
                    }
                }
            }else{
                rtCode='F';
                rtError = '관련 탬플릿 설정 정보가 없습니다.';
            }


            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\
            //실작업 처리 종료
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\

        }

        output_t_data.message_result = rtCode ;
        output_t_data.message_result_desc = rtError;
        outputBody.t_data.add(output_t_data);

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\
        //아이트렉터 로그 등록 처리
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\

        iTractorIFLog__c ifLog = new iTractorIFLog__c();
        ifLog.IFID__c = 'IF_KR_IT_SE_0006';
        ifLog.AssetNumber__c = tractor_id;
        ifLog.ErrorMessage__c = rtError;
        ifLog.ReturnCode__c = (rtCode.contains('S'))? 'Success' : 'Fail' ;
        insert ifLog;

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\
        //아이트렉터 로그 등록 처리
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\



        // 성공일 경우
//        output_t_data.message_result = 'S';

        // 실패일 경우
/*
        output_t_data.message_result = 'E';
        output_t_data.message_result_desc = '해당 기대번호 정보가 없습니다.';

        outputBody.t_data.add(output_t_data);
*/

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return outputBody;
    }

}