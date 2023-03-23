public with sharing class ContractDetailBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('ContractDetailBatch');
    public Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        String query = 'SELECT Id, Account__c, First_ZDX_Contract_Date__c FROM Account_Extension__c WHERE First_ZDX_Contract_Date__c = NULL';
        
        System.debug('-=-= query -=- '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account_Extension__c> accExtList){
        this.zb.callExecute('Account_Extension__c', accExtList.size());
        System.debug('-=- inside execute -=- '+accExtList);
        
        Map<Id, Id> accVsAccExt = new Map<Id, Id>();
        Map<Id,Account_Extension__c> accExtMap = new Map<Id,Account_Extension__c> ();
        
        for (Account_Extension__c accExt : accExtList) {
            
            accExtMap.put(accExt.Id, accExt);
            
            accVsAccExt.put(accExt.Account__c, accExt.Id);
            
        }
        
        System.debug('-=- accVsAccExt -=- '+accVsAccExt);
        
        
        Set<String> setSKUCodes = new Set<String>();
        setSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZDX_Contract_Date').SKU_Codes__c.split(';'));
        
        
        List<Contract_Detail__c> contractDetails = [SELECT Id, Account_Name__c, Start_Date__c,Product_SKU__c 
                                                    FROM Contract_Detail__c 
                                                    WHERE Account_Name__c IN :accVsAccExt.keySet() 
                                                    AND Start_Date__c != Null 
                                                    AND Product_SKU__c IN :setSKUCodes];
        
        System.debug('-=- contractDetails -=- '+contractDetails);
        Map<Id,Date> accMinDateMap = new  Map<Id,Date>();
        for(Contract_Detail__c cd : contractDetails){
            if(accMinDateMap.containsKey(cd.Account_Name__c)){
                Date minDate =  accMinDateMap.get(cd.Account_Name__c);
                if(minDate > cd.Start_Date__c){ 
                    accMinDateMap.put(cd.Account_Name__c, cd.Start_Date__c);
                }
            }else{
                accMinDateMap.put(cd.Account_Name__c, cd.Start_Date__c);
            }                                                     
        }
        
        List<Account_Extension__c> accExtToUpdateList = new List<Account_Extension__c>();
        for(Id accId : accMinDateMap.keySet()){
            
            
            
            Account_Extension__c acExt = accExtMap.get(accVsAccExt.get(accId));
            
            if((acExt.First_ZDX_Contract_Date__c == NULL) || (acExt.First_ZDX_Contract_Date__c > accMinDateMap.get(accId))){
                acExt.First_ZDX_Contract_Date__c = accMinDateMap.get(accId);
                accExtToUpdateList.add(acExt);
            }
        }
        
        if(!accExtToUpdateList.isEmpty()){
            UPDATE accExtToUpdateList;
        }
        
        
        
        
        
        
        
        
        
    }
    
    public void finish(Database.BatchableContext BC){
        this.zb.callFinish(BC);
    }
}