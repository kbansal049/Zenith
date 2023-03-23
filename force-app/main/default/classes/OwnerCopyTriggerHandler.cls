/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* OwnerCopyTriggerHandler
* @description    Merged code from OwnerCopy trigger.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Mahesh T.
* @modifiedBy     Mahesh T.
* @maintainedBy   Mahesh T.
* @version        1.0
* @created        2021-09-13
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class OwnerCopyTriggerHandler {
    
    private static OwnerCopyTriggerHandler instance;
    public static OwnerCopyTriggerHandler getInstance() {
        if (instance == NULL) {
            instance = new OwnerCopyTriggerHandler();
        }
        
        return instance;
    }
        
    private List<Opportunity> newOppList;
    public void setNewOppList(List<Opportunity> newOppList) {
        this.newOppList = newOppList;
    }
    
    public void beforeInsert(){
        Set<id> CampaignIdSet= new Set<id>();
        Set<String> UntaggingCampaignTypeSet= new Set<String>();
        String UntaggingCampaignType = ZscalerCustomSetting__c.getInstance('UntaggingCampaignType') != null && ZscalerCustomSetting__c.getInstance('UntaggingCampaignType').Value__c!=null ? ZscalerCustomSetting__c.getInstance('UntaggingCampaignType').Value__c:'Operational,Non-Marketing Programs';
        UntaggingCampaignTypeSet.addall(UntaggingCampaignType.split(','));      
        for(Opportunity opp : newOppList){
            if((opp.Type == 'Existing Customer (Add On)' || opp.Type == 'New Business' ) && opp.Lead_Source_Map__c != null && opp.Lead_Source_Map__c != '' ){
                opp.LeadSource = opp.Lead_Source_Map__c;
            }
            if(opp.CampaignId != null){
                CampaignIdSet.add(opp.CampaignId);              
            }
        }
        
        Map<Id, Campaign> CampaignMap = new Map<Id,Campaign>([Select Id,name,type,Campaign_Type__c from Campaign where Id =:CampaignIdSet]);
        
        for(Opportunity opp : newOppList){
            if(opp.CampaignId != null && CampaignMap.get(opp.CampaignId) != null && UntaggingCampaignTypeSet.contains(CampaignMap.get(opp.CampaignId).Campaign_Type__c)){
                opp.CampaignId = null;
            }
        }
        
    }
    
}