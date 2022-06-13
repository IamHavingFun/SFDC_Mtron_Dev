public class MyAccountController {
    // Holds a reference to the account associated with the page controller
    private final Account acct;

    // Hold the username of a static Tableau username as a default
    //private static final String DEFAULT_TABLEAU_USERNAME = 'standard_user1';
    //private static final String DEFAULT_TABLEAU_USERNAME = 'corea2u@lsmtron.ps';
    private static final String DEFAULT_TABLEAU_USERNAME = userInfo.getusername();


    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public MyAccountController(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
        init();
    }

    //Initializes the controller.
    public MyAccountController() {
        this.acct = null;
        init();
    }

    // Load the tableau username into a static at page load since this won't change
    private void init() {
    }

    // This is the method that actually determines which field you want to use as the
    // source of the mapping to a Tableau user
    // In our example we use a static string "sfUser" as the string to map.
    private String myCustomFieldMapper() {
        // This customer written class does the "work" need to map and get a Tableau username
        // In our example we use a static string "sfUser" as the string to map.
        return DEFAULT_TABLEAU_USERNAME;
    }

    /**
    * Gets the signed identity; always want to generate this in a getter since the constructor
    * only gets called on original page load and timestamp will skew
    */
    public String getSignedIdentity() {
        String signedIdentity = TableauSparklerUtilities.generateSignedIdentity(this.myCustomFieldMapper());
        return signedIdentity;
    }
}