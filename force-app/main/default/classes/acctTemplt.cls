public class acctTemplt
{
    public Id requestId {get;set;}
    public boolean commaValue {get;set;}
    
    public List<Contact> getContactList (){
        commaValue = false;
        List<Contact> contactList = new List<Contact> ();
        Security_Requests__c record  = [SELECT Id, Contact_Attendee_Role__c FROM Security_Requests__c WHERE Id = :requestId];
        if (String.isNotBlank(record.Contact_Attendee_Role__c)){
            contactList = (List<Contact>) JSON.deserialize( record.Contact_Attendee_Role__c, List<Contact>.class);
        }
        if(contactList.size()>1){
          commaValue = true;  
        }
        return contactList;
    }
    
    public String yearVal {
        get{
            return String.valueOf(date.today().year());
        } set;
    }
    
    public String baseUrl {
        set;
        get{
            return Url.getSalesforceBaseUrl().toExternalForm()+'/';
        }
    }
    
    
    public String lastComment {
        get {
            ProcessInstanceStep lastStep = getLastApprovalStep();
            return (( lastStep != null ) ? lastStep.comments : '');
        }
         set;
    }
    
    public String approverName {
        get {
            ProcessInstanceStep lastStep = getLastApprovalStep();
            return (( lastStep != null ) ? lastStep.Actor.Name : '');
        }
         set;
    }
    
    public List<Security_Requests__c> getCISORequest() {
        List<Security_Requests__c> oppty;
        oppty = [SELECT Id, Name,Opportunity__c,Opportunity__r.Name,Account_Name__r.Name,Account_Name__c,CISO_Name__r.Name, 
                 LastModifiedBy.Name,CISO_Request_Type__c,Topic_and_Proposed_Agenda__c, Contact_Attendee_Role__c,Owner.Username, Owner.Name 
                 FROM Security_Requests__c 
                 WHERE id =: requestId ];
        return oppty;
    }				
    
    public ProcessInstanceStep getLastApprovalStep() {
        List<ProcessInstanceStep> steps = new List<ProcessInstanceStep>([
            SELECT
            Comments, ActorId, Actor.Name , OriginalActorId
            FROM
            ProcessInstanceStep
            WHERE
            ProcessInstance.TargetObjectId = :requestId
            ORDER BY
            SystemModStamp DESC
        ]);
        return ( steps.size() > 0 ) ? steps[0] : null;
    }
}