/**
 *    Author			    Version 	Description
 *    Swathi Goudar         v1.0 		CR#4587 : Initial code
 */
public class UpdateZscalerRelatedobjectAccValue implements System.Queueable{
    private Set<Id> zscalerCloudIds;
    
    public UpdateZscalerRelatedobjectAccValue(Set<Id> zscalerCloudIds) {
        this.zscalerCloudIds = zscalerCloudIds;
    }
    public void execute(QueueableContext context) {
        System.debug('zscalerCloudIds' + zscalerCloudIds);
        Map<id,Zscaler_Cloud_ID__c> zscalerCloudmap= new Map<id,Zscaler_Cloud_ID__c>([SELECT id,Account__c FROM Zscaler_Cloud_ID__c where Id=:zscalerCloudIds]);
        List<Cloud_Usage__c> cloudUsageList = new List<Cloud_Usage__c>();
        List<ZDX_Cloud_Usage__c> ZDXCloudUsageList = new List<ZDX_Cloud_Usage__c>();
        List<Monthly_Policy_Configurations__c> MonthlyPolicyList = new List<Monthly_Policy_Configurations__c>();
        if(!zscalerCloudIds.isEmpty()){
            for(Cloud_Usage__c cloudrecord : [SELECT id,Account__c,Zscaler_Cloud_ID__c FROM Cloud_Usage__c where Zscaler_Cloud_ID__c IN :zscalerCloudmap.keySet()]){
                cloudrecord.Account__c = zscalerCloudmap.get(cloudrecord.Zscaler_Cloud_ID__c).Account__c;
                cloudUsageList.add(cloudrecord);
            }
            for(ZDX_Cloud_Usage__c ZDXcloudrecord : [SELECT id,Account__c,Zscaler_Cloud_ID__c FROM ZDX_Cloud_Usage__c where Zscaler_Cloud_ID__c  IN :zscalerCloudmap.keySet()]){
                ZDXcloudrecord.Account__c = zscalerCloudmap.get(ZDXcloudrecord.Zscaler_Cloud_ID__c).Account__c;
                ZDXCloudUsageList.add(ZDXcloudrecord);
            }
            for(Monthly_Policy_Configurations__c monthlyPolicyRecord : [SELECT id,Account__c,Zscaler_Cloud_ID__c FROM Monthly_Policy_Configurations__c where Zscaler_Cloud_ID__c  IN :zscalerCloudmap.keySet()]){
                monthlyPolicyRecord.Account__c = zscalerCloudmap.get(monthlyPolicyRecord.Zscaler_Cloud_ID__c).Account__c;
                MonthlyPolicyList.add(monthlyPolicyRecord);
            }
        }
        if(!cloudUsageList.isEmpty()){
            System.debug('cloudUsageList' + cloudUsageList);
            Database.SaveResult [] updateResult = Database.update(cloudUsageList, false);
            for (Database.SaveResult r : updateResult)
            {
                if (!r.isSuccess())
                {
                    for (Database.Error e : r.getErrors())
                    { 
                        System.debug('error message'+e.getMessage());
                        System.debug('error message'+e);
                    }
                }
            }
        }
        if(!ZDXCloudUsageList.isEmpty()){
            System.debug('ZDXCloudUsageList' + ZDXCloudUsageList);
            Database.SaveResult [] updateResult = Database.update(ZDXCloudUsageList, false);
            for (Database.SaveResult r : updateResult)
            {
                if (!r.isSuccess())
                {
                    for (Database.Error e : r.getErrors())
                    { 
                        System.debug('error message'+e.getMessage());
                        System.debug('error message'+e);
                    }
                }
            }
        }
        if(!MonthlyPolicyList.isEmpty()){
            System.debug('MonthlyPolicyList' + MonthlyPolicyList);
            Database.SaveResult [] updateResult = Database.update(MonthlyPolicyList, false);
            for (Database.SaveResult r : updateResult)
            {
                if (!r.isSuccess())
                {
                    for (Database.Error e : r.getErrors())
                    { 
                        System.debug('error message'+e.getMessage());
                        System.debug('error message'+e);
                    }
                }
            }
        }
    }
}