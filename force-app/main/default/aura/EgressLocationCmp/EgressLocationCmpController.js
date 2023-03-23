({
	    
    doInit : function(component, event, helper) {
        component.set("v.loaded", true);
        //alert('=='+ component.get('v.PassesValueFromVF'));
        var optyId = component.get('v.PassesValueFromVF');
        var nameValue = component.find("OpptyId").get("v.value");
        console.log(nameValue);
        // set value
        component.find("OpptyId").set("v.value", optyId);
        
        
        var action = component.get("c.getAccount");
        action.setParams({
            "optyId" : optyId 
        });
        action.setCallback(this, function(response) {
            //alert(response.getState());
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert(response.getReturnValue());
                var result=response.getReturnValue();
                component.set("v.accObj", response.getReturnValue());
                component.find("accId").set("v.value", result.Id);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        component.set("v.loaded", false);
    },
    handleSubmit : function(component, event, helper) {
    	component.set("v.loaded", true);
    },
    handleSuccess : function(component, event, helper) {
        
        window.location.href=component.get('v.optyURL');
       //alert('Successfully created a record.');
        /*var navService = component.find("navigation"); 
        var pageReference = {
            type: 'standard__recordPage',         
            attributes: {              
                "recordId": component.get('v.PassesValueFromVF'),
                "actionName": "view",               
                "objectApiName":"Opportunity"              
            }        
        };
        component.set("v.pageReference", pageReference);
        var pageReference = component.get("v.pageReference");
        navService.navigate(pageReference,true); 
        //alert(window.location.hostname);
        //alert(window.location.pathname);
        component.find("navigation")
        .navigate({
            "type" : "standard__recordPage",
            "attributes": {
                "recordId"      : component.get('v.PassesValueFromVF'),
                "actionName"    : "view"   //clone, edit, view
            }
        }, true);
        var labelSubStr = "DomainOptyURL";
        var labelReference = $A.getReference("$Label.c." + labelSubStr);
        window.location.href=labelReference+component.get('v.PassesValueFromVF')+"/view";
    	component.set("v.loaded",false); */
        
    },

})