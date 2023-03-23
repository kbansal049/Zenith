public without sharing class CreateSalesOrderExtensionCPQSalesLWC {
    
    public static List<String> ZIAServiceEdgeSKUs = new List<String>{'ZIA-SVC-EDGE-3' , 'ZIA-SVC-EDGE-5'};
        public static List<String> ZIAVirtualServiceEdgeSKUs = new List<String>{'ZIA-SVC-EDGE-V'};
            public static List<String> equpMentRequest = new List<String>{'ZIA Service Edge', 'ZIA Virtual Service Edge'};
                  
                public static List<String> prRequestProdutFamilyList = new List<String>{'Bundle Platforms', 'Zscaler Internet Access', 'Zscaler Private Access', 'Pre SKUs'};
                       public static List<String> prProdutFamilyList = new List<String>{'ZIA', 'ZPA', 'ZDX'};
                            public static List<String> prProdutSOWList = new List<String>{'ZCES-PRO-SVC', 'ZCES-PRO-SVC-CUST-FED'};
                                
                                
                               
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
    public static List<String> prRecodInvalidStatusList {
        get{
            if(prRecodInvalidStatusList == null){
                if(Label.Sales_Wizard_PR_RecordTypes != null){
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
        public MAP<String, List<Provisioning_Request__c>> prMAP { get; set; }
        
        @auraEnabled
        public MAP<String, List<Provisioning_group__c>> prgMAP { get; set; }
        
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
        public Boolean specialInstructionNotRequired { get; set; } //CR#3611

        @auraEnabled
        public String specialInstructionForMultiCloud { get; set; } //CR#3611

        @auraEnabled
        public String oppAccountName { get; set; } //CR#3611

        @auraEnabled
        public MAP<String, List<String>> cloudTypeCloudListMAP {get; set;} //CR#3611
        
        @auraEnabled
        public PO_Detail__c poDet {get; set;} //EDI
        
        @auraEnabled
        public Boolean isPSStartDateRequired { get; set; }
    }    
    
                           
    @AuraEnabled
    public static PreQCResultWrapper retrivePreQCDetails(Id opportunityId){
        System.debug('----retrivePreQCDetails---opportunityId--'+opportunityId);
        PreQCResultWrapper prWrap = new PreQCResultWrapper();
        if(opportunityId != null){
            PreQCWrapper pqw = new PreQCWrapper();
            
          
            //Get opportunity Record
            Opportunity opp = getOppRecord(opportunityId);
            
            //get all PR Records
            List<Provisioning_Request__c> allPRList = getALLPRList(opp);
            List<Provisioning_Group__c> allPRGList = getALLPGList(opp);
            //PS StartDateRequired Check CR#4083
            pqw.isPSStartDateRequired = opp.DAS_Package_New__c != null ? true : false;
            
            //Set opportunity Record
            pqw.opp = opp;
            pqw.primaryQuoteCPQ = opp.SBQQ__PrimaryQuote__r;
            
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
            pqw.isServiceStartDateEarlierProvisionDate = getServiceStartDateEarlierProvisionDate(opp,allPRList);

            //Billing Check
            if(opp.type == 'Existing Customer (Renewal)'){
                pqw.isBillingCheckRequired = false;                
            }else if(opp.type == 'New Business'){
                pqw.isBillingCheckRequired = getIsBillingCheckRequired(opp);
            }else{
                pqw.isBillingCheckRequired = false;
            }
            pqw.isBillingDeclarationAttached = opp.Declaration_Attached__c;
           
            //Provisioning Request Details
            MAP<String, List<sObject>> quoteLineFamilyMAP = new  MAP<String, List<sObject>>();
            
            System.debug('--opp SBQQ__PrimaryQuote__c--'+opp.SBQQ__PrimaryQuote__c);
            if(opp.SBQQ__PrimaryQuote__c != null){
                for(SBQQ__QuoteLine__c qline : [Select id,SBQQ__ProductCode__c,SBQQ__Product__c,SBQQ__Product__r.name,
                                                SBQQ__Product__r.Product_Family__c,SBQQ__Product__r.Product_Line__c from SBQQ__QuoteLine__c 
                                                where SBQQ__Quote__c != null and SBQQ__Quote__c = :opp.SBQQ__PrimaryQuote__c 
                                                and SBQQ__Product__r.Product_Line__c in :prProdutFamilyList
                                                and SBQQ__Product__r.Product_Family__c in : prRequestProdutFamilyList])
                {
                    List<sObject> qlineList = quoteLineFamilyMAP.containsKey(qline.SBQQ__Product__r.Product_Line__c)     
                        ?   quoteLineFamilyMAP.get(qline.SBQQ__Product__r.Product_Line__c)  
                        : new List<sObject>();
                    sObject sobj = (sObject) qline;
                    qlineList.add(sobj);
                    quoteLineFamilyMAP.put(qline.SBQQ__Product__r.Product_Line__c, qlineList);
                }
            }
            
            System.debug('--quoteLineFamilyMAP--'+quoteLineFamilyMAP.keyset());
            
            MAP<id, Zscaler_Cloud_ID__c> accCloudIds = new MAP<id, Zscaler_Cloud_ID__c>([Select id,Name,Org_Name__c,Cloud_Type__c from Zscaler_Cloud_ID__c where Account__c = :opp.AccountId]);
            
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
            
            System.debug('---pqw.cloudTypeCloudMAP: '+ cloudTypeCloudMAP);
            System.debug('---pqw.cloudTypeCloudListMAP: '+ pqw.cloudTypeCloudListMAP);
            
            MAP<ID, Provisioning_Request__c> cloudPRMAP = new MAP<ID, Provisioning_Request__c>();
            MAP<ID, Provisioning_Request__c> zpaAsZIAPRMAP = new MAP<ID, Provisioning_Request__c>();
            MAP<String, List<Provisioning_Request__c>> prefCloudPRMAP = new MAP<String, List<Provisioning_Request__c>>();
            
            MAP<ID, Provisioning_Group__c> cloudPRGMAP = new MAP<ID, Provisioning_Group__c>();
            MAP<ID, Provisioning_Group__c> zpaAsZIAPRGMAP = new MAP<ID, Provisioning_Group__c>();
            MAP<String, List<Provisioning_Group__c>> prefCloudPRGMAP = new MAP<String, List<Provisioning_Group__c>>();

            for(Provisioning_Request__c prReq : allPRList){
                if(prReq.ZIA_Org_ID__c != null){
                    cloudPRMAP.put(prReq.ZIA_Org_ID__c, prReq);
                }
                if(prReq.ZPA_Org_ID__c != null){
                    cloudPRMAP.put(prReq.ZPA_Org_ID__c, prReq);
                }
                if(prReq.ZIA_Org_ID_to_be_used_for_Zapp__c != null){
                    zpaAsZIAPRMAP.put(prReq.ZIA_Org_ID_to_be_used_for_Zapp__c, prReq);
                }
                if(prReq.Preferred_Cloud__c != null){
                    List<Provisioning_Request__c> prList = prefCloudPRMAP.containsKey(prReq.Preferred_Cloud__c) ? prefCloudPRMAP.get(prReq.Preferred_Cloud__c) : new List<Provisioning_Request__c>();
                    prList.add(prReq);
                    prefCloudPRMAP.put(prReq.Preferred_Cloud__c, prList);
                }
                if(prReq.Product_Line_for_PR__c != null){
                    for(String cloudProductType : prReq.Product_Line_for_PR__c.split(';')){
                        if(cloudProductType != null){
                            String cpType = cloudProductType.trim();
                            List<Provisioning_Request__c> prList = prefCloudPRMAP.containsKey(cpType) ? prefCloudPRMAP.get(cpType) : new List<Provisioning_Request__c>();
                            prList.add(prReq);
                            prefCloudPRMAP.put(cpType, prList);
                        }
                    }
                }
            }

            for(Provisioning_Group__c prg : allPRGList){
                if(prg.Zscaler_Cloud_ID__c != null){
                    cloudPRGMAP.put(prg.Zscaler_Cloud_ID__c, prg);
                }
                if(prg.Associated_ZIA_Zscaler_Cloud__c != null){
                    zpaAsZIAPRGMAP.put(prg.Associated_ZIA_Zscaler_Cloud__c, prg);
                }
                if(prg.Product_Line__c != null){
                    List<Provisioning_Group__c> prgList = prefCloudPRGMAP.containsKey(prg.Product_Line__c) ? prefCloudPRGMAP.get(prg.Product_Line__c) : new List<Provisioning_Group__c>();
                    prgList.add(prg);
                    prefCloudPRGMAP.put(prg.Product_Line__c, prgList);
                }
            }
            System.debug('--cloudPRGMAP--'+cloudPRMAP);
            System.debug('--zpaAsZIAPRGMAP--'+zpaAsZIAPRMAP);
            System.debug('--prefCloudPRGMAP--'+prefCloudPRMAP);
            
            MAP<String, List<Provisioning_Request__c>> zscalrFamilyPRRaised = new  MAP<String, List<Provisioning_Request__c>>();
            MAP<String, List<Provisioning_Group__c>> zscalrFamilyPRGRaised = new  MAP<String, List<Provisioning_Group__c>>();
            
            for(String zscalFamily : quoteLineFamilyMAP.keyset()){
                if(zscalFamily == 'ZIA' || zscalFamily == 'ZPA'){
                    MAP<Id, Provisioning_Request__c> prMAP = new MAP<Id, Provisioning_Request__c>(
                        zscalrFamilyPRRaised.containsKey(zscalFamily) ? 
                        zscalrFamilyPRRaised.get(zscalFamily) : 
                        new List<Provisioning_Request__c>()
                    );
                    MAP<Id, Provisioning_Group__c> prgMAP = new MAP<Id, Provisioning_Group__c>(
                        zscalrFamilyPRGRaised.containsKey(zscalFamily) ? 
                        zscalrFamilyPRGRaised.get(zscalFamily) : 
                        new List<Provisioning_Group__c>()
                    );
                    if(cloudTypeCloudMAP.containsKey(zscalFamily)){
                        for(Zscaler_Cloud_ID__c zci : cloudTypeCloudMAP.get(zscalFamily)){
                            if(cloudPRMAP.containskey(zci.id)){
                                prMAP.put(cloudPRMAP.get(zci.id).id, cloudPRMAP.get(zci.id));
                            }
                            if(cloudPRGMAP.containskey(zci.id)){
                                prgMAP.put(cloudPRGMAP.get(zci.id).id, cloudPRGMAP.get(zci.id));
                            }
                        }
                    }
                    if(zscalFamily == 'ZPA' && cloudTypeCloudMAP.containsKey('ZIA')){
                        for(Zscaler_Cloud_ID__c zci : cloudTypeCloudMAP.get('ZIA')){
                            if(zpaAsZIAPRMAP.containskey(zci.id)){
                                prMAP.put(zpaAsZIAPRMAP.get(zci.id).id, zpaAsZIAPRMAP.get(zci.id));
                            }
                            if(zpaAsZIAPRGMAP.containskey(zci.id)){
                                prgMAP.put(zpaAsZIAPRGMAP.get(zci.id).id, zpaAsZIAPRGMAP.get(zci.id));
                            }
                        }
                    }
                    
                    for(String preferredCloud : prefCloudPRMAP.keyset()){
                        if(zscalFamily.containsIgnoreCase(preferredCloud)){
                            for(Provisioning_Request__c pr : prefCloudPRMAP.get(preferredCloud)){
                                prMAP.put(pr.id, pr);
                            }
                        }
                    }
                    for(String preferredCloud : prefCloudPRGMAP.keyset()){
                        if(zscalFamily.containsIgnoreCase(preferredCloud)){
                            for(Provisioning_Group__c prg : prefCloudPRGMAP.get(preferredCloud)){
                                prgMAP.put(prg.id, prg);
                            }
                        }
                    }
                    
                    zscalrFamilyPRRaised.put(zscalFamily, prMAP.values());
                    zscalrFamilyPRGRaised.put(zscalFamily, prgMAP.values());
                }
            }
            
            System.debug('-- zscalrFamilyPRRaised--'+zscalrFamilyPRRaised);
            
            
            if(opp.Account.Is_Federal_Account_Sync__c || opp.Override_PR_check__c || 
               (opp.Type == 'Existing Customer (Renewal)' && (opp.Split_Type__c == 'No Split'|| opp.Split_Type__c == 'Comp Split')))
            {
                pqw.prRequired = false;
            } else{
                pqw.prRequired = zscalrFamilyPRRaised.keySet().size() > 0 ? true : false;
            }
            pqw.prMAP = zscalrFamilyPRRaised;
            pqw.prgMAP = zscalrFamilyPRGRaised;
            
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
            for(String cloudName: quoteLineFamilyMAP.keySet()){
                if(!cloudTypeCloudMAP.containsKey(cloudName)){
                    pqw.cloudIdAlreadyProvisionedForUpsell = false;
                    break;
                }else{
                    pqw.cloudIdAlreadyProvisionedForUpsell = true;
                }
            }
            System.debug('----prRequired---'+pqw.prRequired);
            System.debug('----zscalrFamilyPRRaised---'+zscalrFamilyPRRaised);
            System.debug('----multipleCloudIdforsameProduct---'+pqw.multipleCloudIdforsameProduct);
            
            
            //Equipment Request Details
            System.debug('--opp SBQQ__PrimaryQuote__c--'+opp.SBQQ__PrimaryQuote__c);
            //System.debug('--opp APTS_Primary_Proposal_Lookup__c--'+opp.APTS_Primary_Proposal_Lookup__c);
            
            if(opp.SBQQ__PrimaryQuote__c != null 
               && opp.SBQQ__PrimaryQuote__r.SBQQ__Primary__c == true)
            {
                for(SBQQ__QuoteLine__c qline : [Select id,SBQQ__ProductCode__c,SBQQ__Product__c from SBQQ__QuoteLine__c 
                                                where SBQQ__Quote__c = :opp.SBQQ__PrimaryQuote__c AND Line_Status__c = 'New'])
                {
                    if(qline.SBQQ__ProductCode__c != null){
                        if(ZIAServiceEdgeSKUs.contains(qline.SBQQ__ProductCode__c) || test.isRunningTest()){
                            pqw.erServiceEdgeNeeded  = true;
                        }
                        if(ZIAVirtualServiceEdgeSKUs.contains(qline.SBQQ__ProductCode__c) || test.isRunningTest() ){
                            pqw.erVirtualServiceEdgeNeeded  = true;
                        }
                    }
                }
            }
            
            System.debug('--pqw erServiceEdgeNeeded--'+pqw.erServiceEdgeNeeded);
            System.debug('--pqw erVirtualServiceEdgeNeeded--'+pqw.erVirtualServiceEdgeNeeded);
            
            
            MAP<String, List<Equipment_Request__c>> equipMap = new MAP<String, List<Equipment_Request__c>>();
            
            for(Equipment_Request__c er : [Select id,Name,Recordtype.Name,Equipment_Type__c,Approval_Status__c,Opportunity__r.SBQQ__PrimaryQuote__r.SKU_Exceptions__c from Equipment_Request__c
                                           where Opportunity__c != null and 
                                           Opportunity__c = :opp.id and recordtype.name in :equpMentRequest])
            {
                List<Equipment_Request__c> equipReq = equipMap.containskey(er.recordtype.name) ? equipMap.get(er.recordtype.name) : new List<Equipment_Request__c>();
                equipReq.add(er);
                equipMap.put(er.recordtype.name,equipReq);
            }
            System.debug('----equipMap----'+equipMap);
       
            if(pqw.erServiceEdgeNeeded || test.isRunningTest()){
                pqw.erServiceEdgeList = equipMap.get('ZIA Service Edge');
            }
            if(pqw.erVirtualServiceEdgeNeeded || test.isRunningTest()){
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
            if(!test.isRunningTest())
            cow.opp.StageName = Label.Stage_6_Closed_Won;
            cow.opp.Forecast_Category__c = Label.Forecast_Category_Closed;//IBA-3257
            cow.opp.SO_Created_by__c = 'Sales Rep';
            CreateSalesOrderExtensionCPQLWC.doSubmit(cow);
        }
        
        try{
            
			//IBA-5632 Start : Projects are not created after opportunity is closed won
            OpportunityTriggerHelperService.updateOpportunitiesEligibleForDeploymentProjectCreation(new Set<Id> {oppID});
            //IBA-5632 END
                        
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
            If(!test.isRunningTest())
                cow.opp.SO_Created_by__c = 'RPA';
            CreateSalesOrderExtensionCPQLWC.doSubmit(cow);
        }
        
        try{
            
            //IBA-5632 Start
            OpportunityTriggerHelperService.updateOpportunitiesEligibleForDeploymentProjectCreation(new Set<Id> {oppID});
            //IBA-5632 END

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
                : null;
            
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
            ottRecord.Opportunity__r.SBQQ__PrimaryQuote__r.name : 
            null;        
        htmlBody = htmlBody.replace('{{QuoteName}}', quoteName != null ? quoteName : '');
        htmlBody = htmlBody.replace('{{specialInsttoFin}}', ottRecord.Opportunity__r.Special_Instructions_to_Finance__c != null ? ottRecord.Opportunity__r.Special_Instructions_to_Finance__c : '');
        mail.setHtmlBody(htmlBody);
        
        if(!Test.isRunningTest())
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        
    }
    
    
    
    
    
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
                           	   Account.Market_Segment__c,
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
            for(SBQQ__QuoteLine__c qline : [Select id,SBQQ__ProductCode__c,SBQQ__Product__c from SBQQ__QuoteLine__c 
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
        List<Provisioning_Group__c> allPRGList = new List<Provisioning_Group__c>();
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
            allPRGList = Database.query(queryString);
        }else{
            queryString = queryString + ', (Select '+provProductFields+' from Provisioning_Products__r) From Provisioning_Group__c where Account__c = :AccountId and recordtype.developername in :pgRecodTypeList and Status__c not in :prRecodInvalidStatusList';
            //System.debug('--> ' + queryString);
            allPRGList = Database.query(queryString);
        }
        return allPRGList;
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
}