({
    doInit : function(component, event, helper) {
        
        var recordID = component.get("v.recordId");
        console.log('---recordId---',recordID);
        if(recordID){
            var action = component.get("c.generateOneDocForAccount");
            action.setParams({
                'accountID': recordID
            }); 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    var rslt = response.getReturnValue(); 
                    console.log('---rslt--',rslt);
                    if(!rslt.mes){
                        component.set("v.fileID",rslt.docId);
                        console.log('----doc--id---',rslt.docId);
                        toastEvent.setParams({
                            "type" :"success",
                            "title": "Success!",
                            "message": 'Doc Generated Successfully.'
                        });
                        toastEvent.fire();
                        /*var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": '/sfc/servlet.shepherd/document/download/' + rslt.docId
                        });
                        urlEvent.fire();*/
                        window.open('/sfc/servlet.shepherd/document/download/' + rslt.docId, '_top');
                        $A.get('e.force:closeQuickAction').fire();
                    }else{
                        toastEvent.setParams({
                            "type" :"error",
                            "title": "Doc Generation Failed!",
                            "message": "" + rslt.mes
                        });
                        toastEvent.fire();
                        $A.get('e.force:closeQuickAction').fire();
                    }
                    //helper.openSingleFile(component, event, helper);
                    
                }else if (state === "INCOMPLETE") {
                    alert('Response is Incompleted');
                    $A.get('e.force:closeQuickAction').fire();
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            $A.get('e.force:closeQuickAction').fire();
                            toastEvent.setParams({
                                "type" :"error",
                                "title": "OneDoc Generation",
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