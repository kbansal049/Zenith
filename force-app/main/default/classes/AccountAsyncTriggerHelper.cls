/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* AccountAsyncTriggerHelper
* @description    This is the Account Trigger helper class called asynchronously from AccountAsyncTriggerHandler.
*					All the methods needs to be called asynchronously from the Account Trigger
* 					should be called from here.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2021-11-09
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            Nagesh M
* 2022-02-21      CR# 3469. This CR requires creating Survey Records when Accounts become Customer
* 2022-03-30      CR# 4285
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class AccountAsyncTriggerHelper {
    
    private static AccountAsyncTriggerHelper instance;
    
    public static AccountAsyncTriggerHelper getInstance() {
        if (instance == NULL) {
            instance = new AccountAsyncTriggerHelper();
        }
        return instance;
    }	
    
    private List<AccountChangeEvent> newAccountList;    
    public void setNewAccountList(List<AccountChangeEvent> newAccountList) {
        this.newAccountList = newAccountList;
    }
    
    private Map<Id, Account> newAccountMap;
    private void setNewAccountMap(Map<Id, Account> newAccountMap) {
        this.newAccountMap = newAccountMap;    
    }
    
    private void retrieveAccounts(List<String> accountIdList) {
        
        Map<Id, Account> newAccountMap = new Map<Id, Account> (
            [
                SELECT
                Id,
                Is_Federal_Account_Sync__c,
                TriggerPatchAssignment__c,
                Patch_Assignment_Failed__c,
                Name,
                BillingCountry,
                BillingState,
                BillingPostalCode,
                Domain__c,
                Industry,
                Market_Segment__c,
                Type,
                Federal_Account_Sync_Text__c,
                CSM_NAMEOverlay__c,
                TAM_s__c,
                CSM_Name2_Formula__c,
                OwnerId,
                Patch__c,
                Area__c,
                Region__c,
                Active_1_Year_Log_Retention__c
                FROM
                Account
                WHERE 
                Id IN :accountIdList
            ]
        );
        setNewAccountMap(newAccountMap);
    }
    
    
    public void process() {
        
        List<String> accountIdList = new List<String>();
        List<Id> accNeedsPatchAssign = new List<Id>();
        List<Account> accountForChangeRelatedContactsOwnerList = new List<Account>();
        List<Account> accountUpdateContactsPatchList = new List<Account>();
        List<Account> accountListToUpdate = new List<Account>();
        
        for (AccountChangeEvent accChangeEvt : newAccountList) {        
            EventBus.ChangeEventHeader header = accChangeEvt.ChangeEventHeader;
            accountIdList.addAll(header.getRecordIds());//for batch size more than 1
        }
        
        System.debug('AccountAsyncTriggerHelper.process() accountIdList : ' + accountIdList);
        
        retrieveAccounts(accountIdList);
        
        for (AccountChangeEvent accChangeEvt : newAccountList) {
            
            EventBus.ChangeEventHeader header = accChangeEvt.ChangeEventHeader;
            System.debug('Received change event for ' +
                         header.entityName +
                         ' for the ' + header.changeType + 
                         ' operation. - ' + header);
            
            List<String> updatedFieldList = new List<String>();
            if (header.changetype == 'UPDATE') {
                for(String recordId : header.getRecordIds()){//process each record in a bulk operation, batch size more than 1
                    
                    updatedFieldList = header.changedFields;                
                    Id accountId = recordId;
                    
                    for(String fieldStr : updatedFieldList){
                        System.debug('AccountAsyncTriggerHelper.process() updatedFieldList fieldStr : ' + fieldStr);
                    }
                    if ( !newAccountMap.get(accountId).Is_Federal_Account_Sync__c ) {
                        
                        //Patch Assignment Moved to platform Event
                        /*
Boolean isAccountInPatchEngine = !PatchRuleEngineStarter.isInPipeline(accountId);                        
if(isAccountInPatchEngine){
//To accomodate below logic 
//PatchDataModel.MatchTarget target = new PatchDataModel.MatchTarget(acc);
//PatchDataModel.MatchTarget oldTarget = new PatchDataModel.MatchTarget(oldAccount);
//if(acc.TriggerPatchAssignment__c || !target.isSameTarget(oldTarget))
//Below checks are performed, fields are fetched from a custom setting PatchFieldMapping__c, 
//reference class PatchRuleHelper.getConfig
if (updatedFieldList.contains('TriggerPatchAssignment__c') && //To avoid Infinite loop
newAccountMap.get(accountId).TriggerPatchAssignment__c)
{
accNeedsPatchAssign.add(accountId);
}else if(!updatedFieldList.contains('TriggerPatchAssignment__c') && //To avoid Infinite loop
(updatedFieldList.contains('Name') || 
updatedFieldList.contains('BillingAddress.Country') ||
updatedFieldList.contains('BillingAddress.State') ||
updatedFieldList.contains('BillingAddress.PostalCode') ||
updatedFieldList.contains('Domain__c') ||
updatedFieldList.contains('Industry') ||
updatedFieldList.contains('Market_Segment__c') ||
updatedFieldList.contains('Type') ||
updatedFieldList.contains('Federal_Account_Sync_Text__c') ||
updatedFieldList.contains('CSM_NAMEOverlay__c') ||
updatedFieldList.contains('TAM_s__c') ||
updatedFieldList.contains('CSM_Name2_Formula__c') ))
{
accNeedsPatchAssign.add(accountId);

}
}
}*/
                        //System.debug('AccountAsyncTriggerHelper.process() accNeedsPatchAssign : ' + accNeedsPatchAssign);
                        
                        
                        //If Patch Reallign Fails - Retry, this process occurs only once 
                        //It will not go into loop because when Retry fails 
                        //Patch_Assignment_Failed__c value will be TRUE, 
                        //so updatedFieldList will not contain this field, as there was no change in fields's value
                        if(updatedFieldList.contains('Patch_Assignment_Failed__c') &&
                           newAccountMap.get(accountId).Patch_Assignment_Failed__c )
                        {
                            accNeedsPatchAssign.add(accountId);
                        }
                        
                        if(updatedFieldList.contains('OwnerId')){
                            accountForChangeRelatedContactsOwnerList.add(newAccountMap.get(accountId));
                        }
                        
                        if(updatedFieldList.contains('Patch__c')){
                            accountUpdateContactsPatchList.add(newAccountMap.get(accountId));
                            updateCTO_CISO(newAccountMap);  						// Added by Ayush Kangar as part of CR# 4023 
                        }    
                        // Added by Ayush Kangar as part of CR# 3284 - Start
                        
                        // CR# 4805 START 
                        if(updatedFieldList.contains('Type')){

                            accountListToUpdate.add(newAccountMap.get(accountId));
                            // Commented below line to avoid updating the other accounts where Account Type is already Customer
                            //updateProductionOrgCheckboxOnZscalerCloudId(newAccountMap.values());
                        }    
                        // CR# 4805 END
                        
                        // Added by Ayush Kangar as part of CR# 3284 - End
                        // Added by Swathi: CR# 4285 Start
                        /*if(updatedFieldList.contains('Active_1_Year_Log_Retention__c')){
                            updateCloudOpsNotifyCheckboxOnZscalerCloudId(newAccountMap.values());
                        }*/
                        // Added by Swathi: CR# 4285 End
                    }
                }
                
                Boolean isPatchRealignRunning = TriggerUtility.isPatchRealigning();
                
                if(!isPatchRealignRunning) {
                    //Skip these methods when patch is realigned -- Don't change anything here
                    //Need to run when patch is realigned
                    //Below two method calls are from After Update of AccountTriggerHandler
                    //AccountTriggerHelper.changeRelatedContactsOwner(accountForChangeRelatedContactsOwnerList);  
                    changeRelatedContactsOwner(accountForChangeRelatedContactsOwnerList);
                    //AccountSalesTerritoryAndContactPatch.updateContactsPatch(accountUpdateContactsPatchList);
                    updateContactsPatch(accountUpdateContactsPatchList);
                }
                
            } else if (header.changetype == 'CREATE') {
                
                //Patch Assignment Moved to platform Event
                /*
for(String recordId : header.getRecordIds()){//process each record in a bulk operation, batch size more than 1              
Id accountId = recordId;
accNeedsPatchAssign.add(accountId);                    
}
System.debug('AccountAsyncTriggerHelper.process() accNeedsPatchAssign : ' + accNeedsPatchAssign);
*/
            }
        }

        // CR# 4805 START
        if (!accountListToUpdate.isEmpty()) {
            updateProductionOrgCheckboxOnZscalerCloudId(accountListToUpdate);
        }
        // CR# 4805 END
        
        if(!accNeedsPatchAssign.isEmpty()){
            /*
TriggerUtility.SkipAccTriggerExecuted();
PatchRuleEngineStarter starter = new PatchRuleEngineStarter(accNeedsPatchAssign);
starter.start();
*/
        }
    }
    
    private void changeRelatedContactsOwner(list<Account> accountNewList){
        
        list < Contact > contactUpdateList = new list < Contact > ();
        map < Id, Id > accIdOwnerIdMap = new map < Id, Id > ();
        set < Id > activeUserIdSet = new set < Id > ();
        for (Account acc: accountNewList) {            
            accIdOwnerIdMap.put(acc.id, acc.OwnerId);           
        }
        
        if (!accIdOwnerIdMap.values().isEmpty()) {
            
            for (User usr: [select id from user where isActive =: true and ID IN: accIdOwnerIdMap.values()]) {
                activeUserIdSet.add(usr.Id);
            }
            
            for (Contact con: [Select Id, OwnerId, AccountId from Contact WHERE AccountId IN: accIdOwnerIdMap.keyset()]) {
                if (con.OwnerId != accIdOwnerIdMap.get(con.AccountId) && activeUserIdSet.contains(accIdOwnerIdMap.get(con.AccountId)))
                    contactUpdateList.add(new Contact(Id = con.Id, ownerId = accIdOwnerIdMap.get(con.AccountId)));
            }
            
            if (!contactUpdateList.isEmpty())
                Database.update(contactUpdateList, false);
        }
        TriggerUtility.accToContactOwnerExecuted();
        
    }
    
    private void updateContactsPatch(list<Account> newAccList){
        list<Contact> contactUpdateList = new list<Contact>();
        Map<Id, Id> accIdPatchIdMap = new Map<Id, Id>();
        set<id> accIdSet = new set<id>();
        
        try{
            for(Account acc : newAccList){                
                if(acc.Patch__c != null)
                    accIdPatchIdMap.put(acc.Id, acc.Patch__c);
            }
            
            if(!accIdPatchIdMap.isEmpty()){
                for(Contact con : [select Id, AccountId, Patch__c from Contact where AccountId IN: accIdPatchIdMap.keySet()]){
                    if(accIdPatchIdMap.containsKey(con.AccountId)){
                        con.Patch__c = accIdPatchIdMap.get(con.AccountId);
                    }else{
                        con.Patch__c = null;
                        con.Account_Manager__c = null;
                        con.Channel_Manager__c = null;
                        con.Customer_Advocate__c = null;
                        con.Sales_Engineer__c = null;
                        con.Lead_Development__c = null;
                        con.ZPA_Manager__c = null;
                        con.ZPA_SE__c = null;
                        con.ZPA_Manager_Email__c = null;
                        con.ZPA_SE_Email__c = null;
                    }
                    contactUpdateList.add(con);
                }
            }
            if(!contactUpdateList.isEmpty())
                database.update(contactUpdateList, false);
            
        }catch (exception e){}
    }
    
    // Added by Ayush Kangar as part of CR# 4023 - Start
    private void updateCTO_CISO(map < Id, Account > accountNewMap) {
        List <Account_Extension__c> listToUpdate= new List<Account_Extension__c>();
        Map<String,Id> areaCisoMap = new Map<String,Id>();
        Map<String,Id> regionCtoMap = new Map<String,Id>();
        for(CTO_CISO_Transformation_Team_Member__c teamMember : [select type__c,Area__c,Region__c,Linked_CTO_Team_Member__c,Linked_CISO_Team_Member__c  from CTO_CISO_Transformation_Team_Member__c]){
            if(teamMember.type__c == 'Field CTO'){
                regionCtoMap.put(teamMember.Region__c,teamMember.Linked_CTO_Team_Member__c);
            }
            if(teamMember.type__c == 'Field CISO'){
                areaCisoMap.put(teamMember.Area__c,teamMember.Linked_CISO_Team_Member__c);
            }
        }
        for(Account_Extension__c accntExtension : [Select id,Account__r.Area__c, Account__r.Region__c,Account__c,Field_CTO__c,Field_CISO__c from Account_Extension__c where Account__c in:accountNewMap.keySet()]){
            if(regionCtoMap.containskey(accntExtension.Account__r.Area__c)){
                accntExtension.Field_CTO__c = regionCtoMap.get(accntExtension.Account__r.Area__c);
            }else{
                accntExtension.Field_CTO__c = null;
            }
            if(areaCisoMap.containskey(accntExtension.Account__r.Region__c)){
                accntExtension.Field_CISO__c = areaCisoMap.get(accntExtension.Account__r.Region__c);
            }else{
                accntExtension.Field_CISO__c = null;
            }
            listToUpdate.add(accntExtension);
        }
        if(!listToUpdate.isEmpty()){
            update listToUpdate;
        }      
    }
    // Added by Ayush Kangar as part of CR# 4023 - End
    
    // Added by Ayush Kangar as part of CR# 3284 - Start
    @TestVisible
    private static void updateProductionOrgCheckboxOnZscalerCloudId(List <Account> newAccountList) {
        List<Id> customerAccountList = new List<Id>();
        List<Zscaler_Cloud_ID__c> listToUpdate = new List<Zscaler_Cloud_ID__c>();
        Map<Id,Zscaler_Cloud_ID__c> zCloudIdMap = new  Map<Id,Zscaler_Cloud_ID__c>(); 
        for(Account acc : newAccountList){
            if( acc.Type == 'Customer'){
                customerAccountList.add(acc.Id);
            }
        }
        /* Commenting as part of CR# 4840
        // CR#3469. Invoke the Create Survey method to new Survery records for every Contact Record
        if(!customerAccountList.isEmpty())
            createSurveys(customerAccountList); 
		*/

        List <ZscalerCloudIdProgOrgChecbox__c> customSettingList = ZscalerCloudIdProgOrgChecbox__c.getall().values();
        for (Zscaler_Cloud_ID__c Zcloud: [select id,Cloud_Type__c,Production_Org__c,Name,Account__c from Zscaler_Cloud_ID__c where Account__c in :customerAccountList and Cloud_Type__c = 'ZIA']) {
            // ZscalerCloudIdProgOrgChecbox__c is the custom setting, it contains 'dev', 'beta','test'
            // To add more values that need to be considered while checking production org checkbox, we can add those values to ZscalerCloudIdProgOrgChecbox__c custom setting
            boolean flag= false;
            for(ZscalerCloudIdProgOrgChecbox__c custom: customSettingList){
                flag = Zcloud.Name.toLowercase().Contains(custom.Name.toLowercase());
                if(flag){
                    break;
                }
            }
            Zcloud.Production_Org__c = Zcloud.Cloud_Type__c == 'ZIA' && !flag;
            listToUpdate.add(Zcloud);
        }  
        if(!listToUpdate.isEmpty()){
            update listToUpdate;
        }
    }
    // Added by Ayush Kangar as part of CR# 3284 - End
    
    /* Commenting as part of CR# 4840
    // CR# 3469. The below method creates Survey Records for new Customer Accounts.(Or Type is changed to Customers)
    public static void createSurveys(List<Id> customerAccIdsList){
        
        Id csmRecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('Customer_Success').getRecordTypeId();
        List<Survey__c> lSurveys = new List<Survey__c>();
        List<Contact> lContacts = [Select Id, Email, AccountId From Contact Where AccountId in:customerAccIdsList And Email!=null];

        List<String> domainsToExclude = CaseTriggerUtility.fetchDomainsToExclude();
       

        for(Contact con: lContacts){


            Survey__c survey = new Survey__c(Account__c = con.AccountId,
                                             Contact__c=con.Id,
                                             RecordTypeId=csmRecordTypeId
                                            ); 
            if(CaseTriggerUtility.checkEmailDomainsExclude(con.Email, domainsToExclude)){
                survey.Contact_Email_Includes_Public_Domain__c = true;
                survey.Survey_Status__c='Survey not Sent due to Public Domain';
            }                                
            lSurveys.add(survey);  
        }
        try {
            insert lSurveys;
        } catch (Exception e){

            Zscaler_Error_Logs__c errorLog  = new Zscaler_Error_Logs__c(
                                                                        Class_Name__c = 'AccountAsyncTriggerHelper',
                                                                        Exception_info__c = e.getMessage(),
                                                                        Method_Name__c = 'createSurveys',
                                                                        Multiple_records_info__c = JSON.serialize(lContacts),
                                                                        Operation__c = 'Creates Surveys for New Customers'
                                                                       );
            insert errorLog;
        }
        
   
    }
    */
    
    // Added by Swathi: CR# 4285 Start
    /*private static void updateCloudOpsNotifyCheckboxOnZscalerCloudId(List <Account> newAccountList) {
        List<Id> AccountIdList = new List<Id>();
        List<Zscaler_Cloud_ID__c> listToUpdate = new List<Zscaler_Cloud_ID__c>();
        Map<Id,Zscaler_Cloud_ID__c> zCloudIdMap = new  Map<Id,Zscaler_Cloud_ID__c>(); 
        for(Account acc : newAccountList){
            if( acc.Active_1_Year_Log_Retention__c > 0){
                AccountIdList.add(acc.Id);
                System.debug('AccountList ' + AccountIdList);
            }
        }
        for (Zscaler_Cloud_ID__c Zcloud: [select id,Cloud_Opp_Email_Notification__c from Zscaler_Cloud_ID__c where Account__c in :AccountIdList and RecordType.Name = 'ZIA Cloud ID' 
                                          and Cloud_Opp_Email_Notification__c!='Yes' and Account__r.Name != '41 CorpZU Test Account_changed' and (Not Name Like 'zscalerbeta.net%')]) {
            Zcloud.Cloud_Opp_Email_Notification__c = 'No';
            System.debug('Zcloud ' + Zcloud);
            listToUpdate.add(Zcloud);
        }  
        if(!listToUpdate.isEmpty()){
            update listToUpdate;
        }
     }*/
    // Added by Swathi: CR# 4285 End
}