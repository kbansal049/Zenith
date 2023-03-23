public class MatchingDealRegAccountsControllerExt {
    public List<Account> matchingAccountList {get;set;}
    private Deal_Reg__c deal;
    public MatchingDealRegAccountsControllerExt(ApexPages.StandardController controller) {
        this.deal = (Deal_Reg__c)controller.getRecord();
        matchingAccountList = new list<Account>();
        this.deal = [Select Id,End_Customer_Domain__c from Deal_Reg__c where ID =: deal.Id];
        //Added for CR#3585
        String endCustomerDomain = '%'+deal.End_Customer_Domain__c +'%';
        if(deal.End_Customer_Domain__c  != '' && deal.End_Customer_Domain__c != null ){
            for(Account acc : [Select id, Name, type, NumberOfEmployees, Owner.Name, Domain__c, Additional_Organization_Domains__c, Sales_Territory__c,DS_Review_Status__c, BillingCountry from Account where 
                              (Domain__c =: deal.End_Customer_Domain__c or Additional_Organization_Domains__c like :endCustomerDomain) ])
                matchingAccountList.add(acc);        
        }
        
    }
}