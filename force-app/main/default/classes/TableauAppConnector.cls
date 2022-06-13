/**
 * Created by ms on 2020-05-15.
 */

public with sharing class TableauAppConnector {

    private static final String DEFAULT_TABLEAU_USERNAME = userInfo.getusername();

    /**
     * @description init method
     *
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static String init() {
        String signedIdentity = null;
        if(!Test.isRunningTest()) signedIdentity = TableauSparklerUtilities.generateSignedIdentity(DEFAULT_TABLEAU_USERNAME);
        return  signedIdentity;
    }

}