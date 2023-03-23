/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* TechnologyPartnerUsageHelper
* @description    
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
public class TechnologyPartnerUsageHelper {
    
    public static Map<String,Zscaler_Cloud_ID__c> getZscalerCloudIdRecords(Set<String> cloudNameCompanyIdSet){
        Map<String,Zscaler_Cloud_ID__c> zScalerCouldIdMap = new Map<String,Zscaler_Cloud_ID__c>();
        
        List<Zscaler_Cloud_ID__c> zscalerCloudIdList = [SELECT Id, Name 
                                                        FROM Zscaler_Cloud_ID__c
                                                        WHERE Name IN : cloudNameCompanyIdSet];
        
        for(Zscaler_Cloud_ID__c zscalerCloudIdRecord : zscalerCloudIdList){
            //Due to case sensitivity OrgIds were not getting mapped, added toLowerCase()
            zScalerCouldIdMap.put(zscalerCloudIdRecord.Name.toLowerCase(),zscalerCloudIdRecord);
        }
        
        return zScalerCouldIdMap;
    }
    
    @AuraEnabled
    public static void updateIsPrimaryFieldOnTechPartnerRecords(Map<Id,String> customerAccountIdSegmentStringMap, List<Id> technologyPartnerUsageIds){
        
        System.debug('customerAccountIdSegmentStringMap : ' + customerAccountIdSegmentStringMap);
        System.debug('technologyPartnerUsageIds : ' + technologyPartnerUsageIds);
        List<Technology_Partner_Usage__c> recordsToUpdate = new List<Technology_Partner_Usage__c>();
        List<Technology_Partner_Usage__c> techPartnerUsageRecordList = [SELECT Id,
                                                                        Customer_Account__c,
                                                                        Segment__c,
                                                                        Is_Primary__c
                                                                        FROM Technology_Partner_Usage__c
                                                                        WHERE 
                                                                        Customer_Account__c IN :customerAccountIdSegmentStringMap.keySet()];
        
        for(Technology_Partner_Usage__c techPartnerUsageRecord : techPartnerUsageRecordList){
            if(!technologyPartnerUsageIds.contains(techPartnerUsageRecord.Id) &&
               customerAccountIdSegmentStringMap.containsKey(techPartnerUsageRecord.Customer_Account__c) &&
               techPartnerUsageRecord.Segment__c == customerAccountIdSegmentStringMap.get(techPartnerUsageRecord.Customer_Account__c) &&
               techPartnerUsageRecord.Is_Primary__c){
                   Technology_Partner_Usage__c record = new Technology_Partner_Usage__c();
                   record.Id = techPartnerUsageRecord.Id;
                   record.Is_Primary__c = FALSE;
                   recordsToUpdate.add(record);
               }
        }        
        System.debug('recordsToUpdate : ' + recordsToUpdate);        
        if(!recordsToUpdate.isEmpty()){
            update recordsToUpdate;
        }
    }
    
    public List<Technology_Partner_Usage__c> populateCustomerFieldsOnInsert(List<Technology_Partner_Usage__c> newTechnologyPartnerUsageList, Set<Id> customerTechPartnerAccountIds){
        
        Map<Id,Account> accountIdRecordMap = new Map<Id,Account> ([SELECT Id,
                                                                   Name, Type                                                                   
                                                                   FROM Account
                                                                   WHERE Id IN :customerTechPartnerAccountIds]);
        
        for(Technology_Partner_Usage__c techPartnerUsageRecord : newTechnologyPartnerUsageList){           
            if(accountIdRecordMap.containsKey(techPartnerUsageRecord.Customer_Account__c)){                
                if(accountIdRecordMap.get(techPartnerUsageRecord.Customer_Account__c).Type == 'Customer'){
                    techPartnerUsageRecord.Company_Name__c = accountIdRecordMap.get(techPartnerUsageRecord.Customer_Account__c).Name;
                    techPartnerUsageRecord.Account_Type__c = 'Customer';
                }                
            }else if(accountIdRecordMap.containsKey(techPartnerUsageRecord.Technology_Partner_Id__c)){
                if(accountIdRecordMap.get(techPartnerUsageRecord.Technology_Partner_Id__c).Type == 'Technology Partner'){
                    techPartnerUsageRecord.Technology_Partner__c = accountIdRecordMap.get(techPartnerUsageRecord.Technology_Partner_Id__c).Name;
                }
                
            }                
        }
        
        return newTechnologyPartnerUsageList;        
    }
    
    public Map<Id, Technology_Partner_Usage__c> populateCustomerFieldsOnUpdate(Map<Id, Technology_Partner_Usage__c> newTechPartnerUsageMap, Set<Id> customerTechPartnerAccountIds){
        
        Map<Id,Account> accountIdRecordMap = new Map<Id,Account> ([SELECT Id,
                                                                   Name, Type                                                                   
                                                                   FROM Account
                                                                   WHERE Id IN :customerTechPartnerAccountIds]);
        
        for(Technology_Partner_Usage__c techPartnerUsageRecord : newTechPartnerUsageMap.values()){
            if(accountIdRecordMap.containsKey(techPartnerUsageRecord.Customer_Account__c)){                
                if(accountIdRecordMap.get(techPartnerUsageRecord.Customer_Account__c).Type == 'Customer'){
                    techPartnerUsageRecord.Company_Name__c = accountIdRecordMap.get(techPartnerUsageRecord.Customer_Account__c).Name;
                    techPartnerUsageRecord.Account_Type__c = 'Customer';
                }                
            }else if(accountIdRecordMap.containsKey(techPartnerUsageRecord.Technology_Partner_Id__c)){
                if(accountIdRecordMap.get(techPartnerUsageRecord.Technology_Partner_Id__c).Type == 'Technology Partner'){
                    techPartnerUsageRecord.Technology_Partner__c = accountIdRecordMap.get(techPartnerUsageRecord.Technology_Partner_Id__c).Name;
                }
                
            }
        }
        return newTechPartnerUsageMap;        
    }
    
    // 0017000001VmzxdAAB-0014u00001md9oSAAQ-634560-zscalerthree.net-Solution-Identity
    //Customer_Account__c-Technology_Partner_Id__c-Company_Id__c-Cloud_Name__c-Usage_Type__c-Segment__c
    public List<Technology_Partner_Usage__c> updateExternalIdOnRecordsInsert(List<Technology_Partner_Usage__c> newTechnologyPartnerUsageList){
        system.debug('inside updateExternalIdOnRecords method');
        for(Technology_Partner_Usage__c tpu : newTechnologyPartnerUsageList){
            system.debug('tpu   '+tpu);
            if(tpu.External_Id__c==null || tpu.External_Id__c==''){             
                string externalid='';
                String delimiter = '-';             
                String input = tpu.Org_ID_Name__c;
                String cloudname='';
                String companyid='';
                system.debug('input ' +input);
                if(input!=null && input!=''){
                    cloudname= input.substringBefore(delimiter); 
                    companyid = input.substringAfter(delimiter);
                }
                system.debug('firstSplit ' +cloudname);
                system.debug('lastSplits ' +companyid);
                externalid=tpu.Customer_Account__c + '-' +tpu.Technology_Partner_Id__c  + '-' + companyid + '-' +  cloudname    + '-' +  tpu.Usage_Type__c + '-' + tpu.Segment__c;
                system.debug('externalid'+externalid);
                tpu.External_Id__c=externalid;
                tpu.Company_Id__c=companyid;
                tpu.Cloud_Name__c=cloudname;
            }
        }
        return newTechnologyPartnerUsageList;
    }
    
    public Map<Id, Technology_Partner_Usage__c> updateExternalIdOnRecordsUpdate(Map<Id, Technology_Partner_Usage__c> newTechPartnerUsageMap){
        system.debug('inside updateExternalIdOnRecords method');
        for(Technology_Partner_Usage__c tpu : newTechPartnerUsageMap.values()){
            system.debug('tpu   '+tpu);
            //if(tpu.External_Id__c==null || tpu.External_Id__c==''){               
                string externalid='';
                String delimiter = '-';             
                String input = tpu.Org_ID_Name__c;
                String cloudname='';
                String companyid='';
                system.debug('input ' +input);
                if(input!=null && input!=''){
                    cloudname= input.substringBefore(delimiter); 
                    companyid = input.substringAfter(delimiter);
                }
                system.debug('firstSplit ' +cloudname);
                system.debug('lastSplits ' +companyid);
                externalid=tpu.Customer_Account__c + '-' +tpu.Technology_Partner_Id__c  + '-' + companyid + '-' +  cloudname    + '-' +  tpu.Usage_Type__c + '-' + tpu.Segment__c;
                system.debug('externalid'+externalid);
                tpu.External_Id__c=externalid;
                tpu.Company_Id__c=companyid;
                tpu.Cloud_Name__c=cloudname;
            //}
        }
        return newTechPartnerUsageMap;
    }
    
}