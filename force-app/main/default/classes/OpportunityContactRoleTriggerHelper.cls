/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2022-05-24      CR# 4715 Nagesh/Bikram - Calling FullCircle method to update Responses on Opportunity.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class OpportunityContactRoleTriggerHelper {
    
    private FINAL String excludeRole = 'People.ai';
    public Set<String> contactRolesToLook = new Set<String>{'Service Owner','Economic Buyer','Champion (Business)','Deployment Contact'};
    //public boolean isDelete;
        
    public void afterInsert(List<OpportunityContactRole> newContactRoles){
       
        updateOpportunityCheckForContactRole(newContactRoles,false);   
        //UpdateContactDeploymentFieldOnOpp(newContactRoles, new Map<Id,Opportunity>());
        
        //CR# 4715 START - Nagesh/Bikram
        Map<Id,Opportunity> oppIdMap = new Map<Id,Opportunity>();
        for(OpportunityContactRole ocr : newContactRoles){
            if(!oppIdMap.containsKey(ocr.OpportunityId)){
                oppIdMap.put(ocr.OpportunityId,new Opportunity(Id=ocr.OpportunityId));
            }            
        }
        FCRM.FCR_SupportAPI.AssociateOpportunitiesToResponses(oppIdMap.values());
        //CR# 4715 END - Nagesh/Bikram 
    }
    
    public void afterUpdate(List<OpportunityContactRole> newContactRoles){ 
        if(newContactRoles[0].Role!=NULL && String.isNotBlank(newContactRoles[0].Role) && !newContactRoles[0].Role.containsIgnoreCase(excludeRole)){
            TriggerUtility.stopOpportunityUpdatesContactHandler();
            updateOpportunityCheckForContactRole(newContactRoles,false);
            //UpdateContactDeploymentFieldOnOpp(newContactRoles, new Map<Id,Opportunity>());
        }
    }
    
    public void beforeDelete(List<OpportunityContactRole> newContactRoles){
        //isDelete = true;
        //updateOpportunityCheckForContactRole(newContactRoles);
    }
    
    public void AfterDelete(List<OpportunityContactRole> oldContactRoles){
        System.debug('--oldContactRoles--'+oldContactRoles);
        updateOpportunityCheckForContactRole(oldContactRoles,true);
        //afterDeleteContactRole(oldContactRoles);
    }
    
    public void updateOpportunityCheckForContactRole(List<OpportunityContactRole> newContactRoles, Boolean isDelete){
        
        Set<Id> oppIds = new Set<Id>();
        for(OpportunityContactRole oppContactRole : newContactRoles){
            oppIds.add(oppContactRole.OpportunityId); 
        }
        
        system.debug('newContactRoles ::'+newContactRoles);
        system.debug('newContactRoles Size ::'+newContactRoles.size());
        
        //List<OpportunityContactRole> opportunityContactRoles = ;
        
        //System.debug('-opportunityContactRoles-'+opportunityContactRoles);                                                             
        Map<Id, Set<String>> oppContactRoleMap = new Map<Id, Set<String>>();   
        Map<Id, Map<String, String>> oppContactRoletoIdMap = new Map<Id, Map<String, String>>();                                                              
        
         for(OpportunityContactRole contactRoleRec : [SELECT Id,OpportunityId,contactid,Role 
                                                                FROM OpportunityContactRole 
                                                                Where 
                                                                Role != null AND Role!='Created by People.ai' AND OpportunityId IN: oppIds]){
            if(oppContactRoleMap.get(contactRoleRec.OpportunityId) == null){
                Set<String> contactRoles = new Set<String>();
                contactRoles.add(contactRoleRec.Role);
                oppContactRoleMap.put(contactRoleRec.OpportunityId, contactRoles);
                oppContactRoletoIdMap.put(contactRoleRec.OpportunityId, new Map<String, string>{contactRoleRec.Role => contactRoleRec.contactid});
            }else{
                Set<String> contactRoles = oppContactRoleMap.get(contactRoleRec.OpportunityId);
                contactRoles.add(contactRoleRec.Role);
                Map<string, string> maproletoConId = oppContactRoletoIdMap.get(contactRoleRec.OpportunityId);
                maproletoConId.put(contactRoleRec.Role, contactRoleRec.contactid);
                oppContactRoleMap.put(contactRoleRec.OpportunityId, contactRoles);
                oppContactRoletoIdMap.put(contactRoleRec.OpportunityId, maproletoConId);
            }
        }
        System.debug('oppContactRoleMap::1::'+oppContactRoleMap);
        // For CR - 563    
        /*
        if(!isDelete){
            for(OpportunityContactRole contactRoleRec : newContactRoles){
                if(oppContactRoleMap.get(contactRoleRec.OpportunityId) == null){
                    Set<String> contactRoles = new Set<String>();
                    contactRoles.add(contactRoleRec.Role);
                    oppContactRoleMap.put(contactRoleRec.OpportunityId, contactRoles);
                }else{
                    Set<String> contactRoles = oppContactRoleMap.get(contactRoleRec.OpportunityId);
                    contactRoles.add(contactRoleRec.Role);
                    oppContactRoleMap.put(contactRoleRec.OpportunityId, contactRoles);
                }
            }
        }*/
        System.debug('oppContactRoleMap::2::'+oppContactRoleMap);    
        
        //List<Opportunity> opportunityDetails = ];
        
        List<Opportunity> opportunitiesToUpdate =  new List<Opportunity>();
        
        for(Opportunity oppRec : [Select Id, has_Required_Contact_Roles__c, Deployment_contact__c, Has_Business_Champion__c, 
                                    Has_Economic_Buyer__c, has_Service_Owner_Contact_Role__c 
                                     from Opportunity Where Id IN: oppIds]){
            if(oppContactRoleMap.get(oppRec.Id) != null){
                
                Boolean isOppUpdated = false;
                
                //All Opportunity Contact Roles
                Set<String> conRoles = oppContactRoleMap.get(oppRec.Id);
                Map<String, String> conMap = oppContactRoletoIdMap.get(oppRec.Id);
                
                Boolean conAllRolesExist = true;
                //Check if all required contact roles exist
                for(String cr : contactRolesToLook){
                    if(!conRoles.contains(cr)){
                        conAllRolesExist = false;
                        break;
                    }
                }
                if(oppRec.has_Required_Contact_Roles__c != conAllRolesExist){
                    oppRec.has_Required_Contact_Roles__c = conAllRolesExist;
                    isOppUpdated = true;
                }
                
                //Viral CR# 151
                Boolean isServiceOwnerRoleExist = false;
                //Check if Service owner exist in contact roles
                if(conRoles.contains('Service Owner')){
                    isServiceOwnerRoleExist = true;
                }
                if(oppRec.has_Service_Owner_Contact_Role__c != isServiceOwnerRoleExist){
                    oppRec.has_Service_Owner_Contact_Role__c = isServiceOwnerRoleExist;
                    isOppUpdated = true;
                }
                
                Boolean isBusinessChampionExist = false;
                if(conRoles.contains('Champion (Business)')){
                    isBusinessChampionExist = true;
                }
                if(oppRec.Has_Business_Champion__c != isBusinessChampionExist){
                    oppRec.Has_Business_Champion__c = isBusinessChampionExist;
                    isOppUpdated = true;
                }
                
                Boolean isEconomicBuyerExisit = false;
                if(conRoles.contains('Economic Buyer')){
                    isEconomicBuyerExisit = true;
                }
                if(oppRec.Has_Economic_Buyer__c != isEconomicBuyerExisit){
                    oppRec.Has_Economic_Buyer__c = isEconomicBuyerExisit;
                    isOppUpdated = true;
                }
                
                string deplcontact = null;
                if(conRoles.contains('Deployment Contact')){
                    deplcontact = conMap.get('Deployment Contact');
                }
                if(oppRec.Deployment_contact__c != deplcontact){
                    oppRec.Deployment_contact__c = deplcontact;
                    isOppUpdated = true;
                }
                
                if(isOppUpdated){
                    opportunitiesToUpdate.add(oppRec);
                }
                
            }else{
                oppRec.has_Required_Contact_Roles__c = false;
                oppRec.has_Service_Owner_Contact_Role__c = false;
                oppRec.Has_Economic_Buyer__c = false;
                oppRec.Has_Business_Champion__c = false;
                oppRec.Deployment_contact__c = null;
                opportunitiesToUpdate.add(oppRec);
            }
            
        }
        System.debug('opportunitiesToUpdate::'+opportunitiesToUpdate);    
        update opportunitiesToUpdate;
    }
    
    /*Public void afterDeleteContactRole(List<OpportunityContactRole> newContactRoles){
        
        Map<Id,Opportunity> OpportunityMap = new Map<Id,Opportunity>();
        
        for(OpportunityContactRole cr : newContactRoles){
            OpportunityMap.put(cr.OpportunityId, new Opportunity(Id = cr.OpportunityId, Deployment_contact__c = ''));
        }
        
        
        List<OpportunityContactRole> ContactOppRoleList = [SELECT Id, Role, ContactId, OpportunityId FROM OpportunityContactRole WHERE OpportunityId IN : OpportunityMap.keySet()];
        
        //UpdateContactDeploymentFieldOnOpp(ContactOppRoleList, OpportunityMap);
    }*/
    
    
    /*public void UpdateContactDeploymentFieldOnOpp(List<OpportunityContactRole> newContactRoles, Map <Id, Opportunity> OppMap){
        
        Map<Id,Opportunity> OpportunityMap = OppMap;
        
        for(OpportunityContactRole cr : newContactRoles){
            if(cr.Role == 'Deployment Contact'){
                OpportunityMap.put(cr.OpportunityId, new Opportunity(Id = cr.OpportunityId, Deployment_contact__c = cr.ContactId));
            }else{
                if(!OpportunityMap.containsKey(cr.OpportunityId)){
                    OpportunityMap.put(cr.OpportunityId, new Opportunity(Id = cr.OpportunityId, Deployment_contact__c = ''));
                }
            }
        }
        
        System.debug('OpportunityMap.values()'+OpportunityMap.values());
        try{
            update OpportunityMap.values();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }*/
}