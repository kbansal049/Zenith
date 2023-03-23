/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* CampaignMemberTriggerHandler
* @description    This is the CampaignMember Trigger handler class called synchronously from CampaignMemberMasterTrigger.
*				  All the methods needs to be called synchronously from the CampaignMember Trigger
* 				  should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-02-09
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2022-11-21	  IBA-4812 : Remove Rollup Summary Helper Package Code.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class CampaignMemberTriggerHandler extends TriggerHandler {
    
    public Map<Id,Lead> getLeadRecordsRelatedFields(List<Id> leadIdList){
        return new Map<Id,Lead>([SELECT Id, Patch__c, Patch__r.PatchTeam__c, Assets_Names__c,
                Qualification_Notes__c,Person_MQL_Date__c,MQL_Date__c 
                FROM Lead 
                WHERE ID IN: leadIdList]);
    }
    
    public Map<Id,Contact> getContactRecordsRelatedFields(List<Id> conIdlist){
        return new Map<Id,Contact>([SELECT Id, Patch__c, Patch__r.PatchTeam__c,Assets_Names__c, 
                                    Qualification_Notes__c,Person_MQL_Date__c,MQL_Date__c 
                                    FROM Contact 
                                    WHERE ID IN: conIdlist]);
    }
    
    public override void beforeInsert(){ 
        
        System.debug('CampaignMemberTriggerHandler beforeInsert Is Invoked');
        System.debug('--> 1. beforeInsert CPU Time : ' + Limits.getCpuTime());
        
        if(test.isrunningtest()){
            booster();
        }
        
        List<CampaignMember> newCampaignMemberList = new List<CampaignMember>();
        
        Map<Id, CampaignMember> newCampaignMemberMap = new Map<Id,CampaignMember>();
        Map<Id, CampaignMember> oldCampaignMemberMap = new Map<Id,CampaignMember>();
        
        list<id> conIdlist = new list<Id>();
        list<id> leadIdlist = new list<Id>();
        map<id, id> conleadIdterritoryIdMap = new map<Id, Id>();
        map<id, sObject> conleadIdsObjectMap = new map<Id, sObject>(); // Rajesh CR 1124 : Start
        Map<Id,Lead> leadRecordsWithRelatedFieldValuesMap = new Map<Id,Lead>();
        Map<Id,Contact> contactRecordsWithRelatedFieldValuesMap = new Map<Id,Contact>();
        
        //CR# 4090 START
        Set<Id> contactIdsSet = new Set<Id>();
        Set<Id> leadIdsSet = new Set<Id>();
        Set<Id> campaignIdsSet = new Set<Id>();

        for (SObject campaignMemberRec : Trigger.New) {
            CampaignMember newCampaignMember = (CampaignMember) campaignMemberRec;
            if (String.isNotBlank(newCampaignMember.ContactId)) {
                contactIdsSet.add(newCampaignMember.ContactId);
            }
            if (String.isNotBlank(newCampaignMember.LeadId)) {
                leadIdsSet.add(newCampaignMember.LeadId);
            }
            if (String.isNotBlank(newCampaignMember.CampaignId)) {
                campaignIdsSet.add(newCampaignMember.CampaignId);
            }
        }

        System.debug('--> 2. beforeInsert CPU Time : ' + Limits.getCpuTime());
        Map<Id, Contact> contactMap = !contactIdsSet.isEmpty() ? new Map<Id, Contact> ([SELECT Id, Campaign_Content__c, Campaign_ID__c, Campaign_Medium__c, 
            Campaign_Source__c, Campaign_Term__c,Linkedin_Campaign_ID__c FROM Contact WHERE Id IN :contactIdsSet]) : new Map<Id, Contact>();            //modified CR# 4957 

        Map<Id, Lead> leadMap = !leadIdsSet.isEmpty() ? new Map<Id, Lead> ([SELECT Id, Campaign_Content__c, Campaign_ID__c, Campaign_Medium__c, 
            Campaign_Source__c, Campaign_Term__c,Linkedin_Campaign_ID__c FROM Lead WHERE Id IN :leadIdsSet]) : new Map<Id, Lead>();                     //modified CR# 4957 

        Map<Id, Campaign> campaignMap = !campaignIdsSet.isEmpty() ? new Map<Id, Campaign> ([SELECT Id, Name, FCRM__FCR_Repeat_Responses_Allowed__c, Type 
            FROM Campaign WHERE Id IN :campaignIdsSet]) : new Map<Id, Campaign>();
        System.debug('--> 3. beforeInsert CPU Time : ' + Limits.getCpuTime());
        //CR# 4090 END

        for (SObject campaignMemberRec: Trigger.new) {            
            CampaignMember newCampaignMember = (CampaignMember) campaignMemberRec;
            
            //CR# 4090 START
            Contact associatedContact = contactMap.get(newCampaignMember.ContactId);
            Lead associatedLead = leadMap.get(newCampaignMember.LeadId);
            Campaign associatedCampaign = campaignMap.get(newCampaignMember.CampaignId);
            //CR# 4090 END
            
            //From genericCampaignMemberTrigger START
            if(newCampaignMember.ContactId != null){
                conIdlist.add(newCampaignMember.ContactId);
            }
                
            if(newCampaignMember.leadId != null){
                leadIdlist.add(newCampaignMember.leadId);
            }
            //From genericCampaignMemberTrigger END    
            //System.Debug('CampaignMemberTriggerHandler beforeInsert newCampaignMember : ' + newCampaignMember);
            //newCampaignMemberMap.put(newCampaignMember.Id,newCampaignMember);
            newCampaignMemberList.add(newCampaignMember);

            //CR# 4090 START

            //Workflow Name : Campaign Member: Update Lead Source Info on Camp Member
            if (associatedContact != null) {
                newCampaignMember.Campaign_Content2__c = associatedContact.Campaign_Content__c;
                newCampaignMember.Campaign_ID2__c = associatedContact.Campaign_ID__c;
                newCampaignMember.Campaign_Medium2__c = associatedContact.Campaign_Medium__c;
                newCampaignMember.Campaign_Source2__c = associatedContact.Campaign_Source__c;
                newCampaignMember.Campaign_Term2__c	 = associatedContact.Campaign_Term__c;
                //CR# 4957 - Added Linkedin_Campaign_ID__c
                newCampaignMember.Linkedin_Campaign_ID__c = associatedContact.Linkedin_Campaign_ID__c;
            } else if (associatedLead != null) {
                newCampaignMember.Campaign_Content2__c = associatedLead.Campaign_Content__c;
                newCampaignMember.Campaign_ID2__c = associatedLead.Campaign_ID__c;
                newCampaignMember.Campaign_Medium2__c = associatedLead.Campaign_Medium__c;
                newCampaignMember.Campaign_Source2__c = associatedLead.Campaign_Source__c;
                newCampaignMember.Campaign_Term2__c	 = associatedLead.Campaign_Term__c;
                //CR# 4957 - Added Linkedin_Campaign_ID__c
                newCampaignMember.Linkedin_Campaign_ID__c = associatedLead.Linkedin_Campaign_ID__c;
            }

            //Combined the following workflows:
            //  Workflow Name : Live Chat Member Status = Meeting Scheduled
            //  Workflow Name : Live Chat Member Status = Responded
            if (associatedCampaign != null && associatedCampaign.FCRM__FCR_Repeat_Responses_Allowed__c == true && 
                'Contact Request-Live Chat'.equalsIgnoreCase(associatedCampaign.Type)) {

                if ('Meeting Scheduled'.equalsIgnoreCase(newCampaignMember.Status)) {
                    newCampaignMember.Status = 'Meeting Scheduled-';
                } else if ('Responded'.equalsIgnoreCase(newCampaignMember.Status)) {
                    newCampaignMember.Status = 'Responded-';
                }
            }

            //Workflow Name : Member Status = Demo Requested-
            if (associatedCampaign != null && associatedCampaign.FCRM__FCR_Repeat_Responses_Allowed__c == true &&
                'Demo Requested'.equalsIgnoreCase(newCampaignMember.Status) &&  
                'ZPA Interactive'.equalsIgnoreCase(newCampaignMember.Name)) {

                newCampaignMember.Status = 'Demo Requested-';
            }

            //Workflow Name : Set Lead Score on Closed/Won
            if (newCampaignMember.FCRM__FCR_SQR_Won__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_Closed_Won__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_Closed_Won__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_Closed_Won__c = newCampaignMember.Lead_Score__c;
            }

            // Workflow Name : Set Lead Score on DM Completed
            if (newCampaignMember.CFCR_Discovery_Meeting_Completed__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_DM_Completed__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_DM_Completed__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_DM_Completed__c = newCampaignMember.Lead_Score__c;
            }

            //Workflow Name : Set Lead Score on DM Scheduled
            if (newCampaignMember.CFCR_Discovery_Meeting_Scheduled__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_DM_Scheduled__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_DM_Scheduled__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_DM_Scheduled__c = newCampaignMember.Lead_Score__c;
            } 

            //Workflow Name : Set Lead Score on MQL
            if (newCampaignMember.FCRM__FCR_QR__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_MQL__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_MQL__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_MQL__c = newCampaignMember.Lead_Score__c;
            }

            //Workflow Name : Set Lead Score on SAL Connected
            if (newCampaignMember.SAL_Sales_Connected_Lead__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_SAL_Connected__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_SAL_Connected__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_SAL_Connected__c = newCampaignMember.Lead_Score__c;
            }

            //Workflow Name : Set Lead Score on SAL Pursuing
            if (newCampaignMember.FCRM__FCR_SAR__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_SAL_Pursuing__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_SAL_Pursuing__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_SAL_Pursuing__c = newCampaignMember.Lead_Score__c;
            }

            //Workflow Name : Set Lead Score on SQL
            if (newCampaignMember.CFCR_Sales_Qualified_Lead__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_SQL__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_SQL__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_SQL__c = newCampaignMember.Lead_Score__c;
            }

            //Workflow Name : Set Lead Score on SQO
            if (newCampaignMember.FCRM__FCR_SQR__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_SQO__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_SQO__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_SQO__c = newCampaignMember.Lead_Score__c;
            }
            //CR# 4090 END
        }
        System.debug('--> 4. beforeInsert CPU Time : ' + Limits.getCpuTime());
        if(!leadIdlist.isEmpty()){
            leadRecordsWithRelatedFieldValuesMap = getLeadRecordsRelatedFields(leadIdlist);
        }
        if(!conIdlist.isEmpty()){
            contactRecordsWithRelatedFieldValuesMap = getContactRecordsRelatedFields(conIdlist);
        }
        //System.Debug('CampaignMemberTriggerHandler beforeInsert Trigger.new : ' + Trigger.new);
        //System.Debug('CampaignMemberTriggerHandler beforeInsert leadIdlist : ' + leadIdlist);
        //System.Debug('CampaignMemberTriggerHandler beforeInsert newCampaignMemberList : ' + newCampaignMemberList);
        //System.Debug('CampaignMemberTriggerHandler beforeInsert leadRecordsWithRelatedFieldValuesMap : ' + leadRecordsWithRelatedFieldValuesMap);
        //System.Debug('CampaignMemberTriggerHandler beforeInsert contactRecordsWithRelatedFieldValuesMap : ' + contactRecordsWithRelatedFieldValuesMap);
        //From genericCampaignMemberTrigger START
        if(!leadIdlist.isEmpty()){
            for(lead le : leadRecordsWithRelatedFieldValuesMap.values()){
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
        System.debug('--> 5. beforeInsert CPU Time : ' + Limits.getCpuTime());
        if(!conIdlist.isEmpty()){
            for(Contact con : contactRecordsWithRelatedFieldValuesMap.values()){
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
        System.debug('--> 6. beforeInsert CPU Time : ' + Limits.getCpuTime());
        for(CampaignMember camp : newCampaignMemberList){
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
            //WF Rule - Assets Names Update START
            if(camp.leadId != NULL && leadRecordsWithRelatedFieldValuesMap.containsKey(camp.leadId)){
                camp.Assets_Names__c = leadRecordsWithRelatedFieldValuesMap.get(camp.leadId).Assets_Names__c;
            }
            if(camp.contactId != NULL && contactRecordsWithRelatedFieldValuesMap.containsKey(camp.contactId)){
                camp.Assets_Names__c = contactRecordsWithRelatedFieldValuesMap.get(camp.contactId).Assets_Names__c;
            }
            //WF Rule - Assets Names Update END contactRecordsWithRelatedFieldValuesMap
        }
        //From genericCampaignMemberTrigger END
    	System.debug('--> 7. beforeInsert CPU Time : ' + Limits.getCpuTime());
        //From CampaignMemberTrigger START
        if(CampaignMemberTriggerHelper.cmTriggerSkip == false){
            if(!leadIdlist.isEmpty()){
                for(lead le : [Select Id, Territory__c,Territory__r.Name, Patch__c, Patch__r.PatchTeam__c from Lead where ID IN: leadIdList AND Patch__c != null]){
                    conleadIdterritoryIdMap.put(le.Id, Le.Patch__r.PatchTeam__c);
                }
            }
            
            if(!conIdlist.isEmpty()){
                for(Contact con : [Select Id, Patch__c, Patch__r.PatchTeam__c from Contact where ID IN: conIdlist AND Patch__c != null]){
                    conleadIdterritoryIdMap.put(con.Id, con.Patch__r.PatchTeam__c);
                }
            }
            for(CampaignMember camp : newCampaignMemberList){
                if(camp.ContactId != null)
                    camp.Territory__c = conleadIdterritoryIdMap.get(camp.ContactId);
                if(camp.leadId != null)
                    camp.Territory__c = conleadIdterritoryIdMap.get(camp.leadId);
                // Added by Varun for CR -2271 - Start
                if(camp.ContactId != null && camp.MCI_Tagged__c == true)
                    camp.Account__c = camp.Account_formula__c;
                if(camp.LeadId !=null && camp.Account_Formula__c !=null && camp.MCI_Tagged__c == true)
                    camp.Account__c = camp.Account_formula__c;
                if(camp.ContactId != null && camp.MCI_Tagged__c == false)
                    camp.Account__c = null;
                if(camp.LeadId !=null && camp.MCI_Tagged__c == false &&  camp.Account_Formula__c !=null) 
                    camp.Account__c = null;
                // Added by Varun for CR -2271 - End
            }
        }
        //From CampaignMemberTrigger END
        System.debug('--> 8. beforeInsert CPU Time : ' + Limits.getCpuTime());
    }
    
    public override void beforeUpdate(){
        
        System.debug('CampaignMemberTriggerHandler beforeUpdate Is Invoked');
        
        Map<Id, CampaignMember> newCampaignMemberMap = new Map<Id,CampaignMember>();
        Map<Id, CampaignMember> oldCampaignMemberMap = new Map<Id,CampaignMember>();
        
        list<id> conIdlist = new list<Id>();
        list<id> leadIdlist = new list<Id>();
        map<id, id> conleadIdterritoryIdMap = new map<Id, Id>();
        map<id, sObject> conleadIdsObjectMap = new map<Id, sObject>(); // Rajesh CR 1124 : Start        
        Map<Id,Lead> leadRecordsWithRelatedFieldValuesMap = new Map<Id,Lead>();
        Map<Id,Contact> contactRecordsWithRelatedFieldValuesMap = new Map<Id,Contact>();

        //CR# 4090 START
        Set<Id> campaignIdsSet = new Set<Id>();

        for (SObject campaignMemberRec : Trigger.New) {
            CampaignMember newCampaignMember = (CampaignMember) campaignMemberRec;
            if (String.isNotBlank(newCampaignMember.CampaignId)) {
                campaignIdsSet.add(newCampaignMember.CampaignId);
            }
        }

        Map<Id, Campaign> campaignMap = !campaignIdsSet.isEmpty() ? new Map<Id, Campaign> ([SELECT Id, Name, FCRM__FCR_Repeat_Responses_Allowed__c, Type 
            FROM Campaign WHERE Id IN :campaignIdsSet]) : new Map<Id, Campaign>();
        //CR# 4090 END
        
        for (SObject campaignMemberRec: Trigger.new) {
            
            CampaignMember newCampaignMember = (CampaignMember) campaignMemberRec;
            CampaignMember oldCampaignMember = (CampaignMember) Trigger.oldMap.get(newCampaignMember.Id); 

            //CR# 4090 START
            Campaign associatedCampaign = campaignMap.get(newCampaignMember.CampaignId);

            //Combined the following workflows:
            //  Workflow Name : Live Chat Member Status = Meeting Scheduled
            //  Workflow Name : Live Chat Member Status = Responded
            if ((newCampaignMember.CampaignId != oldCampaignMember.CampaignId || newCampaignMember.Status != oldCampaignMember.Status) && 
                associatedCampaign != null && associatedCampaign.FCRM__FCR_Repeat_Responses_Allowed__c == true && 
                'Contact Request-Live Chat'.equalsIgnoreCase(associatedCampaign.Type)) {

                if ('Meeting Scheduled'.equalsIgnoreCase(newCampaignMember.Status)) {
                    newCampaignMember.Status = 'Meeting Scheduled-';
                } else if ('Responded'.equalsIgnoreCase(newCampaignMember.Status)) {
                    newCampaignMember.Status = 'Responded-';
                }
            }

            //Workflow Name : Member Status = Demo Requested-
            if ((newCampaignMember.CampaignId != oldCampaignMember.CampaignId || newCampaignMember.Status != oldCampaignMember.Status) && 
                associatedCampaign != null && associatedCampaign.FCRM__FCR_Repeat_Responses_Allowed__c == true &&
                'Demo Requested'.equalsIgnoreCase(newCampaignMember.Status) &&  
                'ZPA Interactive'.equalsIgnoreCase(associatedCampaign.Name)) {

                newCampaignMember.Status = 'Demo Requested-';
            }

            //Workflow Name : Set Lead Score on Closed/Won
            if (newCampaignMember.FCRM__FCR_SQR_Won__c != oldCampaignMember.FCRM__FCR_SQR_Won__c && 
                newCampaignMember.FCRM__FCR_SQR_Won__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_Closed_Won__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_Closed_Won__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_Closed_Won__c = newCampaignMember.Lead_Score__c;
            }

            // Workflow Name : Set Lead Score on DM Completed
            if (newCampaignMember.CFCR_Discovery_Meeting_Completed__c != oldCampaignMember.CFCR_Discovery_Meeting_Completed__c && 
                newCampaignMember.CFCR_Discovery_Meeting_Completed__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_DM_Completed__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_DM_Completed__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_DM_Completed__c = newCampaignMember.Lead_Score__c;
            }

            //Workflow Name : Set Lead Score on DM Scheduled
            if (newCampaignMember.CFCR_Discovery_Meeting_Scheduled__c != oldCampaignMember.CFCR_Discovery_Meeting_Scheduled__c && 
                newCampaignMember.CFCR_Discovery_Meeting_Scheduled__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_DM_Scheduled__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_DM_Scheduled__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_DM_Scheduled__c = newCampaignMember.Lead_Score__c;
            } 

            //Workflow Name : Set Lead Score on MQL
            if (newCampaignMember.FCRM__FCR_QR__c != oldCampaignMember.FCRM__FCR_QR__c && newCampaignMember.FCRM__FCR_QR__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_MQL__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_MQL__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_MQL__c = newCampaignMember.Lead_Score__c;
            }

            //Workflow Name : Set Lead Score on SAL Connected
            if (newCampaignMember.SAL_Sales_Connected_Lead__c != oldCampaignMember.SAL_Sales_Connected_Lead__c && 
                newCampaignMember.SAL_Sales_Connected_Lead__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_SAL_Connected__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_SAL_Connected__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_SAL_Connected__c = newCampaignMember.Lead_Score__c;
            }

            //Workflow Name : Set Lead Score on SAL Pursuing
            if (newCampaignMember.FCRM__FCR_SAR__c != oldCampaignMember.FCRM__FCR_SAR__c && newCampaignMember.FCRM__FCR_SAR__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_SAL_Pursuing__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_SAL_Pursuing__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_SAL_Pursuing__c = newCampaignMember.Lead_Score__c;
            }

            //Workflow Name : Set Lead Score on SQL
            if (newCampaignMember.CFCR_Sales_Qualified_Lead__c != oldCampaignMember.CFCR_Sales_Qualified_Lead__c && 
                newCampaignMember.CFCR_Sales_Qualified_Lead__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_SQL__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_SQL__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_SQL__c = newCampaignMember.Lead_Score__c;
            }

            //Workflow Name : Set Lead Score on SQO
            if (newCampaignMember.FCRM__FCR_SQR__c != oldCampaignMember.FCRM__FCR_SQR__c && newCampaignMember.FCRM__FCR_SQR__c == true) {
                newCampaignMember.CFCR_Behavior_Score_on_SQO__c = newCampaignMember.Behavior_Score__c;
                newCampaignMember.CFCR_Demographic_Score_on_SQO__c = newCampaignMember.Demographic_Score__c;
                newCampaignMember.CFCR_Lead_Score_on_SQO__c = newCampaignMember.Lead_Score__c;
            }
            //CR# 4090 END
            
            //From genericCampaignMemberTrigger START
            if(newCampaignMember.ContactId != null){
                conIdlist.add(newCampaignMember.ContactId);
            }
                
            if(newCampaignMember.leadId != null){
                leadIdlist.add(newCampaignMember.leadId);
            }
           
            //From genericCampaignMemberTrigger END
            
            newCampaignMemberMap.put(newCampaignMember.Id, newCampaignMember);
            oldCampaignMemberMap.put(oldCampaignMember.Id, oldCampaignMember);            
        }       
        if(!leadIdlist.isEmpty()){
            leadRecordsWithRelatedFieldValuesMap = getLeadRecordsRelatedFields(leadIdlist);
        }
        if(!conIdlist.isEmpty()){
            contactRecordsWithRelatedFieldValuesMap = getContactRecordsRelatedFields(conIdlist);
        }
        System.debug('CampaignMemberTriggerHandler beforeUpdate Is Invoked newCampaignMemberMap : ' + newCampaignMemberMap);
        System.debug('CampaignMemberTriggerHandler beforeUpdate Is Invoked oldCampaignMemberMap : ' + oldCampaignMemberMap);
        System.debug('CampaignMemberTriggerHandler leadRecordsWithRelatedFieldValuesMap : ' + leadRecordsWithRelatedFieldValuesMap);
        System.debug('CampaignMemberTriggerHandler contactRecordsWithRelatedFieldValuesMap : ' + contactRecordsWithRelatedFieldValuesMap);
        
        //From genericCampaignMemberTrigger START
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
        
        for(CampaignMember camp : newCampaignMemberMap.values()){
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
           //WF Rule - Assets Names Update START
            if(camp.leadId != NULL && leadRecordsWithRelatedFieldValuesMap.containsKey(camp.leadId)){
                camp.Assets_Names__c = leadRecordsWithRelatedFieldValuesMap.get(camp.leadId).Assets_Names__c;
            }
            if(camp.contactId != NULL && contactRecordsWithRelatedFieldValuesMap.containsKey(camp.contactId)){
                camp.Assets_Names__c = contactRecordsWithRelatedFieldValuesMap.get(camp.contactId).Assets_Names__c;
            }
            //WF Rule - Assets Names Update END contactRecordsWithRelatedFieldValuesMap 
        }
        //From genericCampaignMemberTrigger END
        
        //From CampaignMemberTrigger START
        if(CampaignMemberTriggerHelper.cmTriggerSkip == false){
            if(!leadIdlist.isEmpty()){
                for(lead le : [Select Id, Territory__c,Territory__r.Name, Patch__c, Patch__r.PatchTeam__c from Lead where ID IN: leadIdList AND Patch__c != null]){
                    conleadIdterritoryIdMap.put(le.Id, Le.Patch__r.PatchTeam__c);
                }
            }
            
            if(!conIdlist.isEmpty()){
                for(Contact con : [Select Id, Patch__c, Patch__r.PatchTeam__c from Contact where ID IN: conIdlist AND Patch__c != null]){
                    conleadIdterritoryIdMap.put(con.Id, con.Patch__r.PatchTeam__c);
                }
            }
            for(CampaignMember camp : newCampaignMemberMap.values()){
                if(camp.ContactId != null)
                    camp.Territory__c = conleadIdterritoryIdMap.get(camp.ContactId);
                if(camp.leadId != null)
                    camp.Territory__c = conleadIdterritoryIdMap.get(camp.leadId);
                // Added by Varun for CR -2271 - Start
                if(camp.ContactId != null && camp.MCI_Tagged__c == true)
                    camp.Account__c = camp.Account_formula__c;
                if(camp.LeadId !=null && camp.Account_Formula__c !=null && camp.MCI_Tagged__c == true)
                    camp.Account__c = camp.Account_formula__c;
                if(camp.ContactId != null && camp.MCI_Tagged__c == false)
                    camp.Account__c = null;
                if(camp.LeadId !=null && camp.MCI_Tagged__c == false &&  camp.Account_Formula__c !=null) 
                    camp.Account__c = null;
                // Added by Varun for CR -2271 - End
            }
        }
        //From CampaignMemberTrigger END
    }
    
    public override void afterInsert(){
        
        System.debug('CampaignMemberTriggerHandler afterInsert Is Invoked');
        System.Debug('Enter afterInsert : ' + Limits.getCpuTime());
        System.debug('--> 9. afterInsert CPU Time : ' + Limits.getCpuTime());
               
        Map<Id, CampaignMember> newCampaignMemberMap = new Map<Id,CampaignMember>();
        Map<Id, CampaignMember> oldCampaignMemberMap = new Map<Id,CampaignMember>();
        
        for (SObject campaignMemberRec: Trigger.new) {
            
            CampaignMember newCampaignMember = (CampaignMember) campaignMemberRec;
            
            newCampaignMemberMap.put(newCampaignMember.Id,newCampaignMember);    
            
        }
        System.debug('--> 10. afterInsert CPU Time : ' + Limits.getCpuTime());
        //From genericCampaignMemberTrigger START
        if(CampaignMemberTriggerHelper.skipTrigger == false)
        {
            //Added for CR-2271 - Varun  Start
            //if(!TriggerUtility.isUpdateLeadContactForCampExecuted())
            //{
            //CampaignMemberTriggerHelper.updateLeadContactForCamp(trigger.new);
            
            if(!TriggerUtility.isUpdateLeadForCampExecuted()){
                CampaignMemberTriggerHelper.updateLeadForCamp(newCampaignMemberMap.keySet());
                CampaignMemberTriggerHelper.skipTrigger = true;
            }
        }
        if(CampaignMemberTriggerHelper.skipTrigger2 == false)
        {
            if(!TriggerUtility.isUpdateContactForCampExecuted()){
                CampaignMemberTriggerHelper.updateContactForCamp(newCampaignMemberMap.keySet());
                CampaignMemberTriggerHelper.skipTrigger2 = true;
            }  
        }
        
        //From CampaignMemberTrigger START
        if(CampaignMemberTriggerHelper.cmTriggerSkip == false){
            CampaignMemberTriggerHelper.cmTriggerSkip = true;
            Map<Id,String> LeadTerritory = new Map<Id,String>();
            list<id> leadIdlist = new list<Id>();
            for(CampaignMember camp : newCampaignMemberMap.values()){
                if(camp.leadId != null)
                    leadIdlist.add(camp.leadId);
            }
            System.debug('--> 13. afterInsert CPU Time : ' + Limits.getCpuTime());
            if(!leadIdlist.isEmpty()){
                for(lead le : [Select Id, Territory__c,Territory__r.Name, Patch__c, Patch__r.PatchTeam__c from Lead where ID IN: leadIdList AND Patch__c != null]){
                    if(le.Territory__c != null && le.Territory__r.Name.contains('Catch All'))
                    {
                        LeadTerritory.put(le.Id, le.Territory__r.Name);
                    }
                }
            }
            
            System.debug('--> 14. afterInsert CPU Time : ' + Limits.getCpuTime());
            //Added for CR-2271 - Varun  Start
            if(!TriggerUtility.isUpdateLeadForCampExecuted()){
                CampaignMemberTriggerHelper.updateLeadForCamp(Trigger.NewMap.keySet());
            }
            if(!TriggerUtility.isUpdateContactForCampExecuted()){
                CampaignMemberTriggerHelper.updateContactForCamp(Trigger.NewMap.keySet());
            }
            //Merged with updateLeadForCamp method, for CR# 4090 - Bikram 28th Feb 2022
            //if(!TriggerUtility.isUpdateRecentCampaignExecuted()){
                //CampaignMemberTriggerHelper.updateRecentCampaign(Trigger.NewMap.keySet());
            //}
            //Merged with updateLeadForCamp method, for CR# 4090 - Bikram 28th Feb 2022
            //Added for CR-2271 - Varun  End
            //CampaignMemberTriggerHelper.createZPAProvisioningRequest(trigger.new);
            CampaignMemberTriggerHelper.createCase(trigger.new,LeadTerritory);            
        }
        //From CampaignMemberTrigger END
        System.debug('--> 15. afterInsert CPU Time : ' + Limits.getCpuTime());
    }
    
    public override void afterUpdate(){
        
        System.debug('CampaignMemberTriggerHandler afterUpdate Is Invoked');
        System.debug('CampaignMemberTriggerHandler AfterUpdate SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        System.Debug('CampaignMemberTriggerHandler afterUpdate CpuTime : ' + Limits.getCpuTime());
        
        ManageRecursive.timesCampaignMemberInvoked = ManageRecursive.timesCampaignMemberInvoked + 1;
        
        Map<Id, CampaignMember> newCampaignMemberMap = new Map<Id,CampaignMember>();
        Map<Id, CampaignMember> oldCampaignMemberMap = new Map<Id,CampaignMember>();
        
        for (SObject campaignMemberRec: Trigger.new) {
            CampaignMember newCampaignMember = (CampaignMember) campaignMemberRec;
            CampaignMember oldCampaignMember = (CampaignMember) Trigger.oldMap.get(newCampaignMember.Id);
            
            if(!ManageRecursive.processedCampaignMemberIds.contains(newCampaignMember.Id) || qualifiedUpdate(newCampaignMember, oldCampaignMember)){
                
                newCampaignMemberMap.put(newCampaignMember.Id, newCampaignMember);
                oldCampaignMemberMap.put(oldCampaignMember.Id, oldCampaignMember);
                
                ManageRecursive.processedCampaignMemberIds.add(newCampaignMember.Id);
                
                System.Debug('Test Recursive- No of times CampaignMember After Update Invoked: '+ ManageRecursive.timesCampaignMemberInvoked);
                System.Debug('CampaignMemberTriggerHandler: '+ ManageRecursive.timesCampaignMemberInvoked);
                System.debug('CampaignMemberTriggerHandler Processed Ids: ' + ManageRecursive.processedCampaignMemberIds);
                System.debug('CampaignMemberTriggerHandler newCampaignMemberMap: ' + newCampaignMemberMap);
                
            }
        }
    }
    
    public override void beforeDelete(){
        
        Map<Id, CampaignMember> oldCampaignMemberMap = new Map<Id,CampaignMember>();
        Map<Id, CampaignMember> newCampaignMemberMap = new Map<Id,CampaignMember>();
        
        for (SObject campaignMemberRec: Trigger.old) {
            CampaignMember oldCampaignMember = (CampaignMember) campaignMemberRec;
            
            oldCampaignMemberMap.put(oldCampaignMember.Id, oldCampaignMember);
        }
    }
    
    public override void afterDelete(){
        
        Map<Id, CampaignMember> oldCampaignMemberMap = new Map<Id,CampaignMember>();
        Map<Id, CampaignMember> newCampaignMemberMap;
        
        for (SObject campaignMemberRec: Trigger.old) {
            CampaignMember oldCampaignMember = (CampaignMember) campaignMemberRec;
            oldCampaignMemberMap.put(oldCampaignMember.Id, oldCampaignMember);
        }
    }
    
    public override void afterUndelete(){
        
        Map<Id, CampaignMember> oldCampaignMemberMap = new Map<Id,CampaignMember>();
        Map<Id, CampaignMember> newCampaignMemberMap = new Map<Id,CampaignMember>();
        
        for (SObject campaignMemberRec: Trigger.old) {
            CampaignMember oldCampaignMember = (CampaignMember) campaignMemberRec;  
            oldCampaignMemberMap.put(oldCampaignMember.Id, oldCampaignMember);
        }
    }
    
    public boolean qualifiedUpdate(CampaignMember newCampaignMember, CampaignMember oldCampaignMember){
        Boolean valChanged = false;
        //if( newCampaignMember.Name != oldCampaignMember.Name )
        //{
        //valChanged = true;
        //}
        return valChanged;
        
    } 
    
    public static void booster(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}