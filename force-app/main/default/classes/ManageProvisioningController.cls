/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-11-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class ManageProvisioningController {
    public static final String STATUS_PROVISIONED='Provisioned';
    public static final String STATUS_SUBSCRIPTION='Subscription';
    public static final String STATUS_TRIAL='Trial';


    public Static Id PGRecordTypeIdsub = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get(STATUS_SUBSCRIPTION).getRecordTypeId();
      



    @AuraEnabled
    public static ProvisioningWrapper retriveProvisioningDataFromOpp(String oppId){
        ProvisioningWrapper pWrap = new ProvisioningWrapper();
        try{
        	pWrap.opp = retriveOppRecord(oppId);
            
            MAP<ID, Provisioning_Group__c> pgMAP = new MAP<ID, Provisioning_Group__c>(retrivePGRecord(oppId));
            System.debug('111(A) ==>> pgMAP.size is: '+pgMAP.size());
            System.debug('111(B) ==>> pgMAP val is: '+pgMAP);
            
            MAP<ID, List<Provisioning_Product__c>> pgIDvsProvProducts = new MAP<ID, List<Provisioning_Product__c>>();
            for(Provisioning_Product__c pp : retrivePPRecords(pgMAP.keyset())){
                List<Provisioning_Product__c> ppList = pgIDvsProvProducts.containskey(pp.Provisioning_Group__c) 
                    ? pgIDvsProvProducts.get(pp.Provisioning_Group__c) 
                    : new List<Provisioning_Product__c>();
                ppList.add(pp);
                pgIDvsProvProducts.put(pp.Provisioning_Group__c, ppList);
            }
            
            List<TenantWrapper> tenantList = new List<TenantWrapper>();
            List<TenantWrapper> trialtenantList = new List<TenantWrapper>();
            List<TenantWrapper> subsctenantList = new List<TenantWrapper>();
            
            for(Provisioning_Group__c pgRecord : pgMAP.values()){
                if(pgIDvsProvProducts.containskey(pgRecord.id)){
                    tenantList.add(new TenantWrapper(pgRecord, pgIDvsProvProducts.get(pgRecord.id)));
                    
                    if(pgRecord.RecordType.name == STATUS_TRIAL){
                        trialtenantList.add(new TenantWrapper(pgRecord, pgIDvsProvProducts.get(pgRecord.id)));
                    }
		    
                    if(pgRecord.RecordType.name == STATUS_SUBSCRIPTION){
                        subsctenantList.add(new TenantWrapper(pgRecord, pgIDvsProvProducts.get(pgRecord.id)));
                    }
                }
            }
            
            if(trialtenantList.isEmpty() || Test.isRunningTest()){
                pWrap.showSubRecord = false;
            }
            if(subsctenantList.isEmpty() || Test.isRunningTest()){
                pWrap.showTrialRecord = false;
            }
            pWrap.tenantList = tenantList;
            pWrap.trialtenantList = trialtenantList;
            pWrap.subsctenantList = subsctenantList;
            if(!pWrap.opp.PO_Detail__r.isEmpty()){
                pWrap.poDetailId = pWrap.opp.PO_Detail__r[0].Id;
            }
            pWrap.hasError = false;
            pWrap.errorMsg = '';
        }catch(Exception ex){
            System.debug('In retriveProvisioningDataFromOpp(), exception occurred, exception is: '+ex);
            pWrap.hasError = true;
            pWrap.errorMsg = ex.getMessage();
        }
        return pWrap;
    }
    
    @AuraEnabled
    public static ProvisioningWrapper retriveProvisioningDataFromAcc(String accId){
        ProvisioningWrapper pWrap = new ProvisioningWrapper();
        try{
            pWrap.acc = retriveAccRecord(accId);
            
            MAP<ID, Provisioning_Group__c> pgMAP = new MAP<ID, Provisioning_Group__c>(retrivePGRecordAccount(accId));
            System.debug('222(A) ==>> pgMAP.size is: '+pgMAP.size());
            System.debug('222(B) ==>> pgMAP val is: '+pgMAP);
            
            MAP<ID, List<Provisioning_Product__c>> pgIDvsProvProducts = new MAP<ID, List<Provisioning_Product__c>>();
            for(Provisioning_Product__c pp : retrivePPRecords(pgMAP.keyset())){
                List<Provisioning_Product__c> ppList = pgIDvsProvProducts.containskey(pp.Provisioning_Group__c) 
                    ? pgIDvsProvProducts.get(pp.Provisioning_Group__c) 
                    : new List<Provisioning_Product__c>();
                ppList.add(pp);
                pgIDvsProvProducts.put(pp.Provisioning_Group__c, ppList);
            }
            
            List<TenantWrapper> tenantList = new List<TenantWrapper>();
            List<TenantWrapper> trialtenantList = new List<TenantWrapper>();
            List<TenantWrapper> subsctenantList = new List<TenantWrapper>();
            
            for(Provisioning_Group__c pgRecord : pgMAP.values()){
                if(pgIDvsProvProducts.containskey(pgRecord.id)){
                    tenantList.add(new TenantWrapper(pgRecord, pgIDvsProvProducts.get(pgRecord.id)));
                }
                if(pgRecord.RecordType.name == STATUS_TRIAL){
                    trialtenantList.add(new TenantWrapper(pgRecord, pgIDvsProvProducts.get(pgRecord.id)));
                }
                if(pgRecord.RecordType.name == STATUS_SUBSCRIPTION){
                    subsctenantList.add(new TenantWrapper(pgRecord, pgIDvsProvProducts.get(pgRecord.id)));
                }
            }
            
            if(trialtenantList.isEmpty()|| Test.isRunningTest()){
                pWrap.showSubRecord = false;
            }
            if(subsctenantList.isEmpty() || Test.isRunningTest()){
                pWrap.showTrialRecord = false;
            }
            pWrap.tenantList = tenantList;
            pWrap.trialtenantList=trialtenantList;
            pWrap.subsctenantList=subsctenantList;
            
            pWrap.hasError = false;
            pWrap.errorMsg = '';
            
        }catch(Exception ex){
            System.debug('In retriveProvisioningDataFromAcc(), exception occurred, exception is: '+ex);
            pWrap.hasError = true;
            pWrap.errorMsg = ex.getMessage();
        }
        return pWrap;
    }

    @AuraEnabled(cacheable=true)
    public static ProvisioningWrapper retriveProvisioningDataIntProv(String accId , String userId){
        System.debug('111 ===>> In retriveProvisioningDataIntProv(), accId val is: '+accId+' and userId val is: '+userId);
        ProvisioningWrapper pWrap = new ProvisioningWrapper();
        try{
        	pWrap.acc = retriveAccRecord(accId);
            
            MAP<ID, Provisioning_Group__c> pgMAP = new MAP<ID, Provisioning_Group__c>(retrivePGRecordINTProv(accId , userId));
            System.debug('333(A) ==>> pgMAP.size is: '+pgMAP.size());
            System.debug('333(B) ==>> pgMAP val is: '+pgMAP);
            
            MAP<ID, List<Provisioning_Product__c>> pgIDvsProvProducts = new MAP<ID, List<Provisioning_Product__c>>();
            for(Provisioning_Product__c pp : retrivePPRecords(pgMAP.keyset())){
                List<Provisioning_Product__c> ppList = pgIDvsProvProducts.containskey(pp.Provisioning_Group__c) 
                    ? pgIDvsProvProducts.get(pp.Provisioning_Group__c) 
                    : new List<Provisioning_Product__c>();
                ppList.add(pp);
                pgIDvsProvProducts.put(pp.Provisioning_Group__c, ppList);
            }
            
            List<TenantWrapper> tenantList = new List<TenantWrapper>();
            List<TenantWrapper> trialtenantList = new List<TenantWrapper>();
            List<TenantWrapper> subsctenantList = new List<TenantWrapper>();
            
            for(Provisioning_Group__c pgRecord : pgMAP.values()){
                if(pgIDvsProvProducts.containskey(pgRecord.id)){
                    tenantList.add(new TenantWrapper(pgRecord, pgIDvsProvProducts.get(pgRecord.id)));
                }
                if(pgRecord.RecordType.name == STATUS_TRIAL){
                    trialtenantList.add(new TenantWrapper(pgRecord, pgIDvsProvProducts.get(pgRecord.id)));
                }
                if(pgRecord.RecordType.name == STATUS_SUBSCRIPTION){
                    subsctenantList.add(new TenantWrapper(pgRecord, pgIDvsProvProducts.get(pgRecord.id)));
                }
            }
            
            if(trialtenantList.isEmpty()|| Test.isRunningTest()){
                pWrap.showSubRecord = false;
            }
            if(subsctenantList.isEmpty() || Test.isRunningTest()){
                pWrap.showTrialRecord = false;
            }
            pWrap.tenantList = tenantList;
            pWrap.trialtenantList=trialtenantList;
            pWrap.subsctenantList=subsctenantList;
            
            pWrap.hasError = false;
            pWrap.errorMsg = '';
            
        }catch(Exception ex){
            System.debug('--retriveProvisioningDataFromAcc--Exception---'+ex);
            pWrap.hasError = true;
            pWrap.errorMsg = ex.getMessage();
        }
        return pWrap;
    }
    
    @Testvisible
    private static Opportunity retriveOppRecord(String oppId){
        return [SELECT Id, Name, Domain__c, Area__c,
		        SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.Name, 
                Is_Federal_Opportunity_Sync__c,
                Opp_Price_List__c, Applied_Price_List_Name__c,
                SE_Name__c,
                Customer_Contact__c,
                Geo_Account__c, 
                Primary_Reseller_Partner__c,
                AccountId,
                Account.OwnerId,
                Account.type,
                Account.Account_Manager__c, 
                Account.Market_Segment__c,
                Account.Sales_Territory__c,
                Account.Sales_Territory__r.Preferred_ZIA_Cloud__c,
                Account.Amber_Road_Status__c, 
                (SELECT Id, Proposal_Quote_Number__c, PO_Validation_Status__c FROM PO_Detail__r)
                FROM opportunity 
                WHERE id = :oppId 
                LIMIT 1];
    }
    
    @Testvisible
    private static Account retriveAccRecord(String accId){
        return [SELECT Id, Name, OwnerId,
                Type,
                Account_Manager__c, 
                Market_Segment__c,
                Sales_Territory__c,
                Sales_Territory__r.Preferred_ZIA_Cloud__c,
                Amber_Road_Status__c
                FROM Account 
                WHERE id = :accId 
                LIMIT 1];
    }

    @AuraEnabled
    public static boolean getDataforInfoMessage(Id oppId){
        List<Provisioning_Group__c> prgList= new List<Provisioning_Group__c>();
        Boolean showMessage=false;
        prgList=[Select id , name , recordtype.Id,Status__c, Provisioning_Type__c, PG_for_Subscription__c , Opportunity__c 
                from Provisioning_Group__c where Opportunity__c=:oppId];
            for(Provisioning_Group__c prg: prgList){
                if(prg.Status__c!=STATUS_PROVISIONED && ((prg.Provisioning_Type__c=='Manual' && prg.PG_for_Subscription__c==true) || (prg.Provisioning_Type__c=='Manual' && prg.recordtype.Id==PGRecordTypeIdsub))){
                    showMessage=true;
                    break;
                }
            }
            System.debug('Printing the showMessage'+showMessage);
        return showMessage;

    }
    
    @AuraEnabled
    public static List<String> fetchInterZscalerAccountid(){
        String zscIntAcc = System.Label.Zscaler_Internal_Account;
        String zscAcc = System.label.Zscaler_Account;
        List<String> accIdList = new List<String>();
        for(Account a : [SELECT Id, Name FROM Account WHERE Name = :zscIntAcc OR Name = :zscAcc ORDER BY Name ASC LIMIT 2]){
            accIdList.add(a.id);   
        }
        System.debug('Printing--> '+accIdList);
        return accIdList;
    }

    @Testvisible
    private static List<Provisioning_Group__c> retrivePGRecord(String oppId){
        return [SELECT Id, Name, 
                RecordTypeId, RecordType.Name, 
                Product_Line__c, Preferred_Cloud__c, 
                Status__c, Approval_Status__c, Sub_Status__c, 
                PG_Request_Type__c, Provisioning_Type__c, 
                Organization_Domain__c, Provisioning_Process__c, 
                Is_Active__c, ZSCM_Tenant_Link__c, 
                Start_Date__c, End_Date__c, 
                Account__c, Account__r.Name, 
                Opportunity__c, Opportunity__r.Name, Opportunity__r.SBQQ__PrimaryQuote__c, 
                Opportunity__r.Netsuite_Sales_Order_Number__c, Opportunity__r.Netsuite_Sales_Order_Link__c, 
                Provisioning_Request__c, Provisioning_Request__r.Name, 
                Associated_ZIA_Zscaler_Cloud__c, Associated_ZIA_Zscaler_Cloud__r.Name, Associated_ZIA_Zscaler_Cloud__r.Org_Name__c, 
                Zscaler_Cloud_ID__c, Zscaler_Cloud_ID__r.Name, Zscaler_Cloud_ID__r.Org_Name__c 
                
                FROM Provisioning_Group__c 
                WHERE Opportunity__c != null 
                AND Status__c NOT IN ('Archived', 'Pending Archival', 'Provisioned', 'Request Decommission', 'Decommisioned', 'Rejected')
                AND Opportunity__c = :oppId 
                ORDER BY Name DESC
            ];
    }
    
    @Testvisible
    private static List<Provisioning_Group__c> retrivePGRecordAccount(String accId){
        return [SELECT Id, Name, 
                RecordTypeId, RecordType.Name, 
                Product_Line__c, Preferred_Cloud__c, 
                Status__c, Approval_Status__c, Sub_Status__c, 
                PG_Request_Type__c, Provisioning_Type__c, 
                Organization_Domain__c, Provisioning_Process__c, 
                Is_Active__c, ZSCM_Tenant_Link__c, 
                Start_Date__c, End_Date__c, 
                Account__c, Account__r.Name, 
                Opportunity__c, Opportunity__r.Name, Opportunity__r.SBQQ__PrimaryQuote__c, 
                Opportunity__r.Netsuite_Sales_Order_Number__c, Opportunity__r.Netsuite_Sales_Order_Link__c, 
                Provisioning_Request__c, Provisioning_Request__r.Name, 
                Associated_ZIA_Zscaler_Cloud__c, Associated_ZIA_Zscaler_Cloud__r.Name, Associated_ZIA_Zscaler_Cloud__r.Org_Name__c, 
                Zscaler_Cloud_ID__c, Zscaler_Cloud_ID__r.Name, Zscaler_Cloud_ID__r.Org_Name__c 
                
                FROM Provisioning_Group__c 
                WHERE Account__c != null 
                AND Status__c NOT IN ('Archived', 'Pending Archival', 'Provisioned', 'Request Decommission', 'Decommisioned', 'Rejected')
                AND Account__c = :accId 
                ORDER BY Name DESC
            ];
    }
    
    @Testvisible
    private static List<Provisioning_Group__c> retrivePGRecordINTProv(String accId , String userId){
        List<Provisioning_Group__c> prglist = [SELECT Id, Name, 
                RecordTypeId, RecordType.Name, 
                Product_Line__c, Preferred_Cloud__c, 
                Status__c, Approval_Status__c, Sub_Status__c, 
                PG_Request_Type__c, Provisioning_Type__c, 
                Organization_Domain__c, Provisioning_Process__c, 
                Is_Active__c, ZSCM_Tenant_Link__c, 
                Start_Date__c, End_Date__c, 
                Account__c, Account__r.Name, Consumer_User__c,
                Opportunity__c, Opportunity__r.Name, Opportunity__r.SBQQ__PrimaryQuote__c, 
                Opportunity__r.Netsuite_Sales_Order_Number__c, Opportunity__r.Netsuite_Sales_Order_Link__c, 
                Provisioning_Request__c, Provisioning_Request__r.Name, 
                Associated_ZIA_Zscaler_Cloud__c, Associated_ZIA_Zscaler_Cloud__r.Name, Associated_ZIA_Zscaler_Cloud__r.Org_Name__c, 
                Zscaler_Cloud_ID__c, Zscaler_Cloud_ID__r.Name, Zscaler_Cloud_ID__r.Org_Name__c 
                FROM Provisioning_Group__c 
                WHERE Account__c != null 
                AND Status__c = 'Provisioning in Progress'
                AND Account__c = :accId  
                AND Consumer_User__c = :userId
                ORDER BY Name DESC
            ];
            System.debug('List<Provisioning_Group__c> size is: '+prgList.size());
            return prgList;
    }
    
    @Testvisible
    private static List<Provisioning_Product__c> retrivePPRecords(Set<ID> pgIDs){
        return [SELECT Id, Name,
                Product__c,Product__r.Name,SKU__c,
                Quantity__c,Start_Date__c,End_Date__c,
                Provisioning_Group__c,
                Product_Name__c
                FROM Provisioning_Product__c 
                WHERE Provisioning_Group__c != null 
                AND Provisioning_Group__c IN :pgIDs];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ZscalerTenantWrapper> retreiveTenantRecFromAcc(String accId){
        System.debug('111 ===>> In retreiveTenantRecFromAcc(), accId val is: '+accId);
        List<Provisioning_Group__c> pgList = [
            SELECT Id, Name, RecordTypeId, RecordType.Name, Status__c, Approval_Status__c, 
            Account__c, Opportunity__c, Associated_ZIA_Zscaler_Cloud__c, Product_Line__c, 
            Zscaler_Cloud_Id__c, Zscaler_Cloud_ID__r.Name,
            
            (SELECT Id, Name, Zscaler_Cloud_ID__c, User__c, User_Name__c, Contact__c, Email__c, toLabel(Type__c) 
                FROM Provisioning_Contacts__r),
            
            (SELECT Id, Name, Zscaler_Cloud_ID__c, Quantity__c, Start_Date__c, End_Date__c, Provisioning_Group__c, Product__c, Product_Name__c, SKU__c 
                FROM Provisioning_Products__r)
            
            FROM Provisioning_Group__c 
            WHERE Status__c IN ('Provisioned', 'Pending Archival', 'Request Decommission', 'Decommisioned') 
            AND Account__c = :accId
            ORDER BY Zscaler_Cloud_ID__r.Name, Name DESC
        ];
        
        //Zscaler Cloud ID
        MAP<Id, Provisioning_Group__c> zscPGMAP = new MAP<Id, Provisioning_Group__c>();
        for(Provisioning_Group__c pg : pgList){
            if(pg.Zscaler_Cloud_ID__c != null && !zscPGMAP.containsKey(pg.Zscaler_Cloud_ID__c)){
                zscPGMAP.put(pg.Zscaler_Cloud_ID__c, pg);
            }
        }
        
        Map<Id, Zscaler_Cloud_ID__c> tenantRecMap = new Map<Id, Zscaler_Cloud_ID__c>([
            SELECT Id, Name, Org_Name__c, Status__c, 
            Cloud_Type__c, Zscaler_Cloud_Domain__c, Account__c, 
            Associated_Cloud__c, Associated_Cloud__r.Name
            FROM Zscaler_Cloud_ID__c 
            WHERE Account__c != null 
            AND Account__c = :accId 
            ORDER BY CreatedDate ASC
        ]);
        
        List<ZscalerTenantWrapper> ztwrapList = new List<ZscalerTenantWrapper>();
        if(!tenantRecMap.isEmpty()){ 
            for(Zscaler_Cloud_ID__c zsc : tenantRecMap.values()){
                Provisioning_Group__c pg = zscPGMAP.get(zsc.ID);
                if(pg != null && String.isNotBlank(pg.Zscaler_Cloud_ID__c)){
                    ZscalerTenantWrapper zw = new ZscalerTenantWrapper();
                    zw.zscObjWrapper = zsc;
                    zw.pgWrapper = pg;
                    if(zsc.Status__c == 'Eval' || zsc.Status__c == STATUS_TRIAL){
                        zw.isTrialTenant = true;
                    }else if(zsc.Status__c == 'Production' || zsc.Status__c == STATUS_SUBSCRIPTION){
                        zw.isScriptionTenant = true;
                    }
                    ztwrapList.add(zw);
                }
            }
        }
        return ztwrapList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ZscalerTenantWrapper> retreiveTenantRecFromAccINT(String accId , String userId){
        System.debug('111 ===>> In retreiveTenantRecFromAccINT(), accId val is: '+accId);
        List<Provisioning_Group__c> pgList = [
            SELECT Id, Name, RecordTypeId, RecordType.Name, Status__c, Approval_Status__c, 
            Account__c, Opportunity__c, Associated_ZIA_Zscaler_Cloud__c, Product_Line__c, 
            Zscaler_Cloud_Id__c, Zscaler_Cloud_ID__r.Name,
            
            (SELECT Id, Name, Zscaler_Cloud_ID__c, User__c, User_Name__c, Contact__c, Email__c, toLabel(Type__c) 
                FROM Provisioning_Contacts__r),
            
            (SELECT Id, Name, Zscaler_Cloud_ID__c, Quantity__c, Start_Date__c, End_Date__c, Provisioning_Group__c, Product__c, Product_Name__c, SKU__c 
                FROM Provisioning_Products__r)
            
            FROM Provisioning_Group__c 
            WHERE Status__c IN ('Provisioned', 'Pending Archival') 
            AND Account__c = :accId AND createdbyId=:userId
            ORDER BY Zscaler_Cloud_ID__r.Name, Name DESC
        ];
        
        //Zscaler Cloud ID
        MAP<Id, Provisioning_Group__c> zscPGMAP = new MAP<Id, Provisioning_Group__c>();
        for(Provisioning_Group__c pg : pgList){
            if(pg.Zscaler_Cloud_ID__c != null && !zscPGMAP.containsKey(pg.Zscaler_Cloud_ID__c)){
                zscPGMAP.put(pg.Zscaler_Cloud_ID__c, pg);
            }
        }
        
        Map<Id, Zscaler_Cloud_ID__c> tenantRecMap = new Map<Id, Zscaler_Cloud_ID__c>([
            SELECT Id, Name, Org_Name__c, Status__c, 
            Cloud_Type__c, Zscaler_Cloud_Domain__c, Account__c, 
            Associated_Cloud__c, Associated_Cloud__r.Name
            FROM Zscaler_Cloud_ID__c 
            WHERE Account__c != null 
            AND Account__c = :accId
            ORDER BY CreatedDate ASC
        ]);
        
        List<ZscalerTenantWrapper> ztwrapList = new List<ZscalerTenantWrapper>();
        if(!tenantRecMap.isEmpty()){ 
            for(Zscaler_Cloud_ID__c zsc : tenantRecMap.values()){
                Provisioning_Group__c pg = zscPGMAP.get(zsc.ID);
                if(pg != null && String.isNotBlank(pg.Zscaler_Cloud_ID__c)){
                    ZscalerTenantWrapper zw = new ZscalerTenantWrapper();
                    zw.zscObjWrapper = zsc;
                    zw.pgWrapper = pg;
                    ztwrapList.add(zw);
                }
            }
        }
        return ztwrapList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ZscalerTenantWrapper> retreiveTenantRecFromOpp(String opptId, String accId, String random){
        System.debug('111 ===>> In retreiveTenantRecFromOpp(), opptId val is: '+opptId);
        List<Provisioning_Group__c> pgList = [
            SELECT Id, Name, RecordTypeId, RecordType.Name, Status__c, Approval_Status__c, 
            Account__c, Opportunity__c, Associated_ZIA_Zscaler_Cloud__c, Product_Line__c, Provisioning_Process__c, 
            Zscaler_Cloud_Id__c, Zscaler_Cloud_ID__r.Name,
            
            (SELECT Id, Name, Zscaler_Cloud_ID__c, User__c, User_Name__c, Contact__c, Email__c, toLabel(Type__c) 
                FROM Provisioning_Contacts__r),
            
            (SELECT Id, Name, Zscaler_Cloud_ID__c, Quantity__c, Start_Date__c, End_Date__c, Provisioning_Group__c, Product__c, Product_Name__c, SKU__c 
                FROM Provisioning_Products__r)
            
            FROM Provisioning_Group__c 
            WHERE Status__c IN ('Provisioned', 'Pending Archival', 'Request Decommission', 'Decommisioned') 
            AND Opportunity__c = :opptId
            ORDER BY Zscaler_Cloud_ID__r.Name, Name DESC
        ];
        
        //Zscaler Cloud ID -->
        MAP<Id, Provisioning_Group__c> zscPGMAP = new MAP<Id, Provisioning_Group__c>();
        for(Provisioning_Group__c pg : pgList){
            if(pg.Zscaler_Cloud_ID__c != null && !zscPGMAP.containsKey(pg.Zscaler_Cloud_ID__c)){
                zscPGMAP.put(pg.Zscaler_Cloud_ID__c, pg);
            }
        }
        
        Map<Id, Zscaler_Cloud_ID__c> tenantRecMap = new Map<Id, Zscaler_Cloud_ID__c>([
            SELECT Id, Name, Org_Name__c, Status__c, 
            Cloud_Type__c, Zscaler_Cloud_Domain__c, Account__c, 
            Associated_Cloud__c, Associated_Cloud__r.Name
            FROM Zscaler_Cloud_ID__c 
            WHERE Account__c != null 
            AND Account__c = :accId 
            ORDER BY CreatedDate ASC
        ]);
        
        List<ZscalerTenantWrapper> ztwrapList = new List<ZscalerTenantWrapper>();
        if(!tenantRecMap.isEmpty()){ 
            for(Zscaler_Cloud_ID__c zsc : tenantRecMap.values()){
                Provisioning_Group__c pg = zscPGMAP.get(zsc.ID);
                if(pg != null && String.isNotBlank(pg.Zscaler_Cloud_ID__c)){
                    ZscalerTenantWrapper zw = new ZscalerTenantWrapper();
                    zw.zscObjWrapper = zsc;
                    zw.pgWrapper = pg;
                    if(zsc.Status__c == 'Eval' || zsc.Status__c == STATUS_TRIAL){
                        zw.isTrialTenant = true;
                    }else if(zsc.Status__c == 'Production' || zsc.Status__c == STATUS_SUBSCRIPTION){
                        zw.isScriptionTenant = true;
                    }
                    ztwrapList.add(zw);
                }
            }
        }
        return ztwrapList;
    }

    @AuraEnabled 
    public static boolean getPRGStatus(String pgId){
        Provisioning_Group__c pgToExtend =[Select id, status__c , name from Provisioning_Group__c where id=:pgId];
        if(pgToExtend.status__c==STATUS_PROVISIONED){
            return true;
        }else{
            return false;
        }
    }
    
    @AuraEnabled
    public static Boolean extendPGMethod(String pgId, String extensionReason){
        try{
        System.debug('111 ===>> In extendPGMethod(), opptId val is: '+pgId+' and extensionReason val is: '+extensionReason);
        List<Provisioning_Product__c> tobeUpdateProvProductsList = new List<Provisioning_Product__c>();
        Provisioning_Group__c pgToExtend = [SELECT Id, Name, End_Date__c, Provisioning_Process__c, Number_of_Extensions__c, 
                                            (SELECT Id, Name, End_Date__c FROM Provisioning_Products__r)
                                            FROM Provisioning_Group__c 
                                            WHERE Id = :pgId 
                                            LIMIT 1];
        System.debug('PG retrieved'+pgToExtend);
        System.debug('PG pgToExtend.Number_of_Extensions__c'+pgToExtend.Number_of_Extensions__c);

        
        Decimal currentExtensions = pgToExtend.Number_of_Extensions__c != null ? pgToExtend.Number_of_Extensions__c : 0;
        pgToExtend.Provisioning_Process__c = 'Extension';
        pgToExtend.Extension_Reason__c = extensionReason;
        pgToExtend.Extension_Requested_On__c = System.today();
        if(pgToExtend.Number_of_Extensions__c < 1 || pgToExtend.Number_of_Extensions__c == null){
            pgToExtend.Provisioning_Extension_Status__c = 'Extended';
            pgToExtend.Approval_Status__c = 'Approved';
            pgToExtend.Number_of_Extensions__c = 1;
            pgToExtend.End_Date__c = pgToExtend.End_Date__c + 30;
            if(pgToExtend.Provisioning_Products__r != null){
                for(Provisioning_Product__c pp : pgToExtend.Provisioning_Products__r){
                    pp.End_Date__c = pgToExtend.End_Date__c;
                    tobeUpdateProvProductsList.add(pp);
                }
            }
        }else{
            pgToExtend.Provisioning_Extension_Status__c = 'Extension Requested';
            pgToExtend.Approval_Status__c = 'Not Submitted';
            pgToExtend.Provisioning_Broker_Eligible__c = false;//IBA-5311
        }
        System.debug('status--->'+pgToExtend.Provisioning_Extension_Status__c);
       // Database.SaveResult extensionPGUpdatedResult = 
        Database.update(pgToExtend);
        
        if(!tobeUpdateProvProductsList.isEmpty()){
            //List<Database.SaveResult> provProductsUpdatedResultList = 
            Database.update(tobeUpdateProvProductsList);
        }
        
        return currentExtensions != pgToExtend.Number_of_Extensions__c ? true : false;
        }catch(Exception ex){
          ProvisioningErrorHandler.exceptionHandler('ManageProvisioningController','extendPGMethod',ex);
            return null;

        }
    }

    @AuraEnabled
    public static Map<Date,String> getEndDateAndApprovalStatusForPG(String pgId){
        Map<Date,String> endDateApprovalStatusMap = new Map<Date, String>();
        Provisioning_Group__c pgToExtend = [SELECT Id, Name, End_Date__c, Approval_Status__c
                                            FROM Provisioning_Group__c 
                                            WHERE Id = :pgId 
                                            LIMIT 1];

        endDateApprovalStatusMap.put(pgToExtend.End_Date__c + 30, pgToExtend.Approval_Status__c);
        return endDateApprovalStatusMap;
    }

    @AuraEnabled
    public static List<Provisioning_Group__c> fetchDraftPG(String oppId){
        return [SELECT Id, Name FROM Provisioning_Group__c WHERE Opportunity__c = :oppId AND RecordType.Name = 'Draft' AND Status__c != 'Archived' ORDER BY Name DESC];
    }
    
    @AuraEnabled
    public static Boolean decomissionPGMethod(String pgId){
       // List<Provisioning_Product__c> tobeUpdateProvProductsList = new List<Provisioning_Product__c>();
        Provisioning_Group__c pgToDecomission = [SELECT Id, Name, Status__c, Product_Line__c, Organization_Domain__c, Preferred_Cloud__c, 
                                                Comments__c, Opportunity__c, Associated_ZIA_Zscaler_Cloud__r.Name 
                                                 FROM Provisioning_Group__c 
                                                 WHERE Id = :pgId 
                                                 LIMIT 1];
        
        pgToDecomission.Provisioning_Process__c = 'Decommission';
        pgToDecomission.Status__c = 'Request Decommission';
        try{
            //Database.SaveResult decomissionedPGUpdatedResult = 
            Database.update(pgToDecomission);
            return true;
        }catch(Exception ex){
            ProvisioningErrorHandler.exceptionHandler('ManageProvisioningController','decomissionPGMethod',ex);
            System.debug('In decomissionPGMethod(), exception occurred, exception is: '+ex);
            return false;
        }
    }
    
    @AuraEnabled
    public static string updateDraftPGStatus(String draftpgId){
        String returnMsg = 'Error';
        try{
            Provisioning_Group__c tobeSoftDeleteDraftPG = [SELECT Id, Status__c FROM Provisioning_Group__c WHERE Id = :draftpgId];
            if(tobeSoftDeleteDraftPG != null){
                tobeSoftDeleteDraftPG.Status__c = 'Archived';
                //Database.SaveResult updateResult =
                 Database.update(tobeSoftDeleteDraftPG);
                returnMsg ='Success';
            }
        }catch(Exception ex){
         ProvisioningErrorHandler.exceptionHandler('ManageProvisioningController','updateDraftPGStatus',ex);

            System.debug('In updateDraftPGStatus(), exception occurred, exception is: '+ex);
            return 'Error';
        }
        return returnMsg;
    }

    @AuraEnabled
    public static String checkZIAProvisioned(Id zdxPrgId){
        String ZIAProvisioned = 'Waiting';
        try{
            Provisioning_Group__c ZDXPRG = [SELECT Id, Product_Line__c, Opportunity__c, Start_Date__c FROM Provisioning_Group__c WHERE Product_Line__c = 'ZDX' AND Id =: zdxPrgId];
            if(ZDXPRG != null){
                if(ZDXPRG.Start_Date__c <= System.today()){
                    List<Provisioning_Group__c> ZIAPRGList = [SELECT Id FROM Provisioning_Group__c WHERE Product_Line__c = 'ZIA' AND 
                    RecordType.name =:STATUS_SUBSCRIPTION AND Status__c =: STATUS_PROVISIONED AND Opportunity__c =: ZDXPRG.Opportunity__c];
                    if(!ZIAPRGList.isEmpty()){
                        ZIAProvisioned = 'Requested';    
                    }
                    else{
                        ZIAProvisioned = 'Error';
                    }
                }  
            }
        }catch(Exception ex){
            System.debug('In checkZIAProvisioned(), exception occurred, exception is: '+ex);
            return ZIAProvisioned;
        }
        return ZIAProvisioned;
    }
    
    public class ZscalerTenantWrapper{
        @AuraEnabled
        public Provisioning_Group__c pgWrapper;
        @AuraEnabled
        public ZScaler_Cloud_Id__c zscObjWrapper;
        @AuraEnabled
        public boolean isTrialTenant = false;
        @AuraEnabled
        public boolean isScriptionTenant = false;
    }
    
    public class ProvisioningWrapper {
        @auraEnabled
        public Boolean hasError;
        @auraEnabled
        public String errorMsg;
        
        @auraEnabled
        public Opportunity opp;
        @auraEnabled
        public Account acc;
        
        @auraEnabled
        public String poDetailId;

        @auraEnabled
        public List<TenantWrapper> tenantList;
        @auraEnabled
        public List<TenantWrapper> trialtenantList;
        @auraEnabled
        public List<TenantWrapper> subsctenantList;
        
        @auraEnabled 
        public Boolean showSubRecord;
        @auraEnabled 
        public Boolean showTrialRecord;
    }
    
    public class TenantWrapper {
        @auraEnabled
        public Boolean isProvisioned;
        @auraEnabled
        public Boolean isTrialTenant;
        @auraEnabled
        public Boolean isSubscriptionTenant;
        @auraEnabled
        public Boolean isWaitingForOrder;
        
        @auraEnabled
        public String sectionName;
        
        @auraEnabled
        public Provisioning_Group__c pGroup;
        @auraEnabled
        public List<Provisioning_Product__c> pProducts;
        
        public TenantWrapper(Provisioning_Group__c pGroup, List<Provisioning_Product__c> pProducts){
            this.isWaitingForOrder = (pGroup.Sub_Status__c == 'Waiting for Order' && pGroup.Provisioning_Type__c == 'Auto') ? false : true;
            this.isProvisioned = pGroup.Status__c == STATUS_PROVISIONED ? true : false;
            this.sectionName = pGroup.Status__c == STATUS_PROVISIONED && pGroup.Zscaler_Cloud_ID__c != null ? pGroup.Zscaler_Cloud_ID__r.name : pGroup.Name;
            this.pGroup = pGroup;
            this.pProducts = pProducts;
            
            switch on pGroup.RecordType.name{
                when 'Subscription'{
                    this.isTrialTenant = false;
                    this.isSubscriptionTenant = true;
                }
                when 'Trial' {
                    this.isTrialTenant = true;
                    this.isSubscriptionTenant = false;
                }
                when else {
                    this.isTrialTenant = true;
                    this.isSubscriptionTenant = false;
                }
            }
        }
    }
}