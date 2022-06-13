/**
 * Created by MS on 2020-06-25.
 */

({
    //-------------------------------------------------------------
    // 초기화
    //-------------------------------------------------------------
    doInit : function(component, event, helper){
        !$A.util.isEmpty($A.get("$SObjectType.CurrentUser.Id")) && component.set('v.isUserLogin', true);
    }
});