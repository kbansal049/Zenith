/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* LeadTriggerHandler
* @description    This is the Lead Trigger handler class called synchronously from LeadMasterTrigger.
*				  All the methods needs to be called synchronously from the Lead Trigger
* 				  should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-01-27
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2022-05-25      CR# 4898 Bikram - Leads records created by Marketo, field Map_To_Opportunity__c is not set to TRUE 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class LeadTriggerHandler extends TriggerHandler {
    
    public LeadMasterTriggerHandler instTrHand = new LeadMasterTriggerHandler();
    
    public override void beforeInsert(){        
        
        List<Lead> newLeadList = new List<Lead>();
        Map<Id, Lead> oldLeadMap = new Map<Id,Lead>();
        //CR# 4090 START
        Set<Id> campaignIdsSet = new Set<Id>();
        Set<Id> territoryIdsSet = new Set<Id>();
        Set<String> geoNamesSet = new Set<String>{'AMERICAS', 'PUBLIC SECTOR'};
        Set<String> campaignNamesSet = new Set<String>{'INFO REQUEST', 'ONLINE DEMO', '18Q1-08-WW-CORP-DA-GOOGLE ADWORDS CONTACT US', 
            '18Q1-08-WW-ZIA-DA-GOOGLE ADWORDS REQUEST DEMO', '19Q1-10-WW-O365-RD-REQUEST DEMO-OFFICE 365-GOOGLE', 
            '18Q3-02-WW-O365-RD-REQUEST DEMO-OFFICE 365', 'ZPA-INTERACTIVE-DEMO-REQUEST', 'LIVE CHAT', 'SDRP: CONTACT REQUEST', 
            'SECURITY PREVIEW 2.0 CAMPAIGN', 'MARKETING QUALIFIED'};
        Set<String> districtNamesSet = new Set<String>{'JAPAN LE & KOREA', 'JAPAN MAJOR', 'JAPAN LE'};
        Set<String> territoryNamesSet = new Set<String>{'ENT ASEAN 1', 'ENT ASEAN 2', 'CATCH ALL ASEAN ENT', 'CATCH ALL COMM INDIA', 
            'CSR INDIA 1', 'CSR INDIA 2', 'ENT INDIA N&W 1', 'ENT INDIA SOUTH 2', 'CATCH ALL INDIA ENT', 'CATCH ALL COMM ASEAN', 
            'CSR ASEAN 1', 'CSR ASEAN 2', 'CATCH ALL - APAC'};
        Set<String> areaNamesSet = new Set<String>{'EMEA COMMERCIAL', 'EMEA ENTERPRISE', L2O_Constants.LeadObject.LEAD_AREA_EMEA};
        // Set<String> emeaTerritoryNamesSet = new Set<String>{'CATCH ALL UK&I REGION', 'CATCH ALL SEUR REGION', 'CATCH ALL NEUR REGION', 
        //     'CATCH ALL CEUR REGION', 'CATCH ALL EMEA NORTH ENT', 'CATCH ALL EMEA SOUTH ENT', 'CATCH ALL ENT NEUR', 'CATCH ALL ENT SEUR'};
        List<Group> queueList = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN ('SDR_AMER', 'SDR_EMEA')];
        System.debug('--> queueList : ' + queueList);
        Map<String, Group> queueNameToQueueMap = new Map<String, Group>();
        for (Group queue : queueList) {
            queueNameToQueueMap.put(queue.DeveloperName, queue);
        }

        for (SObject leadRec : Trigger.New) {
            Lead newLead = (Lead) leadRec;
            //CR# 4898 START - Bikram 25th May 2022
            newLead.Map_To_Opportunity__c = TRUE;
            //CR# 4898 END - Bikram 25th May 2022
            if (newLead.Most_Recent_Campaign2__c != null) {
                campaignIdsSet.add(newLead.Most_Recent_Campaign2__c);
            } 
            if (newLead.Territory__c != null) {
                territoryIdsSet.add(newLead.Territory__c);
            }
        }

        Map<Id, Campaign> campaignMap = !campaignIdsSet.isEmpty() ? 
            new Map<Id, Campaign>([SELECT Id, Name FROM Campaign WHERE Id IN :campaignIdsSet]) : 
            new Map<Id, Campaign>();
        Map<Id, PatchTeam__c> territoryMap = !territoryIdsSet.isEmpty() ? 
            new Map<Id, PatchTeam__c>([SELECT Id, Name, Area__c FROM PatchTeam__c WHERE Id IN :territoryIdsSet]) : 
            new Map<Id, PatchTeam__c>();
        //Map<Id, User> currentUserMap = new Map<Id, User> ([SELECT Id, FirstName, LastName FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1]);
        //CR# 4090 END

        for (SObject leadRec: Trigger.new) {            
            Lead newLead = (Lead) leadRec;
            //CR# 4090 START
            Boolean is70PlusNotification = false;
            Campaign mostRecentCampaign = campaignMap.get(newLead.Most_Recent_Campaign2__c);
            PatchTeam__c territory = territoryMap.get(newLead.Territory__c);
            //CR# 4090 END
			
            newLeadList.add(newLead);
            
            //CR# 3943 START, LeadIQ Field Logic
            if(newLead.LeadIQ__c == 'LeadiQ'){
                newLead.LeadSource = 'SDR Prospecting';
                newLead.Lead_Source_Type__c = 'LeadIQ';
            }
            //CR# 3943 END
            
            //Moved PB - "Update Lead Stage To Lead In Lead" Update Lead Funnel Stage logic to trigger START
            if(newLead.Status == L2O_Constants.LeadObject.LEAD_STATUS_PENDING_MARKETING_QUALIFICATION || 
               newLead.Status == L2O_Constants.LeadObject.LEAD_STATUS_RECYCLED_TO_MARKETING || 
               newLead.Status == L2O_Constants.LeadObject.LEAD_STATUS_DISQUALIFIED){
                newLead.Funnel_Stage__c = 'Inactive';
                newLead.Funnel_Stage_Date__c = NULL;
            }
            //Moved PB - "Update Lead Stage To Lead In Lead" Update Lead Funnel Stage logic to trigger END

            //CR# 4090 START, Moved workflow Logic to trigger

            //Common Conditons of the following workflows :
            //  Workflow Name : 70+ Notification for Leads - AMERICAS v2 (OnCreate)
            //  Workflow Name : 70+ Notification for Leads - APJ v3 (OnCreate)
            //  Workflow Name : 70+ Notification for Leads - EMEA v2 (OnCreate)
            if (newLead.mkto71_Lead_Score__c > 69 && String.isNotBlank(newLead.Email) &&
                (mostRecentCampaign != null && !mostRecentCampaign.Name.containsIgnoreCase('Security Preview') && 
                !campaignNamesSet.contains(mostRecentCampaign.Name.toUpperCase()))) {
                
                if ((String.isNotBlank(newLead.Geo__c) && geoNamesSet.contains(newLead.Geo__c.toUpperCase())) && 
                    !(territory != null && 'Catch All - US'.equalsIgnoreCase(territory.Name))) { //Workflow Name : 70+ Notification for Leads - AMERICAS v2 (OnCreate)

                    is70PlusNotification = true; 

                } else if (('APJ'.equalsIgnoreCase(newLead.Region_T__c) && !'ANZ'.equalsIgnoreCase(newLead.Area__c) && 
                    !(newLead.District__c != null && districtNamesSet.contains(newLead.District__c.toUpperCase()))) ||
                    (territory != null && territoryNamesSet.contains(territory.Name.toUpperCase()))) { //Workflow Name : 70+ Notification for Leads - APJ v3 (OnCreate)

                    is70PlusNotification = true;

                } else if (L2O_Constants.LeadObject.LEAD_AREA_EMEA.equalsIgnoreCase(newLead.Region_T__c) || (String.isNotBlank(newLead.Area__c) && 
                    areaNamesSet.contains(newLead.Area__c.toUpperCase()))) { //Workflow Name : 70+ Notification for Leads - EMEA v2 (OnCreate)

                    is70PlusNotification = true;
                }
            }

            if (is70PlusNotification) {
                newLead.Last_Notification_Date__c = Date.today();
                newLead.MQL_Notification_Count__c = (newLead.MQL_Notification_Count__c == null) ? 1 : newLead.MQL_Notification_Count__c + 1;
                newLead.MQL__c = true;
                newLead.MQL_Date__c = Date.today();
            }
            
            //Workflow Name : 70+ Notification for Leads - Manual Trigger
            if (newLead.Trigger_MQL_Notification__c == true) {
                newLead.Last_Notification_Date__c = Date.today();
                newLead.MQL_Notification_Count__c = (newLead.MQL_Notification_Count__c == null) ? 1 : newLead.MQL_Notification_Count__c + 1;
            }
            //Workflow Name : CFCR Clear Status Reason
            if (String.isNotBlank(newLead.Status) && (newLead.Status.startsWithIgnoreCase(L2O_Constants.LeadObject.LEAD_STATUS_MQL_SALES_UNTOUCHED) ||
                newLead.Status.startsWithIgnoreCase('Marketing Qualified: Sales Accepted') || newLead.Status.startsWithIgnoreCase('Actively Engaged') ||
                newLead.Status.startsWithIgnoreCase('Meeting Scheduled') || newLead.Status.startsWithIgnoreCase(L2O_Constants.LeadObject.LEAD_STATUS_SAL_SALES_CONNECTED_LEAD))) {

                newLead.Remarks__c = '';
            }
            //Workflow Name : Field Update_RingLead DMS Status - Lead
            if (String.isBlank(newLead.RingLead_DMS_Status__c)) {
                newLead.RingLead_DMS_Status__c = 'pending';
            }
            //Combined the following workflows
            //  Workflow Name : Lead Territory Update
            //  Workflow Name : Lead Territory Update - EMEA
            // if (territory != null && String.isNotBlank(territory.Name) && ('Marketo'.equalsIgnoreCase(System.UserInfo.getFirstName()) || 
            //     'Marketo'.equalsIgnoreCase(System.UserInfo.getLastName()))) {
                
            //     String queueDeveloperName;
            //     if ('Catch All - US'.equalsIgnoreCase(territory.Name) || 'Catch All LE/Major Canada'.equalsIgnoreCase(territory.Name)) {
            //         queueDeveloperName = 'SDR_AMER';
            //     } else if (emeaTerritoryNamesSet.contains(territory.Name.toUpperCase())) {
            //         queueDeveloperName = 'SDR_EMEA';
            //     }
            //     if (String.isNotBlank(queueDeveloperName) && queueNameToQueueMap.containsKey(queueDeveloperName)) {
            //         newLead.OwnerId = queueNameToQueueMap.get(queueDeveloperName).Id;
            //     }
            // }

            //Workflow Name : Update Deal Reg Convert to Contact field (L)
            if ('Accepted'.equalsIgnoreCase(newLead.Deal_Reg_Status__c)) {
                newLead.Deal_Reg_Convert_to_Contact__c = true;
            }

            //Workflow Name : MQL Conversion
            if (newLead.mkto71_Lead_Score__c > 69) {
                newLead.MQL__c = true;
                newLead.MQL_Date__c = Date.today();
            }

            //Workflow Name : Stamp Federal Change
            if (territory != null && 'US Federal'.equalsIgnoreCase(territory.Area__c)) {
                newLead.Federal_Change__c = System.now();
            }
            //CR# 4090 END
        }
        
        if(!TriggerUtility.isafterUpdateRelatedLeadExecuted()){
            //From Lead_Master_trigger
            instTrHand.onBeforeInsert(newLeadList);
            //From UpdateLeadMarketSegment
            leadTriggerHelper.UpdateMarketSegment(newLeadList,oldLeadMap,Trigger.isinsert,Trigger.isupdate);
            //From UpdateLeadMarketSegment
            lead_ClosedDate_Owner_Territory_Assignment(newLeadList,oldLeadMap,Trigger.isupdate);
        }
    }
    
    public override void beforeUpdate(){
        
        System.debug('LeadTriggerHandler beforeUpdate Is Invoked');
        
        Map<Id, Lead> newLeadMap = new Map<Id,Lead>();
        Map<Id, Lead> oldLeadMap = new Map<Id,Lead>();

        //CR# 4090 START
        Date MQL_DATE = Date.newInstance(13, 09, 2018);

        Set<Id> territoryIdsSet = new Set<Id>();
        Set<Id> campaignIdsSet = new Set<Id>();
        Set<Id> userIdsSet = new Set<Id>();
        Set<String> geoNamesSet = new Set<String>{'AMERICAS', 'PUBLIC SECTOR'};
        Set<String> campaignNamesSet = new Set<String>{'INFO REQUEST', 'ONLINE DEMO', '18Q1-08-WW-CORP-DA-GOOGLE ADWORDS CONTACT US', 
            '18Q1-08-WW-ZIA-DA-GOOGLE ADWORDS REQUEST DEMO', '19Q1-10-WW-O365-RD-REQUEST DEMO-OFFICE 365-GOOGLE', 
            '18Q3-02-WW-O365-RD-REQUEST DEMO-OFFICE 365', 'ZPA-INTERACTIVE-DEMO-REQUEST', 'LIVE CHAT', 'SDRP: CONTACT REQUEST', 
            'SECURITY PREVIEW 2.0 CAMPAIGN', 'MARKETING QUALIFIED'};
        Set<String> districtNamesSet = new Set<String>{'JAPAN LE & KOREA', 'JAPAN MAJOR', 'JAPAN LE'};
        Set<String> territoryNamesSet = new Set<String>{'ENT ASEAN 1', 'ENT ASEAN 2', 'CATCH ALL ASEAN ENT', 'CATCH ALL COMM INDIA', 
            'CSR INDIA 1', 'CSR INDIA 2', 'ENT INDIA N&W 1', 'ENT INDIA SOUTH 2', 'CATCH ALL INDIA ENT', 'CATCH ALL COMM ASEAN', 
            'CSR ASEAN 1', 'CSR ASEAN 2', 'CATCH ALL - APAC'};
        Set<String> areaNamesSet = new Set<String>{'EMEA COMMERCIAL', 'EMEA ENTERPRISE', L2O_Constants.LeadObject.LEAD_AREA_EMEA};
        // Set<String> emeaTerritoryNamesSet = new Set<String>{'CATCH ALL UK&I REGION', 'CATCH ALL SEUR REGION', 'CATCH ALL NEUR REGION', 
        //     'CATCH ALL CEUR REGION', 'CATCH ALL EMEA NORTH ENT', 'CATCH ALL EMEA SOUTH ENT', 'CATCH ALL ENT NEUR', 'CATCH ALL ENT SEUR'};
        List<Group> queueList = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN ('SDR_AMER', 'SDR_EMEA')];
        Map<String, Group> queueNameToQueueMap = new Map<String, Group>();
        for (Group queue : queueList) {
            queueNameToQueueMap.put(queue.DeveloperName, queue);
        }
        
        for (SObject leadRec : Trigger.New) {
            Lead newLead = (Lead) leadRec;
            
            if (newLead.Most_Recent_Campaign2__c != null) {
                campaignIdsSet.add(newLead.Most_Recent_Campaign2__c);
            }
            if (newLead.Territory__c != null) {
                territoryIdsSet.add(newLead.Territory__c);
            }
            userIdsSet.add(newLead.CreatedById);
        }

        Map<Id, Campaign> campaignMap = !campaignIdsSet.isEmpty() ? 
            new Map<Id, Campaign>([SELECT Id, Name FROM Campaign WHERE Id IN :campaignIdsSet]) : 
            new Map<Id, Campaign>();
        Map<Id, PatchTeam__c> territoryMap = !territoryIdsSet.isEmpty() ? 
            new Map<Id, PatchTeam__c>([SELECT Id, Name, Area__c FROM PatchTeam__c WHERE Id IN :territoryIdsSet]) : 
            new Map<Id, PatchTeam__c>();
        Map<Id, User> userMap = !userIdsSet.isEmpty() ? new Map<Id, User>([SELECT Id, FirstName, LastName FROM User WHERE Id IN :userIdsSet]) : 
            new Map<Id, User>();
        //CR# 4090 END
        System.debug('--> 1. LeadTriggerHandler CPU Time : ' + Limits.getCpuTime());
        for (SObject lead: Trigger.new) {
            
            Lead newLead = (Lead) lead;
            Lead oldLead = (Lead) Trigger.oldMap.get(newLead.Id);
            
            //CR# 4090 START
            Boolean is70PlusNotification = false;
            Campaign mostRecentCampaign = campaignMap.get(newLead.Most_Recent_Campaign2__c);
            PatchTeam__c territory = territoryMap.get(newLead.Territory__c);
            User owner = userMap.get(newLead.CreatedById);
            //CR# 4090 END
            
            //Moved PB - "Update Lead Stage To Lead In Lead" Update Lead Funnel Stage logic to trigger START
            if((newLead.Status == L2O_Constants.LeadObject.LEAD_STATUS_PENDING_MARKETING_QUALIFICATION && oldLead.Status != L2O_Constants.LeadObject.LEAD_STATUS_PENDING_MARKETING_QUALIFICATION)|| 
               (newLead.Status == L2O_Constants.LeadObject.LEAD_STATUS_RECYCLED_TO_MARKETING && oldLead.Status != L2O_Constants.LeadObject.LEAD_STATUS_RECYCLED_TO_MARKETING) || 
               (newLead.Status == L2O_Constants.LeadObject.LEAD_STATUS_DISQUALIFIED && oldLead.Status != L2O_Constants.LeadObject.LEAD_STATUS_DISQUALIFIED)){
                newLead.Funnel_Stage__c = 'Inactive';
                newLead.Funnel_Stage_Date__c = NULL;
            }
            //Moved PB - "Update Lead Stage To Lead In Lead" Update Lead Funnel Stage logic to trigger END

            //CR# 4090 START, Moved workflow to trigger

            //Common Conditons of the following workflows :
            //  Workflow Name : 70+ Notification for Leads - AMERICAS v2 (Generic)
            //  Workflow Name : 70+ Notification for Leads - APJ v3 (Generic)
            //  Workflow Name : 70+ Notification for Leads - EMEA v2 (Generic)
            if (newLead.mkto71_Lead_Score__c != oldLead.mkto71_Lead_Score__c &&
                newLead.mkto71_Lead_Score__c > 69 && String.isNotBlank(newLead.Email) && 
                System.UserInfo.getUserId() != '00570000004lx1h' && newLead.Duplicate_Lead_Flag__c == false &&
                (mostRecentCampaign != null && !mostRecentCampaign.Name.containsIgnoreCase('Security Preview') && 
                !campaignNamesSet.contains(mostRecentCampaign.Name.toUpperCase())) &&
                ((newLead.MQL_Notification_Count__c != null && newLead.MQL_Notification_Count__c == 0 && 
                newLead.MQL_Date__c != null && newLead.MQL_Date__c > MQL_DATE) || 
                (oldLead.mkto71_Lead_Score__c != null && oldLead.mkto71_Lead_Score__c < 70) ||
                oldLead.mkto71_Lead_Score__c == null || (newLead.mkto71_Lead_Score__c != null && 
                oldLead.mkto71_Lead_Score__c != null && newLead.mkto71_Lead_Score__c - oldLead.mkto71_Lead_Score__c >= 10))) {

                if (!(territory != null && 'Catch All - US'.equalsIgnoreCase(territory.Name)) && 
                    (String.isNotBlank(newLead.Geo__c) && geoNamesSet.contains(newLead.Geo__c.toUpperCase()))) { //Workflow Name : 70+ Notification for Leads - AMERICAS v2 (Generic)
                    
                    is70PlusNotification = true;

                } else if (('APJ'.equalsIgnoreCase(newLead.Region_T__c) && !'ANZ'.equalsIgnoreCase(newLead.Area__c) && 
                    !districtNamesSet.contains(newLead.District__c)) ||
                    (territory != null && territoryNamesSet.contains(territory.Name.toUpperCase()))) { //Workflow Name : 70+ Notification for Leads - APJ v3 (Generic)

                    is70PlusNotification = true;

                } else if (L2O_Constants.LeadObject.LEAD_AREA_EMEA.equalsIgnoreCase(newLead.Region_T__c) || (String.isNotBlank(newLead.Area__c) && 
                    areaNamesSet.contains(newLead.Area__c.toUpperCase()))) { //Workflow Name : 70+ Notification for Leads - EMEA v2 (Generic)
                    
                    is70PlusNotification = true;
                }
            }

            if (is70PlusNotification) {
                newLead.Last_Notification_Date__c = Date.today();
                newLead.MQL_Notification_Count__c = newLead.MQL_Notification_Count__c == null ? 1 : newLead.MQL_Notification_Count__c + 1;
            }

            //Workflow Name : Lead Meeting Update
            if (newLead.Has_Meeting_test__c != oldLead.Has_Meeting_test__c && newLead.Has_Meeting_test__c == true) {
                newLead.Date_of_Meeting_Scheduled__c = Date.today();
            }

            //Workflow Name : Lead Status change FROM "Recycled to Marketing"
            if (L2O_Constants.LeadObject.LEAD_STATUS_RECYCLED_TO_MARKETING.equalsIgnoreCase(oldLead.Status) && (L2O_Constants.LeadObject.LEAD_STATUS_PENDING_MARKETING_QUALIFICATION.equalsIgnoreCase(newLead.Status) ||
                L2O_Constants.LeadObject.LEAD_STATUS_MQL_SALES_UNTOUCHED.equalsIgnoreCase(newLead.Status)) && (L2O_Constants.LeadObject.MARKETO_STRING.equalsIgnoreCase(owner.FirstName) || 
                L2O_Constants.LeadObject.MARKETO_STRING.equalsIgnoreCase(owner.LastName)) && (territory != null && 'Catch All - US'.equalsIgnoreCase(territory.Name)) && 
                queueNameToQueueMap.containsKey('SDR_AMER')) {
                
                newLead.OwnerId = queueNameToQueueMap.get('SDR_AMER').Id;
            }

            //Workflow Name : Lead: Key Contact Validation - Marked as Not a Key Contact

            if (newLead.Key_contact_validation__c != oldLead.Key_contact_validation__c && 
                'Not a Key Contact'.equalsIgnoreCase(newLead.Key_contact_validation__c)) {
                
                newLead.Validation_date__c = null;
            }

            //Workflow Name : MQL Conversion
            if (newLead.mkto71_Lead_Score__c != null && newLead.mkto71_Lead_Score__c != oldLead.mkto71_Lead_Score__c && 
                newLead.mkto71_Lead_Score__c > 69 && (oldLead.mkto71_Lead_Score__c == null || oldLead.mkto71_Lead_Score__c <= 69) && 
                newLead.MQL_Date__c == null) {

                newLead.MQL__c = true;
                newLead.MQL_Date__c = Date.today();
            }

            //Workflow Name : Set Admin Score Increment

	        if (newLead.mkto71_Lead_Score__c != oldLead.mkto71_Lead_Score__c && (oldLead.CFCR_FCCRM_Threshold__c != null && oldLead.CFCR_FCCRM_Threshold__c < 100) &&
                newLead.CFCR_FCCRM_Threshold__c >= 100) {

                newLead.CFCR_Admin_Score_Increment__c = (newLead.CFCR_Admin_Score_Increment__c != null && newLead.CFCR_Admin_Score_Increment__c == 1) ? 
                    2 : 1;
                newLead.CFCR_Admin_Score_Increment_Audit__c = System.now();
            }

            //Workflow Name : Stamp Federal Change
            
            if ((newLead.Territory__c != oldLead.Territory__c || newLead.mkto71_Lead_Score__c != oldLead.mkto71_Lead_Score__c || 
                newLead.Most_Recent_Campaign2__c != oldLead.Most_Recent_Campaign2__c || newLead.MQL_Date__c != oldLead.MQL_Date__c) && 
                ('US Federal'.equalsIgnoreCase(oldLead.Area__c) || (territory != null && 'US Federal'.equalsIgnoreCase(territory.Area__c)))) {
                    
                newLead.Federal_Change__c = System.now();
            }

            //Workflow Name : Update Lead Closed/Recycled Reason To null - Full Circle
            
            if(newLead.Status != oldLead.Status && L2O_Constants.LeadObject.LEAD_STATUS_SAL_SALES_CONNECTED_LEAD.equalsIgnoreCase(newLead.Status)) {
                newLead.Remarks__c = '';
            }

            //Workflow Name : Update Lead Status To 'SAL: Sales Connected Lead' - Full Circle

            if (newLead.Outreach_Status__c != oldLead.Outreach_Status__c && 'Connected'.equalsIgnoreCase(newLead.Outreach_Status__c) && 
                !'Actively Engaged'.equalsIgnoreCase(newLead.Status) && !'Meeting Scheduled'.equalsIgnoreCase(newLead.Status)) {

                newLead.Status = L2O_Constants.LeadObject.LEAD_STATUS_SAL_SALES_CONNECTED_LEAD;
            }

            //Workflow Name : Update Lead Status To 'SAL: Sales Pursuing Lead' - Full Circle
           
            if(newLead.Outreach_Status__c != oldLead.Outreach_Status__c && (L2O_Constants.LeadObject.LEAD_STATUS_PENDING_MARKETING_QUALIFICATION.equalsIgnoreCase(newLead.Status) || 
                L2O_Constants.LeadObject.LEAD_STATUS_RECYCLED_TO_MARKETING.equalsIgnoreCase(newLead.Status) || L2O_Constants.LeadObject.LEAD_STATUS_MQL_SALES_UNTOUCHED.equalsIgnoreCase(newLead.Status)) && 
                ('Added to Sequence'.equalsIgnoreCase(newLead.Outreach_Status__c) || 'Contact Attempted'.equalsIgnoreCase(newLead.Outreach_Status__c))) {

                newLead.Status = 'SAL: Sales Pursuing Lead';
            }

            //Workflow Name : Update Matched account type
            //This is commented because on Lead object there is a warning message as below
            //  This Custom Field Definition has been removed from the managed package. You can delete the component if no longer needed.
            /*
	        if (newLead.LeanData__Matched_Account_Name__c != oldLead.LeanData__Matched_Account_Name__c) {
                newLead.Matched_Account_Lead_Type__c = 'LeanData__Matched_Account_Type__c';
            }
            */

            //Workflow Name : 70+ Notification for Leads - Manual Trigger
            if (newLead.Trigger_MQL_Notification__c != oldLead.Trigger_MQL_Notification__c && 
                newLead.Trigger_MQL_Notification__c == true) {
                newLead.Last_Notification_Date__c = Date.today();
                newLead.MQL_Notification_Count__c = newLead.MQL_Notification_Count__c == null ? 1 : newLead.MQL_Notification_Count__c + 1;
            }

            //Workflow Name : CFCR Clear Status Reason
            if (String.isNotBlank(newLead.Status) && newLead.Status != oldLead.Status  && 
                (newLead.Status.startsWithIgnoreCase(L2O_Constants.LeadObject.LEAD_STATUS_MQL_SALES_UNTOUCHED) || 
                newLead.Status.startsWithIgnoreCase('Marketing Qualified: Sales Accepted') || newLead.Status.startsWithIgnoreCase('Actively Engaged') ||
                newLead.Status.startsWithIgnoreCase('Meeting Scheduled') || newLead.Status.startsWithIgnoreCase(L2O_Constants.LeadObject.LEAD_STATUS_SAL_SALES_CONNECTED_LEAD))) {

                newLead.Remarks__c = '';
            }

            //Workflow Name : Field Update_RingLead DMS Status - Lead
            if (newLead.RingLead_DMS_Status__c != oldLead.RingLead_DMS_Status__c && 
                String.isBlank(newLead.RingLead_DMS_Status__c)) {
                newLead.RingLead_DMS_Status__c = 'pending';
            }
            
            //Combined the following workflows
            //  Workflow Name : Lead Territory Update
            //  Workflow Name : Lead Territory Update - EMEA
            // if (newLead.Territory__c != oldLead.Territory__c && territory != null && String.isNotBlank(territory.Name) && ('Marketo'.equalsIgnoreCase(System.UserInfo.getFirstName()) || 
            //     'Marketo'.equalsIgnoreCase(System.UserInfo.getLastName()))) {
                
            //     String queueDeveloperName;
            //     if ('Catch All - US'.equalsIgnoreCase(territory.Name) || 'Catch All LE/Major Canada'.equalsIgnoreCase(territory.Name)) {
            //         queueDeveloperName = 'SDR_AMER';
            //     } else if (emeaTerritoryNamesSet.contains(territory.Name.toUpperCase())) {
            //         queueDeveloperName = 'SDR_EMEA';
            //     }
                
            //     if (String.isNotBlank(queueDeveloperName) && queueNameToQueueMap.containsKey(queueDeveloperName)) {
            //         newLead.OwnerId = queueNameToQueueMap.get(queueDeveloperName).Id;
            //     }
            // }

            //Workflow Name : Update Deal Reg Convert to Contact field (L)
            if (newLead.Deal_Reg_Status__c != oldLead.Deal_Reg_Status__c && 
                'Accepted'.equalsIgnoreCase(newLead.Deal_Reg_Status__c)) {
                newLead.Deal_Reg_Convert_to_Contact__c = true;
            }

            //CR# 4090 END
            
            newLeadMap.put(newLead.Id, newLead);
            oldLeadMap.put(oldLead.Id, oldLead);            
        }
        System.debug('--> 2. LeadTriggerHandler CPU Time : ' + Limits.getCpuTime());
        //Moved PB - "Update Lead Stage To Lead In Lead" logic to trigger START
        Map<String, OnOffSwitch__c> switchmap = OnOffSwitch__c.getAll();
        if(switchmap != null && switchmap.containskey('UpdateLeadLeadStage') && OnOffSwitch__c.getInstance('UpdateLeadLeadStage').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('UpdateLeadLeadStage').Deactivate_Component__c==False && !TriggerUtility.isafterUpdateRelatedLeadExecuted()){
            for (Lead lead : [SELECT Id, MKTO71_Lead_Score__c, First_Lead_Date__c, Geo__c, LeadSource, Territory_Type__c,
                              (SELECT Id, Campaign.Type, CampaignId FROM CampaignMembers WHERE Campaign.Type LIKE '%Opedational%'),
                              (SELECT Id FROM Tasks) FROM Lead
                              WHERE ID IN :newLeadMap.keySet() AND First_Lead_Date__c = null AND Geo__c <> 'Channel' AND LeadSource <> 'Sales Generated'
                              AND Lead_Stage__c NOT IN ('SAL', 'SQL', 'MQL')]) {
                                  if ((lead.MKTO71_Lead_Score__c >= 5
                                       || (lead.CampaignMembers.isEmpty()
                                           && !lead.Tasks.isEmpty()))
                                      && lead.First_Lead_Date__c == null
                                      && (lead.LeadSource != null && !lead.LeadSource.equalsIgnoreCase('sales generated'))
                                      && (lead.Territory_Type__c != null && !lead.Territory_Type__c.equalsIgnoreCase('channel') && !lead.Territory_Type__c.equalsIgnoreCase('catch all') && !lead.Territory_Type__c.equalsIgnoreCase('row'))
                                      && (lead.Geo__c != null && !lead.Territory_Type__c.equalsIgnoreCase('channel'))) {
                                          newLeadMap.get(lead.Id).Lead_Stage__c = L2O_Constants.LeadObject.LEAD_STRING;
                                          //leadsToUpdate.add(new Lead(Id = lead.Id, Lead_Stage__c = 'Lead'));
                                      }
                              }
        }
        //Moved PB - "Update Lead Stage To Lead In Lead" logic to trigger END
        
        System.debug('LeadTriggerHandler beforeUpdate Is Invoked newLeadMap : ' + newLeadMap);
        System.debug('LeadTriggerHandler beforeUpdate Is Invoked oldLeadMap : ' + oldLeadMap);
        
        if(!TriggerUtility.isafterUpdateRelatedLeadExecuted()){
            //From UpdateLeadMarketSegment
            if(!TriggerUtility.UpdatingMarketsegmentforLeadExecuted()){
                leadTriggerHelper.UpdateMarketSegment(Trigger.new,oldLeadMap,Trigger.isinsert,Trigger.isupdate);
            }
            //From UpdateLeadMarketSegment
            lead_ClosedDate_Owner_Territory_Assignment(Trigger.new,oldLeadMap,Trigger.isupdate);
        }
    }
    
    public override void afterInsert(){
        
        System.debug('LeadMasterTriggerHandler afterInsert Is Invoked');
        System.Debug('Enter afterInsert : ' + Limits.getCpuTime());
        
        List<Id> leadNeedsPatchAssign = new List<Id>();
        List<Id> ZPAInteractiveList = new List<Id>();
        List<Id> ZB2BInteractiveList = new List<Id>();
        List<Id> convertedLeadIdList = new List<Id>();
        //CR# 4090 - START
        List<Task> tasksList = new List<Task>();
        //CR# 4090 - END
        
        Map<Id, Lead> newLeadMap = new Map<Id,Lead>();
        
        for (SObject lead: Trigger.new) {
            Lead newLead = (Lead) lead;
            newLeadMap.put(newLead.Id,newLead);
            
            //From LinkLeadToPatch
            if(leadTriggerHelper.skipTrigger == false){
                if(!newLead.Not_Eligible_for_Lead_Routing__c){
                    leadNeedsPatchAssign.add(newLead.Id);
                }
            }
            //Moved PB - "Update Contact Lead Status on lead conversion" logic to trigger
            if(newLead.IsConverted){
                convertedLeadIdList.add(newLead.Id);
            }

            //CR# 4090 - START

            //Workflow Name : Kronologic Task Creation
            if ('Meeting Accepted'.equalsIgnoreCase(newLead.Kronologic_Status__c)) {
                Task newTask = new Task();
                newTask.OwnerId = newLead.OwnerId;
                newTask.Subject = 'Kronologic - Meeting Accepted';
                newTask.Status = 'Not Started';
                newTask.Priority = 'High';
                newTask.ActivityDate = Date.today().addDays(1);
                tasksList.add(newTask);
            }
            //CR# 4090 - END
        }
        
        //CR# 4090 - START
        if (!tasksList.isEmpty()) {
            insert tasksList;
        }
        //CR# 4090 - END

        //From LinkLeadToPatch
        if(!leadNeedsPatchAssign.isEmpty()){
            //PatchRuleEngineStarter starter = new PatchRuleEngineStarter(leadNeedsPatchAssign);
            //starter.start();
            //Using Account Event Trigger to initiate the Patch Assignment
            List<Account_Event__e> accEvts = new List<Account_Event__e>();
            for(Id leadId:leadNeedsPatchAssign){
                Account_Event__e accEvt = new Account_Event__e(Record_Id__c=leadId, Event_Type__c='LinkAccountToPatch');
                accEvts.add(accEvt);
            }
            Eventbus.publish(accEvts);
        }
        
        //From LinkLeadToPatch
        if(!TriggerUtility.isafterUpdateRelatedLeadExecuted()){
            for(Lead leadRec : newLeadMap.values()){
                if(leadRec.ZPA_Interactive_Lead__c){
                    ZPAInteractiveList.add(leadRec.Id);
                }
                if(leadRec.ZB2B_Interactive_Prospect__c){
                    ZB2BInteractiveList.add(leadRec.Id);
                }
            }            
        }
        
        if(!ZPAInteractiveList.isEmpty()){
            System.enqueueJob(new ZPAInteractiveRequest(L2O_Constants.LeadObject.LEAD_STRING,ZPAInteractiveList));
        }
        if(!ZB2BInteractiveList.isEmpty()){
            System.enqueueJob(new ZB2BInteractiveRequest(L2O_Constants.LeadObject.LEAD_STRING,ZB2BInteractiveList));
        }
        if(!convertedLeadIdList.isEmpty()){
            UpdatecontactStatus.updateContactStatus(convertedLeadIdList);
            UpdatecontactStatus.updateContactCampaignID(convertedLeadIdList);
        }
    }
    
    public override void afterUpdate(){
        
        System.debug('LeadTriggerHandler afterUpdate Is Invoked');
        System.debug('LeadTriggerHandler AfterUpdate SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        System.Debug('LeadTriggerHandler afterUpdate CpuTime : ' + Limits.getCpuTime());
        
        List<Id> leadNeedsPatchAssign = new List<Id>();
        List<Id> ZPAInteractiveList = new List<Id>();
        List<Id> ZB2BInteractiveList = new List<Id>();
        List<Id> convertedLeadIdList = new List<Id>();
        // IBA-1137 START
        List<Lead> convertedLeadList = new List<Lead>();
        // IBA-1137 END

        //CR# 4090 START
        Set<Id> leadIdsSet = new Set<Id>();
        List<Task> kronologicTasksList = new List<Task>();
        //CR# 4090 END
        
        ManageRecursive.timesLeadTriggerInvoked = ManageRecursive.timesLeadTriggerInvoked + 1;
        
        Map<Id, Lead> newLeadMap = new Map<Id,Lead>();
        Map<Id, Lead> oldLeadMap = new Map<Id,Lead>();
      
        for (SObject lead: Trigger.new) {
            Lead newLead = (Lead) lead;
            Lead oldLead = (Lead) Trigger.oldMap.get(newLead.Id);
            
            if(!ManageRecursive.processedLeadIds.contains(newLead.Id) || qualifiedUpdate(newLead, oldLead)){
                
                newLeadMap.put(newLead.Id, newLead);
                oldLeadMap.put(oldLead.Id, oldLead);
                
                ManageRecursive.processedLeadIds.add(newLead.Id);
                
                /*
                System.Debug('Test Recursive- No of times Lead After Update Invoked: '+ ManageRecursive.timesLeadTriggerInvoked);
                System.Debug('LeadTriggerHandler: '+ ManageRecursive.timesLeadTriggerInvoked);
                System.debug('LeadTriggerHandler Processed Ids: ' + ManageRecursive.processedLeadIds);
                System.debug('LeadTriggerHandler newLeadtMap: ' + newLeadMap);
                */
                
                if(leadTriggerHelper.skipTrigger == false){
                    if(!PatchRuleEngineStarter.isInPipeline(newLead.Id))
                    {
                        if(!newLead.IsConverted && !newLead.Not_Eligible_for_Lead_Routing__c )
                        {
                            PatchDataModel.MatchTarget target = new PatchDataModel.MatchTarget(newLead);
                            PatchDataModel.MatchTarget oldTarget = new PatchDataModel.MatchTarget(oldLead);
                            if(newLead.TriggerPatchAssignment__c || !target.isSameTarget(oldTarget) || newLead.Not_Eligible_for_Lead_Routing__c != oldLeadMap.get(newLead.Id).Not_Eligible_for_Lead_Routing__c)
                            {
                                leadNeedsPatchAssign.add(newLead.Id);
                            }
                        }                  
                        
                    }
                }
                
                //Moved PB - "Update Contact Lead Status on lead conversion" logic to trigger
                if(newLead.IsConverted){
                    convertedLeadIdList.add(newLead.Id);
                }
                //CR# 4090 START
                if (newLead.Territory__c != oldLead.Territory__c && newLead.Territory__c != null) {
                    leadIdsSet.add(newLead.Id);
                }

                //Workflow Name : Kronologic Task Creation
                if (newLead.Kronologic_Status__c != oldLead.Kronologic_Status__c  && 'Meeting Accepted'.equalsIgnoreCase(newLead.Kronologic_Status__c)) {
                    Task newTask = new Task();
                    newTask.OwnerId = newLead.OwnerId;
                    newTask.Subject = 'Kronologic - Meeting Accepted';
                    newTask.Status = 'Not Started';
                    newTask.Priority = 'High';
                    newTask.ActivityDate = Date.today().addDays(1);
                    kronologicTasksList.add(newTask);
                }
                //CR# 4090 END

                // IBA-1137 START
                if (newLead.IsConverted != oldLead.IsConverted && newLead.IsConverted) {
                    convertedLeadList.add(newLead);
                }
                // IBA-1137 END
            }
        }
        
        //CR# 4090 START
        if (!kronologicTasksList.isEmpty()) {
            insert kronologicTasksList;
        }

        //Moved "Update territory changes from Lead to Task/Event" Process builder logic to trigger
        if (!leadIdsSet.isEmpty()) {
            List<Lead> leadsList = [SELECT Id, Territory__r.Name, Territory__r.Area__c, Territory__r.Theater__c, Territory__r.Territory_Type__c, 
                (SELECT Id, Sales_Territory__c, Territory_Area__c, Territory_Geo__c, Territory_Type__c FROM Tasks WHERE IsClosed = false), 
                (SELECT Id, Sales_Territory__c, Territory_Area__c, Territory_Geo__c, Territory_Type__c FROM Events WHERE EndDateTime >= :System.now()) 
                FROM Lead WHERE Id IN :leadIdsSet];

            List<Event> eventsList = new List<Event>();
            for (Lead currentLead : leadsList) {
                for (Event associatedEvent : currentLead.Events) {
                    associatedEvent.Sales_Territory__c = currentLead.Territory__r.Name;
                    associatedEvent.Territory_Area__c = currentLead.Territory__r.Area__c;
                    associatedEvent.Territory_Geo__c = currentLead.Territory__r.Theater__c;
                    associatedEvent.Territory_Type__c = currentLead.Territory__r.Territory_Type__c;
                    eventsList.add(associatedEvent);
                }
            }
            if (!eventsList.isEmpty()) {
                update eventsList;
            }
        }
        //CR# 4090 END

        //From LinkLeadToPatch
        if(!leadNeedsPatchAssign.isEmpty()){
            //PatchRuleEngineStarter starter = new PatchRuleEngineStarter(leadNeedsPatchAssign);
            //starter.start();
            //Using Account Event Trigger to initiate the Patch Assignment
            List<Account_Event__e> accEvts = new List<Account_Event__e>();
            for(Id leadId:leadNeedsPatchAssign){
                Account_Event__e accEvt = new Account_Event__e(Record_Id__c=leadId, Event_Type__c='LinkAccountToPatch');
                accEvts.add(accEvt);
            }
            Eventbus.publish(accEvts);
        }
        
        //CR# 4809-START
        Map<Id,Lead>trigNewLeadsMap = new Map<Id,Lead>();
        Map<Id,Lead>trigOldLeadsMap = new Map<Id,Lead>();
        for(Sobject eachLead:trigger.New){
            trigNewLeadsMap.put(eachLead.Id,(Lead)Trigger.newMap.get(eachLead.Id));
            trigOldLeadsMap.put(eachLead.Id,(Lead)Trigger.oldMap.get(eachLead.Id));
        } //CR# 4809-End
        
        if(!TriggerUtility.isafterUpdateRelatedLeadExecuted()){
            //From Lead_Master_trigger
            instTrHand.onAfterupdate(trigNewLeadsMap,trigOldLeadsMap);//CR# 4809
            
            //From LinkLeadToPatch
            for(Lead leadRec : newLeadMap.values()){
                if(leadRec.ZPA_Interactive_Lead__c != oldLeadMap.get(leadRec.Id).ZPA_Interactive_Lead__c 
                   && leadRec.ZPA_Interactive_Lead__c == true){
                       ZPAInteractiveList.add(leadRec.Id);
                   }
                if(leadRec.ZB2B_Interactive_Prospect__c != oldLeadMap.get(leadRec.Id).ZB2B_Interactive_Prospect__c
                   && leadRec.ZB2B_Interactive_Prospect__c == true){
                       ZB2BInteractiveList.add(leadRec.Id);
                   }
            }
        }
        
        if(!ZPAInteractiveList.isEmpty()){
            System.enqueueJob(new ZPAInteractiveRequest(L2O_Constants.LeadObject.LEAD_STRING,ZPAInteractiveList));
        }
        if(!ZB2BInteractiveList.isEmpty()){
            System.enqueueJob(new ZB2BInteractiveRequest(L2O_Constants.LeadObject.LEAD_STRING,ZB2BInteractiveList));
        }
        
        if(!convertedLeadIdList.isEmpty()){
            UpdatecontactStatus.updateContactStatus(convertedLeadIdList);
            UpdatecontactStatus.updateContactCampaignID(convertedLeadIdList);
        }

        // IBA-1137 START
        if (!convertedLeadList.isEmpty()) {
            updateAssociatedStudentRecords(convertedLeadList);
        }
        // IBA-1137 END
        
        //From LinkLeadToPatch
        if(leadTriggerHelper.skipTrigger == false){
            map<id, id> leadIdTerritoryIdMap = new map<Id, Id>();
            map<Id, Id> leadAccManagerIdMap = new map<Id, Id>();
            
            User u = [SELECT Id, Name FROM User WHERE FirstName = :L2O_Constants.LeadObject.MARKETO_STRING];
            
            for(lead le : newLeadMap.values()){
                if(le.Territory__c != oldLeadMap.get(le.Id).Territory__c)
                    leadIdTerritoryIdMap.put(le.id, Le.Territory__c);
                if(le.Lead_Development__c != null && oldLeadMap.get(le.Id).Lead_Development__c != le.Lead_Development__c && le.OwnerId != u.Id && !TriggerUtility.getRunningForMarketo())
                    leadAccManagerIdMap.put(le.Id, le.Lead_Development__c);
            }
            if(leadIdTerritoryIdMap != null && leadIdTerritoryIdMap.keySet().Size() > 0)
                CampaignMemberPatchManager.getPatchInformation(leadIdTerritoryIdMap,L2O_Constants.LeadObject.LEAD_STRING);
            
            if(!TriggerUtility.isCaseCreationForLeadTerrirtory())
                leadTriggerHelper.caseCreationForDefaultTerrirtory(newLeadMap.values(), oldLeadMap);
            leadTriggerHelper.updateDealRegAfterLeadConversion(oldLeadMap, newLeadMap);
            
            if(!System.isFuture() && !System.isBatch() && !leadAccManagerIdMap.isEmpty())
                leadTriggerHelper.changeLeadOwnership(leadAccManagerIdMap);
            
            if (!TriggerUtility.isUpdateLeadSalesTeamEmailFieldsExecuted()) {
                leadTriggerHelper.updateSalesTeamEmailFields(oldLeadMap, newLeadMap);
            }
            
            // Commented this code as the logic should not be based on Bizible Account field 
            // if (!TriggerUtility.isUpdateLeadNoOfEmployeesExecuted()) {
            //     leadTriggerHelper.updateNumberOfEmployees(Trigger.new);
            // }
            //Added by Swathi : CR1127 Start
            if(!TriggerUtility.isleadtaskFieldUpdateExecuted()){
                leadTriggerHelper.UpdateTaskFields(newLeadMap.values(),oldLeadMap);
            }
            //Added by Swathi : CR1127 End
        }
        LeadTriggerHelper.skipTrigger = true;
    }
    
    public override void beforeDelete(){
        
        Map<Id, Lead> oldLeadMap = new Map<Id,Lead>();
        
        for (SObject lead: Trigger.old) {
            Lead oldLead = (Lead) lead;
            
            oldLeadMap.put(oldLead.Id, oldLead);
        }
        
        if(LeadTriggerHelper.skipTrigger == false)
        {
            LeadTriggerHelper.dealRegValidation(oldLeadMap);
        }
        LeadTriggerHelper.skipTrigger = true;
    }
    
    public override void afterDelete(){
        
    }
    
    public override void afterUndelete(){
        
    }
    
    public boolean qualifiedUpdate(Lead newLead, Lead oldLead){
        
        Boolean valChanged = false;
        /*
if( newLead.Name != oldLead.Name )
{
valChanged = true;
} 
*/
        return valChanged;
        
    } 

    // IBA-1137 START
    public void updateAssociatedStudentRecords(List<Lead> leadList) {
        if (leadList == null) {
            throw new IllegalArgumentException('Parameter leadList cannot be null');
        }

        // IBA-1931 START
        Set<Id> convertedAccountIdSet = new Set<Id>();
        for (Lead currentLead : leadList) {
            if (currentLead.ConvertedAccountId != null) {
                convertedAccountIdSet.add(currentLead.ConvertedAccountId);
            }
        }
        Map<Id, Account> convertedAccountIdToAccountMap = new Map<Id, Account>(getAccountByIds(convertedAccountIdSet));
        // IBA-1931 END

        Map<Id, Lead> leadIdToLeadMap = new Map<Id, Lead>(leadList);
        Map<Id, skilljar__Student__c> leadIdToStudentMap = new Map<Id, skilljar__Student__c>();
        List<skilljar__Student__c> studentList = getAssociatedStudents(leadIdToLeadMap.keySet());

        List<skilljar__Student__c> studentsToUpdateList = new List<skilljar__Student__c>();
        List<Contact> contactToUpdateList = new List<Contact>();

        for (skilljar__Student__c student : studentList) {
            leadIdToStudentMap.put(student.skilljar__Lead__c, student);
        }
        for (Id leadId : leadIdToStudentMap.keySet()) {
            skilljar__Student__c student = leadIdToStudentMap.get(leadId);
            Lead associatedLead = leadIdToLeadMap.get(leadId);
            student.Account__c = student.Account__c == null ? associatedLead.ConvertedAccountId : student.Account__c;
            student.skilljar__Contact__c = associatedLead.ConvertedContactId;
            student.Account_Type__c = convertedAccountIdToAccountMap.containsKey(student.Account__c) ? 
                convertedAccountIdToAccountMap.get(student.Account__c).Type : student.Account_Type__c;
            studentsToUpdateList.add(student);

            // IBA-1594 START
            Contact convertedContactToUpdate = new Contact(Id = associatedLead.ConvertedContactId, Okta_ID__c = associatedLead.Okta_ID__c);
            contactToUpdateList.add(convertedContactToUpdate);
            // IBA-1594 END
        }

        if (!studentsToUpdateList.isEmpty()) {
            update studentsToUpdateList;

            // IBA-1594 START
            TriggerHandler.bypass('ContactTriggerHandler');
            update contactToUpdateList;
            // IBA-1594 END
        }
    }

    // IBA-1931 START
    public List<Account> getAccountByIds(Set<Id> accountIdSet) {
        if (accountIdSet == null) {
            throw new IllegalArgumentException('Parameter accountIdSet cannot be null');
        }
        return [SELECT Id, Type FROM Account WHERE Id IN :accountIdSet];
    }
    // IBA-1931 END

    public List<skilljar__Student__c> getAssociatedStudents(Set<Id> leadIdSet) {
        if (leadIdSet == null) {
            throw new IllegalArgumentException('Parameter leadIdSet cannot be null');
        }
        return [SELECT Id, skilljar__Contact__c, Account__c, skilljar__Lead__c, Account_Type__c FROM skilljar__Student__c WHERE skilljar__Lead__c IN :leadIdSet];
    }
    // IBA-1137 END
    
    //From UpdateLeadMarketSegment
    public void lead_ClosedDate_Owner_Territory_Assignment(List<Lead> triggerNew,Map<Id,Lead> oldLeadMap,Boolean triggerIsUpdate){
        set<id> patchIdSet = new Set<id>();
        map<Id, Id> patchTerritoryMap = new map<Id, Id>();

        Map<Id, Patch__c> patchIdToPatchMap = new Map<Id, Patch__c>();
        // IBA-3252 START
        Set<String> queueDeveloperNamesSet = new Set<String>();
        Map<String, Lead_Territory_to_Queue_Mapping__mdt> leadTerritoryToQueueMappingMetadataMap = new Map<String, Lead_Territory_to_Queue_Mapping__mdt>();
        for (Lead_Territory_to_Queue_Mapping__mdt metadataRecord : Lead_Territory_to_Queue_Mapping__mdt.getAll().values()) {
            if (metadataRecord.Is_Active__c == true) {
                queueDeveloperNamesSet.add(metadataRecord.Queue_Developer_Name__c);
                leadTerritoryToQueueMappingMetadataMap.put(metadataRecord.MasterLabel, metadataRecord);
            }
        } 
        // IBA-3252 END
        List<Group> queueList = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :queueDeveloperNamesSet];
        Map<String, Group> queueNameToQueueMap = new Map<String, Group>();
        for (Group queue : queueList) {
            queueNameToQueueMap.put(queue.DeveloperName, queue);
        }
        // IBA-3252 START
        // Commented this variable because the logic is now configurable using Lead Territory To Queue Mapping Metadata
        // Set<String> emeaTerritoryNamesSet = new Set<String>{'CATCH ALL UK&I REGION', 'CATCH ALL SEUR REGION', 'CATCH ALL NEUR REGION', 
        //     'CATCH ALL CEUR REGION', 'CATCH ALL EMEA NORTH ENT', 'CATCH ALL EMEA SOUTH ENT', 'CATCH ALL ENT NEUR', 'CATCH ALL ENT SEUR'};
        // IBA-3252 END
        Map<Id, User> createdByUsersMap = new Map<Id, User>();
        Set<Id> createdByUserIds = new Set<Id>();
        if (Trigger.isInsert) {
            createdByUserIds.add(UserInfo.getUserId());
        }
        
        for(lead le : triggerNew){
            if(le.Patch__c != null)
                patchIdSet.add(le.Patch__c);
            if(le.Status.equalsIgnoreCase(L2O_Constants.LeadObject.LEAD_STATUS_DISQUALIFIED) || le.Status.equalsIgnoreCase(L2O_Constants.LeadObject.LEAD_STATUS_RECYCLED_TO_MARKETING)) {
                le.Last_Closed_Date__c = system.today();
            }
            if ( triggerIsUpdate  && le.Last_Opened_Date__c!=NULL && le.Last_Opened_Date__c != oldLeadMap.get(le.ID).Last_Opened_Date__c){
                le.Last_Closed_Date__c = Null;
            }
            //Added by Swathi : CR#3101 Start
            if( Trigger.isInsert && le.Not_Eligible_for_Lead_Routing__c ){
                le.OwnerId = Label.Unassigned_Lead_Queue_Id;
            }
            if( triggerIsUpdate && le.Not_Eligible_for_Lead_Routing__c && le.Not_Eligible_for_Lead_Routing__c != oldLeadMap.get(le.Id).Not_Eligible_for_Lead_Routing__c){
                le.OwnerId = Label.Unassigned_Lead_Queue_Id;
            }
            if (triggerIsUpdate) {
                createdByUserIds.add(le.CreatedById);
            }
            //Added by Swathi : CR#3101 End
            /*
if(le.Status.equalsIgnoreCase('Actively Engaged') && le.Days_since_last_activity__c==Null && le.Age_Since_Last_Open__c >= 61){
le.Status = 'Recycled to Marketing'; 
le.Remarks__c ='Not Interested' ;
le.Outreach_Status__c ='Closed';
}
*/
            // Commented out below code as logic moves to workflow for Fullcircle
            /* if(Trigger.isUpdate && le.status.equalsIgnoreCase('Marketing Qualified: Sales Untouched')  && String.isNotBlank(le.Outreach_Status__c) && le.Outreach_Status__c != Trigger.oldMap.get(le.ID).Outreach_Status__c && (le.Outreach_Status__c.equalsIgnoreCase('Added to Sequence') || le.Outreach_Status__c.equalsIgnoreCase('Contact Attempted') )){
//le.Status = 'Marketing Qualified: Sales Accepted';
le.Status = 'SAL: Sales Pursuing Lead';     //Added as part of CR# 2731 :Gurjinder
}
if(Trigger.isUpdate && String.isNotBlank(le.Outreach_Status__c) && le.Outreach_Status__c != Trigger.oldMap.get(le.ID).Outreach_Status__c && (le.Outreach_Status__c.equalsIgnoreCase('Connected'))){
//le.Status = 'Actively Engaged';
le.Status = 'SAL: Sales Connected Lead'; //Added as part of CR# 2731 :Gurjinder
}
if(Trigger.isUpdate && le.Status!=Trigger.oldMap.get(le.ID).status && le.Status.equalsIgnoreCase('SAL: Sales Connected Lead') ){ //updated the status condition as part of CR# 2731 :Gurjinder
le.Remarks__c = null;
}  */
        }
        for(Patch__c patch : [Select Id, PatchTeam__c, PatchTeam__r.Name from Patch__c where PatchTeam__c != null AND ID IN: patchIdSet]){
            patchTerritoryMap.put(patch.id, patch.PatchTeam__c);
            patchIdToPatchMap.put(patch.Id, patch);
        }

        if (!createdByUserIds.isEmpty()) {
            createdByUsersMap = new Map<Id, User>([SELECT Id, FirstName, LastName FROM User WHERE Id IN :createdByUserIds]);
        }
        
        for(lead le : triggerNew){
            Lead oldLead = oldLeadMap.get(le.Id); 

            if(le.Patch__c != null) {
                le.Territory__c = patchTerritoryMap.get(le.Patch__c);
                User createdByUser = Trigger.isInsert ? createdByUsersMap.get(UserInfo.getUserId()) : createdByUsersMap.get(le.CreatedById);
                
                //Combined the following workflows
                //  Workflow Name : Lead Territory Update
                //  Workflow Name : Lead Territory Update - EMEA  
                // Movied the logic here because the territory gets updated from the patch only
                Patch__c associatedPatch = patchIdToPatchMap.get(le.Patch__c);
                if (le.Territory__c != null && ((triggerIsUpdate && le.Territory__c != oldLead.Territory__c) || !triggerIsUpdate) && String.isNotBlank(associatedPatch.PatchTeam__r.Name) && (createdByUser != null && (L2O_Constants.LeadObject.MARKETO_STRING.equalsIgnoreCase(createdByUser.FirstName) || 
                    L2O_Constants.LeadObject.MARKETO_STRING.equalsIgnoreCase(createdByUser.LastName)))) {
                    
                    // IBA-3252 START
                    String queueDeveloperName = leadTerritoryToQueueMappingMetadataMap.containsKey(associatedPatch.PatchTeam__r.Name) ? 
                        leadTerritoryToQueueMappingMetadataMap.get(associatedPatch.PatchTeam__r.Name).Queue_Developer_Name__c : '';
                    
                    /*
                    // Commented this logic because the logic is now configurable using Lead Territory To Queue Mapping Metadata
                    if ('Catch All - US'.equalsIgnoreCase(associatedPatch.PatchTeam__r.Name) || 'Catch All LE/Major Canada'.equalsIgnoreCase(associatedPatch.PatchTeam__r.Name)) {
                        queueDeveloperName = 'SDR_AMER';
                    } else if (emeaTerritoryNamesSet.contains(associatedPatch.PatchTeam__r.Name.toUpperCase())) {
                        queueDeveloperName = 'SDR_EMEA';
                    }
                    */
                    // IBA-3252 END
                    
                    if (String.isNotBlank(queueDeveloperName) && queueNameToQueueMap.containsKey(queueDeveloperName)) {
                        le.OwnerId = queueNameToQueueMap.get(queueDeveloperName).Id;
                        TriggerUtility.isRunningForMarketo = true;
                    }
                }
            }
        }
    }
    
}