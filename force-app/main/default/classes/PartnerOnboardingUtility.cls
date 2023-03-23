/**
* @File Name          : PartnerOnboardingUtility.cls
* @TestClass          : PartnerProspectTriggerTest
*==============================================================================
* Ver         Date                     Author                    Modification
* 1.0         2023-01-12               Akash/Viral               Initialized
*==============================================================================
**/
public without sharing class PartnerOnboardingUtility {
    private static String renewalCont = 'Renewal Contact';
    private static String primaryPartCont = 'Primary Partner Contact';
    //Pouplate Long Form Default values
    public static Partner_Prospect__c preparePartnerProspectRecord(Partner_Prospect__c pi, Generic_Field_Mapping_Default_Value__mdt mtd){
        System.Debug('--preparePartnerIncentiveRecord--ppfieldTypeMAP--'+ppfieldTypeMAP);    
        return (Partner_Prospect__c) prepareGenericRecord(pi,ppfieldTypeMAP,mtd);
    }
    
    //IBA-5868 - AT [Account & Contact Creation]
    public static void createPartnerAccount(List<Partner_Prospect__c> prospectList){
        
        MAP<Id,Partner_Prospect__c> ppMAP = new MAP<Id,Partner_Prospect__c>();
        for(Partner_Prospect__c pp : prospectList){
            if(pp.Application_Status__c == 'Approved' && pp.Partner_Account__c == null){
                ppMAP.put(pp.Id, pp);
            }
        }
        
        if(ppMAP.isEmpty())
            return;
        
        system.debug('--createPartnerAccount--ppMAP--'+ppMAP);
        
        MAP<ID,Account> ppAccountMAP = new MAP<ID,Account>();
        Map<ID,ID> ppIdToAccId = new Map<id, id>();
        
        //Step1 : Create Account Record - [AT - IBA-6213]
        MAP<id, id> ppIdPatchIdMap = getPatchid(ppMAP.values()); 
        for(Partner_Prospect__c pp : ppMAP.values()){
            Account acc = new Account();
            
            if(defaultMappingMdtList != null && !defaultMappingMdtList.isEmpty()){
                acc = prepareAccount(acc, defaultMappingMdtList);
            }
            if(fieldMappingMdtList != null && !fieldMappingMdtList.isEmpty()){
                acc = prepareAccountMapping(pp, acc, fieldMappingMdtList);
            }
            if(!ppIdPatchIdMap.isEmpty() && ppIdPatchIdMap.get(pp.id) != null){
                acc.Patch__c = ppIdPatchIdMap.get(pp.id);
                acc.PatchLocked__c = true;
            }
            acc.Initial_Request_Date__c = pp.CreatedDate.date();
            acc.Domain__c = pp.Email_Address__c.subStringAfter('@');
            acc.SummitDistribution__c = pp.Partner_Level__c == 'Tier 2'? true : false;
            
            ppAccountMAP.put(pp.Id,acc);
        }
        System.debug('---createPartnerAccount--ppAccountMAP--'+ppAccountMAP);
        Database.insert(ppAccountMAP.values());
        
        //Step2 : Create Contact Record
        List<Contact> ppConList = new List<Contact>();
        for(Partner_Prospect__c pp : ppMAP.values()){
            Account createdAcc = ppAccountMAP.get(pp.Id);
            if(createdAcc.Id != null){
                ppIdToAccId.put(pp.id, createdAcc.id);
                ppConList.addALL(createPartnerContacts(pp, createdAcc));
            }
        }
        System.debug('---createPartnerAccount--ppConList--'+ppConList);
        Database.insert(ppConList);
        
        //Step3 : Create Partner Incentive record
        createPartnerIncentiveRecords(ppMAP,ppIdToAccId);
        
        //Step4 : Update Partner Contract Reviewer On Account and tag Partner Account to Partner Prospect Record
        updateAccountAndPartnerProspect(ppIdToAccId);
    }
    
    //IBA-5868 - AT [Contact Creation for Partner]
    @testvisible 
    private static List<Contact> createPartnerContacts(Partner_Prospect__c pp, Account acc){
        List<Contact> conListToInsert = new List<Contact>();
        if(pp.Source__c == 'Long Form' && contactMappingMdtList != null && !contactMappingMdtList.isEmpty()){
            conListToInsert = prepareContactMapping(pp, conListToInsert, contactMappingMdtList, acc);
        }
        System.debug('---createPartnerAccount--conListToInsert--'+conListToInsert);
        System.debug('---createPartnerAccount--contactMappingMdtList--'+contactMappingMdtList.Size());        
        return conListToInsert;
    }

    
    //IBA-6153 - AT [Craete Incentive Records]
    @testVisible
    private static void createPartnerIncentiveRecords(MAP<Id,Partner_Prospect__c> ppMAP,Map<ID,ID> ppIdToAccId){
        List<Partner_Incentive__c> piListToInsert = new List<Partner_Incentive__c>();
        for(Partner_Prospect__c pp : ppMAP.values()){
            Partner_Incentive__c pi = preparePIRec(pp);
            if(pi == null) continue;
            pi.Partner_Tier__c = pp.Partner_Tier__c;
            pi.Effective_End_Date__c = Date.newInstance(2099, 12, 31);
            pi.Effective_Start_Date__c = System.today();
            pi.Account__c = ppIdToAccId.get(pp.id);
            if(pp.Partner_Level__c == 'Tier 2'){
                pi.Transacting_Entity__c = pp.Distributor_Name__c;
                pi.Transacting_Location__c = pp.Country__c;
            }
			
            piListToInsert.add(pi);
        }
        
        try{
            Database.insert(piListToInsert);
        }catch(exception e){
            ZscalerErrorLogsUtility.insertLogs('PartnerOnboardingUtility', 'createPartnerIncentiveRecords', 'Apex', UserInfo.getUserId(), 'Sales Cloud', 
                                               e.getStackTraceString(), 'DML Partner Incentive Insertion failed ' + e.getMessage(), 
                                               e.getTypeName());
        }
    }
    
    //Update Account Lookup on the Partner Prospect after Account creation
    //Update PartnerContractReviewer__c on Acocunt
    @future @testVisible
    private static void updateAccountAndPartnerProspect(Map<Id, Id> ppIdToAccId){
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('PartnerProspectTriggerHandler');
        
        Set<String> ppASEmails = new Set<String>();
        //Boolean accUpdate = false;
        List<Partner_Prospect__c> ppList = new List<Partner_Prospect__c>();
        for(Partner_Prospect__c pp : [SELECT id,Partner_Account__c,Authorized_Signer_Email__c FROM Partner_Prospect__c WHERE id IN :ppIdToAccId.keySet()]){
            if(pp.Authorized_Signer_Email__c != null)
                ppASEmails.add(pp.Authorized_Signer_Email__c);
            pp.Partner_Account__c = ppIdToAccId.get(pp.id);
            ppList.add(pp);
        }
        
        Map<Id,Contact> accIdconMap = new Map<Id,Contact>();
        for(Contact con : [SELECT ID,AccountId FROM Contact WHERE AccountId In :ppIdToAccId.values() and Email in :ppASEmails]){
            accIdconMap.put(con.AccountId, con);
        }
        
        List<Account> accList = new List<Account>();
        for(Account acc: [SELECT id,PartnerContractReviewer__c FROM Account WHERE id IN :accIdconMap.keySet()]){
            if(accIdconMap.containskey(acc.id)){
                acc.PartnerContractReviewer__c = accIdconMap.get(acc.id).id;
                accList.add(acc);
            }
        }
        
        System.debug('---UpdateAccount--accList--'+accList);
        System.debug('---UpdatePartnerProspect--ppList--'+ppList);
               
        try{
            Database.update(accList);
            Database.update(ppList);
            //accUpdate = true;
        }catch(exception e){
            ZscalerErrorLogsUtility.insertLogs('PartnerOnboardingUtility', 'updateAccountAndPartnerProspect', 
                                               'Apex', UserInfo.getUserId(), 'Sales Cloud', e.getStackTraceString(), 
                                               'DML Account or Partner Prospect Updation failed ' + e.getMessage(), 
                                               e.getTypeName());
        }
    }
    
    
    ///////////////////////////////Utility Methods////////////////////////
   	
    @testVisible
    private static Partner_Incentive__c preparePIRec(Partner_Prospect__c pp){
        
        if(piRecDefaultMappingMdtList == null || piRecDefaultMappingMdtList.isEmpty()) 
            return null;
        
        Partner_Incentive__c pi = new Partner_Incentive__c();
        
        for(Generic_Field_Mapping_Default_Value__mdt mtd : piRecDefaultMappingMdtList){
            if(pp.Partner_Tier__c == 'Zenith'){
                if(mtd.Origin__c == 'PO Partner Incentive Zenith'){
                    pi = preparePartnerIncentiveRecord(pi, mtd);
                }
            }   
            if(pp.Partner_Tier__c == 'Alpine'){
                if(mtd.Origin__c == 'PO Partner Incentive Alpine'){
                    pi = preparePartnerIncentiveRecord(pi, mtd);
                }
            }
            if(mtd.Origin__c == 'PO Partner Incentive'){
                pi = preparePartnerIncentiveRecord(pi, mtd);                 
            }
            if(pp.Partner_Level__c == 'Tier 1'){
                if(mtd.Origin__c == 'PO Partner Incentive Tier 1'){
                pi = preparePartnerIncentiveRecord(pi, mtd);
                }
            }
            if(pp.Partner_Level__c == 'Tier 2'){
                if(mtd.Origin__c == 'PO Partner Incentive Tier 2'){
                pi = preparePartnerIncentiveRecord(pi, mtd);
                }
            }
        }
        return pi;
    }
    
    //Prepare Initial default values for Account Record
    private static Account prepareAccount(Account acc, List<Generic_Field_Mapping_Default_Value__mdt> defaultMappingMdtList) {
        if(acc == null){
            acc = new Account();
        }
        
        for(Generic_Field_Mapping_Default_Value__mdt genericMDT : defaultMappingMdtList) {
            //acc.put(genericMDT.Field_API_Name__c, genericMDT.Default_Value__c);
            prepareGenericRecord(acc,accfieldTypeMAP,genericMDT);
        }
        
        System.debug('---prepareAccount--acc--'+acc);
        return acc;
    }
    
    //Prepare Account from Generic Field Mapping
    private static Account prepareAccountMapping(Partner_Prospect__c partnerProspect, Account acc, List<Generic_Field_Mapping__mdt> metaDataList){
        if(acc == null){
            acc = new Account();
        }
        
        List<Generic_Field_Mapping__mdt> accMapping = new  List<Generic_Field_Mapping__mdt>();
        for(Generic_Field_Mapping__mdt mdt : metaDataList){
            if(mdt.Origin__c != null && mdt.Origin__c == 'Partner Onboarding'){
                accMapping.add(mdt);
            }
        }
        System.debug('---prepareAccountMapping--accMapping--'+accMapping);
        
        acc = (Account)GenericFieldMappingController.prepareRecordFromGenericFieldMapping(partnerProspect, acc, accMapping);
        return acc;
    }
    
    //Prepare List<Contact> from Generic Field Mapping
    private static List<Contact> prepareContactMapping(Partner_Prospect__c partnerProspect, List<Contact> conList,
                                                       List<Generic_Field_Mapping__mdt> metaDataList, Account acc)
    {       
        List<Generic_Field_Mapping__mdt> partnerAdmin = new List<Generic_Field_Mapping__mdt>();
        List<Generic_Field_Mapping__mdt> renewal = new List<Generic_Field_Mapping__mdt>();
        List<Generic_Field_Mapping__mdt> primary = new List<Generic_Field_Mapping__mdt>();
        List<Generic_Field_Mapping__mdt> authSignee = new List<Generic_Field_Mapping__mdt>();
        List<Generic_Field_Mapping__mdt> applicationSub = new List<Generic_Field_Mapping__mdt>();
        
        Map<String, List<Generic_Field_Mapping__mdt>> uniqueCon = new Map<String, List<Generic_Field_Mapping__mdt>>();
        Map<String, List<Generic_Field_Mapping__mdt>> metadataMap = new Map<String, List<Generic_Field_Mapping__mdt>>();
        
        for(Generic_Field_Mapping__mdt mdt : metaDataList){
            if(mdt.Origin__c != null){
                if(mdt.Origin__c == 'Application Submitter Contact'){
                    applicationSub.add(mdt);
                    metadataMap.put('Application Submitter Contact', applicationSub);
                }else if(mdt.Origin__c == 'Authorized Signee Contact'){
                    authSignee.add(mdt);
                    metadataMap.put('Authorized Signee Contact', authSignee);
                }else if(mdt.Origin__c == 'Partner Admin Contact' ){
                    partnerAdmin.add(mdt);
                    metadataMap.put('Partner Admin Contact', partnerAdmin);
                }else if(mdt.Origin__c == renewalCont){
                    renewal.add(mdt);
                    metadataMap.put(renewalCont, renewal);
                }else if(mdt.Origin__c == primaryPartCont){
                    primary.add(mdt);
                    metadataMap.put(primaryPartCont, primary);
                } 
            }
        }
        uniqueCon = validateDuplicateContacts(partnerProspect,metadataMap);
        Map<String, List<String>> roleMap = new Map<String, List<String>>();
        roleMap = getContactRoles(partnerProspect);
        System.debug(roleMap);
        
        System.debug('---UniqueContactsToCreate--uniqueCon--'+uniqueCon);
        System.debug('---UniqueContactsToCreate--uniqueCon--'+uniqueCon.Size());
        
        for(String key : uniqueCon.keySet()){
            Contact con = new Contact();
            con = (Contact)GenericFieldMappingController.prepareRecordFromGenericFieldMapping(partnerProspect, con, uniqueCon.get(key));
            con.AccountId = acc.Id;
            con.MailingCountry = acc.BillingCountry;
            con.MailingState = acc.BillingState;
            con.MailingCity = acc.BillingCity;
            con.MailingPostalCode = acc.BillingPostalCode;
            con.MailingStreet = acc.BillingStreet;
            con.Sync_to_PRM__c = 'Yes';
            System.debug(roleMap.get(key));
            if(roleMap.get(key)!= null)
            	con.Role__c = String.join(roleMap.get(key), ';');
            conList.add(con);
        }
        System.debug('---prepareAccountMapping--conList--'+conList);
        return conList;
    }
    
    private static Map<String, List<Generic_Field_Mapping__mdt>> validateDuplicateContacts (Partner_Prospect__c partnerProspect, Map<String, List<Generic_Field_Mapping__mdt>> metadataMap){
        Map<String, List<Generic_Field_Mapping__mdt>> uniqueCon = new Map<String, List<Generic_Field_Mapping__mdt>>();
        if(partnerProspect.Primary_Partner_Contact_Email__c != null){
            uniqueCon.put((partnerProspect.Primary_Partner_Contact_Email__c).trim().toLowerCase(), metadataMap.get(primaryPartCont));
        }
        if(partnerProspect.Renewal_Contact_Email__c != null){
            uniqueCon.put((partnerProspect.Renewal_Contact_Email__c).trim().toLowerCase(), metadataMap.get(renewalCont));
        }
        if(partnerProspect.Partner_Admin_Email__c != null){
            uniqueCon.put((partnerProspect.Partner_Admin_Email__c).trim().toLowerCase(), metadataMap.get('Partner Admin Contact'));
        }
        if(partnerProspect.Authorized_Signer_Email__c != null){
            uniqueCon.put((partnerProspect.Authorized_Signer_Email__c).trim().toLowerCase(), metadataMap.get('Authorized Signee Contact'));
        }
		if(partnerProspect.Email_Address__c!=Null){
            uniqueCon.put((partnerProspect.Email_Address__c).trim().toLowerCase(), metadataMap.get('Application Submitter Contact'));
        }        
        return uniqueCon;
    }
    
     //IBA-6801 : Need to capture Partner Contact role on the Contact Object
     private static Map<String, List<String>> getContactRoles (Partner_Prospect__c partnerProspect){
        Map<String, List<String>> conRoles = new Map<String, List<String>>();
       
		if(partnerProspect.Email_Address__c != null){
            conRoles.put((partnerProspect.Email_Address__c).trim().toLowerCase(), new List<String>());
            conRoles.get((partnerProspect.Email_Address__c).trim().toLowerCase()).add('Application Submitter');
        }
        if(partnerProspect.Authorized_Signer_Email__c != null){
            if(conRoles.containsKey((partnerProspect.Authorized_Signer_Email__c).trim().toLowerCase())){
                conRoles.get((partnerProspect.Authorized_Signer_Email__c).trim().toLowerCase()).add('Authorized Signee');
            }
            else{
                conRoles.put((partnerProspect.Authorized_Signer_Email__c).trim().toLowerCase(), new List<String>());
                conRoles.get((partnerProspect.Authorized_Signer_Email__c).trim().toLowerCase()).add('Authorized Signee');
            }
        }
        if(partnerProspect.Partner_Admin_Email__c!=Null){
            if(conRoles.containsKey((partnerProspect.Partner_Admin_Email__c).trim().toLowerCase())){
                conRoles.get((partnerProspect.Partner_Admin_Email__c).trim().toLowerCase()).add('Partner Admin');
            }
            else{
                conRoles.put((partnerProspect.Partner_Admin_Email__c).trim().toLowerCase(), new List<String>());
                conRoles.get((partnerProspect.Partner_Admin_Email__c).trim().toLowerCase()).add('Partner Admin');
            }
        }
        if(partnerProspect.Renewal_Contact_Email__c != null){
            if(conRoles.containsKey((partnerProspect.Renewal_Contact_Email__c).trim().toLowerCase())){
                conRoles.get((partnerProspect.Renewal_Contact_Email__c).trim().toLowerCase()).add(renewalCont);
            }
            else{
                conRoles.put((partnerProspect.Renewal_Contact_Email__c).trim().toLowerCase(), new List<String>());
                conRoles.get((partnerProspect.Renewal_Contact_Email__c).trim().toLowerCase()).add(renewalCont);
            }
        }
        if(partnerProspect.Primary_Partner_Contact_Email__c != null){
            if(conRoles.containsKey((partnerProspect.Primary_Partner_Contact_Email__c).trim().toLowerCase())){
                conRoles.get((partnerProspect.Primary_Partner_Contact_Email__c).trim().toLowerCase()).add(primaryPartCont);
            }
            else{
                conRoles.put((partnerProspect.Primary_Partner_Contact_Email__c).trim().toLowerCase(), new List<String>());
                conRoles.get((partnerProspect.Primary_Partner_Contact_Email__c).trim().toLowerCase()).add(primaryPartCont);
            }
        }
        return conRoles;
    }
    
    //IBA-6153 - Create Partner Incentive Record
    private static Partner_Incentive__c preparePartnerIncentiveRecord(Partner_Incentive__c pi, Generic_Field_Mapping_Default_Value__mdt mtd){
        System.Debug('--preparePartnerIncentiveRecord--pifieldTypeMAP--'+pifieldTypeMAP);    
        return (Partner_Incentive__c) prepareGenericRecord(pi,pifieldTypeMAP,mtd);
    }
    
    //IBA-6213 - Populating address fields and Sales Territory Information on Partner Account and Partner Contacts
    private static MAP<id, id> getPatchId(List<Partner_Prospect__c> ppList) {
        Map<id, id> ppIdPatchIdMap = new Map<id, id>();
        Map<id, id> salesTerritoryIdPpIdMap = new Map<id, id>();
        for(Partner_Prospect__c pp : ppList){
            if(pp.Sales_Territory__c != null)
                salesTerritoryIdPpIdMap.put(pp.Sales_Territory__c, pp.id);
        }
        for(Patch__c p : [SELECT id,PatchTeam__c, Name FROM Patch__c WHERE PatchTeam__c IN :salesTerritoryIdPpIdMap.keySet()]){
            if(p != null)
                ppIdPatchIdMap.put(salesTerritoryIdPpIdMap.get(p.PatchTeam__c), p.id );

        }
        return ppIdPatchIdMap;
    }
    
    @testVisible
    private static List<Generic_Field_Mapping__mdt> fieldMappingMdtList {
        get{
            if(fieldMappingMdtList == null){
                fieldMappingMdtList = GenericFieldMappingController.getMappingFromMetaData('Partner_Prospect__c','Account');
            }
            return fieldMappingMdtList;
        }
        set;
    }
    
    @testVisible
    private static List<Generic_Field_Mapping__mdt> contactMappingMdtList {
        get{
            if(contactMappingMdtList == null){
                contactMappingMdtList = GenericFieldMappingController.getMappingFromMetaData('Partner_Prospect__c','Contact');
            }
            return contactMappingMdtList;
        }
        set;
    }
    
    @testVisible
    private static List<Generic_Field_Mapping_Default_Value__mdt> defaultMappingMdtList {
        get{
            if(defaultMappingMdtList == null){
                defaultMappingMdtList = [Select Id, Label,
                                         Field_API_Name__c, Object_API_Name__c, Origin__c, Default_Value__c
                                         from Generic_Field_Mapping_Default_Value__mdt where Object_API_Name__c = 'Account'
                                         and Origin__c = 'Partner Onboarding Prospect Account' and Active__c = true];
            }
            return defaultMappingMdtList;
        }
        set;
    }
    
    @testVisible
    private static List<Generic_Field_Mapping_Default_Value__mdt> piRecDefaultMappingMdtList {
        get{
            if(piRecDefaultMappingMdtList == null){
                piRecDefaultMappingMdtList = [Select Id, Label,
                                              Field_API_Name__c, Object_API_Name__c, Origin__c, Default_Value__c
                                              from Generic_Field_Mapping_Default_Value__mdt where Object_API_Name__c = 'Partner_Incentive__c'
                                              and Origin__c LIKE 'PO Partner Incentive%' and active__c = true ];
            }
            return piRecDefaultMappingMdtList;
        }
        set;
    }
    
    @testVisible
    private static MAP<String, String> pifieldTypeMAP {
        get{
            if(pifieldTypeMAP == null){
                pifieldTypeMAP = new MAP<String,String>();
                Schema.DescribeSObjectResult objectDescribe = Schema.SObjectType.Partner_Incentive__c.getSObjectType().getDescribe();
                Map<String, Schema.SObjectField> fields = objectDescribe.fields.getMap();
                for(String fieldName : fields.keySet()) {
                    Schema.SObjectField field = fields.get(fieldName);
                    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                    pifieldTypeMAP.put(fieldDescribe.getName(), String.valueOf(fieldDescribe.getType()));
                }
            }
            return pifieldTypeMAP;
        }
        set;
    }
    
    @testVisible
    private static MAP<String, String> ppfieldTypeMAP {
        get{
            if(ppfieldTypeMAP == null){
                ppfieldTypeMAP = new MAP<String,String>();
                Schema.DescribeSObjectResult objectDescribe = Schema.SObjectType.Partner_Prospect__c.getSObjectType().getDescribe();
                Map<String, Schema.SObjectField> fields = objectDescribe.fields.getMap();
                for(String fieldName : fields.keySet()) {
                    Schema.SObjectField field = fields.get(fieldName);
                    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                    ppfieldTypeMAP.put(fieldDescribe.getName(), String.valueOf(fieldDescribe.getType()));
                }
            }
            return ppfieldTypeMAP;
        }
        set;
    }
    
    @testVisible
    private static MAP<String, String> accfieldTypeMAP {
        get{
            if(accfieldTypeMAP == null){
                accfieldTypeMAP = new MAP<String,String>();
                Schema.DescribeSObjectResult objectDescribe = Schema.SObjectType.Account.getSObjectType().getDescribe();
                Map<String, Schema.SObjectField> fields = objectDescribe.fields.getMap();
                for(String fieldName : fields.keySet()) {
                    Schema.SObjectField field = fields.get(fieldName);
                    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                    accfieldTypeMAP.put(fieldDescribe.getName(), String.valueOf(fieldDescribe.getType()));
                }
            }
            return accfieldTypeMAP;
        }
        set;
    }
        
    @testVisible
    public static List<Generic_Field_Mapping_Default_Value__mdt> defaultLongFormMappingMdtList {
        get{
            if(defaultLongFormMappingMdtList == null){
                defaultLongFormMappingMdtList = [Select Id, Label,Field_API_Name__c, Object_API_Name__c, Origin__c, Default_Value__c
                                         from Generic_Field_Mapping_Default_Value__mdt where Object_API_Name__c = 'Partner_Prospect__c'
                                         and Origin__c = 'Long Form'];
            }
            return defaultLongFormMappingMdtList;
        }
        set;
    }
    
    private static sObject prepareGenericRecord(sObject pi, MAP<String, String> sObjectfieldTypeMAP, Generic_Field_Mapping_Default_Value__mdt mtd){
        System.Debug('--preparePartnerIncentiveRecord--sObjectfieldTypeMAP--'+sObjectfieldTypeMAP);    
        if(sObjectfieldTypeMAP.containsKey(mtd.Field_API_Name__c) && 
           sObjectfieldTypeMAP.get(mtd.Field_API_Name__c) == String.valueOf(Schema.SoapType.DECIMAL))
            pi.put(mtd.Field_API_Name__c, Decimal.valueOf(mtd.Default_Value__c));
        
        else if(sObjectfieldTypeMAP.containsKey(mtd.Field_API_Name__c) && 
                sObjectfieldTypeMAP.get(mtd.Field_API_Name__c) == String.valueOf(Schema.SoapType.DATE))
            pi.put(mtd.Field_API_Name__c, Date.valueOf(mtd.Default_Value__c));
        
        else if(sObjectfieldTypeMAP.containsKey(mtd.Field_API_Name__c) &&
                sObjectfieldTypeMAP.get(mtd.Field_API_Name__c) == String.valueOf(Schema.SoapType.BOOLEAN))
            pi.put(mtd.Field_API_Name__c, mtd.Default_Value__c == 'true' ? true : false);
        
        else if(sObjectfieldTypeMAP.containsKey(mtd.Field_API_Name__c) &&
                sObjectfieldTypeMAP.get(mtd.Field_API_Name__c) == String.valueOf(Schema.SoapType.DOUBLE))
            pi.put(mtd.Field_API_Name__c, Double.valueOf(mtd.Default_Value__c));
        
        else 
            pi.put(mtd.Field_API_Name__c, String.valueOf(mtd.Default_Value__c));
        
        return pi;
    }
    
    
    //IBA-6228 : Create Integration Log Record :  Start
    public static void insertIntegrationLog(List<Contact> conList, String process_Name) {
        List<Integration_Log__c> logsToInsert = new List<Integration_Log__c>();
        for(Contact con: conList){
            Integration_Log__c log = new Integration_Log__c();
            log.Invoked_from__c = 'Partner Onboarding';
            log.Object_Id__c = con.Id;
            log.Object_Name__c = 'Contact';
            log.Request__c = Json.serialize(new ContactRequestWrapper(con));
            log.Status__c = 'Inprogress';
            log.Type__c = process_Name;
            logsToInsert.add(log);
        }
        if(!logsToInsert.isEmpty()){
            insert logsToInsert;
            fireGenericContactPlatformEvent(logsToInsert);
        }     
    }
    
    //Workato generic platform event callout for Okta Integration
    @InvocableMethod(label='Publish Callout Event for Partner Onboarding' description='Publishes the platform event to workato for Partner Onboarding')
    public static void fireGenericContactPlatformEvent(List<Integration_Log__c> logsToInsert){
        List<Workato_Generic_Event__e> eventList = new List<Workato_Generic_Event__e>();
        for(Integration_Log__c log : logsToInsert){
            Workato_Generic_Event__e evnt = new Workato_Generic_Event__e();
            evnt.Object_API_Name__c='Contact';
            evnt.Process__c = log.Type__c;
            evnt.Record_Id__c = log.Id;
            evnt.Additional_Detail__c = log.Request__c;
            eventList.add(evnt);
            System.debug('Additional_Detail__c'+evnt.Additional_Detail__c);
        }
        if(eventList !=null && !eventList.isEmpty()){
            List<Database.SaveResult> sr = Eventbus.publish(eventList);
            if (sr[0].isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr[0].getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        }
    }
    
    /*public static void recallApproval(List<Partner_Prospect__c> prospectList){
        boolean isError = false;
        List<Partner_Prospect__c> ppListToUpdate = new List<Partner_Prospect__c>();
        Set<Id> ppIds = new Set<Id>();      
        for(Partner_Prospect__c pp : prospectList){
            ppIds.add(pp.Id);
        }
        List<Approval.ProcessWorkitemRequest> reqs = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem piwi : [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                            FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :ppIds]) 
        {
            System.debug('--PartnerOnboardingUtility--recallApproval--piwi--' + piwi);
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Removed');
            req.setWorkitemId(piwi.Id);
            reqs.add(req);
        }
        System.debug('--PartnerOnboardingUtility--recallApproval--reqs--'+reqs);
        if(!reqs.isEmpty()) {
            Approval.process(reqs);
        }
    }*/
    
    public class ContactRequestWrapper {
        public String FirstName;
        public String LastName;
        Public String Email;
        Public String organization;
        Public ID accountId;
        Public ID contactId;
        Public String partner_role;
        Public String account_Type;
        Public String oktaId;
        Public String groupid;
        ContactRequestWrapper(Contact con){
            this.FirstName = con.FirstName;
            this.LastName = con.LastName;
            this.Email = con.Email;
            this.organization = con.AccountName__c;
            this.accountId = con.AccountId;
            this.contactId = con.Id;
            this.partner_role = 'Other';
            this.account_Type = 'Partner';
            this.oktaId = con.OKTA_User_ID__c;
            this.groupid = System.label.ImpartnerPartnerPortalGroupId;
        }
    }
    //IBA-6228 End
    
    public class PartnerOnboardingException extends Exception {}
}