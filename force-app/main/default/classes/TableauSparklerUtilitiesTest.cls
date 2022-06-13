@isTest
public class TableauSparklerUtilitiesTest {
    @testSetup static void setupDefaultCustomSetting() {
        TableauSparklerConsumerSecret__c setting = new TableauSparklerConsumerSecret__c();
        setting.Name = 'defaultSecret';
        setting.SecretValue__c = '_default_secret_';
        insert setting;
    }
    
    /* ------------ Add - S -----------*/
    @isTest static void testGetSignedIdentity() {
        Test.startTest();

        String expected = 'ey';
        MyAccountController mac = new MyAccountController();

        String actual = mac.getSignedIdentity().substring(0,2) ;
        System.assertEquals(expected, actual);

        Test.stopTest();
    }
    /* ------------ Add - S -----------*/
    
    @isTest static void testSerializeDateTimeToUtcFormat() {
        Test.startTest();

        String expected = '2016-01-08T18:06:45Z';

        Datetime dt = Datetime.newInstanceGmt(2016, 1, 8, 18, 6, 45);
        String actual = TableauSparklerUtilities.serializeDateTimeToUtcFormat(dt);

        System.assertEquals(expected, actual);

        Test.stopTest();
    }

    @isTest static void testSerializeUserIdentityToJson_NoFieldIsEmpty() {
        Test.startTest();

        String expected = '{"userName":"user","timestamp":"2016-01-08T18:06:45Z","siteId":"site"}';

        String actual = TableauSparklerUtilities.serializeUserIdentityToJson('user', 'site', '2016-01-08T18:06:45Z');

        Test.stopTest();

        System.assertEquals(expected, actual);
    }

    @isTest static void testSerializeUserIdentityToJson_UserNameIsEmpty() {
        Test.startTest();

        String expected = '{"userName":"","timestamp":"2016-01-08T18:06:45Z","siteId":"site"}';

        String actual = TableauSparklerUtilities.serializeUserIdentityToJson('', 'site', '2016-01-08T18:06:45Z');

        Test.stopTest();

        System.assertEquals(expected, actual);
    }

    @isTest static void testSerializeUserIdentityToJson_UserNameIsNull() {
        Test.startTest();

        String expected = '{"userName":null,"timestamp":"2016-01-08T18:06:45Z","siteId":"site"}';
        String actual = TableauSparklerUtilities.serializeUserIdentityToJson(null, 'site', '2016-01-08T18:06:45Z');

        Test.stopTest();

        System.assertEquals(expected, actual);
    }

    @isTest static void testreadTableauSparklerConsumerSecret_ReadNotExistedSecret() {
        Test.startTest();

        try {
            TableauSparklerUtilities.readTableauSparklerConsumerSecret('__Not_Existed_Secret__');
        }
        catch(TableauSparklerUtilities.TableauSparklerUtilitiesException e) {
            System.assertEquals('Cannot find record named as __Not_Existed_Secret__ in custom setting "TableauSparklerConsumerSecret".', e.getMessage());
            return;
        }

        System.assert(false);
        Test.stopTest();
    }

    @isTest static void testreadTableauSparklerConsumerSecret_ReadExistingSecret() {
        Test.startTest();

        String testSecretName = 'testSecret';
        String testSecretValue = '_testSecret_';

        TableauSparklerConsumerSecret__c setting = new TableauSparklerConsumerSecret__c();
        setting.Name = testSecretName;
        setting.SecretValue__c = testSecretValue;
        insert setting;

        String actual = TableauSparklerUtilities.readTableauSparklerConsumerSecret(testSecretName);

        System.assertEquals(testSecretValue, actual);

        Test.stopTest();
    }

    @isTest static void testInnerGenerateSignedIdentity_UserNameIsNull() {
        Test.startTest();

        try {
            TableauSparklerUtilities.innerGenerateSignedIdentity(null, 'site', 'timestamp', 'secret');
        }
        catch(TableauSparklerUtilities.TableauSparklerUtilitiesException e) {
            System.assertEquals('userName cannot be empty.', e.getMessage());
            return;
        }

        System.assert(false);

        Test.stopTest();
    }

    @isTest static void testInnerGenerateSignedIdentity_UserNameIsEmpty() {
        Test.startTest();

        try {
            TableauSparklerUtilities.innerGenerateSignedIdentity('', 'site', 'timestamp', 'secret');
        }
        catch(TableauSparklerUtilities.TableauSparklerUtilitiesException e) {
            System.assertEquals('userName cannot be empty.', e.getMessage());
            return;
        }

        System.assert(false);

        Test.stopTest();
    }

    @isTest static void testInnerGenerateSignedIdentity_TimestampIsNull() {
        Test.startTest();

        try {
            TableauSparklerUtilities.innerGenerateSignedIdentity('user', 'site', null, 'secret');
        }
        catch(TableauSparklerUtilities.TableauSparklerUtilitiesException e) {
            System.assertEquals('timestamp cannot be empty.', e.getMessage());
            return;
        }

        System.assert(false);

        Test.stopTest();
    }

    @isTest static void testInnerGenerateSignedIdentity_TimestampIsEmpty() {
        Test.startTest();

        try {
            TableauSparklerUtilities.innerGenerateSignedIdentity('user', 'site', '', 'secret');
        }
        catch(TableauSparklerUtilities.TableauSparklerUtilitiesException e) {
            System.assertEquals('timestamp cannot be empty.', e.getMessage());
            return;
        }

        System.assert(false);

        Test.stopTest();
    }

    @isTest static void testInnerGenerateSignedIdentity_SecretIsNull() {
        Test.startTest();

        try {
            TableauSparklerUtilities.innerGenerateSignedIdentity('user', 'site', 'timestamp', null);
        }
        catch(TableauSparklerUtilities.TableauSparklerUtilitiesException e) {
            System.assertEquals('secret cannot be empty.', e.getMessage());
            return;
        }

        System.assert(false);

        Test.stopTest();
    }

    @isTest static void testInnerGenerateSignedIdentity_SecretIsEmpty() {
        Test.startTest();

        try {
            TableauSparklerUtilities.innerGenerateSignedIdentity('user', 'site', 'timestamp', '');
        }
        catch(TableauSparklerUtilities.TableauSparklerUtilitiesException e) {
            System.assertEquals('secret cannot be empty.', e.getMessage());
            return;
        }

        System.assert(false);

        Test.stopTest();
    }

    @isTest static void testInnerGenerateSignedIdentity_SiteIdIsNull() {
        Test.startTest();

        String expected = 'eyJ1c2VyTmFtZSI6InVzZXIiLCJ0aW1lc3RhbXAiOiIyMDE2LTAxLTA4VDE4OjA2OjQ1WiIsInNpdGVJZCI6bnVsbH0=.auADyjrV7+x51nqdYGFdBh4N29jdAhCvxc3TVRSMsbM=';

        String actual = TableauSparklerUtilities.innerGenerateSignedIdentity('user', null, '2016-01-08T18:06:45Z', '_secret_value_');

        System.assertEquals(expected, actual);

        Test.stopTest();
    }

    @isTest static void testInnerGenerateSignedIdentity_SiteIdIsEmpty() {
        Test.startTest();

        String expected = 'eyJ1c2VyTmFtZSI6InVzZXIiLCJ0aW1lc3RhbXAiOiIyMDE2LTAxLTA4VDE4OjA2OjQ1WiIsInNpdGVJZCI6IiJ9.HSKXR21QQI8HsjmJQCEeo4l45/JXZ1qmQFP+eoHgM9w=';

        String actual = TableauSparklerUtilities.innerGenerateSignedIdentity('user', '', '2016-01-08T18:06:45Z', '_secret_value_');

        System.assertEquals(expected, actual);

        Test.stopTest();
    }

    @isTest static void testInnerGenerateSignedIdentity_NoFieldNotEmpty() {
        Test.startTest();

        String expected = 'eyJ1c2VyTmFtZSI6InVzZXIiLCJ0aW1lc3RhbXAiOiIyMDE2LTAxLTA4VDE4OjA2OjQ1WiIsInNpdGVJZCI6InNpdGUifQ==.1XRvGijeN3dvc4yQQd4Q6lDLh8Gf3UhXnhIl1VR0nds=';

        String actual = TableauSparklerUtilities.innerGenerateSignedIdentity('user', 'site', '2016-01-08T18:06:45Z', '_secret_value_');

        System.assertEquals(expected, actual);

        Test.stopTest();
    }
}