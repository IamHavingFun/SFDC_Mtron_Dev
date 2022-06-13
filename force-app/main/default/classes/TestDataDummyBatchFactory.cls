/****************************************************************************************
  * @filename      : TestDataDummyBatchFactory
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-23
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : TestDataDummyBatchFactory_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23         i2max          Create
****************************************************************************************/
@IsTest
public class TestDataDummyBatchFactory {
    public static void init(){}

    final private static String strDate = '20200501';
    final private static String strDateTime = '20200501123030';

    /**
     * @description IF Dummy 0001 Data.
     *
     * @param isInsert Boolean
     *
     * @return IF_KR_ERP_SE_0001__c
     */
    public static IF_KR_ERP_SE_0001__c creatErpSe0001(final Boolean isInsert) {
        IF_KR_ERP_SE_0001__c erpSe0001 = new IF_KR_ERP_SE_0001__c();

        erpSe0001.CustomerName__c           = '테스트';
        erpSe0001.ERPCode__c                = '001';
        erpSe0001.ErpKVGR2__c               = '71A';
        erpSe0001.BusinessOffice__c         = '001';
        erpSe0001.isDelete__c               = '';
        erpSe0001.InterfaceId__c            = 'IF_KR_ERP_SE_0001';
        erpSe0001.isBatchCompleted__c       = false;
        erpSe0001.isBatchError__c           = false;


        if(isInsert)    insert erpSe0001;

        return erpSe0001;
    }

    public static IF_KR_ERP_SE_0001__c erpSe0001dummyDataBase           {get;set;}
    public static IF_KR_ERP_SE_0001__c erpSe0001dummyDataSoldTo         {get;set;}
    public static IF_KR_ERP_SE_0001__c erpSe0001dummyDataAccount        {get;set;}

    static {
        if(erpSe0001dummyDataBase == null) {
            erpSe0001dummyDataBase = creatErpSe0001(true);
        }

        if(erpSe0001dummyDataSoldTo == null) {
            erpSe0001dummyDataSoldTo = erpSe0001dummyDataBase.clone(false, true);
            erpSe0001dummyDataSoldTo.InterfaceId__c = 'IF_KR_ERP_SE_0027';
            erpSe0001dummyDataSoldTo.ErpKUNNR__c    = '001';
            erpSe0001dummyDataSoldTo.ErpKUNN2__c    = '001';
            erpSe0001dummyDataSoldTo.ErpPARVW__c    = 'AG';


            insert erpSe0001dummyDataSoldTo;
        }

        if(erpSe0001dummyDataAccount == null) {
            erpSe0001dummyDataAccount = erpSe0001dummyDataBase.clone(false, true);
            erpSe0001dummyDataAccount.InterfaceId__c = 'IF_KR_ERP_SE_0002';

            insert erpSe0001dummyDataAccount;
        }
    }

    /**
     * @description IF Dummy 0003 Data.
     *
     * @param isInsert Boolean
     *
     * @return IF_KR_ERP_SE_0003__c
     */
    public static IF_KR_ERP_SE_0003__c creatErpSe0003(final Boolean isInsert) {
        IF_KR_ERP_SE_0003__c erpSe0003 = new IF_KR_ERP_SE_0003__c();

        erpSe0003.ErpVKORG__c               = '테스트';
        erpSe0003.ErpVTWEG__c               = '001';
        erpSe0003.ErpSPART__c               = '71A';
        erpSe0003.ProductCode__c            = '00000001';
        erpSe0003.ErpPriceType__c           = '';
        erpSe0003.UnitPrice__c              = 0;
        erpSe0003.WAERK__c                  = '';
        erpSe0003.KMEIN__c                  = '';
        erpSe0003.DATAB__c                  = '';
        erpSe0003.InterfaceId__c            = 'IF_KR_ERP_SE_0003';
        erpSe0003.isBatchCompleted__c       = false;
        erpSe0003.isBatchError__c           = false;

        if(isInsert)    insert erpSe0003;

        return erpSe0003;
    }

    public static IF_KR_ERP_SE_0003__c erpSe0003dummyDataBase               {get;set;}
    public static IF_KR_ERP_SE_0003__c erpSe0003dummyDataProduct            {get;set;}

    static {
        if(erpSe0003dummyDataBase == null) {
            erpSe0003dummyDataBase = creatErpSe0003(true);
        }

        if(erpSe0003dummyDataProduct == null) {
            erpSe0003dummyDataProduct = erpSe0003dummyDataBase.clone(false, true);
            erpSe0003dummyDataProduct.InterfaceId__c = 'IF_KR_ERP_SE_0028';
            erpSe0003dummyDataProduct.ProductCode__c = '00000001';

            insert erpSe0003dummyDataProduct;
        }
    }

    /**
     * @description IF Dummy 0004 Data.
     *
     * @param isInsert Boolean
     *
     * @return IF_KR_ERP_SE_0004__c
     */
    public static IF_KR_ERP_SE_0004__c creatErpSe0004(final Boolean isInsert) {
        IF_KR_ERP_SE_0004__c erpSe0004 = new IF_KR_ERP_SE_0004__c();

        erpSe0004.InterfaceId__c            = 'IF_KR_ERP_SE_0004';
        erpSe0004.isBatchCompleted__c       = false;
        erpSe0004.isBatchError__c           = false;
        erpSe0004.Stock__c                  = 10;
        erpSe0004.MachineNo__c              = '1234567890';


        if(isInsert)    insert erpSe0004;

        return erpSe0004;
    }

    public static IF_KR_ERP_SE_0004__c erpSe0004dummyDataBase           {get;set;}

    static {
        if(erpSe0004dummyDataBase == null) {
            erpSe0004dummyDataBase = creatErpSe0004(true);
        }
    }

    /**
     * @description IF Dummy 0006 Data.
     *
     * @param isInsert Boolean
     *
     * @return IF_KR_ERP_SE_0006__c
     */
    public static IF_KR_ERP_SE_0006__c creatErpSe0006(final Boolean isInsert) {
        IF_KR_ERP_SE_0006__c erpSe0006 = new IF_KR_ERP_SE_0006__c();

        erpSe0006.CustomerName__c           = '테스트';
        erpSe0006.CustomerCode__c           = '001';
        erpSe0006.isBatchCompleted__c       = false;
        erpSe0006.isBatchError__c           = false;
        erpSe0006.BatchErrorMessage__c      = '';
        erpSe0006.InterfaceId__c            = 'IF_KR_ERP_SE_0014';
        erpSe0006.PlanDate__c               = strDate;
        erpSe0006.BookkeepingDate__c        = strDate;
        erpSe0006.QueryDate__c              = strDate;
        erpSe0006.DateOfSales__c            = strDate;
        erpSe0006.RealCollectMoneyDay__c    = strDate;
        erpSe0006.ArStatement__c            = '22222';
        erpSe0006.MachineNo__c              = '1234567890';
        erpSe0006.CurrencyName__c           = 'KRW';
        erpSe0006.SalesDate__c              = '20200101';
        erpSe0006.ErpZUONR__c               = '1234567890';
        erpSe0006.ArAmtKRW__c               = 1000;
        erpSe0006.CollectMoneyKRW__c        = 100;

        if(isInsert)    insert erpSe0006;

        return erpSe0006;
    }


    public static IF_KR_ERP_SE_0006__c erpSe0006dummyDataBase           {get;set;}
    public static IF_KR_ERP_SE_0006__c erpSe0006dummyDataDealerStock    {get;set;}
    public static IF_KR_ERP_SE_0006__c erpSe0006dummyActualSales        {get;set;}
    public static IF_KR_ERP_SE_0006__c erpSe0006dummySalesPerformance   {get;set;}

    static {
        List<IF_KR_ERP_SE_0006__c> erpSe0006sList = new List<IF_KR_ERP_SE_0006__c>();

        if(erpSe0006dummyDataBase == null) {
            erpSe0006dummyDataBase = creatErpSe0006(false);

            erpSe0006sList.add(erpSe0006dummyDataBase);
        }

        if(erpSe0006dummyDataDealerStock == null) {
            erpSe0006dummyDataDealerStock = erpSe0006dummyDataBase.clone(false, true);
            erpSe0006dummyDataDealerStock.DataType__c       = 'I';
            erpSe0006dummyDataDealerStock.ProductCode__c    = '00000001';
            erpSe0006dummyDataDealerStock.InterfaceId__c    = 'IF_KR_ERP_SE_0006';
            erpSe0006dummyDataDealerStock.ErpCode__c        = '001';

            erpSe0006sList.add(erpSe0006dummyDataDealerStock);
        }

        if(erpSe0006dummyActualSales == null) {
            erpSe0006dummyActualSales = erpSe0006dummyDataBase.clone(false, true);
            erpSe0006dummyActualSales.DataType__c       = 'C';
            erpSe0006dummyActualSales.ProductCode__c    = '00000001';
            erpSe0006dummyActualSales.InterfaceId__c    = 'IF_KR_ERP_SE_0006';
            erpSe0006dummyActualSales.ErpCode__c        = '001';

            erpSe0006sList.add(erpSe0006dummyActualSales);
        }

        if(erpSe0006dummySalesPerformance == null) {
            erpSe0006dummySalesPerformance = erpSe0006dummyDataBase.clone(false, true);
            erpSe0006dummySalesPerformance.InterfaceId__c    = 'IF_KR_ERP_SE_0016';

            erpSe0006sList.add(erpSe0006dummySalesPerformance);
        }

        if(erpSe0006sList.size() != 0)  insert erpSe0006sList;
    }

    /**
     * @description IF Dummy 0012 Data.
     *
     * @param isInsert Boolean
     *
     * @return IF_KR_ERP_SE_0012__c
     */
    public static IF_KR_ERP_SE_0012__c creatErpSe0012(final Boolean isInsert) {
        IF_KR_ERP_SE_0012__c erpSe0012 = new IF_KR_ERP_SE_0012__c();

        erpSe0012.InterfaceId__c            = 'IF_KR_ERP_SE_0012';
        erpSe0012.isBatchCompleted__c       = false;
        erpSe0012.isBatchError__c           = false;
        erpSe0012.BatchErrorMessage__c      = '';
        erpSe0012.DealerCode__c             = '001';
        erpSe0012.ProductCode__c            = '00000001';
        erpSe0012.ErpOUT_DATE__c            = '20200501';
        erpSe0012.ErpOUT_TIME__c            = '102030';
        erpSe0012.SalesDocItem__c           = '000001';
        erpSe0012.SalesDocNo__c             = '123';
        erpSe0012.Asset__c                  = '1234567890';

        if(isInsert)    insert erpSe0012;

        return erpSe0012;
    }

    public static IF_KR_ERP_SE_0012__c erpSe0012dummyDataBase           {get;set;}

    static {
        if(erpSe0012dummyDataBase == null) {
            erpSe0012dummyDataBase = creatErpSe0012(true);
        }
    }


    /**
     * @description IF Dummy 0036 Data.
     *
     * @param isInsert Boolean
     *
     * @return IF_KR_ERP_SE_0036__c
     */
    public static IF_KR_ERP_SE_0036__c creatErpSe0036(final Boolean isInsert) {
        IF_KR_ERP_SE_0036__c erpSe0036 = new IF_KR_ERP_SE_0036__c();

        erpSe0036.InterfaceId__c            = 'IF_KR_ERP_SE_0036';
        erpSe0036.isBatchCompleted__c       = false;
        erpSe0036.isBatchError__c           = false;
        erpSe0036.BatchErrorMessage__c      = '';
        //erpSe0036.OrderID__c                = '01';
        //erpSe0036.ErpABGRU__c               = '01';

        if(isInsert)    insert erpSe0036;

        return erpSe0036;
    }

    public static IF_KR_ERP_SE_0036__c erpSe0036dummyDataBase           {get;set;}

    static {
        if(erpSe0036dummyDataBase == null) {
            erpSe0036dummyDataBase = creatErpSe0036(true);
        }
    }



    /**
     * @description IF Dummy 0029 Data.
     *
     * @param isInsert Boolean
     *
     * @return IF_KR_PLM_SE_0029__c
     */
    public static IF_KR_PLM_SE_0029__c createPlmSe0029(final Boolean isInsert) {
        IF_KR_PLM_SE_0029__c plmSe0029 = new IF_KR_PLM_SE_0029__c();

        plmSe0029.PECN_ID__c                = '00001';
        plmSe0029.PLANT_ID__c               = '001';
        //plmSe0029.isBatchCompleted__c     = false;
        //plmSe0029.isBatchError__c         = false;
        //plmSe0029.BatchErrorMessage__c    = '';

        if(isInsert)    insert plmSe0029;

        return plmSe0029;
    }

    public static IF_KR_PLM_SE_0029__c plmSe0006dummyDataBase               {get;set;}
    public static IF_KR_PLM_SE_0029__c plmSe0006dummyDataProductChange      {get;set;}
    public static IF_KR_PLM_SE_0029__c plmSe0006dummyDataProductChangeItem  {get;set;}
    public static IF_KR_PLM_SE_0029__c plmSe0006dummyDataProductChangeModel {get;set;}

    static {
        if(plmSe0006dummyDataBase == null) {
            plmSe0006dummyDataBase = createPlmSe0029(true);
        }

        if(plmSe0006dummyDataProductChange == null) {
            plmSe0006dummyDataProductChange = plmSe0006dummyDataBase.clone(false, true);
            plmSe0006dummyDataProductChange.InterfaceId__c          = 'IF_KR_PLM_SE_0029';
            plmSe0006dummyDataProductChange.PREGISTRATION_DATE__c   = strDate;
            plmSe0006dummyDataProductChange.RELEASED_DATE__c        = strDate;
            plmSe0006dummyDataProductChange.PAPPLY_DATE__c          = strDate;

            insert plmSe0006dummyDataProductChange;
        }

        if(plmSe0006dummyDataProductChangeItem == null) {
            plmSe0006dummyDataProductChangeItem = plmSe0006dummyDataBase.clone(false, true);
            plmSe0006dummyDataProductChangeItem.InterfaceId__c      = 'IF_KR_PLM_SE_0030';
            plmSe0006dummyDataProductChangeItem.PSEQ__c             = '1';

            insert plmSe0006dummyDataProductChangeItem;
        }

        if(plmSe0006dummyDataProductChangeModel == null) {
            plmSe0006dummyDataProductChangeModel = plmSe0006dummyDataBase.clone(false, true);
            plmSe0006dummyDataProductChangeModel.InterfaceId__c     = 'IF_KR_PLM_SE_0031';
            plmSe0006dummyDataProductChangeModel.PSEQ__c            = '1';
            plmSe0006dummyDataProductChangeModel.PMODEL_ID__c       = '00000001';

            insert plmSe0006dummyDataProductChangeModel;
        }
    }
}