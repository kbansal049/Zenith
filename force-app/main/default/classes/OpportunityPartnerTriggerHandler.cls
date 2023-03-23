/**
  Updated BY : Sateesh U 
  This class is used To update 'Has_Technology_Partner__c' on opportunity when there is Technology partners exists
  VERSION        AUTHOR                  DATE              DETAIL              
  1.0            NA                      NA                Initial Development
  2.0            Swathi                 2/25/2022          CR#3744 - Professional Sercives Partner
  3.0            Swathi                 9/13/2022          IBA-2980 replacing teaming tech partner with influence Partner
**/
 
public class OpportunityPartnerTriggerHandler {
    
    //refactored the code and moved the logic in after Insert
    /* public static void onBeforeInsert(list<Opportunity_Partner__c> newOppPartnerList){
        
        List<string> OppIds = new List<string>();
        List<string> PartnerOppIds = new List<string>();
        Map<string,Opportunity_Partner__c> OppIdVsOppPartner = new Map<string,Opportunity_Partner__c>();
        Map<String,string> oppPrimaryResellerPartnerMap = new Map<String,string>();
        List<id> AccIds = new List<id>();
        for(Opportunity_Partner__c Partner:newOppPartnerList){
            
               if(Partner.Opportunity__c != null && Partner.Is_Primary__c == true && Partner.Partner_Type__c == 'Reseller' && Partner.Account__c!=null){
                
                oppPrimaryResellerPartnerMap.put(Partner.Opportunity__c,Partner.Account__c);
            }
            if(Partner.Opportunity__c != null && Partner.Partner_Type__c == 'Tech Partner'){
                OppIds.Add(Partner.Opportunity__c);
                AccIds.add(Partner.Account__c);
                System.debug('OppIds-->'+ OppIds);
                System.debug('AccIds-->'+ AccIds);
            }
        }
        System.debug('OppIds-->'+ OppIds);
        Map<Id,opportunity> opportunityMap = New Map<Id,opportunity>([Select Id, Has_Technology_Partner__c,Validated_Solution_Tech_Partner__c From opportunity where id IN:OppIds]);
        Map<Id,Account> accountMap =New Map<Id,Account>([select id,Name from Account where Id in:AccIds and Type='Technology Partner']);
        System.debug('opportunityMap'+opportunityMap);
        System.debug('accountMap '+accountMap);
        for(Opportunity_Partner__c Partner:newOppPartnerList){
            if(opportunityMap.containskey(Partner.Opportunity__c)){
                Opportunity opp = opportunityMap.get(Partner.Opportunity__c);
                if(opp.Validated_Solution_Tech_Partner__c != Null && opp.Validated_Solution_Tech_Partner__c != ''){
                    opp.Validated_Solution_Tech_Partner__c = opp.Validated_Solution_Tech_Partner__c+ ';' + accountMap.get(Partner.Account__c).Name;
                }
                else if(accountMap.containsKey(Partner.Account__c))
                    opp.Validated_Solution_Tech_Partner__c = accountMap.get(Partner.Account__c).Name;
                opp.Has_Technology_Partner__c=True;
                opportunityMap.put(Partner.Opportunity__c, opp);
            }
            }
         list<opportunity> opportunityResellerList = [Select Id,Primary_reseller_Partner__c From opportunity where id IN:oppPrimaryResellerPartnerMap.Keyset() LIMIT 10000];
        for(opportunity rec:opportunityResellerList){
            rec.Primary_reseller_Partner__c = oppPrimaryResellerPartnerMap.get(rec.Id);
        }
        
        //list<opportunity> PartnerOppList = [Select Id,Partner_Account_Name__c From opportunity where id IN:PartnerOppIds];
        //for(opportunity OppRec:PartnerOppList){
        //    OppRec.Partner_Account_Name__c = OppIdVsOppPartner.get(OppRec.Id).Account__c;
        //}
        //update PartnerOppList;

        TriggerUtility2.setOppRelTechPartnerExecuted();
        System.debug('opportunityMap '+opportunityMap);
        if(!opportunityMap.isEmpty()){
            update opportunityMap.values();
        }
        //System.debug('opportunityList '+opportunityList);
        update opportunityResellerList;
        TriggerUtility2.setOppPartnerTechPartnerExecuted();        
    } */

    public static void onAfterInsert(list<Opportunity_Partner__c> newOppPartnerList){
        List<string> OppIds = new List<string>();
        List<id> AccIds = new List<id>();
        Map<Id,Opportunity> OpportunityToUpdateMap = new Map<Id,Opportunity>();
        
        System.debug('newOppPartnerList: '+newOppPartnerList);
        for(Opportunity_Partner__c Partner : newOppPartnerList){
            if(Partner.Opportunity__c != null){ OppIds.Add(Partner.Opportunity__c); }
            if(Partner.Account__c != null){ AccIds.Add(Partner.Account__c); }
        }

        Map<Id,opportunity> opportunityMap = new Map<Id,opportunity>([SELECT Id, Has_Technology_Partner__c,Validated_Solution_Tech_Partner__c FROM opportunity WHERE id IN :OppIds]);
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT id,Name,Type FROM Account WHERE Id IN :AccIds]);

        System.debug('opportunityMap: '+opportunityMap);
        System.debug('accountMap: '+accountMap);

        for(Opportunity_Partner__c Partner:newOppPartnerList){
            if(Partner.Opportunity__c != null && Partner.Account__c != null){
                Opportunity opp;
                if(OpportunityToUpdateMap.containsKey(Partner.Opportunity__c)){
                    opp = OpportunityToUpdateMap.get(Partner.Opportunity__c);
                } else {
                    opp = new Opportunity(Id = Partner.Opportunity__c);
                }

                Boolean updateOpp = false;

                if(Partner.Partner_Type__c == 'Tech Partner' && accountMap.get(Partner.Account__c)?.Type == 'Technology Partner'){
                    //Check in the Opportunity from Query - "opportunityMap"
                    if(!String.isEmpty(opportunityMap.get(Partner.Opportunity__c)?.Validated_Solution_Tech_Partner__c)){
                        opp.Validated_Solution_Tech_Partner__c = opportunityMap.get(Partner.Opportunity__c)?.Validated_Solution_Tech_Partner__c+ ';' + accountMap.get(Partner.Account__c)?.Name;
                    }
                    else{
                        //Check in the Opportunity which will get updated - "OpportunityToUpdateMap"
                        if(!String.isEmpty(OpportunityToUpdateMap.get(Partner.Opportunity__c)?.Validated_Solution_Tech_Partner__c)){
                            opp.Validated_Solution_Tech_Partner__c = OpportunityToUpdateMap.get(Partner.Opportunity__c)?.Validated_Solution_Tech_Partner__c+ ';' + accountMap.get(Partner.Account__c)?.Name;
                        } else{
                            opp.Validated_Solution_Tech_Partner__c = accountMap.get(Partner.Account__c)?.Name;
                        }
                    }
                    opp.Has_Technology_Partner__c = true;
                    updateOpp = true;
                }
                
                if(Partner.Is_Primary__c == true && Partner.Partner_Type__c == 'Reseller'){
                    opp.Primary_reseller_Partner__c = Partner.Account__c;
                    updateOpp = true;
                }
                //CR#3744 Start
                if(Partner.Is_Primary__c == true && Partner.Partner_Type__c == 'Professional Services'){
                    opp.Professional_Services_Partner__c = Partner.Account__c;
                    updateOpp = true;
                }
                //CR#3744 End
                //CR# 4055 - Update Primary Distributor on opportunity
                if(Partner.Is_Primary__c == true && Partner.Partner_Type__c == 'Distributor'){
                    opp.Primary_Transacting_Distributor__c = Partner.Account__c;
                    opp.Primary_Transacting_Distributor_Name__c = accountMap.get(Partner.Account__c)?.Name;
                    updateOpp = true;
                }

                if(updateOpp){
                    OpportunityToUpdateMap.put(opp.id, opp);
                }
            }
        }

        TriggerUtility2.setOppRelTechPartnerExecuted();

        //Bypass Opportunity trigger
        Triggerhandler.bypass('OpportunityTriggerHandler');
        update OpportunityToUpdateMap.values();
        Triggerhandler.clearBypass('OpportunityTriggerHandler');

        TriggerUtility2.setOppPartnerTechPartnerExecuted();
    }
    
    //refactored the code and moved the logic in after Update
    /* public static void onBeforeUpdate(list<Opportunity_Partner__c> newOppPartnerList,Map<ID, Opportunity_Partner__c> oldOppPartnerMap){
        
        List<string> OppIds = new List<string>();
        List<string> PartnerOppIds = new List<string>();
        Map<string,Opportunity_Partner__c> OppIdVsOppPartner = new Map<string,Opportunity_Partner__c>();
         List<string> PartnerResellerOppIds = new List<string>();
        Map<string,Opportunity_Partner__c> OppIdVsOppResellerPartner = new Map<string,Opportunity_Partner__c>();
        
        for(Opportunity_Partner__c Partner:newOppPartnerList){
            if(Partner.Opportunity__c != null && Partner.Partner_Type__c == 'Tech Partner'){
                OppIds.Add(Partner.Opportunity__c);
                System.debug('OppIds-->'+ OppIds);
            }
            if(Partner.Opportunity__c != null && Partner.Is_Primary__c == true && Partner.Is_Primary__c != oldOppPartnerMap.get(Partner.Id).Is_Primary__c && Partner.Partner_Type__c == 'Reseller'){
                PartnerResellerOppIds.Add(Partner.Opportunity__c);
                OppIdVsOppResellerPartner.put(Partner.Opportunity__c,Partner);
            }
        }
        
        list<opportunity> opportunityList = [Select Id, Has_Technology_Partner__c From opportunity where id IN:OppIds And Has_Technology_Partner__c = false];
        for(opportunity rec:opportunityList){
            rec.Has_Technology_Partner__c = true;
        }
        
        list<opportunity> PartnerResellerOppList = [Select Id,Primary_reseller_Partner__c From opportunity where id IN:PartnerResellerOppIds];
        for(opportunity OppRec:PartnerResellerOppList){
            OppRec.Primary_reseller_Partner__c = OppIdVsOppResellerPartner.get(OppRec.Id).Account__c;
        }
        update PartnerResellerOppList;
        
        //update PartnerOppList;
        
        update opportunityList;
        System.debug('opportunityList '+opportunityList);
    } */

    public static void onAfterUpdate(list<Opportunity_Partner__c> newOppPartnerList,Map<ID, Opportunity_Partner__c> oldOppPartnerMap){
        List<string> OppIds = new List<string>();
        List<id> AccIds = new List<id>();
        Map<Id,Opportunity> OpportunityToUpdateMap = new Map<Id,Opportunity>();
        
        for(Opportunity_Partner__c Partner:newOppPartnerList){
            if(Partner.Opportunity__c != null){ OppIds.Add(Partner.Opportunity__c); }
            if(Partner.Account__c != null){ AccIds.Add(Partner.Account__c); }
        }
        
        Map<Id,opportunity> opportunityMap = new Map<Id,opportunity>([SELECT Id, Has_Technology_Partner__c, Primary_reseller_Partner__c,Professional_Services_Partner__c, Primary_Transacting_Distributor_Name__c,Primary_Transacting_Distributor__c FROM opportunity WHERE Id IN :OppIds]);

        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id,Name,Type FROM Account WHERE Id IN :AccIds]);

        for(Opportunity_Partner__c Partner:newOppPartnerList){
            if(Partner.Opportunity__c != null){
                Opportunity opp;
                if(OpportunityToUpdateMap.containsKey(Partner.Opportunity__c)){
                    opp = OpportunityToUpdateMap.get(Partner.Opportunity__c);
                } else {
                    opp = new Opportunity(Id = Partner.Opportunity__c);
                }

                Boolean updateOpp = false;

                if(Partner.Partner_Type__c == 'Tech Partner' && opportunityMap.get(Partner.Opportunity__c)?.Has_Technology_Partner__c == false){
                    opp.Has_Technology_Partner__c =  true;
                    updateOpp = true;
                }
                
                if(Partner.Is_Primary__c == true && oldOppPartnerMap.get(Partner.Id).Is_Primary__c == false){
                    if(Partner.Partner_Type__c == 'Reseller'){ 
                        opp.Primary_reseller_Partner__c = Partner.Account__c; 
                        updateOpp = true;
                    }

                    //CR# 4055 - Update Primary Distributor on opportunity
                    if(Partner.Partner_Type__c == 'Distributor'){ 
                        opp.Primary_Transacting_Distributor__c = Partner.Account__c;
                        opp.Primary_Transacting_Distributor_Name__c = accountMap.get(Partner.Account__c)?.Name;
                        updateOpp = true;
                    }
                    //CR#3744 Start
                    if(Partner.Partner_Type__c == 'Professional Services'){ 
                        opp.Professional_Services_Partner__c = Partner.Account__c; 
                        updateOpp = true;
                    }
                    //CR#3744 End
                } else if(Partner.Is_Primary__c == false && oldOppPartnerMap.get(Partner.Id).Is_Primary__c == true){
                    if(Partner.Partner_Type__c == 'Reseller' && opportunityMap.get(Partner.Opportunity__c)?.Primary_reseller_Partner__c == Partner.Account__c){ 
                        opp.Primary_reseller_Partner__c = null; 
                        updateOpp = true;
                    }
                    //CR# 4055 - Update Primary Distributor on opportunity
                    if(Partner.Partner_Type__c == 'Distributor' && opportunityMap.get(Partner.Opportunity__c)?.Primary_Transacting_Distributor__c == Partner.Account__c){ 
                        opp.Primary_Transacting_Distributor__c = null;
                        opp.Primary_Transacting_Distributor_Name__c = null;
                        updateOpp = true;
                    }
                    //CR#3744 Start
                    if(Partner.Partner_Type__c == 'Professional Services' && opportunityMap.get(Partner.Opportunity__c)?.Professional_Services_Partner__c == Partner.Account__c){ 
                        opp.Primary_reseller_Partner__c = null; 
                        updateOpp = true;
                    }
                    //CR#3744 End
                }

                if(updateOpp){
                    OpportunityToUpdateMap.put(opp.id, opp);
                }
            }
        }
        System.debug('OpportunityToUpdateMap: '+OpportunityToUpdateMap);  

        //Bypass Opportunity trigger
        Triggerhandler.bypass('OpportunityTriggerHandler');
        update OpportunityToUpdateMap.values();  
        Triggerhandler.clearBypass('OpportunityTriggerHandler');
    }
    
    /*public static void onBeforeDelete(list<Opportunity_Partner__c> newOppPartnerList){
        
        List<string> OppIds = new List<string>();
        Map<string,string> IdVsRecMap = new Map<string,string>();
        List<Opportunity_Partner__c> OppPartnersList = new List<Opportunity_Partner__c>();
        
        for(Opportunity_Partner__c Partner:newOppPartnerList){
            OppIds.Add(Partner.Opportunity__c);
        }
        
        if(OppIds.size()>0){
            OppPartnersList = [select Id,Name,
                                      Opportunity__c,
                                      Partner_Type__c 
                                      from 
                                      Opportunity_Partner__c 
                                      where 
                                      Opportunity__c IN:OppIds 
                                      And 
                                      Partner_Type__c = 'Tech Partner'
                                      And 
                                      Is_Primary__c = true];
                                      
            for(Opportunity_Partner__c Partner:OppPartnersList){
                IdVsRecMap.put(Partner.Opportunity__c,Partner.Opportunity__c);
            }
                                      
            list<opportunity> opportunityList = [Select Id, Has_Technology_Partner__c From opportunity where id IN:OppIds And Has_Technology_Partner__c = true];
            for(opportunity rec:opportunityList){
                if(IdVsRecMap.get(rec.Id) == null){
                    rec.Has_Technology_Partner__c = false;
                }
            }
            update opportunityList;
            
        } 
        
        /**for(Opportunity_Partner__c Partner:newOppPartnerList){
            if(Partner.Is_Primary__c == true){
                Partner.addError('You Cannot Delete Primary Partner Record');
            }
        }**
    }**/
    //Added by Swathi: CR 1926 Start
    public static void onBeforeDelete(list<Opportunity_Partner__c> newOppPartnerList){
        List<ID> oppId = new List<ID>();
        Map<id,Id> OppAccId = new map<id,id>();
        List<Opportunity> opptoUpdate = new List<Opportunity>();
                for(Opportunity_Partner__c OppPartnerList : newOppPartnerList){
                    if(OppPartnerList.Partner_Type__c == 'Tech Partner'){
                        oppId.add(OppPartnerList.Opportunity__c);
                        System.debug('oppId'+oppId);
                        OppAccId.put(OppPartnerList.Opportunity__c,OppPartnerList.Account__c);
                    }
                }
        Map<Id,Account> AccMap = New Map<Id,Account>([select ID,Name from Account where ID = :OppAccId.values()]);
        for(Opportunity Opprec : [select Id,Validated_Solution_Tech_Partner__c from Opportunity Where Id=:oppId]){
            string strPickListValue = Opprec.Validated_Solution_Tech_Partner__c;
            List<string> lstPicklistValues = new List<string>();
            if(!String.isBlank(strPickListValue)){
                lstPicklistValues = strPickListValue.split(';');
            }
            string strValueToRemove = AccMap.get(OppAccId.get(Opprec.Id)).Name;
            if(lstPicklistValues.contains(strValueToRemove)){
                lstPicklistValues.remove(lstPicklistValues.indexOf(strValueToRemove));
            }
            Opprec.Validated_Solution_Tech_Partner__c = String.join(lstPicklistValues,';');
            opptoUpdate.add(Opprec);
        }
        system.debug('opptoUpdate'+opptoUpdate);
        if(!opptoUpdate.isEmpty()){
            TriggerUtility2.setOppRelTechPartnerExecuted();
            update opptoUpdate;
        }
    }
    //Added by Swathi: CR 1926 End

    /**
    * @description: To delete the distributor associated with Reseller. 
                    We should not delete if distributor is associated with multiple partner 
    * @author rakshitha | 12-17-2021 
    * @param oldOppPartnerList 
    **/
    public static void deleteDistributor(list<Opportunity_Partner__c> oldOppPartnerList){
        List<Opportunity_Partner__c> distributorDeleteList = new list<Opportunity_Partner__c>();
        List<Id> resellerList = new List<Id>();
        List<Id> oppIdList = new List<Id>();
        Map<String,Integer> distributorResllerMap = new Map<String,Integer>();
        Map<String,Opportunity_Partner__c> distributorMap = new Map<String,Opportunity_Partner__c>();
        for(Opportunity_Partner__c opPartner:oldOppPartnerList){
            if(opPartner.Partner_Type__c=='Reseller' && opPartner.DistributorAccount__c!=null){
                distributorResllerMap.put(opPartner.DistributorAccount__c,0);
                system.debug(distributorResllerMap);
                resellerList.add(opPartner.Id);
                oppIdList.add(opPartner.Opportunity__c);
            }
        }
       List<Opportunity_Partner__c> partnerList = [SELECT Id,DistributorAccount__c,Account__c,Partner_Type__c FROM  Opportunity_Partner__c Where Opportunity__c In :oppIdList and (DistributorAccount__c In:distributorResllerMap.keySet() or Account__c In:distributorResllerMap.keySet()) and Id not In:resellerList ];
       for(Opportunity_Partner__c opPartner :partnerList){
         if(opPartner.Partner_Type__c =='Reseller'){
            distributorResllerMap.put(opPartner.DistributorAccount__c,distributorResllerMap.get(opPartner.DistributorAccount__c)+1);
         }else if(opPartner.Partner_Type__c =='Distributor'){
            distributorMap.put(opPartner.Account__c,opPartner);
         }
       }
       system.debug(distributorResllerMap);
       system.debug(distributorMap);
       for(String distributor :distributorResllerMap.keySet()){
           if(distributorResllerMap.get(distributor) == 0 && distributorMap.containsKey(distributor)){
              distributorDeleteList.add(distributorMap.get(distributor));
           }
       }

       if(!distributorDeleteList.isEmpty() && distributorDeleteList.size()>0){
           Delete distributorDeleteList;
       }
    }
    
    //Added by Chandan Panigrahy: CR# 2153 Start
    private static OpportunityPartnerTriggerHandler instance;
    
    public static OpportunityPartnerTriggerHandler getInstance() {
        if (instance == NULL) {
            instance = new OpportunityPartnerTriggerHandler();
        }
        
        return instance;
    }
    
    public void onAfterUpdate() {
        System.debug('-=- inside trigger after update -=- ');
        //Updating Teaming tech Partner to Influence Partner
        
        Map<Id, Id> relatedOppAccMap = new Map<Id, Id>();
        
        for (Opportunity_Partner__c opnew : (List<Opportunity_Partner__c>) Trigger.new) {
            if (opnew.Partner_Type__c.equalsIgnoreCase('Influence Partner')
                && ((String.isNotBlank(opnew.Approval_Status__c)) 
                    && (opnew.Approval_Status__c.equalsIgnoreCase('Approved')))) {
                relatedAccountIdSet = new Set<Id>();
                relatedAccountIdSet.add(opnew.Account__c);
                relatedOppAccMap.put(opnew.Opportunity__c, opnew.Account__c);
            }
        }
        
        for (Opportunity_Partner__c opRetrieved : [SELECT Id, Account__c, Opportunity__c,Account__r.Partner_Type__c,Partner_Type__c FROm Opportunity_Partner__c WHERE Opportunity__c IN :relatedOppAccMap.keySet() AND Account__c IN :relatedOppAccMap.values() AND (Partner_Type__c = 'Tech Partner' OR Account__r.Partner_Type__c='Partner-Integrator')]) {
            
            if ((opRetrieved.Partner_Type__c == 'Tech Partner' && relatedOppAccMap.containsKey(opRetrieved.Opportunity__c) 
                && (opRetrieved.Account__c != NULL)
                && (relatedOppAccMap.get(opRetrieved.Opportunity__c) == opRetrieved.Account__c)) 
                ||  (opRetrieved.Account__c!=Null && opRetrieved.Account__r.Partner_Type__c=='Partner-Integrator')) {
                
                    relatedAccountIdSet.remove(opRetrieved.Account__c);
            }
        }
        
        System.debug('-=-- relatedAccountIdSet -=- '+relatedAccountIdSet);
        setRelatedAccoudIdSet(relatedAccountIdSet);
        
        fetchRelatedAccountData();
        
        List<Opportunity_Partner__c> techPartnerOppPartnerList = new List<Opportunity_Partner__c> ();
        
        Opportunity_Partner__c techPartnerOppPartner;
        
        for (Opportunity_Partner__c opnew : (List<Opportunity_Partner__c>) Trigger.new) {
            
            Account acc = relatedAccountMap.containsKey(opnew.Account__c) 
                ? relatedAccountMap.get(opnew.Account__c) 
                : new Account();
            
            String modelTypePartner = '';
            
            if ((acc != NULL) 
                && (String.isNotBlank(acc.Model_Type_Partner__c)) 
                && (acc.Model_Type_Partner__c != 'Both') ) {
                modelTypePartner = acc.Model_Type_Partner__c;
            }
            
            
            
            if (((relatedAccountIdSet != NULL) 
                 && relatedAccountIdSet.contains(opnew.Account__c)) 
                && opnew.Approval_Status__c.equalsIgnoreCase('Approved') 
                && opnew.Partner_Type__c.equalsIgnoreCase('Influence Partner')) {
				techPartnerOppPartner = new Opportunity_Partner__c();
				techPartnerOppPartner.Account__c 		= opnew.Account__c;
                techPartnerOppPartner.Opportunity__c 	= opnew.Opportunity__c;
                techPartnerOppPartner.Partner_Type__c	= 'Tech Partner';
				techPartnerOppPartner.Partner_Program__c= acc.Model_Type_Partner__c == 'Both'
                    ? Label.Partner_Program_Partner_Summit
                    : modelTypePartner;
                
                
                
                techPartnerOppPartnerList.add(techPartnerOppPartner);
            }
        }
        
        
        if (!techPartnerOppPartnerList.isEmpty()) {
        	INSERT techPartnerOppPartnerList;    
        }
        
        
        System.debug('-=- techPartnerOppPartnerList =- '+techPartnerOppPartnerList);
    }
    
    private Set<Id> relatedAccountIdSet;
    private void setRelatedAccoudIdSet(Set<Id> relatedAccountIdSet) {
        this.relatedAccountIdSet = relatedAccountIdSet;
    }
    
    private Map<Id, Account> relatedAccountMap;
    private void setRelatedAccountMap(Map<Id, Account> relatedAccountMap) {
        this.relatedAccountMap = new Map<Id, Account>();
        this.relatedAccountMap = relatedAccountMap;
    }
    
    private void fetchRelatedAccountData() {
        Map<Id, Account> relatedAccountMap = new Map<Id, Account> (
            [
                SELECT 
                	Id, 
                	Model_Type_Partner__c 
                FROM 
                	Account 
                WHERE 
                	Id = :relatedAccountIdSet
            	LIMIT 50000
            ]
        );
        setRelatedAccountMap(relatedAccountMap);
    }
    
    //Added by Chandan Panigrahy: CR# 2153 End
}