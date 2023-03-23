({
    doInit : function(component, event, helper) 
    {        
        var pageRef = component.get("v.pageReference");
        if(pageRef != null)
        {
            var state = pageRef.state;
            var base64Context = state.inContextOfRef;
            if (base64Context.startsWith("1\."))
            {
                base64Context = base64Context.substring(2);
            }
            component.set("v.recordTypeId",state.recordTypeId);
            var addressableContext = JSON.parse(window.atob(base64Context));
            if(addressableContext != null && addressableContext.attributes != null)
            {
                if(addressableContext.attributes.objectApiName == 'Opportunity')
                {
                    component.set("v.opportunityId",addressableContext.attributes.recordId);  
                    //Added by Ayush Kangar as part of IBA-5280 - START                 
                    if(!component.get("v.recordId"))
                    {
                        var action = component.get("c.getPSOnboardingRecordTypeId");
                        action.setCallback(this, function(response) {
                            var responseState = response.getState();
                            if (responseState === "SUCCESS") {
                                if(component.get("v.pageReference").state.recordTypeId === response.getReturnValue()){
                                    component.set("v.showPSQComponent",false);
                                    var actionOverideNew = component.get('c.overrideNewButton');
                                    $A.enqueueAction(actionOverideNew);
                                }
                            }
                            else {
                                console.log("Failed with state: " + responseState);
                            }
                        });
                        
                        $A.enqueueAction(action);
                    }  
                    //Added by Ayush Kangar as part of IBA-5280 - END               
                }
                else if(addressableContext.attributes.objectApiName == 'inspire1__Project__c')
                {
                    component.set("v.projectId",addressableContext.attributes.recordId); 
                    //Added by Ayush Kangar as part of IBA-5280 - START                 
                    if(!component.get("v.recordId"))
                    {
                        var action = component.get("c.getPSOnboardingRecordTypeId");
                        action.setCallback(this, function(response) {
                            var responseState = response.getState();
                            if (responseState === "SUCCESS") {
                                if(component.get("v.pageReference").state.recordTypeId === response.getReturnValue()){
                                    component.set("v.showPSQComponent",false);
                                    var actionOverideNew = component.get('c.overrideNewButton');
                                    $A.enqueueAction(actionOverideNew);
                                }
                            }
                            else {
                                console.log("Failed with state: " + responseState);
                            }
                        });
                        
                        $A.enqueueAction(action);
                    }  
                    //Added by Ayush Kangar as part of IBA-5280 - END
                }   
            }
        }
    },
    
    //Added by Ayush Kangar as part of IBA-5065 - START
    //This method is used to Navigate to the record page after edit.
    navigateToRecordDetailPage: function (component){
        if(component.get("v.navigateToRecord")===true){
            setTimeout(function(){
                component.set("v.navigateToRecord",false);  
                window.location.href = '/'+component.get("v.recordId");
            }, 600);
        }
    },
    
    //This method is used to call the standard new page
    overrideNewButton: function (component){
        var nav = component.find("navService"); 
        var pageReference = { 
            "type": "standard__objectPage", 
            "attributes": {
                "objectApiName": "PS_Questionnaire__c",
                "actionName": "new",
            }, 
            state: { 
                nooverride: '1',
                recordTypeId:component.get("v.pageReference").state.recordTypeId,
            } 
        }  
        var URL = nav.navigate(pageReference);   
    }
})