/**
 * @description       : This class contains helper methods contact trigger
 * 1.0            Satishakumar Awati   14th Dec 2022   Move Contact Trigger to New Trigger Framework
**/
public class ContactTriggerHelper{

    public static final Set<String> CONTACT_LEAD_STATUS_SET = new Set<String>{
        'Pending Marketing Qualification',
        'Recycled to Marketing',
        'Disqualified'
    };

    // IBA-5318 START
    public static final String BUDGET_AUTHORITY_STRING = 'BudgetAuthority';
    public static final String SERVICE_OWNER_STRING = 'ServiceOwner';
    // IBA-5318 END

    public static boolean skipTrigger = false;
    public static void changeContactOwnership(List<Contact> newContactList, Map<Id, Contact> oldContactMap){
        set<Id> accIdSet = new set<Id>();
        map<Id, Id> accIdOwnerIdMap = new map<id,id>();
        for(Contact con : newContactList){
            if(con.AccountId != null){
                Contact oldContact = oldContactMap != null ? oldContactMap.get(con.Id) : null;
                if(oldContact == null || (oldContact != null && (con.AccountId != oldContact.AccountId || con.OwnerId != oldContact.OwnerId))){
                    accIdSet.add(con.AccountId);
                }
            }
        }

        if(accIdSet != null && !accIdSet.isEmpty()){
            for(Account acc: [SELECT Id, OwnerId FROM Account WHERE Id IN: accIdSet AND Owner.isActive =: true]){
                accIdOwnerIdMap.put(acc.Id, acc.OwnerId);
            }
    
            for(Contact con : newContactList){
                if(accIdOwnerIdMap.keyset().Contains(con.AccountId)){
                    con.OwnerId = accIdOwnerIdMap.get(con.AccountId);
                }
            }
        }
        TriggerUtility.contactOwnerShipExecuted();
    }    
    
    public static void updateContactWhiteSpace(List<Contact> newContacts, Map<Id, Contact> mapOldContacts) {
        if (TriggerUtility.isconWhiteSpaceUpdateExecuted()) {
            return;
        }

        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setContactIdsToExclude = new Set<Id>();
        List<Contact> lstContactsToUpdate = new List<Contact>();
        Map<Id, Map<String, Id>> mapAccountContactRole = new Map<Id, Map<String, Id>>();
        
        for (Contact contact : newContacts) {
            Contact oldContact = (mapOldContacts != null && mapOldContacts.isEmpty()) ? mapOldContacts.get(contact.Id) : null;
            if (contact.AccountId != null
                && (oldContact == null
                    || (contact.Budget_Authority__c && contact.Budget_Authority__c != oldContact.Budget_Authority__c)
                    || (contact.Service_Owner__c && contact.Service_Owner__c != oldContact.Service_Owner__c) || contact.Active__c!=oldContact.Active__c)) {
                    
                setAccountIds.add(contact.AccountId);
                setContactIdsToExclude.add(contact.Id);
                
                if (!mapAccountContactRole.containsKey(contact.AccountId)) {
                    Map<String, Id> roleContactMap = new  Map<String, Id>();
                    if (contact.Budget_Authority__c) {
                        roleContactMap.put(BUDGET_AUTHORITY_STRING, contact.Id);
                    }

                    if (contact.Service_Owner__c) {
                        roleContactMap.put(SERVICE_OWNER_STRING, contact.Id);
                    }
                    
                    if(!roleContactMap.isEmpty()){
                        mapAccountcontactRole.put(contact.AccountId, roleContactMap);
                    }
                } //END IF mapAccountContactRole

            }
        }
        //Changed by Nathan : CR# 55: CTM Changes : Start
        ////Added by Gurjinder : CR# 154 : (Head_of_IT__c = True OR Head_of_Networking__c = True OR Head_of_Security__c = True) Removed Criteria from Query
        for (Contact dbContact : [SELECT Id, 
                                    Budget_Authority__c, Service_Owner__c, AccountId,Active__c
                                  FROM Contact WHERE AccountId IN :setAccountIds AND Id NOT IN :setContactIdsToExclude
                                   AND (Budget_Authority__c = True OR Service_Owner__c = True)]) {
            Map<String, Id> mapContactRoles = mapAccountContactRole.containsKey(dbContact.AccountId) ? mapAccountContactRole.get(dbContact.AccountId) : new Map<String, Id>();
            Boolean needToUpdate = false;
            
            if (dbContact.Budget_Authority__c
                && mapContactRoles.containsKey(BUDGET_AUTHORITY_STRING)
                && mapContactRoles.get(BUDGET_AUTHORITY_STRING) != dbContact.Id) {
                dbContact.Budget_Authority__c = false;
                needToUpdate = true;
            }

            if (dbContact.Service_Owner__c
                && mapContactRoles.containsKey(SERVICE_OWNER_STRING)
                && mapContactRoles.get(SERVICE_OWNER_STRING) != dbContact.Id) {
                dbContact.Service_Owner__c = false;
                needToUpdate = true;
            }

            if (needToUpdate) {
                lstContactsToUpdate.add(dbContact);
            }
        }
        
        List<String> errorlst = new List<String>();
        try {
            if (!lstContactsToUpdate.isEmpty()) {
                Database.SaveResult[] srList = Database.update(lstContactsToUpdate, true);
                for(Database.SaveResult sr : srList){
                    if(!sr.isSuccess()){
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()){
                            errorlst.add(sr.getId() + ' - ' + err.getMessage());
                        }
                    }
                }
            }
            TriggerUtility.conWhiteSpaceUpdateExecuted();
        } catch(Exception ex) {
            String errorMsg = 'Exception occurred while updating contacts whitespace roles. ' + ex.getMessage() + ' ' + ex.getStackTraceString();
            System.debug(LoggingLevel.DEBUG, errorMsg);
            errorlst.add(errorMsg);
        }

        if(!errorlst.isEmpty()){
            String errorMessage = String.join(errorlst, ', ');
            ZscalerErrorLogsUtility.insertLogsForAsync('ContactTriggerHelper', 'updateContactWhiteSpace', 'Apex', UserInfo.getUserId(), 'Sales Cloud', 'NA', errorMessage, 'Exception');
        }
    }
        
    public static void dealRegValidation(Map<Id, Contact> conOldMap){
        set<id> conIdSet  = new set<Id>();

        for(Deal_Reg__c deal : [Select Id, Contact__c from Deal_Reg__c Where Contact__c IN: conOldMap.keySet()] ){
            conIdSet.add(deal.Contact__c);
        }

        for(Contact con : conOldMap.Values()){
            if(conIdSet.contains(con.id))
                con.addError('Deal is associated to this contact and cannot be deleted.');
        }
    }
        
    //Added By Gurjinder
    public static void ZCloudIDContactInsert(List<Contact> conList){
        List<Contact> UpdateconList= new List<Contact>();
        Set<String> SendCIOReportstatus= new Set<String>();

        ZscalerCustomSetting__c zSetting = ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus');
        String ContactSendCIOReportstatus= (zSetting != null && zSetting.Value__c != null) ? zSetting.Value__c : 'Send,Send delayed';

        SendCIOReportstatus.addall(ContactSendCIOReportstatus.split(','));
        for(Contact con:conList){
            // IBA-5318 Added ZCloudId_Org_IDs for the contact
            if(con.Contacts_that_matter__c && SendCIOReportstatus.contains(con.Send_CIO_Report__c)){
                UpdateconList.add(new Contact(Id = con.Id,accountid=con.accountid, ZCloudID_Org_IDs__c=con.ZCloudID_Org_IDs__c));
            }
        }
        if(!UpdateconList.isempty()){
            ContactTriggerHelper.InsertZcloudIDContact(UpdateconList);              
        }
    }
    
    public static void ZCloudIDContactUpdate(List<Contact> Conlist,Map<Id, Contact> conOldMap){
        if (TriggerUtility.AutocreateZCloudIDcontactUpdateExecuted()) {
            return;
        }
        
        TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
        
        Set<String> SendCIOReportstatus= new Set<String>();
        List<Contact>  ListtocreateZCIDContacts= new List<Contact>();
        List<Contact>  ListtoRemoveZCIDContacts= new List<Contact>();
        Map<id,Contact>  MaptoRemoveZCIDContacts= new Map<id,Contact>();

        ZscalerCustomSetting__c zSetting = ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus');
        String ContactSendCIOReportstatus= zSetting!=null && zSetting.Value__c!=null ? zSetting.Value__c:'Send,Send delayed';

        SendCIOReportstatus.addall(ContactSendCIOReportstatus.split(','));
        
        for(Contact Con:Conlist){         
            Contact oldContact = conOldMap.get(con.id);       
            if((con.Contacts_that_matter__c && oldContact.Contacts_that_matter__c==false && con.Send_CIO_Report__c!=null && SendCIOReportstatus.contains(con.Send_CIO_Report__c) && !SendCIOReportstatus.contains(oldContact.Send_CIO_Report__c))  || (con.Contacts_that_matter__c && oldContact.Contacts_that_matter__c==false && con.Send_CIO_Report__c!=null && SendCIOReportstatus.contains(con.Send_CIO_Report__c)) ){
                ListtocreateZCIDContacts.add(con);              
            }else if(con.Contacts_that_matter__c && con.Send_CIO_Report__c!=null && !con.Send_CIO_Report__c.equalsignorecase(oldContact.Send_CIO_Report__c) && SendCIOReportstatus.contains(con.Send_CIO_Report__c) && !SendCIOReportstatus.contains(oldContact.Send_CIO_Report__c)  ){
                ListtocreateZCIDContacts.add(con);
            }
            else if((!con.Contacts_that_matter__c && oldContact.Contacts_that_matter__c==true) || (con.Send_CIO_Report__c!=null && !SendCIOReportstatus.contains(con.Send_CIO_Report__c))  || (con.Send_CIO_Report__c==null && oldContact.Send_CIO_Report__c!=null) ){
                MaptoRemoveZCIDContacts.put(con.id,con);
                ListtoRemoveZCIDContacts.add(con);
            }
        }
        
        if(!ListtocreateZCIDContacts.isempty()){
            ContactTriggerHelper.InsertZcloudIDContact(ListtocreateZCIDContacts);
            
        }
        
        if(!ListtoRemoveZCIDContacts.isempty()){
            ContactTriggerHelper.ZCloudIDContactDelete(ListtoRemoveZCIDContacts);
            
        }
    }
        
    public static void ZCloudIDContactDelete(List<Contact> conOldList){
        Set<id> ContactIdSet =new Set<id>();        
        for(Contact Con:conOldList){
            ContactIdSet.add(con.id);   
        }
        if(!ContactIdSet.isempty()){
            List<Zscaler_Cloud_ID_Contact__c> ZCloudIDCncttoDelete = [SELECT Id FROM Zscaler_Cloud_ID_Contact__c WHERE Contact__c IN:ContactIdSet];
            
            if(ZCloudIDCncttoDelete != null && !ZCloudIDCncttoDelete.isEmpty()){
                TriggerUtility.ZCloudIDcontactDeletetriggersettrue();
                try{
                    Database.delete(ZCloudIDCncttoDelete);
                }catch(DmlException e){
                    System.debug(LoggingLevel.DEBUG, e.getMessage());
                    ZscalerErrorLogsUtility.insertlogsForAsync('ContactTriggerHelper' , 'ZCloudIDContactDelete', 'Apex',UserInfo.getUserId(),'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
                } 
            }
        }
    }
        
    public static void InsertZcloudIDContact(List<Contact> conList){
        Set<id> AccountidSet = new Set<id>();
        Set<id> ContactidSet = new Set<id>();
        // IBA-5318 START
        List<String> errorMessageList = new List<String>();
        // IBA-5318 END
        List<Zscaler_Cloud_ID_Contact__c> ZCloud_IDContactList= new List<Zscaler_Cloud_ID_Contact__c>();
        Map<id,List<Zscaler_Cloud_ID__c>> AccwithOrgIdMap= new Map<id,List<Zscaler_Cloud_ID__c>>();
        for(Contact Con:conList)
        {
            AccountidSet.add(Con.Accountid);
            ContactidSet.add(Con.id);
        }

        for(Zscaler_Cloud_ID__c ZC:[Select id,Name,Account__c from Zscaler_Cloud_ID__c where Account__c IN:AccountidSet]){
            if(!ZC.Name.contains('beta')){
                if(AccwithOrgIdMap!=null && AccwithOrgIdMap.containskey(ZC.Account__c)){
                    AccwithOrgIdMap.get(ZC.Account__c).add(ZC);             
                }else{
                    AccwithOrgIdMap.put(ZC.Account__c, new List<Zscaler_Cloud_ID__c>{ZC});
                }
            }
        }

        Set<String> ZCloudidSet;
        for(Contact Con:conList){
            if(Con.ZCloudID_Org_IDs__c!=null && Con.ZCloudID_Org_IDs__c!=''){
                ZCloudidSet = new Set<String>();
                ZCloudidSet.addall(Con.ZCloudID_Org_IDs__c.split(','));
                for(String str:ZCloudidSet){
                    Zscaler_Cloud_ID_Contact__c ZCC= new Zscaler_Cloud_ID_Contact__c();
                    ZCC.Account__c=Con.Accountid;
                    ZCC.Contact__c=Con.id;
                    ZCC.Zscaler_Cloud_ID__c=id.valueof(str);
                    ZCloud_IDContactList.add(ZCC);
                }               
            }
            else if(AccwithOrgIdMap !=null && AccwithOrgIdMap.containskey(Con.AccountId) && AccwithOrgIdMap.get(Con.AccountId)!=null){
                String OrGIDs='';
                for(Zscaler_Cloud_ID__c ZCloudid:AccwithOrgIdMap.get(Con.AccountId)){
                    Zscaler_Cloud_ID_Contact__c ZCC= new Zscaler_Cloud_ID_Contact__c();
                    ZCC.Account__c=Con.Accountid;
                    ZCC.Contact__c=Con.id;
                    ZCC.Zscaler_Cloud_ID__c=ZCloudid.id;
                    ZCloud_IDContactList.add(ZCC);
                    OrGIDs=OrGIDs+ZCloudid.id+',';
                }
                    con.ZCloudID_Org_IDs__c=OrGIDs;
                                
            }   
        }
        TriggerUtility.ZCloudIDcontactAfterInserttriggersettrue();
        // IBA-5318 START Added Error Handling
        List<Database.SaveResult> insertResultList = database.insert(ZCloud_IDContactList, false);
        for (Database.SaveResult insertResult : insertResultList) {
            if (!insertResult.isSuccess()) {
                for (Database.Error error : insertResult.getErrors()) {
                    errorMessageList.add(error.getMessage());
                }
            }
        }
        
        if (!errorMessageList.isEmpty()) {
            ZscalerErrorLogsUtility.insertLogs('ContactTriggerHelper', 'InsertZcloudIDContact', 'Apex', UserInfo.getUserId(), 'Sales Cloud', 'NA', String.join(errorMessageList, ','), 'NA');
        }
        // IBA-5318 END 
        if(trigger.isinsert){
            TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
            update conList;
        }  
    }
	
    //Added by Swathi: CR1416/CR1127 Start
    public static void UpdateTaskFields( List<Contact> conList, map < Id, Contact > contactOldMap){
        if (TriggerUtility.iscontaskFieldUpdateExecuted()) {
            return;
        }

        set<Id> contactIdset = new set<Id>();
        List<Task> tasktoUpdate= new List<Task>();
        Map<Id,Contact> MapOfContRecord = New Map<Id,Contact>();
        for(Contact con : conList){
            Contact oldContact = contactOldMap.get(con.Id);
            if((con.Qualifying_SDR__c != oldContact.Qualifying_SDR__c) || (con.Qualification_Status__c != oldContact.Qualification_Status__c)){
                contactIdset.add(con.ID);
                MapOfContRecord.put(con.ID,con);
            }
        }

        if(contactIdset.isEmpty()){
            return;
        }

        List<Id> taskIdList = new List<Id>();
        For(TaskWhoRelation RelIds: [SELECT id,taskid from TaskWhoRelation where Type='Contact' and RelationId in: contactIdset]){
            taskIdList.add(RelIds.taskid);
        }
        for(Task tas: [SELECT id,SDR_Qualified__c,Whoid,WhoCount,(SELECT RelationId from TaskWhoRelations) FROM Task WHERE id in: taskIdList ]){
            Boolean track=false;
            if(tas.WhoCount<=1){
                if(MapOfContRecord.containsKey(tas.WhoId) && MapOfContRecord.get(tas.WhoId) != null){
                    if(MapOfContRecord.get(tas.Whoid).Qualifying_SDR__c == null || (MapOfContRecord.get(tas.Whoid).Qualifying_SDR__c != null && MapOfContRecord.get(tas.Whoid).Qualification_Status__c == 'Disqualified')){
                        tas.SDR_Qualified__c = False;
                    }else{
                        tas.SDR_Qualified__c = True;
                    }
                    tasktoUpdate.add(tas);
                }
            }
            else{
                for(TaskWhoRelation tWho : tas.TaskWhoRelations){
                    if( !track 
                        && MapOfContRecord.containsKey(tWho.RelationId) 
                        && MapOfContRecord.get(tWho.RelationId)?.Qualifying_SDR__c != null 
                        && MapOfContRecord.get(tWho.RelationId)?.Qualification_Status__c != 'Disqualified'){
                            tas.SDR_Qualified__c = True;
                            track = true;
                            tasktoUpdate.add(tas);
                    }
                }
                if(!track){
                    tas.SDR_Qualified__c = False;
                    tasktoUpdate.add(tas);
                }
            }
        }

        if(!tasktoUpdate.isEmpty()) {
            TriggerHandler.bypass('TaskTriggerHandler');
            Database.update(tasktoUpdate, false);
            TriggerHandler.clearBypass('TaskTriggerHandler');
        }
        TriggerUtility.contaskFieldUpdateExecuted();
    }
    //Added by Swathi: CR1416/CR1127 End
  
    //Added by Gurjinder : CR# 1256 :Start
    public static void updateTouchesSinceLastOpen(List<Contact> Contactlist,Map<id,Contact> OldContactMap){
        if (TriggerUtility2.IsupdateTouchesSinceLastOpenExecuted()) {
            return;
        }

        List<Id> contact_ids= new List<id>();
        Map<id,date> ContactandLastOpenedDate= new map<id,date>();
        Map<id,integer> ContactandLastTouches= new map<id,integer>();
        for(Contact c:Contactlist){
            Contact oldContact = OldContactMap.get(c.id);
            if(c.Last_Opened_Date__c != oldContact.Last_Opened_Date__c && c.Last_Opened_Date__c != null){
                contact_ids.add(c.id);
                ContactandLastOpenedDate.put(c.id,c.Last_Opened_Date__c);
            }else if(c.Last_Opened_Date__c != oldContact.Last_Opened_Date__c && c.Last_Opened_Date__c == null){
                c.Touches_Since_Last_Open__c = 0;
            }
        }
        if(!contact_ids.isEmpty()){
            for(Contact c : [SELECT Last_Opened_Date__c,Touches_Since_Last_Open__c, (select id,ActivityDate from tasks where Status= 'Completed'),(select id,ActivityDate,enddatetime from events) FROM Contact WHERE ID IN :contact_ids and Last_Opened_Date__c!=null]){
                
                Integer taskscount2 =  0;
                if(c.tasks != null){
                    for(task t:c.tasks){
                        if(t.ActivityDate>=ContactandLastOpenedDate.get(c.id)){
                            taskscount2=taskscount2+1;
                        }
                    }
                }

                Integer Eventcount2 =  0;
                if(c.events != null){
                    for(event evnt:c.events){
                        if(evnt.ActivityDate>=ContactandLastOpenedDate.get(c.id) && evnt.enddatetime<=System.now()){
                            Eventcount2=Eventcount2+1;
                        }
                    }
                }
                
                integer totalcount2 = taskscount2+Eventcount2;
                c.Touches_Since_Last_Open__c = totalcount2;
                ContactandLastTouches.put(c.id,totalcount2);
            }
            
            for(Contact c:Contactlist){
                if(ContactandLastTouches.containskey(c.id)){
                    c.Touches_Since_Last_Open__c=ContactandLastTouches.get(c.id);
                }
            }
        }
        
    }
    
    //Added by Gurjinder : CR# 1256 :End
    //Added by Swathi : CR 1505 Start
    public static void updateCampaignMemberBasedCont(List<Contact> Contactlist,Map<id,Contact> OldContactMap){
        Map<id,contact> contmap = new Map<id,Contact>();
        List<CampaignMember> update_campaignMember = new List<CampaignMember>();
        for(Contact c:Contactlist){
            Contact oldContact = OldContactMap.get(c.id);
            if((c.MQL_Date__c != null && oldContact.MQL_Date__c == null) || (c.Person_MQL_Date__c != null && oldContact.Person_MQL_Date__c == null)){
                contmap.put(c.id, c);
            }
        }

        if(!contmap.isEmpty()){
            for(CampaignMember c : [SELECT MQL_Date_Stamped__c,Contactid,Person_MQL_Date_Stamped__c FROM CampaignMember WHERE Contactid IN :contmap.keySet()]){
                Contact conObj = contmap.get(c.Contactid);
                if((c.MQL_Date_Stamped__c == null && conObj?.MQL_Date__c != null)){
            		c.MQL_Date_Stamped__c = conObj.MQL_Date__c;
            		update_campaignMember.add(c);
                }
                if((c.Person_MQL_Date_Stamped__c == null && conObj?.Person_MQL_Date__c != null)){
                    c.Person_MQL_Date_Stamped__c = conObj.Person_MQL_Date__c;
                    update_campaignMember.add(c);
                }
            }
        }

        if(!update_campaignMember.isEmpty()){
            update update_campaignMember;
        }

        TriggerUtility2.UpdateCampaignMemberBasedOnContExecuted();
    }
    //Added by Swathi : CR 1505 End
    
    //CR# 3382 START - Bikram 11th Oct 2021 Update Contact Funnel Stage
    public static void insertFunnelStageAutomation(List<Contact> contactlist){
        for(Contact con : contactlist){
            if(ContactTriggerHelper.CONTACT_LEAD_STATUS_SET.contains(con.Contact_Lead_Status__c)){
                con.Funnel_Stage_Date__c = NULL;
                con.Funnel_Stage__c = 'Inactive';                   
            }
        }
    }
    //CR# 3382 END - Bikram 11th Oct 2021
    
    //CR# 3382 START - Bikram 11th Oct 2021 Update Contact Funnel Stage
    public static void updateFunnelStageAutomation(List<Contact> contactList,Map<Id,Contact> oldContactMap){
        for(Contact con : contactlist){
            Contact oldContact = oldContactMap.get(con.Id);
            if( ContactTriggerHelper.CONTACT_LEAD_STATUS_SET.contains(con.Contact_Lead_Status__c) 
                && con.Contact_Lead_Status__c != oldContact.Contact_Lead_Status__c){
                    con.Funnel_Stage_Date__c = NULL;
                    con.Funnel_Stage__c = 'Inactive';
            }
        }
    }    
    //CR# 3382 END - Bikram 11th Oct 2021

    /**
    * @description returns the map of contact and territory
    **/
    public static Map<Id, Id> getMapContactIdAndTerrityId(List<Contact> contactList,Map<Id,Contact> oldContactMap){
        Map<Id, Id> contactIdTerritoryIdMap = new Map<Id, Id>();
        for(Contact con : contactList){
            Contact oldContact = oldContactMap.get(con.Id);
            if(oldContact != null && con.Territory__c != oldContact.Territory__c){
                contactIdTerritoryIdMap.put(con.id, con.Territory__c);
            }
        }
        return contactIdTerritoryIdMap;
    }

    /**
    * @description populate Sync_to_PRM__c field before update
    **/
    public static void populateSynctoPRM(List<Contact> contactList,Map<Id,Contact> oldContactMap){
        for(Contact c : contactList){
            Contact oldContact = oldContactMap.get(c.id);
            if(oldContact != null && oldContact.Request_to_Sync_to_PRM__c != c.Request_to_Sync_to_PRM__c ){
                c.Sync_to_PRM__c = c.Request_to_Sync_to_PRM__c;
            } 
        }
    }

    /**
    * @description enqueues job to insert Provisioning_Request__c & Product_Demo_Instance_Request__c
    **/
    public static void processInteractiveList(List<Contact> contactList,Map<Id,Contact> oldContactMap, String action){
        List<Id> ZPAInteractiveList = new List<Id>();
        List<Id> ZB2BInteractiveList = new List<Id>();
        List<Contact> contactIdVsContactList = new List<Contact>();//IBA-6228
        List<Contact> contactIdVsExistingContactList = new List<Contact>();//IBA-6228
        if (action == 'INSERT') {
            for (Contact con: contactList) {
                if (con.ZPA_Interactive_Prospect__c) {
                    ZPAInteractiveList.add(con.Id);
                }
                if (con.ZB2B_Interactive_Prospect__c) {
                    ZB2BInteractiveList.add(con.Id);
                }
                //IBA-6228 Start
                if(con.Sync_to_PRM__c=='Yes' && System.label.OktaCalloutController == 'Active' ){
                	contactIdVsContactList.add(con);
                }
                //IBA-6228 End
            }
        } else if (action == 'UPDATE') {
            if (!TriggerUtility.isPatchRealigning()) {
                for (Contact con: contactList) {
                    Contact oldContact = oldContactMap.get(con.Id);
                    if (oldContact != null 
                        && con.ZPA_Interactive_Prospect__c != oldContact.ZPA_Interactive_Prospect__c 
                        && con.ZPA_Interactive_Prospect__c == true) {
                            ZPAInteractiveList.add(con.Id);
                    }
                    if (oldContact != null 
                        && con.ZB2B_Interactive_Prospect__c != oldContact.ZB2B_Interactive_Prospect__c 
                        && con.ZB2B_Interactive_Prospect__c == true) {
                            ZB2BInteractiveList.add(con.Id);
                    }
                    //IBA-6228 Start
                    if (con.Sync_to_PRM__c != oldContact.Sync_to_PRM__c 
                        && con.Sync_to_PRM__c == 'Yes' && con.OKTA_User_ID__c==Null 
                        && System.label.OktaCalloutController == 'Active') {
                    	contactIdVsContactList.add(con);
                    }
                    if (( con.FirstName != oldContact.FirstName
                        || con.LastName != oldContact.LastName
                        || con.Email != oldContact.Email
                        || con.AccountId != oldContact.AccountId )
                        && con.Sync_to_PRM__c == 'Yes' && con.OKTA_User_ID__c!=Null
                        && System.label.OktaCalloutController == 'Active') {
                            contactIdVsExistingContactList.add(con);
                    }
                	//IBA-6228 End
                }
            }
        }

        if (ZPAInteractiveList != null && !ZPAInteractiveList.isEmpty()) {
            System.enqueueJob(new ZPAInteractiveRequest('Contact', ZPAInteractiveList));
        }
        
        if (ZB2BInteractiveList != null && !ZB2BInteractiveList.isEmpty()) {
            System.enqueueJob(new ZB2BInteractiveRequest('Contact', ZB2BInteractiveList));
        }
        //IBA-6228 Start
        if (contactIdVsContactList != null && !contactIdVsContactList.isEmpty()) {
            PartnerOnboardingUtility.insertIntegrationLog(contactIdVsContactList,'New');
        }
        
        if (contactIdVsExistingContactList != null && !contactIdVsExistingContactList.isEmpty()) {
            PartnerOnboardingUtility.insertIntegrationLog(contactIdVsExistingContactList,'Update');
        }
        //IBA-6228 End
    }
    
}