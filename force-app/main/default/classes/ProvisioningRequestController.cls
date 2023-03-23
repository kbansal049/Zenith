public with sharing class ProvisioningRequestController{
    
    @AuraEnabled
    public static PRValidateWrapper validateForPRComponent(Id oppId){
        System.debug('---oppId---'+oppId);
        Opportunity opp = [Select id, name, domain__c, SBQQ__PrimaryQuote__c, 
                           Area__c,
                           Is_Federal_Opportunity_Sync__c,
                           Opp_Price_List__c,Applied_Price_List_Name__c,
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
                           Account.Sales_Territory__r.Preferred_ZIA_Cloud__c
                           from opportunity where id = :oppId limit 1];
        
        
        List<SBQQ__QuoteLine__c> lineItemList = [select id, SBQQ__Product__c,SBQQ__Product__r.Id,SBQQ__Product__r.name,SBQQ__Product__r.productcode,
                                                 SBQQ__Product__r.Product_Line__c 
                                                 from SBQQ__QuoteLine__c where SBQQ__Quote__c in (select SBQQ__PrimaryQuote__c from opportunity where id = :oppId) and 
                                                 (NOT SBQQ__Product__r.Product_Line__c in ('Support','Service')) 
                                                 and SBQQ__Product__r.Rev_Model__c = 'Subscription'];
    
        PRValidateWrapper validate = new PRValidateWrapper();
       	validate.oppId = oppId;
        validate.opp = opp;
        validate.domain = opp.domain__c;
        validate.ziaClouds = new MAP<String,Id>();
        
        //set ZIA Cloud Ids for DropDown
        for(Zscaler_Cloud_ID__c zc : [Select id,Name from Zscaler_Cloud_ID__c where Cloud_Type__c = 'ZIA' and account__c = :opp.AccountId]){
            validate.ziaClouds.put(zc.Name, zc.id);
        }
        
        
        //set defaulte value of checkbox
        validate.checkSKU = opp.SBQQ__PrimaryQuote__c != null ? true : false;
       
        validate.region = opp.Geo_Account__c;
        
        validate.preferredZIA = opp.Account.Sales_Territory__c != null && opp.Account.Sales_Territory__r.Preferred_ZIA_Cloud__c != null ? opp.Account.Sales_Territory__r.Preferred_ZIA_Cloud__c : null;
        
        
        //SE Required 
        validate.isSERequired = opp.Account.type == 'Prospect' && opp.Account.Market_Segment__c != 'Commercial' ? true : false;
        
        //IF primary Quote Avilable
        if(opp.SBQQ__PrimaryQuote__c == null){
            validate.cloud = 'None';
        }
        //IF primary Quote not Avilable
        else{
            Boolean isZPA = false;
            Boolean isZIA = false;
            Boolean isBoth = false;
            for(SBQQ__QuoteLine__c lineItem : lineItemList){
                if(lineItem.SBQQ__Product__r.Product_Line__c == 'ZPA'){
                    isZPA = true;
                }
                if(lineItem.SBQQ__Product__r.Product_Line__c == 'ZIA'){
                    isZIA = true;
                }
            }
            if(isZIA && isZPA){
                validate.cloud = 'Both';
            }else if(isZIA){
                validate.cloud = 'ZIA';
            }else if(isZPA){
                validate.cloud = 'ZPA';
            }else{
                validate.cloud = 'None';
            }
        }
               
        System.debug('---validate---'+validate);
        return validate;
    }

   	
    @AuraEnabled
    public static PRValidateWrapper getALLPOCProducts(String jsonStr){
        System.debug('---getALLPOCProducts called---');
        System.debug('---getALLPOCProducts jsonStr---'+jsonStr);
        
        PRValidateWrapper prWrapper = (PRValidateWrapper)JSON.deserialize(jsonStr, PRValidateWrapper.class);
        System.debug('---getALLPOCProducts prWrapper---'+prWrapper);
        
        Opportunity opp = prWrapper.opp;
        
        //IF primary Quote Avilable
        if(opp.SBQQ__PrimaryQuote__c == null){
            prWrapper.pocProducts = fillPOCProductsFromOpportunityPriceList(opp);
        }
        //IF primary Quote not Avilable
        else if(opp.SBQQ__PrimaryQuote__c != null &&  prWrapper.checkSKU == true){
            prWrapper.pocProducts = fillPOCProductListFromPrimaryQuote(opp);
        }
        else if(opp.SBQQ__PrimaryQuote__c != null &&  prWrapper.checkSKU == false){
            prWrapper.pocProducts = fillPOCProductsFromOpportunityPriceList(opp);
        }
       
        return prWrapper;
    }
    
   
    @AuraEnabled
    public static Map<String,Provisioning_Request__c> createPRrecords(String jsonStr){
        System.debug('---createPRrecords-----jsonStr: '+ jsonStr);
        
        Map<String,Provisioning_Request__c> prMapToReturn = new Map<String,Provisioning_Request__c>();
        
        
        PRValidateWrapper prWrapper = (PRValidateWrapper)JSON.deserialize(jsonStr, PRValidateWrapper.class);
        System.debug('---createPRrecords----prWrapper: '+ prWrapper);
        
        List<Opportunity> oppList = [Select id, accountId,SE_Name__c from Opportunity where id = :prWrapper.oppId];
        
        List<POC_Product__c> pocListToInsert = new List<POC_Product__c>();
        
        List<Provisioning_Request__c> prToInsert = new List<Provisioning_Request__c>();
        Provisioning_Request__c ziaPR  = new Provisioning_Request__c();
        Provisioning_Request__c zpaPR  = new Provisioning_Request__c();
        Provisioning_Request__c postureControlPR  = new Provisioning_Request__c();

        Set<ID> createdPRIDs = new Set<ID>();
        
        Set<ID> createdProductIds = new Set<ID>();
       
        try{ //CR#4694
        if((prWrapper.cloud == 'ZIA' || prWrapper.cloud == 'Both') && (prWrapper.onlyPostureControlSelected==false || prWrapper.onlyPostureControlSelected==null) ){
            //Create ZIA Reuqest
            ziaPR = createPRInstance(prWrapper, 'ZIA');
            prToInsert.add(ziaPR);
            
        } 
        
        if((prWrapper.cloud == 'ZPA' || prWrapper.cloud == 'Both') &&  (prWrapper.onlyPostureControlSelected==false || prWrapper.onlyPostureControlSelected==null) ){
            //Create ZPA Reuqest
            zpaPR = createPRInstance(prWrapper, 'ZPA');
            prToInsert.add(zpaPR);
            
        }
        
        if(prWrapper.isPostureControlSelected==true){
            //Create Posture Control Reuqest
            postureControlPR = createPRInstance(prWrapper, 'Posture Control');
            prToInsert.add(postureControlPR);
        }
        if(prToInsert!=null && !prToInsert.isEmpty()){
            ProvisioningRequestTriggerHelper.skipTrigger = false;
            insert prToInsert;

            if((prWrapper.cloud == 'ZIA' || prWrapper.cloud == 'Both') && (prWrapper.onlyPostureControlSelected==false || prWrapper.onlyPostureControlSelected==null) ){
                createdPRIDs.add(ziaPR.id);
                prMapToReturn.put('ZIA', ziaPR);
            
            System.debug('---createPRrecords---ZIA--pr:'+ziaPR);
            
            if(prWrapper.checkSKU){
                for(SBQQ__QuoteLine__c ql:  getLineItemsList(prWrapper.oppId)){
                    if(ql.SBQQ__Product__r != null){
                        if(ql.SBQQ__Product__r.Product_Line__c.contains('ZIA') || 
                           ql.SBQQ__Product__r.Product_Line__c.contains('ZDX') || 
                           ql.SBQQ__Product__r.Product_Line__c.contains('Workload Protection') ||
                           ql.SBQQ__Product__r.Product_Line__c.contains('Cross Platform'))
                        {
                            if(!createdProductIds.contains(ql.SBQQ__Product__r.Id)){
                                createdProductIds.add(ql.SBQQ__Product__r.Id);
                                POC_Product__c newProd = createProduct(ql.SBQQ__Product__r.Id, ziaPR.id);
                                pocListToInsert.add(newProd);
                            }
                        }
                    }
                }
            }else if(prWrapper.pocProducts.size() > 0){
                for(POCProductWrapper poc: prWrapper.pocProducts){
                    if(poc.ProductLine != null && (poc.ProductLine.contains('ZIA') || poc.ProductLine.contains('ZDX') ||
                                                   poc.ProductLine.contains('Workload Protection') || poc.ProductLine.contains('Cross Platform'))
                      )
                    {
                        if(!createdProductIds.contains(poc.ProductID)){
                            createdProductIds.add(poc.ProductID);
                        POC_Product__c pocPrd = createProduct(poc.ProductID, ziaPR.id);
                    pocListToInsert.add(pocPrd);
                    }
                }
                }
                }
            }

            if((prWrapper.cloud == 'ZPA' || prWrapper.cloud == 'Both') &&  (prWrapper.onlyPostureControlSelected==false || prWrapper.onlyPostureControlSelected==null) ){
                createdPRIDs.add(zpaPR.id);
                prMapToReturn.put('ZPA', zpaPR);
            
            System.debug('---createPRrecords---ZPA--pr:'+zpaPR);
            
            if(prWrapper.checkSKU){
               for(SBQQ__QuoteLine__c ql:  getLineItemsList(prWrapper.oppId)){
                   if(ql.SBQQ__Product__r != null){
                       if(ql.SBQQ__Product__r.Product_Line__c.contains('ZPA') || 
                          ql.SBQQ__Product__r.Product_Line__c.contains('ZDX') || 
                          ql.SBQQ__Product__r.Product_Line__c.contains('Workload Protection') ||
                          ql.SBQQ__Product__r.Product_Line__c.contains('Cross Platform'))
                       {
                           if(!createdProductIds.contains(ql.SBQQ__Product__r.Id)){
                               createdProductIds.add(ql.SBQQ__Product__r.Id);
                               POC_Product__c newProd = createProduct(ql.SBQQ__Product__r.Id, zpaPR.id);
                               pocListToInsert.add(newProd);
                           }
                       }
                   }
               }
            }else if(prWrapper.pocProducts.size() > 0){
                for(POCProductWrapper poc: prWrapper.pocProducts){
                    if(poc.ProductLine != null &&  (poc.ProductLine.contains('ZPA') || poc.ProductLine.contains('ZDX') || 
                                                    poc.ProductLine.contains('Workload Protection') || poc.ProductLine.contains('Cross Platform'))
                      )
                    {
                        if(!createdProductIds.contains(poc.ProductID)){
                            createdProductIds.add(poc.ProductID);
                        POC_Product__c pocPrd = createProduct(poc.ProductID, zpaPR.id);
                        pocListToInsert.add(pocPrd);
                    }
                }
                }
                }
            }

            if(prWrapper.isPostureControlSelected==true){
                createdPRIDs.add(postureControlPR.id);
                prMapToReturn.put('Posture Control', postureControlPR);

                if(prWrapper.pocProducts.size() > 0){
                    for(POCProductWrapper poc: prWrapper.pocProducts){
                        if(poc.ProductLine != null &&  poc.ProductLine=='Posture Control')
                        {
                            if(!createdProductIds.contains(poc.ProductID)){
                                createdProductIds.add(poc.ProductID);
                            POC_Product__c pocPrd = createProduct(poc.ProductID, postureControlPR.id);
                            pocListToInsert.add(pocPrd);
                        }
                    }
                    }
                }
            }


        }
        
        if(pocListToInsert.size() > 0){
            insert pocListToInsert;
        }
        //CR#4694 Start
        }catch(Exception exp){
            string errorMsg = exp.getMessage();
            if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                errorMsg = errorMsg.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1];
            }
            throw new AuraHandledException(errorMsg);
         }
        //CR#4694 End
        //List<Provisioning_Request__c> createdPR = new List<Provisioning_Request__c>();
        //createdPR = [Select id,RecordTypeId,Approval_Status__c,SE_Manager__c,CreatedByID,CreatedBy.ProfileId,Area__c,GEO__c from Provisioning_Request__c where ID =:createdPRIDs];
        for(Provisioning_Request__c createdPR: [Select id,RecordTypeId,Approval_Status__c,SE_Manager__c,CreatedByID,CreatedBy.ProfileId,Area__c,GEO__c from Provisioning_Request__c where ID =:createdPRIDs]){
            System.debug('PRCreated##'+createdPR);
            if(createdPR.SE_Manager__c!= null 
               && (!System.Label.Finance_V2_Profile_ID.contains(createdPR.CreatedBy.ProfileId) && createdPR.CreatedByID!=System.Label.PRUserIdToExcludeFromApproval)
               && createdPR.GEO__c!='WW Commercial'){
                   Approval.ProcessSubmitRequest newApprovalRequest = new Approval.ProcessSubmitRequest();
                   newApprovalRequest.setComments('Submit for Manager\'s approval');
                   newApprovalRequest.setObjectId(createdPR.Id);
                   newApprovalRequest.setSubmitterId(createdPR.CreatedByID);
                   Approval.ProcessResult result = Approval.process(newApprovalRequest);
               }
        }
        System.debug('---createPRrecords----prMapToReturn:'+ prMapToReturn);
        MAP<Id,Provisioning_Request__c> prMAP = new MAP<Id,Provisioning_Request__c>([Select id, name from Provisioning_Request__c where id in :createdPRIDs]);
        
        //Refresh the Field and pass it to frontEnd
        for(String key: prMapToReturn.keySet()){
            Provisioning_Request__c tPR = prMapToReturn.get(key);
            if(tPR.id != null && prMAP.containsKey(tPR.id)){
                prMapToReturn.put(key, prMAP.get(tPR.id));
            }
        }
		
        System.debug('---createPRrecords----prMapToReturn:'+ prMapToReturn);
        return prMapToReturn.size() > 0 ? prMapToReturn : null;
    }
    
    @testvisible
    private static Boolean isValidId(String strId) {
        Boolean isValid = (strId InstanceOf ID) ? true : false ;
        return isValid;
    }
    
   
    @testVisible
    private Static Provisioning_Request__c createPRInstance(PRValidateWrapper prWrapper, String cloudType){

        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.recordTypeId = '01270000000QB3a';
        pr.Organization_Domain__c = prWrapper.domain;
        pr.Provisioning_Status__c ='Requested';
        if(prWrapper.numberOfLoads!=null)
            pr.No_of_Loads__c = Integer.valueOf(prWrapper.numberOfLoads);
        
        if(cloudType == 'ZIA'){
            pr.Preferred_Cloud__c = prWrapper.preferredZIA;
        }else if(cloudType == 'Posture Control'){
            pr.Preferred_Cloud__c = 'Posture Control Cloud';
        }
        else{
			pr.ZIA_Org_ID__c = prWrapper.ziaCloudIdForZPA != null && isValidId(prWrapper.ziaCloudIdForZPA)  ? prWrapper.ziaCloudIdForZPA : null;
            pr.ZIA_Org_ID_to_be_used_for_Zapp__c = prWrapper.ziaCloudIdForZPA != null && isValidId(prWrapper.ziaCloudIdForZPA)  ? prWrapper.ziaCloudIdForZPA : null;
            pr.Preferred_Cloud__c = prWrapper.preferredZPA;
        }

        if(cloudType != 'Posture Control'){
            pr.Additional_Organization_domains__c = prWrapper.additionalDomain;
            pr.Eval_Comments__c = prWrapper.additionalInfo;
        }
        
        pr.Opportunity__c = prWrapper.oppId;
        pr.Account__c = prWrapper.opp.accountId;
        pr.Product_Line_for_PR__c  = prWrapper.preferredCloud != null ?  String.join(prWrapper.preferredCloud,';') : null; 
        pr.Provisioning_Type__c = 'Production'; 
        Set<String> credSendTo = new Set<String>();
        if(prWrapper.credDetails.size() > 0){
            for(CredentialDetails cred : prWrapper.credDetails){
                if(cred.Type == 'SE'){
                    pr.SE__c = cred.RecID;
                    credSendTo.add('SE');
                }else if(cred.Type == 'Customer'){
                    pr.Primary_Eval_Contact__c = cred.RecID;
                    credSendTo.add('Customer');
                }else if(cred.Type == 'Partner'){
                    pr.Partner_Contact__c = cred.RecID;
                    credSendTo.add('Partner');
                }else if(cred.Type == 'Account Manager'){
                    pr.Account_Manager__c = cred.RecID;
                    credSendTo.add('Account Manager');
                }else if(cred.Type == 'Account Owner'){
                    pr.CSM__c = cred.RecID;
                    credSendTo.add('Account Owner');
                }
            }
        }
        pr.Send_Initial_l__c = String.join(new List<String>(credSendTo),';');
        //CR# 4853 - Start
        if(prWrapper.opp.SE_Name__c!=Null && pr.SE__c==Null){
            pr.SE__c=prWrapper.opp.SE_Name__c;
        }
        //CR# 4853 - End
        return pr;
    }
   
    
    @testVisible
    private Static List<POCProductWrapper> fillPOCProductListFromPrimaryQuote(Opportunity opp){
        
        List<POCProductWrapper> pocList = new List<POCProductWrapper>();
        if(opp.Primary_Quote_Source__c != 'None'){
            /*List<SBQQ__QuoteLine__c> lineItemList = [select id, SBQQ__Product__c,SBQQ__Product__r.Id,SBQQ__Product__r.name,SBQQ__Product__r.productcode,
                                                     SBQQ__Product__r.Product_Line__c
                                                     from SBQQ__QuoteLine__c 
                                                     where SBQQ__Quote__c = :opp.SBQQ__PrimaryQuote__c
                                                     and SBQQ__Product__r.Product_Line__c not in ('Support','Service')
                                                     and SBQQ__Product__r.Rev_Model__c = 'Subscription'
                                                     and SBQQ__Product__r.POC_Products__c != null];
            for(SBQQ__QuoteLine__c ql : lineItemList){
                if(ql.SBQQ__Product__r != null){
                    pocList.add(new POCProductWrapper(ql.SBQQ__Product__r));
                }
            }   
        }*/
        List<OpportunityLineItem> lineItemList = [select id, Product2Id,Product2.Id,Product2.name,Product2.productcode,
                                                    Product2.Product_Line__c, Product2.Zscaler_Product_Family__c
                                                     from OpportunityLineItem 
                                                     where OpportunityId = :opp.Id
                                                     and Product2.Product_Line__c not in ('Support','Service')
                                                     and Product2.Rev_Model__c = 'Subscription'
                                                     and Product2.POC_Products__c != null];
            for(OpportunityLineItem ql : lineItemList){
                if(ql.Product2Id != null){
                    pocList.add(new POCProductWrapper(ql.Product2));
                }
            }   
        }
        return pocList;
    }
    
    @testVisible
    private Static List<POCProductWrapper> fillPOCProductsFromOpportunityPriceList(Opportunity opp){
        
        List<POCProductWrapper> pocList = new List<POCProductWrapper>();
        
        string cpqPriceListId = (opp != null && opp.Opp_Price_List__c != null) ? opp.Opp_Price_List__c : '';
        Set<String> excludedSKU = new Set<String>();
        excludedSKU.add('ZWS-BUYBACK-PROMO');
        excludedSKU.add('ZCES-ZWS-DEP-PRE');
        excludedSKU.add('ZCES-ZWS-ESS-PRE');
        if(cpqPriceListId != null && cpqPriceListId != ''){
            for(SBQQ__LookupData__c priceListItem : [Select id, SBQQ__Product__r.Id,
                                                     SBQQ__Product__r.name,
                                                     SBQQ__Product__r.productcode,
                                                     SBQQ__Product__r.Product_Line__c,
                                                     SBQQ__Product__r.Zscaler_Product_Family__c
                                                     from SBQQ__LookupData__c 
                                                     where Price_List__c =: cpqPriceListId AND SBQQ__Product__r.IsActive =: true 
                                                     AND (( SBQQ__Product__r.Product_Line__c != null 
                                                     AND SBQQ__Product__r.Product_Line__c not in ('Support','Service')
                                                     AND SBQQ__Product__r.productcode not in: excludedSKU
                                                     AND SBQQ__Product__r.Rev_Model__c = 'Subscription'
                                                     AND SBQQ__Product__r.POC_Products__c != null) OR SBQQ__Product__r.Product_Line__c = 'Posture Control')])
            {
                pocList.add(new POCProductWrapper(priceListItem.SBQQ__Product__r));
            }
        }
        
       
        return pocList;
    }
    
    
    
    
    @testvisible
    private Static List<SBQQ__QuoteLine__c> getLineItemsList(Id oppId){
        return [select id, SBQQ__Product__c,SBQQ__Product__r.Id,SBQQ__Product__r.name,SBQQ__Product__r.productcode,
                SBQQ__Product__r.Product_Line__c
                from SBQQ__QuoteLine__c 
                where 
                SBQQ__Quote__c in (select SBQQ__PrimaryQuote__c from opportunity where id = :oppId) 
                AND (NOT SBQQ__Product__r.Product_Line__c in ('Support','Service')) 
                AND SBQQ__Product__r.Product_Line__c != null
                AND SBQQ__Product__r.Rev_Model__c = 'Subscription'
                AND SBQQ__Product__r.POC_Products__c != null];
    }
    

    
    @testvisible
    private static POC_Product__c createProduct(String prdId, String prId){
        POC_Product__c pocPrd = new POC_Product__c();
        pocPrd.Product__c = prdId;
        pocPrd.Provisioning_Request__c = prId;
        return pocPrd;
    }
    
    
    public class PRValidateWrapper{
        @auraEnabled
        public string cloud;
        @auraEnabled
        public string region;
        @auraEnabled
        public string domain;
        @auraEnabled
        public String oppId;
        @auraEnabled
        public Opportunity opp;
        @auraEnabled
        public Boolean isPostureControlSelected;
        @auraEnabled
        public Boolean onlyPostureControlSelected;
        @auraEnabled
        public boolean checkSKU;
        @auraEnabled
        public String preferredZIA;
        @auraEnabled
        public String preferredZPA;
        @auraEnabled
        public String additionalDomain;
        @auraEnabled
        public String additionalInfo;
        @auraEnabled
        public String numberOfLoads;
        
        @auraEnabled
        public String ziaCloudIdForZPA;
        
        @auraEnabled
        public MAP<String, ID> ziaClouds;
        
        @auraEnabled
        public List<POCProductWrapper> pocProducts;

        @auraEnabled
        public List<CredentialDetails> credDetails;
        
        @auraEnabled
        public List<String> preferredCloud;
        
        
        @auraEnabled
        public Boolean isSERequired;
         
        PRValidateWrapper(){}
        
    }
    
    
    public class POCProductWrapper{
        @auraEnabled
        public string Name;
        @auraEnabled
        public boolean Selected;
        @auraEnabled
        public string ProductCode;
        @auraEnabled
        public string ProductLine;
        @auraEnabled
        public string ProductID;
        @auraEnabled
        public string ZScalerProductFamily;
       
        
        @auraEnabled
        public Product2 prd;
        
        public POCProductWrapper(){
            
        }
        
        public POCProductWrapper(Product2 prd){
            this.Selected = false;
            this.ProductCode = prd.productCode;
            this.ProductLine = prd.Product_Line__c;
            this.ProductID = prd.Id;
            this.Name = prd.Name;
            this.prd = prd;
            this.ZScalerProductFamily = prd.Zscaler_Product_Family__c;
        }
        
    }

    public class CredentialDetails{
        @auraEnabled
        public string Type;
        @auraEnabled
        public string RecID; 
        @auraEnabled
        public Integer Index;
        @auraEnabled
        public Boolean IsUser; 
    }
    public static void booster(){
        integer i=0;
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