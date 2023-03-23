//Test Class: CommissionExceptiontriggerhandlerTest
public class GetCommssionExceptionDetails{
    
    //Inputs
    public String ebId {get; set;}
    public String typeofTemplate {get; set;}
    public String recipientName {get; set;}
    public String approverName {get; set;}
    public Boolean nextApprover {get; set;}
    public String nextApproverName {get; set;}
    public String comments {get; set;}
    
    public Commission_Exception__c commissionException;
    
    public String yearVal { get{ return String.valueOf(date.today().year()); } set; }
    public string url{ get{ return System.Url.getSalesforceBaseURL().toExternalForm(); } set; }
        
    public Commission_Exception__c GetcommissionException(){
        if(ebId != null){
            Commission_Exception__c commissionExceptionRecord = [SELECT Id, LastModifiedBy.Name, Name, Account__c, Account__r.Name, Account_Name__c, Commission_Amount__c, 
                                                                 Justification__c, Opportunity__c, Opportunity__r.Name, Request_Status__c, Owner.Name, Sub_Status__c, 
                                                                 Approved_With_Reservation__c 
                                                                 FROM Commission_Exception__c WHERE Id = :ebId];
            return getLastestComment(commissionExceptionRecord); 
        }
        return null;
    }
    
    public Commission_Exception__c getLastestComment(Commission_Exception__c commissionExceptionRecord){

        if(commissionExceptionRecord != null){
            
            Id recordID = commissionExceptionRecord.Id;
        	
            //Get Approval History Records Steps with latest comments            
            List<ProcessInstance> newInstanceList = [SELECT CompletedDate, CreatedById, CreatedDate,Id,IsDeleted,LastActorId,
                                                     LastModifiedById,LastModifiedDate,ProcessDefinitionId,Status,SubmittedById,
                                                     SystemModstamp,TargetObjectId, (SELECT ID, StepStatus,Comments,ActorId,Actor.Name,
                                                                                     CreatedById,OriginalActorId,
                                                                                     ProcessInstanceId,CreatedDate FROM Steps ORDER BY CreatedDate DESC) 
                                                     FROM ProcessInstance
                                                     WHERE TargetObjectId = :recordID ORDER BY CreatedDate DESC];
            if(!newInstanceList.isEmpty()){                                
                this.approverName = newInstanceList[0].Steps[0].Actor.Name;
                this.comments = newInstanceList[0].Steps[0].Comments;
                
                //Get Next Approval Step details
                Map<Id,ProcessInstanceWorkitem> PIWorkitems = new Map<Id,ProcessInstanceWorkitem>();
                for(ProcessInstanceWorkitem workitem : [SELECT ActorId, Actor.Name,CreatedById,ProcessInstance.TargetObjectId,CreatedDate,Id,
                                                        OriginalActorId,ProcessInstanceId,SystemModstamp
                                                        FROM ProcessInstanceWorkitem 
                                                        WHERE ProcessInstance.TargetObjectId = :recordID ORDER BY CreatedDate DESC]){
                    PIWorkitems.put(workitem.ProcessInstance.TargetObjectId, workitem);
                }
                
                this.nextApprover = PIWorkitems.get(recordID) == null? False : True;
                this.nextApproverName = PIWorkitems.get(recordID)?.Actor.Name;
                
                //Check if comments contains any reservaton keyword 
                List<String> reservationKeywordList = System.Label.With_Reservation_Key_Words.split(',');
                if(this.comments != null && String.isNotBlank(this.comments)){
                    for(String keyword : reservationKeywordList){
                        if(this.comments?.containsIgnoreCase(keyword.trim())){
                            commissionExceptionRecord.Approved_With_Reservation__c = true;
                            commissionExceptionRecord.Sub_Status__c = 'With Reservation';
                            break;
                        } else {
                            commissionExceptionRecord.Sub_Status__c = null;
                        } 
                    }
                } else { commissionExceptionRecord.Sub_Status__c = null; }                  
            }
        }        
        return commissionExceptionRecord;
    }    
}