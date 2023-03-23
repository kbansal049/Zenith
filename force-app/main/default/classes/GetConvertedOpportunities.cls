// Commenting Deal_Reg_Teaming_Tech_Partner__c as part of IBA-7556
public class GetConvertedOpportunities {
    public Id dealRegId {get; set;}
    public Opportunity opp {
        get{
            System.debug('dealRegId '+dealRegId);
            if(dealRegId != null){
                List<Opportunity> oppList = [Select Id, Name from Opportunity where (Deal_Reg__c = :dealRegId or Deal_Reg_Teaming_Reseller__c = :dealRegId /*or Deal_Reg_Teaming_Tech_Partner__c = :dealRegId*/) AND Sub_Stage__c != :System.label.SubStage_Closed_Delete_Duplicate limit 1];
                if(oppList != null && oppList.size()>0){
                    opp = oppList[0];
                }else{
                    opp = new Opportunity();
                }
            }
            return opp;
        } set;
    }
    public Deal_Reg__c DR {
        get{
            System.debug('dealRegId '+dealRegId);
            if(dealRegId != null){
                List<Deal_Reg__c> drList = [SELECT id, Name, Partner_Account__r.Name, Channel_Manager__r.Name,
                                            Channel_Manager__r.Email, Technology_Alliance_Manager__r.Email,
                                            Technology_Alliance_Manager__r.Name, Partner_Company_Name__c, 
                                            Distributor__r.Name, Account_Manager__r.Name, Account__r.Name,Deal_Reg_Type__c from Deal_Reg__c WHERE id = :dealRegId LIMIT 1];
                if(drList != null && drList.size()>0){
                    DR = drList[0];
                }else{
                    DR = new Deal_Reg__c();
                }
            }
            return DR;
        } set;
    }
}