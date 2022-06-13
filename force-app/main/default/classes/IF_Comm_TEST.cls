/****************************************************************************************
  * File Name   : IF_Comm_TEST
  * Description : Interface Common TEST
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author          Modification
  * ===============================================================
    1.0  2020.03.09  ldb3100         Create 
****************************************************************************************/
@isTest
private class IF_Comm_TEST {
    @isTest public static void myUnitTest() {
        try{
            //IF_Base.dummyMethod();
        
            DateTime tDateTime = DateTime.now();
            Date tDate = Date.today();
            String tReq = '{"pDate":"","pDate":"99999999","spricever":"00000000","spricever":"2014-01-01","spricever":"2014-01-01 00:00:11","spricever":"","reqdate":2015.2-}';
            String tReqBulk = '{"pDate":"","pDate":"99999999","spricever":"00000000","spricever":"2014-01-01","spricever":"2014-01-01 00:00:11","reqdate":"2015.2-"},{"pDate":"","pDate":"99999999","spricever":"00000000","spricever":"2014-01-01","spricever":"2014-01-01 00:00:11","reqdate":2015.2-},{"pDate":"","pDate":"99999999","spricever":"00000000","spricever":"2014-01-01","spricever":"2014-01-01 00:00:11","reqdate":2015.2-},{"pDate":"","pDate":"99999999","spricever":"00000000","spricever":"2014-01-01","spricever":"2014-01-01 00:00:11","reqdate":2015.2-},{"pDate":"","pDate":"99999999","spricever":"00000000","spricever":"2014-01-01","spricever":"2014-01-01 00:00:11","reqdate":2015.2-}';
            String tRes = '{"spricever":123.1-,"reqdate":"9999-99-99"}';
            String tStrDate = '20140101';
            List<string> tConvList;
            
            IF_Comm.show();
            IF_Comm.convDateToStr(tDateTime);
            IF_Comm.convDateToStr(tDate);
            IF_Comm.convDateToStr8(tDateTime);
            IF_Comm.convDateToStr8(tDate);
            
            IF_Comm.normalizeDecimal(tRes, 'spricever|totamt');
            IF_Comm.normalizeDateFromDIH(tReq, 'pDate|inpDate|crdat|zcmErdat');
            IF_Comm.normalizeDateToDIH(tRes, 'reqdate|deliveryDate|inDueDay|hdmInDueDay|inpDate|compDate|hdmInpDate|hdmEndDate');
        
            tConvList = IF_Comm.convertJsonToChunkList(tReq);
            IF_Comm.convertChunkListToJson(tConvList);
            tConvList = IF_Comm.convertJsonToChunkList(tReq);
            IF_Comm.convertDecimal(tConvList, 'spricever|reqdate');
            tConvList = IF_Comm.convertJsonToChunkList(tReq);
            IF_Comm.convertDateSFDCToDIH(tConvList, 'spricever|reqdate');
            tConvList = IF_Comm.convertJsonToChunkList(tReq);
            IF_Comm.convertDateDIHToSFDC4Null(tConvList, 'spricever|reqdate');
            
            IF_Comm.convDateProp(null);
            IF_Comm.convDateProp(tDate);
            tDate = Date.newInstance(0000,01,01);
            IF_Comm.convDateProp(tDate);
            tDate = Date.newInstance(20150101,01,01);
            IF_Comm.convDateProp(tDate); 
            
            IF_Comm.convStrToDate(tStrDate);
                        
            tDate = Date.today();
            IF_Comm.convDateToDatetime(tDate,9,0);
            IF_Comm.convDateToDatetime(tDate,9);
            IF_Comm.convDateToDatetime(tDate);
            
            String tStrTime = '0101';
            IF_Comm.convDateTimeToStr14(IF_Comm.convStrToDatetime(tStrDate, tStrTime, false));
            IF_Comm.convDateTimeToStr14(IF_Comm.convStrToDatetime(tStrDate, tStrTime, true));

            system.debug(IF_Comm.cryptoEncrypt('AES128', 'SFDCI2MAX_IF_VEC', 'SFDCI2MAX_IF_PRO', '1111'));

            // system.debug(IF_Comm.cryptoDecrypt('AES128', 'SFDCI2MAX_IF_VEC', 'SFDCI2MAX_IF_PRO', 'jP3hhdK1LEkBiN7d6r86VA=='));

            IF_Comm.stringToDecimal('123');
            
            IF_Comm.isSandbox();

            IF_Comm.convStrToDatetime('20190814');
            IF_Comm.convStrToDatetime('2019081412');
            IF_Comm.convStrToDatetime('201908141259');
            IF_Comm.convStrToDatetime('20190814125900');
            
            IF_Comm.convertEmpty('12345');

            IF_Comm.replaceHyphen('2020-01-01');
            IF_Comm.replaceColon('11:11:11');
            IF_Comm.replaceDateToStr('2020-01-01 11:11:11');
            IF_Comm.strLeftPad('1111');


            throw new DmlException('Test Dml Exception');           
        } catch(Exception e) {
            IF_Comm.errorDebug(e);
            IF_Comm.errorText(e); 
        }
    }
}