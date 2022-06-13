/****************************************************************************************
  * @filename       : i2SEMA_Util
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-06 오후 3:28
  * @group          :
  * @group-content  :
  * @description    :
  * @tester         : i2SEMA_Util_ts.cls
  * @reference      :
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-06 오후 3:28     i2max_byeon.jw       Create
****************************************************************************************/

global inherited sharing class i2SEMA_Util extends i2SEMA_Base{
    /**
     * @description 공백 체크
     * @param o {Object} 검증 데이터
     * @return {Boolean} 빈값 여부 true/false
     */
    global static Boolean isEmpty(Object o) {
        if (o == null) return true;

        if (o instanceof String) {
            if (''.equals(o)) return true;
            if (''.equals(String.valueOf(o).trim())) return true;
        }
        return false;
    }
    global static Boolean isNotEmpty(Object o){
        return !isEmpty(o);
    }
    /**
     * @description IF String 치환
     * @param s {String} 원본 문자열
     * @return {String} 치환 문자열
     */
    global static String convertIFString(String s) {
        if(s == null || s == 'null') return '';
        return s;
    }
    /**
     * @description Phone Number Format
     * @param phoneNumber {String} Phone Number
     * @return {String} "-" , "()" , 공백이 제거된 Phone Number
     */
    global static String convertPhoneNumberFormat(String phoneNumber){
        return convertIFString(phoneNumber).replace('-','').replace('(','').replace(')','').deleteWhitespace();
    }
    /**
     * @description Picklist Value 조회
     * @param fieldName {String} Object API
     * @param fieldName {String} Field API
     * @return {Map<String,String>} K: Value , V: Label
     */
    global static Map<String,String> getPicklistValue(String objectName, String fieldName ){
        Map<String, String> values = new Map<String, String>{};
        List<Schema.DescribeSObjectResult> results = Schema.describeSObjects(new List<String>{objectName});

        for(Schema.DescribeSObjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }
        return values;
    }
    /**
     * @description SObject Field Label,Value 조회
     * @param sObjectTypes {List<String>} SObject Type 목록
     * @return {Map<String,Object>} SObject 조회 결과
     */
    global static Map<String,Object> getSObjectDescribe(List<String> sObjectTypes){
        Map<String, Object> result = new Map<String, Object>();

        if( !sObjectTypes.isEmpty() ){
            // Object Describe
            List<DescribeSObjectResult> objectDescribes = Schema.describeSObjects(sObjectTypes);
            for( DescribeSObjectResult dsr : objectDescribes ){
                // Object Label,Name
                Map<String,Object> describeMap = new Map<String,Object>();
                describeMap.put('label',dsr.getLabel());
                describeMap.put('name',dsr.getName());

                // Object Fields
                Map<String,Schema.SObjectField> describeFields = dsr.fields.getMap();
                for( String fieldName : describeFields.keySet() ){
                    Map<String,Object> fieldItem = new Map<String,Object>();

                    Schema.SObjectField field       = describeFields.get(fieldName);
                    Schema.DescribeFieldResult dfr  = field.getDescribe();

                    fieldItem.put('label',dfr.getLabel());
                    fieldItem.put('name',dfr.getName());

                    // Picklist
                    if( dfr.getType() == Schema.DisplayType.PICKLIST ){
                        List<Schema.PicklistEntry> picklistEntries  = dfr.getPicklistValues();
                        List<Map<String,Object>> picklistOptions    = new List<Map<String,Object>>();

                        Map<String,Object> initialOptions = new Map<String,Object>();

                        for( Schema.PicklistEntry pe : picklistEntries ){
                            Map<String,Object> picklistItem = new Map<String,Object>();
                            picklistItem.put('label',pe.getLabel());
                            picklistItem.put('value',pe.getValue());

                            picklistOptions.add(picklistItem);
                        }
                        fieldItem.put('picklistOptions',picklistOptions);
                    }
                    describeMap.put(dfr.getName() , fieldItem);
                }
                result.put(dsr.getName() , describeMap);
            }
        }
        return result;
    }
    /**
     * @description Channel 을 통한 Message 길이 유효확인
     *
     * @param channel {String} SMS,MMS,Kakao 등 Channel 구분자
     * @param message {String} 길이확인 대상 메세지
     *
     * @return {Boolean} 길이 유효여부
     */
    global static Boolean isValidMessageLength( String channel , String message ){
        Integer byteLimit;

        switch on channel {
            when '0' {
                byteLimit = getSMSByteLimit();
            }
            when '2' {
                byteLimit = getMMSByteLmit();
            }
            when '3' {
                byteLimit = getLMSByteLimit();
            }
            when '1009'{
                byteLimit = getKakaoFriendTalkByteLimit();
            }
            when '1008' {
                byteLimit = getKakaoNotificationTalkByteLimit();
            }
            when '10'{
                byteLimit = getChatterByteLimit();
            }
        }

        // UTF-8 기준에서 한글이 3byte 로 책정되므로 한글을 영문 'aa' 로 변환하여 계산
        String convertMessage = message.replaceAll('[가-힣]','aa');

        Blob textBlob = Blob.valueOf(convertMessage);

        return byteLimit >= textBlob.size();
    }
    /**
     * @description 예약시간을 스케줄 설정 값으로 변환
     *
     * @param message {Datetime} 예약 시간
     *
     * @return {String} 스케줄 값
     */
    global static String convertSchedule(Datetime reservationDate){
        Integer year = reservationDate.year();
        Integer day = reservationDate.day();
        Integer month = reservationDate.month();
        Integer hour = reservationDate.hour();
        Integer minute = reservationDate.minute();

        String sch = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;       //ex) 0 5 10 24 3 ? 2020   = 2020-03-24 10:05
        return sch;
    }


}