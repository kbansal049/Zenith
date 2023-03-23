/*
 * Modified Opportunity query as part of CR# 3381
 * Commenting Deal_Reg_Teaming_Tech_Partner__c as part of IBA-7556
 */
public class OpportunityLinkControllerExt {
    public string oppId {get; set;}
    public string oppName {get; set;} 
    public Deal_Reg__c dealReg = new Deal_Reg__c();
    public OpportunityLinkControllerExt(ApexPages.StandardController controller) {
        this.dealReg = (Deal_Reg__c)controller.getRecord();
        this.oppId = '';
        this.oppName = '';
        list<Opportunity> oppList = new list<Opportunity>();
        oppList  = [Select Id, Name from Opportunity where (Deal_Reg__c =: dealReg.Id or Deal_Reg_Teaming_Reseller__c = :dealReg.Id /*or Deal_Reg_Teaming_Tech_Partner__c = :dealReg.Id*/) AND Sub_Stage__c != :System.label.SubStage_Closed_Delete_Duplicate limit 1];
        if(!oppList.isEmpty()){
            oppId = oppList[0].Id;
            oppName = oppList[0].Name;
        }
        
    }
    
    
}