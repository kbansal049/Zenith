({
    doInit : function(component, event, helper) {
        
        var recordID = component.get("v.recordId");
        console.log('---recordId---',recordID);
        if(recordID){
            var action = component.get("c.generateDesignPlanFromQuestionnaire");
            action.setParams({
                'questionnaireId': recordID
            }); 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    var rslt = response.getReturnValue(); 
                    console.log('---rslt--',rslt);
                    component.set("v.fileID",rslt.docId);
                    console.log('----doc--id---',rslt.docId);                    
                    if(rslt.mes!=''){
                        toastEvent.setParams({
                            "type" :"error",
                            "title": "Error!",
                            "message": rslt.mes
                        });
                        toastEvent.fire();
                    }else{
                        toastEvent.setParams({
                            "type" :"success",
                            "title": "Success!",
                            "message": 'Design Plan Document Has Been Generated Successfully.'
                        });
                        toastEvent.fire();                   
                        window.open('/sfc/servlet.shepherd/document/download/' + rslt.docId, '_top');
                        $A.enqueueAction(component.get('c.sendEmail'));
                        
                    }
                    
                    $A.get('e.force:closeQuickAction').fire();
                }                    
                else if (state === "INCOMPLETE") {
                    alert('Response Is Incompleted');
                    $A.get('e.force:closeQuickAction').fire();
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            $A.get('e.force:closeQuickAction').fire();
                            toastEvent.setParams({
                                "type" :"error",
                                "title": "Generate Design Plan",
                                "message": errors[0].message
                            });
                            toastEvent.fire();
                        }   
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    sendEmail : function(component, event, helper){
        var docID = component.get("v.fileID");
        var recordID = component.get("v.recordId");
        
        console.log('---docID---',docID);
        if(docID){
            var action = component.get("c.sendEmailWithDesignDoc");
            action.setParams({
                'questionnaireId': recordID,
                'docId': docID
            }); 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    var rslt = response.getReturnValue(); 
                    console.log('---rslt--',rslt);
                    console.log('----doc--id---',rslt.docId);
                    if(rslt.mes!=''){
                        toastEvent.setParams({
                            "type" :"error",
                            "title": "Error!",
                            "message": rslt.mes
                        });
                        toastEvent.fire();
                    }else{
                        toastEvent.setParams({
                            "type" :"success",
                            "title": "Success!",
                            "message": 'Design Plan Document Has Been Emailed To You.'
                        });
                        toastEvent.fire();                   
                    }
                    
                    $A.get('e.force:closeQuickAction').fire();
                }                    
                else if (state === "INCOMPLETE") {
                    alert('Response Is Incompleted');
                    $A.get('e.force:closeQuickAction').fire();
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            $A.get('e.force:closeQuickAction').fire();
                            toastEvent.setParams({
                                "type" :"error",
                                "title": "Error While Sending An Email",
                                "message": errors[0].message
                            });
                            toastEvent.fire();
                        }   
                    }
                }
            });
            $A.enqueueAction(action);
        }
        
        
    }
    
})