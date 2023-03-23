({
    setAgentStausToBusy : function(cmp, evt, hlp) {
        //Set Status to Busy -- 0N50g000000Kyln
        var omniAPI = cmp.find("omniToolkit");
        omniAPI.setServicePresenceStatus({statusId: "0N50g000000Kyln"}).then(function(result) {
            console.log('Current statusId is: ' + result.statusId);
            console.log('Channel list attached to this status is: ' + result.channels); 
        }).catch(function(error) {
            console.log(error);
        });
    },
    
    setAgentStausToOnAWebCase : function(cmp, evt, hlp) {        
        //Set Status to OnAWebCase -- 0N5210000008P5B
        var omniAPI = cmp.find("omniToolkit");
        var statId = $A.get("$Label.c.Omni_Channel_StatusID_OnAWebCase");
        console.log('setAgentStausToOnAWebCase--before--statusId--' + statId);
        omniAPI.setServicePresenceStatus({statusId: statId}).then(function(result) {
            console.log('--setAgentStausToOnAWebCase--after--statusId---' + result.statusId);
        }).catch(function(error) {
            console.log(error);
        });
    },
    
    setAgentStausToAvailable : function(cmp, evt, hlp) {
        //Set Status to Available -- 0N50g000000Kyll
        var omniAPI = cmp.find("omniToolkit");
        var statId = $A.get("$Label.c.Omni_Channel_StatusID_Available");
        console.log('setAgentStausToAvailable--before--statusId--' + statId);
        omniAPI.setServicePresenceStatus({statusId: statId}).then(function(result) {
            console.log('setAgentStausToAvailable--before--statusId--' + result.statusId);
        }).catch(function(error) {
            console.log(error);
        });
    },
    
    updateOnStatusChange :  function(cmp,evt,hlp){
        return new Promise($A.getCallback(function(resolve, reject) {
            console.log('----updateOnStatusChange called started----');
            let omniAPI = cmp.find("omniToolkit");
            omniAPI.getAgentWorkload().then(function(result) {
                resolve(result);
            }).catch(function(error) {
                reject(error);
                console.log(error);
            });
            console.log('----updateOnStatusChange called ended----');
        }));
    },
	
    pollPriorityCheck : function(component, event, helper){
        helper.callApexPriorityCheck(component,event,helper);
        //window.setInterval(helper.callApexPriorityCheck(component,helper),1000); 
        var pollId = window.setInterval(
            $A.getCallback(function() { 
                helper.callApexPriorityCheck(component,helper,pollId);
            }), 10000
        );
        component.set("v.setIntervalId", pollId);
    },
    
    stopPolling : function(component, event, helper){
        let currentPollId = component.get("v.setIntervalId");
        console.log('currentPollId--->'+currentPollId);
        window.clearInterval(currentPollId);
    },
    
    callApexPriorityCheck : function(component, event, helper, isException){
        var currentStatusApiName;
        var omniAPI = component.find("omniToolkit");
        /*omniAPI.getServicePresenceStatusId().then(function(result) {
            currentStatusApiName = result.statusApiName;
        }).catch(function(error) {
            console.log(error);
        });*/
        var action = component.get("c.getAgentStatus");
        action.setParams({ currentPriority : component.get("v.currentPriority"), 
                          currentUspName : component.get("v.currentUSPName")
                         });
        action.setCallback(this, function(response) {
            var wrapperResult = response.getReturnValue();
            //var retVal = response.getReturnValue();
            if(wrapperResult){
            	var retVal = wrapperResult.status;
                var performLogin = wrapperResult.performLogin;
                console.log('Agent Current Status-->'+retVal +'--->'+performLogin);
                if(retVal != 'Backlog' && retVal != 'Weekend'){
                    if(retVal.includes('Available_NoChange')){
                        
                        var currentUSPSelected = component.get("v.currentUSPName");
                        var allowedStatus = $A.get("$Label.c.Omni_Channel_Available_Options");
                        let allowedCheck = allowedStatus.includes(currentUSPSelected);
                        if(allowedCheck == false || isException){
                            console.log('Current USP ---> '+component.get("v.currentUSPName"));
                            if(retVal.includes('Quota_Met')){
                                //this.setAgentStatusToQuotaMet(component, event, helper);
                                //var omniAPI1 = component.find("omniToolkit");
                                if(performLogin == true){
                                    this.performLoginAction(component, $A.get("$Label.c.Omni_Quota_Met_Status"));
                                }else{
                                    this.setAgentStatusToQuotaMet(component, event, helper)
                                }
                                
                            }
                            else if(retVal.includes('Overflow')){
                                if(isException){
                                    performLogin=false;
                                }
                                if(performLogin == true){
                                    this.performLoginAction(component, $A.get("$Label.c.Omni_Channel_Overflow_Status"));
                                }else{
                                    this.setAgentStatusToOverflow(component, event, helper);
                                }
                            }
                            /*else if(retVal.includes('WeeklyQuotaMet')){
                                this.setAgentStatusToWeeklyQuotaMet(component, event, helper);
                            }*/
                            else{
                                if(performLogin == true){
                                    console.log('Available and Perform Login');
                                    this.performLoginAction(component, $A.get("$Label.c.Omni_Channel_StatusID_Available"));
                                }else{
                                    this.setAgentStausToAvailable(component, event, helper);    
                                }
                            }
                        } 
                    }else{
                        console.log('Priority Changed-->'+retVal);
                        var currPriority = retVal;
                        var stattId = $A.get("$Label.c.Omni_Channel_StatusID_Available");
                        if(retVal.includes(';')){
                            const priorityArray = retVal.split(';');
                            currPriority = priorityArray[0];
                            if(priorityArray[1] == 'Quota_Met'){
                                stattId = $A.get("$Label.c.Omni_Quota_Met_Status")
                            }
                            else if(priorityArray[1] == 'Overflow'){
                                stattId = $A.get("$Label.c.Omni_Channel_Overflow_Status");
                            }
                            /*else if(priorityArray[1] == 'WeeklyQuotaMet'){
                                stattId = $A.get("$Label.c.Omni_Channel_Weekly_Quota_Met_Status");        
                            }*/
                        }
                        component.set("v.currentPriority", currPriority);
                        
                        //var omniAPI = component.find("omniToolkit");
                        omniAPI.logout().then(function(result) {
                            if (result) {
                                console.log('Logout Successful from Polling');
                                omniAPI.login({statusId: stattId}).then(function(result) {
                                if (result) {
                                    console.log("Login successful from Polling");
                                } else {
                                    console.log("Login failed from Polling");
                                }
                            }).catch(function(error) {
                                console.log(error);
                            });
                                
                            } else {
                                console.log("Logout failed");
                            }
                        }).catch(function(error) {
                            console.log(error);
                        });
                    }
                    
                    
                }
                else if(retVal == 'Backlog'){
                   this.setAgentStatusToBacklog(component, event, helper); 
                } 
            }
            
        });
        $A.enqueueAction(action);
    },
    
    loginToOmni : function(component, event, helper){
        var omniAPI = component.find("omniToolkit");
        omniAPI.getServicePresenceStatusId().then(function(result) {
            console.log('Status Id is: ' + result.statusId);
            if(result.statuId == 'test'){
            	
            }
        }).catch(function(error) {
            console.log('Custom Error-->'+error);
            //this.checkAvailabilityAndLoginUser(component, event, helper);
            var omniAPI = component.find("omniToolkit");
            omniAPI.login({statusId: "0N50g000000Kylm"}).then(function(result) {
                if (result) {
                    console.log("Login successful");
                } else {
                    console.log("Login failed");
                }
            }).catch(function(error) {
                console.log(error);
            });
            /*var action = component.get("c.agentPriorityChangeCheck");
            console.log('Check code executed');
            action.setCallback(this, function(response) {
                var retVal = response.getReturnValue();
                console.log('retVal-->'+retVal);
                //if(retVal == true){
                    var omniAPI = component.find("omniToolkit");
                    omniAPI.login({statusId: "0N50g000000Kylm"}).then(function(result) {
                        if (result) {
                            console.log("Login successful");
                        } else {
                            console.log("Login failed");
                        }
                    }).catch(function(error) {
                        console.log(error);
                    });
                //}
            });
            $A.enqueueAction(action);*/
        });
    },
    
    checkAvailabilityAndLoginUser : function(component, event, helper){
        console.log('Test Main Anup');
        var action = component.get("c.agentPriorityChangeCheck");
        console.log('Check code executed');
        action.setCallback(this, function(response) {
            var retVal = response.getReturnValue();
            console.log('retVal-->'+retVal);
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
    },
    
    checkAgentQuota : function(component, event, helper){
    	var action = component.get("c.checkAgentQuotaMet");
        console.log('Check Agent Quota');
        action.setCallback(this, function(response) {
            var retVal = response.getReturnValue();
            console.log('Quota Met?-->'+retVal);
            if(retVal != 'No_Change'){
                var omniAPI = component.find("omniToolkit");
                var statId = $A.get("$Label.c.Omni_Quota_Met_Status");
                if(retVal == 'Overflow'){
                    statId = $A.get("$Label.c.Omni_Channel_Overflow_Status");
                }
                else if(retVal == 'Quota_Met'){
                    statId = $A.get("$Label.c.Omni_Quota_Met_Status");
                }
                
                omniAPI.setServicePresenceStatus({statusId: statId}).then(function(result) {
                    console.log('Setting status to Quota Met' + result.statusId);
                }).catch(function(error) {
                    console.log(error);
                });
            }
        });
        $A.enqueueAction(action);
    },
    
    setAgentStatusToBacklog : function(cmp, evt, hlp) {
        //Set Status to Backlog -- 0N50g000000Kylm
        var omniAPI = cmp.find("omniToolkit");
        var currentUSPSelected = cmp.get("v.currentUSPName");
        var allowedStatus = $A.get("$Label.c.Omni_Channel_Restricted_Status");
        let allowedCheck = allowedStatus.includes(currentUSPSelected);
        
        if(allowedCheck == false){
           omniAPI.setServicePresenceStatus({statusId: "0N50g000000Kylm"}).then(function(result) {
            	console.log('Setting Status to Backlog');
            }).catch(function(error) {
                console.log(error);
            }); 
        }
        
    },
    
    setAgentStatusToQuotaMet : function(cmp, evt, hlp) {
        var omniAPI = cmp.find("omniToolkit");
        var statQuotaMetId = $A.get("$Label.c.Omni_Quota_Met_Status");
        omniAPI.setServicePresenceStatus({statusId: statQuotaMetId}).then(function(result) {
            	console.log('Setting Status to Quota Met');
            }).catch(function(error) {
                console.log(error);
            }); 
    },
    
    setAgentStatusToOverflow : function(cmp, evt, hlp) {
        var omniAPI = cmp.find("omniToolkit");
        var statOverflowId = $A.get("$Label.c.Omni_Channel_Overflow_Status");
        omniAPI.setServicePresenceStatus({statusId: statOverflowId}).then(function(result) {
            	console.log('Setting Status to Overflow');
            }).catch(function(error) {
                console.log(error);
            }); 
    },
    
    /*setAgentStatusToWeeklyQuotaMet : function(cmp, evt, hlp) {
        var omniAPI = cmp.find("omniToolkit");
        var statWeeklyQuotaMetId = $A.get("$Label.c.Omni_Channel_Weekly_Quota_Met_Status");
        omniAPI.setServicePresenceStatus({statusId: statWeeklyQuotaMetId}).then(function(result) {
            	console.log('Setting Status to Overflow');
            }).catch(function(error) {
                console.log(error);
            }); 
    },*/
    
    performLoginAction : function(cmp,statusId){
        console.log('Log in perform function called');
        var omniAPI = cmp.find("omniToolkit");
    	omniAPI.logout().then(function(result) {
            if (result) {
                console.log('Logout Successful from Polling - Quota Met');
                omniAPI.login({statusId: statusId}).then(function(result) {
                    if (result) {
                        console.log("Login successful from Polling -"+statusId);
                        component.set("v.currentUSPName", 'Quota_Met');
                    } else {
                        console.log("Login failed from Polling -"+statusId);
                    }
                }).catch(function(error) {
                    console.log(error);
                });
                
            } else {
                console.log("Logout failed");
            }
        }).catch(function(error) {
            console.log('Custom Error from Change--->'+error);
            var omniAPI = cmp.find("omniToolkit");
            omniAPI.login({statusId: statusId}).then(function(result) {
                if (result) {
                    console.log("Login successful from Change");
                } else {
                    console.log("Login failed from Change");
                }
            }).catch(function(error) {
                console.log(error);
            });
        });
	}
    
    
})