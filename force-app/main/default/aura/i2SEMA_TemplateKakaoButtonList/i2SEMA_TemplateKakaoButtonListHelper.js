/****************************************************************************************
  * @filename      : i2SEMA_TemplateKakaoButtonListHelper.js
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/27 10:31 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/27 10:31 PM     i2max_shlee       Create
****************************************************************************************/
({
    /**
     *  @description 프리뷰 갱신
     */
    fn_firePreviewEvent : function(component,event,helper){
        let recordId   = component.get('v.recordId');
        let referenceData   = component.get('v.referenceData');
        let previewEvent    = component.getEvent('previewEvent');

        previewEvent.setParams({
            templateId : recordId,
            previewReferenceData : referenceData
        });
        helper.gfn_log(component,'helper.fn_firePreviewEvent',referenceData);
        previewEvent.fire();
    },
});