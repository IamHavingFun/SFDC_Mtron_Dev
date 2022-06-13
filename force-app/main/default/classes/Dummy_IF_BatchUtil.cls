/****************************************************************************************
  * @filename      : Dummy_IF_BatchUtil
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-20
  * @group         : 
  * @group-content : 
  * @description   : Dummy IF Batch와 관련된 Util Method를 정의함.
  * @tester        : Dummy_IF_BatchUtil_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-20      i2max          Create
****************************************************************************************/
public inherited sharing class Dummy_IF_BatchUtil {

    /**
     *
     * Interface 데이터중 날짜는 String Type임.
     *
     * yyyyMMdd ㅎ여식의 8자리 Date 문자열을 Date 로 변환
     * ex: 20200401
     * yyyy-MM-dd 형식의 10자리 Date 문자열을 Date 로 변환
     * ex: 2020-04-01
     * yyyy/MM/dd 형식의 10자리 Date 문자열을 Date 로 변환
     * ex: 2020/04/01
     * yyyy.MM.dd 형식의 10자리 Date 문자열을 Date 로 변환
     * ex: 2020.04.01
     *
     * @param strDate : yyyyMMdd 형식의 Date 문자열
     *
     * @return : Date
     */
    public static Date getIFDate(final String strDate) {
        if(String.isBlank(strDate)) return null;

        String targetStrDate = strDate;
        /*
         * ================================================================
         * -, /, . 으로 구분되는 날짜형식을 찾음
         * ================================================================
         */
        if(Pattern.compile('[-/.]').matcher(strDate).find()) {
            targetStrDate = strDate.replaceAll('[-/.]', '');
        }

        //============================================================================
        // 0000-00-00 으로 들어오는 경우 null로 리턴
        //============================================================================
        if(targetStrDate == '00000000') {
            return null;
        }

        Matcher m = Pattern.compile('(\\d{4})(\\d{2})(\\d{2})').matcher(targetStrDate);
        m.find();
        final Integer year = Integer.valueOf(m.group(1)),
            month = Integer.valueOf(m.group(2)),
            day = Integer.valueOf(m.group(3));
        targetStrDate = year + '-' + month + '-' + day;

        if(year < 1970 || year > 4000) {
            throw new DummyValidException('날짜형식 Valid Error 발생. 년도 체크. 날짜 스트링 : [' + targetStrDate + ']');
        }

        return Date.valueOf(targetStrDate);
    }

    /**
     * @description 문자열로 들어온 datetime을 Datetime fieldType으로 return.
     * 기본적인 param 형태는 yyyyMMDDhhmmss(ex : 20200506112020) or
     * yyyyMMDD hhmmss(ex : 20200506 112020)이나,
     * -, /. ., :의 특수 기호와 함께 넘겨도 처리함. (ex : 2020-05-06 11:20:20 등)
     *
     * @param strDateTime Datetime 문자열(20200101 121212)
     *
     * @return Datetime
     */
    public static Datetime getIFDateTime(final String strDateTime) {
        if(String.isBlank(strDateTime)) return null;

        String strDt = strDateTime;
        String targetStrDate;

        // 들어 올 수 있는 특수 문자를 전부 제거 후, 공통 로직 수행 하고 정제.
        if(Pattern.compile('[-/.: ]').matcher(strDt).find()) {
            strDt = strDt.replaceAll(' ', '').replaceAll('/', '').replaceAll('\\.', '').replaceAll(':','').replaceAll('-','');
        }

        // 날짜 필드만 들어 왔을 경우, 뒤에 시간 필드는 000000으로 추가.
        if(strDt.length() == 8) {
            strDt = strDt + '000000';
        }

        Matcher m = Pattern.compile('(\\d{4})(\\d{2})(\\d{2})(\\d{2})(\\d{2})(\\d{2})').matcher(strDt);
        m.find();

        final Integer year = Integer.valueOf(m.group(1)),
            month = Integer.valueOf(m.group(2)),
            day = Integer.valueOf(m.group(3)),
            hour = Integer.valueOf(m.group(4)),
            min = Integer.valueOf(m.group(5)),
            sec = Integer.valueOf(m.group(6));

        targetStrDate = year + '-' + month + '-' + day + ' ' + hour + ':' + min + ':' + sec;

        if(year < 1970 || year > 4000) {
            throw new DummyValidException('날짜형식 Valid Error 발생. 년도 체크. 날짜 스트링 : [' + targetStrDate + ']');
        }

        return Datetime.valueOf(targetStrDate);
    }

    /**
     * @description 대리점과 농협 관납 계정의 Owner를 구한다.
     *                전부 대리점 주로 설정.
     *
     * @param interfaceId 해당 배치의 dummy data query에 조건이 되는 interfaceId__c
     * @param erpCodeList Account의 ERPCode에 해당하는 CodeList.
     *
     * @return Map<String, String> => Map<erpCode:넘어온 코드, User Id>
     */
    public static Map<String, Id> getRecordOwnder(String interfaceId, Set<String> erpCodeList) {
        Map<String, Account> accountMap = new Map<String, Account>();
        for(Account r : [SELECT Id, OwnerId, ERPCode__c, Dealer__r.ERPCode__c, CustomerType__c FROM Account WHERE ERPCode__c IN :erpCodeList]) {
            accountMap.put(r.ERPCode__c, r);
            if(String.isEmpty(r.Dealer__r.ERPCode__c) == false) erpCodeList.add(r.Dealer__r.ERPCode__c);    //TODO : 데이터 없는 경우는 오류다..
        }
        /**
         * TODO : 사용자가 InActive 되면 여기 에러다.^^;
         *        사용자 Field에 ERPCode__c를 추가 해서 관리 해야 겠다.
         */
        Map<String, Id> userMap = new Map<String, Id>();
        for(User u : [
                SELECT Id, Contact.Account.ERPCode__c
                FROM User
                WHERE Contact.Account.ERPCode__c IN :erpCodeList
                AND Contact.DealerRole__c = '대표'
                AND IsActive = TRUE
        ]) {
            userMap.put(u.Contact.Account.ERPCode__c, u.Id);
        }
      //TODO : 실 운영시 사용..
        Map<String, Id> accountOwnerMap = new Map<String, Id>();
        Account account;
        for(String key : erpCodeList) {
            if(accountMap.containsKey(key)) {
                account = accountMap.get(key);
                if(account.CustomerType__c == '대리점') {
                    accountOwnerMap.put(key, userMap.containsKey(key) ? userMap.get(key) : UserInfo.getUserId());
                } else {
                    // 농협/관납
                    if(DEALER_OWNER_IF.contains(interfaceId)) {
                        //accountOwnerMap.put(key, userMap.get(account.Dealer__r.ERPCode__c));     // 농협/관납의 대리점의 대리점주
                        accountOwnerMap.put(key, userMap.containsKey(account.Dealer__r.ERPCode__c) ? userMap.get(account.Dealer__r.ERPCode__c) : UserInfo.getUserId());   // 농협/관납의 대리점의 대리점주
                    } else {
                        accountOwnerMap.put(key, account.OwnerId);                               // 농협/관납의 소유자
                    }
                }

            } else {
                //accountOwnerMap.put(key, null);     // 소유주 못 찾았다.
                accountOwnerMap.put(key, UserInfo.getUserId());     // TODO : 임시로 배치 사용자 설정
            }
        }

        // TODO : 1차 오픈시만 사용한다.
//        Map<String, Id> accountOwnerMap = new Map<String, Id>();
//        Account account;
//        for(String key : erpCodeList) {
//            if (accountMap.containsKey(key)) {
//                account = accountMap.get(key);
//                accountOwnerMap.put(key, account.OwnerId);
//            } else {
//                accountOwnerMap.put(key, UserInfo.getUserId());     // TODO : 임시로 배치 사용자 설정
//            }
//        }
        return accountOwnerMap;
    }

    /**
     * @description 해당 AccountId에 맞는 UserId를 Map형태로 return.
     *
     * @param accountIdSet : Set<String> => AccountId Set
     *
     * @return Map<String,Id> => Map<Contact.AccountId, User.Id>
     */
    public static Map<String, Id> getDealerOwner(Set<String> accountIdSet) {
        Map<String, Id> returnMap = new Map<String, Id>();

        for(User u : [
                SELECT Id, Contact.AccountId
                FROM User
                WHERE Contact.AccountId IN :accountIdSet
                AND Contact.DealerRole__c = '대표'
                AND IsActive = TRUE
        ]) {
            returnMap.put(u.Contact.AccountId, u.Id);
        }

        System.debug('@@@@@@@@@@@@@ returnMap : ' + returnMap);

        // 해당 AccountId에 해당하는 UserId가 없을 경우, Account의 OwnerId를 return.
        for(Account acc : [SELECT Id, OwnerId FROM Account WHERE Id = :accountIdSet]) {
            if(!returnMap.containsKey(acc.Id)) returnMap.put(acc.Id, acc.OwnerId);
        }

        System.debug('@@@@@@@@@@@@@ retrunMap11111111 : ' + returnMap);

        return returnMap;
    }

    /**
     * 농협관납 데이터중 대리점주에게 소유자를 지정해야 하는 IF 목록
     * TODO : enum으로 해야 하나???
     */
    public static Set<String> DEALER_OWNER_IF = new Set<String>{'IF_KR_ERP_SE_0012'};

    /**
     * 배치 수행중 에러발생 메시지
     */
    public static String DUMMY_BATCH_ERROR_DML = 'DML 에러';

    /**
     * 배치 수행중 VALID 메시지
     */
    public static String DUMMY_BATCH_ERROR_VALID = '{0} 데이터 및 매핑 에러';


    public static SObject setDummyBatchResult(SObject dummy, List<Id> errorDummyids) {
        return setDummyBatchResult(new List<SObject>{dummy}, Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_DML, errorDummyids, null)[0];
    }

    public static SObject setDummyBatchResult(SObject dummy, final String batchErrorMessage, List<Id> errorDummyids) {
        return setDummyBatchResult(new List<SObject>{dummy}, batchErrorMessage, errorDummyids, null)[0];
    }

    /**
     * Dummy Record에 에러메시지 세팅
     *
     * @param dummy Dummy
     * @param batchErrorMessage errorMessage
     * @param errorDummyids ErrorDummy Ids
     * @param e Exception
     *
     * @return Dummy
     */
    public static SObject setDummyBatchResult(SObject dummy, final String batchErrorMessage, List<Id> errorDummyids, Exception e) {
        return setDummyBatchResult(new List<SObject>{dummy}, batchErrorMessage, errorDummyids, e)[0];
    }

    public static List<SObject> setDummyBatchResult(List<SObject> dummies, List<Id> errorDummyids) {
        return setDummyBatchResult(dummies, Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_DML, errorDummyids, null);
    }

    public static List<SObject> setDummyBatchResult(List<SObject> dummies, List<Id> errorDummyids, Exception e) {
        return setDummyBatchResult(dummies, Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_DML, errorDummyids, e);
    }

    public static List<SObject> setDummyBatchResult(List<SObject> dummies, final String batchErrorMessage, List<Id> errorDummyids) {
        return setDummyBatchResult(dummies, batchErrorMessage, errorDummyids, null);
    }

    public static List<SObject> setDummyBatchResult(List<SObject> dummies, final String batchErrorMessage, List<Id> errorDummyids, Exception e) {
        String errorMessage = batchErrorMessage;
        if(e != null) {
            errorMessage = errorMessage + ' : ' + e.getMessage();
        }

        for(SObject dummy : dummies) {
            dummy.put('isBatchCompleted__c', true);
            dummy.put('isBatchError__c', true);
            dummy.put('BatchErrorMessage__c', errorMessage);

            errorDummyids.add((Id)dummy.get('Id'));
        }
        return dummies;
    }

    /**
     * ERP 에서 중복건으로 들어오는 dummy 데이터중 각자의 로직으로 필터링 된 중복 dummy data를
     * 배치 수행 결과 일괄 처리
     * @param dummies 중복 dummies
     * @param messages ErrorMessage 저장 메시지
     *
     * @return List<SObject.
     */
    public static List<SObject> setDummyBatchDupResult(List<SObject> dummies, final String messages) {
        for(SObject dummy : dummies) {
            dummy.put('isBatchCompleted__c', true);
            dummy.put('isBatchError__c', false);
            dummy.put('BatchErrorMessage__c', messages);
        }
        return dummies;
    }

    public static List<SObject> setDummyBatchDupResult(List<SObject> dummies) {
        return setDummyBatchDupResult(dummies, '중복');
    }

    /**
     * 임시적으로 LPad 처리여부
     * ERPCode 및 ProduceCode 가 dummy에서 앞의 0이 제거된 상태로 들어옴.
     * Lpading 처리를 하여 임시적으로 데이터 비교함.
     * 2020-04-29 : Dummy Data에서 '0' 문자 lpad 하여 정상적으로 넘어옴
     * 따라서 false 처리 : 변경하지 말것
     */
    private static Boolean hasLpading = true;

    /**
     * erpCode를 lpad 하여 리턴 : 10자리
     *
     * @param erpCode ERPCode
     *
     * @return lpad ErpCode
     */
    public static String getErpCodeLpad(final String erpCode) {
        if(Test.isRunningTest()) return erpCode;
        return hasLpading ? (String.isNotBlank(erpCode) ? erpCode.leftPad(10, '0') : '') : erpCode;
    }

    /**
     * productCode를 lpad 하여 리턴 : 18자리
     *
     * @param productCode ProductCode
     *
     * @return lpad ProductCode
     */
    public static String getProductCodeLpad(final String productCode) {
        if(Test.isRunningTest()) return productCode;
        return hasLpading ? (String.isNotBlank(productCode) ? productCode.leftPad(18, '0') : '') : productCode;
    }

    /**
     * Dummy Batch Valid Exception
     */
    public class DummyValidException extends Exception {}


    /**
     * productCode를 기준으로 Map 리턴
     * Type__c 는 본체 기준
     * Select 필드는 필요시 추가바람.
     *
     * @return Product Code 기준 Map
     */
    public static Map<String, Product2> getTargetProduct2(final Boolean isAll) {
        Map<String, Product2> productsByProductCode = new Map<String, Product2>();
        String productCode;

        String query = 'SELECT' + '\n';
        query += 'Id, ProductCode, BaseModel__c, ProductType__c,' + '\n';
        query += 'Segment__c, Series__c, HorsePowerStandard__c,' + '\n';
        query += 'Option1__c,Option2__c,Option3__c,Option4__c,' + '\n';
        query += 'Name, OEMCompany__c' + '\n';
        query += 'FROM Product2' + '\n';
        query += (isAll ? '' : 'WHERE Type__c = \'본체\''+ '\n') + '\n';

        for(Product2 product : Database.query(query)) {
            productCode = product.ProductCode;
            if(String.isNotBlank(productCode) && !productsByProductCode.containsKey(productCode)) {
                productsByProductCode.put(productCode, product);
            }
        }

        return productsByProductCode;
    }

    public static Map<String, Product2> getTargetProduct2() {
        return Dummy_IF_BatchUtil.getTargetProduct2(false);
    }

    /**
     * batch에서 insert 혹은 udpate 해야 할 data인지 판단 하는 currencyCode set.
     */
    private static Set<String> correctCurrencySet = new Set<String>{
        'KRW'
    };

    /**
     * dummy에서 currencyCode를 넘겼을 때 해당 data가 에러 data인지 아닌지 체크 해주는 method.
     *
     * @param targetCurrency : ex) KRW 등...
     *
     * @return Boolean
     */
    public static Boolean isValidCurrency(String targetCurrency) {
        Boolean isTrueCurrency = false;

        if(String.isBlank(targetCurrency)) {
            targetCurrency = 'KRW';
        }

        if(correctCurrencySet.contains(targetCurrency.toUpperCase())) {
            isTrueCurrency = true;
        }

        return isTrueCurrency;
    }

    /**
     * 사용자의 User.EmployeeNumber(직원번호)를 기준으로 Map 리턴
     *
     * @return Product 직원번호 기준 Map
     */
    public static Map<String, User> getEmployeeNumber() {
        Map<String, User> usersByEmployeeNumber = new Map<String, User>();
        String employeeNumber;

        String query = 'SELECT' + '\n';
        query += 'Id, EmployeeNumber' + '\n';
        query += 'FROM User' + '\n';
        query += 'WHERE EmployeeNumber != NULL ' + '\n';

        for(User u : Database.query(query)) {
            employeeNumber = u.employeeNumber;
            if(String.isNotBlank(employeeNumber) && !UsersByEmployeeNumber.containsKey(employeeNumber)) {
                usersByEmployeeNumber.put(employeeNumber, u);
            }
        }

        return usersByEmployeeNumber;
    }

    /**
     * String으로 넘어 오는 값들을 Boolean으로 변환.
     * 유형 별로 추가 필요.
     * ex) Y / N or TRUE / FALSE
     *
     * @param strBoolean : String
     *
     * @return
     */
    public static Boolean getBooleanFromString(final String strBoolean) {
        Boolean isTrue;
        if(strBoolean == null) return null;
        Set<String> targetStrings = new Set<String>{
                'Y', 'N',
                'TRUE', 'FALSE'
        };

        if(targetStrings.contains(strBoolean.toUpperCase())) {
            if (strBoolean.toUpperCase().equals('Y') || strBoolean.toUpperCase().equals('TRUE')) {
                isTrue = true;
            } else {
                isTrue = false;
            }
        }

        return isTrue != null ? isTrue : null;
    }

    /**
     * 제품코드에 따른 본체/작업기/none 의 type 항목을 구함
     * @param productCode 제품코드
     *
     * @return 항목
     */
    public static String getTypeFromProductCode(final String productCode) {
        final String targetCode = productCode?.replaceAll('\\D', '');
        String returnType = null;

        if(String.isBlank(targetCode)) {
            return returnType;
        }

        final String targetChar = String.valueOf(Integer.valueOf(targetCode)).substring(0,1);

        switch on targetChar {
            when '1' {
                returnType = '본체';
            }
            when '3' {
                returnType = '작업기';
            }
        }

        return returnType;
    }

    public static Decimal getNumber(final String param) {
        if(String.isEmpty(param)) return null;
        String targetString = param.replaceAll(',', '');
        return Decimal.valueOf(targetString);
    }
}