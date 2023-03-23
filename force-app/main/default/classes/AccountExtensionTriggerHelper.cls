/*
* @description       : 
* Modifications Log 
* Ver   Date         		Author        	Modification
* 1.0   NA   				NA    			Initial Version
* 2.0   08/06/2022			Mahesh T		CR#4705

*/
public class AccountExtensionTriggerHelper {
    
    public static void afterInsert(List<Account_Extension__c> newList){
        
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Service_Owner_Change_Trigger') && tsmap.get('Service_Owner_Change_Trigger') != null && tsmap.get('Service_Owner_Change_Trigger').Execute__c && !TriggerUtility.getAccountExtensionmethod()){
            ServiceOwnerChangeAtInsert(newList);
        }
        
    }
    
    public static void afterUpdate( Map<Id, Account_Extension__c> newMap, Map<Id,Account_Extension__c> oldmap){
        
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Service_Owner_Change_Trigger') && tsmap.get('Service_Owner_Change_Trigger') != null && tsmap.get('Service_Owner_Change_Trigger').Execute__c && (!TriggerUtility.getAccountExtensionmethod() || Test.isRunningTest())){
            serviceOwnerChangeAtUpdate(newMap,oldmap);   
        }
    }
    public static void serviceOwnerChangeAtUpdate(Map<Id, Account_Extension__c> newMap,Map<Id, Account_Extension__c> oldMap)
    {
        
        list<id> idList =new list<id>();
        list<id> deleteIdList =new list<id>();
        set<id> curntAcc = newMap.keySet();
        for(Account_Extension__c acc: newMap.values()){
            if( oldMap.get(acc.id).Service_Owner__c !=newMap.get(acc.id).Service_Owner__c){
                if(newMap.get(acc.id).Service_Owner__c !=null){
                    idList.add(acc.Service_Owner__c);
                }
                if(oldMap.get(acc.id).Service_Owner__c!=null) {
                    deleteIdList.add(oldMap.get(acc.id).Service_Owner__c);
                    idList.add(oldMap.get(acc.id).Service_Owner__c); 
                }
            }
        }
        changeServiceOwner(idList,deleteIdList,curntAcc);
        
    }
    public static void ServiceOwnerChangeAtInsert(List<Account_Extension__c> newList)
    {
        list<id> idList =new list<id>();
        list<id> deleteIdList =new list<id>();
        set<id> curntAcc = new set<id>();
        for(Account_Extension__c acc: newList){
            curntAcc.add(acc.id);          
            if(acc.Service_Owner__c !=null){
                idList.add(acc.Service_Owner__c); 
            }  
        }
        changeServiceOwner(idList,deleteIdList,curntAcc);
        
    }
    public static void changeServiceOwner(list<id> contactidList,list<id> deleteIdList,set<id> curntAcc)
    {
        
        list<id> alreadyInOther = new list<id>();
        if(deleteIdList.size()>0) {
            list<Account_Extension__c> otherActlist = [select Service_Owner__c from Account_Extension__c where Service_Owner__c in : deleteIdList and id not in :curntAcc];	
            for(Account_Extension__c act : otherActList){
                alreadyInOther.add(act.Service_Owner__c);
            }
        }
        list<contact> conList = [select id,Service_Owner__c  from contact where id in : contactidList];
        list<contact> conUpdateList = new list<contact>();
        for(contact cant : conList){
            boolean changes  = (deleteIdList.contains(cant.id) && !alreadyInOther.contains(cant.id));
            if(changes == cant.Service_Owner__c){
                cant.Service_Owner__c = !changes;
                conUpdateList.add(cant);
            }
            
        }
        //TriggerUtility.setAccountExtension();
        update conUpdateList;
    }
    //added by Anup : CR#1142 - Start
    public static void SendEmailtoCSM(Map<Id, Account_Extension__c> newMap,Map<Id, Account_Extension__c> oldMap) {
        List<Id> listOfUserId = new List<Id>();
        Map<Id, String> mapOfCsmAndManagerEmail = new Map<Id,String>();
        Map<Id, String> mapOfCsmAndEmail = new Map<Id,String>();
        Map<Id, String> mapOfUserAndName = new Map<Id,String>();
        List<id> listofAccId = new List<id>();
        Map<id, Account> mapOfAccrecords = new Map<id,Account>();
        for(Account_Extension__c acc : newMap.values()){
            if(acc.Account_Manager_tracker__c == False && acc.Account_Manager_tracker__c != oldMap.get(acc.id).Account_Manager_tracker__c){
                listofAccId.add(acc.Account__c);
            }
        }
        if(!listofAccId.isEmpty()){
            for(Account acct : [Select Id,OwnerId,CSM_Name_New__c from Account where ID in : listofAccId]){
                if(acct.CSM_Name_New__c !=null){
                    listOfUserId.add(acct.CSM_Name_New__c);
                    mapOfAccrecords.put(acct.id,acct);
                }          
            }
        }
        if(!listOfUserId.isEmpty()){
            for(User uId : [select id, Email,Manager.Email, Name from User where Id IN :listOfUserId]){
                if(uId.Manager.Email != null && uId.Manager.Email != ''){
                    mapOfCsmAndManagerEmail.put(uId.Id, uId.Manager.Email);
                }
                mapOfCsmAndEmail.put(uId.Id,uid.Email);
                mapOfUserAndName.put(uId.Id,uid.Name);
            }
        }
        // Step 0: Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mailLst = new List<Messaging.SingleEmailMessage>();
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
        // Get the Email Template  
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Account_Owner_Change_Notification_Template'];
        mail.setTemplateID(emailTemplate.Id); 
        for (Account account: mapOfAccrecords.values()) {
            if(account.CSM_Name_New__c !=null && !(mapOfUserAndName.get(account.CSM_Name_New__c).equals('TBH CSM')) && !(mapOfUserAndName.get(account.CSM_Name_New__c).equals('No CSM Coverage'))){
                mail.settargetObjectId([select id from Contact limit 1].Id);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setWhatId(account.Id);
                // Step 2: Set list of people who should get the email
                List<String> sendTo = new List<String>();
                if(mapOfCsmAndEmail.containsKey(account.CSM_Name_New__c)){
                    sendTo.add(mapOfCsmAndEmail.get(account.CSM_Name_New__c));
                }
                if(mapOfCsmAndManagerEmail.containsKey(account.CSM_Name_New__c)){
                    sendTo.add(mapOfCsmAndManagerEmail.get(account.CSM_Name_New__c));
                }
                system.debug('sendTo :'+sendTo);
                mail.setToAddresses(sendTo);
                // Step 3: Set who the email is sent from
                mail.setReplyTo('z-sales-ops@zscaler.com');
                mail.setSenderDisplayName('Sales Operations Team');
                mailLst.add(mail);
            }
            if(!mailLst.isEmpty()){
                Messaging.sendEmail(mailLst);    
            }
            TriggerUtility.AccountOwnerChangeAlertExecuted();
        }
        //added by Anup : CR#1142 - Start
    }
    
    //Added by Swathi: CR1410 Start
    public static void AccountFieldUpdate(Map<Id, Account_Extension__c> newMap,Map<Id, Account_Extension__c> oldMap)
    {
        List<id> listofAccId = new List<id>();
        Map<id, Account_Extension__c> mapOfAccrecords = new Map<id,Account_Extension__c>();
        for(Account_Extension__c acc: newMap.values()){
            if( (oldMap!=null && oldMap.get(acc.id).Account_Risk_Type__c !=newMap.get(acc.id).Account_Risk_Type__c) || (oldMap==null && acc.Account_Risk_Type__c !=null)){
                mapOfAccrecords.put(acc.Account__c,acc);
            }
        }
        List<Account> AccListToUpdate = new List<Account>();
        if(!mapOfAccrecords.isEmpty()){
            for(Account acct : [Select Id,Account_Risk_Type__c from Account where ID IN: mapOfAccrecords.keyset()]){
                if(acct.Account_Risk_Type__c != mapOfAccrecords.get(acct.id).Account_Risk_Type__c){
                    acct.Account_Risk_Type__c = mapOfAccrecords.get(acct.id).Account_Risk_Type__c;
                    AccListToUpdate.add(acct);
                }
            }
        }
        TriggerUtility.accToContactOwnerExecuted();
        TriggerUtility.UpdatingMarketsegmentforEMEAsettrue();
        TriggerUtility.accTerritoryPatchExecuted();
        TriggerUtility.accSalesTeamExecuted();
        TriggerUtility.realignPatch();
        TriggerUtility.CustomerSuccessUpdatemethodsettrue();
        TriggerUtility.prospectTypeUpdExecuted();
        TriggerUtility.UpdateAccountExtensionmethodsettrue();
        TriggerUtility.CreateAccExtensionExecuted();
        TriggerUtility.ScreenAccountsWithAmberRoadExecutedsettrue();
        TriggerUtility.captureCustomerNextStepsHistoryExecuted();
        TriggerUtility.updateSENameFromAccountExecuted();
        TriggerUtility.updateContractEndDateExecuted();
        TriggerUtility.AcctoActivityTerritoryExecuted();
        TriggerUtility.CustomerSuccessUpdatemethodsettrue();
        TriggerUtility.IsCSMmanagerEmailCodeexecutedsettrue();
        TriggerUtility.ProspectEntitlementExecuted();
        TriggerUtility.UpdateCSMAccountExtenssionMethodsettrue();
        TriggerUtility.UpdatingMarketsegmentforEMEAsettrue();
        TriggerUtility.CreateCustomerScoreCardExecuted();
        if(!AccListToUpdate.isEmpty()){
            Update AccListToUpdate;
        }
        TriggerUtility2.updateAccExtRelatedAccExecuted();
    }
    //Added by Swathi: CR1410 End
    
    //Added by Varun : CR# 1807: Start
    public static List<Account_Extension__c> updateAccountExtensionCheckBoxFromBatch(List<Account_Extension__c> lstAccntExtensionFromBatch){
        List<Account_Extension__c> lstAccntExtension= new List<Account_Extension__c> ();
        Map<Id, Account_Extension__c> accntExtensionMap = new Map<Id, Account_Extension__c>([Select id,Latest_ZIA_Contract_25_Attained__c,
                                                                                             Latest_ZPA_Contract_25_Attained__c,
                                                                                             Account__r.Avg_Estimated_Users_L31D_Vs_Purchase__c,
                                                                                             Account__r.ZPA_Enrolled_users_L31D_Vs_Purchase__c
                                                                                             from Account_Extension__c 
                                                                                             where Id in:lstAccntExtensionFromBatch ]);
        for(Account_Extension__c accExtension: lstAccntExtensionFromBatch){
            if(accntExtensionMap.get(accExtension.Id).Account__r.Avg_Estimated_Users_L31D_Vs_Purchase__c>25/*accExtension.Account__r.Avg_Estimated_Users_L31D_Vs_Purchase__c >25*/ ){
                accExtension.Latest_ZIA_Contract_25_Attained__c =true;
            }else{
                accExtension.Latest_ZIA_Contract_25_Attained__c =false; 
            }
            if(accntExtensionMap.get(accExtension.Id).Account__r.ZPA_Enrolled_users_L31D_Vs_Purchase__c >25 ){
                accExtension.Latest_ZPA_Contract_25_Attained__c =true;
            }else{
                accExtension.Latest_ZPA_Contract_25_Attained__c =false;
            }
        }
        return lstAccntExtensionFromBatch;
    }
    //Added by Varun : CR# 1807: Start
    
    // Added BY Mahesh T: CR#4705--Start
    public static void createAccountTeamMember(list<Account_Extension__c> accExtList, Map<Id, Account_Extension__c> oldAccExtMap){
        List<AccountTeamMember> result = new List<AccountTeamMember>();      
        List<AccountTeamMember> accTeamIds = new List<AccountTeamMember>();
        Set<Id> oldUserIds =new set<Id>();
        Set<Id> accIds =new set<Id>();
        set<string> accSet = new Set<String>{'Customer', 'Prospect','Ex-Customer'};
            
            for(Account_Extension__c accExtRecord : accExtList){
                if(accSet.contains(accExtRecord.Account_Type__c) && accExtRecord.Secondary_Account_Owner__c !=null &&   accExtRecord.Secondary_Account_Owner__c != oldAccExtMap.get(accExtRecord.Id).Secondary_Account_Owner__c && !accExtRecord.Federal_Account_Sync__c){
                    AccountTeamMember member  = new AccountTeamMember();
                    member.AccountId = accExtRecord.Account__c;
                    member.UserId = accExtRecord.Secondary_Account_Owner__c;
                    member.TeamMemberRole = 'Secondary Account Owner';
                    member.AccountAccessLevel = 'Edit';
                    member.OpportunityAccessLevel = 'Edit';
                    member.CaseAccessLevel = 'Edit';
                    member.ContactAccessLevel = 'Edit';
                    result.add(member);
                    
                }
                if(oldAccExtMap.get(accExtRecord.Id).Secondary_Account_Owner__c !=null && oldAccExtMap.get(accExtRecord.Id).Secondary_Account_Owner__c != accExtRecord.Secondary_Account_Owner__c){  
                    oldUserIds.add(oldAccExtMap.get(accExtRecord.Id).Secondary_Account_Owner__c);
                    accIds.add(accExtRecord.Account__c);  
                }      
            } 
        if(oldUserIds.size()>0){
        	accTeamIds = new Map<Id, AccountTeamMember>([SELECT Id FROM AccountTeamMember where UserId in :oldUserIds and AccountId in :accIds and TeamMemberRole = 'Secondary Account Owner']).values();   
        	//system.debug('accTeamIds'+accTeamIds);
        }
        if(result.size()>0){
            Database.SaveResult[] 	srList = Database.Insert(result,false);
        }
        if (accTeamIds.size()>0){
            Database.DeleteResult[] drList = Database.delete(accTeamIds, false);
        }
    } // CR#4705--End
}