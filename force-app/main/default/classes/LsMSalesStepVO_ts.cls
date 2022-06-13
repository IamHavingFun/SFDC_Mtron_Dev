@IsTest
private class LsMSalesStepVO_ts {
    class TestWrapper implements LsMSalesStepVO {}

    @IsTest
    static void testBehavior() {
        System.assertNotEquals((LsMSalesStepVO)new TestWrapper(), null);
    }
}