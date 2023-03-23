/*
TestClass CampaignMemberTriggerHelperTest
*/
trigger genericCampaignMemberTrigger on CampaignMember (before insert, before update, after insert, after update ) {
    if(trigger.isbefore && (trigger.isUpdate || trigger.isInsert)){
        list<id> conIdlist = new list<Id>();
        list<id> leadIdlist = new list<Id>();
        map<id, id> conleadIdterritoryIdMap = new map<Id, Id>();
        map<id, sObject> conleadIdsObjectMap = new map<Id, sObject>(); // Rajesh CR 1124 : Start
        for(CampaignMember camp : trigger.new){
            if(camp.ContactId != null)
                conIdlist.add(camp.ContactId);
            if(camp.leadId != null)
                leadIdlist.add(camp.leadId);
        }
        // Changed by Rajesh CR 1124 : removed Patch__c != null from below SOQL
        
        if(!leadIdlist.isEmpty()){
            for(lead le : [Select Id, Patch__c, Patch__r.PatchTeam__c, Qualification_Notes__c,Person_MQL_Date__c,MQL_Date__c from Lead where ID IN: leadIdList]){
                if(le.Patch__c != null){
                    conleadIdterritoryIdMap.put(le.Id, Le.Patch__r.PatchTeam__c);
                }
                
                // Rajesh CR 1124 : Start //added Person_MQL_Date__c,MQL_Date__c by SWathi CR 1505
                if(le.Qualification_Notes__c != null || le.Person_MQL_Date__c!=Null || le.MQL_Date__c!=Null){
                    conleadIdsObjectMap.put(le.Id,le);
                }
                // Rajesh CR 1124 : End
            }
        }
        
        if(!conIdlist.isEmpty()){
            for(Contact con : [Select Id, Patch__c, Patch__r.PatchTeam__c, Qualification_Notes__c,Person_MQL_Date__c,MQL_Date__c from Contact where ID IN: conIdlist]){
                if(con.Patch__c != null){
                    conleadIdterritoryIdMap.put(con.Id, con.Patch__r.PatchTeam__c);
                }
                // Rajesh CR 1124 : Start //added Person_MQL_Date__c,MQL_Date__c by SWathi CR 1505
                if(con.Qualification_Notes__c != null || con.Person_MQL_Date__c!=Null || con.MQL_Date__c!=Null){
                    conleadIdsObjectMap.put(con.Id,con);
                }
                // Rajesh CR 1124 : End
            }
        }
        
        for(CampaignMember camp : trigger.new){
            if(camp.ContactId != null){
                camp.Territory__c = conleadIdterritoryIdMap.get(camp.ContactId);
                // Rajesh CR 1124 : Start
                if(conleadIdsObjectMap.containsKey(camp.ContactId)){
                    Contact con = (Contact)conleadIdsObjectMap.get(camp.ContactId);
                    if(con.Qualification_Notes__c!=null)
                        camp.Qualification_Notes__c = con.Qualification_Notes__c;
                    //added by SWathi : CR 1505 Start
                    if(con.Person_MQL_Date__c!=null && camp.Person_MQL_Date_Stamped__c == null)
                        camp.Person_MQL_Date_Stamped__c = con.Person_MQL_Date__c;
                    if(con.MQL_Date__c!=null && camp.MQL_Date_Stamped__c == null)
                        camp.MQL_Date_Stamped__c = con.MQL_Date__c;
                    //added by SWathi : CR 1505 End
                }
                // Rajesh CR 1124 : End
            }
            if(camp.leadId != null){
                camp.Territory__c = conleadIdterritoryIdMap.get(camp.leadId);
                // Rajesh CR 1124 : Start
                if(conleadIdsObjectMap.containsKey(camp.leadId)){
                    Lead ld = (Lead)conleadIdsObjectMap.get(camp.leadId);
                    if(ld.Qualification_Notes__c!=null)
                        camp.Qualification_Notes__c = ld.Qualification_Notes__c;
                    //added by SWathi : CR 1505 Start
                    if(ld.Person_MQL_Date__c!=null && camp.Person_MQL_Date_Stamped__c == null)
                        camp.Person_MQL_Date_Stamped__c = ld.Person_MQL_Date__c;
                    if(ld.MQL_Date__c!=null && camp.MQL_Date_Stamped__c == null)
                        camp.MQL_Date_Stamped__c = ld.MQL_Date__c;
                    //added by SWathi : CR 1505 end
                }
                // Rajesh CR 1124 : End
            }
            
        }
    }

    if(trigger.isAfter && trigger.isInsert){
        if(CampaignMemberTriggerHelper.skipTrigger == false)
        {
            //Added for CR-2271 - Varun  Start
            //if(!TriggerUtility.isUpdateLeadContactForCampExecuted())
            //{
            //CampaignMemberTriggerHelper.updateLeadContactForCamp(trigger.new);
            
            if(!TriggerUtility.isUpdateLeadForCampExecuted()){
                CampaignMemberTriggerHelper.updateLeadForCamp(Trigger.NewMap.keySet());
                CampaignMemberTriggerHelper.skipTrigger = true;
            }
        }
        if(CampaignMemberTriggerHelper.skipTrigger2 == false)
        {
            if(!TriggerUtility.isUpdateContactForCampExecuted()){
                CampaignMemberTriggerHelper.updateContactForCamp(Trigger.NewMap.keySet());
                CampaignMemberTriggerHelper.skipTrigger2 = true;
            }  
        }//Added for CR-2271 - Varun  End
        
    }
}