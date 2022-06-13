/****************************************************************************************
 * @filename       : i2SEMA_ManualSendActivityController.js
 * @projectname    : i2SEMA Core
 * @author         : i2max_byeon.jw
 * @date           : 2020-04-16 오후 4:01
 * @group          :
 * @group-content  :
 * @description    :
 * @copyright      : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                author              description
 * ===============================================================
 0.1     2020-04-16 오후 4:01     i2max_byeon.jw       Create
 ****************************************************************************************/
({
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
        $A.get('e.force:closeQuickAction').fire();
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