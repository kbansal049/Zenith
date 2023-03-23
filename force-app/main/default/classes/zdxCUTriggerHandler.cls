/**
 *  ZDX Cloud Usage TriggerHandler
 *    Author			    Version 	Description
 *    Bharath Regunathan    v1.0 		Initial Trigger handler
 *    Swathi Goudar         v2.0        CR#4587
 *    Swathi Goudar         v3.0        CR#4775: Afterupdate logic moved to UpdateZscalerCloudIDRecordsBatch
 */
public with sharing class zdxCUTriggerHandler {
    public static boolean skipTrigger = false;

    public void OnBeforeInsert(List<ZDX_Cloud_Usage__c> newzdxCUlst)
    { 
        Map<String,Zscaler_Cloud_ID__c> zscalerCloudIdvsAcc = new Map<String,Zscaler_Cloud_ID__c>();
        List<String> zscalerCloudIds = new List<String>();
        List<ZDX_Cloud_Usage__c> zsCloudUseId = new List<ZDX_Cloud_Usage__c>();
        for(ZDX_Cloud_Usage__c cloudUse:newzdxCUlst){
            if(/*String.isBlank(cloudUse.Account__c) &&*/ String.isNotBlank(cloudUse.cloud_id__c)){
                zscalerCloudIds.add(cloudUse.cloud_id__c);
                zsCloudUseId.add(cloudUse);
            }
        }
        if(!zscalerCloudIds.isEmpty()){
            zscalerCloudIdvsAcc = findLinkedAccount(zscalerCloudIds);
            System.debug('result++'+zscalerCloudIdvsAcc);
            // Modified by Swathi CR#4587 start
            for(ZDX_Cloud_Usage__c cloudUseUp:zsCloudUseId){
                if(zscalerCloudIdvsAcc.containskey((cloudUseUp.cloud_id__c).substring(0,1).toUpperCase()+ (cloudUseUp.cloud_id__c).substring(1).toLowerCase())){
                	cloudUseUp.Account__c = zscalerCloudIdvsAcc.get((cloudUseUp.cloud_id__c).substring(0,1).toUpperCase()+ (cloudUseUp.cloud_id__c).substring(1).toLowerCase()).Account__c;
                	cloudUseUp.Zscaler_Cloud_ID__c = zscalerCloudIdvsAcc.get((cloudUseUp.cloud_id__c).substring(0,1).toUpperCase()+ (cloudUseUp.cloud_id__c).substring(1).toLowerCase()).Id;
                	System.debug('finalrec++'+cloudUseUp);
                }
            }
            // Modified by Swathi CR#4587 End
        }
         
    }
    public void OnAfterInsert(List<ZDX_Cloud_Usage__c> newzdxCUlst)
    { 
        //Commenting to resolve CR#4775 issue - Logic moved to UpdateZscalerCloudIDRecordsBatch
        /*Map<Id,Id> zscalerCloudIdvsZDXId = new Map<Id,Id>();
        List<Zscaler_Cloud_ID__c> zscalerCloudIds = new List<Zscaler_Cloud_ID__c>();

        for(ZDX_Cloud_Usage__c cloudUse:newzdxCUlst){
            if(String.isNotBlank(cloudUse.Zscaler_Cloud_ID__c)){
                zscalerCloudIdvsZDXId.put(cloudUse.Zscaler_Cloud_ID__c, cloudUse.Id);
            }
        }
        if(!(zscalerCloudIdvsZDXId.keySet()).isEmpty()){
            for(Id zsc:zscalerCloudIdvsZDXId.keySet()){
                Zscaler_Cloud_ID__c zscid = new Zscaler_Cloud_ID__c();
                zscid.id = zsc;
                zscid.Latest_ZDX_Cloud_Usage__c = zscalerCloudIdvsZDXId.get(zsc);
                zscalerCloudIds.add(zscid);
            }
        }
        if(!zscalerCloudIds.isEmpty()){
            TriggerUtility2.UpdateZscalerCloudIdTriggerExecuted();
            UPDATE zscalerCloudIds;
            TriggerUtility2.UpdateZscalerCloudIdTriggerReset();
        }*/
    }
    public void OnBeforeUpdate(Map<Id,ZDX_Cloud_Usage__c> oldzdxCUMap,Map<Id,ZDX_Cloud_Usage__c> newzdxCUMap)
    { 

    }
    public void OnAfterUpdate(Map<Id,ZDX_Cloud_Usage__c> oldzdxCUMap,Map<Id,ZDX_Cloud_Usage__c> newzdxCUMap)
    { 

    }
    public void onBeforeDelete(Map<Id,ZDX_Cloud_Usage__c> oldzdxCUMap)
    {
        
    }
    
    public void onAfterDelete(Map<Id,ZDX_Cloud_Usage__c> oldzdxCUMap)
    {
        
    }
    
    public void onAfterUndelete(Map<Id,ZDX_Cloud_Usage__c> newzdxCUMap)
    {
        
    }
    public Map<String,Zscaler_Cloud_ID__c> findLinkedAccount(List<String> zscalerCloudIds){
        Map<String,Zscaler_Cloud_ID__c> zscalerCloudIdvsAccount = new Map<String,Zscaler_Cloud_ID__c>();
        if(!zscalerCloudIds.isEmpty()){
        // Modified by Swathi CR#4587 start
        //List<Zscaler_Cloud_ID__c> zscalerCloudIdlst = new List<Zscaler_Cloud_ID__c> ([SELECT id,Account__c,Name FROM Zscaler_Cloud_ID__c where Name IN :zscalerCloudIds]);
            for(Zscaler_Cloud_ID__c zscid:[SELECT id,Account__c,Name FROM Zscaler_Cloud_ID__c where Name LIKE:zscalerCloudIds]){
                zscalerCloudIdvsAccount.put((zscid.Name).substring(0,1).toUpperCase()+ (zscid.Name).substring(1).toLowerCase(), zscid);
            }
        // Modified by Swathi CR#4587 end
        }
        return zscalerCloudIdvsAccount;
    }
    
}