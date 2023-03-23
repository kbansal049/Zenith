({
    doInit : function(component, event, helper) {
        
        var recordID = component.get("v.recordId");
        console.log('---recordId---',recordID);
        if(recordID){
            var action = component.get("c.exportDocumentFromQuestionnaire");
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
                        toastEvent.setParams({
                            "type" :"success",
                            "title": "Success!",
                            "message": 'Questionnaire Has Been Generated Successfully.'
                        });
                        toastEvent.fire();                   
                        window.open('/sfc/servlet.shepherd/document/download/' + rslt.docId, '_top');
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
                                "title": "Export Questionnaire",
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