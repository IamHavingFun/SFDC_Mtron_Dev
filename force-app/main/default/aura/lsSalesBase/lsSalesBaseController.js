({
    /**
     * current user의 LDS 레코드 데이터의 변경시 적용
     * @param component
     * @param event
     * @param helper
     */
    doRecordUpdated: function (component, event, helper) {
        let changeType = event.getParams().changeType;
        if (changeType === "CHANGED") {
            component.find("currentUserLoader").reloadRecord();
        }
    }
});