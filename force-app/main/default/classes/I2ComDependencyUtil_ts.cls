@IsTest
private class I2ComDependencyUtil_ts {
    @IsTest
    static void testBehavior() {
        I2ComDependencyUtil.getDependentOptions('Product2', 'ProductType__c', 'Series__c');
        I2ComDependencyUtil.getDependentPickListOptions('Product2', 'ProductType__c', 'Series__c', null, true, true);

        I2ComDependencyUtil.TPicklistEntry tPicklistEntry = new I2ComDependencyUtil.TPicklistEntry();
        System.assertEquals(tPicklistEntry.active, null);
        System.assertEquals(tPicklistEntry.defaultValue, null);
    }
}