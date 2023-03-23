/*****************************************************************************************
Name: CampaignMemberTriggerHelper
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Trigger helper class for genericCampaignMemberTrigger.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            4-Nov-2016    Initial Development
******************************************************************************************/

public class CampaignMemberTriggerHelper{

    /**
    *@purpose : Method to update Lead/Contact with latest campaign.
    *@param :  New list of campaign member.
    *@return : None
    **/

    public static boolean skipTrigger = false;
    public static boolean skipTrigger2 = false;
    public static boolean skipUpdateTrigger = false;
    public static boolean cmTriggerSkip = false;
    // Commented by Varun for CR # 2271
    /**public static void updateLeadContactForCamp(list<CampaignMember> newCampMemList){
        list<Contact> conUpdateList = new list<Contact>();
        list<Lead> leadUpdateList = new list<Lead>();
        Set<id>  campIdsSet= new Set<id>();
        if(ZscalerSetting__c.getValues('CampaignExceptions1') != null && ZscalerSetting__c.getValues('CampaignExceptions2') != null){
            string exceptionCampaigns1  = ZscalerSetting__c.getValues('CampaignExceptions1').Value__c;
            string exceptionCampaigns2  = ZscalerSetting__c.getValues('CampaignExceptions2').Value__c;
            set<string> campExceptionIdSet = new set<string>();
            campExceptionIdSet.addAll(exceptionCampaigns1.split(';'));
            campExceptionIdSet.addAll(exceptionCampaigns2.split(';'));
            Set<String> UntaggingCampaignTypeSet= new Set<String>();
            String UntaggingCampaignType= ZscalerCustomSetting__c.getInstance('UntaggingCampaignType')!=null && ZscalerCustomSetting__c.getInstance('UntaggingCampaignType').Value__c!=null ? ZscalerCustomSetting__c.getInstance('UntaggingCampaignType').Value__c:'Operational,Non-Marketing Programs';
            UntaggingCampaignTypeSet.addall(UntaggingCampaignType.split(','));
            
            for(CampaignMember campMember : newCampMemList)
            {
                campIdsSet.add(campMember.CampaignId);
            }
            
            Map<Id,Campaign> CampaignMap = new Map<Id,Campaign>([Select Id,name,type,Campaign_Type__c,Recommended_Outreach_Sequence__c from Campaign where Id =:campIdsSet]);

            for(CampaignMember campMem : newCampMemList){
                if(!campExceptionIdSet.contains(campMem.CampaignId) && CampaignMap.get(campMem.CampaignId)!=null && !UntaggingCampaignTypeSet.contains(CampaignMap.get(campMem.CampaignId).Campaign_Type__c)){
                    if(campMem.LeadId != null && campMem.Status!='On List' && campMem.Status!='On-List' && campMem.Status!='Pre Reg List' && campMem.Status!='Pre-Reg List' && campMem.Status!='Book Sent' && campMem.Status!='Default'&& campMem.Status!='Delivered' && campMem.Status!='Direct Mail' && campMem.Status!='eGift Clicked' && campMem.Status!='eGift Credited' && campMem.Status!='eGift Opened' && campMem.Status!='eGift Sent (or Generated)' && campMem.Status!='Item Delivered' && campMem.Status!='Item Processing' && campMem.Status!='Item Shipped' && campMem.Status!='Item Undeliverable' && campMem.Status!='Mail Delivered' && campMem.Status!='Mailed' && campMem.Status!='Member' && campMem.Status!='Opened' && campMem.Status!='Other' && campMem.Status!='Sent' && campMem.Status!='Waiting List' && campMem.Status!='Waitlisted' )
                        leadUpdateList.add(new Lead(id = campMem.Leadid, Most_Recent_Campaign2__c = campMem.CampaignId, Recommended_Outreach_Sequence__c = CampaignMap.get(campMem.CampaignId).Recommended_Outreach_Sequence__c));
                    if(campMem.ContactId != null){
                        conUpdateList.add(new Contact(id= campMem.ContactId, Most_Recent_Campaign__c = campMem.CampaignId, Recommended_Outreach_Sequence__c = CampaignMap.get(campMem.CampaignId).Recommended_Outreach_Sequence__c));
                    }
                }
            }

            if(!conUpdateList.isEmpty())
                database.update(conUpdateList, false);
            if(!leadUpdateList.isEmpty())
                database.update(leadUpdateList, false);
            TriggerUtility.updateLeadContactForCampExecuted();
        }
    }*/
    
    // Added by Varun for CR # 2271 - Start
    //Merged updateRecentCampaign method, for CR# 4090 - Bikram 28th Feb 2022
    //And the process was moved back to syncronous, @future is commented 
    //@future(callout=true)
    public static void updateLeadForCamp(Set<Id> newCampaignIds){
        
        TriggerUtility.UpdateLeadForCampExecuted();
        list<Lead> leadUpdateList = new list<Lead>();
        Set<id>  campIdsSet= new Set<id>();
        Map<Id,Lead> leadsToUpdateMap = new Map<Id,Lead>();
        
        if(!newCampaignIds.isEmpty()){
            
            if(ZscalerSetting__c.getValues('CampaignExceptions1') != null && 
               ZscalerSetting__c.getValues('CampaignExceptions2') != null){
                   
                string exceptionCampaigns1  = ZscalerSetting__c.getValues('CampaignExceptions1').Value__c;
                string exceptionCampaigns2  = ZscalerSetting__c.getValues('CampaignExceptions2').Value__c;
                set<string> campExceptionIdSet = new set<string>();
                campExceptionIdSet.addAll(exceptionCampaigns1.split(';'));
                campExceptionIdSet.addAll(exceptionCampaigns2.split(';'));
                Set<String> UntaggingCampaignTypeSet= new Set<String>();
                
                String UntaggingCampaignType= ZscalerCustomSetting__c.getInstance('UntaggingCampaignType')!=null && 
                    ZscalerCustomSetting__c.getInstance('UntaggingCampaignType').Value__c!=null ? 
                    ZscalerCustomSetting__c.getInstance('UntaggingCampaignType').Value__c:'Operational,Non-Marketing Programs';
                   
                UntaggingCampaignTypeSet.addall(UntaggingCampaignType.split(','));
                   
                List<CampaignMember> newCampMemList = [Select id,Name,LeadId, ContactId,CampaignId,Status,
                                                       lead.Most_Recent_Campaign__c,Campaign.Name,Campaign.Type, Campaign.RecordType.Name
                                                       from  CampaignMember where Id in :newCampaignIds];
                System.debug('newCampMemList'+newCampMemList);
                
                for(CampaignMember campMember : newCampMemList){
                    campIdsSet.add(campMember.CampaignId);
                    //Moved the method updateRecentCampaign, so that a single Update operation will be executed
                    if(campMember.Name != 'Marketing Qualified' && campMember.LeadId != NULL){
                        leadsToUpdateMap.put(campMember.Leadid,new Lead(id = campMember.Leadid, Most_Recent_Campaign__c = campMember.Campaign.Name,
                                                Campaign_Type__c = campMember.Campaign.Type  ));
                        //leadUpdateList.add(new Lead(id = campMember.Leadid, Most_Recent_Campaign__c = campMember.Campaign.Name,
                                                //Campaign_Type__c = campMember.Campaign.Type  ));
                    }
                }
                   System.debug('leadsToUpdateMap method updateRecentCampaign ' + leadsToUpdateMap);
                Map<Id,Campaign> CampaignMap = new Map<Id,Campaign>([Select Id,name,type,Campaign_Type__c,
                                                                     Recommended_Outreach_Sequence__c 
                                                                     from Campaign where Id =:campIdsSet]);
                System.debug('newCampMemList'+newCampMemList);
                   
                for(CampaignMember campMem : newCampMemList){
                    
                    if(!campExceptionIdSet.contains(campMem.CampaignId) && 
                       CampaignMap.get(campMem.CampaignId)!=null && 
                       !UntaggingCampaignTypeSet.contains(CampaignMap.get(campMem.CampaignId).Campaign_Type__c)){
                           
                        if(campMem.LeadId != null && campMem.Status!='On List' && 
                           campMem.Status!='On-List' && campMem.Status!='Pre Reg List' && 
                           campMem.Status!='Pre-Reg List' && campMem.Status!='Book Sent' && 
                           campMem.Status!='Default'&& campMem.Status!='Delivered' && 
                           campMem.Status!='Direct Mail' && campMem.Status!='eGift Clicked' && 
                           campMem.Status!='eGift Credited' && campMem.Status!='eGift Opened' && 
                           campMem.Status!='eGift Sent (or Generated)' && campMem.Status!='Item Delivered' && 
                           campMem.Status!='Item Processing' && campMem.Status!='Item Shipped' && 
                           campMem.Status!='Item Undeliverable' && campMem.Status!='Mail Delivered' && 
                           campMem.Status!='Mailed' && campMem.Status!='Member' && campMem.Status!='Opened' && 
                           campMem.Status!='Other' && campMem.Status!='Sent' && campMem.Status!='Waiting List' && 
                           campMem.Status!='Waitlisted' ){
                               if(leadsToUpdateMap.containsKey(campMem.Leadid)){
                                    Lead leadRecord = leadsToUpdateMap.get(campMem.Leadid);
                                    //leadRecord.Most_Recent_Campaign2__c = campMem.CampaignId;
                                    if (campMem.CampaignId == null || !'Internal'.equalsIgnoreCase(campMem.Campaign.RecordType.Name)) {
                                        leadRecord.Most_Recent_Campaign2__c = campMem.CampaignId;
                                    }
                                    leadRecord.Recommended_Outreach_Sequence__c = CampaignMap.get(campMem.CampaignId).Recommended_Outreach_Sequence__c;
                               }else {
                                    Lead leadRecord = new Lead(id = campMem.Leadid, Recommended_Outreach_Sequence__c = CampaignMap.get(campMem.CampaignId).Recommended_Outreach_Sequence__c);
                                    if (campMem.CampaignId == null || !'Internal'.equalsIgnoreCase(campMem.Campaign.RecordType.Name)) {
                                        leadRecord.Most_Recent_Campaign2__c = campMem.CampaignId;
                                    }
                                    leadsToUpdateMap.put(campMem.Leadid, leadRecord);
                               }                               
                               //leadUpdateList.add(new Lead(id = campMem.Leadid, 
                                                        //Most_Recent_Campaign2__c = 
                                                        //campMem.CampaignId, 
                                                        //Recommended_Outreach_Sequence__c = 
                                                           //CampaignMap.get(campMem.CampaignId).Recommended_Outreach_Sequence__c));
                           }
                            
                    }
                }
                System.debug('leadsToUpdateMap method updateLeadForCamp ' + leadsToUpdateMap);
                if(!leadsToUpdateMap.isEmpty()){
                //if(!leadUpdateList.isEmpty()){
                    CampaignTriggerHelper.setTriggerUtilityFlags();
                    //database.update(leadUpdateList, false);
                    Database.SaveResult [] updateResult = database.update(leadsToUpdateMap.values(), false);
                    for (Database.SaveResult res : updateResult){
                        if (!res.isSuccess()){
                            for (Database.Error e : res.getErrors()){ 
                                System.debug('updateLeadForCamp e.getMessage :' + e.getMessage());
                            }
                        }
                    }
                    CampaignTriggerHelper.resetTriggerUtilityFlags();       
                }  
            }
        }
        
    }
    
    //@future(callout=true)
    public static void updateContactForCamp(Set<Id> newCampaignIds){
        TriggerUtility.UpdateContactForCampExecuted();
        list<Contact> conUpdateList = new list<Contact>();
        Set<id>  campIdsSet= new Set<id>();
        if(!newCampaignIds.isEmpty()){
            if(ZscalerSetting__c.getValues('CampaignExceptions1') != null && ZscalerSetting__c.getValues('CampaignExceptions2') != null){
                string exceptionCampaigns1  = ZscalerSetting__c.getValues('CampaignExceptions1').Value__c;
                string exceptionCampaigns2  = ZscalerSetting__c.getValues('CampaignExceptions2').Value__c;
                set<string> campExceptionIdSet = new set<string>();
                campExceptionIdSet.addAll(exceptionCampaigns1.split(';'));
                campExceptionIdSet.addAll(exceptionCampaigns2.split(';'));
                Set<String> UntaggingCampaignTypeSet= new Set<String>();
                String UntaggingCampaignType= ZscalerCustomSetting__c.getInstance('UntaggingCampaignType')!=null && ZscalerCustomSetting__c.getInstance('UntaggingCampaignType').Value__c!=null ? ZscalerCustomSetting__c.getInstance('UntaggingCampaignType').Value__c:'Operational,Non-Marketing Programs';
                UntaggingCampaignTypeSet.addall(UntaggingCampaignType.split(','));
                List<CampaignMember> newCampMemList = [Select id,LeadId, ContactId,CampaignId, Campaign.RecordType.Name from  CampaignMember where Id in :newCampaignIds];
                
                for(CampaignMember campMember : newCampMemList)
                {
                    campIdsSet.add(campMember.CampaignId);
                }
                
                Map<Id,Campaign> CampaignMap = new Map<Id,Campaign>([Select Id,name,type,Campaign_Type__c,Recommended_Outreach_Sequence__c from Campaign where Id =:campIdsSet]);
                
                for(CampaignMember campMem : newCampMemList){
                    if(!campExceptionIdSet.contains(campMem.CampaignId) && CampaignMap.get(campMem.CampaignId)!=null && !UntaggingCampaignTypeSet.contains(CampaignMap.get(campMem.CampaignId).Campaign_Type__c)){
                        if(campMem.ContactId != null) {
                            Contact newContact = new Contact(id= campMem.ContactId, Recommended_Outreach_Sequence__c = CampaignMap.get(campMem.CampaignId).Recommended_Outreach_Sequence__c);
                            if (campMem.CampaignId == null || !'Internal'.equalsIgnoreCase(campMem.Campaign.RecordType.Name)) {
                                newContact.Most_Recent_Campaign__c = campMem.CampaignId;
                            }
                            conUpdateList.add(newContact);
                        }
                            
                    }
                }
                
                if(!conUpdateList.isEmpty()){
                    CampaignTriggerHelper.setTriggerUtilityFlags();
                    Database.SaveResult [] updateResult = database.update(conUpdateList, false);
                    for (Database.SaveResult res : updateResult){
                        if (!res.isSuccess()){
                            for (Database.Error e : res.getErrors()){ 
                                System.debug('updateContactForCamp e.getMessage :' + e.getMessage());
                            }
                        }
                    }
                    CampaignTriggerHelper.resetTriggerUtilityFlags();  
                }
            }
        }
        
    }
    
    //Merged with updateLeadForCamp method, for CR# 4090 - Bikram 28th Feb 2022
    /*@future(callout=true)
    public static void updateRecentCampaign(Set<Id> newCampaignIds){
        TriggerUtility.UpdateRecentCampaignExecuted();
        list<Lead> leadUpdateList = new list<Lead>();
        Set<id>  leadIdsSet= new Set<id>();
        Map<ID, Lead> parentOpps = new Map<ID, Lead>();
        if(!newCampaignIds.isEmpty()){
            List<CampaignMember> newCampMemList = [Select id,name, Campaign_Type__c, LeadId ,
                                                   lead.Most_Recent_Campaign__c,Campaign.Name,Campaign.Type 
                                                   from  CampaignMember 
                                                   where id in :newCampaignIds and 
                                                   name !='Marketing Qualified'];
            for(CampaignMember campMember : newCampMemList)
            {
                if((campMember.LeadId)!=null){
                    leadUpdateList.add(new Lead(id = campMember.Leadid, Most_Recent_Campaign__c = campMember.Campaign.Name,
                                                Campaign_Type__c = campMember.Campaign.Type  ));
                }           	
            }
            
            if(!leadUpdateList.isEmpty()){
                CampaignTriggerHelper.setTriggerUtilityFlags();
                //database.update(leadUpdateList, false);
                CampaignTriggerHelper.resetTriggerUtilityFlags();       
            }
        }
    }
	// Added by Varun for CR # 2271 - End
	*/	
	//Merged with updateLeadForCamp method, for CR# 4090
	
    /*
     * Check if records are related to ZPA Interactive Campaign or not. If so create Provisioning Request
     *
     *
     */
    public static void createZPAProvisioningRequest(list<CampaignMember> newCampMemList)
    {
         Custom_Metadata__mdt cusMetaDataList = [Select Id,MasterLabel,DeveloperName from Custom_Metadata__mdt where DeveloperName='ZPA_Interactive'];
         String CampaignName =  cusMetaDataList.MasterLabel;
         List<CampaignMember> zpaFevaList = new List<CampaignMember>();
         List<Provisioning_Request__c> newPRList = new List<Provisioning_Request__c>();

         List<Id> campIds = new List<Id>();
         List<Id> leadList = new List<Id>();
         List<Id> contactList = new List<Id>();

         for(CampaignMember campMember : newCampMemList)
         {
             campIds.add(campMember.CampaignId);
         }

         Map<Id,Campaign> CampaignMap = new Map<Id,Campaign>([Select Id,name from Campaign where Id = :campIds]);

         for(CampaignMember campMember : newCampMemList)
         {

            String campName = '';
            if(CampaignMap.get(campMember.CampaignId) != null)
                campName = CampaignMap.get(campMember.CampaignId).name;
            if(campName == CampaignName)
            {
                zpaFevaList.add(campMember);
                if(campMember.LeadId != null)
                    leadList.add(campMember.LeadId);
                else
                    contactList.add(campMember.ContactId);
            }
         }

        system.debug('Is Empty ::'+!(zpaFevaList.isEmpty()));
        if(!(zpaFevaList.isEmpty()))
        {
            RecordType rt = [Select Id,Name from RecordType where DeveloperName='ZPA_Interactive'];
            Map<Id,Lead> leadMap = new Map<Id,Lead>([select Id, name, ZPA_Manager__c,ZPA_SE__c, Lead_Development_Email__c, Lead_Development_Name__c from Lead where Id in :leadList]);
            Map<Id,Contact> contactMap = new Map<Id,Contact>([select Id, name, ZPA_Manager__c,ZPA_SE__c from Contact where Id in :contactList]);
            for(CampaignMember campMember : zpaFevaList)
            {
                if(campMember.LeadId != null)
                {
                    Provisioning_Request__c pr = new Provisioning_Request__c();
                    pr.recordTypeId= rt.Id;
                    pr.Lead__c = campMember.LeadId;
                    pr.ZPA_Interactive_User_Email__c = campMember.Email;
                    pr.Provisioning_Status__c = 'Requested';
                    if(leadMap.get(campMember.LeadId) != null)
                    {
                        pr.ZPA_Manager__c = leadMap.get(campMember.LeadId).ZPA_Manager__c;
                        pr.ZPA_SE__c = leadMap.get(campMember.LeadId).ZPA_SE__c;
                        pr.Full_Name__c = leadMap.get(campMember.LeadId).name;
                        pr.Lead_Development_Email__c = leadMap.get(campMember.LeadId).Lead_Development_Email__c;
                        pr.Lead_Development_Name__c = leadMap.get(campMember.LeadId).Lead_Development_Name__c;
                    }
                    pr.Provisioning_Date__c = System.today();
                    pr.Provisioning_End_Date__c = System.today()+7;
                    newPRList.add(pr);
                }
                else if(campMember.ContactId != null)
                {
                    Provisioning_Request__c pr = new Provisioning_Request__c();
                    pr.recordTypeId= rt.Id;
                    pr.Primary_Eval_Contact__c  = campMember.contactId;
                    pr.Account__c =  campMember.contact.AccountId;
                    pr.ZPA_Interactive_User_Email__c = campMember.Email;
                    pr.Provisioning_Status__c = 'Requested';
                    if(leadMap.get(campMember.ContactId) != null)
                    {
                        pr.ZPA_Manager__c = contactMap.get(campMember.ContactId).ZPA_Manager__c;
                        pr.ZPA_SE__c = contactMap.get(campMember.ContactId).ZPA_SE__c;
                        pr.Full_Name__c = contactMap.get(campMember.ContactId).name;
                        pr.Lead_Development_Email__c = leadMap.get(campMember.LeadId).Lead_Development_Email__c;
                        pr.Lead_Development_Name__c = leadMap.get(campMember.LeadId).Lead_Development_Name__c;
                    }
                    pr.Provisioning_Date__c = System.today();
                    pr.Provisioning_End_Date__c = System.today()+7;
                    newPRList.add(pr);
                }
            }
        }

        if(!(newPRList.isEmpty()))
        {
            database.insert(newPRList,false);
        }
    }

    public static void createCase(list<CampaignMember> newCampMemList,Map<Id,String> LeadTerritory)
    {
         Custom_Metadata__mdt cusMetaDataList = [Select Id,MasterLabel,DeveloperName from Custom_Metadata__mdt where DeveloperName='ZPA_Interactive'];
         String CampaignName =  cusMetaDataList.MasterLabel;
         system.debug('Campaign Name ::'+CampaignName);
         List<CampaignMember> zpaFevaList = new List<CampaignMember>();
         List<Case> zpaCases = new List<Case>();
        List<Id> campIds = new List<Id>();

         for(CampaignMember campMember : newCampMemList)
         {
             campIds.add(campMember.CampaignId);
         }

         Map<Id,Campaign> CampaignMap = new Map<Id,Campaign>([Select Id,name from Campaign where Id = :campIds]);

         for(CampaignMember campMember : newCampMemList)
         {
            //system.debug('Campaign Info ::'+campMember);

            String campName = '';
            if(CampaignMap.get(campMember.CampaignId) != null)
                campName = CampaignMap.get(campMember.CampaignId).name;
            system.debug('Campaign Name ::'+CampaignName+' : '+campName);
            if(campName == CampaignName)
            {
                zpaFevaList.add(campMember);
            }
         }

        for(CampaignMember campMember : zpaFevaList)
        {
            if(campMember.LeadId != null && LeadTerritory.get(campMember.LeadId) != null)
            {
                Case zpaCase = new Case();
                zpaCase.Lead__c = campMember.LeadId;
                zpaCase.Subject = 'ZPA Interactive Campaign Lead went to catch all territory';
                zpaCase.Description = 'ZPA Interactive Campaign Lead went to catch all territory';
                zpaCase.Status = 'New';
                zpaCase.recordtypeid = label.CaseRT_SalesOperation;
                zpaCases.add(zpaCase);

            }
        }

        if(zpaCases.size() > 0)
            insert zpaCases;
    }

}