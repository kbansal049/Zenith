public without sharing class NewSCIController {
    public String patchIdVal{ get; set; }
    public ApexPages.StandardSetController stdCntrlr {get; set;}
    public NewSCIController(ApexPages.StandardSetController controller) {
        stdCntrlr = controller;
        String currentRecordId  = String.valueof(ApexPages.CurrentPage().getparameters().get('id'));
        List<Account> accList = [select id ,Sales_Territory__c from Account where id =: currentRecordId and Sales_Territory__c!=null Limit 1];
        if(!accList.isEmpty())
            patchIdVal = accList[0].Sales_Territory__c;
    }
}