public class ZscalerCloudIdHelper {
    //Added by Ayush Kangar as Part of CR# 3284 - Start
    public static void beforeInsert(List<Zscaler_Cloud_ID__c> ZscalerCloudIdList){
        Map<Id,String> mapAccIdAccType = new Map<Id,String>();
        Set<Id> accList = new Set<Id>();
        for(Zscaler_Cloud_ID__c Zcloud : ZscalerCloudIdList){
            accList.add(Zcloud.Account__c);
        } 
        for(Account acc : [Select id,Type from Account where id in: accList]){
            mapAccIdAccType.put(acc.id,acc.Type);
        }
        List <ZscalerCloudIdProgOrgChecbox__c> customSettingList = ZscalerCloudIdProgOrgChecbox__c.getall().values();
        for(Zscaler_Cloud_ID__c Zcloud : ZscalerCloudIdList){
            if( mapAccIdAccType.containskey(Zcloud.Account__c) && mapAccIdAccType.get(Zcloud.Account__c) =='Customer' ){
                // ZscalerCloudIdProgOrgChecbox__c is the custom setting, it contains 'dev', 'beta','test'
                // To add more values that need to be considered while checking production org checkbox, we can add those values to ZscalerCloudIdProgOrgChecbox__c custom setting
                boolean flag= false;
                for(ZscalerCloudIdProgOrgChecbox__c custom: customSettingList){
                    flag = Zcloud.Name.toLowercase().Contains(custom.Name.toLowercase());
                    if(flag){
                        break;
                    }
                }
                Zcloud.Production_Org__c = Zcloud.Cloud_Type__c == 'ZIA' && !flag;
            }
        }
    }
    //Added by Ayush Kangar as Part of CR# 3284 - End
    //Added by Swathi as part of CR#4587 Start
    public static void AfterUpdate(map<id, Zscaler_Cloud_ID__c> newMap, map<id, Zscaler_Cloud_ID__c> OldMap){
        if(!newMap.isEmpty() && !system.isFuture() && !system.isBatch() && !system.isQueueable() /*&& !test.isRunningTest()*/){
            Set<Id> zscalerCloudIds = new Set<Id>();
            for(Zscaler_Cloud_ID__c zsCloudId : newMap.values()){
                if(zsCloudId.Account__c != oldMap.get(zsCloudId.Id).Account__c){
                    zscalerCloudIds.add(zsCloudId.Id);
                }
            }
            if(!zscalerCloudIds.isEmpty()){
                System.enqueuejob(new UpdateZscalerRelatedobjectAccValue(zscalerCloudIds));
            }
        }
    }
    //Added by Swathi as part of CR#4587 End
}