({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        
        var action = component.get("c.getRecordTypeValues");
        action.setParams({
            erId : component.get('v.recordId') 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(component.get('v.recordId') != '' && component.get('v.recordId') != null){
                    console.log('Check Edit Access :'+result.haveEditAccess);
                    if(!result.haveEditAccess){
                        console.log('haveEditAccess:');
                        component.set('v.showEditAccessDiv', true);
                        
                        //alert('You do not have access to Edit this record.');
                        //window.open('/' + component.get('v.recordId'), '_self');
                        return;
                    }
                }
                var recordTypes = result.executiveRequestRecordTypes;
                var recordTypesDescription = result.executiveRequestTypeDesc;
                console.log('skipSelection :'+result.skipRecordTypeSelection);
                var recordtypeMap =[];
                var recordtypeDescMap =[];
                for(var key in recordTypes){
                    recordtypeMap.push({label: recordTypes[key], value: key});
                    recordtypeDescMap.push({label: recordTypesDescription[key], value: key});
                }
                console.log('recordtypeMap :'+recordtypeMap);
                if(result.skipRecordTypeSelection){
                    
                    console.log('Skip recordTypeName :'+recordtypeMap[0].label);
                    var updateEvent = $A.get("e.c:executiveRequestRecordTypeEvent");
                    updateEvent.setParams({"recordTypeSelectedId": result.defaultRecordTypeId});
                    updateEvent.setParams({"recordTypeSelectedName":recordtypeMap[0].label});
                    updateEvent.setParams({"haveEditAccess":result.haveEditAccess});
                    updateEvent.fire();
                }else{
                    console.log('Record Types Show');
                    component.set("v.recordTypeMap", recordtypeMap);
                    component.set("v.recordTypeDescMap", recordtypeDescMap);
                    component.set("v.selectedRecordTypeId", result.defaultRecordTypeId);
                    component.set("v.showTypeSelection", true);
                }
                
            }
        });
        $A.enqueueAction(action);
        component.set('v.showSpinner', false);
    },
     
    closeSelection: function(component, event, helper){
        component.set('v.showSpinner', true);
        if (component.get('v.recordId')) {
            window.open('/' + component.get('v.recordId'), '_self');
        } else if (component.get('v.oppId')) {
            window.open('/' + component.get('v.oppId'), '_self');
        } else if (component.get('v.accId')) {
            window.open('/' + component.get('v.accId'), '_self');
        }
    },
    submitRecordType: function(component, event, helper) { 
        var selectedRecordTypeId = component.get("v.selectedRecordTypeId");
        
        var recordTypeMap1 = component.get("v.recordTypeMap");
        var recordTypeName='';
        
        for(var key in recordTypeMap1){
           if(recordTypeMap1[key].value == selectedRecordTypeId){
                recordTypeName = recordTypeMap1[key].label;
            }
        }
        console.log('selected record type Name :'+recordTypeName);
        var updateEvent = $A.get("e.c:executiveRequestRecordTypeEvent");
        updateEvent.setParams({"recordTypeSelectedId": selectedRecordTypeId});
        updateEvent.setParams({"recordTypeSelectedName": recordTypeName});
        updateEvent.fire();
        
    },
    
    optionChange : function(component, event, helper) { 
    	var recordName = event.target.getAttribute("value");
        component.set("v.selectedRecordTypeId", recordName);
    }
})