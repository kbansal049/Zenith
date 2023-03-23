public class emailToSECompController {
    
    public Id caseIdRec {get;set;}
    public Id caseId {get;set;}
    public String caseLink {get;set;}
    public String optyLink {get;set;}
     public String PRGLink {get;set;}
    
    public Case cs{get;set;}
    
    
    public Case getCaserecord() {
        System.debug('caseId '+caseId);
         Case cs ;
        if( caseIdRec !=null){
            cs =[select id,Provisioning_Group__c,Provisioning_Group__r.Start_Date__c,Provisioning_Group__r.name ,Provisioning_Group__r.End_Date__c, Provisioning_Group__r.Opportunity__c, Provisioning_Group__r.Opportunity__r.SE_Name__r.Name
                  ,Provisioning_Group__r.SE__c, Provisioning_Group__r.Account__r.Name from Case where id=:caseIdRec limit 1]; //   5008J000001GRvi  SE_Name__c
        caseLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+cs.id;
        
        optyLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+cs.Provisioning_Group__r.Opportunity__c;
            PRGLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+cs.Provisioning_Group__c;
        //wrapper wrp = new wrapper(cs,optyLink,caseLink);
        
        }
         
        return  cs;
        
        
    }
    /*   
public class wrapper{
public case cs;
public string optyLink;
public string caseLink;
public wrapper(case cs,string optyLink, string caseLink){
this.cs = cs;
this.optyLink= optyLink;
this.caseLink = caseLink;

}

}
*/      
    
    
    
}