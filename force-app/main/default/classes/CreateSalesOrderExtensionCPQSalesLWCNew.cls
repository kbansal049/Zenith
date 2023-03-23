public without sharing class CreateSalesOrderExtensionCPQSalesLWCNew {
    
    public static List<String> ZIAServiceEdgeSKUs = new List<String>{'ZIA-SVC-EDGE-3' , 'ZIA-SVC-EDGE-5'};
        public static List<String> ZIAVirtualServiceEdgeSKUs = new List<String>{'ZIA-SVC-EDGE-V'};
            public static List<String> equpMentRequest = new List<String>{'ZIA Service Edge', 'ZIA Virtual Service Edge'};
                
                public static List<String> prRequestProdutFamilyList = new List<String>{'Bundle Platforms', 'Zscaler Internet Access', 'Zscaler Private Access', 'Pre SKUs'};
                    public static List<String> prProdutFamilyList = new List<String>{'ZIA', 'ZPA', 'ZDX','ZWS','Workload Protection','Cross Platform'};
                        public static List<String> prProdutSOWList = new List<String>{'ZCES-PRO-SVC', 'ZCES-PRO-SVC-CUST-FED'};
                            
                            
                            
    //Get Valid PG erecord types 
    public static List<String> pgRecodTypeList {
        get{
            if(pgRecodTypeList == null){
                if(Label.Sales_Wizard_PG_RecordTypes != null){
                    return getListFromString(Label.Sales_Wizard_PG_RecordTypes, ',');
                }else{
                    return new List<String>{'Subscription', 'Trial'};
                }
            }
            return pgRecodTypeList;
        }
        set;
    }
    
    //Get Valid PR erecord types 
    public static List<String> prRecodTypeList {
        get{
            if(prRecodTypeList == null){
                if(Label.Sales_Wizard_PR_RecordTypes != null){
                    return getListFromString(Label.Sales_Wizard_PR_RecordTypes, ',');
                }else{
                    return new List<String>{'New_Eval', 'Zscaler_cloud_in_Production','Zscaler_Cloud_Details'};
                        }
            }
            return prRecodTypeList;
        }
        set;
    }
    
    //Get Valid PR erecord types 
    public static List<String> prRecodInvalidStatusList {
        get{
            if(prRecodInvalidStatusList == null){
                if(Label.Sales_Wizard_PR_Invalid_Status != null){
                    return getListFromString(Label.Sales_Wizard_PR_Invalid_Status, ',');
                }else{
                    return new List<String>{'Request Decommission','Archived','Disabled','Provisioning Failed', 'To Be Purged','Decommissioned'};
                        }
            }
            return prRecodInvalidStatusList;
        }
        set;
    }
    
    
    public class PreQCWrapper {
        @auraEnabled
        public Opportunity opp { get; set; }
        @auraEnabled
        public SBQQ__Quote__c primaryQuoteCPQ { get; set; }
        
        @auraEnabled
        public Decimal oppSaleThreshold { get; set; }
        
        @auraEnabled
        public Boolean oppSaleThresholdPassed { get; set; }
        
        @auraEnabled
        public Boolean oppMovedToNext { get; set; }
        
        @auraEnabled
        public Boolean erServiceEdgeNeeded { get; set; }
        @auraEnabled
        public List<Equipment_Request__c> erServiceEdgeList { get; set; }
        
        @auraEnabled
        public Boolean erVirtualServiceEdgeNeeded { get; set; }
        @auraEnabled
        public List<Equipment_Request__c> erVirtualServiceEdgeList { get; set; }
        
        
        @auraEnabled
        public Boolean prRequired { get; set; }
        @auraEnabled
        public MAP<String, List<Provisioning_Group__c>> prMAP { get; set; }
        
        
        
        @auraEnabled
        public Boolean isLegalRequired { get; set; }
        @auraEnabled
        public List<Legal__c> leagalRecList { get; set; }
        
        
        @auraEnabled
        public Boolean isSOWRequired { get; set; }
        @auraEnabled
        public Boolean isSOWAttached { get; set; }
        
        @auraEnabled
        public Boolean isBillingCheckRequired { get; set; }
        @auraEnabled
        public Boolean isBillingDeclarationAttached { get; set; }
        
        @auraEnabled
        public MAP<String,List<Object>> attachedFiles {get; set;}
        
        @auraEnabled
        public Boolean isServiceStartDateEarlierProvisionDate { get; set; }
        
        
        @auraEnabled
        public Boolean isAmberRoadFailed { get; set; }
        
        
        @auraEnabled
        public String ottTicketName { get; set; }
        
        @auraEnabled
        public Boolean nsIntegartionSuccess { get; set; }
        
        @auraEnabled
        public Boolean multipleCloudIdforsameProduct { get; set; }
        
        @auraEnabled
        public Boolean cloudIdAlreadyProvisionedForUpsell { get; set; } //CR#3611
        
        @auraEnabled
        public Map<String, String> tenantsStatusMap { get; set; } //IBA-224

        @auraEnabled
        public Map<String, Decimal> cloudTypeToTotalQtyMap { get; set; } //IBA-224

        @auraEnabled
        public Boolean specialInstructionNotRequired { get; set; } //CR#3611
        
        @auraEnabled
        public String specialInstructionForMultiCloud { get; set; } //CR#3611
        
        @auraEnabled
        public String oppAccountName { get; set; } //CR#3611
        
        @auraEnabled
        public MAP<String, List<String>> cloudTypeCloudListMAP {get; set;} //CR#3611
        
        @auraEnabled
        public MAP<String, List<CloudIdRecsWrapper>> cloudTypeCloudMAP {get; set;} //IBA-224
        
        @auraEnabled
        public PO_Detail__c poDet {get; set;} //EDI

        @auraEnabled    
        public Boolean isPSStartDateRequired { get; set; }
        
        @auraEnabled
        public String accountId {get; set;}
        
        @auraEnabled
        public Boolean isCrossPlatformSelected {get; set;}
        
    }    
    
    
    @auraEnabled
    public static PreQCResultWrapper retrivePreQCDetails(Id opportunityId){
        System.debug('----retrivePreQCDetails---opportunityId--'+opportunityId);
        PreQCResultWrapper prWrap = new PreQCResultWrapper();
        if(opportunityId != null){
            PreQCWrapper pqw = new PreQCWrapper();
            
            
            //Get opportunity Record
            Opportunity opp = getOppRecord(opportunityId);
            System.debug('opp:::::'+opp);
            //get all PR Records
            List<Provisioning_Group__c> allPRList = getALLPGList(opp);
            
            //PS StartDateRequired Check CR#4083
            pqw.isPSStartDateRequired = opp.DAS_Package_New__c != null ? true : false;
            
            //Set opportunity Record
            pqw.opp = opp;
            pqw.primaryQuoteCPQ = opp.SBQQ__PrimaryQuote__r;
            
            pqw.accountId = opp.AccountId;
            pqw.oppAccountName = opp.Account.Name; //CR#3611
            //CR#3611 set multiRecordFields
            pqw.specialInstructionNotRequired = opp.Special_Instructions_Not_Required__c;
            pqw.specialInstructionForMultiCloud = opp.Special_Instructions_for_MultiCloud__c;
            
            pqw.oppSaleThreshold =  decimal.valueOf(label.Threshold_Value_for_Sales_Order_Button); // CR#4833
            pqw.oppSaleThresholdPassed = opp.amount > decimal.valueOf(label.Threshold_Value_for_Sales_Order_Button) ? true :  false;// CR#4833
            
            pqw.erServiceEdgeNeeded  = false;
            pqw.erVirtualServiceEdgeNeeded  = false;
            
            //Set Compliance status
            pqw.isAmberRoadFailed = (opp.account.Amber_Road_Status__c == 'Match' || opp.account.Amber_Road_Status__c == 'Potential Match' ) ? true : false;
            
            //Set NS Integartion status 
            pqw.nsIntegartionSuccess = (opp.Netsuite_Sales_Order_Internal_ID__c != null && opp.NS_Integration_Status__c == 'Success') ? true : false;
            
            
            if((pqw.oppSaleThresholdPassed && opp.StageName == Label.Stage_5A_Opportunity) || (opp.StageName == Label.Stage_6_Closed_Won)){
                pqw.oppMovedToNext = true;
            }else{
                pqw.oppMovedToNext = false;
            }
            
            //isServiceStartDateEarlierProvisionDate
            pqw.isServiceStartDateEarlierProvisionDate = getServiceStartDateEarlierPGProvisionDate(opp,allPRList);
            
            //Billing Check
            if(opp.type == 'Existing Customer (Renewal)'){
                pqw.isBillingCheckRequired = false;                
            }else if(opp.type == 'New Business'){
                pqw.isBillingCheckRequired = getIsBillingCheckRequired(opp);
            }else{
                pqw.isBillingCheckRequired = false;
            }
            pqw.isBillingDeclarationAttached = opp.Declaration_Attached__c;
            pqw.isCrossPlatformSelected = false;
            Set<Id> prodIds = new Set<Id>();
            Set<String> productLinesMissingCloudIds = new Set<String>();
            Set<String> cloudTypeSet = new Set<String>();
            List<SBQQ__QuoteLine__c> qliList = [Select Id,SBQQ__ProductCode__c,SBQQ__Product__c,SBQQ__Product__r.name,SBQQ__Product__r.Product_Line__c,
                                                SBQQ__Product__r.Product_Family__c,SBQQ__Product__r.Zscaler_Product_Family__c,SBQQ__Quantity__c,
                                                SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Number__c, SBQQ__StartDate__c, SBQQ__EndDate__c
                                                from SBQQ__QuoteLine__c where SBQQ__Quote__c != null and SBQQ__Quote__c = :opp.SBQQ__PrimaryQuote__c 
                                                and SBQQ__Product__r.Product_Line__c in :prProdutFamilyList
                                                and SBQQ__RequiredBy__c != null order by SBQQ__Product__r.Product_Line__c, 
                                                SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Number__c, SBQQ__StartDate__c];
                                                //and SBQQ__Product__r.Product_Family__c in : prRequestProdutFamilyList];
            for(SBQQ__QuoteLine__c qli: qliList)
            {   
                if(qli.SBQQ__Product__r.Product_Line__c == 'Cross Platform'){
                    cloudTypeSet.add('ZIA');
                    cloudTypeSet.add('ZPA');
                    cloudTypeSet.add('ZDX');
                    pqw.isCrossPlatformSelected = true;
                }
                cloudTypeSet.add(qli.SBQQ__Product__r.Product_Line__c);
                prodIds.add(qli.SBQQ__Product__c);
            }
            List<Product_License__c> licenseList = new List<Product_License__c>([SELECT ID,License_Product_Line__c,Product__c FROM Product_License__c WHERE Product__c IN: prodIds]);
            Map<Id,String> requiredLicensesMap = new Map<Id,String>();
            Set<String> requiredLicenses = new Set<String>();
            
            Id trialPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();//IBA-399
            MAP<id, Zscaler_Cloud_ID__c> accCloudIds = new MAP<id, Zscaler_Cloud_ID__c>([Select id,Name,Org_Name__c,NS_Org_ID__c,Cloud_Type__c from Zscaler_Cloud_ID__c where Account__c = :opp.AccountId and Cloud_Type__c = :cloudTypeSet]);
            
            MAP<String, List<Zscaler_Cloud_ID__c>> cloudTypeCloudMAP = new  MAP<String, List<Zscaler_Cloud_ID__c>>();
            pqw.cloudTypeCloudListMAP = new  MAP<String, List<String>>();
            for(Zscaler_Cloud_ID__c zsc : accCloudIds.values()){
                if(zsc.Cloud_Type__c != null){
                    List<Zscaler_Cloud_ID__c> zsclIst = cloudTypeCloudMAP.containsKey(zsc.Cloud_Type__c) ? cloudTypeCloudMAP.get(zsc.Cloud_Type__c) : new List<Zscaler_Cloud_ID__c>();
                    List<String> zscNamelIst = pqw.cloudTypeCloudListMAP.containsKey(zsc.Cloud_Type__c) ? pqw.cloudTypeCloudListMAP.get(zsc.Cloud_Type__c) : new List<String>();
                    zsclIst.add(zsc);
                    zscNamelIst.add(zsc.Name);
                    cloudTypeCloudMAP.put(zsc.Cloud_Type__c, zsclIst);
                    pqw.cloudTypeCloudListMAP.put(zsc.Cloud_Type__c, zscNamelIst);
                }
            }
            
            for(Product_License__c pl : licenseList){
                requiredLicensesMap.put(pl.Product__c,pl.License_Product_Line__c);   
            }
            if(requiredLicensesMap != NULL && !requiredLicensesMap.isEmpty()){
                for(string str: requiredLicensesMap.values()){
                    List<string> stringset = str.split(';');
                    requiredLicenses.addAll(stringset);
                }
                for(string str : requiredLicenses){
                    if(!cloudTypeCloudMAP.containsKey(str)) {
                        productLinesMissingCloudIds.add(str);
                    }
                }
            }

            System.debug('---pqw.cloudTypeCloudListMAP: '+ pqw.cloudTypeCloudListMAP);
            
            //Provisioning Request Details
            MAP<String, List<sObject>> quoteLineFamilyMAP = new  MAP<String, List<sObject>>();
            MAP<String, List<Provisioning_Group__c>> zscalrFamilyPRRaised = new  MAP<String, List<Provisioning_Group__c>>();
            
            System.debug('--opp SBQQ__PrimaryQuote__c--'+opp.SBQQ__PrimaryQuote__c);
            if(opp.SBQQ__PrimaryQuote__c != null){
                for(SBQQ__QuoteLine__c qline : qliList)
                {
                    List<sObject> qlineList = quoteLineFamilyMAP.containsKey(qline.SBQQ__Product__r.Product_Line__c)     
                        ?   quoteLineFamilyMAP.get(qline.SBQQ__Product__r.Product_Line__c)  
                        : new List<sObject>();
                    sObject sobj = (sObject) qline;
                    qlineList.add(sobj);
                    quoteLineFamilyMAP.put(qline.SBQQ__Product__r.Product_Line__c, qlineList);
                    
                    if(!cloudTypeCloudMAP.containsKey(qline.SBQQ__Product__r.Product_Line__c)) {
                        productLinesMissingCloudIds.add(qline.SBQQ__Product__r.Product_Line__c);
                    } 
                    
                    zscalrFamilyPRRaised.put(qline.SBQQ__Product__r.Product_Line__c, new List<Provisioning_Group__c>());
                    //pqw.isTenantMissing = !pqw.isTenantMissing && cloudTypeCloudMAP.containsKey(qline.SBQQ__Product__r.Product_Line__c) ? false : true;
                }
            }
            
            System.debug('productLinesMissingCloudIds:::'+productLinesMissingCloudIds);

            
            //System.debug('--quoteLineFamilyMAP--'+quoteLineFamilyMAP.keyset());
            
            MAP<ID, Provisioning_Group__c> cloudPRMAP = new MAP<ID, Provisioning_Group__c>();
            MAP<ID, Provisioning_Group__c> zpaAsZIAPRMAP = new MAP<ID, Provisioning_Group__c>();
            MAP<String, List<Provisioning_Group__c>> prefCloudPRMAP = new MAP<String, List<Provisioning_Group__c>>();
            for(Provisioning_Group__c prReq : allPRList){
                if(prReq.Product_Line__c == 'ZIA' || prReq.Product_Line__c == 'ZPA' || prReq.Product_Line__c == 'Workload Protection'){
                    MAP<Id, Provisioning_Group__c> prMAP = new MAP<Id, Provisioning_Group__c>(
                        zscalrFamilyPRRaised.containsKey(prReq.Product_Line__c) ? 
                        zscalrFamilyPRRaised.get(prReq.Product_Line__c) : 
                        new List<Provisioning_Group__c>()
                    );
                    if(productLinesMissingCloudIds.contains(prReq.Product_Line__c)) {
                        prMAP.put(prReq.id, prReq);
                    }
                    zscalrFamilyPRRaised.put(prReq.Product_Line__c, prMAP.values());
                }
            }
            
            if(opp.Account.Is_Federal_Account_Sync__c || opp.Override_PR_check__c || (opp.Type == 'Existing Customer (Renewal)' && (opp.Split_Type__c == 'No Split'|| opp.Split_Type__c == 'Comp Split'))){
                pqw.prRequired = false;
            } else{
                pqw.prRequired = zscalrFamilyPRRaised.keySet().size() > 0 ? true : false;
            }
            pqw.prMAP = zscalrFamilyPRRaised;
            system.debug('***PRMap**:::'+pqw.prMAP);
            if(!cloudTypeCloudMAP.isEmpty()){
                for(String cloudName : cloudTypeCloudMAP.keySet()){
                    if(cloudTypeCloudMAP.get(cloudName).size()>1){
                        pqw.multipleCloudIdforsameProduct = true;
                        break;
                    }else{
                        pqw.multipleCloudIdforsameProduct = false;
                    }
                }
            }
            //CR#3611 changes for Quote Line to ZScaler Cloud Id check
            System.debug('cloudTypeCloudMAP:::'+cloudTypeCloudMAP);
            System.debug('quoteLineFamilyMAP.keySet():::'+quoteLineFamilyMAP.keySet());
            pqw.cloudIdAlreadyProvisionedForUpsell = false;
            Set<String> crossPlatformSet = new Set<String>{'ZIA','ZPA','ZDX'};
            for(String cloudName: quoteLineFamilyMAP.keySet()){
                if(cloudTypeCloudMAP.containsKey(cloudName) || (cloudName == 'Cross Platform' && cloudTypeCloudMAP.keyset().containsAll(crossPlatformSet))){
                    pqw.cloudIdAlreadyProvisionedForUpsell = true;
                }else{
                    pqw.cloudIdAlreadyProvisionedForUpsell = false;
                    break;
                }
                }
            
            pqw.tenantsStatusMap = new Map<String, String>();

            System.debug('pqw.cloudIdAlreadyProvisionedForUpsell:::'+pqw.cloudIdAlreadyProvisionedForUpsell);
            System.debug('quoteLineFamilyMAP:::'+quoteLineFamilyMAP.keySet());
            for(String cloudName: quoteLineFamilyMAP.keySet()){
                if(cloudTypeCloudMAP.containsKey(cloudName) || (cloudName == 'Cross Platform' && cloudTypeCloudMAP.keyset().containsAll(crossPlatformSet))){
                    pqw.tenantsStatusMap.put(cloudName, 'Green');
                } else {
                    pqw.tenantsStatusMap.put(cloudName, 'Red');
                }
                }
            if(quoteLineFamilyMAP.containsKey('Cross Platform')){
                pqw.tenantsStatusMap.remove('ZIA');
                pqw.tenantsStatusMap.remove('ZPA');
                pqw.tenantsStatusMap.remove('ZDX');  
            }
            System.debug('pqw.tenantsStatusMap:::'+pqw.tenantsStatusMap);
            System.debug('----prRequired---'+pqw.prRequired);
            System.debug('----zscalrFamilyPRRaised---'+zscalrFamilyPRRaised);
            System.debug('----multipleCloudIdforsameProduct---'+pqw.multipleCloudIdforsameProduct);
            
            MAP<String, List<CloudIdRecsWrapper>> cloudIdWrapperList = new  MAP<String, List<CloudIdRecsWrapper>>();
            Map<Id, Provisioning_Group__c> cloudIdToProvGroupMap = new Map<Id, Provisioning_Group__c>();
            Map<String, Decimal> cloudTypeToTotalQtyMap = new Map<String, Decimal>();
            if(pqw.cloudIdAlreadyProvisionedForUpsell == true) {
                System.debug(' inside if:: pqw.cloudIdAlreadyProvisionedForUpsell:::'+pqw.cloudIdAlreadyProvisionedForUpsell);
                Set<Id> prgIds = new Set<Id>();
                Set<String> missingSubscriptionFlagCloudTypes = new Set<String>();
                for(Provisioning_Group__c prReq : allPRList){
                    if(prReq.Zscaler_Cloud_ID__c != null && prReq.status__c == 'Provisioned' && prReq.PG_for_Subscription__c == false) {
                        cloudIdToProvGroupMap.put(prReq.Zscaler_Cloud_ID__c, prReq);
                        missingSubscriptionFlagCloudTypes.add(prReq.Product_Line__c);
                        prgIds.add(prReq.Id);
                    }
                        
                }
                for(Provisioning_Group__c prReq : allPRList){
                    if(prReq.PG_for_Subscription__c == true && (prReq.status__c == 'Provisioned' || prReq.status__c == 'Requested' || prReq.status__c == 'Waiting' || prReq.status__c == 'Provisioning In Progress')){
                        missingSubscriptionFlagCloudTypes.remove(prReq.Product_Line__c);    
                    }
                }
                system.debug('**missingSubscriptionFlagCloudTypes'+missingSubscriptionFlagCloudTypes);
                system.debug('**cloudTypeCloudMAP'+cloudTypeCloudMAP);
                system.debug('**cloudIdToProvGroupMap'+cloudIdToProvGroupMap);
                for(String cloudType: cloudTypeCloudMAP.keySet()) {
                    if(missingSubscriptionFlagCloudTypes.contains(cloudType)) {
                        for(Zscaler_Cloud_ID__c zsc: cloudTypeCloudMAP.get(cloudType)) {
                            System.debug('cloudType1madhu:::'+missingSubscriptionFlagCloudTypes+':::'+zsc.Cloud_Type__c);
                            List<CloudIdRecsWrapper> cloudWrapList = cloudIdWrapperList.containsKey(zsc.Cloud_Type__c) ? cloudIdWrapperList.get(zsc.Cloud_Type__c) : new List<cloudIdRecsWrapper>();
                            cloudIdRecsWrapper cloudIdWrap = new CloudIdRecsWrapper();
                            cloudIdWrap.cloudIdRec         = zsc;
                            cloudIdWrap.applyQuoteQty = false;
                            if(cloudIdToProvGroupMap.get(zsc.Id) != null) {
                                cloudIdWrap.provGroup                   = cloudIdToProvGroupMap.get(zsc.Id);
                                cloudIdWrap.provProdWrapperList         = new  List<provisioningQuoteLinesWrapper>();
                                System.debug('inside if:::');
                                //System.debug('cloudIdToProvGroupMap.get(zsc.Id).Provisioning_Products__r:::'+cloudIdToProvGroupMap.get(zsc.Id).Provisioning_Products__r);
                                //if(cloudIdToProvGroupMap.get(zsc.Id).Provisioning_Products__r != null && cloudIdToProvGroupMap.get(zsc.Id).Provisioning_Products__r.size() > 0) {
                                    
                                    for(SBQQ__QuoteLine__c qli: qliList) {
                                        //System.debug('provProdIdSet:::'+provProdIdSet);
                                        if(quoteLineFamilyMAP.containsKey('Cross Platform') && qli.SBQQ__Product__r.Product_Line__c == 'Cross Platform' && zsc.Cloud_Type__c == 'ZIA'){
                                            provisioningQuoteLinesWrapper qliWrap = new provisioningQuoteLinesWrapper();
                                            qliWrap.qli = qli;
                                            qliWrap.qliTocloudIdKey = qli.Id+' - '+zsc.Id;
                                            qliWrap.remainingQuantity = qli.SBQQ__Quantity__c;
                                            cloudIdWrap.provProdWrapperList.add(qliWrap);    
                                        }
                                        else if(qli.SBQQ__Product__r.Product_Line__c == zsc.Cloud_Type__c && !quoteLineFamilyMAP.containsKey('Cross Platform')) {
                                           System.debug('inside inner if:::');
                                            provisioningQuoteLinesWrapper qliWrap = new provisioningQuoteLinesWrapper();
                                            qliWrap.qli = qli;
                                            qliWrap.qliTocloudIdKey = qli.Id+' - '+zsc.Id;
                                            qliWrap.remainingQuantity = qli.SBQQ__Quantity__c;
                                            cloudIdWrap.provProdWrapperList.add(qliWrap);
                                        }
                                    }
                                //}
                            }
                            if(cloudIdWrap.provProdWrapperList != null && !cloudIdWrap.provProdWrapperList.isEmpty()) {
                                cloudWrapList.add(cloudIdWrap);
                                //System.debug('zsc.Cloud_Type__c:::'+zsc.Cloud_Type__c + ':::::'+cloudWrapList);
                                cloudIdWrapperList.put(zsc.Cloud_Type__c, cloudWrapList); 
                            } 
                        }

                        for(SBQQ__QuoteLine__c qli: qliList) {
                            //System.debug('provProdIdSet:::'+provProdIdSet);
                            if(!quoteLineFamilyMAP.containsKey('Cross Platform') && qli.SBQQ__Product__r.Product_Line__c == cloudType) {
                                if(qli.SBQQ__Product__r.Product_Family__c == 'Bundle Platforms' && qli.SBQQ__Quantity__c != null) {
                                    if(cloudTypeToTotalQtyMap.get(cloudType) == null) {
                                        cloudTypeToTotalQtyMap.put(cloudType, qli.SBQQ__Quantity__c);
                                    } else {
                                        Decimal totQty = cloudTypeToTotalQtyMap.get(cloudType) + qli.SBQQ__Quantity__c;
                                        cloudTypeToTotalQtyMap.put(cloudType, totQty);
                                    }
                                }
                                System.debug('qli.SBQQ__Quantity__c:::'+qli.SBQQ__Quantity__c);
                            }
                            else if(quoteLineFamilyMAP.containsKey('Cross Platform') && qli.SBQQ__Product__r.Product_Line__c == 'Cross Platform' && cloudType == 'ZIA'){
                            	if(qli.SBQQ__Product__r.Product_Family__c == 'Bundle Platforms' && qli.SBQQ__Quantity__c != null) {
                                    if(cloudTypeToTotalQtyMap.get(cloudType) == null) {
                                        cloudTypeToTotalQtyMap.put(cloudType, qli.SBQQ__Quantity__c);
                                    } else {
                                        Decimal totQty = cloudTypeToTotalQtyMap.get(cloudType) + qli.SBQQ__Quantity__c;
                                        cloudTypeToTotalQtyMap.put(cloudType, totQty);
                                    }
                                }    
                            }
                        }
                    }      
                }
            }
            pqw.cloudTypeCloudMAP = cloudIdWrapperList;
            pqw.cloudTypeToTotalQtyMap = cloudTypeToTotalQtyMap;
            SYstem.debug('pqw.cloudTypeToTotalQtyMap:::'+pqw.cloudTypeToTotalQtyMap);
            System.debug('pqw.cloudIdAlreadyProvisionedForUpsell:::'+pqw.cloudIdAlreadyProvisionedForUpsell);
            
            //Equipment Request Details
            System.debug('--opp SBQQ__PrimaryQuote__c--'+opp.SBQQ__PrimaryQuote__c);
            //System.debug('--opp APTS_Primary_Proposal_Lookup__c--'+opp.APTS_Primary_Proposal_Lookup__c);
            
            if(opp.SBQQ__PrimaryQuote__c != null 
               && opp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c == true)
            {
                for(SBQQ__QuoteLine__c qline : [Select Id,SBQQ__ProductCode__c,SBQQ__Product__c from SBQQ__QuoteLine__c 
                                                where SBQQ__Quote__c = :opp.SBQQ__PrimaryQuote__c ])
                {
                    if(qline.SBQQ__ProductCode__c != null){
                        if(ZIAServiceEdgeSKUs.contains(qline.SBQQ__ProductCode__c) ){
                            pqw.erServiceEdgeNeeded  = true;
                        }
                        if(ZIAVirtualServiceEdgeSKUs.contains(qline.SBQQ__ProductCode__c) ){
                            pqw.erVirtualServiceEdgeNeeded  = true;
                        }
                    }
                }
            }
            
            
            System.debug('--pqw erServiceEdgeNeeded--'+pqw.erServiceEdgeNeeded);
            System.debug('--pqw erVirtualServiceEdgeNeeded--'+pqw.erVirtualServiceEdgeNeeded);
            
            
            MAP<String, List<Equipment_Request__c>> equipMap = new MAP<String, List<Equipment_Request__c>>();
            
            for(Equipment_Request__c er : [Select id,Name,Recordtype.Name,Equipment_Type__c,Approval_Status__c from Equipment_Request__c
                                           where Opportunity__c != null and 
                                           Opportunity__c = :opp.id and recordtype.name in :equpMentRequest])
            {
                List<Equipment_Request__c> equipReq = equipMap.containskey(er.recordtype.name) ? equipMap.get(er.recordtype.name) : new List<Equipment_Request__c>();
                equipReq.add(er);
                equipMap.put(er.recordtype.name,equipReq);
            }
            System.debug('----equipMap----'+equipMap);
            
            if(pqw.erServiceEdgeNeeded){
                pqw.erServiceEdgeList = equipMap.get('ZIA Service Edge');
            }
            if(pqw.erVirtualServiceEdgeNeeded){
                pqw.erVirtualServiceEdgeList = equipMap.get('ZIA Virtual Service Edge');
            }
            
            
            
            //Legal Check
            List<Legal__c> leagalRecList = new List<Legal__c>([Select id,Name,Opportunity__c,Contract_Execution_Date__c from Legal__c where Opportunity__c != null and Opportunity__c = :opp.id]);    
            pqw.leagalRecList = leagalRecList;
            pqw.isLegalRequired = leagalRecList != null && leagalRecList.size() > 0 ? true : false;
            System.debug('---isLegalRequired--'+pqw.isLegalRequired);
            System.debug('---leagalRecList--'+leagalRecList);
            
            
            //SOW Check
            pqw.isSOWRequired = getIsSOWRequired(opp);
            pqw.isSOWAttached = opp.SOW_Attached__c;
            System.debug('---isSOWRequired--'+pqw.isSOWRequired);
            System.debug('---isSOWRequired--'+pqw.isSOWAttached);
            
            
            
            //Existing Files
            
            MAP<String,List<Object>> attachedFiles = new MAP<String,List<Object>>();
            
            Set<ID> ContentDocumentIdList = new Set<ID>();
            for (ContentDocumentLink cdl : [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :opp.id]){
                ContentDocumentIdList.add(cdl.ContentDocumentId);
            }
            System.debug('--ContentDocumentIdList--'+ContentDocumentIdList);
            
            for(ContentVersion cv : [SELECT ContentDocumentId,Source_fileupload__c,FileExtension,Title,FileType
                                     FROM ContentVersion WHERE (ContentDocumentId in :ContentDocumentIdList) and Source_fileupload__c != null and IsLatest=true])
            {
                if(cv.Source_fileupload__c != null){
                    
                    List<Object> contentFileList = attachedFiles.containskey(cv.Source_fileupload__c) ? attachedFiles.get(cv.Source_fileupload__c) : new List<Object>();
                    
                    Map<String,String> fileMAP = new Map<String,String>();
                    fileMAP.put('fileId',cv.ContentDocumentId);
                    if((cv.Title).contains((cv.FileType).toLowercase()) || cv.FileType=='UNKNOWN'){
                        fileMAP.put('fileTitle',cv.Title);
                    }else{
                        fileMAP.put('fileTitle',cv.Title + '.' + cv.FileExtension);
                    }
                    contentFileList.add(fileMAP);
                    attachedFiles.put(cv.Source_fileupload__c, contentFileList);
                }
            }
            System.debug('--attachedFiles--'+attachedFiles);
            pqw.attachedFiles = attachedFiles;
            
            
            
            //OTT Record
            String ottTicketName = null;
            for(Order_Tracker__c ott : [Select id,Ticket__c from  Order_Tracker__c where opportunity__c = : opp.id and Status__c not in ('Duplicate') limit 1]){
                ottTicketName = ott.Ticket__c;
            }
            
            pqw.ottTicketName = ottTicketName;
            
            
            //PO Detail
            for(PO_Detail__c podet : [Select id,name from PO_Detail__c where opportunity__c = :opportunityId and  Order_Tracker__r.Status__c not in ('Duplicate') order by createddate desc limit 1] ){
                pqw.poDet = podet;
            }
            
            
            
            prWrap.pqw = pqw;
            prWrap.isSuccess = true;
            prWrap.errMsg = '';            
        }else{
            prWrap.isSuccess = false;
            prWrap.errMsg = 'Invalid Opportunity id has been provided';
        }
        
        return prWrap;
            }    
    
    
    
    @AuraEnabled
    public static void attachPOtoOpportunity(Opportunity opp,List<Map<String, Object>> files, String source){
        System.debug('----CreateSalesOrderExtensionCPQSalesLWC---attachPOtoOpportunity--opp--'+opp);
        System.debug('----CreateSalesOrderExtensionCPQSalesLWC---attachPOtoOpportunity--files--'+files);
        if(files != null && files.size()>0){
            Set<ID> ContentDocumentIdList = new Set<ID>();
            for (ContentDocumentLink cdl : [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :opp.id]){
                ContentDocumentIdList.add(cdl.ContentDocumentId);
            }
            System.debug('--ContentDocumentIdList--'+ContentDocumentIdList);
            
            List<ContentDocumentLink> reAttachTheFiles = new List<ContentDocumentLink>();
            for (Map<String, Object> file : files){
                String fileJson = JSON.serialize(file);
                relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
                if(relatedDocument.fileId != null && !ContentDocumentIdList.contains(relatedDocument.fileId)){
                    reAttachTheFiles.add(new contentDocumentLink(ContentDocumentId = relatedDocument.fileId, LinkedEntityId = opp.id, ShareType = 'I'));
                }
            }
            insert reAttachTheFiles;
            
            Triggerhandler.bypass('OpportunityTriggerHandler');
            if(source == 'PO'){
                opp.PO_Attached__c = true;
                update opp;
            }else if(source == 'SOW'){
                opp.SOW_Attached__c = true;
                update opp;
            }else if(source == 'BILL'){
                opp.Declaration_Attached__c = true;
                update opp;
            }
        }
    }
    
    
    @AuraEnabled
    public static void removePOFromOpportunity(Opportunity opp,Id fileId){
        System.debug('----CreateSalesOrderExtensionCPQSalesLWC---removePOFromOpportunity--opp--'+opp);
        System.debug('----CreateSalesOrderExtensionCPQSalesLWC---removePOFromOpportunity--fileId--'+fileId);
        if(fileId != NULL && opp != null && opp.id != NULL){
            List<ContentDocumentLink> ContentDocumentIdList = new List<ContentDocumentLink>();
            for (ContentDocumentLink cdl : [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :opp.id and  ContentDocumentId = :fileId]){
                ContentDocumentIdList.add(cdl);
            }
            System.debug('--ContentDocumentIdList--'+ContentDocumentIdList);
            delete ContentDocumentIdList;
        }
    }
    
    
    
    @AuraEnabled
    public static void createSalesOrder(id oppID){
        
        //Bypass Opportunity trigger
        Triggerhandler.bypass('OpportunityTriggerHandler');
        
        Opportunity opp = getOppRecord(oppID);
        
        
        if(opp.SBQQ__PrimaryQuote__c != null && opp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c == true)
        {
            CreateSalesOrderExtensionCPQLWC.CustomOrderWrapper cow = CreateSalesOrderExtensionCPQLWC.getCustomOrder(oppID);
            cow.opp.SO_Creation_Date__c = System.Today();
            cow.opp.StageName = Label.Stage_6_Closed_Won;
            cow.opp.SO_Created_by__c = 'Sales Rep';
            CreateSalesOrderExtensionCPQLWC.doSubmit(cow);
        }
        
        try{
            
            //Create OTT Record
            createOTTRecord(oppID);
            
            //Hard Close the Opportunity by creating Contract
            List<Provisioning_Request__c> allPRList = getALLPRList(opp);
            Boolean isServiceStartDateEarlierProvisionDate = getServiceStartDateEarlierProvisionDate(opp,allPRList);
            if(!isServiceStartDateEarlierProvisionDate){
                AcceptOpportunity.acceptOpp(oppID);
            }
        }catch(Exception ex){
            System.debug('----exception ---'+ex.getMessage());
            System.debug('----exception ---'+ex.getLineNumber());
            System.debug('----exception ---'+ex.getStackTraceString());
            throw new AuraHandledException('Create Sales Order failed :'+ ex.getMessage());
        }
        
    }
    
    
    
    //CR# 3887 - Auto Sales Order Creation
    public static void createSalesOrderPODetail(id oppID){
        
        //Bypass Opportunity trigger
        Triggerhandler.bypass('OpportunityTriggerHandler');
        Opportunity opp = getOppRecord(oppID);
        if(opp.SBQQ__PrimaryQuote__c != null && opp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c == true){
            CreateSalesOrderExtensionCPQLWC.CustomOrderWrapper cow = CreateSalesOrderExtensionCPQLWC.getCustomOrder(oppID);
            cow.opp.SO_Creation_Date__c = System.Today();
            cow.opp.StageName = Label.Stage_6_Closed_Won;
            cow.opp.SO_Created_by__c = 'RPA';
            CreateSalesOrderExtensionCPQLWC.doSubmit(cow);
        }
        
        try{
            
            //Create OTT Record
            createOTTRecord(oppID);
            
            //Hard Close the Opportunity by creating Contract
            List<Provisioning_Request__c> allPRList = getALLPRList(opp);
            Boolean isServiceStartDateEarlierProvisionDate = getServiceStartDateEarlierProvisionDate(opp,allPRList);
            if(!isServiceStartDateEarlierProvisionDate){
                AcceptOpportunity.acceptOpp(oppID);
            }
        }catch(Exception ex){
            System.debug('----exception ---'+ex.getMessage());
            System.debug('----exception ---'+ex.getLineNumber());
            System.debug('----exception ---'+ex.getStackTraceString());
            throw new AuraHandledException('Create Sales Order failed :'+ ex.getMessage());
        }
        
    }
    
    
    
    
    @AuraEnabled
    public static void moveOpptoFinance(id oppID){
        try{
            Triggerhandler.bypass('OpportunityTriggerHandler');
            opportunity opp = new opportunity();
            opp.Id = oppID;
            opp.StageName = Label.Stage_5A_Opportunity;
            update opp;
            
            //createOTTRecord(oppID);
        }catch(Exception ex){
            System.debug('----exception ---'+ex.getMessage());
            System.debug('----exception ---'+ex.getLineNumber());
            System.debug('----exception ---'+ex.getStackTraceString());
            throw new AuraHandledException('Error ocurred while moving teh stage :'+ ex.getMessage());
        }
    }
    
    public static void createOTTRecord(ID oppID){
        Order_Tracker__c ottRecord = null;
        
        Opportunity opp = getOppRecord(oppID);
        
        for(Order_Tracker__c ott : [Select id from Order_Tracker__c where Opportunity__c = :opp.Id]){
            ottRecord = ott;
        }
        System.debug('--ottRecord--'+ottRecord);
        if(ottRecord  == null){
            ottRecord = new Order_Tracker__c();
            ottRecord.From__c = userinfo.getUserEmail();
            ottRecord.Opportunity__c = opp.Id;
            ottRecord.Email_Subject__c = 'Sales Wizard : SO Creation';
            ottRecord.body__c = 'NA';
            ottRecord.isNewFlag__c = true;
            ottRecord.PO__c = opp.Partner_PO_Number__c;
            ottRecord.Proposal_for_initiating_QC__c = opp.SBQQ__PrimaryQuote__c != null && opp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c == true 
                ? opp.SBQQ__PrimaryQuote__r.name 
                :null;                    
                    //ottRecord.Remarks__c = opportunity.Special_Instructions_to_Finance__c;
                    
                    
                    ottRecord.Status__c = 'PO Pending for QR';
            
            insert ottRecord;
        }
        sendOTTEmail(ottRecord, opp.Id);   
    }
    
    
    public static void sendOTTEmail(Order_Tracker__c ott, Id oppID){
        
        System.debug('--Order_Tracker__c--'+ott);
        
        String htmlBody = '<p>Dear {{userName}}</p>'+
            '<p>Your order has been submitted for processing. This is an automated email confirming receipt of PO and that a new ticket has been created against it.</p>'+
            '<p>If you have any updates or questions/comments regarding it, please reply to this email thread for efficient tracking.</p>'+
            '<p>As we work through your request, the order will pass through various review processes and the status of your request shall accordingly change.</p>'+
            '<p>Sepcial Instruction to Finance: {{specialInsttoFin}}</p>'+
            //Mayank needs to add Special instructions for Multi Cloud in html body.
            //Add the same to email template:: https://zscaler--sbdev7.my.salesforce.com/00X4u0000020NfF only in HTML
            //Make changes mentioned in Slack by Dheeraj:: Show datatable of ZsScaler CLoud id and type in Multicloud pop up and then text area with checkbox
            '<p>Thanks</p>'+
            '<p>Order Processing Team</p>'+
            '<hr />'+
            '<p><br /><strong>Request Details:</strong></p>'+
            '<p>Quote#: {{QuoteName}}</p>';
        
        if(Label.Orders_Mail_Box == Null || Label.Orders_Mail_Box == '' || ott == null || ott.id == null)
            return;
        
        Order_Tracker__c ottRecord = [Select id,name,Ticket__c,
                                      Opportunity__c,
                                      Opportunity__r.Account.name,
                                      Opportunity__r.Special_Instructions_to_Finance__c,
                                      Opportunity__r.Primary_Quote_Source__c,
                                      Opportunity__r.SBQQ__PrimaryQuote__c,
                                      Opportunity__r.SBQQ__PrimaryQuote__r.name,
                                      //Opportunity__r.APTS_Primary_Proposal_Lookup__c,
                                      //Opportunity__r.APTS_Primary_Proposal_Lookup__r.Name,
                                      Thread_ID__c,Message_Id__c
                                      from Order_Tracker__c where id  = :ott.Id];
        
        System.debug('--ottRecord---'+ottRecord);
        String messageId = ottRecord.Message_Id__c;
        Set<ID> ContentDocumentIdList = new Set<ID>();
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :oppID]){
            ContentDocumentIdList.add(cdl.ContentDocumentId);
        }
        System.debug('--ContentDocumentIdList--'+ContentDocumentIdList);
        
        List<id> contentVersionIds = new List<id>();
        for(ContentVersion cv : [SELECT ContentDocumentId,Source_fileupload__c,FileExtension,Title,FileType
                                 FROM ContentVersion WHERE (ContentDocumentId in :ContentDocumentIdList) and Source_fileupload__c = 'PO_Document' and IsLatest=true])
        {
            if(cv.Source_fileupload__c != null){
                contentVersionIds.add(cv.id);
            }
        }
        System.debug('--contentVersionIds--'+contentVersionIds);
        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toCC = new List<String>();
        if(Label.Orders_Mail_Box.contains(',')){
            toCC.addAll(Label.Orders_Mail_Box.split(','));
        }else{
            toCC.add(Label.Orders_Mail_Box);
        }
        
        if(!contentVersionIds.isEmpty())       
            mail.setEntityAttachments(contentVersionIds);
        
        mail.setToAddresses(new String[]{userinfo.getUserEmail()});
        mail.setCcAddresses(toCC);
        
        if(messageId != null){
            mail.setReferences(messageId);
        }
        //if(ottRecord.Opportunity__c != null){
        //    mail.setSubject('Sales Wizard : '+ottRecord.Opportunity__r.Name+' is ready for Sales Order, OTT Record : '+ ottRecord.Ticket__c);
        //}else{
        mail.setSubject('Sales Wizard : OTT Record Creation : '+ ottRecord.Ticket__c);
        //}
        
        
        htmlBody = htmlBody.replace('{{userName}}', userInfo.getFirstName() + ' '+ userinfo.getLastName());
        
        String quoteName = ottRecord.Opportunity__r.Primary_Quote_Source__c == 'CPQ' ? 
            ottRecord.Opportunity__r.SBQQ__PrimaryQuote__r.name : null;    
        
        htmlBody = htmlBody.replace('{{QuoteName}}', quoteName != null ? quoteName : '');
        htmlBody = htmlBody.replace('{{specialInsttoFin}}', ottRecord.Opportunity__r.Special_Instructions_to_Finance__c != null ? ottRecord.Opportunity__r.Special_Instructions_to_Finance__c : '');
        mail.setHtmlBody(htmlBody);
        
        if(!Test.isRunningTest())
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        
    }
    
    //IBA-352 START
    @AuraEnabled
    public static string createTrialPGForSubscription(List<CloudIdRecsWrapper> trialTenantWrapperList, Boolean isCrossPlatformSelected) {
        set<Id> PGIds = new set<Id>();
        List<Provisioning_Group__c> newTrialPGList  = new List<Provisioning_Group__c>();    
        List<Provisioning_Group__c> oldPGUpdateList  = new List<Provisioning_Group__c>(); 
        List<Provisioning_Contact__c> provContactList = new List<Provisioning_Contact__c>(); 
        Map<Id, Id> oldPGToCloudIdMap = new Map<Id, Id>(); 
        Map<String, Provisioning_Product__c> provisioningProductsMap = new Map<String, Provisioning_Product__c>();
        Map<String, List<String>> productToSubscriptionLinesDataMap = new Map<String, List<String>>();
        if(isCrossPlatformSelected){
            system.debug('isCrossPlatformSelected**'+isCrossPlatformSelected);
        	string msg = createTrialPGForSubscriptionCP(trialTenantWrapperList); 
            return msg;
        }
        for(cloudIdRecsWrapper cloudIdWrap: trialTenantWrapperList) {
            System.debug('cloudIdWrap:::'+cloudIdWrap);
            if(cloudIdWrap.provGroup != null) {
                Provisioning_Group__c clonedPG = cloudIdWrap.provGroup.clone(false, true, false, false);
                clonedPG.PG_for_Subscription__c = true;
                clonedPG.Status__c = 'Requested';
                clonedPG.Approval_Status__c = 'Approved';
                clonedPG.PG_Request_Type__c = 'Replace';
                clonedPG.Original_Provisioning_Group__c = cloudIdWrap.provGroup.Id;
                clonedPG.Subscription_Id__c = '';
                clonedPG.Subscription_Name__c = '';
                clonedPG.Start_Date__c=System.today();
                clonedPG.End_Date__c = clonedPG.Start_Date__c.addDays(29);
                if(Date.isLeapYear(clonedPG.Start_Date__c.year())){
                    clonedPG.ZSCM_End_Date__c = clonedPG.Start_Date__c.addDays(365);
                }else{
                    clonedPG.ZSCM_End_Date__c = clonedPG.Start_Date__c.addDays(364);
                }
                newTrialPGList.add(clonedPG);

                Provisioning_Group__c oldPG = new Provisioning_Group__c();
                oldPG.Id = cloudIdWrap.provGroup.Id;
                oldPG.Status__c = 'Archived';
                oldPGUpdateList.add(oldPG);
            }
            for (provisioningQuoteLinesWrapper provProd : cloudIdWrap.provProdWrapperList) {
                Provisioning_Product__c provisioningProduct = new Provisioning_Product__c();
                provisioningProduct.Product__c = provProd.qli.SBQQ__Product__c!= null ? provProd.qli.SBQQ__Product__c : null;
                provisioningProduct.Start_Date__c = System.today();
                provisioningProduct.End_Date__c = System.today().addDays(29);
                provisioningProduct.Provisioning_Group__c = cloudIdWrap.provGroup != null ? cloudIdWrap.provGroup.Id : null;
                provisioningProduct.Quantity__c = 100;
                provisioningProduct.Status__c = 'Trial';
                String sKey = String.valueOf(cloudIdWrap.cloudIdRec.Id) + String.valueOf(provisioningProduct.Product__c);
                if(productToSubscriptionLinesDataMap.get(sKey) == null) {
                    provisioningProductsMap.put(sKey, provisioningProduct);
                }
                String subscriptionValues = String.valueOf(provProd.qli.SBQQ__StartDate__c) +':' + String.valueOf(provProd.qli.SBQQ__EndDate__c)+':' + String.valueOf(provProd.individualProdQuantity);
                List<String> subscriptionValuesList = productToSubscriptionLinesDataMap.containsKey(sKey) ? productToSubscriptionLinesDataMap.get(sKey) : new List<String>();
                subscriptionValuesList.add(subscriptionValues);
                subscriptionValuesList.sort();
                productToSubscriptionLinesDataMap.put(sKey, subscriptionValuesList);
            }
            oldPGToCloudIdMap.put(cloudIdWrap.provGroup.Id, cloudIdWrap.cloudIdRec.Id);
            PGIds.add(cloudIdWrap.provGroup.Id);
        }
        provContactList = cloneProvisioningContacts(PGIds);
        try{
        	if(!newTrialPGList.isEmpty())  {
            	insert newTrialPGList;
        	}    
        }
        catch(Exception ex){
        	ProvisioningErrorHandler.exceptionHandler('CreateSalesOrderExtensionCPQSalesLWCNew','createTrialPGForSubscription',ex);    
        }

        if(!oldPGUpdateList.isEmpty())  {
            //update oldPGUpdateList;
        }

        Map<Id, Id> cloudIdToNewPGIdMap = new Map<Id, Id>();
        for(Provisioning_Group__c pg: newTrialPGList) {
            cloudIdToNewPGIdMap.put(pg.Zscaler_Cloud_ID__c, pg.Id);
        }

        for (String sKey: provisioningProductsMap.keySet()) {
            Provisioning_Product__c provProd = provisioningProductsMap.get(sKey);
            String subscriptionLinesData = String.join(productToSubscriptionLinesDataMap.get(sKey), ',');
            provProd.Subscription_Lines_Data__c = subscriptionLinesData;
            if(oldPGToCloudIdMap.get(provProd.Provisioning_Group__c) != null && cloudIdToNewPGIdMap.get(oldPGToCloudIdMap.get(provProd.Provisioning_Group__c)) != null) {
                provProd.Provisioning_Group__c = cloudIdToNewPGIdMap.get(oldPGToCloudIdMap.get(provProd.Provisioning_Group__c));
            }
        }
        
        for (Provisioning_Contact__c pc : provContactList){
            if(cloudIdToNewPGIdMap.containsKey(pc.Provisioning_Group__r.Zscaler_Cloud_ID__c)){
                pc.Provisioning_Group__c = cloudIdToNewPGIdMap.get(pc.Provisioning_Group__r.Zscaler_Cloud_ID__c);    
            }
        }
        if (provisioningProductsMap.values() != null && !provisioningProductsMap.values().isEmpty()) {
			try{
                insert provisioningProductsMap.values();  
        	}
        	catch(Exception ex){
        		ProvisioningErrorHandler.exceptionHandler('CreateSalesOrderExtensionCPQSalesLWCNew','createTrialPGForSubscription',ex);    
        	}
        }
		try{
            if (provContactList != null && !provContactList.isEmpty()) {
            	insert provContactList;
        	}  
        }
        catch(Exception ex){
        	ProvisioningErrorHandler.exceptionHandler('CreateSalesOrderExtensionCPQSalesLWCNew','createTrialPGForSubscription',ex);    
        }
        return 'Success';   
    }
    //IBA-352 END
    
    @testVisible
    private static Opportunity getOppRecord(Id oppID){
        Opportunity opp = [SELECT Id, Name,Amount,Type,StageName,
                               Netsuite_Sales_Order_Internal_ID__c,
                               NS_Integration_Failure_Reason__c, 
                               NS_Integration_Status__c,
                               
                               First_PO_Date__c,
                               RecordType.Name,
                               CloseDate,
                               
                               Partner_PO_Number__c, 
                               Legal_Create_Sales_Order__c,
                               
                               Primary_Partner_Program__c, 
                               Finance_Comments__c,
                              
                               SBQQ__PrimaryQuote__c,
                               SBQQ__PrimaryQuote__r.name,
                               SBQQ__PrimaryQuote__r.SBQQ__Primary__c,
                               SBQQ__PrimaryQuote__r.SBQQ__StartDate__c,
                               SBQQ__PrimaryQuote__r.SBQQ__EndDate__c,
                               SBQQ__PrimaryQuote__r.SBQQ__Account__c, 
                               SBQQ__PrimaryQuote__r.SBQQ__Status__c,
                               SBQQ__PrimaryQuote__r.ApprovalStatus__c,
                               
                               Custom_Order__c,
                               
                               PO_Attached__c,
                               SOW_Attached__c,
                               Declaration_Attached__c,
                               Sales_Declaration_Done__c,
                               
                               AccountId,
                               Account.Amber_Road_Status__c,
                               Account.Is_Federal_Account_Sync__c,
                               split_type__c,
                               Special_Instructions_to_Finance__c,
                               Override_PR_check__c,

                               Special_Instructions_for_MultiCloud__c,
                               Special_Instructions_Not_Required__c,
                               Account.Name,
                               PO_Source__c,
                               DAS_Start_Date__c,
                               DAS_Package_New__c
                               
                               FROM Opportunity WHERE Id = :oppID LIMIT 1];
       return opp;
    }
    
    @testVisible 
    private static Boolean getServiceStartDateEarlierProvisionDate(Opportunity opp,List<Provisioning_Request__c> allPRList){
        
        Boolean isServiceStartDateEarlierProvisionDate = false;
        
        for(Provisioning_Request__c prReq : allPRList){
            if(opp.SBQQ__PrimaryQuote__c != null
               && opp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c == true 
               && opp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c != null 
               && prReq.Provisioning_Date__c > opp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c )
            {
                isServiceStartDateEarlierProvisionDate = true;
                break;
            }
        }
        return isServiceStartDateEarlierProvisionDate;
    }
    
    @testVisible 
    private static Boolean getServiceStartDateEarlierPGProvisionDate(Opportunity opp,List<Provisioning_Group__c> allPRList){
        
        Boolean isServiceStartDateEarlierProvisionDate = false;
        
        for(Provisioning_Group__c prReq : allPRList){
            if(opp.SBQQ__PrimaryQuote__c != null
               && opp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c == true 
               && opp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c != null 
               && prReq.Start_Date__c > opp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c )
            {
                isServiceStartDateEarlierProvisionDate = true;
                break;
            }
        }
        return isServiceStartDateEarlierProvisionDate;
    }
    
    
    @testVisible
    private static Boolean getIsBillingCheckRequired(Opportunity opp){
        Boolean IsBillingCheckRequired = false;
        if(opp.SBQQ__PrimaryQuote__c != null
           && opp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c == true 
           && opp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c != null 
          )
        {
            IsBillingCheckRequired = MAth.abs(opp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c.daysBetween(opp.CloseDate)) > 32;
        }
        return IsBillingCheckRequired;
    }
    
    @testVisible
    public static Boolean getIsSOWRequired(Opportunity opp){
        Boolean isSOWRequired = false;
        if(opp.SBQQ__PrimaryQuote__c != null 
           && opp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c == true)
        {
            for(SBQQ__QuoteLine__c qline : [Select Id,SBQQ__ProductCode__c,SBQQ__Product__c,SBQQ__Product__r.name,
                                            SBQQ__Product__r.Product_Family__c from SBQQ__QuoteLine__c 
                                            where SBQQ__Quote__c != null and SBQQ__Quote__c = :opp.SBQQ__PrimaryQuote__c ])
            {
                if(qline.SBQQ__ProductCode__c != null && prProdutSOWList.contains(qline.SBQQ__ProductCode__c)){
                    isSOWRequired = true;
                    break;
                }
            }
        }
        
        
        return isSOWRequired;
    }
    
    @testVisible
    private static List<Provisioning_Request__c> getALLPRList(Opportunity opp){
        List<Provisioning_Request__c> allPRList = new List<Provisioning_Request__c>();
        if(opp.type=='New Business'){
            allPRList = [Select id,name,Provisioning_Status__c,Provisioning_Date__c,Recordtype.Name,
                         ZIA_Org_ID__c,ZIA_Org_ID__r.name,
                         ZPA_Org_ID__c,ZPA_Org_ID__r.name,
                         ZIA_Org_ID_to_be_used_for_Zapp__c,ZIA_Org_ID_to_be_used_for_Zapp__r.name,
                         Preferred_Cloud__c,
                         Product_Line_for_PR__c
                        from Provisioning_Request__c where Opportunity__c = :opp.id and recordtype.developername in :prRecodTypeList and Provisioning_Status__c not in :prRecodInvalidStatusList];
        }else{
            allPRList = [Select id,name,Provisioning_Status__c,Provisioning_Date__c,Recordtype.Name,
                         ZIA_Org_ID__c,ZIA_Org_ID__r.name,
                         ZPA_Org_ID__c,ZPA_Org_ID__r.name,
                         ZIA_Org_ID_to_be_used_for_Zapp__c,ZIA_Org_ID_to_be_used_for_Zapp__r.name,
                         Preferred_Cloud__c,
                         Product_Line_for_PR__c
                        from Provisioning_Request__c where Account__c = :opp.AccountId and recordtype.developername in :prRecodTypeList and Provisioning_Status__c not in :prRecodInvalidStatusList];
        }
        return allPRList;
    }
    
    @testVisible
    private static List<Provisioning_Group__c> getALLPGList(Opportunity opp){
        List<Provisioning_Group__c> allPRList = new List<Provisioning_Group__c>();
        String provGroupFields = getFieldNamesOfSObject('Provisioning_Group__c');
        String provProductFields = getFieldNamesOfSObject('Provisioning_Product__c');
        String queryString;
        Id OpptyId = opp.Id;
        Id AccountId = opp.AccountId;
        queryString = 'Select id,name,Status__c,Start_Date__c,End_Date__c,RecordTypeId,Organization_Domain__c,PG_for_Subscription__c,Additional_Organization_domains__c,Preferred_Cloud__c,Product_Line__c,Zscaler_Cloud_ID__c,Opportunity__c, Account__c';
        queryString = queryString + ',Provisioning_Type__c,Default_Preferred_Cloud__c,Provisioning_Process__c,Send_Initial_Login_Credentials_To__c,Is_Active__c,Nanolog_Cluster__c,Sandbox_Cluster__c,SMCDSS_DLP_Cluster__c,ZPA_Preferred_Cloud__c';
        queryString = queryString + ',Manually_Processed__c,Number_of_Extensions__c,SE_Manager_Email__c,Provisioning_Broker_Eligible__c,Integration_Status__c,PG_Request_Type__c,Associated_ZIA_Zscaler_Cloud__c,Original_Provisioning_Group__c,Initial_Login_Credentials_Receiver_Email__c';
        if(opp.type=='New Business'){ 
            queryString = queryString + ', (Select '+provProductFields+' FROM Provisioning_Products__r) From Provisioning_Group__c where Opportunity__c = :OpptyId and recordtype.developername in :pgRecodTypeList and Status__c not in :prRecodInvalidStatusList';
            System.debug('queryString:::'+queryString);
            allPRList = Database.query(queryString);
        }else{
            queryString = queryString + ', (Select '+provProductFields+' from Provisioning_Products__r) From Provisioning_Group__c where Account__c = :AccountId and recordtype.developername in :pgRecodTypeList and Status__c not in :prRecodInvalidStatusList';
            //System.debug('--> ' + queryString);
            allPRList = Database.query(queryString);
        }
        return allPRList;
    }
    
    @testVisible
    public static list<String> getListFromString(String inpStr, String seprator){
        list<String> retStr = new List<String>();
        if(inpStr.contains(seprator)){
            for(String abc : inpStr.split(seprator)){
                if(abc != null && abc.trim().length()>0){
                    retStr.add(abc.trim());
                }
            }
        }else{
            retStr.add(inpStr); 
        }
        return retStr;
    }
    
    
    //wrapper class for attachments/content-version
    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public String fileId;
    }
    
    
    public class PreQCResultWrapper {
        @auraEnabled
        public Boolean isSuccess { get; set; }
        @auraEnabled
        public String errMsg { get; set; }
        @auraEnabled
        public PreQCWrapper pqw { get; set; }
    }
    
    public class CloudIdRecsWrapper {
        @auraEnabled
        public Boolean isSelected { get; set; }
        @auraEnabled
        public Boolean applyQuoteQty { get; set; }
        @auraEnabled
        public string showPlatformSKUSeats { get; set; }
        @auraEnabled
        public string showcartView { get; set; }
        @auraEnabled
        public Zscaler_Cloud_ID__c cloudIdRec { get; set; }
        @auraEnabled
        public Provisioning_Group__c provGroup { get; set; }
        @auraEnabled
        public List<ProvisioningQuoteLinesWrapper> provProdWrapperList { get; set; }
    }
    
    public class ProvisioningQuoteLinesWrapper {
        @auraEnabled
        public String qliTocloudIdKey { get; set; }
        @auraEnabled
        public SBQQ__QuoteLine__c qli { get; set; }
        @auraEnabled
        public Decimal individualProdQuantity { get; set; }
        @auraEnabled
        public Decimal remainingQuantity { get; set; }
    }
    
    public static String getFieldNamesOfSObject(String objectName) {
        
        Set<String> queryFieldsSet = new Set<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        String queryFields = '';
        for(String fieldName : fieldMap.keySet()) {
            if(fieldMap.get(fieldName).getDescribe().isCustom() && !fieldMap.get(fieldName).getDescribe().isCalculated()) {
                queryFields += fieldName + ',';
            }
        }
        queryFields += ' Id';
        //queryFields = queryFields.removeEnd(',');
        System.debug('--> queryFieldsSet : ' + queryFields);
        return queryFields;
    }
    
    public static List<Provisioning_Contact__c> cloneProvisioningContacts(set<Id> provGroupIds){
        List<Provisioning_Contact__c> provContactList = [SELECT Id,Contact__c,Email__c,Name,Provisioning_Group__c,
                                                        Type__c,User__c,User_Name__c,Zscaler_Cloud_ID__c,Provisioning_Group__r.Zscaler_Cloud_ID__c 
                                                        FROM Provisioning_Contact__c 
                                                        WHERE Provisioning_Group__c IN : provGroupIds];

        List<Provisioning_Contact__c> listToBeInserted = new List<Provisioning_Contact__c>();
        for(Provisioning_Contact__c pc : provContactList){
            Provisioning_Contact__c newPC = pc.clone(false,true,false,false);
            listToBeInserted.add(newPC);
        }
        return listToBeInserted;
    }
    public static string createTrialPGForSubscriptionCP(List<CloudIdRecsWrapper> trialTenantWrapperList) {
        string msg;
        set<Id> prgIds = new set<Id>();
        set<Id> allPrgIds = new set<Id>();
        Map<Id,List<Provisioning_Group__c>> prodLineMap = New Map<Id,List<Provisioning_Group__c>>();
        Map<Id,Set<string>> prodLineStringMap = new Map<Id,Set<string>>();
        List<Provisioning_Group__c> newTrialPGList  = new List<Provisioning_Group__c>();    
        List<Provisioning_Group__c> oldPGUpdateList  = new List<Provisioning_Group__c>(); 
        List<Provisioning_Contact__c> provContactList = new List<Provisioning_Contact__c>();
        List<Provisioning_Product__c> provProdList = new List<Provisioning_Product__c>();
        Map<Id,Id> prgCloudMap = new Map<Id,Id>();
        String provGroupFields = getFieldNamesOfSObject('Provisioning_Group__c');
        String provProductFields = getFieldNamesOfSObject('Provisioning_Product__c');
        string queryString;
        queryString = 'Select id,name,Status__c,Start_Date__c,End_Date__c,RecordTypeId,Organization_Domain__c,PG_for_Subscription__c,Additional_Organization_domains__c,Preferred_Cloud__c,Product_Line__c,Zscaler_Cloud_ID__c,Opportunity__c, Account__c';
        queryString = queryString + ',Provisioning_Type__c,Default_Preferred_Cloud__c,Provisioning_Process__c,Send_Initial_Login_Credentials_To__c,Is_Active__c,Nanolog_Cluster__c,Sandbox_Cluster__c,SMCDSS_DLP_Cluster__c,ZPA_Preferred_Cloud__c';
        queryString = queryString + ',Manually_Processed__c,Number_of_Extensions__c,SE_Manager_Email__c,Provisioning_Broker_Eligible__c,Integration_Status__c,PG_Request_Type__c,Associated_ZIA_Zscaler_Cloud__c,Original_Provisioning_Group__c,Initial_Login_Credentials_Receiver_Email__c';
        queryString = queryString + ', (Select '+provProductFields+',Provisioning_Group__r.Zscaler_Cloud_ID__c FROM Provisioning_Products__r) From Provisioning_Group__c where ID = :allPrgIds';
        for(cloudIdRecsWrapper cloudIdWrap: trialTenantWrapperList) {
        	prgIds.add(cloudIdWrap.provGroup.Id);
            allPrgIds.add(cloudIdWrap.provGroup.Id);
        }
        if(!prgIds.isEmpty() && prgIds != NULL){
            List<Provisioning_Group__c> prgList = [SELECT Id, Product_Line__c, Zscaler_Cloud_ID__c,Associated_Provisioning_Group__c,Opportunity__c,opportunity__r.SBQQ__PrimaryQuote__c 
                                                   FROM Provisioning_Group__c 
                                                   WHERE Associated_Provisioning_Group__c IN : prgIds and Status__c = 'Provisioned' and Cross_Platform_Selected__c = true];
            if(!prgList.isEmpty() & prgList!=NULL){
            	for(Provisioning_Group__c prg: prgList){
                    if(!prodLineMap.containsKey(prg.Associated_Provisioning_Group__c)){
                        prodLineMap.put(prg.Associated_Provisioning_Group__c,new List<Provisioning_Group__c>{prg});
                        prodLineStringMap.put(prg.Associated_Provisioning_Group__c, new Set<string>{prg.Product_Line__c});
                    }
                    else{
                        prodLineMap.get(prg.Associated_Provisioning_Group__c).add(prg);
                        prodLineStringMap.get(prg.Associated_Provisioning_Group__c).add(prg.Product_Line__c);
                    }
                    allPrgIds.add(prg.ID);
                }    
            }
            for(cloudIdRecsWrapper cloudIdWrap: trialTenantWrapperList) {
                if(prodLineMap.containsKey(cloudIdWrap.provGroup.Id)){
                    if(prodLineStringMap.get(cloudIdWrap.provGroup.Id).contains('ZPA') && prodLineStringMap.get(cloudIdWrap.provGroup.Id).contains('ZDX')){
                        for(Provisioning_Group__c prg : prodLineMap.get(cloudIdWrap.provGroup.Id)){
                            if(prg.Zscaler_Cloud_ID__c == NULL){
                            	msg = 'Please select a tenant which has both associated ZPA and ZDX tenants.';
                    			return msg;    
                            }    
                        }
                    }
                    else{
                    	msg = 'Please select a tenant which has both associated ZPA and ZDX tenants.';
                    	return msg;    
                    }	    
                }
                else{
                	msg = 'Please select a tenant which has both associated ZPA and ZDX tenants.';
                    return msg;
                }    
        	}
            Map<string,List<SBQQ__QuoteLine__c>> qliMap = new Map<string,List<SBQQ__QuoteLine__c>>();
            for(SBQQ__QuoteLine__c qli : [Select Id,SBQQ__ProductCode__c,SBQQ__Product__c,SBQQ__Product__r.name,SBQQ__Product__r.Product_Line__c,
                                                SBQQ__Product__r.Product_Family__c,SBQQ__Product__r.Zscaler_Product_Family__c,SBQQ__Quantity__c,
                                                SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Number__c, SBQQ__StartDate__c, SBQQ__EndDate__c
                                                from SBQQ__QuoteLine__c where SBQQ__Quote__c != null and SBQQ__Quote__c = :prgList[0].opportunity__r.SBQQ__PrimaryQuote__c 
                                                and SBQQ__Product__r.Product_Line__c in :prProdutFamilyList
                                                and SBQQ__RequiredBy__c != null order by SBQQ__Product__r.Product_Line__c, 
                                                SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Number__c, SBQQ__StartDate__c]){
            	if(qliMap.containsKey(qli.SBQQ__Product__r.Product_Line__c)){
                	qliMap.get(qli.SBQQ__Product__r.Product_Line__c).add(qli);     
                }
                else{
                    qliMap.put(qli.SBQQ__Product__r.Product_Line__c, new List<SBQQ__QuoteLine__c>{qli});    
                } 
            }
            system.debug('qliMap**'+qliMap);
            List<Provisioning_Group__c> allPGList = Database.query(queryString);
            for(Provisioning_Group__c prg: allPGList) {
            	Provisioning_Group__c clonedPG = prg.clone(false, true, false, false);
                clonedPG.PG_for_Subscription__c = true;
                clonedPG.Status__c = 'Requested';
                clonedPG.Approval_Status__c = 'Approved';
                clonedPG.PG_Request_Type__c = 'Replace';
                clonedPG.Original_Provisioning_Group__c = prg.Id;
                if(prg.Product_Line__c == 'ZDX'){
                	clonedPG.Provisioning_Broker_Eligible__c = true;    
                }
                clonedPG.Subscription_Id__c = '';
                clonedPG.Subscription_Name__c = '';
                clonedPG.Start_Date__c=System.today();
                clonedPG.End_Date__c = clonedPG.Start_Date__c.addDays(29);
                prgCloudMap.put(prg.Id,prg.Zscaler_Cloud_ID__c);
                if(Date.isLeapYear(clonedPG.Start_Date__c.year())){
                    clonedPG.ZSCM_End_Date__c = clonedPG.Start_Date__c.addDays(365);
                }else{
                    clonedPG.ZSCM_End_Date__c = clonedPG.Start_Date__c.addDays(364);
                }
                newTrialPGList.add(clonedPG);

                Provisioning_Group__c oldPG = new Provisioning_Group__c();
                oldPG.Id = prg.Id;
                oldPG.Status__c = 'Archived';
                oldPGUpdateList.add(oldPG);
                if(!qliMap.isEmpty() && qliMap!=NULL){
                    if(qliMap.containsKey(prg.Product_Line__c)){
                    	for (SBQQ__QuoteLine__c qli : qliMap.get(prg.Product_Line__c)) {
                            Provisioning_Product__c provisioningProduct = new Provisioning_Product__c();
                            provisioningProduct.Product__c = qli.SBQQ__Product__c!= null ? qli.SBQQ__Product__c : null;
                            provisioningProduct.Start_Date__c = System.today();
                            provisioningProduct.End_Date__c = System.today().addDays(29);
                            provisioningProduct.Provisioning_Group__c = prg != null ? prg.Id : null;
                            provisioningProduct.Quantity__c = 100;
                            provisioningProduct.Status__c = 'Trial';
                            provProdList.add(provisioningProduct);
                        }    
                    }
                    if(qliMap.containsKey('Cross Platform')){
                    	for (SBQQ__QuoteLine__c qli : qliMap.get('Cross Platform')) {
                            Provisioning_Product__c provisioningProduct = new Provisioning_Product__c();
                            provisioningProduct.Product__c = qli.SBQQ__Product__c!= null ? qli.SBQQ__Product__c : null;
                            provisioningProduct.Start_Date__c = System.today();
                            provisioningProduct.End_Date__c = System.today().addDays(29);
                            provisioningProduct.Provisioning_Group__c = prg != null ? prg.Id : null;
                            provisioningProduct.Quantity__c = 100;
                            provisioningProduct.Status__c = 'Trial';
                            provProdList.add(provisioningProduct);
                        }    
                    }
                }
            }
            provContactList = cloneProvisioningContacts(allPrgIds);
            try{
            	if(!newTrialPGList.isEmpty())  {
                    insert newTrialPGList;
                }    
            }
            catch(Exception ex){
                ProvisioningErrorHandler.exceptionHandler('CreateSalesOrderExtensionCPQSalesLWCNew','createTrialPGForSubscriptionCP',ex);
                msg = ex.getMessage();
                return msg;
            }
            Map<Id, Id> cloudIdToNewPGIdMap = new Map<Id, Id>();
        	for(Provisioning_Group__c pg: newTrialPGList) {
            	cloudIdToNewPGIdMap.put(pg.Zscaler_Cloud_ID__c, pg.Id);
        	}
            for (Provisioning_Product__c pp : provProdList) {
                system.debug('***test1***'+pp);
                system.debug('***test***'+pp.Provisioning_Group__r.Zscaler_Cloud_ID__c);
                if(cloudIdToNewPGIdMap.containsKey(prgCloudMap.get(pp.Provisioning_Group__c))){
                    pp.Provisioning_Group__c = cloudIdToNewPGIdMap.get(prgCloudMap.get(pp.Provisioning_Group__c));    
                }
            }
            
            for (Provisioning_Contact__c pc : provContactList){
                if(cloudIdToNewPGIdMap.containsKey(pc.Provisioning_Group__r.Zscaler_Cloud_ID__c)){
                    pc.Provisioning_Group__c = cloudIdToNewPGIdMap.get(pc.Provisioning_Group__r.Zscaler_Cloud_ID__c);    
                }
            }
            if (provProdList != null && !provProdList.isEmpty()) {
                try{
                    insert provProdList;  
                }
                catch(Exception ex){
                    ProvisioningErrorHandler.exceptionHandler('CreateSalesOrderExtensionCPQSalesLWCNew','createTrialPGForSubscriptionCP',ex);
                	msg = ex.getMessage();
                	return msg;
                }
            }
            try{
                if (provContactList != null && !provContactList.isEmpty()) {
                    insert provContactList;
                }  
            }
            catch(Exception ex){
                ProvisioningErrorHandler.exceptionHandler('CreateSalesOrderExtensionCPQSalesLWCNew','createTrialPGForSubscriptionCP',ex);
                msg = ex.getMessage();
                return msg;
            }
            msg = 'Success';
            system.debug('mSG**'+msg);
        }
    	return msg;    
    }
}