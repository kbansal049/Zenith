public class EgressLocationPageController {
    //Apex properties or variables
    
    Map<String,string> urlparams;
    public String oppId{get; set;}
    public String accId{get; set;}
    public String recordTypeName{get; set;}
    public String optyURL{get;set;}
    public Egress_Location__c egressLocObj { get; set; }
    
    //constructor to get the Case record
    public EgressLocationPageController(ApexPages.StandardController controller) {
        egressLocObj =  (Egress_Location__c) controller.getRecord();
        String temp='';
        System.debug('The Egress_Location__c record: ' + egressLocObj);
        if(string.valueOf(egressLocObj)!=null && string.valueOf(egressLocObj).split('=')[1]!=null){
            temp = string.valueOf(egressLocObj).split('=')[1];
            oppId = temp.substring(0,temp.length()-1);
        }
        
        system.debug('oppId'+oppId);
        system.debug('accId'+accId);
        String tempURL = String.valueOf(URL.getSalesforceBaseUrl()); 
        system.debug('tempURL'+tempURL);
        optyURL=tempURL.split('=')[1].substring(0,tempURL.split('=')[1].length()-1)+'/'+oppId;
        system.debug('optyURL'+optyURL);
    }
    
    //Method that can is called from the Visual Force page action attribute
    /*public PageReference createNewEgressLocation() {
        System.debug('Egress_Location__c Owner: ' );
        System.debug('Egress_Location__c Id: ' + egressLocObj);
        //build your code logic here
        PageReference pageRef = new PageReference('/'+oppId);
        pageRef.setRedirect(true);
        return pageRef; //Returns to the case page
    }*/
    
   @AuraEnabled
    public static Account getAccount(String optyId){
        System.debug('optyId==>'+optyId);
        String accId=[select id,AccountId from Opportunity where id =:optyId].AccountId;
        Account accObj = [select id from Account where id=:accId];
        return accObj;
    }
}