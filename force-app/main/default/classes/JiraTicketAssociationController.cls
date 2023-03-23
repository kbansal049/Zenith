//CR# 1051
public class JiraTicketAssociationController {

    @testVisible
    public Id recordID {get; private set;} 
    @testVisible
    public String recordType {get; private set;} 
   
    public PageReference doRedirectToRecord(){
        System.debug('--doRedirectToRecord--called-- ');
        PageReference pageRef = null;
        System.debug('--recordID--'+recordID);
        if(recordID != null ){
            pageRef = new PageReference('/'+recordID);
            pageRef.setRedirect(true);
        }
        return pageRef;
    }
    
    public JiraTicketAssociationController(){
        try{
            recordID =  ApexPages.currentPage().getParameters().get('recordID');
            recordType =  ApexPages.currentPage().getParameters().get('recordType');
            
            if(/*recordID.getSobjectType() != Case.sObjectType &&*/ recordID.getSobjectType() != Opportunity.sObjectType){
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please provide valid ID for the Selection.'));
            }
            /*if(recordType != 'Bug' &&  recordType != 'Improvement'){
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please provide valid type for the Selection.'));
            }*/
            if(recordType != 'Improvement'){
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please provide valid type for the Selection.'));
            }
        }catch(Exception ex){
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Error :'+ex.getmessage()));
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public Static AssociatedJIRARequestWrapper getNonAssoicatedRecord(ID recordId, String recordType){
        
        System.debug('--getNonAssoicatedRecord--recordID--'+recordId);
        System.debug('--getNonAssoicatedRecord--recordType--'+recordType);
        
        AssociatedJIRARequestWrapper ajw = new AssociatedJIRARequestWrapper();
        try{
            /*if(recordId.getSobjectType() == Case.sObjectType){
                ajw.type= 'Case';
                ajw.typeApiName = 'Case';
                ajw.recordList =  getAssociatedRecordsForCase(recordId, recordType);
            }else 
			*/
			if(recordId.getSobjectType() == Opportunity.sObjectType){
                ajw.type= 'Opportunity';
                ajw.typeApiName = 'Opportunity';
                ajw.recordList =  getAssociatedRecordsForOpportunity(recordId,recordType);
            }else{
				ajw.isSuccess = false;
				ajw.errMsg = 'Not a valid record for association.';
			}
            ajw.isSuccess = true;
            ajw.errMsg = '';
        }catch(Exception ex){
            System.debug('--getNonAssoicatedRecord--Exception--'+ex.getMessage());
            System.debug('--getNonAssoicatedRecord--Exception--'+ex.getLineNumber());
            ajw.isSuccess = false;
            ajw.errMsg = ex.getMessage();
        }
        return ajw;
    }
    
    @auraEnabled
    public Static AssociateJIRARequestWrapperResult saveRecords(List<Account_JIRA_Integration__c> records, ID parentID,String parentType,String requestType){
        AssociateJIRARequestWrapperResult result = new AssociateJIRARequestWrapperResult();
        try{
            
            List<Account_JIRA_Integration__c> accJiraList = new List<Account_JIRA_Integration__c>();
            
            for(Account_JIRA_Integration__c aji : records){
                if(parentType == 'Opportunity'){
                    switch on  requestType{
                        when 'Improvement'{
                            aji.Improvement_Opportunity__c = parentID;
                        }
                        /*when 'Bug'{
                            //Account_JIRA_Integration__c cloneAJI = aji.clone(false, false, false, false);
                            aji.Bug_Opportunity__c = parentID;
                        }*/
                    }
                }
                /*else if(parentType == 'Case'){                    
                    switch on  requestType{
                        when 'Improvement'{
                            aji.Improvement_Case__c = parentID;
                        }
                        when 'Bug'{
                            aji.Bug_Case__c = parentID;
                        }
                    }
                }*/
            }
            
            //insert accJiraList;
            System.debug('---records---'+records);
            update records;
            result.isSuccess = true;
        }catch(Exception ex){
            System.debug('--getNonAssoicatedRecord--Exception--'+ex.getMessage());
            System.debug('--getNonAssoicatedRecord--Exception--'+ex.getLineNumber());
            result.isSuccess = false;
            result.errMsg = ex.getMessage();
        }
        return result;
    }
    
    

    /*
    @testVisible
    private Static List<Account_JIRA_Integration__c> getAssociatedRecordsForCase(Id caseID, String recordType){
        List<Account_JIRA_Integration__c> caseAssRecList = new List<Account_JIRA_Integration__c>();
        
        Id AccountID = [Select ID, AccountID from Case where id = :caseID].AccountID;
        switch on recordType{
            when 'Improvement'{
                caseAssRecList = [Select ID,Name,Account__c,Account__r.Name,Assignee__c,Improvement_Case__c,
                                  JIRA_Ticket__c,JIRA_Ticket_Number__c,Summary__c,
                                  Status__c,Ticket_Type__c from Account_JIRA_Integration__c 
                                  where Account__c = :AccountID and Ticket_Type__c = :recordType and Improvement_Case__c != :caseID
                                 ];
            }
            when 'Bug'{
                caseAssRecList = [Select ID,Name,Account__c,Account__r.Name,Assignee__c,Bug_Case__c,
                                  JIRA_Ticket__c,JIRA_Ticket_Number__c,Summary__c,
                                  Status__c,Ticket_Type__c from Account_JIRA_Integration__c 
                                  where Account__c = :AccountID and Ticket_Type__c = :recordType and Bug_Case__c != :caseID
                                 ];
            }
        }
        return caseAssRecList;
    }
    */
    
    @testVisible
    private Static List<Account_JIRA_Integration__c> getAssociatedRecordsForOpportunity(Id oppID, String recordType){
        List<Account_JIRA_Integration__c> oppAssRecList = new List<Account_JIRA_Integration__c>();
        
        Id AccountID = [Select ID, AccountID from Opportunity where id = :oppID].AccountID;
        
        switch on recordType{
            when 'Improvement'{
                oppAssRecList = [Select ID,Name,Account__c,Account__r.Name,Assignee__c,Improvement_Opportunity__c,Improvement_Opportunity__r.name,
                         JIRA_Ticket__c,JIRA_Ticket_Number__c,Summary__c,
                         Status__c,Ticket_Type__c from Account_JIRA_Integration__c 
                         where Account__c = :AccountID and Ticket_Type__c = :recordType and Improvement_Opportunity__c != :oppID
                        ];
            }
            /*when 'Bug'{
                oppAssRecList = [Select ID,Name,Account__c,Account__r.Name,Assignee__c,Bug_Opportunity__c,
                         JIRA_Ticket__c,JIRA_Ticket_Number__c,Summary__c,
                         Status__c,Ticket_Type__c from Account_JIRA_Integration__c 
                         where Account__c = :AccountID and Ticket_Type__c = :recordType and Bug_Opportunity__c != :oppID
                        ];
            }*/
        }
        return oppAssRecList;
    }


    public class AssociatedJIRARequestWrapper{
        @auraEnabled
        public List<Account_JIRA_Integration__c> recordList{get; set;}
        @auraEnabled
        public String type {get; set;}
        @auraEnabled
        public String typeApiName {get; set;}
        @auraEnabled
        public Boolean isSuccess {get; set;}
        @auraEnabled
        public String errMsg {get; set;}
    }
    
    
    public class AssociateJIRARequestWrapperResult{
        @auraEnabled
        public Boolean isSuccess {get; set;}
        @auraEnabled
        public String errMsg {get; set;}
    }
}