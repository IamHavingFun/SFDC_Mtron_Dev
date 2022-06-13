/****************************************************************************************
  * @filename      : LsMSalesAddressSearchQa_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-15 오후 2:27
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-15 오후 2:27     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesAddressSearchQa_ts {
    @IsTest
    static void testBehavior() {
        Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock('{"common":{"errorMessage":"정상","countPerPage":"10","totalCount":"1","errorCode":"0","currentPage":"1"},"juso":[{"detBdNmList":"","engAddr":"137, Mapo-daero, Mapo-gu, Seoul","rn":"마포대로","emdNm":"공덕동","zipNo":"04143","roadAddrPart2":" (공덕동)","emdNo":"02","sggNm":"마포구","jibunAddr":"서울특별시 마포구 공덕동 473 KPX빌딩","siNm":"서울특별시","roadAddrPart1":"서울특별시 마포구 마포대로 137","bdNm":"KPX빌딩","admCd":"1144010200","udrtYn":"0","lnbrMnnm":"473","roadAddr":"서울특별시 마포구 마포대로 137 (공덕동)","lnbrSlno":"0","buldMnnm":"137","bdKdcd":"0","liNm":"","rnMgtSn":"114402113001","mtYn":"0","bdMgtSn":"1144010200104730000000001","buldSlno":"0"}]}'));

        LsMSalesAddressSearchQa.init();
        LsMSalesAddressSearchQa.search(10, 1, 'Test');
    }
}