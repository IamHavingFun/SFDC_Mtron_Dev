/**
 * Created by
  * +on 2021-04-12.
 */

@IsTest
private class LsMSalesLeaseInspectionVO_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesLeaseInspectionVO lsMSalesLeaseInspectionVO = new LsMSalesLeaseInspectionVO();

        System.assertNotEquals(new LsMSalesLeaseInspectionVO.BizData(), lsMSalesLeaseInspectionVO.bizData);
        System.assertEquals(null, lsMSalesLeaseInspectionVO.setData);

        lsMSalesLeaseInspectionVO.bizData = new LsMSalesLeaseInspectionVO.BizData();
        System.assertEquals(null, lsMSalesLeaseInspectionVO.bizData.leaseInspectionReport);
        System.assertEquals(null, lsMSalesLeaseInspectionVO.bizData.contract);

        lsMSalesLeaseInspectionVO.setData = new LsMSalesLeaseInspectionVO.SetData();
        System.assertEquals(null, lsMSalesLeaseInspectionVO.setData.targetContracts);
        System.assertEquals(null, lsMSalesLeaseInspectionVO.setData.noContractMessage);
    }
}