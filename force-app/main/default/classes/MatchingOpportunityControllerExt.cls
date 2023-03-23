public class MatchingOpportunityControllerExt{
    private ApexPages.StandardController controller {get; set;}
    private Deal_Reg__c deal;
    public List<opportunity> matchingOpportunityList {get;set;}
    public MatchingOpportunityControllerExt(ApexPages.StandardController controller){
        //initialize the stanrdard controller
        this.controller = controller;
        this.deal = (Deal_Reg__c)controller.getRecord();
        matchingOpportunityList = new list<Opportunity>();
        this.deal = [Select Id,End_Customer_Domain__c from Deal_Reg__c where ID =: deal.Id];
        //Added for CR#3585
        String endCustomerDomain = '%'+deal.End_Customer_Domain__c +'%';
        if(deal.End_Customer_Domain__c  != '' && deal.End_Customer_Domain__c != null ){
            for(Opportunity opp : [Select Id, Name, AccountId, Account.Name, Amount, StageName,CloseDate,(Select id, AccountTo.Name from OpportunityPartnersFrom where IsPrimary =: true limit 1)
                                   from opportunity  Where 
                                   (Account.Domain__c =: deal.End_Customer_Domain__c 
                                    or Account.Additional_Organization_Domains__c like :endCustomerDomain) 
                                   and StageName not in (:Label.Stage_6_Closed_Won,:label.Stage_7_Closed_Lost)  Order BY StageName]){
                matchingOpportunityList.add(opp);
            }
        }
    }
}