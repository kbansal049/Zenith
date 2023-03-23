@RestResource(urlMapping='/OPPDEALREGSYNC/*')
global with sharing class OPPDEALREGSYNC {
    
    @HttpPost
    global static Map<String, String> doPost(List<Opportunity> opptylst, List<Partner> oppartlst) {
        Map<String, String> mapresult = new Map<String, String>();
        System.debug(opptylst);
        System.debug(mapresult);
            if(!opptylst.isEmpty()){
                Database.update(opptylst, false);
                mapresult.put('oppid',opptylst[0].Id);
            }
        /// Delete and add new Deal reg as opportunity partner //
            List<Opportunity_Partner__c> existingOppPartners = [select  id, Opportunity__c,Partner_Type__c from Opportunity_Partner__c where Partner_Type__c = 'Deal Reg' and Opportunity__c = :opptylst[0].Id];
       			 if( existingOppPartners!=null && existingOppPartners.size()>0 ){
            		//database.delete(existingOppPartners,false);
                    Database.DeleteResult[] drList = Database.delete(existingOppPartners, false);
            
            // Iterate through each returned result
            for(Database.DeleteResult dr : drList) {
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
            }
            }
             //create OpportunityPartners for the new opp using imported partner data
                List<Opportunity_Partner__c> newOppPartners = new List<Opportunity_Partner__c>();
                for(Partner part: oppartlst){
                    Opportunity_Partner__c newOppPartner = new Opportunity_Partner__c();
                    newOppPartner.Account__c = part.AccountToId;
                    newOppPartner.Opportunity__c = opptylst[0].Id;
                    newOppPartner.Is_Primary__c = part.IsPrimary;
                    newOppPartner.Partner_Type__c = part.Role;

              //if ceating DR partner, use partner program from Opp for OppPartner as well, and also verify that it is a valid picklist option
                    if(newOppPartner.Partner_Type__c == 'Deal Reg'){
                        List<Schema.PicklistEntry> partnerProgramsOptions = Opportunity_Partner__c.Partner_Program__c.getDescribe().getPicklistValues();
                        for(Schema.PicklistEntry partnerProgramOption: partnerProgramsOptions){
                            if(partnerProgramOption.getValue() == opptylst[0].Primary_Partner_Program__c){
                                newOppPartner.Partner_Program__c = opptylst[0].Primary_Partner_Program__c;
                            }
                        }
                    }
                    newOppPartners.add(newOppPartner);
                }
                insert newOppPartners;
           ///  Delete and add new Deal reg as opportunity partner //
                return mapresult;
    }
}