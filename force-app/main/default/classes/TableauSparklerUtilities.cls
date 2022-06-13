/**
 * Utility methods provided to Sparkler tenant developer
 */
public class TableauSparklerUtilities {
    /**
     * TableauSparklerUtilities specific exception
     */
    public class TableauSparklerUtilitiesException extends Exception { }

    private class UserIdentity {
        String userName;
        String siteId;
        String timestamp;

        UserIdentity(final String userName, final String siteId, final String timestamp) {
            this.userName = userName;
            this.siteId = siteId;
            this.timestamp = timestamp;
        }
    }

    @TestVisible private static String serializeDateTimeToUtcFormat(final Datetime dt) {
        return dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'UTC');
    }

    @TestVisible private static String serializeUserIdentityToJson(final String userName, final String siteId, final String timestamp) {
        UserIdentity payLoad = new UserIdentity(userName, siteId, timestamp);
        return JSON.serialize(payLoad);
    }

    @TestVisible private static String readTableauSparklerConsumerSecret(final String secretName) {
        TableauSparklerConsumerSecret__c setting = TableauSparklerConsumerSecret__c.getInstance(secretName);

        if (setting == null) {
            String msg = String.format('Cannot find record named as {0} in custom setting "TableauSparklerConsumerSecret".', new String[] {secretName});
            System.debug(msg);
            throw new TableauSparklerUtilitiesException(msg);
        }

        // SecretValue__c field is configured as a required text field, so its value won't be empty string
        return setting.SecretValue__c;
    }

    @TestVisible private static String innerGenerateSignedIdentity(final String userName, final String siteId, final String timestamp, final String secret) {
        if (String.isEmpty(userName)) {
            String msg = 'userName cannot be empty.';
            System.debug(msg);
            throw new TableauSparklerUtilitiesException(msg);
        }

        if (String.isEmpty(timestamp)) {
            String msg = 'timestamp cannot be empty.';
            System.debug(msg);
            throw new TableauSparklerUtilitiesException(msg);
        }

        if (String.isEmpty(secret)) {
            String msg = 'secret cannot be empty.';
            System.debug(msg);
            throw new TableauSparklerUtilitiesException(msg);
        }

        String jsonUserIdentity = TableauSparklerUtilities.serializeUserIdentityToJson(userName, siteId, timestamp);
        String base64UserIdentity = EncodingUtil.base64Encode(Blob.valueOf(jsonUserIdentity));
        Blob signature = crypto.generateMac('hmacSHA256', Blob.valueOf(base64UserIdentity), Blob.valueOf(secret));

        return base64UserIdentity + '.' + EncodingUtil.base64Encode(signature);
    }

    private final static String defaultSecret = TableauSparklerUtilities.readTableauSparklerConsumerSecret('defaultSecret');

    /**
     * Generate a signed identity that is consist of a Tableau user name and a Tableau Server site id.
     *
     * @param userName The Tableau Server user name needed to be signed.
     * @param siteId Tableau site ID needed to be signed.
     * @return Signed identity information in base64 format.
     */
    public static String generateSignedIdentity(final String userName, final string siteId) {
        // Datetime.now() returns the current Datetime based on a GMT calendar
        // according to Salesforce Apex Code Developer's Guide (Version 35.0, Winter'16)
        String nowUTC = TableauSparklerUtilities.serializeDateTimeToUtcFormat(Datetime.now());
        return TableauSparklerUtilities.innerGenerateSignedIdentity(userName, siteId, nowUTC, defaultSecret);
    }

    /**
     * Generate a signed identity that is consist of a Tableau user name.
     *
     * @param userName The Tableau Server user name needed to be signed.
     * @return Signed identity information in base64 format.
     */
    public static String generateSignedIdentity(final String userName) {
        return generateSignedIdentity(userName, null);
    }
}