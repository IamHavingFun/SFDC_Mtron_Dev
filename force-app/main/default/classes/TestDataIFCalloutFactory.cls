/****************************************************************************************
  * @filename      : TestDataIFCalloutFactory
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-07-20
  * @group         : 
  * @group-content : 
  * @description   : IF Callout 관련 세팅 및 데이터 생성 Factory
  * @tester        : TestDataIFCalloutFactory_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-07-20         i2max          Create
****************************************************************************************/
@IsTest
public class TestDataIFCalloutFactory {

    /**
     * I/F Static Value 객체 생성
     *
     * @return IfStaticValue__c
     */
    public static IfStaticValue__c createIfStaticValue() {
        IfStaticValue__c staticValue = new IfStaticValue__c();

        staticValue.Org_URL__c              = 'https://salesforce.com';
        staticValue.oauth_client_id__c      = 'client_id';
        staticValue.oauth_client_secret__c  = 'client_secret';
        staticValue.oauth_username__c       = 'salesforce@salesforce.com';
        staticValue.oauth_password__c       = 'salesforce';
        staticValue.ENCRYPT_ALGORITHM__c    = 'AES256';
        staticValue.dihAuthName__c          = 'dih';
        staticValue.dihAuthPwd__c           = 'dih_password';
        staticValue.dihAesKey__c            = EncodingUtil.base64Encode(Crypto.generateAesKey(192));
//        staticValue.dihAesKey__c            = (String) Crypto.generateAesKey(128);
        staticValue.dihAesInitVector__c     = '1234567890135670';
        staticValue.PRIVATE_KEY__c          = 'private_key11';
        staticValue.API_KEY__c              = 'api_key12345';
        staticValue.TOKEN_URL__c            = 'http://lwstest.lsmtron.com/SeInterface/services/auth/token';

        return staticValue;
    }

    /**
     * I/F 정보 데이터 생성
     *
     * @return IF_INFO__c
     */
    public static IF_INFO__c createIFInfo() {
        return new IF_INFO__c(
            IF_ID__c = 'IF_KR_SE_PLM_0037',
            URL__c = '/api/dev/IF_KR_SE_PLM_0037.json',
            CYCLE__c = 'batch',
            FROM__c = 'SE',
            TO__c = 'PLM',
            TITLE__c = 'SE에서 PLM으로 PLM 호출을 한다.',
            FORCE_LOGGING__c = true
        );
    }

}