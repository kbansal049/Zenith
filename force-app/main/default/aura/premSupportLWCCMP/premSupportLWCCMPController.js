({
    doInit : function(component, event, helper) {
        //alert('in doinit');
        var pageReference = component.get("v.pageReference");
        /*if(pageReference.state.c__refresh =='false'){
            window.location.assign('/lightning/cmp/c__premSupportLWCCMP?c__id=' + pageReference.state.c__id +'&c__refresh=true');
        }else{
            component.set("v.quoteId", pageReference.state.c__id);
            component.set("v.boolean", "true");
        }*/
        component.set("v.quoteId", pageReference.state.c__id);
        component.set("v.boolean", "true");
    },
    
    onPageReferenceChanged: function(cmp, event, helper) {
            $A.get('e.force:refreshView').fire();
    }
    
})