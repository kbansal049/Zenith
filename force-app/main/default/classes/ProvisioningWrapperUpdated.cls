/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 06-03-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//ProvisioningWrapperUpdated class 
//New Request Format as per Dicussion : 13/02/2022
//https://docs.google.com/document/d/1ri_HjoiFkvwKxS40jVJilAZtnzMjahXcWEb5R0XYjQQ/edit

public without sharing class ProvisioningWrapperUpdated{
    public String actionType;
    public String activity;
    public String origin;
    
    public Cls_requestData requestData;
    
    public class Cls_requestData{
        public Cls_pg prGroup;
        public Cls_customer customer;
        public Cls_product[] licenses;
        public Cls_contact[] contacts;
    }
    
    public class Cls_pg {
        public String domains;
        public String additionalDomains;
        public String groupType;
        public String preferredCloud;
        public String prGroupId;
        public string pgNumber;
        public String productLine;
        public String proxyCloud;
        public String ziaOrgId;
        public String zpaOrgId;     
        public String salesOrderNumber;
        public String sendInitialCredentialsTo;
        public String requesterName;
        public String requesterLoginId;
        
        //cluster
        public String nanologCluster;
        public Integer nanologClusterId;
        public String sandboxCluster;
        public Integer sandboxClusterId;
        public String caCluster;
        public Integer caClusterId;
        public Boolean exceptionToClusterAssignment;
    }
    
    public class Cls_customer {
        public String accountId;
        public String accountType; 
        public String billingAddress;
        public String customerId;
        public String geoLocation;
        public String hqLocation;
        public String industryVertical;
        public String name;
        public string countryCode;
        public Integer numberOfEmployees;    
        public String accountOwner;
        public String region;
    }
    
    public class Cls_product {
        public String licenseProductLine;
        public String skuCode;
        //public String hasSpecialZPASKU;
        public String licenseCode;
        public String quantity;
        public String seatOrQuantity;
        public long endDate;
        public long startDate;
        public String status;
        public String type;
        public String totalRampQuantity;
    }
    
    public class Cls_contact {
        public String contactType;
        public String name;
        public String title;
        public String email;
        public String phone;
        public String altPhone;
        public String contactId;
    }
    
    public ProvisioningWrapperUpdated(){}
    
    public ProvisioningWrapperUpdated(Provisioning_Group__c prGrpRecord, 
                                      Account customer, 
                                      List<Provisioning_Contact__c> prvContacts, 
                                      List<Provisioning_Product__c> ppList, 
                                      MAP<ID, List<Product_License__c>> plMAP){
                                          this.requestData = new Cls_requestData();
                                          
                                          //Fill PG Record
                                          this.requestData.prgroup = getPGDetails(prGrpRecord);
                                          
                                          //Fill Customer Details
                                          this.requestData.customer = getCustomerDataFromAccountRecord(prGrpRecord, customer);
                                          
                                          //Fill PG Contacts Details
                                          this.requestData.contacts = getCustomerConatacts(prvContacts);
                                         
                                          
                                          //Fill PG Contacts Details
                                          this.requestData.licenses = getProductLicense(prGrpRecord, ppList, plMAP);    
                                      }
    
    @testvisible
    private Cls_pg getPGDetails(Provisioning_Group__c prGrpObj){
        System.debug('---getPGDetails--called---');
        Cls_pg clspg = new Cls_pg();
        clspg.prGroupId=prGrpObj.Id;
        clspg.pgNumber = prGrpObj.name;
        clspg.preferredCloud =  prGrpObj.Preferred_Cloud__c;
        clspg.salesOrderNumber = prGrpObj.opportunity__r.Netsuite_Sales_Order_Number__c != null ? prGrpObj.opportunity__r.Netsuite_Sales_Order_Number__c : '';
        if(prGrpObj.Product_Line__c=='ZDX')
            clspg.productLine = 'ZIA';
        else
            clspg.productLine = prGrpObj.Product_Line__c;
        clspg.sendInitialCredentialsTo = prGrpObj.Send_Initial_Login_Credentials_To__c;
        if(prGrpObj.Organization_Domain__c !=null)
        	clspg.domains = prGrpObj.Organization_Domain__c.toLowercase();
         clspg.additionalDomains= prGrpObj.Additional_Organization_domains__c!=null ? prGrpObj.Additional_Organization_domains__c.replaceAll('\\s+','').toLowerCase() : '';
        clspg.proxyCloud = prGrpObj.Proxy_Cloud__c; // hardcoded
        System.debug('clspg'+clspg);
        clspg.requesterName = prGrpObj.Owner.name ;
        clspg.requesterLoginId =  prGrpObj.Owner.Username;
        
        clspg.exceptionToClusterAssignment =prGrpObj.Exception_to_Cluster_assignment__c;
        if(prGrpObj.Provisioning_Process__c=='New Tenant' && prGrpObj.Product_Line__c=='ZIA' && prGrpObj.PG_Request_Type__c=='Create'){
            clspg.nanologCluster = prGrpObj.Nanolog_Cluster__r.Name;
            if(prGrpObj.Nanolog_Cluster__r.clusterId__c !=null)
                clspg.nanologClusterId = Integer.valueOf(prGrpObj.Nanolog_Cluster__r.clusterId__c);
            clspg.sandboxCluster = prGrpObj.Sandbox_Cluster__r.Name;
            if(prGrpObj.Sandbox_Cluster__r.clusterId__c !=null)
                clspg.sandboxClusterId =  Integer.valueOf(prGrpObj.Sandbox_Cluster__r.clusterId__c);
            clspg.caCluster = prGrpObj.SMCDSS_DLP_Cluster__r.Name;
            if(prGrpObj.SMCDSS_DLP_Cluster__r.clusterId__c !=null)
                clspg.caClusterId =  Integer.valueOf(prGrpObj.SMCDSS_DLP_Cluster__r.clusterId__c);
            
        }
        
        switch on prGrpObj.Product_Line__c{
            when 'ZIA'{
                System.debug('zia'+clspg);
                clspg.ziaOrgId = prGrpObj.Zscaler_Cloud_ID__r.Name;
            }
            when 'ZDX'{
                System.debug('zia'+clspg);
                clspg.ziaOrgId =prGrpObj.Associated_ZIA_Zscaler_Cloud__r.Name;
            }
            when 'ZPA'{
                System.debug('zpa'+clspg);
                clspg.zpaOrgId = prGrpObj.Zscaler_Cloud_ID__r.Name;
                clspg.ziaOrgId = prGrpObj.Associated_ZIA_Zscaler_Cloud__r.Name;
                //clspg.proxyCloud = prGrpObj.Preferred_Cloud__c;
                clspg.preferredCloud =  prGrpObj.ZPA_Preferred_Cloud__c;
            }
            when else{
                System.debug('else'+clspg);
                clspg.ziaOrgId = prGrpObj.Zscaler_Cloud_ID__r.Name;
            }
        }
        
        switch on prGrpObj.RecordType.name{
            when 'Subscription'{
                clspg.groupType = 'SUBSCRIBED';
            }
            when 'Trial' {
                clspg.groupType = 'TRIAL';
            }
        }
        
        return clspg;
    }
    
    @testvisible
    private Cls_customer getCustomerDataFromAccountRecord(Provisioning_Group__c prGrpRecord, Account customer){
        System.debug('---getCustomerDataFromAccountRecord--called---');
        Cls_customer cst= new Cls_customer();
        cst.name =  customer.name;
        cst.accountId = String.valueOf(customer.Id);
        cst.accountOwner = prGrpRecord.Owner.name;
        cst.accountType = prGrpRecord.RecordType.Name=='Subscription' ? 'Customer' : 'Prospect'; //customer.Type == 'Customer'? 'Customer' : 'Prospect';
        cst.billingAddress = customer.BillingCountry!=null ? customer.BillingCountry : '';
        cst.numberOfEmployees = customer.NumberOfEmployees;
        
        switch on prGrpRecord.Product_Line__c{
            when 'ZIA' , 'ZDX' {  
                String tenantCustId;
                if(prGrpRecord.Product_Line__c == 'ZIA')
                    tenantCustId = prGrpRecord.Zscaler_Cloud_ID__r.Customer_Id__c ;
                else if(prGrpRecord.Product_Line__c == 'ZDX')
                    tenantCustId = prGrpRecord.Associated_ZIA_Zscaler_Cloud__r.Customer_Id__c ;
                // if requesttype create or any other type and customerid is balnk at tenant level
                if(prGrpRecord.PG_Request_Type__c=='Create' || tenantCustId==null){
                    if(System.label.Beta_Clouds.contains(prGrpRecord.Preferred_Cloud__c)){
                        if(customer.ZIA_Customer_Id__c !=null && customer.ZIA_Customer_Id__c.contains(','))
                            cst.customerId = String.valueOf(customer.ZIA_Customer_Id__c.substringBefore(','));
                    	else
                        	cst.customerId = String.valueOf(customer.ZIA_Customer_Id__c);
                    }
                    else{
                        if(customer.ZPA_Customer_ID__c !=null && customer.ZPA_Customer_ID__c.contains(','))
                        	cst.customerId = String.valueOf(customer.ZPA_Customer_ID__c.substringBefore(','));
                        else
                            cst.customerId = String.valueOf(customer.ZPA_Customer_ID__c);
                    }
                } else {
                     cst.customerId = tenantCustId ;
                   /* else 
                    {
                        if(System.label.Beta_Clouds.contains(prGrpRecord.Preferred_Cloud__c))
                            cst.customerId = String.valueOf(customer.ZIA_Customer_Id__c);
                        else
                            cst.customerId = String.valueOf(customer.ZPA_Customer_ID__c);
                    } */
                }
            }
            when 'ZPA'{
                if(prGrpRecord.Zscaler_Cloud_ID__c !=null){
                    cst.customerId = prGrpRecord.Zscaler_Cloud_ID__r.name;//String.valueOf(customer.ZPA_Customer_ID__c);
                }
            }
           
            when else{
                cst.customerId = String.valueOf(customer.ZIA_Customer_Id__c);   
            }
        }
        if(customer.billingCountry != null){
            cst.hqLocation = customer.billingCountry;
        }
        else{
            cst.hqLocation ='US';
        }
        
        cst.industryVertical = customer.FP_A_Parent_industry__c != null ? customer.FP_A_Parent_industry__c : 'Others'; // Set Other if Industry is blank.
        String validIndValues = System.Label.FPA_Industry_Value;
        System.debug('validIndValues=='+validIndValues);
        List<String> lstValues = validIndValues.split(';');
        Map<String,String> mapSFDCwithBroker = new Map<String,String>();//lstValues
        for(String val : lstValues){
            mapSFDCwithBroker.put(val.substringBefore(','),Val.substringAfter(','));
        }
        
        if(mapSFDCwithBroker.containskey(customer.FP_A_Parent_industry__c) && mapSFDCwithBroker.get(customer.FP_A_Parent_industry__c)!=null){
            cst.industryVertical = mapSFDCwithBroker.get(customer.FP_A_Parent_industry__c);
        }
        
        //IBA-195
        cst.region = customer.Sales_Territory__r.Provisioning_Region__c; //US|EU broker having issue in region as EU so temp harcoded
        cst.geoLocation = customer.Sales_Territory__r.Provisioning_Geographical_Region__c != null ? customer.Sales_Territory__r.Provisioning_Geographical_Region__c :  'OTHER'; // hardcoded
        
        //IBA-1649
        Map<String,String> mapCountryWithCode = new map<String,String>();
        List<NS_Country_Code__mdt> countryCodeList= [Select Country__c, Label, NS_Code__c, X2_Digit_ISO_Code__c, X3_Digit_Code__c from NS_Country_Code__mdt];
        if(countryCodeList !=null){
            for(NS_Country_Code__mdt obj :countryCodeList){
                if(customer.BillingCountry.equalsIgnoreCase(obj.Country__c))
                    cst.countryCode = obj.X2_Digit_ISO_Code__c;
            }
        }
        
        System.debug('---getCustomerDataFromAccountRecord--cst---'+cst);
        return cst;
    }
    
    @testvisible
    private List<Cls_product> getProductLicense(Provisioning_Group__c prGrpRecord, List<Provisioning_Product__c> ppList, MAP<ID, List<Product_License__c>> plMAP){
        System.debug('---getProductLicense--called---'+ppList);
        System.debug('---getProductLicense--called--plMAP-'+plMAP);
        MAP<String, Cls_product> licences = new MAP<String,Cls_product>();
        
        // get the bundles startDate and set that as startdate for already provisioned ZDX
        Date maxBunldeStartDate = System.today().addYears(100);
             for(Provisioning_Product__c pp : ppList){
                     if(pp.Product__c != null && plMAP.containskey(pp.Product__c) && pp.Product__r.Provisioning_Product_Family__c=='Bundles'){
                         maxBunldeStartDate = maxBunldeStartDate> pp.Start_Date__c ? pp.Start_Date__c : maxBunldeStartDate;
                     }
                }
        // if ZDX then send ZIA licenses
        if(prGrpRecord.Product_Line__c=='ZDX' && prGrpRecord.Associated_ZIA_Zscaler_Cloud__c != null){
            System.debug(' prGrpRecord.Associated_ZIA_Zscaler_Cloud__c=='+ prGrpRecord.Associated_ZIA_Zscaler_Cloud__c);
            Wrapper wrp = getProductLicenseDetails(prGrpRecord.Associated_ZIA_Zscaler_Cloud__c,'ZDX');
           
            ppList.addAll(wrp.lstProd);
            plMAP.putAll(wrp.productLicenseMap);
        }
        
        // Send ZDX produt license on ZIA in case of 
        if(prGrpRecord.Product_Line__c=='ZIA' && prGrpRecord.PG_Request_Type__c=='Replace' && prGrpRecord.Zscaler_Cloud_ID__c !=null
           &&  prGrpRecord.RecordType.name=='Trial'){
            //lstcloud[0].Provisioning_Groups_ZIA_Cloud__r[0].Zscaler_Cloud_ID__c 
            Wrapper wrp = getProductLicenseDetails(prGrpRecord.Zscaler_Cloud_ID__c,'ZIA');//lstcloud[0].Provisioning_Groups_ZIA_Cloud__r[0].Zscaler_Cloud_ID__c);
             for(Provisioning_Product__c pp : wrp.lstProd){
                pp.Start_Date__c = pp.Start_Date__c > maxBunldeStartDate ? pp.Start_Date__c : maxBunldeStartDate;
            }
            ppList.addAll(wrp.lstProd);
            plMAP.putAll(wrp.productLicenseMap);
        }
        
        //public String type;
        //public Decimal totalRampQuantity;
        System.debug('ppList=='+ppList);
        
        if(prGrpRecord.Product_Line__c!='ZPA'){
            
            if(ppList != null){
                MAP<String, Product_License__c> productLicenecesToBePassed = new MAP<String, Product_License__c>();
                ///MAP<String, String> mapBundleSKU = new MAP<String, String>();
                Set<String> skuInBundles = new Set<String>();
                Decimal bundleProdQty;
                for(Provisioning_Product__c pp : ppList){
                    System.debug(pp.Product__c+'==pp.Product__c='+plMAP.containskey(pp.Product__c)+'=='+pp.Product__r.Provisioning_Product_Family__c);
                    if(pp.Product__c != null && plMAP.containskey(pp.Product__c) && pp.Product__r.Provisioning_Product_Family__c=='Bundles' ){ //
                        //  productLicenecesToBePassed.put(licence.Provisioning_License__c, licence);
                        for(Product_License__c  licence : plMAP.get(pp.Product__c)){ 
                            skuInBundles.add(licence.License_Code__c);
                            productLicenecesToBePassed.put(licence.Provisioning_License__c, licence);
                        }
                        for(Product_License__c  licence : productLicenecesToBePassed.values()){
                           Cls_product cont =  new Cls_product();
                            if(licence.License_Product_Line__c!=null && licence.License_Product_Line__c.contains(';')){
                                cont.licenseProductLine = licence.License_Product_Line__c.replace(';', ',');// licence.License_Product_Line__c;
                            }
                            else{
                                cont.licenseProductLine =licence.License_Product_Line__c;
                            }
                            cont.skuCode = licence.Product_SKU_Code__c; 
                            cont.licenseCode = licence.Provisioning_License__c; 
                            cont.seatOrQuantity = licence.License_Based_On__c;
                            
                            if(prGrpRecord.RecordType.Name == 'Trial' || pp.ContinueTrialForFutureDatedSku__c){
                                System.debug(licence.POV_Quantity__c+'Inside trial for quantity'+cont.licenseCode);
                                cont.quantity = licence.POV_Quantity__c != null ? String.valueOf(licence.POV_Quantity__c) : '0';
                                 cont.status = pp.ContinueTrialForFutureDatedSku__c ? 'continuetrial': cont.status;
                            }
                            
                            else{
                                List<String>lstlabel = System.label.SO_Quantity_Update.split(';');
                                if(! lstlabel.isEmpty()){
                                    Map<String,String> mapLicensewithQuantity = new map<String,String>();
                                    for(String st : lstLabel){
                                        mapLicensewithQuantity.put(st.substringBefore(','),st.substringAfter(','));
                                    }
                                    if(mapLicensewithQuantity !=null && mapLicensewithQuantity.size()>0){
                                        if(mapLicensewithQuantity.containskey(licence.Provisioning_License__c))
                                            cont.quantity = mapLicensewithQuantity.get(licence.Provisioning_License__c);
                                        else
                                            cont.quantity = pp.Quantity__c != null ? String.valueOf(pp.Quantity__c) : '0';
                                    }
                                }
                            }
                            cont.startDate = getEpoc(pp.Start_Date__c,prGrpRecord);
                            
                            if(prGrpRecord.RecordType.Name == 'Trial'){
                                if(prGrpRecord.Product_Line__c != 'ZDX'){
                                    cont.endDate = getEpocEndDate(prGrpRecord.ZSCM_End_Date__c,prGrpRecord);
                                }
                                else{
                                    cont.endDate = getEpocEndDate(getZscmEndDate(prGrpRecord.Associated_ZIA_Zscaler_Cloud__c),prGrpRecord);
                                }
                            }else{
                                cont.endDate =  getEpocEndDate(pp.End_Date__c,prGrpRecord); 
                            }
                            cont.type = pp.Product__r.Provisioning_Product_Family__c;
                            licences.put(cont.licenseCode, cont);
                             System.debug(cont.licenseCode+'=licences map=='+licences);
                            bundleProdQty = cont.quantity.isNumeric() && Decimal.valueOf(cont.quantity) > bundleProdQty ? Decimal.valueOf(cont.quantity): null;
                           // MaxbundleProdQty = bundleProdQty != null && bundleProdQty
							
                        }
                        
                         productLicenecesToBePassed.clear();
                       
                    }
                }
                 
                for(Provisioning_Product__c pp : ppList){
                    if(pp.Product__c != null && plMAP.containskey(pp.Product__c) && pp.Product__r.Provisioning_Product_Family__c !='Bundles'){
                        System.debug('add on started ');
                        //  MAP<String, Product_License__c> productLicenecesToBePassed = new MAP<String, Product_License__c>();
                        //Identify unique Provisioning_License__c
                        for(Product_License__c  licence : plMAP.get(pp.Product__c)){ 
                            productLicenecesToBePassed.put(licence.Provisioning_License__c, licence);
                        }
                        
                        for(Product_License__c  licence : productLicenecesToBePassed.values()){
                           // if( !skuInBundles.contains(licence.Provisioning_License__c) || System.label.exceptionSKUs.contains(licence.Provisioning_License__c)){
                                Cls_product cont =  new Cls_product();
                                if(licence.License_Product_Line__c!=null && licence.License_Product_Line__c.contains(';')){
                                    cont.licenseProductLine = licence.License_Product_Line__c.replace(';', ',');// licence.License_Product_Line__c;
                                }
                                else{
                                    cont.licenseProductLine =licence.License_Product_Line__c;
                                }
                                cont.skuCode = licence.Product_SKU_Code__c; 
                                cont.licenseCode = licence.Provisioning_License__c; 
                                cont.seatOrQuantity = licence.License_Based_On__c;
                                
                                if(prGrpRecord.RecordType.Name == 'Trial' || pp.ContinueTrialForFutureDatedSku__c){
                                    cont.quantity = licence.POV_Quantity__c != null ? String.valueOf(licence.POV_Quantity__c) : '0';
                                 cont.quantity = (bundleProdQty != null && cont.quantity.isNumeric() && Decimal.valueOf(cont.quantity) > bundleProdQty)? String.valueOf(bundleProdQty) : cont.quantity;
                                 System.debug(cont.quantity+'=cont.quantity=='+licence.POV_Quantity__c+'Inside trial of addon for quantity'+cont.licenseCode);
                                 cont.status = pp.ContinueTrialForFutureDatedSku__c ? 'continuetrial': cont.status;
                               
                                }
                                
                                else{
                                    List<String>lstlabel = System.label.SO_Quantity_Update.split(';');
                                    if(! lstlabel.isEmpty()){
                                        Map<String,String> mapLicensewithQuantity = new map<String,String>();
                                        for(String st : lstLabel){
                                            mapLicensewithQuantity.put(st.substringBefore(','),st.substringAfter(','));
                                        }
                                        if(mapLicensewithQuantity !=null && mapLicensewithQuantity.size()>0){
                                            if(mapLicensewithQuantity.containskey(licence.Provisioning_License__c)) //Provisioning_License__c
											 cont.quantity = mapLicensewithQuantity.get(licence.Provisioning_License__c);
                                            else
                                                cont.quantity = pp.Quantity__c != null ? String.valueOf(pp.Quantity__c) : '0';
                                            
                                             cont.quantity = (bundleProdQty != null && cont.quantity.isNumeric() && Decimal.valueOf(cont.quantity) > bundleProdQty)? String.valueOf(bundleProdQty) : cont.quantity;
                                
                                        }
                                        if(pp!=null && pp.SKU__c!=null && pp.Quantity__c!=null && (licence.Provisioning_License__c =='Z_DLP_EDM' || licence.Provisioning_License__c =='ZIA_ADD50K_URLS' )){//IBA-4778
                                            cont.quantity= getApproxQuantityForBroker(pp.Quantity__c, licence.Provisioning_License__c);//IBA-4778
                                        }
                                    }
                                }
                                cont.startDate = getEpoc(pp.Start_Date__c,prGrpRecord);
                                
                                if(prGrpRecord.RecordType.Name == 'Trial'){
                                    if(prGrpRecord.Product_Line__c != 'ZDX'){
                                        cont.endDate = getEpocEndDate(prGrpRecord.ZSCM_End_Date__c,prGrpRecord);
                                    }
                                    else{
                                        cont.endDate = getEpocEndDate(getZscmEndDate(prGrpRecord.Associated_ZIA_Zscaler_Cloud__c),prGrpRecord);
                                    }
                                }else{
                                    cont.endDate =  getEpocEndDate(pp.End_Date__c,prGrpRecord); 
                                }
                                cont.type = pp.Product__r.Provisioning_Product_Family__c;
                               licences.put(cont.licenseCode, cont);
                                System.debug(cont.licenseCode+'licences map=='+licences);
                            
                           // } 
                        }
                          productLicenecesToBePassed.clear();
                    }
                } 
               
                               
            }
        }        
        // In case of ZPA Special SKU
        /* else if(prGrpRecord.Product_Line__c=='ZPA'){
if( ! ppList.isEmpty()){
for(Provisioning_Product__c ppObj : ppList){
if(System.label.Special_ZPA_SKU.contains(ppObj.SKU__c)){
Cls_product cont =  new Cls_product();
cont.skuCode = ppObj.SKU__c;
//cont.hasSpecialZPASKU = 'Yes';
licences.put(ppObj.SKU__c, cont);
}
}
}
}  */
        
        System.debug('Licenses++'+licences);
        return licences.values();
    }

    //IBA-4778 Updated method to calculate 50000 additional URL quantity - Start
    public String getApproxQuantityForBroker(Decimal qty, String productLicense){
        String quantityToReturn = '';
        List<Quantity_Calculation_for_Z_DLP_EDM__mdt> mcs = Quantity_Calculation_for_Z_DLP_EDM__mdt.getAll().values();

        if(productLicense=='Z_DLP_EDM'){
            Decimal quantityToConsider = qty*25000;
            for(Quantity_Calculation_for_Z_DLP_EDM__mdt m:mcs){
                if(m.Is_DLP_EDM__c==true && m.Lower_Quantity_Range__c<= quantityToConsider && m.Higher_Quantity_Range__c>=quantityToConsider) {
                    quantityToReturn = m.Quantity_Passed_to_Broker__c;
                }
            }
        }if(productLicense=='ZIA_ADD50K_URLS'){
            Decimal quantityToConsider = qty*50000;
            for(Quantity_Calculation_for_Z_DLP_EDM__mdt m:mcs){
                if(m.Is_50000_Additional_URLs__c==true && m.Lower_Quantity_Range__c<= quantityToConsider && m.Higher_Quantity_Range__c>=quantityToConsider) {
                    quantityToReturn = m.Quantity_Passed_to_Broker__c;
                }
            }
        }    
        return quantityToReturn;
    }
    //IBA-4778 Updated method to calculate 50000 additional URL quantity - End
    
    @TestVisible
    private date getZscmEndDate(String zscalercloudId){
        Date dt = System.today();
        List<Zscaler_Cloud_ID__c> lstcloud = [select id,name,(select id,name,ZSCM_End_Date__c from Provisioning_Groups__r where product_line__c ='ZIA'
                                                              and Status__c = 'Provisioned' and Zscaler_Cloud_ID__c !=null)
                                              from Zscaler_Cloud_ID__c where id=: zscalercloudId order by createdDate Desc limit 1 ];
        if(lstcloud !=null && lstcloud.size()>0){
            if(lstcloud[0].Provisioning_Groups__r !=null && lstcloud[0].Provisioning_Groups__r.size()>0){
                return lstcloud[0].Provisioning_Groups__r[0].ZSCM_End_Date__c;
            }
        }
        return dt;
    }
    
    @TestVisible
    private Wrapper getProductLicenseDetails(String zscalercloudId, string type){
        System.debug('zscalercloudId=='+zscalercloudId);
        
        List<Zscaler_Cloud_ID__c> lstcloud =[select id,name,(select id,name from Provisioning_Groups__r where product_line__c ='ZIA'
                                                             and (Status__c='Provisioned' OR status__c='Pending Archival') and Zscaler_Cloud_ID__c != null order by createdDate Desc),
                                             (select id,name,Status__c,Zscaler_Cloud_ID__c from Provisioning_Groups_ZIA_Cloud__r where product_line__c ='ZDX'
                                              and (Status__c='Provisioned' OR status__c='Pending Archival') and Zscaler_Cloud_ID__c != null order by createdDate Desc)
                                             from Zscaler_Cloud_ID__c where id=: zscalercloudId limit 1];
        
        //System.debug('---lstcloud----'+lstcloud[0].Provisioning_Groups_ZIA_Cloud__r);
        List <Provisioning_Product__c> lstprod = new List<Provisioning_Product__c>();
        MAP<ID, List<Product_License__c>> plMAP = new MAP<ID, List<Product_License__c>>();
        if(lstcloud != null && lstcloud.size() > 0) {
            String pgToQuery ;
            if(type == 'ZIA'){
                if(lstcloud[0].Provisioning_Groups_ZIA_Cloud__r !=null && lstcloud[0].Provisioning_Groups_ZIA_Cloud__r.size()>0){
                    System.debug('lstcloud[0].Provisioning_Groups_ZIA_Cloud__r=='+lstcloud[0].Provisioning_Groups_ZIA_Cloud__r);
                    System.debug('PG '+ lstcloud[0].Provisioning_Groups_ZIA_Cloud__r[0].id);
                    pgToQuery =  lstcloud[0].Provisioning_Groups_ZIA_Cloud__r[0].id;
                }
            }else if(type == 'ZDX'){
                if(lstcloud[0].Provisioning_Groups__r !=null && lstcloud[0].Provisioning_Groups__r.size()>0){
                    System.debug('lstcloud[0].Provisioning_Groups__r=='+lstcloud[0].Provisioning_Groups__r);
                    System.debug('PG '+ lstcloud[0].Provisioning_Groups__r[0].id);
                    pgToQuery=  lstcloud[0].Provisioning_Groups__r[0].id;
                }
            }
            
            if(pgToQuery != null && pgToQuery != ''){
                lstprod = [select id,Name,
                           Product_Name__c,SKU__c,
                           Product_Family__c,
                           Product_Category__c,
                           Quantity__c,
                           Start_Date__c,End_Date__c,
                           
                           Product__c,
                           Product__r.Provisioning_Product_Family__c,
                           ContinueTrialForFutureDatedSku__c,
                           //PG Details
                           Provisioning_Group__c,
                           Provisioning_Group__r.Name,
                           
                           //Cloud Details
                           Zscaler_Cloud_ID__c,
                           Zscaler_Cloud_ID__r.Name,
                           CreatedDate,LastModifiedDate
                           from Provisioning_Product__c  
                           where Zscaler_Cloud_ID__c!=null 
                           and Provisioning_Group__c =:pgToQuery];
                
                Set<ID> productIDs = new Set<ID>();
                if(lstprod != null && lstprod.size() > 0){
                    for(Provisioning_Product__c pp : lstprod){
                        if(pp.Product__c != null){
                            productIDs.add(pp.Product__c);
                        }
                    }
                    List<Product_License__c> LicenseList = [Select License_Code__c,ID,Name,Product__c,Provisioning_License__c,POV_Quantity__c,License_SKU__c,Product_SKU_Code__c,License_Product_Line__c,
                                                            License_Based_On__c,License__c,Is_JIRA_Ticket_Required__c
                                                            from Product_License__c where License__c != null and Product__c != null and Product__c in : productIDs];
                    for(Product_License__c pc : LicenseList){
                        List<Product_License__c> pcList = plMAP.containsKey(pc.Product__c) ? plMAP.get(pc.Product__c) : new List<Product_License__c>();
                        pcList.add(pc);
                        plMAP.put(pc.Product__c, pcList);
                    }
                }
            }
        }
        Wrapper wrp = new Wrapper(lstprod,plMAP);
        return wrp;
    }
    
    public class Wrapper{
        public  List<Provisioning_Product__c> lstProd;
        public  MAP<ID, List<Product_License__c>> productLicenseMap;
        public Wrapper(List<Provisioning_Product__c> lstProd,MAP<ID, List<Product_License__c>> productLicenseMap)
        {
            this.lstProd = lstProd;
            this.productLicenseMap = productLicenseMap;
        }
    }
    
    Public long getEpocEndDate(Date dt,Provisioning_Group__c prGrpRecord){
        Datetime dtime = dt;
       Long l;
        if(dtime != null){
            dtime = dtime.addHours(23) ;
            dtime=dtime.addMinutes(59);
            dtime= dtime.addSeconds(59);
            l = dtime.getTime();
            l= l/1000;
          }
        return l;
    }
    
    // for handling start date
    Public long getEpoc(Date dt,Provisioning_Group__c prGrpRecord){
        Datetime dtime = dt;
        Long l;
        if(dtime != null){
            
            if(prGrpRecord.RecordType.Name == 'Subscription'){
                
                if(prGrpRecord.Account__r.Geo__c=='Americas'){
                    l= getEpocEndDate(dt,prGrpRecord);
                    return l;
                }
                else if(prGrpRecord.Account__r.Geo__c=='APJ' || prGrpRecord.Account__r.Geo__c=='EMEA'){
                    l = dtime.getTime();
                    l= l/1000;
                    return l;
                }
                else if(prGrpRecord.Account__r.Geo__c=='WW Enterprise'){
                    if(prGrpRecord.Account__r.Area__c.contains('AMS')){
                        l= getEpocEndDate(dt,prGrpRecord);
                        return l; 
                    }else if(prGrpRecord.Account__r.Area__c.contains('EMEA') || prGrpRecord.Account__r.Area__c.contains('APJ') ){
                        l = dtime.getTime();
                        l= l/1000;
                        return l;
                    }
                    
                }
                else if(prGrpRecord.Account__r.Geo__c=='WW Commercial'){ //
                    if(prGrpRecord.Account__r.District__c.contains('AMS')){
                        l= getEpocEndDate(dt,prGrpRecord);
                        return l; 
                    }else if(prGrpRecord.Account__r.District__c.contains('EMEA') || prGrpRecord.Account__r.District__c.contains('APJ') ){
                        l = dtime.getTime();
                        l= l/1000;
                        return l;
                    }
                    
                    
                }
                else{
                    l = dtime.getTime();
                    l= l/1000;
                    return l; 
                }
                
                
            } 
            else {
                l= getEpocEndDate(dt,prGrpRecord);
                return l;
            }
            
        }
        return l;
    }
    
    
    @testVisible
    private List<Cls_contact> getCustomerConatacts(List<Provisioning_Contact__c> prvContacts){
        System.debug('---getCustomerConatacts--called---');
        List<Cls_contact> contacts= new List<Cls_contact>();
        If(prvContacts !=null){
            For(Provisioning_Contact__c  contact: prvContacts){
                Cls_contact cont=  new Cls_contact();
                cont.name = contact.User_Name__c;
                cont.title = contact.User__r.title;
                cont.email = contact.Email__c;
                cont.contactType  = contact.Type__c;
                cont.phone = contact.User__r.phone;
                cont.altPhone = contact.User__r.phone;
                cont.contactId = contact.Id;
                contacts.add(cont);
            }
        }
        return contacts;
    }
    
    public static ProvisioningWrapperUpdated parse(String json){
        return (ProvisioningWrapperUpdated) System.JSON.deserialize(json, ProvisioningWrapperUpdated.class);
    }
}