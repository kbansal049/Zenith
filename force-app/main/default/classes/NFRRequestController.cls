public with sharing class NFRRequestController{
    
    @AuraEnabled
    public static NFRValidateWrapper validateForNFRComponent(Id accountId){
        System.debug('---accountId---'+accountId);
        
        Account acc = [Select id, domain__c,
                       Geo__c,Sales_Territory__c,
                       Sales_Territory__r.Preferred_ZIA_Cloud__c,
                       type,
                       OwnerId,Account_Manager__c, Market_Segment__c from Account where id =:accountId ];
    
        NFRValidateWrapper validate = new NFRValidateWrapper();
        validate.accountId = accountId;
        validate.acc = acc;
        validate.domain = acc.domain__c;
        validate.ziaClouds = new MAP<String,Id>();
        
        //set ZIA Cloud Ids for DropDown
        for(Zscaler_Cloud_ID__c zc : [Select id,Name from Zscaler_Cloud_ID__c where Cloud_Type__c = 'ZIA' and account__c = :accountId and  Status__c !='Decommisioned' ]){
            validate.ziaClouds.put(zc.Name, zc.id);
        }
        
        
        //set defaulte value of checkbox
        //validate.checkSKU = opp.SBQQ__PrimaryQuote__c != null ? true : false;
       
        validate.region = acc.Geo__c;
        
        validate.preferredZIA = acc.Sales_Territory__c != null && acc.Sales_Territory__r.Preferred_ZIA_Cloud__c != null ? acc.Sales_Territory__r.Preferred_ZIA_Cloud__c : null;
        
        
        //SE Required 
        validate.isSERequired = acc.type == 'Prospect' && acc.Market_Segment__c != 'Commercial' ? true : false;
        
        System.debug('---validate---'+validate);
        return validate;
    }

   	
    @AuraEnabled
    public static NFRValidateWrapper getALLPOCProducts(String jsonStr){
        
        NFRValidateWrapper nfrWrapper = (NFRValidateWrapper)JSON.deserialize(jsonStr, NFRValidateWrapper.class);
        List<POCProductWrapper> pocList = new List<POCProductWrapper>();
       
        String prodQuery = 'Select id,name,productcode, Product_Line__c,CBI_Provisioning__c,NSS_Provisioning__c from product2 where NFR_Product__c=true';
        /**    
        if (nfrWrapper.editions ==true) {
            prodQuery += ' AND productcode like \'%edition%\' and  (not name like \'%light%\') and  (not name like \'%fed%\')';
        } */
        
        List<Product2> productList =  Database.query(prodQuery); 
        for(Product2 pr:productList){
            pocList.add(new POCProductWrapper(pr));
        }
        nfrWrapper.pocProducts = pocList;
       
        return nfrWrapper;
    }
    
   
    
    @AuraEnabled
    public static Map<String,NFR__c> createNFRrecords(String jsonStr){
        
        String pocProducts;
        Map<String,NFR__c> nfrMapToReturn = new Map<String,NFR__c>();
        NFR__c nfrRecord = new NFR__c();
        
        NFRValidateWrapper nfrWrapper = (NFRValidateWrapper)JSON.deserialize(jsonStr, NFRValidateWrapper.class);
        
        List<POC_Product__c> pocListToInsert = new List<POC_Product__c>();
        
        nfrRecord.Number_of_Users__c=nfrWrapper.numberOfUsers;
        if(nfrWrapper.acc.type=='Partner'){
            nfrRecord.RecordTypeId=Schema.SObjectType.NFR__c.getRecordTypeInfosByDeveloperName().get('Partners').getRecordTypeId();
            nfrRecord.Comments__c =  nfrWrapper.additionalInfo;
        }
        else if(nfrWrapper.acc.type=='Technology Partner'){
            nfrRecord.RecordTypeId=Schema.SObjectType.NFR__c.getRecordTypeInfosByDeveloperName().get('Technology_Partners').getRecordTypeId();
            nfrRecord.Comments__c =  nfrWrapper.additionalInfo;
        }       
        nfrRecord.Contract_Term_Months__c=12;
        nfrRecord.Ask_Justification__c=nfrWrapper.justification;
        nfrRecord.Account_Name__c = nfrWrapper.accountId;
        nfrRecord.Additional_Organisation_Domain__c = nfrWrapper.additionalDomain;
        nfrRecord.Number_of_Users__c = 50;
        nfrRecord.Start_Date__c = nfrWrapper.startDate;
        if(nfrRecord.Start_Date__c != null){
            nfrRecord.Expiry_Date_FromStartDate__c = nfrRecord.Start_Date__c.addMonths(12);
        }
        nfrRecord.Organisation_Domain__c =  nfrWrapper.domain;
        nfrRecord.Preferred_Cloud__c = nfrWrapper.preferredZIA;
        nfrRecord.Preferred_ZPA_Cloud__c = nfrWrapper.preferredZPA;
        nfrRecord.NFR_Sales_Engineer__c= nfrWrapper.salesEngineer;
        if(nfrWrapper.ziaCloudIdForZPA!='Request New ZIA Tenant'){
            nfrRecord.ZIA_Org_ID_to_be_associated_with_ZPA__c = nfrWrapper.ziaCloudIdForZPA;
            nfrRecord.ZIA_Org_ID__c = nfrWrapper.ziaCloudIdForZPA;
            nfrRecord.Preferred_Cloud__c = '';
        }  
        
        nfrRecord.Cloud_With_POC_Products__c = JSON.serialize(nfrWrapper.cloudSkuMap);
        for(POCProductWrapper poc: nfrWrapper.pocProducts){
            pocProducts += poc.ProductCode  +';';
        }
        if(!String.isEmpty(pocProducts)){
        	nfrRecord.POC_Products__c = pocProducts.subString(4,pocProducts.length());
        }

        Set<String> credSendTo = new Set<String>();
        if(nfrWrapper.credDetails.size() > 0){
            for(CredentialDetails cred : nfrWrapper.credDetails){
                if(cred.Type == 'SE/PE'){
                //  nfrRecord.NFR_Sales_Engineer__c = cred.RecID;       
                    credSendTo.add('SE');
                    nfrRecord.Send_Initial_Credentials_To__c+=cred.Type+';';
                }else if(cred.Type == 'Partner'){
                    nfrRecord.Partner_Contact__c = cred.RecID;
                    nfrRecord.Send_Initial_Credentials_To__c+=cred.Type+';';
                    credSendTo.add('Partner');
                }else if(cred.Type == 'Account Manager'){
                    nfrRecord.Account_Manager__c = cred.RecID;
                    credSendTo.add('Account Manager');
                    nfrRecord.Send_Initial_Credentials_To__c+=cred.Type+';';
                }
            }
        }
        nfrRecord.Send_Initial_Credentials_To__c = String.join(new List<String>(credSendTo),';');
        
        insert nfrRecord;
        LIST<NFR__c> nfrList = [SELECT Id, Name,Additional_Organisation_Domain__c FROM NFR__c WHERE Id = :nfrRecord.Id LIMIT 1];
        nfrRecord.put('Name__c', nfrList.get(0).Name);
        nfrMapToReturn.put('NFR record', nfrRecord);
        return nfrMapToReturn;
        
       
    }

    @testvisible
    private static Boolean isValidId(String strId) {
        Boolean isValid = (strId InstanceOf ID) ? true : false ;
        return isValid;
    }
    
    public class NFRValidateWrapper{
        @AuraEnabled
        public String partnerType;
        @AuraEnabled
        public Date startDate = System.today();
        @AuraEnabled
        public Integer numberOfUsers;
        @AuraEnabled
        public Integer contractTerm;
        @AuraEnabled
        public Boolean justification = FALSE;
        @AuraEnabled
        public Boolean editions;
        @auraEnabled
        public string nssComments;
        @auraEnabled
        public string cloud;
        @auraEnabled
        public string region;
        @auraEnabled
        public string domain;
        @auraEnabled
        public String accountId;
        @auraEnabled
        public String accountManager;
        @auraEnabled
        public Account acc;
        @auraEnabled
        public List<String> selectedCloud;
        @auraEnabled
        public List<String> selectedDependencyProducts;
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
        public Map<String,List<String>> cloudSkuMap;
        
        @auraEnabled
        public String ziaCloudIdForZPA;
        
        @auraEnabled
        public MAP<String, ID> ziaClouds;

        @auraEnabled
        public String salesEngineer;
        
        @auraEnabled
        public List<POCProductWrapper> pocProducts;

        @auraEnabled
        public List<CredentialDetails> credDetails;
        
        @auraEnabled
        public List<String> preferredCloud;
        
        
        @auraEnabled
        public Boolean isSERequired;
        
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
        public boolean cbiProvisioning;
        @auraEnabled
        public boolean nssProvisioning;
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
            this.nssProvisioning= prd.NSS_Provisioning__c;
            this.cbiProvisioning = prd.CBI_Provisioning__c;
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
    
}