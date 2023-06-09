global class OpportunitywithoutchurnRecBatch implements Database.Batchable<sObject>,  Database.Stateful {
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('OpportunitywithoutchurnRecBatch');
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callStart();
     
        Set<String> stageSet = new Set<String>();
        stageSet.add(label.Stage_7_Closed_Lost );
        //stageSet.add('12 - Closed With No Decision');  //Commented as 11 - Closed Lost and 12 - Closed With No Decision has same replaceable value.
        String SubStageClosedWithNoDes = Label.SubStage_Closed_With_No_Decision;
        List<string> SubStageList = new List<String>();
        SubStageList.Add(Label.SubStage_Closed_With_No_Decision);
        SubStageList.Add(Label.SubStage_Closed_Lost);
        Set<Id> ownerIdSet = new Set<Id>();
        
        List<Opportunity> oppList = new List<Opportunity>();
        if(test.isRunningTest()){
            oppList =  [Select Id, OwnerId from 
                                     Opportunity
                                     limit 1];
        }else{
           oppList =  [Select Id, OwnerId from  Opportunity
                                     Where ID NOT IN (SELECT Opportunity__c FROM Churn__c)
                                     AND StageName NOT IN: stageSet
                                     AND CloseDate = THIS_FISCAL_QUARTER];
        }
        for(Opportunity oppRec : oppList){
            ownerIdSet.add(oppRec.OwnerId);
        }  
        String query = 'SELECT Id, Name, Manager.Email, Email FROM User Where Id IN: ownerIdSet';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, list<User> userScope){
        this.zscalerBatchFrameWorkObj.callExecute(userScope[0]?.Id, userScope.size());
        
        if(!userScope.isEmpty()){
            Set<String> stageSet = new Set<String>();
            stageSet.add(label.Stage_7_Closed_Lost );/*'11 - Closed Lost'*/
            
            MAP<ID,User> userMAP = new MAP<ID, User>(userScope);
            List<Opportunity> opportunitylist = retriveOppList(stageSet, userMAP.keySet());
            
            List<String> UserIds = new List<String>();
            List<String> UserIdEmail = new List<String>();
            if(!opportunitylist.isempty() && opportunityList.size()>0){
                for(Opportunity opp : opportunityList){
                    UserIdEmail.add(opp.owner.Id);
                }
            }
            
            string htmlBody ='';
            if(!userScope.isEmpty()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> userEmails = new List<String>();
                if(userScope[0].Email != null){
                    userEmails.add(userScope[0].Email);
                }
                if(userScope[0].Manager.Email != null){
                    userEmails.add(userScope[0].Manager.Email);
                }
                //userEmails.add('usateesh@cloudely.com');
                if(!userEmails.isEmpty()){
                    mail.toAddresses = userEmails;
                }
                mail.setTreatTargetObjectAsRecipient(false); 
                mail.setSubject('Opportunity with out Churn');  
                htmlBody ='Hi '+ userScope[0].Name + ',<br/><br/>' + 'Below is the list of opportunities where the Loss/Churn Form is not yet submitted.';
                htmlBody += '<br/><br/><table border="1" style="border-collapse: collapse"><tr><th>Name</th><th>Stage Name</th><th>RecordType</th></tr>';
                for(Opportunity  opp : opportunitylist ){
                    htmlBody += '<tr><td>';
                    if(opp.Name != null && opp.Name !=''){ 
                        htmlBody += '<a href="' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/'+opp.id + '">' + opp.Name + '</a>' + '</td><td>';
                    }
                    else{   
                        htmlBody +=''+'</td><td>';
                    }
                    if(opp.StageName  != null && opp.StageName != ''){
                        htmlBody += opp.StageName+ '</td><td>';
                    }
                    else{
                        htmlBody +=''+'</td><td>'; 
                    }
                    if(opp.RecordType.name  != null && opp.RecordType.name != ''){
                        htmlBody += opp.RecordType.name+ '</td>';
                    }
                    else{
                        htmlBody +=''+'</td>'; 
                    }
                    htmlBody += '</tr>';                
                } 
                htmlBody += '</table><br/>'; 
                htmlBody += 'Please update the records.';
                mail.setHTMLBody(htmlBody);
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                }
            }
        }
    }
    
    private List<Opportunity> retriveOppList(Set<String> stageSet, Set<Id> ownerIdset){
        List<Opportunity> opportunitylist = new List<Opportunity>();
        if(!Test.isRunningTest()){
            opportunitylist  = [SELECT Id, Name,Owner.Id,Owner.Manager.Email,RecordType.Name,StageName FROM Opportunity 
                                WHERE OwnerId in :ownerIdset AND ID NOT IN (SELECT Opportunity__c FROM Churn__c) 
                                AND StageName NOT IN: stageSet  AND CloseDate = THIS_FISCAL_QUARTER];
        }else{
            opportunitylist  = [SELECT Id, Name,Owner.Id,Owner.Manager.Email,RecordType.Name,StageName FROM Opportunity LIMIT 1];
        }
        return opportunitylist;
    }
    
    global void finish(Database.BatchableContext bc){
        this.zscalerBatchFrameWorkObj.callFinish(bc); 
    } 
}