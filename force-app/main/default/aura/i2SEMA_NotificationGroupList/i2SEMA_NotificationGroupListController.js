/****************************************************************************************
 * @filename       : i2SEMA_NotificationGroupListController.js
 * @projectname    : i2SEMA Core
 * @author         : i2max_byeon.jw
 * @date           : 2020-05-07 오후 4:34
 * @group          :
 * @group-content  :
 * @description    :
 * @copyright      : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                author              description
 * ===============================================================
 0.1     2020-05-07 오후 4:34     i2max_byeon.jw       Create
 ****************************************************************************************/
({
    // 초기화
    doInit : function(component,event,helper){
        // 조회
        helper.doSearch(component,event,helper);
    },
    // Page 번호 선택
    move : function(component,event,helper){
        component.set('v.pageNumber', event.getSource().get('v.value'));
        // 조회
        helper.doSearch(component,event,helper);
    },
    previous : function(component,event,helper){
        component.set('v.pageNumber', component.get('v.pageNumber') - 1);
        // 조회
        helper.doSearch(component,event,helper);
    },
    next : function(component,event,helper){
        component.set('v.pageNumber',component.get('v.pageNumber') + 1);
        // 조회
        helper.doSearch(component,event,helper);
    },
    navigate : function(component,event,helper){
        // $A.get("e.force:navigateToSObject").setParams(
        //     {
        //         recordId: event.currentTarget.id
        //     }).fire();

        // 새창
        window.open('/'+ event.currentTarget.id);
    },
});