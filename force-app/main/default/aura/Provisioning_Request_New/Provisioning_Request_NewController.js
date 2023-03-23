({
    recordUpdate: function(component, event, helper) {
        helper.recordUpdateHelper(component, event, helper);
    },
    createFeVaCloudRec: function(component, event, helper) {
        helper.callRecordHelper(component, event, helper, false, '');
    },
    recordTypeSelected: function(component, event, helper) {
        helper.createRecord(component, event, helper); 
    },
    handleCancel : function(component, event, helper){
        helper.handleCancelHelper(component, event, helper);
    },
    handleChange : function(component, event, helper){
    	helper.handleChangeHelper(component, event, helper);	
	}
})