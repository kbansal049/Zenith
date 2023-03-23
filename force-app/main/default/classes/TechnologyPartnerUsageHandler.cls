/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* TechnologyPartnerUsageHandler
* @description    This is the Technology_Partner_Usage__c Trigger handler class called synchronously 
*                   from TechnologyPartnerUsageTrigger.
*                   All the methods needs to be called synchronously from the TechnologyPartnerUsageTrigger
*                   should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2021-12-03
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class TechnologyPartnerUsageHandler extends TriggerHandler {
    
    public override void beforeInsert(){
        System.debug('TechnologyPartnerUsageHandler BeforeInsert Is Invoked');
        
        TechnologyPartnerUsageHelper technologyPartnerUsageHelperObj = new TechnologyPartnerUsageHelper();
        List<Technology_Partner_Usage__c> newTechnologyPartnerUsageList = new List<Technology_Partner_Usage__c>();
        Set<String> cloudNameCompanyIdSet = new Set<String>();
        Map<String,Zscaler_Cloud_ID__c> zScalerCouldIdMap = new Map<String,Zscaler_Cloud_ID__c>();
        Set<Id> customerTechPartnerAccountIds = new Set<Id>();
        Id loggedInid = UserInfo.getUserid();
        Id IntegrationuseridforTP=id.valueof(ZscalerCustomSetting__c.getInstance('IntegrationuseridforTP')!=null && ZscalerCustomSetting__c.getInstance('IntegrationuseridforTP').Value__c!=null ? ZscalerCustomSetting__c.getInstance('IntegrationuseridforTP').Value__c:'0054u0000075JtcAAE');

        for (SObject techPartnerUsageRecord: Trigger.new) {            
            Technology_Partner_Usage__c newTechnologyPartnerUsage = (Technology_Partner_Usage__c) techPartnerUsageRecord;
            system.debug('inside techPartnerUsageRecord '+techPartnerUsageRecord);
            //Added as part of CR# 4146 : Start
            //if(!System.isbatch() || (IntegrationuseridforTP!=loggedInid)){
            if(!System.isbatch() && IntegrationuseridforTP!=loggedInid){
                system.debug('inside if condition');
                //if(newTechnologyPartnerUsage.Is_Primary__c==true){
                    newTechnologyPartnerUsage.Do_Not_Override__c=true;
                //}
            }
            //Added as part of CR# 4146 : End
            
            if(newTechnologyPartnerUsage.Org_ID__c == NULL){
                String orgIdStr = newTechnologyPartnerUsage.Cloud_Name__c + '-' + newTechnologyPartnerUsage.Company_Id__c;
                //Due to case sensitivity OrgIds were not getting mapped, added toLowerCase()
                cloudNameCompanyIdSet.add(orgIdStr.toLowerCase());
            }
            //Add Customer Account and Tech partner Account Ids to fetch related field values to pre-populate
            if(newTechnologyPartnerUsage.Customer_Account__c != NULL){
                customerTechPartnerAccountIds.add(newTechnologyPartnerUsage.Customer_Account__c);
            }
            if(newTechnologyPartnerUsage.Technology_Partner_Id__c != NULL){
                customerTechPartnerAccountIds.add(newTechnologyPartnerUsage.Technology_Partner_Id__c);
            }
            
            newTechnologyPartnerUsageList.add(newTechnologyPartnerUsage);
        }
        
        if(!cloudNameCompanyIdSet.isEmpty()){
            zScalerCouldIdMap = TechnologyPartnerUsageHelper.getZscalerCloudIdRecords(cloudNameCompanyIdSet);
        }
        
        if(!zScalerCouldIdMap.isEmpty()){
            for(Technology_Partner_Usage__c techPartnerUsageRecord : newTechnologyPartnerUsageList){
                if(techPartnerUsageRecord.Org_ID__c == NULL){
                String orgIdStr = techPartnerUsageRecord.Cloud_Name__c + '-' + techPartnerUsageRecord.Company_Id__c;
                    //Due to case sensitivity OrgIds were not getting mapped, added toLowerCase()
                    if(zScalerCouldIdMap.containsKey(orgIdStr.toLowerCase())){
                        techPartnerUsageRecord.Org_ID__c = zScalerCouldIdMap.get(orgIdStr.toLowerCase()).Id;
                    }
                }
            }
        }
        if(!customerTechPartnerAccountIds.isEmpty()){
            newTechnologyPartnerUsageList = 
                technologyPartnerUsageHelperObj.populateCustomerFieldsOnInsert(newTechnologyPartnerUsageList,customerTechPartnerAccountIds);
        }
        newTechnologyPartnerUsageList=technologyPartnerUsageHelperObj.updateExternalIdOnRecordsInsert(newTechnologyPartnerUsageList);
        
    }
    
    public override void beforeUpdate(){
        System.debug('TechnologyPartnerUsageHandler beforeUpdate Is Invoked');
        TechnologyPartnerUsageHelper technologyPartnerUsageHelperObj = new TechnologyPartnerUsageHelper();
        Map<Id, Technology_Partner_Usage__c> newTechPartnerUsageMap = new Map<Id,Technology_Partner_Usage__c>();
        Map<Id, Technology_Partner_Usage__c> oldTechPartnerUsageMap = new Map<Id,Technology_Partner_Usage__c>();
        Set<Id> customerTechPartnerAccountIds = new Set<Id>();
        String loggedInUserName = UserInfo.getUserName();
        Id loggedInid = UserInfo.getUserid();
        Id IntegrationuseridforTP=id.valueof(ZscalerCustomSetting__c.getInstance('IntegrationuseridforTP')!=null && ZscalerCustomSetting__c.getInstance('IntegrationuseridforTP').Value__c!=null ? ZscalerCustomSetting__c.getInstance('IntegrationuseridforTP').Value__c:'0054u0000075JtcAAE');
        
        for (SObject campn: Trigger.new) {
            Technology_Partner_Usage__c newTechPartnerUsage = (Technology_Partner_Usage__c) campn;
            Technology_Partner_Usage__c oldTechPartnerUsage = (Technology_Partner_Usage__c) Trigger.oldMap.get(newTechPartnerUsage.Id);
            
            //DO NOT OVERWRITE existing/manually modified data with Data coming from integration
            
            //Added as part of CR# 4146 : Start
            //if(!System.isbatch() || (IntegrationuseridforTP!=loggedInid)){
            if(!System.isbatch() && IntegrationuseridforTP!=loggedInid){
                system.debug('inside if condition');
                //if((newTechPartnerUsage.Is_Primary__c != oldTechPartnerUsage.Is_Primary__c && newTechPartnerUsage.Is_Primary__c==true ) || (newTechPartnerUsage.Segment__c != oldTechPartnerUsage.Segment__c) || (newTechPartnerUsage.Usage_Type__c != oldTechPartnerUsage.Usage_Type__c)){
                    system.debug('inside if condition');
                    newTechPartnerUsage.Do_Not_Override__c=true;
                //}
            }
            //Added as part of CR# 4146 : End
            
            if(loggedInUserName.contains('integration') && oldTechPartnerUsage.ExcludeFromIntegrationUpdate__c){
                if(newTechPartnerUsage.Is_Primary__c != oldTechPartnerUsage.Is_Primary__c){
                    newTechPartnerUsage.Is_Primary__c = oldTechPartnerUsage.Is_Primary__c;
                }
                if(newTechPartnerUsage.Technology_Partner_Id__c != oldTechPartnerUsage.Technology_Partner_Id__c){
                    newTechPartnerUsage.Technology_Partner_Id__c = oldTechPartnerUsage.Technology_Partner_Id__c;
                }
                if(newTechPartnerUsage.Org_ID__c != oldTechPartnerUsage.Org_ID__c){
                    newTechPartnerUsage.Org_ID__c = oldTechPartnerUsage.Org_ID__c;
                }
            }
            
            //Add Customer Account and Tech partner Account Ids to fetch related field values to pre-populate
            if(newTechPartnerUsage.Customer_Account__c != oldTechPartnerUsage.Customer_Account__c){
                customerTechPartnerAccountIds.add(newTechPartnerUsage.Customer_Account__c);
            }
            if(newTechPartnerUsage.Technology_Partner_Id__c != oldTechPartnerUsage.Customer_Account__c){
                customerTechPartnerAccountIds.add(newTechPartnerUsage.Technology_Partner_Id__c);
            }
            
            newTechPartnerUsageMap.put(newTechPartnerUsage.Id, newTechPartnerUsage);
            oldTechPartnerUsageMap.put(oldTechPartnerUsage.Id, oldTechPartnerUsage);
        }
        
        if(!customerTechPartnerAccountIds.isEmpty()){
            newTechPartnerUsageMap = 
                technologyPartnerUsageHelperObj.populateCustomerFieldsOnUpdate(newTechPartnerUsageMap,customerTechPartnerAccountIds);
        }
        newTechPartnerUsageMap = 
                technologyPartnerUsageHelperObj.updateExternalIdOnRecordsUpdate(newTechPartnerUsageMap);
    }
    
    public override void afterInsert(){
        System.debug('TechnologyPartnerUsageHandler afterInsert Is Invoked');
        
        TechnologyPartnerUsageHelper technologyPartnerUsageHelperObj = new TechnologyPartnerUsageHelper();
        Map<Id, Technology_Partner_Usage__c> newTechnologyPartnerUsageMap = new Map<Id,Technology_Partner_Usage__c>();
        Map<Id,String> customerAccountIdSegmentStringMap = new Map<Id,String>();
        Set<Id> newTechPartnerUsageIdSet = new Set<Id>();
        List<Id> newTechPartnerUsageIdList = new List<Id>();
        
        for (SObject techPartnerUsageRecord: Trigger.new) {
            Technology_Partner_Usage__c newTechnologyPartnerUsage = (Technology_Partner_Usage__c) techPartnerUsageRecord;
            newTechPartnerUsageIdSet.add(newTechnologyPartnerUsage.Id);
            if(newTechnologyPartnerUsage.Is_Primary__c){
                customerAccountIdSegmentStringMap.put(newTechnologyPartnerUsage.Customer_Account__c, newTechnologyPartnerUsage.Segment__c);
            }
        }
        newTechPartnerUsageIdList.addAll(newTechPartnerUsageIdSet);//AuraEnabled method does not support Set<Id>
        if(!customerAccountIdSegmentStringMap.isEmpty() && !newTechPartnerUsageIdList.isEmpty()){
            TechnologyPartnerUsageHelper.updateIsPrimaryFieldOnTechPartnerRecords(customerAccountIdSegmentStringMap,newTechPartnerUsageIdList);
        }
        
    }
    
    public override void afterUpdate(){        
        
    }
    
    public boolean qualifiedUpdate(Technology_Partner_Usage__c newTechPartnerUsage, 
                                   Technology_Partner_Usage__c oldTechPartnerUsage){
        
        Boolean valChanged = false;
        /*
        if( newTechPartnerUsage.Name != oldTechPartnerUsage.Name)
        {
            valChanged = true;
        } 
        */
        return valChanged;
    }
}