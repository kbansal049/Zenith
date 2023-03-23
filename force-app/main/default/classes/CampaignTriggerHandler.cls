/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* CampaignTriggerHandler
* @description    This is the Campaign Trigger handler class called synchronously from CampaignTrigger.
*					All the methods needs to be called synchronously from the CampaignTrigger
* 					should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2021-11-29
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2021-11-29      Bikram - Added Trigger Framework and moved Process Builder "Update Standard Campaign Type" 
*				  logic to Trigger.
* 2022-09-02      Udit - IBA-2474 : Identify Partner Led campaigns
* 2022-09-02      Udit - IBA-2498 : Update value populated in "Type" field on campaign object
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class CampaignTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert(){
        System.debug('CampaignTriggerHandler BeforeInsert Is Invoked');
        
        List<Campaign> newCampaignList = new List<Campaign>();
        
        for (SObject campn: Trigger.new) {            
            Campaign newCampaign = (Campaign) campn;
            // Added By Ayush Kangar as part of CR#4856 - Start
            if(newCampaign.Led_By__c != NULL && newCampaign.Campaign_Type__c != NULL){
                newCampaign.Type = newCampaign.Led_By__c + '-' +newCampaign.Campaign_Type__c + '-' + newCampaign.Activity_Details__c;
            }
            // Added By Ayush Kangar as part of CR#4856 - End
            //PB - 'Update Standard Campaign Type' Logic moved to Before Insert and Before Update
            else if(newCampaign.Campaign_Type__c != NULL && newCampaign.Led_By__c == NULL){
                newCampaign.Type = newCampaign.Campaign_Type__c + '-' + newCampaign.Activity_Details__c;
            }            

            //CR# 4090 - START, moved workflows to trigger
            //Workflow Name: Campaign: Set Camp Date When Post_Event_to_Web check box is Checked on Create
            if (newCampaign.Post_Event_to_Web__c == true) {
                newCampaign.Post_Event_to_Web_Date__c = Date.today();
            }

            //Workflow Name: Campaign: Set Camp Date When Post_Event_to_Web check box is Unchecked
            if (newCampaign.Post_Event_to_Web__c == null || newCampaign.Post_Event_to_Web__c == false) {
                newCampaign.Post_Event_to_Web_Date__c = null;
            }
            //CR# 4090 - END

            // Udit  - IBA-2474 - Start
            if(newCampaign.Led_By__c!=null){
                if(newCampaign.Led_By__c == '3rd Party' || newCampaign.Led_By__c == 'Zscaler'){
                    newCampaign.Not_a_Channel_Partner_Campaign__c = true;
                    newCampaign.Not_a_Partner_Campaign__c = true;
                    newCampaign.Not_a_Tech_Partner_Campaign__c = true;
                }else if(newCampaign.Led_By__c == 'Channel Partner'){
                    newCampaign.Not_a_Tech_Partner_Campaign__c = true;
                }else if(newCampaign.Led_By__c == 'Tech Partner'){
                    newCampaign.Not_a_Channel_Partner_Campaign__c = true;
                }else{
                    
                }
            }
            // Udit  - IBA-2474 - End

            // Udit  - IBA-2498 - Start
            if(newCampaign.Campaign_Type__c != null){
                newCampaign.Type = newCampaign.Campaign_Type__c;
            }
            // Udit  - IBA-2498 - End
        }
    }
    
    public override void beforeUpdate(){
        System.debug('CampaignTriggerHandler BeforeUpdate Is Invoked');
        
        Map<Id, Campaign> newCampaignMap = new Map<Id,Campaign>();
        Map<Id, Campaign> oldCampaignMap = new Map<Id,Campaign>();
        
        for (SObject campn: Trigger.new) {
            Campaign newCampaign = (Campaign) campn;
            Campaign oldCampaign = (Campaign) Trigger.oldMap.get(newCampaign.Id);
            // Added By Ayush Kangar as part of CR#4856 - Start
            if(newCampaign.Led_By__c != null && (newCampaign.Campaign_Type__c != oldCampaign.Campaign_Type__c)
               || (newCampaign.Activity_Details__c != oldCampaign.Activity_Details__c) ||
               (newCampaign.Led_By__c != oldCampaign.Led_By__c)){
                newCampaign.Type = newCampaign.Led_By__c + '-' + newCampaign.Campaign_Type__c + '-' + newCampaign.Activity_Details__c;
            }
            // Added By Ayush Kangar as part of CR#4856 - Start
            //PB - 'Update Standard Campaign Type' Logic moved to Before Insert and Before Update
            else if(newCampaign.Led_By__c != null && (newCampaign.Campaign_Type__c != oldCampaign.Campaign_Type__c)
               || (newCampaign.Activity_Details__c != oldCampaign.Activity_Details__c)){
                newCampaign.Type = newCampaign.Campaign_Type__c + '-' + newCampaign.Activity_Details__c;
            }

            //CR# 4090 - START, moved workflows to trigger
            //Workflow Name: Campaign: Set Camp Date When Post_Event_to_Web check box is Checked
            if (newCampaign.Post_Event_to_Web__c != oldCampaign.Post_Event_to_Web__c && newCampaign.Post_Event_to_Web__c == true) {
                newCampaign.Post_Event_to_Web_Date__c	= Date.today();
            }

            //Workflow Name: Campaign: Set Camp Date When Post_Event_to_Web check box is Unchecked
            if (newCampaign.Post_Event_to_Web__c != oldCampaign.Post_Event_to_Web__c && (newCampaign.Post_Event_to_Web__c == null || 
                newCampaign.Post_Event_to_Web__c == false)) {
                newCampaign.Post_Event_to_Web_Date__c = null;
            }
            
            //CR# 4090 - END
            
            newCampaignMap.put(newCampaign.Id, newCampaign);
            oldCampaignMap.put(oldCampaign.Id, oldCampaign);

            // Udit  - IBA-2474 - Start
            if(oldCampaign.Led_By__c != newCampaign.Led_By__c){
                if(newCampaign.Led_By__c == '3rd Party' || newCampaign.Led_By__c == 'Zscaler'){
                    newCampaign.Not_a_Channel_Partner_Campaign__c = true;
                    newCampaign.Not_a_Partner_Campaign__c = true;
                    newCampaign.Not_a_Tech_Partner_Campaign__c = true;
                }else if(newCampaign.Led_By__c == 'Channel Partner'){
                    newCampaign.Not_a_Tech_Partner_Campaign__c = true;
                    newCampaign.Not_a_Channel_Partner_Campaign__c = false;
                    newCampaign.Not_a_Partner_Campaign__c = false;
                }else if(newCampaign.Led_By__c == 'Tech Partner'){
                    newCampaign.Not_a_Channel_Partner_Campaign__c = true;
                    newCampaign.Not_a_Partner_Campaign__c = false;
                    newCampaign.Not_a_Tech_Partner_Campaign__c = false;
                }else{
                    
                }
            }
            // Udit  - IBA-2474 - End

            // Udit  - IBA-2498 - Start
            if(newCampaign.Campaign_Type__c != null && (newCampaign.Campaign_Type__c != oldCampaign.Campaign_Type__c)){
                newCampaign.Type = newCampaign.Campaign_Type__c;
            }
            // Udit  - IBA-2498 - End
        }
    }
    
    public override void afterInsert(){
        
    }
    
    public override void afterUpdate(){
        System.debug('CampaignTriggerHandler AfterUpdate Is Invoked');
        System.debug('CampaignTriggerHandler1 AfterUpdate SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        
        Map<Id, Campaign> newCampaignMap = new Map<Id,Campaign>();
        Map<Id, Campaign> oldCampaignMap = new Map<Id,Campaign>();
        
        ManageRecursive.timesCampaignTriggerInvoked = ManageRecursive.timesCampaignTriggerInvoked + 1;
        
        for (SObject campn: Trigger.new) {
            
            Campaign newCampaign = (Campaign) campn;
            Campaign oldCampaign = (Campaign) Trigger.oldMap.get(newCampaign.Id);
            
            if(!ManageRecursive.processedCampaignIds.contains(newCampaign.Id) || qualifiedUpdate(newCampaign, oldCampaign)){
                
                newCampaignMap.put(newCampaign.Id, newCampaign);
                oldCampaignMap.put(oldCampaign.Id, oldCampaign); 
                
                ManageRecursive.processedCampaignIds.add(newCampaign.Id);
                
                System.Debug('Test Recursive- No of times Campaign After Update Invoked: '+ ManageRecursive.timesCampaignTriggerInvoked);
                System.Debug('CampaignTriggerHandler: '+ ManageRecursive.timesCampaignTriggerInvoked);
                System.debug('CampaignTriggerHandler Processed Ids: '+ManageRecursive.processedCampaignIds);
                System.debug('CampaignTriggerHandler Qualified Update: '+ManageRecursive.processedCampaignIds);
                System.debug('CampaignTriggerHandler newCampaignMap: '+newCampaignMap);
                
            }
        }    
        
        if(!TriggerUtility.isafterUpdateRelatedLeadExecuted() && !system.isbatch()){
            CampaignTriggerHelper.updateRelatedLeads(newCampaignMap.keySet());
        }
        
        if(!TriggerUtility.isafterUpdateRelatedContactExecuted() && !system.isbatch()){
            CampaignTriggerHelper.updateRelatedContacts(newCampaignMap.keySet());
        }
        
        
    }
    
    public override void beforeDelete(){
        
    }
    
    public override void afterDelete(){
        
    }
    
    public override void afterUndelete(){
        
    }
    
    public boolean qualifiedUpdate(Campaign newCampaign, Campaign oldCampaign){
        
        Boolean valChanged = false;
        /*
        if( newCampaign.Name != oldCampaign.Name)
        {
            valChanged = true;
        } 
        */
        return valChanged;
    }

}