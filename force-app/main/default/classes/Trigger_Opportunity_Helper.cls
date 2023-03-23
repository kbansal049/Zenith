/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2022-05-30      CR# 4889 Bikram - Update the logic of Link to Competitors Content field.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class Trigger_Opportunity_Helper{

    public static Set<Id> setRenewedContractIds = new Set<Id>();
    public static  Map<Id,Contract> mapRenewedContract = new Map<Id,Contract>();

    //Method to set set the renewal opportunity field values
    public static void setOpportunityFields(List<Opportunity> listNewOppty){
        List<Opportunity> listRenewalOppty = new List<Opportunity>();
        setRenewedContractIds = new Set<Id>();
        for(Opportunity objOpp : listNewOppty){
            if(objOpp.SBQQ__RenewedContract__c!=null){
                listRenewalOppty.add(objOpp);    
                setRenewedContractIds.add(objOpp.SBQQ__RenewedContract__c);
            }
        }
        if(!listRenewalOppty.isEmpty()){
            Id idRenewalRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
            // IBA-1700 - Added SBQQ__Opportunity__r.Is_Federal_Opportunity_Sync__c field
            mapRenewedContract = new Map<Id,Contract>([SELECT Id,EndDate,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Pricebook2Id,SBQQ__Opportunity__r.Amount,SBQQ__Opportunity__r.Name,SBQQ__Opportunity__r.Is_Federal_Opportunity_Sync__c,Partner__c,Partner_Program__c,AccountId,Account.Customer_Advocate__c,Account.OwnerId,Partner__r.Ultimate_Parent_Account__c,Account.Sales_Territory__c,Account.Sales_Territory__r.Customer_Advocate__c FROM Contract WHERE Id In: setRenewedContractIds]);
            for(Opportunity objOpp: listRenewalOppty){
                objOpp.RecordTypeId = idRenewalRT;
                objOpp.Type = 'Existing Customer (Renewal)';
                objOpp.Forecast_Category__c = 'Best Case';
                objOpp.Stagename = '4 - Impact Validation';
                if(objOpp.SBQQ__RenewedContract__c!=null && mapRenewedContract!=null && mapRenewedContract.containsKey(objOpp.SBQQ__RenewedContract__c)){
                    Contract objContract = mapRenewedContract.get(objOpp.SBQQ__RenewedContract__c);
                    if(objOpp.Custom_Renewal__c ==FALSE){
                        objOpp.Renewal_Amount__c = objContract.SBQQ__Opportunity__r.Amount;
                        objOpp.CloseDate = objContract.EndDate;//.addDays(1);
                    }
                    objOpp.Contract_End_Date_New__c = objContract.EndDate;
                    objOpp.Name = objContract.SBQQ__Opportunity__r.Name + ' - Renewal';
                    objOpp.Is_Federal_Opportunity_Sync__c = objContract.SBQQ__Opportunity__r.Is_Federal_Opportunity_Sync__c;  // IBA-1700
                    objOpp.Pricebook2Id = objContract.SBQQ__Opportunity__r.Pricebook2Id; //aded to avoid pricebook fieldIntegrity exception
                    if(objOpp.Custom_Renewal__c ==TRUE){
                        objOpp.Name+= ' (Add-Ons)';
                    }
                    objOpp.Primary_Reseller_Partner__c = objContract.Partner__c;
                    objopp.Primary_Partner_Program__c = objContract.Partner_Program__c;
                    objopp.ImpartnerPRM__PartnerAccount__c = (objContract.Partner__c!=null && objContract.Partner__r.Ultimate_Parent_Account__c != null) ? objContract.Partner__r.Ultimate_Parent_Account__c : objContract.Partner__c;
                    if(objContract.Account!=null && objContract.Account!=null && objContract.Account.Sales_territory__c!=null && objContract.Account.Sales_Territory__r.Customer_Advocate__c!=null){
                        objOpp.OwnerId =  objContract.Account.Sales_Territory__r.Customer_Advocate__c;
                    }
                }                
            }
        }
    }
   
    //Added by Arsh - CR# 4631
    //Add Competitor Context for opportunity competitor
    public static void setCompetitorContext(List<Opportunity> listNewOppty,Map<id,Opportunity> oldMap){
        
        for(Opportunity objOpp : listNewOppty){
                        
            //CR# 4889 START - Bikram 30th May 2022
            Set<String> newSelections = objOpp.Primary_Competitor__c == null ? 
                new Set<String>() : new Set<String>{objOpp.Primary_Competitor__c};            
            Set<String> oldSelections = (Trigger.isInsert || oldMap.get(objOpp.Id).Primary_Competitor__c == null) ? 
                new Set<String>() : new Set<String>{oldMap.get(objOpp.Id).Primary_Competitor__c};            
            //CR# 4889 END - Bikram 30th May 2022
            
            //Set<String> newSelections = objOpp.Competitor__c == null ? 
            //    new Set<String>() : new Set<String>(objOpp.Competitor__c.split(';')) ;
            //Set<String> oldSelections = (Trigger.isInsert || oldMap.get(objOpp.Id).Competitor__c == null) ? 
            //    new Set<String>() : new Set<String>(oldMap.get(objOpp.Id).Competitor__c.split(';'));
            
            System.debug('new selections: ' + newSelections );
            System.debug('old selections: ' + oldSelections );
            
            if(!(newSelections.equals(oldSelections))){
                objOpp.Competitor_Content_Technical__c = '';
                if(newSelections.contains('Netskope')){
                	objOpp.Competitor_Content_Technical__c = objOpp.Competitor_Content_Technical__c + ' Netskope ';
                    newSelections.remove('Netskope');
                }
                if(newSelections.contains('Palo Alto Networks')){
                	objOpp.Competitor_Content_Technical__c = objOpp.Competitor_Content_Technical__c + ' PaloAltoNetworks ';
                    newSelections.remove('Palo Alto Networks');
                }
                if(newSelections.size()>0){
                    objOpp.Competitor_Content_Technical__c = objOpp.Competitor_Content_Technical__c + ' Others ';
                }
            }
        }
    }

    //Insert Opportunity Partner Records for renewals
    public static void createOpportunityPartnerRecords(List<Opportunity> listNewOppty){
        Set<Id> setRenewalContractIds = new Set<Id>();
        system.debug('listNewOppty## '+listNewOppty);
        if(!mapRenewedContract.isEmpty()){
            Map<Id,Id> mapContractToSourceOpptyId = new Map<Id,Id>();
            Map<Id,Opportunity> mapSourceOpptyIdToREnewal = new Map<Id,Opportunity>();
            Set<Id> oppIds = new Set<Id>();
            
            for(Contract objContract : mapRenewedContract.values()){
                mapContractToSourceOpptyId.put(objContract.id,objContract.SBQQ__opportunity__c);
            }
            Date dtRefMin = System.Today();
            Date dtRefMax = System.Today();
            for(Opportunity objOpp: listNewOppty){
                if(objOpp.SBQQ__RenewedContract__C!=null && mapContractToSourceOpptyId.containsKey(objOpp.SBQQ__RenewedContract__C)){
                    mapSourceOpptyIdToREnewal.put(mapContractToSourceOpptyId.get(objOpp.SBQQ__RenewedContract__c),objOpp);   
                    if(objOpp.CloseDate > dtRefMax){
                        dtRefMax = objOpp.CloseDate;
                    }
                    if(objOpp.CloseDate < dtRefMin){
                        dtRefMin = objOpp.CloseDate;
                    }
                }
            }
            
            List<Opportunity_Partner__c> oppPartnerRecs = new List<Opportunity_Partner__c>();
            
            if(!mapSourceOpptyIdToREnewal.isEmpty() && mapSourceOpptyIdToREnewal.size() > 0){
                for(Id oId: mapSourceOpptyIdToREnewal.keyset()){
                    if(oId != null ){
                        oppIds.add(oId);
                    }
                }
            }
            if(!oppIds.isEmpty()){
                oppPartnerRecs = [SELECT Id, Name, Account__c,Account__r.Name,Approval_Status__c,Is_Primary__c,
                                  Opportunity__c,Opportunity_Type__c,Opportunity__r.Name,Partner_Program__c,Partner_Type__c
                                  FROM Opportunity_Partner__c WHERE Opportunity__c IN:oppIds 
                                  AND Partner_Type__c IN ('Reseller','Distributor')];
            } 
            
            if(oppPartnerRecs.size()>0 ){
                Set<Id> setAccountIds = new Set<Id>();
                for(Opportunity_Partner__c objOppPartner : oppPartnerRecs){
                    setAccountIds.add(objOppPartner.Account__c);
                }
                Map<Id,Account> mapAccountInfo = new Map<Id,Account>([SELECT ID,(SELECT id,Account__c,Active__c,Partner_Program__c,Partner_Role__c,Partner_Tier__c,Effective_End_Date__c,Effective_Start_Date__c,Default__c  FROM Partner_Incentives__r WHERE Account__c=:setAccountIds AND Active__c = true AND ((Effective_Start_date__C>=:dtRefMin AND Effective_End_date__C <=:dtRefMax) OR Default__c = TRUE)) FROM Account WHERE Id In: setAccountIds]);
                
                List<Opportunity_Partner__c> listOpptyPartnerToInsert = new List<Opportunity_Partner__c> ();
                for(Opportunity_Partner__c objOldOpptyPartner:oppPartnerRecs){
                    Opportunity objNewOppty = new Opportunity();
                    if(mapSourceOpptyIdToREnewal.containsKey(objOldOpptyPartner.Opportunity__c)){
                        objNewOppty = mapSourceOpptyIdToREnewal.get(objOldOpptyPartner.Opportunity__c);
                        if(objNewOppty.AccountId!= objOldOpptyPartner.Account__c){
                            Opportunity_Partner__c objOpptyPartner = new Opportunity_Partner__c();
                            objOpptyPartner.Is_Primary__c = objOldOpptyPartner.Is_Primary__c;
                            objOpptyPartner.Partner_Type__c = objOldOpptyPartner.Partner_Type__c;
                            objOpptyPartner.Partner_Program__c = objOldOpptyPartner.Partner_Program__c;
                            objOpptyPartner.Account__c = objOldOpptyPartner.Account__c;
                            objOpptyPartner.Opportunity__c = objNewOppty.Id;
                            objOpptyPartner.Partner_Type__c = objOldOpptyPartner.Partner_Type__c;
                            objOpptyPartner.Approval_Status__c = objOldOpptyPartner.Approval_Status__c;
                            if(mapAccountInfo!=null && mapAccountInfo.containsKey(objOldOpptyPartner.Account__c)){
                                Id objDefaultPI ;
                                for(Partner_Incentive__C objPartnerInc : mapAccountInfo.get(objOldOpptyPartner.Account__c).Partner_Incentives__r){
                                    if(objPartnerInc.Effective_Start_Date__c <= objNewOppty.CloseDate && objPartnerInc.Effective_End_Date__c >= objNewOppty.CloseDate){
                                        objOpptyPartner.Partner_Incentive__C =  objPartnerInc.id;  
                                    }else if(objPartnerInc.Default__c  == TRUE){
                                        objDefaultPI = objPartnerInc.id;
                                        //objOpptyPartner.Partner_Incentive__C =  objPartnerInc.id;     
                                    }
                                }
                                if(objOpptyPartner.Partner_Incentive__C==null && objDefaultPI!=null ){
                                    objOpptyPartner.Partner_Incentive__C = objDefaultPI;
                                }
                            }
                            listOpptyPartnerToInsert.Add(objOpptyPartner);
                            system.debug('listOpptyPartnerToInsert## '+listOpptyPartnerToInsert);
                            
                            
                        }                        
                    }                    
                }
                                    
                if(listOpptyPartnerToInsert.size()>0){
                    insert listOpptyPartnerToInsert;
                }
            }
        }
    }
    
    /*
    * @Description : Show Notification on Quote if Deal Reg Partner (Sourced) / 
    * 				 Deal Reg Partner (Teaming - Reseller) is changed on Opportunity to apply the correct discounts.
    * @Param       : List<Opportunity> oppNewList,Map<id,Opportunity> oldMap
    * @return      : void
    * @throws exception : NONE
    */
    public static void notifyOnDealRegChange(List<Opportunity> oppNewList, Map<id,Opportunity> oldMap){
        map<Id,set<Id>> oppIdVsAccIdMap = new map<Id,set<Id>>();
        List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();
        for(Opportunity opp : oppNewList){
            if(opp.Deal_Reg_Margin__c != oldMap.get(opp.Id).Deal_Reg_Margin__c){
                if(oppIdVsAccIdMap.containsKey(opp.Id)){
                    oppIdVsAccIdMap.get(opp.Id).add(opp.Deal_Reg_Margin__c);
                    oppIdVsAccIdMap.get(opp.Id).add(oldMap.get(opp.Id).Deal_Reg_Margin__c);
                }else{
                    set<id> tempOppId = new set<id>();
                    tempOppId.add(opp.Deal_Reg_Margin__c);
                    tempOppId.add(oldMap.get(opp.Id).Deal_Reg_Margin__c);
                    oppIdVsAccIdMap.put(opp.Id,tempOppId);
                }
            }if(opp.Deal_Reg_Partner_Teaming_Reseller__c != oldMap.get(opp.Id).Deal_Reg_Partner_Teaming_Reseller__c){
                if(oppIdVsAccIdMap.containsKey(opp.Id)){
                    oppIdVsAccIdMap.get(opp.Id).add(opp.Deal_Reg_Partner_Teaming_Reseller__c);
                    oppIdVsAccIdMap.get(opp.Id).add(oldMap.get(opp.Id).Deal_Reg_Partner_Teaming_Reseller__c);
                }else{
                    set<id> tempOppId = new set<id>();
                    tempOppId.add(opp.Deal_Reg_Partner_Teaming_Reseller__c);
                    tempOppId.add(oldMap.get(opp.Id).Deal_Reg_Partner_Teaming_Reseller__c);
                    oppIdVsAccIdMap.put(opp.Id,tempOppId);
                }
            }
        }
        system.debug('oppIdVsAccIdMap'+oppIdVsAccIdMap);
        if(!oppIdVsAccIdMap.isEmpty()){
            for(SBQQ__Quote__c quote : [Select id,SBQQ__Account__c,Show_Banner__c,SBQQ__Status__c,SBQQ__Opportunity2__c,SBQQ__Partner__c,Partner_Program__c from SBQQ__Quote__c where SBQQ__Opportunity2__c IN:oppIdVsAccIdMap.keySet() /*and SBQQ__Partner__c IN :oppIdVsAccIdMap.values()*/]){
                Id quoteOppId = quote.SBQQ__Opportunity2__c;
                if(oppIdVsAccIdMap.get(quoteOppId).contains(quote.SBQQ__Partner__c)){
                    /*if(quote.SBQQ__Status__c == 'Approved'){
                        quote.SBQQ__Status__c = 'Draft';
                    }*/
                    quote.Show_Banner__c = true;
                    quoteToUpdate.add(quote);
                }
            }
            system.debug('quoteToUpdate'+quoteToUpdate);
            if(!quoteToUpdate.isEmpty()){
                update quoteToUpdate;
            }
        }
    }
    public static void setPSSKUfield(List<Opportunity> newOpportunityList,  Map<Id,Opportunity> opportunityOldMap){
        for(Opportunity oppRec:newOpportunityList){
                       oppRec.PS_SKU_System__c = oppRec.DAS_Package_New__c;
         }
    }
}