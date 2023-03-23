({
    doInit : function(component, event, helper) {
        /*console.log('Agent Assigned Work Called');
        helper.loginToOmni(component, event, helper);*/
        var action = component.get("c.skipOmniControlLogic");
        action.setCallback(this, function(response) {
            var skipValue = response.getReturnValue();
            console.log('Skip Control -->'+skipValue);
            component.set("v.isSpecialUser", skipValue);
            if(skipValue == false){
            	helper.pollPriorityCheck(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    
    onRender : function(component, event, helper) {
        var action1 = component.get("c.skipOmniControlLogic");
        action1.setCallback(this, function(response) {
            var skipValue = response.getReturnValue();
            console.log('Skip Control Render-->'+skipValue);
            if(skipValue == false){
            	helper.loginToOmni(component, event, helper);
            }
        });
        $A.enqueueAction(action1);
    },
    
    onWorkAccepted : function(component, event, helper) {
        console.log("Work accepted.");
        var workItemId = event.getParam('workItemId');
        var workId = event.getParam('workId');
    },
    
    onWorkloadChanged : function(component, event, helper) {
        console.log("--onWorkloadChanged called--");
        var configuredCapacity = event.getParam('configuredCapacity');
        var previousWorkload = event.getParam('previousWorkload');
        var newWorkload = event.getParam('newWorkload');
        console.log('configuredCapacity--',configuredCapacity);
        console.log('previousWorkload--',previousWorkload);
        console.log('newWorkload--',newWorkload);
        let currentUSPId =  component.get("v.currentUSPId");
        
        if(configuredCapacity > 0){
           	if(configuredCapacity > newWorkload ){
                let statId = $A.get("$Label.c.Omni_Channel_StatusID_OnAWebCase");
                let isSpecUser = component.get("v.isSpecialUser");
                console.log('Workload changed specUser --->'+isSpecUser);
                if(currentUSPId === statId && isSpecUser==false){
                    //helper.setAgentStausToAvailable(component, event, helper);
                    helper.callApexPriorityCheck(component, event, helper, true);
                    console.log('Polling Resumed....');
                    helper.pollPriorityCheck(component, event, helper);
                }
                else{
                    if(isSpecUser == true){
                    	console.log('currentUSPName for CS--->'+component.get("v.currentUSPName"));
                        let allowedStatuses = $A.get("$Label.c.Allowed_Status_for_CS_Engineers");
                        let currentCSUSPName = component.get("v.currentUSPName");
                        if(!allowedStatuses.includes(currentCSUSPName)){
                            var omniAPI = component.find("omniToolkit");
                            var csStatId = $A.get("$Label.c.Omni_Channel_StatusID_CS_Available");
                            console.log('set CS Available--before--statusId--' + csStatId);
                            omniAPI.setServicePresenceStatus({statusId: csStatId}).then(function(result) {
                                console.log('set CS Available--before--statusId Result--' + result.statusId);
                            }).catch(function(error) {
                                console.log(error);
                            });
                        }
                    }
                }
            }else{
                console.log('Polling Stopped....');
                helper.stopPolling(component, event, helper);
                helper.setAgentStausToOnAWebCase(component, event, helper);
            }
        }
    }, 
    
    onStatusChanged : function(component, event, helper) {
        
        console.log("--onStatusChanged started--");
        var statusId = event.getParam('statusId');
        var channels = event.getParam('channels');
        var statusName = event.getParam('statusName');
        var statusApiName = event.getParam('statusApiName');
        component.set("v.currentUSPId", statusId);
        component.set("v.currentUSPName", statusApiName);
        console.log('statusId--',statusId);
        console.log('channels--',channels);
        console.log('statusName--',statusName);
        console.log('statusApiName--',statusApiName);
        helper.updateOnStatusChange(component, event, helper)
        .then($A.getCallback(function(result) {
            console.log("--parse response--",result);
            let configuredCapacity = result.configuredCapacity;
            let newWorkload = result.currentWorkload;
            console.log('--configured capacity is--' , configuredCapacity);
            console.log('--currently assigned workload--' , newWorkload);
            console.log('--comparision--' , configuredCapacity>=newWorkload);            
            if(newWorkload >= configuredCapacity){
                console.log('---Agent is 100% occupied---');
                //IBA-4710 - Start
                let blockedStatus = $A.get("$Label.c.Omni_Channel_Available_Statuses");
                console.log('---Statuses not allowed--->'+blockedStatus);
                console.log('---Current Status--->'+statusApiName);
                if(blockedStatus.includes(statusApiName)){
                    console.log('Setting Status to On a Web Case');
                	helper.setAgentStausToOnAWebCase(component, event, helper);    
                }
                //IBA-4710 - End
            }else{
                console.log('---Agent has capacity---');
            }
        }))
        .catch(function(errors) {
            console.error('ERROR: ' + errors);
        });
        
        
        console.log("--onStatusChanged ended--");
    }, 

    onLogout : function(component, event, helper) {
        var action = component.get("c.agentPriorityChangeCheck");
        console.log('Logout Code Executng....');
        component.set("v.currentUSPName",'Offline');
        action.setCallback(this, function(response) {
            var retVal = response.getReturnValue();
            console.log('retVal logout-->'+retVal);
            if(retVal == true){
                var omniAPI = component.find("omniToolkit");
                omniAPI.login({statusId: "0N50g000000Kyll"}).then(function(result) {
                    if (result) {
                        console.log("Login successful");
                    } else {
                        console.log("Login failed");
                    }
                }).catch(function(error) {
                    console.log(error);
                });
            }
        });
        $A.enqueueAction(action);
    }

    
})