/**
 * Created by ms on 2020-05-15.
 */

@IsTest
private class TableauAppConnector_ts {
    @IsTest
    static void testBehavior() {
        Test.startTest();
        TableauAppConnector.init();
        Test.stopTest();
    }

}