/****************************************************************************************
 * @filename      : lsMSalesAddressSearchQaHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-30 오후 5:13
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author              description
 * ===============================================================
 0.1     2020-06-30 오후 5:13    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * getAddress : 주소 검색
     **/
    getAddress: function(component, helper, pageSize, pageNumber, searchTerm) {
        if($A.util.isEmpty(component.find('address').get('v.value'))){
            helper.gfn_toast($A.get("{!$Label.c.AddressSearch_SearchMsg}"),'s','pester');
        }else{
            var param = {
                'pageSize' : pageSize,
                'pageNumber' : pageNumber,
                'searchTerm' : searchTerm
            };
            helper.apex(
                component, 'doSearch', 'search', param
            ).then(function ({resData, response}) {
                // =========================================
                // 데이터 세팅
                // =========================================
                var common = resData.results.common;

                if(common.errorCode == '0') { // 정상
                    component.set('v.recordList', resData.results.juso);
                    component.set('v.totalCount', common.totalCount);

                    var pages = Math.ceil(common.totalCount / component.get('v.pageSize'));
                    // 마지막 페이지
                    if(pages == pageNumber){
                        component.set("v.isLastPage", true);
                    } else{
                        component.set("v.isLastPage", false);
                    }

                    // 검색 결과 건수를 표시힌다 ===================================
                    component.set("v.isSearch", true);

                    // 주소 입력 창을 숨긴다 =====================================
                    var inputAddress = component.find('inputAddress').getElement();
                    inputAddress.className = 'slds-hide';

                    // 주소 결과 목록 창을 표시한다 =======================================
                    var addressList = component.find('addressList').getElement();
                    // component가 아닌 일반 html 태그는 토글이 안먹힌다
                    addressList.className = 'slds-show';

                    // 상세주소값 초기화
                    component.set("v.address2", null);
                    // 선택 버튼 감춤
                    component.set("v.showSaveButton", false);

                    component.set("v.searchTerm", param.searchTerm);
                }else{ // 에러
                    helper.gfn_toast(common.errorMessage,'e','pester');
                }
            }).catch(function ({error, response}) {
                helper.gfn_ApexErrorHandle(error, response);
            });
        }
    }
});