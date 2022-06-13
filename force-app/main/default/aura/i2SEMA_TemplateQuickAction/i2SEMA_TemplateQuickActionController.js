/****************************************************************************************
  * @filename      : i2SEMA_TemplateQuickActionController.js
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/17 1:55 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/17 1:55 PM     i2max_shlee       Create
****************************************************************************************/
({
    /**
     * @description Initialize
     */
    doInit : function(component,event,helper){
            let currentURL = window.location.toString();

            //Detail page confirm
            if(currentURL.includes('new')){
                component.set('v.isScreen', 'New');
                component.set('v.isDisable', false);
            } else if(currentURL.includes('view')){
                component.set('v.isScreen', 'Read');
                component.set('v.isDisable', true);
            } else {
                component.set('v.isScreen', 'Edit');
                component.set('v.isDisable', false);
            }
    },
    /**
     * @description Save
     */
    doSave : function(component,event,helper){
        let form = component.find('form');
        form.save();
    },
    /**
     * @description Cancel
     */
    doCancel : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    /**
     * @description Preview Event
     */
    handlePreview : function(component,event,helper){
        let currentTemplateId   = component.get('v.templateId');
        let templateId          = event.getParam('templateId');
        let referenceData       = event.getParam('previewReferenceData');

        // Template ID 가 변경되는 Event 일 경우
        if( currentTemplateId !== templateId ){
            component.set('v.templateId',templateId);
            component.find('preview').refresh();
        }
        // 그 외, Reference Data 반영
        else {
            component.set('v.previewReferenceData',referenceData);
        }
    }
});