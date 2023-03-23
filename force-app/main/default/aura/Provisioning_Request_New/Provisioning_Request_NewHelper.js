({
	recordUpdateHelper : function(component, event, helper) { 
        let action = component.get("c.getOpp"); 
        action.setParams({"recId":component.get("v.recordId")});
        action.setCallback(this, function(res) {
            let state = res.getState();
            console.log('state---'+state);
            if (state === "SUCCESS") {
                component.set("v.record",res.getReturnValue());
                let action1 = component.get("c.getUserRole");       
                action1.setCallback(this, function(response) {
                    let state1 = response.getState();
                    console.log('state1---'+state1);
                    if (state1 === "SUCCESS") {
                        let role = response.getReturnValue();
                        let optyStage = component.get("v.record").StageName;
                        let accountId = component.get("v.record").AccountId;
                        component.set("v.accountId",accountId);
                        console.log('optyStage---'+optyStage);
                        if(role == "Customer Service Engineer - Sunny"){
                            this.showRecordTypeSelection(component, event);
                        }
                        else if(optyStage == $A.get("$Label.c.Stage_1_Alignment") || 
                                optyStage == $A.get("$Label.c.Stage_2_Qualified_Budgeted")){
                            component.set("v.openPopup",true);
                        }
                        else{
                            this.showRecordTypeSelection(component, event);
                       }
                    } else if (state1 == "INCOMPLETE") {
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Oops!",
                            "message": "No Internet Connection"
                        });
                        toastEvent.fire();
                        
                    } else if (state1 == "ERROR") {
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Please contact your administrator"
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action1);
            } else if (state == "INCOMPLETE") {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Oops!",
                    "message": "No Internet Connection"
                });
                toastEvent.fire();
                
            } else if (state == "ERROR") {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please contact your administrator"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	},
    showRecordTypeSelection : function(component, event){
        let action = component.get("c.fetchRecordTypeValues");
        action.setCallback(this, function(response) {
            component.set("v.isOpen", true);
            component.set("v.lstOfRecordType", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    createRecord: function(component, event, helper) {
        if(component.get("v.isFirstScreen") == true && component.get("v.value") == "Yes"){
        	component.set("v.isSelectedYes", true);
        	component.set("v.isFirstScreen", false);    
        }
        else if(component.get("v.isFirstScreen") == true && component.get("v.value") == "No"){
            component.set("v.isFirstScreen", false);
            component.set("v.isSelectedNo", true);
        }
        else if(component.get("v.isSelectedNo") == true){
        	let recordTypeLabel;
            //updated by Ayush Kangar as part of CR# 3371 - Start
            let checkNotFeVa = true;
            let initailavalue = component.find("selectid").get("v.value");
            if(initailavalue === undefined){
            	recordTypeLabel = component.get("v.lstOfRecordType[0]");
            }    
            else{
           		recordTypeLabel = component.find("selectid").get("v.value");    
            }   
            this.callRecordHelper(component, event, helper, true , recordTypeLabel);        
        }
    },
    handleCancelHelper : function(component, event, helper){
        let dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    handleChangeHelper : function(component, event, helper){
    	let changeValue = event.getParam("value");
        component.set("v.value",changeValue);
	},
    callRecordHelper : function(component, event, helper, NotFeva, recordType){
        let recordTypeLabel;
        if(NotFeva){
        	recordTypeLabel = recordType;    
        }
        else{
        	recordTypeLabel = 'FeVa Cloud';
        }
        let action = component.get("c.getRecTypeId");
            action.setParams({
                "recordTypeLabel": recordTypeLabel
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let RecTypeID  = response.getReturnValue();
                    let createRecordEvent = $A.get("e.force:createRecord");
                    createRecordEvent.setParams({
                        "entityApiName": "Provisioning_Request__c",
                        "recordTypeId":RecTypeID,
                        "defaultFieldValues": {
                            'Opportunity__c' : component.get("v.recordId"),
                            'Organization_Domain__c' : component.get("v.record").Account_Org_Domain__c,
                            'SE__c' : component.get("v.record").SE_Name__c,
                            'Account__c' : component.get("v.record").AccountId
                        }
                    });
                    createRecordEvent.fire();
                    
                } else if (state == "INCOMPLETE") {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Oops!",
                        "message": "No Internet Connection"
                    });
                    toastEvent.fire();
                    
                } else if (state == "ERROR") {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please contact your administrator"
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
    }
})