({    
    invoke : function(component, event, helper) {

        const recId = component.get("v.recordId");

        //IBA-6578 - Start
        let action = component.get("c.getDomain");
        action.setParams({ type:'VisualforceHostname', packageName : 'sbqq' });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let baseURL = response.getReturnValue();
                let link =  'https://' + baseURL + '/apex/SelectContractOpp?id=' + recId;
            
                let pageReference = {
                    type: 'standard__webPage',
                    attributes: { url: link }
                };

                console.log(pageReference);

                let navService = component.find("navService");
                navService.navigate(pageReference);
            }            
            else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message){ 
                        console.log("Error message: " + errors[0].message);
                    }
                } else { console.log("Unknown error"); }
            }
        });

        $A.enqueueAction(action);
        //IBA-6578 - End
    }
})