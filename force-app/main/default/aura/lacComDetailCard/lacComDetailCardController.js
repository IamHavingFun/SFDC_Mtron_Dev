({
    doNaviObjHome : function(component, event, helper){
        component.find('lacComService').doNaviService({
            "type": "standard__objectPage",
            "attributes": {
                "objectApiName": component.get('v.targetObject'),
                "actionName": "home"
            }
        });
    }
});