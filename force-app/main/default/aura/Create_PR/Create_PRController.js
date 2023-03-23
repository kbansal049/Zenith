({
    doinit : function(component, event, helper) {
        
         /* var retUrl = "" + window.parent.location;
        if (retUrl.indexOf('#') > -1) 
        {
            retUrl = retUrl.substr(0, retUrl.indexOf('#'));
        }
		console.log('retUrl '+retUrl);
        let rec = component.get("v.record");
            //var redirectTo = '/apex/ManageSCI?edit=falseretUrl='+retUrl+'&accountId='+rec.fields.Id.value+'&patchTeamId='+rec.fields.Sales_Territory__c.value;
            //var redirectTo = 'https://zscaler--zscalerdev.lightning.force.com/lightning/o/Provisioning_Request__c/new?count=1&nooverride=1&useRecordTypeCheck=1&navigationLocation=MRU_LIST&0.source=alohaHeader';
            //var redirectTo = 'https://zscaler--zscalerdev.lightning.force.com/lightning/o/Provisioning_Request__c/new?count=1&nooverride=1&useRecordTypeCheck=1&0.source=alohaHeader';
            window.open(redirectTo,'_self');
            $A.get('e.force:closeQuickAction').fire(); */ 
			var createRecordEvent = $A.get("e.force:createRecord");
			createRecordEvent.setParams({ 
            "entityApiName": "Provisioning_Request__c"
			});
			createRecordEvent.fire();
    }
})