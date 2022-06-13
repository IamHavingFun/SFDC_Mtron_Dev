/****************************************************************************************
 * @filename      : InspectionConfirmationPdfController_ts
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-07-09 오후 02:04
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright ⓒ I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-07-09 오후 02:04      i2max_my.Seo         Create
 ****************************************************************************************/

@IsTest
private class InspectionConfirmationPdfController_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataBizFactory.init();
        
        PDI__c newPdi = TestDataBizFactory.basePDI;
        newPdi.Action__c = '가나다마아가나다마아가나다마아가나다마아가나다마아가나다마아가나다마아가나 다마아가나다마아가나다마아가나다마아가나다마아';
        update newPdi;
        ApexPages.currentPage().getParameters().put('pdiId',newPdi.Id);


        InspectionConfirmationPdfController controller = new InspectionConfirmationPdfController();

    }
}