({
    init : function (component, event, helper){
        let recordId = component.get("v.recordId");
        var action = component.get("c.fetchAssignedContact");
        action.setParams({
            cisorequestId : recordId
        });    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.lstSelectedRecords", JSON.parse(result));
                //helper.showToast(component, event, helper,'title','message');
            }
        });
        $A.enqueueAction(action);
    },
    
    save : function(component,event,helper){
        let recordId = component.get("v.recordId");
        let assignedContacts = component.get("v.lstSelectedRecords");
        var action = component.get("c.saveAssignedContacts");
        action.setParams({
            record : {
                Id : recordId,
                Contact_Attendee_Role__c : JSON.stringify(assignedContacts)
            }
        });    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //showToast.helper(component, event, helper,title,message);
            }
            component.set("v.mode", false);
            window.location.href = "/"+recordId;
        });
        $A.enqueueAction(action);
    }, 
    
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        var lstSelectedRecords = component.get("v.lstSelectedRecords");
        var recordList = [];
        if (Array.isArray(lstSelectedRecords)){
            lstSelectedRecords.forEach(function (element) {
                recordList.push(element.Id);
            })
        }            
        // set param to method  
        action.setParams({
            searchKeyWord: getInputkeyWord,
            ObjectName : component.get("v.objectAPIName"),
            recordList : recordList
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                component.set("v.listOfSearchRecords", storeResponse); 
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    showToast : function(component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    }
})