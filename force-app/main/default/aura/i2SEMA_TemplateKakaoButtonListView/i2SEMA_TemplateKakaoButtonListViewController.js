/****************************************************************************************
  * @filename      : i2SEMA_TemplateKakaoButtonListViewController.js
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/24 1:51 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 카카오 버튼 리스트를 표시하고 삭제 한다.
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/24 1:51 PM     i2max_shlee       Create
****************************************************************************************/
({
    /**
    * @description 카카오 버튼 리스트 표시 초기화 처리
    */
    doInit: function (component, event, helper) {
        // Base Initialize
        helper.gfn_baseInitialize(component,['KakaoTalkButton__c'])
            .then((returnData,response) => {
                // Component Initialize
            })
            .catch((error,response) => {
                helper.gfn_ApexErrorHandle(error, response);
            });
    },
    /**
    * @description 카카오 버튼 리스트 수정 팝업 표시
    */
    showEditPopup : function(component, event, helper) {
        console.log('add Kakao Btn');
        let recordId = component.get('v.recordId');
        let referenceData = component.get('v.referenceData');
        helper.gfn_log(component,'editKakaoBtnList referenceData',referenceData);

        let param = {
          recordId : recordId,
          referenceData: referenceData
        };

        let kakaoBtnList = component.find('ktbList');
        kakaoBtnList.open(param);
    },

})