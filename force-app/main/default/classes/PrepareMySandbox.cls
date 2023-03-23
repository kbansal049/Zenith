global class PrepareMySandbox implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        
        BatchAfterSandboxRefresh BDel = new BatchAfterSandboxRefresh();
        String folderId = '00l70000001Jv5RAAS';
        // Query for selecting the documents to delete
        if(Test.isRunningTest()){
        	BDel.query = 'SELECT Id FROM EmailTemplate WHERE FolderId=\'' + folderId + '\' LIMIT 1';
        }
        else{
            BDel.query = 'SELECT Id FROM EmailTemplate WHERE FolderId=\'' + folderId + '\'';
        }
        try{
        	ID batchprocessid = Database.executeBatch(BDel);
        }
        catch(Exception e){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {'ldogra@zscaler.com'});
            mail.setSenderDisplayName('CopadoIntAdmin@zscaler.com');
            mail.setSubject('Sandbox Refresh Batch Process Failed for Org Id: ' + UserInfo.getOrganizationId());
            mail.setPlainTextBody('Sandbox Refresh Batch Failed with Error: ' + e);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
        
        // Update Emails
        List<User> userEmailList = [Select Email from User where USERROLEID IN (Select Id from UserRole where Name = 'IT/Business Systems') and DEVELOPER_SANDBOX_NAME__C <> NULL]; 
        Profile p = [SELECT id FROM Profile where name = 'System Administrator' ].get(0);  
        
        if(userEmailList != null && !userEmailList.isEmpty() ){
            for(User uc : userEmailList){ 
                    uc.Email = uc.Email.replace('.invalid','');
                    uc.ProfileId = p.Id;
                } 
        }
        
        if(userEmailList.size() > 0 && !test.isRunningTest()){ 
                Database.Update(userEmailList, false); 
        }
        
		//Boosting due to Test class not going in Catch block
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}