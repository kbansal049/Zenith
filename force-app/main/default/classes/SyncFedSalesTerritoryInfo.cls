@RestResource(urlMapping='/SyncFedSalesTerritoryInfo/*')
global class SyncFedSalesTerritoryInfo{
    
    global static Boolean avoidtriggers = false;
    
    @HttpPost
    global static String doPost(Map<String, Account> fedAccounts, Map<String, Opportunity> fedOpportunities, List<AccountTeamMember> fedTeams, List<OpportunityTeamMember> listOtm, List<AccountTeamMember> listDelAccTeamFromFed, List<OpportunityTeamMember> listDelOppTeamFromFed){
        //skip triggers
        TriggerUtility.accTerritoryPatchExecuted();
        TriggerUtility.accSalesTeamExecuted();
        avoidtriggers = true;       
        System.debug('fedAccounts->' + fedAccounts);
        System.debug('fedOpportunities->' + fedOpportunities);   
        System.debug('fedTeams->' + fedTeams);
        System.debug('listOtm->' + listOtm);       
        System.debug('listDelAccTeamFromFed->' + listDelAccTeamFromFed);
        System.debug('listDelOppTeamFromFed->' + listDelOppTeamFromFed);
        
        // This block will delete AccountTeamMember to sync the AccountTeamMember which were changed in Fed
        List<String> teamdelerrorlst = new List<String>();
        List<String> teamdelsuccesslst = new List<String>(); 
        /// Updated to exclude all comm team roles account team members deletion what are not coming from Fed //

        List<String> teamRoleOnlyInComm = new List<String>();
            teamRoleOnlyInComm.add('Out of Territory');
            teamRoleOnlyInComm.add('Out of Territory SE');
            teamRoleOnlyInComm.add('Opportunity Split');
            teamRoleOnlyInComm.add('GAM');
            teamRoleOnlyInComm.add('Overlay Team Member');
            teamRoleOnlyInComm.add('District Manager');
            teamRoleOnlyInComm.add('Vacation Coverage');  
            teamRoleOnlyInComm.add('Overlay Edgewise');       
            teamRoleOnlyInComm.add('Global Account Manager - AMS');      
            teamRoleOnlyInComm.add('Global Account Manager - EMEA');    
            teamRoleOnlyInComm.add('Global Account Manager - APJ');  
            teamRoleOnlyInComm.add('Regional Alliance Manager 5'); 
            teamRoleOnlyInComm.add('ZPA Manager');  
            teamRoleOnlyInComm.add('ZPA SE');   
            teamRoleOnlyInComm.add('Sales Manager'); 
            teamRoleOnlyInComm.add('Solution Architect');  
            teamRoleOnlyInComm.add('Executive Sponsor'); 
          /// Updated to exclude all comm team roles account team members deletion what are not coming from Fed //

        try{
            System.debug('listDelAccTeamFromFed.size()'+ listDelAccTeamFromFed.size());
            List<Id> listDelAcc = new  List<Id>();         
            if (!listDelAccTeamFromFed.isEmpty() && listDelAccTeamFromFed.size()>0 ){         
                System.debug('listDelAccTeamFromFed->' + listDelAccTeamFromFed);
                for (AccountTeamMember acc : listDelAccTeamFromFed){
                    listDelAcc.add(acc.AccountId);
                }
            }
            

            


                
                
                
                
                
                
                
               
                
                
                
                
                
            
            


            
         //   List<AccountTeamMember> listDelAccTeam = [SELECT id, accountId, teamMemberRole  FROM AccountTeamMember WHERE accountId in :listDelAcc AND  teamMemberRole not in ('Out of Territory',   'Out of Territory SE')];           
            List<AccountTeamMember> listDelAccTeam = [SELECT id, accountId, teamMemberRole  FROM AccountTeamMember WHERE accountId in :listDelAcc AND  teamMemberRole not in :teamRoleOnlyInComm ];           

            if (listDelAccTeam!=null){
                Database.DeleteResult[] acctSRList = database.delete(listDelAccTeam,false);              
                for (Database.DeleteResult accountSaveResult : acctSRList){
                    if (accountSaveResult.isSuccess()){
                        // Operation was successful, so get the ID of the record that was processed
                        teamdelsuccesslst.add(accountSaveResult.getId());
                    }                   
                    else{
                        for(Database.Error err : accountSaveResult.getErrors()){
                            String s = '';
                            if(acctSRList.indexOf(accountSaveResult) != -1 && !listDelAccTeam.isEmpty() && listDelAccTeam.size() > acctSRList.indexOf(accountSaveResult) && listDelAccTeam[acctSRList.indexOf(accountSaveResult)] != null){                              
                                s = listDelAccTeam[acctSRList.indexOf(accountSaveResult)].Id;
                            }
                            teamdelerrorlst.add(s + ' - ' + err.getMessage());
                        }
                    }                  
                }
            }                                             
        }catch(Exception e){          
            System.debug('in catch listDelAccTeamFromFed:='+ e.getMessage()+ e.getStackTraceString());
        }
        System.debug('teamdelsuccesslst->' + teamdelsuccesslst);
        System.debug('teamdelerrorlst->' + teamdelerrorlst);
        
        // This block will delete OpportunityTeamMember to sync the OpportunityTeamMember which were changed in Fed
        List<String> oTeamerrorlst = new List<String>();
        List<String> oTeamsuccesslst = new List<String>();      
        try{
            List<Id> listDelOpp = new  List<Id>();                   
            if (!listDelOppTeamFromFed.isEmpty() && listDelOppTeamFromFed.size()>0 ){         
                System.debug('listDelOppTeamFromFed->' + listDelOppTeamFromFed);
                for (OpportunityTeamMember opp : listDelOppTeamFromFed){
                    listDelOpp.add(opp.OpportunityId);
                }
            }
         //   List<OpportunityTeamMember> listDelOppTeam = [SELECT id, OpportunityId, teamMemberRole   FROM OpportunityTeamMember WHERE OpportunityId in :listDelOpp AND  teamMemberRole not in ('Out of Territory' , 'Out of Territory SE' , 'Opportunity Split')];           
              List<OpportunityTeamMember> listDelOppTeam = [SELECT id, OpportunityId, teamMemberRole   FROM OpportunityTeamMember WHERE OpportunityId in :listDelOpp AND  teamMemberRole not in :teamRoleOnlyInComm ];           

            
            System.debug('listDelOppTeam->' + listDelOppTeam);        
            if (listDelOppTeam!=null){
                Database.DeleteResult[] acctSRList = database.delete(listDelOppTeam,false);               
                for (Database.DeleteResult accountSaveResult : acctSRList){
                    if (accountSaveResult.isSuccess()){
                        // Operation was successful, so get the ID of the record that was processed
                        oTeamsuccesslst.add(accountSaveResult.getId());
                    }                   
                    else {
                        for(Database.Error err : accountSaveResult.getErrors()){
                            String s = '';
                            if(acctSRList.indexOf(accountSaveResult) != -1 && !listDelOppTeam.isEmpty() && listDelOppTeam.size() > acctSRList.indexOf(accountSaveResult) && listDelOppTeam[acctSRList.indexOf(accountSaveResult)] != null){
                                s = listDelOppTeam[acctSRList.indexOf(accountSaveResult)].Id;
                            }
                            oTeamerrorlst.add(s + ' - ' + err.getMessage());
                        }
                    }                    
                }
            }                      
        }catch(Exception e){            
            System.debug('in catch listDelOppTeamFromFed:='+ e.getMessage()+ e.getStackTraceString());
        }
        System.debug('oTeamsuccesslst->' + oTeamsuccesslst);
        System.debug('oTeamerrorlst->' + oTeamerrorlst); 
        
        //This block create lists to store DML success/failures
        //update accounts with patch/territory data
        List<String> accerrorlst = new List<String>();
        List<String> accsuccesslst = new List<String>();
        List<Account> listfedAccounts = new List<Account>();
        try{            
            if (fedAccounts!=null){
                listfedAccounts =fedAccounts.values(); 
                Database.SaveResult[] acctSRList = database.update(listfedAccounts,false);               
                for (Database.SaveResult accountSaveResult : acctSRList) {
                    if (accountSaveResult.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        accsuccesslst.add(accountSaveResult.getId());
                    }                    
                    else {
                        for(Database.Error err : accountSaveResult.getErrors()){
                            String s = '';
                            if(acctSRList.indexOf(accountSaveResult) != -1 && !listfedAccounts.isEmpty() && listfedAccounts.size() > acctSRList.indexOf(accountSaveResult) && listfedAccounts[acctSRList.indexOf(accountSaveResult)] != null){
                                s = listfedAccounts[acctSRList.indexOf(accountSaveResult)].Id;
                            }
                            accerrorlst.add(s + ' - ' + err.getMessage());
                        }
                    }                    
                }
            }
            System.debug('accsuccesslst->' + accsuccesslst);
            System.debug('accerrorlst->' + accerrorlst);            
        }
        catch(Exception e){
            System.debug('in catch fedAccounts:='+ e.getMessage()+ e.getStackTraceString());
        }       
        
        //This block will update Opportunities with patch/territory data
        List<String> opperrorlst = new List<String>();
        List<String> oppsuccesslst = new List<String>();   
        List<Opportunity> listfedOpportunities = new List<Opportunity>();   
        try{            
            if (fedOpportunities!=null){
                listfedOpportunities = fedOpportunities.values();
                Database.SaveResult[] oppSRList = database.update(listfedOpportunities,false);
                for (Database.SaveResult oppSaveResult : oppSRList) {
                    if (oppSaveResult.isSuccess()){
                        // Operation was successful, so get the ID of the record that was processed
                        oppsuccesslst.add(oppSaveResult.getId());
                    }
                    else {
                        for(Database.Error err : oppSaveResult.getErrors()){
                            String s = '';
                            if(oppSRList.indexOf(oppSaveResult) != -1 && !listfedOpportunities.isEmpty() && listfedOpportunities.size() > oppSRList.indexOf(oppSaveResult) && listfedOpportunities[oppSRList.indexOf(oppSaveResult)] != null){
                                s = listfedOpportunities[oppSRList.indexOf(oppSaveResult)].Id;
                            }
                            opperrorlst.add(s + ' - ' + err.getMessage());
                        }
                    }                    
                }
            }                  
        }catch(Exception e){
            System.debug('in catch fedOpportunities:='+ e.getMessage()+ e.getStackTraceString());
        }        
        System.debug('oppsuccesslst->' + oppsuccesslst);
        System.debug('opperrorlst->' + opperrorlst);  
        
        // This block will upsert  accountsTeamMembers with patch/territory data      
        List<String> teamerrorlst = new List<String>();
        List<String> teamsuccesslst = new List<String>();      
        try{           
            Database.UpsertResult[] acctSRList = database.upsert(fedTeams, false);            
            for (Database.UpsertResult accountSaveResult : acctSRList){
                if (accountSaveResult.isSuccess()){
                    // Operation was successful, so get the ID of the record that was processed
                    teamsuccesslst.add(accountSaveResult.getId());
                }
                else {
                    for(Database.Error err : accountSaveResult.getErrors()){
                        String s = '';
                        if(acctSRList.indexOf(accountSaveResult) != -1 && !fedTeams.isEmpty() && fedTeams.size() > acctSRList.indexOf(accountSaveResult) && fedTeams[acctSRList.indexOf(accountSaveResult)] != null){
                            s = fedTeams[acctSRList.indexOf(accountSaveResult)].Id;
                        }
                        teamerrorlst.add(s + ' - ' + err.getMessage());
                    }
                }               
            }                       
        }catch(Exception e){
            System.debug('in catch fedTeams:='+ e.getMessage()+ e.getStackTraceString());
        }
        System.debug('teamsuccesslst->' + teamsuccesslst);
        System.debug('teamerrorlst->' + teamerrorlst);
        
        //This block update OpportunityTeamMember with patch/territory data      
        List<String> fedOTeamserrorlst = new List<String>();
        List<String> fedOTeamssuccesslst = new List<String>();        
        try{  
            Database.UpsertResult[]  acctSRList= database.upsert(listOtm,false);          
            for (Database.UpsertResult accountSaveResult : acctSRList){
                if (accountSaveResult.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    fedOTeamssuccesslst.add(accountSaveResult.getId());
                }                          
                else {
                    for(Database.Error err : accountSaveResult.getErrors()){
                        String s = '';
                        if(acctSRList.indexOf(accountSaveResult) != -1 && !listOtm.isEmpty() && listOtm.size() > acctSRList.indexOf(accountSaveResult) && listOtm[acctSRList.indexOf(accountSaveResult)] != null){
                            s = listOtm[acctSRList.indexOf(accountSaveResult)].Id;
                        }
                        fedOTeamserrorlst.add(s + ' - ' + err.getMessage());
                    }
                }               
            }                     
        }catch(Exception e){
            System.debug('in catch listOtm:='+ e.getMessage()+ e.getStackTraceString());
        }
        System.debug('fedOTeamssuccesslst->' + fedOTeamssuccesslst);
        System.debug('fedOTeamserrorlst->' + fedOTeamserrorlst);
        
        // When no unexpected exception thrown then return Pass. If null is passed check debug at Fed side that data did not even pushed from there or at comm some unexpected exception thrown 
        // make sure when search for  'catch' in debug logs to verify that all data dml opearation was successful and errorlst is null as well
        return  'Pass';       
    }  
}