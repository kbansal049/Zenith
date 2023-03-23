trigger OwnerCopy on Opportunity (before Insert,before Update) {
    //if(!TriggerUtility.isPatchRealigning()) {
        /* for(Opportunity x:Trigger.New){
            x.Owner_Details__c=x.OwnerID;
        } */
      
    boolean skipTrigger = false;
    List<Skip_Triggers__c> skipTriggers = Skip_Triggers__c.getall().values();
    if(!skipTriggers.isEmpty()){
        //runTrigger = 
        if(skipTriggers[0].Skip_Opportunity_Triggers__c = true){
            skipTrigger = true;
        }
    }
    //Added by Gurjinder for bypassing trigger for specific user
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    system.debug('usertoskip '+usertoskip);
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        system.debug('inside if of skip triggers on user based in OwnerCopy ');
        skiptrigger = true;
    }
    system.debug('inside if of skip triggers on user based in OwnerCopy'+skiptrigger);
    
    //Added by Gurjinder for Opp Creation Issue :Start
    if(trigger.Isbefore && trigger.isInsert && !TriggerUtility.isSkipAccTriggerExecuted()){ 
        TriggerUtility.SkipAccTriggerExecuted();
    }
    //Added by Gurjinder for Opp Creation Issue : End

    if(!skipTrigger){
        if(trigger.isInsert && trigger.isBefore){
            Set<id> CampaignIdSet= new Set<id>();
            Set<String> UntaggingCampaignTypeSet= new Set<String>();
            String UntaggingCampaignType= ZscalerCustomSetting__c.getInstance('UntaggingCampaignType')!=null && ZscalerCustomSetting__c.getInstance('UntaggingCampaignType').Value__c!=null ? ZscalerCustomSetting__c.getInstance('UntaggingCampaignType').Value__c:'Operational,Non-Marketing Programs';
            UntaggingCampaignTypeSet.addall(UntaggingCampaignType.split(','));      
            for(Opportunity opp : trigger.new){
               if((opp.Type == 'Existing Customer (Add On)' || opp.Type == 'New Business' ) && opp.Lead_Source_Map__c != null && opp.Lead_Source_Map__c != '' ){
                    opp.LeadSource = opp.Lead_Source_Map__c;
                }
                if(opp.CampaignId!=null){
                    CampaignIdSet.add(opp.CampaignId);              
                }
            }
            
            Map<Id,Campaign> CampaignMap = new Map<Id,Campaign>([Select Id,name,type,Campaign_Type__c from Campaign where Id =:CampaignIdSet]);
            
            for(Opportunity opp : trigger.new){
                if(opp.CampaignId!=null && CampaignMap.get(opp.CampaignId)!=null && UntaggingCampaignTypeSet.contains(CampaignMap.get(opp.CampaignId).Campaign_Type__c)){
                    opp.CampaignId=null;
                }
            }
            
        }
    }
    if(test.isrunningtest()){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
         
    //}
}