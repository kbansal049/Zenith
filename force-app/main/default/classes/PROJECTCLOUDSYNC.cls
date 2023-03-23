@RestResource(urlMapping='/PROJECTCLOUDSYNC/*')
global with sharing class PROJECTCLOUDSYNC {
    
    @HttpPost
    global static String doPost(List<Equipment_Request__c> listProductAndServicesOpp) {
        
        Map<String, String> mapresult = new Map<String, String>();
        System.debug(listProductAndServicesOpp);
        Id devRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByName().get('FedRAMP Cloud Services').getRecordTypeId();


        for (Equipment_Request__c e :listProductAndServicesOpp){
            e.RecordTypeId = devRecordTypeId;
        }
        
        System.debug(mapresult);
        if(!listProductAndServicesOpp.isEmpty()){
            Database.upsert(listProductAndServicesOpp, false);
        }
        
        /*        
		// Iterate through each returned result
		for(Database.SaveResult dr : listProductAndServicesOpp) {
		if (dr.isSuccess()) {
		// Operation was successful, so get the ID of the record that was processed
		System.debug('Successfully deleted Opp partner with ID: ' + dr.getId());
		}
		else {
		// Operation failed, so get all errors                
		for(Database.Error err : dr.getErrors()) {
		System.debug('The following error has occurred.');                    
		System.debug(err.getStatusCode() + ': ' + err.getMessage());
		System.debug('Opp partner fields that affected this error: ' + err.getFields());
	}
	}
	}*/
        return 'Passed';
    }
    
}