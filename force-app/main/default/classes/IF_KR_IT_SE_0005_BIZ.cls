/****************************************************************************************
  * File Name   : IF_KR_IT_SE_0005_BIZ
  * Description : IF_KR_IT_SE_0005_BIZ Class 
  * Author      : namho100
  * copyright   : Copyright © I2max. All Rights Reserved.
  * Modification Log
  * ===============================================================
  * Ver   Date         Author       Modification
  * ===============================================================
    1.0   2021-10-18   namho100     Create
***************************************************************************************/
public with sharing class IF_KR_IT_SE_0005_BIZ {

    private static IF_KR_IT_SE_0005_BIZ sInstance = null;
    public static IF_KR_IT_SE_0005_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_IT_SE_0005_BIZ();
        }
        return sInstance;
    }

    /**
     * pre logic
     */
    public IF_KR_IT_SE_0005.InputBody pre(IF_KR_IT_SE_0005.InputBody inputBody, IF_KR_IT_SE_0005.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return inputBody;
    }

    /**
     * post logic
     */
    public IF_KR_IT_SE_0005.OutputBody post(IF_KR_IT_SE_0005.InputBody inputBody, IF_KR_IT_SE_0005.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        IF_KR_IT_SE_0005.OUTPUT_T_DATA output_t_data = new IF_KR_IT_SE_0005.OUTPUT_T_DATA();

        if(inputBody != null && inputBody.t_data != null && !inputBody.t_data.isEmpty()) {


            /* IF에서 사용할 변수 선언 부 */
            String tractor_id;      // 기대번호
            String code_type;       // 00 : 고장, 01 : 경고
            String code;            // 고장, 경고 코드
            String rtError = '';    // 결과값 리턴 에러 메세지
            Boolean isCustomerSend = false;     // 고객
            Boolean isNHSend = false;           // 농협
            Boolean isDealerSend = false;       // 대리점
            Boolean isRepairmanSend = false;    // 영업기사

            if (inputBody.t_data[0].tractor_id != null && inputBody.t_data[0].tractor_id != '') {
                tractor_id = inputBody.t_data[0].tractor_id;
            } else {
                rtError += 'tractor_id 파라미터가 누락되었거나 값이 없습니다. ';
            }
            if (inputBody.t_data[0].code_type != null && inputBody.t_data[0].code_type != '') {
                if (inputBody.t_data[0].code_type == '00') code_type = '고장';
                else if (inputBody.t_data[0].code_type == '01') code_type = '경고';
                else rtError += 'code_type 파라미터 값이 잘못 되었습니다. ';
            } else {
                rtError += 'code_type 파라미터가 누락되었거나 값이 없습니다. ';
            }
            if (inputBody.t_data[0].code != null && inputBody.t_data[0].code != '') {
                code = inputBody.t_data[0].code;
            } else {
                rtError += 'code 파라미터가 누락되었거나 값이 없습니다. ';
            }
            if (inputBody.t_data[0].customer_use_yn != null && inputBody.t_data[0].customer_use_yn != '' && inputBody.t_data[0].customer_use_yn == 'Y') isCustomerSend = true;
            if (inputBody.t_data[0].nonghyup_use_yn != null && inputBody.t_data[0].nonghyup_use_yn != '' && inputBody.t_data[0].nonghyup_use_yn == 'Y') isNHSend = true;
            if (inputBody.t_data[0].agency_use_yn != null && inputBody.t_data[0].agency_use_yn != '' && inputBody.t_data[0].agency_use_yn == 'Y') isDealerSend = true;
            if (inputBody.t_data[0].office_use_yn != null && inputBody.t_data[0].office_use_yn != '' && inputBody.t_data[0].office_use_yn == 'Y') isRepairmanSend = true;

            if (rtError == '') {
                String guestType;   // 기대 번호에 해당하는 고객 유형
                /* 발송 관련 로직 처리 부 */
                List<Asset> assList = [
                        SELECT Id, Name, BatchNo__c, Account.IsPersonAccount, isNHContact__c, Account.PersonMobilePhone, Account.Mobile__c,
                                Customer__r.PersonMobilePhone, Dealer__r.iTractorRepairman__r.Phone__c,
                                Dealer__r.DealerOwner__r.MobilePhone, Product2.Name, Account.Name,
                                Customer__r.Name, Dealer__r.Name, Dealer__r.Phone, Dealer__r.Mobile__c,
                                Dealer__r.DealerOwner__r.Name
                        FROM Asset WHERE BatchNo__c = :tractor_id];
                if(assList.isEmpty()) {
                    output_t_data.message_result = 'E';
                    output_t_data.message_result_desc = '일치하는 기대번호가 없습니다.';
                    recordLog(tractor_id, '기대번호 없음', false);
                    outputBody.t_data.add(output_t_data);
                    return outputBody;
                }

                //TODO unKnown고객 예외처리
                if(!checkAccount(assList)){
                    System.debug('UnKnown 대상으로 한 문자 발송 시도');
                    output_t_data.message_result = 'E';
                    output_t_data.message_result_desc = 'UnKnown 대상에게는 메세지 발송이 불가합니다.';
                    recordLog(tractor_id, 'UnKnown 문자 발송', false);
                    outputBody.t_data.add(output_t_data);
                    return outputBody;
                }

                if(assList[0].isNHContact__c == '개인고객')         guestType = '고객';
                else if(assList[0].isNHContact__c == '농협고객')    guestType = '농협';
                else {
                    System.debug('판매되지 않은 Asset(대리점 혹은 영업소에 있는 Asset)');
                    output_t_data.message_result = 'E';
                    output_t_data.message_result_desc = '실판매 기대번호가 아닙니다.';
                    recordLog(tractor_id, '실판매 데이터 없음', false);
                    outputBody.t_data.add(output_t_data);
                    return outputBody;
                }

                List<iTractorTemplateMap__c> tmList = [select id, Guest_Template__r.Id, Agent_Template__r.Id, NH_Template__r.Id, NHGuest_Template__r.Id, Repairman_Template__r.Id from iTractorTemplateMap__c where Product_Type__c = :code_type and Guest_Type__c = :guestType];
                if(tmList.isEmpty()){
                    System.debug('일치하는 템플릿 찾을 수 없음');
                    output_t_data.message_result = 'E';
                    output_t_data.message_result_desc = '템플릿 등록에 문제가 있습니다. 관리자에게 문의 부탁드립니다.';
                    recordLog(tractor_id, '일치 템플릿 없음', false);
                    outputBody.t_data.add(output_t_data);
                    return outputBody;
                }

                List<iTractorErrorCode__c> errList = [select id, ErrorCode__c, ErrorMessage__c from iTractorErrorCode__c where ErrorCode__c = :code and ErrorType__c = :code_type];
                if(errList.isEmpty()){
                    System.debug('일치하는 에러코드 찾을 수 없음');
                    output_t_data.message_result = 'E';
                    output_t_data.message_result_desc = '등록되어 있지 않은 에러코드입니다.';
                    recordLog(tractor_id, '등록되지 않은 에러코드', false);
                    outputBody.t_data.add(output_t_data);
                    return outputBody;
                }

                // NotificationTemplate 맵 생성해서 문자 발송 시 활용할 수 있게 처리
                Map<Id, NotificationTemplate__c> templateMap = new Map<Id, NotificationTemplate__c>(
                [ SELECT id, name,
                        LABEL1__c,
                        LABEL2__c,
                        LABEL3__c,
                        LABEL4__c,
                        LABEL5__c,
                        Content__c,
                        Title__c
                FROM NotificationTemplate__c]);

                NotificationGroup__c notiGroup = new NotificationGroup__c();
                notiGroup.TargetId__c = assList[0].Id;
                notiGroup.IF_Status__c = 'Pending';
                insert notiGroup;

                NotificationGroup__c notiGroup2 = new NotificationGroup__c();
                notiGroup2.TargetId__c = assList[0].Id;
                notiGroup2.IF_Status__c = 'Pending';
                insert notiGroup2;

                NotificationGroup__c notiGroup3 = new NotificationGroup__c();
                notiGroup3.TargetId__c = assList[0].Id;
                notiGroup3.IF_Status__c = 'Pending';
                insert notiGroup3;

                String pLabel1;
                String pLabel2;
                String pLabel3;
                String pLabel4;
                String pLabel5;

                String errLog = '';
                Boolean isError = false;

                List<Notification__c> ntList = new List<Notification__c>();

                /* notification__c 생성 */
                if(code_type == '고장') {
                    if(guestType == '고객'){
                        // 메세지 치환 정보 설정
//                        if(assList[0].Product2 != null && assList[0].Name != null && assList[0].Account != null && errList[0].ErrorMessage__c != null) {
                        // 20220310 대리점명 파라미터 추가
                        if(assList[0].Product2 != null && assList[0].Name != null && assList[0].Account != null && errList[0].ErrorMessage__c != null && assList[0].Dealer__c != null && assList[0].Dealer__r.Name != null) {
                            pLabel1 = assList[0].Product2.Name + ' ' + assList[0].Name;
                            pLabel2 = assList[0].Account.Name;
                            pLabel2 = maskingName(pLabel2);
                            pLabel3 = code + ' ' + errList[0].ErrorMessage__c;
                            //TODO 대리점명 추가 작업 진행 20220310
                            pLabel4 = assList[0].Dealer__r.Name;
                        } else {
                            System.debug('기대정보가 이상합니다.');
                            output_t_data.message_result = 'F';
                            output_t_data.message_result_desc = '기대정보 확인이 필요합니다.';
                            recordLog(tractor_id, '모델명 / 기대번호 / 고객명 / 에러메세지 확인 필요', false);
                            outputBody.t_data.add(output_t_data);
                            return outputBody;
                        }

                        if(isDealerSend){                   // 대리점대표 발송
                            if(templateMap.get(tmList[0].Agent_Template__c) == null) {
                                errLog += '대리점대표 템플릿 누락 ';
                                isError = true;
                            }
                            if(assList[0].Dealer__c == null || assList[0].Dealer__r.DealerOwner__c == null || assList[0].Dealer__r.DealerOwner__r.MobilePhone == null || assList[0].Dealer__r.DealerOwner__r.MobilePhone ==  '') {
                                errLog += '대리점대표 정보 누락 ';
                                isError = true;
                            }
                            if(!isError) {
                                createNoti(ntList, notiGroup, assList[0].Dealer__r.DealerOwner__r.MobilePhone, templateMap.get(tmList[0].Agent_Template__c), plabel1, plabel2, plabel3, plabel4, null);
                            }
                        }

                        if(isRepairmanSend){                // 영업기사 발송
                            if(templateMap.get(tmList[0].Repairman_Template__c) == null) {
                                errLog += '영업기사 템플릿 누락 ';
                                isError = true;
                            }
                            if(assList[0].Dealer__r.iTractorRepairman__c == null || assList[0].Dealer__r.iTractorRepairman__r.Phone__c == null || assList[0].Dealer__r.iTractorRepairman__r.Phone__c ==  '') {
                                errLog += '영업기사 정보 누락 ';
                                isError = true;
                            }
                            if(!isError) {
                                createNoti(ntList, notiGroup2, assList[0].Dealer__r.iTractorRepairman__r.Phone__c, templateMap.get(tmList[0].Repairman_Template__c), plabel1, plabel2, plabel3, plabel4, null);
                            }
                        }
                    } else {
                        // 메세지 치환 정보 설정
                        if(assList[0].Product2 != null && assList[0].Name != null && assList[0].Account != null && errList[0].ErrorMessage__c != null && assList[0].Customer__c != null) {
                            pLabel1 = assList[0].Product2.Name + ' ' + assList[0].Name;
                            pLabel2 = assList[0].Customer__r.Name;
                            pLabel2 = maskingName(pLabel2);
                            pLabel3 = code + ' ' + errList[0].ErrorMessage__c;
                            pLabel4 = assList[0].Account.Name;
                        } else {
                            System.debug('기대정보가 이상합니다.');
                            output_t_data.message_result = 'F';
                            output_t_data.message_result_desc = '기대정보 확인이 필요합니다.';
                            recordLog(tractor_id, '모델명 / 기대번호 / 고객명 / 에러메세지 / 농협명 확인 필요', false);
                            outputBody.t_data.add(output_t_data);
                            return outputBody;
                        }

                        if(isDealerSend){                   // 대리점대표 발송
                            if(templateMap.get(tmList[0].Agent_Template__c) == null) {
                                errLog += '대리점대표 템플릿 누락 ';
                                isError = true;
                            }
                            if(assList[0].Dealer__c == null || assList[0].Dealer__r.DealerOwner__c == null || assList[0].Dealer__r.DealerOwner__r.MobilePhone == null || assList[0].Dealer__r.DealerOwner__r.MobilePhone ==  '') {
                                errLog += '대리점대표 정보 누락 ';
                                isError = true;
                            }
                            if(!isError) {
                                createNoti(ntList, notiGroup, assList[0].Dealer__r.DealerOwner__r.MobilePhone, templateMap.get(tmList[0].Agent_Template__c), plabel1, plabel2, plabel3, pLabel4, null);
                            }
                        }

                        if(isRepairmanSend){                // 영업기사 발송
                            if(templateMap.get(tmList[0].Repairman_Template__c) == null) {
                                errLog += '영업기사 템플릿 누락 ';
                                isError = true;
                            }
                            if(assList[0].Dealer__r.iTractorRepairman__c == null || assList[0].Dealer__r.iTractorRepairman__r.Phone__c == null || assList[0].Dealer__r.iTractorRepairman__r.Phone__c ==  '') {
                                errLog += '영업기사 정보 누락 ';
                                isError = true;
                            }
                            if(!isError) {
                                createNoti(ntList, notiGroup2, assList[0].Dealer__r.iTractorRepairman__r.Phone__c, templateMap.get(tmList[0].Repairman_Template__c), plabel1, plabel2, plabel3, pLabel4, null);
                            }
                        }

                        if(isNHSend){                       // 농협대표 발송
                            if(templateMap.get(tmList[0].NH_Template__c) == null) {
                                errLog += '농협대표 템플릿 누락 ';
                                isError = true;
                            }
                            if(assList[0].Account.Mobile__c == null || assList[0].Account.Mobile__c == '') {
                                errLog += '농협대표 정보 누락 ';
                                isError = true;
                            }
                            if(!isError) {
                                createNoti(ntList, notiGroup3, assList[0].Account.Mobile__c, templateMap.get(tmList[0].NH_Template__c), plabel1, plabel2, plabel3, pLabel4, null);
                            }
                        }
                    }
                } else if(code_type == '경고') {
                    if(guestType == '고객'){
                        if(isCustomerSend) {
                            // 메세지 치환 정보 설정
                            if(assList[0].Product2 != null && assList[0].Name != null && assList[0].Account != null && errList[0].ErrorMessage__c != null && assList[0].Dealer__c != null && assList[0].Dealer__r.Mobile__c != null && assList[0].Dealer__r.Mobile__c != '') {
                                pLabel1 = assList[0].Account.Name;
                                pLabel1 = maskingName(pLabel1);
                                pLabel2 = assList[0].Product2.Name + ' ' + assList[0].Name;
                                pLabel3 = errList[0].ErrorMessage__c;
                                pLabel4 = assList[0].Dealer__r.Name + ' : ' + assList[0].Dealer__r.Mobile__c;
                            } else {
                                System.debug('기대정보가 이상합니다.');
                                output_t_data.message_result = 'F';
                                output_t_data.message_result_desc = '기대정보 확인이 필요합니다.';
                                recordLog(tractor_id, '고객명 / 모델명 / 기대번호 / 에러메세지 / 대리점정보 확인 필요', false);
                                outputBody.t_data.add(output_t_data);
                                return outputBody;
                            }

                            if(templateMap.get(tmList[0].Guest_Template__c) == null) {
                                errLog += '일반고객 템플릿 누락 ';
                                isError = true;
                            }
                            if(assList[0].Account.PersonMobilePhone == null || assList[0].Account.PersonMobilePhone == '') {
                                errLog += '일반고객 정보 누락 ';
                                isError = true;
                            }
                            if(!isError) {
                                createNoti(ntList, notiGroup, assList[0].Account.PersonMobilePhone, templateMap.get(tmList[0].Guest_Template__c), plabel1, plabel2, plabel3, pLabel4, null);
                            }
                        }
                        if(isDealerSend) {
                            // 메세지 치환 정보 설정
                            if(assList[0].Product2 != null && assList[0].Name != null && assList[0].Account != null && errList[0].ErrorMessage__c != null) {
                                pLabel1 = assList[0].Product2.Name + ' ' + assList[0].Name;
                                pLabel2 = assList[0].Account.Name;
                                pLabel2 = maskingName(pLabel2);
                                pLabel3 = errList[0].ErrorMessage__c;
                            } else {
                                System.debug('기대정보가 이상합니다.');
                                output_t_data.message_result = 'F';
                                output_t_data.message_result_desc = '기대정보 확인이 필요합니다.';
                                recordLog(tractor_id, '모델명 / 기대번호 / 고객명 / 에러메세지 확인 필요', false);
                                outputBody.t_data.add(output_t_data);
                                return outputBody;
                            }

                            if(templateMap.get(tmList[0].Agent_Template__c) == null) {
                                errLog += '대리점대표 템플릿 누락 ';
                                isError = true;
                            }
                            if(assList[0].Dealer__c == null || assList[0].Dealer__r.DealerOwner__c == null || assList[0].Dealer__r.DealerOwner__r.MobilePhone == null || assList[0].Dealer__r.DealerOwner__r.MobilePhone ==  '') {
                                errLog += '대리점대표 정보 누락 ';
                                isError = true;
                            }
                            if(!isError) {
                                createNoti(ntList, notiGroup2, assList[0].Dealer__r.DealerOwner__r.MobilePhone, templateMap.get(tmList[0].Agent_Template__c), plabel1, plabel2, plabel3, null, null);
                            }
                        }
                    } else {
                        if (isCustomerSend) {
                            // 메세지 치환 정보 설정
                            if (assList[0].Product2 != null && assList[0].Name != null && assList[0].Customer__c != null && errList[0].ErrorMessage__c != null && assList[0].Dealer__c != null && assList[0].Dealer__r.Mobile__c != null && assList[0].Dealer__r.Mobile__c != '') {
                                pLabel1 = assList[0].Customer__r.Name;
                                pLabel1 = maskingName(pLabel1);
                                pLabel2 = assList[0].Product2.Name + ' ' + assList[0].Name;
                                pLabel3 = errList[0].ErrorMessage__c;
                                pLabel4 = assList[0].Dealer__r.Name + ' : ' + assList[0].Dealer__r.Mobile__c;
                            } else {
                                System.debug('기대정보가 이상합니다.');
                                output_t_data.message_result = 'F';
                                output_t_data.message_result_desc = '기대정보 확인이 필요합니다.';
                                recordLog(tractor_id, '고객명 / 모델명 / 기대번호 / 에러메세지 / 대리점정보 확인 필요', false);
                                outputBody.t_data.add(output_t_data);
                                return outputBody;
                            }

                            if (templateMap.get(tmList[0].NHGuest_Template__c) == null) {
                                errLog += '농협고객 템플릿 누락 ';
                                isError = true;
                            }
                            if (assList[0].Customer__c == null || assList[0].Customer__r.PersonMobilePhone == null || assList[0].Customer__r.PersonMobilePhone == '') {
                                errLog += '일반고객 정보 누락 ';
                                isError = true;
                            }
                            if (!isError) {
                                createNoti(ntList, notiGroup, assList[0].Customer__r.PersonMobilePhone, templateMap.get(tmList[0].NHGuest_Template__c), plabel1, plabel2, plabel3, pLabel4, null);
                            }
                        }
                        if (isNHSend) {
                            // 메세지 치환 정보 설정
                            if (assList[0].Product2 != null && assList[0].Name != null && assList[0].Account != null && errList[0].ErrorMessage__c != null && assList[0].Customer__c != null) {
                                pLabel1 = assList[0].Product2.Name + ' ' + assList[0].Name;
                                pLabel2 = assList[0].Customer__r.Name;
                                pLabel2 = maskingName(pLabel2);
                                pLabel3 = errList[0].ErrorMessage__c;
                                pLabel4 = assList[0].Account.Name;
                            } else {
                                System.debug('기대정보가 이상합니다.');
                                output_t_data.message_result = 'F';
                                output_t_data.message_result_desc = '기대정보 확인이 필요합니다.';
                                recordLog(tractor_id, '모델명 / 기대번호 / 고객명 / 에러메세지 / 농협정보 확인 필요', false);
                                outputBody.t_data.add(output_t_data);
                                return outputBody;
                            }

                            if (templateMap.get(tmList[0].NH_Template__c) == null) {
                                errLog += '농협대표 템플릿 누락 ';
                                isError = true;
                            }
                            if (assList[0].Account.Mobile__c == null || assList[0].Account.Mobile__c == '') {
                                errLog += '농협대표 정보 누락 ';
                                isError = true;
                            }
                            if (!isError) {
                                createNoti(ntList, notiGroup2, assList[0].Account.Mobile__c, templateMap.get(tmList[0].NH_Template__c), plabel1, plabel2, plabel3, pLabel4, null);
                            }
                        }
                        if (isDealerSend) {
                            // 메세지 치환 정보 설정
                            if (assList[0].Product2 != null && assList[0].Name != null && assList[0].Account != null && errList[0].ErrorMessage__c != null && assList[0].Customer__c != null) {
                                pLabel1 = assList[0].Product2.Name + ' ' + assList[0].Name;
                                pLabel2 = assList[0].Customer__r.Name;
                                pLabel2 = maskingName(pLabel2);
                                pLabel3 = errList[0].ErrorMessage__c;
                                pLabel4 = assList[0].Account.Name;
                            } else {
                                System.debug('기대정보가 이상합니다.');
                                output_t_data.message_result = 'F';
                                output_t_data.message_result_desc = '기대정보 확인이 필요합니다.';
                                recordLog(tractor_id, '모델명 / 기대번호 / 고객명 / 에러메세지 / 농협정보 확인 필요', false);
                                outputBody.t_data.add(output_t_data);
                                return outputBody;
                            }

                            if (templateMap.get(tmList[0].Agent_Template__c) == null) {
                                errLog += '대리점대표 템플릿 누락 ';
                                isError = true;
                            }
                            if (assList[0].Dealer__c == null || assList[0].Dealer__r.DealerOwner__c == null || assList[0].Dealer__r.DealerOwner__r.MobilePhone == null || assList[0].Dealer__r.DealerOwner__r.MobilePhone == '') {
                                errLog += '대리점대표 정보 누락 ';
                                isError = true;
                            }
                            if (!isError) {
                                createNoti(ntList, notiGroup3, assList[0].Dealer__r.DealerOwner__r.MobilePhone, templateMap.get(tmList[0].Agent_Template__c), plabel1, plabel2, plabel3, pLabel4, null);
                            }
                        }
                    }
                }



                System.debug('after creation');
                System.debug(ntList);

                /* 생성된 notification__c 발송 요청(queue) */
                if(!isError && !ntList.isEmpty() && ntList.size() > 0)  System.enqueueJob(new i2SEMA_IFNotificationSend_qu(ntList));
                else {
                    output_t_data.message_result = 'F';
                    if(ntList.size()>0) output_t_data.message_result_desc = errLog;
                    else output_t_data.message_result_desc = '문자 발송 요청 건이 0 입니다.';
                    recordLog(tractor_id, errLog, false);
                    outputBody.t_data.add(output_t_data);
                    return outputBody;
                }

                /* 성공 후 로그 쌓는 로직 */

                // 성공일 경우
                output_t_data.message_result = 'S';
                output_t_data.message_result_desc = '메세지 전송 요청이 정상적으로 완료 되었습니다.';
                recordLog(tractor_id, '메세지 정상 요청', true);
            }

            // 실패일 경우
            else {
                output_t_data.message_result = 'F';
                output_t_data.message_result_desc = rtError;
                recordLog(tractor_id, rtError, false);
            }
        } else{
            output_t_data.message_result = 'F';
            output_t_data.message_result_desc = 't_data 정보가 잘못되었습니다. ';
            recordLog('기대번호 에러', 'API 파라미터 정보 오류', false);
        }


        outputBody.t_data.add(output_t_data);

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return outputBody;
    }

    private static void getData() {

    }

    private static void createNoti(List<Notification__c> ntList, NotificationGroup__c NG, String Phone, NotificationTemplate__c tmp, String label1, String label2, String label3, String label4, String label5){
        Notification__c noti = new Notification__c();
        noti.TargetId__c = NG.TargetId__c;
        noti.Phone__c = Phone;
        noti.NotificationTemplate__c = tmp.Id;
        if(label1 != null)  noti.LABEL1__c = label1;
        if(label2 != null)  noti.LABEL2__c = label2;
        if(label3 != null)  noti.LABEL3__c = label3;
        if(label4 != null)  noti.LABEL4__c = label4;
        if(label5 != null)  noti.LABEL5__c = label5;
        noti.IsSendingReservation__c = false;
        noti.SendingTime__c = Datetime.now();
        noti.msg_status__c = null;
        noti.NotificationGroup__c = NG.Id;
        noti.Channel__c = '3';
        noti.Title__c = tmp.Title__c;
        noti.Content__c = tmp.Content__c;
        noti.RawContents__c = tmp.Content__c;
        insert noti;

        ntList.add(noti);

        System.debug('ntLIst added @ createNoti');
        System.debug(ntList);
    }

    private static void recordLog(String assNo, String recordData, Boolean isSuccess) {
        iTractorIFLog__c log = new iTractorIFLog__c();
        log.AssetNumber__c = assNo;
        log.IFID__c = 'IF_KR_IT_SE_0005';
        if(isSuccess)   log.ReturnCode__c = 'Success';
        else {
            log.ReturnCode__c = 'Fail';
            log.ErrorMessage__c = recordData;
        }
        insert log;
    }

    private static String maskingName(String inputStr) {
        inputStr = inputStr.replaceAll(' ', '');
        String result = '';
        String ast = '';

        for(integer i=0; i<inputStr.length()-2; i++) ast += '*';

        if(inputStr.length() > 2) {
            result = inputStr.left(1) + ast + inputStr.right(1);
        } else {
            result = inputStr.left(1) + '*';
        }

        return result;
    }

    private static boolean checkAccount(list<Asset> input) {
        for(Asset ass : input){
            if((ass.Customer__r.Name != null && ass.Customer__r.Name == 'UnKnown') || (ass.Dealer__r.Name != null && ass.Dealer__r.Name == 'UnKnown') || (ass.Account.Name != null && ass.Account.Name == 'UnKnown')) {
                return false;
            }
        }
        return true;
    }

}