global class FC_Plugin_ResponseAccelerator Implements FCRM.FCR_ExtensibilityAPI.IExtensibilityPlugin
{
    @testVisible private static Boolean MockDMLError = false;

    global void ExtensibilityEvent(String eventname, FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args)
    {
        // Perform your hook operation based on the event name (eventname) // and arguments (args)
        if(eventname == FCRM.FCR_ExtensibilityAPI.REACTIVATIONCOMPLETE)
        {
            /**
             * Process Builder reactivation is triggered by a new opportunity. 
             * If the sequence decides to add a new campaign member, the opportunity is expected to be tied to it.
             * Problem is the opp created date is earlier than response date, and normal RM processing will cause negative velocity in the funnel.
             * The simple solution is to identify new campaign members without opportunities, and pretend they were created earlier than the opportunity.
             */
            if(args == null || args.getRecordMaps() == null || args.getRecordLists() == null || args.getAdditionalParams() == null)
            {
                return;
            }
            Map<ID, SObject> contactmap = args.getRecordMaps()[1]; //index 0: leadsmap
            List<CampaignMember> activecms = args.getRecordLists()[0]; //index 0: successes, 1: retried, 2: failed
            Integer reactivationScenario = (Integer)(args.getAdditionalParams()[0]);

            Integer lookbackTimeframe = 5; // Only look for responses with a response date later than right now minus the specified minutes.
            Integer minutesBeforeOpp = 2; // Number of minutes to set the response behind its opportunity created date.

            // Work around until we query the fields requested in the API
            if(activecms.size() > 0 && activecms[0].FCRM__FCR_Response_Date__c == null)
            {
                Set<ID> cmIds = new Set<ID>();
                for(CampaignMember cm: activecms) cmIds.add(cm.Id);
                activecms = [SELECT Id, ContactId, FCRM__FCR_Response_Date__c, FCRM__FCR_Opportunity__c, FCRM__FCR_Reactivation_Date__c FROM CampaignMember WHERE Id in :cmIds];
            }
            
            // Keeping this list outside of the reactivaion scenario == 3 to upsert any other potential ReactivationComplete plugins within the same DML.
            List<CampaignMember> cmsToUpsert = new List<CampaignMember>();

            if(reactivationScenario == 3)
            {
                //3 = process builder reactivation scenario
                Map<Id, List<CampaignMember>> negativeVelocityCMsByContactId = new Map<Id, List<CampaignMember>>();
                for(CampaignMember cm: activecms)
                {
                    // Only campaign members with an active status that are not tied to an Opportunity are valid.
                    if(cm.FCRM__FCR_Opportunity__c != null)
                        continue;
                    // If the campaign member FCR_Reactivation_Date__c is not null it means is is not a new response date.
                    if(cm.FCRM__FCR_Reactivation_Date__c != null)
                        continue;
                    // The FCR_Response_Date__c custom field should be within the last 5 minutes.
                    if(cm.FCRM__FCR_Response_Date__c < DateTime.Now().addMinutes(-lookbackTimeframe) )
                        continue;
                    // The campaign member is tied to one of the default Campaigns specified in Process Builder reactivation scenario configuration.
                    // NOTE: this condition is not necessary but we will implement the following API call: FCRM.FCR_SupportAPI.getPBRoleBasedDefaultCampaigns();

                    // Campaign Members who can be matched to an opportunity earlier than their response date.
                    if(negativeVelocityCMsByContactId.get(cm.ContactId) != null){
                        negativeVelocityCMsByContactId.get(cm.ContactId).add(cm); // The contacts for both campaign members and potential opportunities.
                    } else {
                        negativeVelocityCMsByContactId.put(cm.ContactId, new List<CampaignMember>{cm});
                    }
                }

                Map<Id, Id> oppIdsToContacts = new Map<Id, Id>();
                // Find the opportunities that may be getting associated soon, make sure to grab CreatedDate.
                List<OpportunityContactRole> ocrs = [SELECT Id, OpportunityId, Opportunity.CreatedDate, ContactId, Contact.Latest_Opportunity_Date__c FROM OpportunityContactRole WHERE ContactId in :negativeVelocityCMsByContactId.keySet() 
                                                        AND Opportunity.FCRM__FCR_Response_ID__c = NULL AND IsPrimary = TRUE AND CreatedDate > :Date.today().addDays(-1)];
                for(OpportunityContactRole ocr: ocrs)
                {
                    // Add all of the opportunities with the same primary contact as the campaign members
                    
                    DateTime oppCreatedDate = ocr.Opportunity.CreatedDate;
                    Id contactId = ocr.ContactId;
                    List<CampaignMember> potentialCMs = negativeVelocityCMsByContactId.get(contactId);
                    for(CampaignMember cm: potentialCMs)
                    {
                        //NOTE: There should really only be 1 active campaign member per contact, we should be prepared for more though.
                        if(cm.FCRM__FCR_Response_Date__c > oppCreatedDate && oppCreatedDate.date() == ocr.Contact.Latest_Opportunity_Date__c)
                        {
                            // This campaign member was created after the opportunity.
                            cm.FCRM__FCR_Response_Date__c = oppCreatedDate.addMinutes(-minutesBeforeOpp);
                            cmsToUpsert.add(cm);
                            break;
                        }
                    }
                }
            }
            
            try{
                if(cmsToUpsert.size() > 0)
                {
                    if(MockDMLError) {
                        cmsToUpsert[0].id = null;
                    }
                    Database.upsert(cmsToUpsert);
                    // Insert success log
                    FCRM.FCR_SupportAPI.ReportDiagnosticInfo(null, 'Success! ReactivaionComplete plugin successfully updated response date on campaign member');
                } else {
                    // Insert nothing to upsert log
                    FCRM.FCR_SupportAPI.ReportDiagnosticInfo(null, 'Warning - ReactivationComplete plugin did not find campaign members to update.');
                }
            } catch (Exception ex) {
                // Insert log about upsert failing.
                FCRM.FCR_SupportAPI.ReportDiagnosticInfo(ex, 'Exception occured during ReactivationComplete Hook:');
            }
        }
    }
    global String GetUniqueName()
    {
        return('FC_Plugin_ResponseAccelerator');
    }
    global SET<String> RequestedAPIs()
    {
        return new Set<String>{FCRM.FCR_ExtensibilityAPI.REACTIVATIONCOMPLETE};
    }
    global Map<String,Set<String>> RequestedFields()
    {
        return null;
    }
}