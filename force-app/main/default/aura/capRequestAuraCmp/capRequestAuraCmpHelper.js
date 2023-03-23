({
    getParentId: function(component, event, name) {
        var pageRef = component.get("v.pageReference");
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        if(addressableContext && addressableContext.attributes) {
            component.set("v.parentId", addressableContext.attributes.recordId);
            component.set("v.parentType", addressableContext.attributes.objectApiName);
        }
    }
})