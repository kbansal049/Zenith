({
    init : function(component, event, helper) {
		var pageReference = component.get("v.pageReference");
        
        var desc = pageReference.state.c__Description;
        var summary = pageReference.state.c__Summary;
        var crType = pageReference.state.c__Type;
        var stage = pageReference.state.c__Stage;
        var priority = pageReference.state.c__Priority;
        var assignee = pageReference.state.c__Assignee;
        var businessAnalyst = pageReference.state.c__BusinessAnalyst;
        var reporter = pageReference.state.c__Reporter;
        var caseId = pageReference.state.c__caseId;
        var caseLink = pageReference.state.c__caseLink;
        
        desc = desc.replaceAll('%','%25');
        desc = desc.replaceAll(',','%2C');
        desc = desc.replaceAll('\n','<br>');
        desc = desc.replaceAll('=','%3D');
        summary = summary.replaceAll('%','%25');
        summary = summary.replaceAll(',','%2C');
        summary = summary.replaceAll('=','%3D');
        
        desc = encodeURIComponent(desc);
        summary = encodeURIComponent(summary);
        
        component.set("v.desc",desc);
        component.set("v.summary", summary);
        component.set("v.caseId",caseId);
        component.set("v.assignee",assignee);
        component.set("v.businessAnalyst", businessAnalyst);
		component.set("v.caseId", pageReference.state.c__caseId);
        component.set("v.reporter",reporter);
        component.set("v.caseLink",caseLink);
        
        var action = component.get("c.checkIfCrExists");
        action.setParams({
            caseId : pageReference.state.c__caseId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result :'+result);
                if(result != null){
                    component.set("v.caseNumber",result);
                    component.set("v.showModal", true);
                }else{
                    
                    var crDesc = desc +'<br>'+ caseLink;
        			var url = '/lightning/o/Tracker_Change_Request__c/new?useRecordTypeCheck=1&defaultFieldValues=Type__c=Issue/Bug,Stage__c=Backlog,Priority__c=Critical,Assignee__c='+assignee+',Business_Analyst__c='+businessAnalyst+',Reporter__c='+reporter+',Case__c='+caseId+',Description__c='+crDesc+',Summary__c='+summary;
                    window.open(url, '_self');
                }
            }
        });
        $A.enqueueAction(action);
	},
	closeSelection: function(component, event, helper){
        if (component.get('v.caseId')) {
            window.open('/' + component.get('v.caseId'), '_self');
        }
    },
    
    createCR : function(component, event, helper){
        
        var caseHyperLink = component.get('v.caseLink');
        var crDesc = component.get('v.desc') +'<br>'+caseHyperLink;
        console.log('crDesc :'+crDesc);
        var url = '/lightning/o/Tracker_Change_Request__c/new?useRecordTypeCheck=1&defaultFieldValues=Type__c=Issue/Bug,Stage__c=Backlog,Priority__c=Critical,Assignee__c='+component.get('v.assignee')+',Business_Analyst__c='+component.get('v.businessAnalyst')+',Reporter__c='+component.get('v.reporter')+',Case__c='+component.get('v.caseId')+',Description__c='+crDesc+',Summary__c='+component.get('v.summary');
        window.open(url, '_self');
    }
})