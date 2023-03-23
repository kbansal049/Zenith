public class NSSCloudCompController {
    
     public Id prgIdRec {get;set;}
    public Id prgID {get;set;}
    public String PRGLink {get;set;}
 
    
    
    public Provisioning_Group__c getPRGrecord() {
        System.debug('prgID '+prgID);
         Provisioning_Group__c prg ;
        if( prgIdRec !=null){
            prg =[select id,Name,
                 
                 RecordType.DeveloperName,
                 RecordType.Name,Proxy_Cloud__c,
                 
                 Product_Line__c,Preferred_Cloud__c,
                 Organization_Domain__c,Provisioning_Process__c,
                 Additional_Organization_domains__c,
                 Start_Date__c,
                 End_Date__c,
                 Send_Initial_Login_Credentials_To__c,
                 Status__c,Approval_Status__c,
                 PG_Request_Type__c,ZSCM_End_Date__c,
                 
                 //Cloud Details
                 Zscaler_Cloud_ID__c,
                 Zscaler_Cloud_ID__r.Name,
                 
                 //Associated Cloud Details
                 Associated_ZIA_Zscaler_Cloud__c,
                 Associated_ZIA_Zscaler_Cloud__r.Name,
                 
                 ZPA_Preferred_Cloud__c,
                 
                 //Opportunity
                 opportunity__c,
                 opportunity__r.Name,
                 opportunity__r.Type,opportunity__r.Id,
                 
                 //Customer
                 Account__r.name,Account__r.Parent.name,Account__r.Operational_HQ__c,Account__r.Region_New__c,
                 Account__r.BillingCountry,Account__r.ZIA_Customer_Id__c,Account__r.ZPA_Customer_ID__c,Account__r.Area__c ,
                 Account__r.Type,Account__r.No_of_Employees_Users__c,Account__r.Industry,Account__r.Geo__c,Account__r.FP_A_Parent_industry__c,
                 Account__r.Sales_Territory__r.Provisioning_Geographical_Region__c,
                 Account__r.Sales_Territory__r.Provisioning_Region__c,Account__r.District__c,
                 
                 CreatedDate,LastModifiedDate,Owner.Name,Owner.email,Owner.Username
                 
                 from Provisioning_Group__c 
         where id =: prgIdRec]; //   5008J000001GRvi  
        PRGLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+prg.id;
        
        //wrapper wrp = new wrapper(cs,optyLink,caseLink);
        
        }
         
        return  prg;
        
        
    }
   

}