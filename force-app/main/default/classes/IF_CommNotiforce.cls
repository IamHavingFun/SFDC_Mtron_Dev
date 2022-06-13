/****************************************************************************************
  * File Name   : IF_CommNotiforce
  * Description : Interface Common
  * Copyright   : Copyright © 2020 i2max All Rights Reserved
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author       Modification
  * ===============================================================
    1.0  2020. 01. 16.  ldb3100      Create
****************************************************************************************/
public with sharing class IF_CommNotiforce {
	  public static Boolean isDev = false;

    public static void show(){
        System.debug('UserInfo.getDefaultCurrency() : '+UserInfo.getDefaultCurrency());
        System.debug('UserInfo.getFirstName() : '+UserInfo.getFirstName());
        System.debug('UserInfo.getLanguage() : '+UserInfo.getLanguage());
        System.debug('UserInfo.getLastName() : '+UserInfo.getLastName());
        System.debug('UserInfo.getLocale() : '+UserInfo.getLocale());
        System.debug('UserInfo.getName() : '+UserInfo.getName());
        System.debug('UserInfo.getOrganizationId() : '+UserInfo.getOrganizationId());
        System.debug('UserInfo.getOrganizationName() : '+UserInfo.getOrganizationName());
        System.debug('UserInfo.getProfileId() : '+UserInfo.getProfileId());
        System.debug('UserInfo.getSessionId() : '+UserInfo.getSessionId());
        System.debug('UserInfo.getTimeZone() : '+UserInfo.getTimeZone());
        System.debug('UserInfo.getUiTheme() : '+UserInfo.getUiTheme());
        System.debug('UserInfo.getUiThemeDisplayed() : '+UserInfo.getUiThemeDisplayed());
        System.debug('UserInfo.getUserEmail() : '+UserInfo.getUserEmail());
        System.debug('UserInfo.getUserId() : '+UserInfo.getUserId());
        System.debug('UserInfo.getUserName() : '+UserInfo.getUserName());
        System.debug('UserInfo.getUserRoleId() : '+UserInfo.getUserRoleId());
        System.debug('UserInfo.getUserType() : '+UserInfo.getUserType());
        System.debug('UserInfo.isMultiCurrencyOrganization() : '+UserInfo.isMultiCurrencyOrganization());

        System.debug('URL.getSalesforceBaseUrl().toExternalForm() : '+URL.getSalesforceBaseUrl().toExternalForm());
        System.debug('URL.getSalesforceBaseUrl().getHost() : '+URL.getSalesforceBaseUrl().getHost());
        System.debug('URL.getSalesforceBaseUrl().getProtocol() : '+URL.getSalesforceBaseUrl().getProtocol());
        System.debug('URL.getSalesforceBaseUrl().getQuery() : '+URL.getSalesforceBaseUrl().getQuery());
    }

    public static void errorDebug(Exception e){
        System.debug('Exception type : ' + e.getTypeName());
        System.debug('Message : ' + e.getMessage());
        System.debug('Stack trace : ' + e.getStackTraceString());
    }

    public static String errorText(Exception e){
        String msg = e.getMessage();
        String stackMsg = e.getStackTraceString();
        msg = msg.replaceAll('"', '\'');
        stackMsg = stackMsg.replaceAll('"', '\'');
        String errorText = 'Message : ' + msg + '\n Stack trace : ' + stackMsg;
        return errorText;
    }

        public static String normalizeDecimal(String jsonStr, String cols){
        string findText = '';
        string regText = '';
        String regexText = '';
        integer foundAt = -1;
        integer startAt = 0;
        integer textLen = jsonStr.length();
        integer endAt = textLen;
        integer cnt = 0;
        List<string> colList = cols.split('\\|');

        //system.debug('colList.count: ' + colList.size());
        for (string col : colList) {
            //system.debug('col: ' + col);
            startAt = 0;
            findText = '"' + col + '":';
            foundAt = jsonStr.indexOf(findText, startAt);

            //system.Debug('findText: ' + findText);
            while (foundAt >= 0) {
                endAt = foundAt + 30;
                endAt = endAt>textLen?textLen:endAt;
                regText = jsonStr.substring(foundAt, endAt);
                //system.Debug('regText: ' + regText);
                if (regText.indexOf('-') > 0) {
                    startAt = foundAt + regText.length();

                    regexText = '"(?<key>'+ col + ')":(?<value>[0-9\\.]+\\-)';
                    Matcher pm = Pattern.compile( regexText ).matcher( regText );

                    while (pm.find()) {
                        String key = pm.group(1);
                        String value = pm.group(2);
                        String oriGroup = pm.group(0);
                        String newValue = decimalConv(pm.group(2));  // newValue setting
                        String newGroup = '"' + key + '":' + newValue;  // newGroup setting
                        //system.debug('<before> replace cnt.' + cnt++ + ' : ' + oriGroup + ' -> ' + newGroup);
                        //debugHeap('BEFORE: ' + findText);
                        jsonStr = jsonStr.replace(oriGroup, newGroup);
                        //debugHeap('AFTER: ' + findText);
                        system.debug('replace cnt.' + cnt++ + ' : ' + oriGroup + ' -> ' + newGroup);
                        //sysDebug(jsonStr);
                    }
                }
                startAt = foundAt + findText.length();
                foundAt = jsonStr.indexOf(findText, startAt);
            }
        }

        //system.Debug('>>>>> normalizeDateFromDIH <<<<<\r\nOrgJson: ' + orgJsonStr + '\r\nNewJson: ' + jsonStr);
        return jsonStr;
    }

    public static String normalizeDateFromDIH(String jsonStr, String cols){
        String orgJsonStr = jsonStr;
        String regexText = '"(?<key>'+ cols + ')":"(?<value>\\d{8}|)"';  // regex Text
        sysDebug('regexText: ' + regexText);
        Matcher pm = Pattern.compile( regexText ).matcher( jsonStr );
        Integer cnt=1;
        while (pm.find()) {
            String key = pm.group(1);
            String value = pm.group(2);
            String oriGroup = pm.group(0);
            String newValue = (value == '')?'':strToDateStr(value);  // newValue setting
            //OHW-2016-08-29
            String newGroup = '';
            if ((value == '00000000')||(value == '')) {
                newGroup = '"' + key + '":null';
            } else {
                newGroup = '"' + key + '":"' + newValue + '"';  // newGroup setting
            }
            jsonStr = jsonStr.replace(oriGroup, newGroup);
            sysDebug('replace cnt.' + cnt++ + ' : ' + oriGroup + ' -> ' + newGroup);
            //sysDebug(jsonStr);
        }
        sysDebug('>>>>> normalizeDateFromDIH <<<<<\r\nOrgJson: ' + orgJsonStr + '\r\nNewJson: ' + jsonStr);
        return jsonStr;
    }

    public static String normalizeDateToDIH(String jsonStr, String cols){
        String orgJsonStr = jsonStr;
        String regexText = '"(?<key>'+ cols + ')":\\s?"(?<value>\\d{4}-\\d{2}-\\d{2})"';  // regex Text
        sysDebug('regexText: ' + regexText);
        Matcher pm = Pattern.compile( regexText ).matcher( jsonStr );
        Integer cnt=1;
        while (pm.find()) {
            String key = pm.group(1);
            String value = pm.group(2);
            String oriGroup = pm.group(0);
            String newValue = dateStrToStr(pm.group(2));  // newValue setting
            String newGroup = '"' + key + '":"' + newValue + '"';  // newGroup setting
            jsonStr = jsonStr.replace(oriGroup, newGroup);
            sysDebug('replace cnt.' + cnt++ + ' : ' + oriGroup + ' -> ' + newGroup);
            //sysDebug(jsonStr);
        }
        sysDebug('>>>>> normalizeDateToDIH <<<<<\r\nOrgJson: ' + orgJsonStr + '\r\nNewJson: ' + jsonStr);
        return jsonStr;
    }

    /**
     * String 을 Decimal 로 변경
     * @param str
     * @return Decimal
     */
    public static Decimal stringToDecimal(String str) {
        if ( str == null || str.length() == 0 ) {
            return 0;
        }
        
        return Decimal.valueOf(str);
    }

    public static String decimalConv(String str){
        return '-' + str.removeEnd('-').trim();
    }
    public static String strToDateStr(String yyyymmdd){
        Integer year = Integer.valueOf( yyyymmdd.subString(0,4) );
        String month = yyyymmdd.subString(4,6);
        String day = yyyymmdd.subString(6,8);
        String newStr;

        // 4000년 이상인경우 4000년으로 치환
        if(year > 4000){
            year = 4000;
            System.debug('[strToDateStr] 9999XXXX: ' + yyyymmdd);
            month = '12';
            day = '31';
        }
        newStr = String.valueOf(year) + '-' + month + '-' + day;
        return newStr;
    }
    public static String dateStrToStr(String yyyyMMdd){
        return yyyyMMdd.replace('-','');
    }

    // system.debug 표출
    public static void sysDebug(String str){
        Datetime currentDateTime = System.now();
        String longDate = currentDateTime.format('yyyy-MM-dd HH:mm:ss,SS');

        if(isDev == true){
            System.debug(longDate + ' [DEBUG] - ' + str);
        }
    }

    /***********************************************************************************/
    public static string convertChunkListToJson(List<string> sList) {
        //debugHeap('[normalizeListToJson] before join');
        string result = String.join(sList, '');
        //debugHeap('[normalizeListToJson] after join');
        return result;
    }

    public static List<string> convertJsonToChunkList(string res) {
        List<string> cList = new list<string>();
        integer chunkSize = 1024 * 50;
        integer resLen = res.length();
        system.debug('initial res.length(): ' + resLen);
        integer lastIdx = resLen - 1;
        integer startAt = 0;
        integer endAt = Math.Min(startAt + chunkSize, lastIdx);
        string chunkText = '';
        while (endAt <= lastIdx) {
            if (endAt < lastIdx) {
                // Key-Value 쌍이 분리되는 경우를 방지하기 위해 가장 가까운 쉼표를 찾아 분리함.
                // Method 1
                /*
                for (integer i= endAt; i > startAt; i--) {
                    integer c = res.charAt(i);
                    // 44 --> Comma
                    if (c == 44) {
                        endAt = i;
                        break;
                    }
                }
                */

                // Method 2
                ///*
                integer commaAt = res.lastIndexOf(',', endAt);
                if (commaAt >= 0) {
                    endAt = commaAt;
                }
                //*/
            }

            chunkText = res.substring(startAt, endAt + 1);
            cList.add(chunkText);
            if (endAt < lastIdx) {
                startAt = endAt + 1;
                endAt = Math.Min(startAt + chunkSize, lastIdx);
            } else {
                break;
            }
        }
        return cList;
    }

    public static void convertDecimal(String jsonStr, String cols, List<string> rList){
        string regexText = '"(?<key>'+ cols + ')":(?<value>[0-9\\.]+\\-)';
        Matcher pm = Pattern.compile( regexText ).matcher( jsonStr );
        while (pm.find()) {
            String key = pm.group(1);
            String value = pm.group(2);
            String oriGroup = pm.group(0);
            String newValue = decimalConv(value);  // newValue setting
            String newGroup = '"' + key + '":' + newValue;  // newGroup setting
            //debugHeap('normalizeDecimalInternal before replace: ' + oriGroup);
            jsonStr = jsonStr.replace(oriGroup, newGroup);
            //debugHeap('[normalizeDecimalInternal] after replace: ' + newValue);
            system.debug('[normalizeDecimalInternal] replace: ' + oriGroup + ' -> ' + newGroup);
        }
        rList.add(jsonStr);
    }

    public static void convertDateSFDCToDIH(String jsonStr, String cols, List<string> dList){
        String orgJsonStr = jsonStr;
        String regexText = '"(?<key>'+ cols + ')":"(?<value>\\d{4}-\\d{2}-\\d{2})"';  // regex Text
        Matcher pm = Pattern.compile( regexText ).matcher( jsonStr );
        while (pm.find()) {
            String key = pm.group(1);
            String value = pm.group(2);
            String oriGroup = pm.group(0);
            String newValue = dateStrToStr(value);  // newValue setting
            String newGroup = '"' + key + '":"' + newValue + '"';  // newGroup setting
            jsonStr = jsonStr.replace(oriGroup, newGroup);
            sysDebug('replace: ' + oriGroup + ' -> ' + newGroup);
        }
        dList.add(jsonStr);
    }

    //public static void convertDateDIHToSFDC(String jsonStr, String keys, List<string> dList){
    //    String orgJsonStr = jsonStr;
    //    String regexText = '"(?<key>'+ keys + ')":"(?<value>\\d{8}|)"';  // regex Text
    //    //System.debug('before convertDateDIHToSFDC: ' + jsonStr);
    //    //sysDebug('regexText: ' + regexText);
    //    Matcher pm = Pattern.compile( regexText ).matcher( jsonStr );
    //    while (pm.find()) {
    //        String key = pm.group(1);
    //        String value = pm.group(2);
    //        String oriGroup = pm.group(0);
    //        String newValue = (value == '')?'':strToDateStr(value);  // newValue setting
    //        String newGroup = '';
    //        //OHW-2016-08-29
    //        if (value == '00000000' || value == '') {
    //            newGroup = '"' + key + '":null';
    //        } else {
    //            newGroup = '"' + key + '":"' + newValue + '"';  // newGroup setting
    //        }
    //        jsonStr = jsonStr.replace(oriGroup, newGroup);
    //
    //        sysDebug('replace: ' + oriGroup + ' -> ' + newGroup);
    //    }
    //    //system.debug('convertDateDIHToSFDC: ' + jsonStr);
    //    //System.debug('after convertDateDIHToSFDC: ' + jsonStr);
    //    dList.add(jsonStr);
    //}

/*
    public static void convertDecimalEx(List<string> srcList, String keys){
            if (srcList.size()<=0) return;
            List<string> convList = convertJsonToChunkList(srcList[0]);
            srcList.clear();
            convList = convertDecimal(convList, keys);
            srcList.add(IF_CommNotiforce.convertChunkListToJson(convList));
            convList.clear();
    }
*/

    public static List<string> convertDecimal(List<string> cList, String keys) {
        List<string> rList = new List<string>();
        string chunk;
        while (cList.size() > 0) {
            chunk = cList[0];
            convertDecimal(chunk, keys, rList);
            cList.remove(0);
        }
        cList.clear();
        return rList;
    }

    public static List<string> convertDateSFDCToDIH(List<string> cList, String keys) {
        List<string> rList = new List<string>();
        string chunk;
        while (cList.size() > 0) {
            chunk = cList[0];
            convertDateSFDCToDIH(chunk, keys, rList);
            cList.remove(0);
        }
        cList.clear();
        return rList;
    }

    //public static List<string> convertDateDIHToSFDC(List<string> cList, String keys) {
    //    List<string> rList = new List<string>();
    //    string chunk;
    //    while (cList.size() > 0) {
    //        chunk = cList[0];
    //        convertDateDIHToSFDC(chunk, keys, rList);
    //        cList.remove(0);
    //    }
    //    cList.clear();
    //    return rList;
    //}

    public static Date convDateProp(Date v){
        if (v!=null) {
            string newValue=string.valueof(v);
            if (newValue.startsWith('0')) {
                return null;
            } else if(newValue.length() == 10){
                return convStrToDate( strToDateStr( dateStrToStr(newValue) ) );
            } else {
                if (newValue.length() >= 14) {  // DIH 00000000로 왔을때 처리 Date에는 00000000-00-00로 들어가있음
                    return Date.valueOf(newValue.substring(0, 4)+'-'+newValue.substring(4, 6)+'-'+newValue.substring(6, 8));
                }
            }
        }
        return v;
    }

    // string을 date로 return. ex) '20160101' or '2016-01-01' -> date형대의 2016-01-01로
    public static Date convStrToDate(String str){
        Date convDate = null;
        if(str != null){
            if(str.length() == 8){
                convDate = Date.valueOf(str.substring(0, 4)+'-'+str.substring(4, 6)+'-'+str.substring(6, 8));
            } else if(str.length() == 10){
                str = str.replace('-', '');
                convDate = Date.valueOf(str.substring(0, 4)+'-'+str.substring(4, 6)+'-'+str.substring(6, 8));
            }
        }
        return convDate;
    }

    // DateTime을 string로 return. 2016-01-01
    public static String convDateToStr(DateTime convDateTime){
        String convStr = null;
        if(convDateTime == null){
            return '';
        }
        convStr = convDateTime.format('yyyy-MM-dd');
        return convStr;
    }
    // Date을 string로 return. 2016-01-01
    public static String convDateToStr(Date convDate){
        String convStr = null;

        if(isNull(convDate)){
            return '';
        }
        convStr = ((DateTime)convDate).format('yyyy-MM-dd');
        return convStr;
    }
    // DateTime을 string로 return. 20160101
    public static String convDateToStr8(DateTime convDateTime){
        String convStr = null;
        if(convDateTime == null){
            return '';
        }
        convStr = convDateTime.format('yyyyMMdd');
        return convStr;
    }
    // Date을 string로 return. 20160101
    public static String convDateToStr8(Date convDate){
        String convStr = null;

        if(isNull(convDate)){
            return '';
        }
        convStr = ((DateTime)convDate).format('yyyyMMdd');
        return convStr;
    }
    // DateTime을 Date로
    public static Date convDatetimeToDate(Datetime convDateTime){
        Date convDate = null;
        if(convDateTime != null){
            convDate = convDateTime.date();
        }
        return convDate;
    }
    
    // DateTime을 string로 return. 20160101
    public static String convDateTimeToStr14(DateTime convDateTime){
        String convStr = null;
        if(convDateTime == null){
            return '';
        }
        convStr = convDateTime.formatGmt('yyyyMMddHHmmss');
        return convStr;
    }

    public static List<string> convertDateDIHToSFDC4Null(List<string> cList, String keys) {
        List<string> rList = new List<string>();
        string chunk;
        while (cList.size() > 0) {
            chunk = cList[0];
            convertDateDIHToSFDC4Null(chunk, keys, rList);
            cList.remove(0);
        }
        cList.clear();
        return rList;
    }

    public static void convertDateDIHToSFDC4Null(String jsonStr, String keys, List<string> dList){
        String orgJsonStr = jsonStr;
        String regexText = '"(?<key>'+ keys + ')":(""|"00000000")';  // regex Text
        //System.debug('before convertDateDIHToSFDC: ' + jsonStr);
        //sysDebug('regexText: ' + regexText);
        Matcher pm = Pattern.compile( regexText ).matcher( jsonStr );
        while (pm.find()) {
            String key = pm.group(1);
            String value = pm.group(2);
            String oriGroup = pm.group(0);
            string newGroup = '"' + key + '":null';
            jsonStr = jsonStr.replace(oriGroup, newGroup);

            sysDebug('replace: ' + oriGroup + ' -> ' + newGroup);
        }
        //system.debug('convertDateDIHToSFDC: ' + jsonStr);
        //System.debug('after convertDateDIHToSFDC: ' + jsonStr);
        dList.add(jsonStr);
    }

    public static Boolean isSandbox(){
        Organization org = [select id,IsSandbox from Organization];
        return org.IsSandbox;
    }

    public static Boolean isNull(Date dateStr){
        if(dateStr == null){
            return true;
        }
        return false;
    }
    /***********************************************************************************/
    /**
     * 일자를 일시로 변환
     * hour, day customize
     * @param convDate
     * @param hours
     * @param days
     * @return Datetime
     * @author lsol927
     * @createdate 20161128
     */
    public static Datetime convDateToDatetime(Date convDate, Integer hours, Integer days) {
        return Datetime.newInstanceGMT(convDate, Time.NewInstance(0,0,0,0)).addHours(hours).addDays(days);
    }
    /**
     * 일자를 일시로 변환
     * hour customize
     * @param convDate
     * @param hours
     * @return Datetime
     * @author lsol927
     * @createdate 20161128
     */
    public static Datetime convDateToDatetime(Date convDate, Integer hours) {
        return Datetime.newInstanceGMT(convDate, Time.NewInstance(0,0,0,0)).addHours(hours);
    }
    /**
     * 일자를 일시로 변환 GMT 0
     * @param convDate
     * @return Datetime
     * @author lsol927
     * @createdate 20161128
     */
    public static Datetime convDateToDatetime(Date convDate) {
        return Datetime.newInstanceGMT(convDate, Time.NewInstance(0,0,0,0));
    }
    

    public static Datetime convStrToDatetime(String convDateStr, String convTimeStr, Boolean endTimeChk) {
        Date convDate = convStrToDate(convDateStr);
        
        String toHourStr   = convTimeStr.substring(0,2);
        String toMinuteStr = convTimeStr.substring(2,4);

        Integer tosecond      = 0;
        Integer toMilliSecond = 0;

        //if (endTimeChk) {
            //tosecond = 59;
            //toMilliSecond = 999;
        //}
        Integer convHour   = Integer.valueOf(toHourStr  );
        Integer convMinute = Integer.valueOf(toMinuteStr);
        
        return Datetime.newInstanceGMT(convDate, Time.NewInstance(convHour,convMinute,tosecond,toMilliSecond));
    }
    
    /* 기능확장으로 인한 주석처리 (2019.07.19 @ldb3100)
    public static Datetime convStrToDatetime(String convDateStr) {
        Date convDate = convStrToDate(convDateStr);
        
        return Datetime.newInstanceGMT(convDate, Time.NewInstance(0,0,0,0));
    }
    */
    
    /**
     * String 날짜 -> Datetime 형변환
     * @param strDate
     * @return Datetime
     * @author ldb3100
     * @createdate 20190717
     */
    public static Datetime convStrToDatetime(String strDate) {
        DateTime returnDt;
        Integer strLength = strDate.length();
        
        if(strLength == 8){ // YYYYMMDD 
            returnDt = Datetime.newInstanceGMT(Integer.valueOf(strDate.left(4)), Integer.valueOf(strDate.substring(4, 6)), Integer.valueOf(strDate.substring(6, 8)), 0, 0, 0);
        }
        if(strLength == 10){ // YYYYMMDDHH
            returnDt = Datetime.newInstanceGMT(Integer.valueOf(strDate.left(4)), Integer.valueOf(strDate.substring(4, 6)), Integer.valueOf(strDate.substring(6, 8)), Integer.valueOf(strDate.substring(8, 10)), 0, 0);
        }
        if(strLength == 12){ // YYYYMMDDHHmm
            returnDt = Datetime.newInstanceGMT(Integer.valueOf(strDate.left(4)), Integer.valueOf(strDate.substring(4, 6)), Integer.valueOf(strDate.substring(6, 8)), Integer.valueOf(strDate.substring(8, 10)), Integer.valueOf(strDate.substring(10, 12)), 0);
        }
        if(strLength == 14){ // YYYYMMDDHHmmss
            returnDt = Datetime.newInstanceGMT(Integer.valueOf(strDate.left(4)), Integer.valueOf(strDate.substring(4, 6)), Integer.valueOf(strDate.substring(6, 8)), Integer.valueOf(strDate.substring(8, 10)), Integer.valueOf(strDate.substring(10, 12)), Integer.valueOf(strDate.right(2)));
        }
    
        return returnDt;
    }

    /**
     * 암호화
     * @param algorithm
     * @param iv
     * @param keyStr
     * @param value
     * @return String
     * @author lsol927
     * @createdate 20190620
     */
    public static String cryptoEncrypt(String algorithm, String iv, String keyStr, String value) {
        Blob initializationVector = Blob.valueOf(iv    );
        Blob key                  = Blob.valueOf(keyStr);
        Blob cipherText           = Blob.valueOf(value );
        Blob encrypted            = Crypto.encrypt(algorithm, key, initializationVector, cipherText);
        
        return EncodingUtil.base64Encode(encrypted);
    } 
    
    /**
     * 복호화
     * @param algorithm
     * @param iv
     * @param keyStr
     * @param value
     * @return String
     * @author lsol927
     * @createdate 20190620
     */
    public static String cryptoDecrypt(String algorithm, String iv, String keyStr, String value) {
        Blob initializationVector = Blob.valueOf(iv    );
        Blob key                  = Blob.valueOf(keyStr);
        Blob cipherText           = EncodingUtil.base64Decode(value);        
        Blob decrypted            = Crypto.decrypt(algorithm, key, initializationVector, cipherText);
        
        return decrypted.toString();
    } 
 
    public static String convertEmpty(Object value) {
        String result = null;
        String valueStr = String.valueof(value);
        
        if(String.isEmpty(valueStr)) {
            result = '';
        } else {
            result = valueStr;
        }
        
        return result;
    }

    /**
     * IF External ID로 파일 정보 가져오기.
     */
    public static List<Blob> getAttachBody(String ifInfo) {
        List<Blob> attachBody = new List<Blob>();
        
        String ifInfoQuery = 'SELECT Id, IF_ID__c, URL__c, CYCLE__c, FROM__c, TO__c, TITLE__c  FROM Notiforce_IF_INFO__c WHERE IF_ID__c = :ifInfo LIMIT 1';
        
        List<Notiforce_IF_INFO__c> ifInfoList = DataBase.query(ifInfoQuery);

        if( ifInfoList.size() > 0 ) {
            integer infoSize = 0;
  /*          
            for( Notiforce_IF_INFO__c info : ifInfoList ) {
                System.debug('Notiforce_IF_INFO__c : ' + infoSize + ' - ' + info);
                
                List<Notiforce_IF_LOG__c> ifLogList = [SELECT Id FROM Notiforce_IF_LOG__c WHERE Notiforce_IF_INFO__c = :info.Id LIMIT 1];
                
                if( ifLogList.size() > 0 ) {
                    integer logSize = 0;
                    
                    for( Notiforce_IF_LOG__c log : ifLogList ) {
                        System.debug('Notiforce_IF_LOG__c : ' + logSize + ' - ' + log);
                        
                        List<Attachment> attachList = [SELECT Id, Body FROM Attachment WHERE ParentId = :log.Id LIMIT 1];
                        
                        if( attachList.size() > 0 ) {
                            integer attachSize = 0;
                            
                            for( Attachment attach : attachList ) {
                                System.debug('Attachment : ' + attachSize + ' - ' + attach.Id);
                                
                                attachBody.add(attach.Body);
                                attachSize++;
                            }
                        }
                        logSize++;
                    }
                }   
                infoSize++;
            }
     */
        }
        
        return attachBody;
    }
    
}