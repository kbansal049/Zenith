({
    invokeVFPageHelper : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var url = '/apex/DealRegConversionPage?id=' + recordId;
        window.open(url, '_self');        
    }
})