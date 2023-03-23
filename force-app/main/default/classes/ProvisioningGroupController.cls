/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-11-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class ProvisioningGroupController {
    public Static Id PGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
    public Static Id PGRecordTypeINTId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Internal Provisioning').getRecordTypeId();

    @AuraEnabled(Cacheable=true)
    public static List<Product2> getALLProductSKUforTable(List<String> prodLine, String priceList){
        List<Product2> prodlist = new List<Product2>();
        
        for(SBQQ__LookupData__c lookup : [Select Id, Name, Price_List__c,SBQQ__Product__c,  SBQQ__Product__r.Name,SBQQ__Product__r.Id, SBQQ__Product__r.product_line__c, 
                 SBQQ__Product__r.poc_products__c, SBQQ__Product__r.IsActive,SBQQ__Product__r.SKU_Type__c,SBQQ__Product__r.Provisioning_Product_Family__c,SBQQ__Product__r.Is_Applicable_for_POC__c,
                 SBQQ__Product__r.ProductCode,SBQQ__Product__r.isBundle__c,SBQQ__Product__r.Provisioning_Broker_Eligible__c  from SBQQ__LookupData__c where 
                 SBQQ__Product__r.Provisioning_Product_Family__c ='Bundles' AND SBQQ__Product__r.Is_Applicable_for_POC__c = true AND SBQQ__Product__r.isActive = true and SBQQ__Product__r.Product_Line__c =:prodLine 
                 and Price_List__c =: priceList]){                         
            prodlist.add(lookup.SBQQ__Product__r);
        }
        return prodlist;
    }
    
    @AuraEnabled
    public static Boolean checkifDraftexists(String oppId){
        List<Provisioning_Group__c> pgList=[Select id , name ,opportunity__c , recordtype.Name from Provisioning_Group__c where opportunity__c=:oppId and RecordType.Name='Draft' and status__c!='Archived'];
        if(!pgList.isEmpty()){
            return true;
        }else{
            return false;
        }
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<Zscaler_Cloud_ID__c> getZIAcloud(String accountId){
        return [Select id,Name from Zscaler_Cloud_ID__c where Cloud_Type__c = 'ZIA' and account__c = :accountId and  Status__c !='Decommisioned' ];
        
        
    }

    @AuraEnabled(Cacheable=true)
    public static boolean getZIAcloudfromPRG(String accountId){
        Boolean pgHasTenant;
        System.debug('Printing inside getZIAcloudfromPRG');
        List<Zscaler_Cloud_ID__c> zscListToreturn = new List<Zscaler_Cloud_ID__c>();
        List<Zscaler_Cloud_ID__c> zscList= [Select id,Name  ,(Select id ,status__c from Provisioning_Groups__r where status__c!='Pending Archival' OR status__c!='Provisioned') from Zscaler_Cloud_ID__c where Cloud_Type__c = 'ZIA' and 
        account__c = :accountId and  
        Status__c !='Decommisioned'];
        System.debug('Printing getZIAcloudfromPRG 2'+zscList);
        for(Zscaler_Cloud_ID__c z : zscList){
            if(z.Provisioning_Groups__r.size()>0){
                pgHasTenant= true;
            }else{
                pgHasTenant= false;
            }
        }
        System.debug('Printing&&&&& pgHasTenant'+pgHasTenant);
        return pgHasTenant;
    }
    @AuraEnabled(Cacheable=true)
    public static boolean getZIAcloudfromPR(String accountId){
        Boolean prHasTenant=false;
        List<Zscaler_Cloud_ID__c> zscListToreturn = new List<Zscaler_Cloud_ID__c>();
        List<Zscaler_Cloud_ID__c> zscList= [Select id,Name  ,(Select id from Provisioning_Requests3__r) from Zscaler_Cloud_ID__c where Cloud_Type__c = 'ZIA' and 
        account__c = :accountId and  
        Status__c !='Decommisioned' ];
        for(Zscaler_Cloud_ID__c z : zscList){
            if(z.Provisioning_Requests3__r.size()>0){
                prHasTenant =true;
        }else{
                prHasTenant =false;
    }
    }
        return prHasTenant;
    }



    @AuraEnabled(Cacheable=false)
    public static String updateProvisioningDetail(String seltenant , String pgId, String opportunityId){//partially done
        try{
            System.debug('seltenant :'+seltenant+' pgId :'+pgId+' opportunityId :'+opportunityId);
            Provisioning_Group__c oldpgzpa;
            List<Provisioning_Product__c> oldprovProdList;
            List<Provisioning_Product__c> newprovProdList= new List<Provisioning_Product__c>();
            // newproduct;
            List<Provisioning_Contact__c> oldprovContactList;
            List<Provisioning_Contact__c> newprovContactList= new List<Provisioning_Contact__c>();

            if(seltenant!=null || seltenant!=''){
                oldpgzpa=[Select id ,Default_Preferred_Cloud__c,Associated_ZIA_Zscaler_Cloud__c,recordtypeId,status__c ,Approval_Status__c,PG_Request_Type__c,opportunity__c , account__c ,Associated_Provisioning_Group__c,End_Date__c,Geo__c,Is_Active__c,Number_of_Extensions__c,Organization_Domain__c,Preferred_Cloud__c,Preferred_cloud_change_reason__c,Product_Line__c,Provisioning_Process__c
                        ,Provisioning_Request__c,Provisioning_Type__c,Renewed_From_Provisioning_Group__c,SE_Manager_Email__c,Send_Initial_Login_Credentials_To__c
                        ,Start_Date__c,ZPA_Preferred_Cloud__c,Zscaler_Cloud_ID__c from Provisioning_Group__c where id =:pgId];
            }
            System.debug('oldpgzpa :'+oldpgzpa);
            oldprovProdList=[Select id ,Product__c,End_Date__c,Start_Date__c,Quantity__c, name, provisioning_Group__c from Provisioning_Product__c where provisioning_Group__c=:oldpgzpa.id];
            oldprovContactList=[Select id , name ,Contact__c,Email__c,Type__c,User__c,Zscaler_Cloud_ID__c, Provisioning_Group__c from Provisioning_Contact__c where Provisioning_Group__c=:oldpgzpa.id];
            System.debug('oldprovProdList :'+oldprovProdList+' \noldprovContactList :'+oldprovContactList);
            if(oldpgzpa!=null){
                Provisioning_Group__c newpgzpa = oldpgzpa.clone(false , true , false , false);
                newpgzpa.Approval_Status__c='Not Submitted';
                newpgzpa.Renewed_From_Provisioning_Group__c=oldpgzpa.Id;
                //oldpgzpa.Provisioning_Process__c='Associate ZIA';
                newpgzpa.Provisioning_Process__c='Associate ZIA';
                newpgzpa.opportunity__c=oldpgzpa.opportunity__c;
                newpgzpa.Status__c='Initiated';
                newpgzpa.PG_Request_Type__c='Replace';
                newpgzpa.recordtypeId=PGRecordTypeId;
                //newpgzpa.Default_Preferred_Cloud__c=oldpgzpa.Default_Preferred_Cloud__c;

                newpgzpa.Associated_ZIA_Zscaler_Cloud__c=seltenant;
                if(newpgzpa!=null){
                    insert newpgzpa;
                    for(Provisioning_Product__c prod : oldprovProdList){
                        Provisioning_Product__c newproduct= prod.clone(false, true , false , false);
                        newproduct.provisioning_Group__c=newpgzpa.id;
                        if(newpgzpa.recordtypeId == PGRecordTypeId){
                            newproduct.Status__c = 'Trial';
                        }
                        newprovProdList.add(newproduct);
                    }
                    for(Provisioning_Contact__c cont : oldprovContactList){
                        Provisioning_Contact__c newcontact= cont.clone(false, true , false , false);
                        newcontact.provisioning_Group__c=newpgzpa.id;
                        newprovContactList.add(newcontact);
                    }
                }
                if(!newprovProdList.isEmpty() && newprovContactList.size()>0){
                    insert newprovProdList;
                }
                if(!newprovContactList.isEmpty() && newprovContactList.size()>0){
                    insert newprovContactList;
                }

                oldpgzpa.status__c='Pending Archival';
                update oldpgzpa;
            }
            return 'Success';
             
        }catch(Exception ex){
            System.debug('Error occured'+ex.getMessage()+ex.getLinenumber());
            ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupController','updateProvisioningDetail',ex);

            return 'Error';
        }
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<Product2> getPOVProductList(String criteria , String priceList){
        List<Product2> prodlist = new List<Product2>();
        for(SBQQ__LookupData__c lookup : [Select Id, Name, Price_List__c,SBQQ__Product__c, 
                 SBQQ__Product__r.Name,SBQQ__Product__r.Id, SBQQ__Product__r.product_line__c, 
                 SBQQ__Product__r.poc_products__c, SBQQ__Product__r.IsActive,SBQQ__Product__r.SKU_Type__c,
                 SBQQ__Product__r.Provisioning_Product_Family__c,SBQQ__Product__r.Is_Applicable_for_POC__c,
                 SBQQ__Product__r.ProductCode,SBQQ__Product__r.isBundle__c,SBQQ__Product__r.Provisioning_Broker_Eligible__c,
                 SBQQ__Product__r.SKU_Category__c,SBQQ__Product__r.Provisioning_Sub_Product_Line__c,SBQQ__Product__r.Auto_Provisioning_Status__c
                 from SBQQ__LookupData__c where SBQQ__Product__c != null and
                 SBQQ__Product__r.Provisioning_Product_Family__c IN ('AddOn', 'Package') AND SBQQ__Product__r.Is_Applicable_for_POC__c = true 
                 AND SBQQ__Product__r.isActive = true and SBQQ__Product__r.Product_Line__c =:criteria 
                 and Price_List__c =: priceList]){
            prodlist.add(lookup.SBQQ__Product__r);
        }
        return prodlist;
        //return [SELECT Id, Name,Product_Line__c, IsActive, ProductCode, SKU_Category__c, SKU_Type__c,Provisioning_Product_Family__c, Is_Applicable_for_POC__c, Provisioning_Sub_Product_Line__c, Provisioning_Broker_Eligible__c, Auto_Provisioning_Status__c FROM Product2 WHERE IsActive = true AND Is_Applicable_for_POC__c = true AND Provisioning_Product_Family__c IN ('AddOn', 'Package') AND Product_line__c = :criteria];
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<Product2> getPOVProductListCrossPlatform(String criteria , String priceList){
        List<Product2> prodlist = new List<Product2>();
        if(criteria!=null && criteria!='ZDX'){
            for(SBQQ__LookupData__c lookup : [Select Id, Name, Price_List__c,SBQQ__Product__c, 
                 SBQQ__Product__r.Name,SBQQ__Product__r.Id, SBQQ__Product__r.product_line__c, 
                 SBQQ__Product__r.poc_products__c, SBQQ__Product__r.IsActive,SBQQ__Product__r.SKU_Type__c,
                 SBQQ__Product__r.Provisioning_Product_Family__c,SBQQ__Product__r.Is_Applicable_for_POC__c,
                 SBQQ__Product__r.ProductCode,SBQQ__Product__r.isBundle__c,SBQQ__Product__r.Provisioning_Broker_Eligible__c,
                 SBQQ__Product__r.SKU_Category__c,SBQQ__Product__r.Provisioning_Sub_Product_Line__c,SBQQ__Product__r.Auto_Provisioning_Status__c
                 from SBQQ__LookupData__c where SBQQ__Product__c != null and
                 SBQQ__Product__r.Provisioning_Product_Family__c IN ('AddOn', 'Package') AND SBQQ__Product__r.Is_Applicable_for_POC__c = true 
                 AND SBQQ__Product__r.isActive = true and SBQQ__Product__r.Product_Line__c =:criteria 
                 and Price_List__c =: priceList]){
                prodlist.add(lookup.SBQQ__Product__r);
            }
        }
        ////Including bundles as well for ZDX in case of cross platform
        else if(criteria!=null && criteria=='ZDX'){
            for(SBQQ__LookupData__c lookup : [Select Id, Name, Price_List__c,SBQQ__Product__c, 
                 SBQQ__Product__r.Name,SBQQ__Product__r.Id, SBQQ__Product__r.product_line__c, 
                 SBQQ__Product__r.poc_products__c, SBQQ__Product__r.IsActive,SBQQ__Product__r.SKU_Type__c,
                 SBQQ__Product__r.Provisioning_Product_Family__c,SBQQ__Product__r.Is_Applicable_for_POC__c,
                 SBQQ__Product__r.ProductCode,SBQQ__Product__r.isBundle__c,SBQQ__Product__r.Provisioning_Broker_Eligible__c,
                 SBQQ__Product__r.SKU_Category__c,SBQQ__Product__r.Provisioning_Sub_Product_Line__c,SBQQ__Product__r.Auto_Provisioning_Status__c
                 from SBQQ__LookupData__c where SBQQ__Product__c != null and
                 SBQQ__Product__r.Provisioning_Product_Family__c IN ('AddOn', 'Package','Bundles') AND SBQQ__Product__r.Is_Applicable_for_POC__c = true 
                 AND SBQQ__Product__r.isActive = true and SBQQ__Product__r.Product_Line__c =:criteria 
                 and Price_List__c =: priceList]){
                prodlist.add(lookup.SBQQ__Product__r);
            }
        }
        return prodlist;
        //return [SELECT Id, Name,Product_Line__c, IsActive, ProductCode, SKU_Category__c, SKU_Type__c,Provisioning_Product_Family__c, Is_Applicable_for_POC__c, Provisioning_Sub_Product_Line__c, Provisioning_Broker_Eligible__c, Auto_Provisioning_Status__c FROM Product2 WHERE IsActive = true AND Is_Applicable_for_POC__c = true AND Provisioning_Product_Family__c IN ('AddOn', 'Package') AND Product_line__c = :criteria];
    }

    @AuraEnabled(Cacheable=true)
    public Static Account getAccountData(String accountId){
        Account accdata =[Select id , domain__c,BillingAddress,Sales_Territory__r.Preferred_ZIA_Cloud__c ,FP_A_Parent_industry__c,Industry from account where Id=:accountId];
        return accdata;
    }
    //get details from PRG from Provisioning Group
    @AuraEnabled(Cacheable=false)
    public static Provisioning_Group__c getTenantDetails(String seltenant){//done
        System.debug('selTenant :'+selTenant);
        List<Provisioning_Group__c> tenantPG =[Select id ,Organization_Domain__c ,  Preferred_Cloud__c ,name, Zscaler_Cloud_ID__c from Provisioning_Group__c 
                                         where Zscaler_Cloud_ID__c=:seltenant and (Status__c='Provisioned' OR Status__c='Pending Archival') and  Product_Line__c ='ZIA' limit 1] ;
        System.debug('tenantPG :'+tenantPG);
        if(tenantPG!=null && tenantPG.size()>0){
            return tenantPG[0];
        }else{
            return null;
        }
    }
    //get details of tenant from ProvisioningRequest
    @AuraEnabled(Cacheable=false)
    public static Provisioning_Request__c getTenantDetailsfromPR(String seltenant){//done
        System.debug('selTenant :'+selTenant);
        Provisioning_Request__c tenantPR =[Select id ,Organization_Domain__c ,  Preferred_Cloud__c ,name, Zscaler_Cloud_ID__c from Provisioning_Request__c 
                                         where Zscaler_Cloud_ID__c=:seltenant limit 1] ;
        System.debug('tenantPG :'+tenantPR);
        if(tenantPR!=null){
           // istenantfromPR=true;
            return tenantPR;
        }else{
            return null;
        }
    }

    @Auraenabled
    public static List<Provisioning_Group__c> createInternalProvisioningDetails(string jsonStr, List<string> selProd){//partiallly done
        Savepoint sp = Database.setSavepoint();
        List<Provisioning_Group__c> provGroupListCreated= new List<Provisioning_Group__c>();
        List<Provisioning_Product__c> procProdListToUpdate = new List<Provisioning_Product__c>();
        List<Provisioning_Contact__c> provContactListToUpdate = new List<Provisioning_Contact__c>();
        Map<String,List<Provisioning_Product__c>> prodLineVsProvProduct = new Map<String,List<Provisioning_Product__c>>();
        Map<String,Provisioning_Group__c> prodLineVsProvGroup = new Map<String,Provisioning_Group__c>();
        List<Provisioning_Group__c> nonZIAPGs = new List<Provisioning_Group__c>();
        Provisioning_Group__c ziaPG = new Provisioning_Group__c();
        Map<String,List<String>> quoteLineDataMap = new Map<String,List<String>>();
        provisioningDetailsWrapper provWrapper = (provisioningDetailsWrapper)JSON.deserialize(jsonStr,provisioningDetailsWrapper.class);
        System.debug('provWrapper'+provWrapper);
        System.debug('Products'+provWrapper.provProdWrapper);
        System.debug('provWrapper.withPrimaryQuoteProducts'+provWrapper.withPrimaryQuoteProducts);

        if(provWrapper!=null && provWrapper.withPrimaryQuoteProducts==false){
            System.debug('inside PG creatiion 1 ');
            for(String productlineselected:selProd){
                if(productlineselected !='Workload Communication'){
                Provisioning_Group__c newPG = preparePGRecord(provWrapper, productlineselected , selProd,true);
                provGroupListCreated.add(newPG);
                System.debug('PG List created'+provGroupListCreated);
            }
                
            }
        }
        if(provGroupListCreated.size()>0){
            insert provGroupListCreated;
        }
        System.debug('provGroupListCreated :'+provGroupListCreated);
        for(Provisioning_Group__c pg :provGroupListCreated){
            String prodLine = pg.Product_Line__c;
            prodLineVsProvGroup.put(prodLine, pg);
            if(pg.Product_Line__c=='ZIA'){
                ziaPG = pg;
            }
        }
  
        for(Provisioning_Group__c pg:provGroupListCreated){
            if(ziaPg!=null && pg.Product_Line__c!='ZIA'){
                nonZIAPGs.add(new Provisioning_Group__c(id=pg.Id,Associated_Provisioning_Group__c =ziaPG.Id));
            }
        }

        if(!nonZIAPGs.isEmpty()){
            TriggerHandler.bypass('ProvisioningGroupTriggerHandler');
            update nonZIAPGs;
            TriggerHandler.clearBypass('ProvisioningGroupTriggerHandler');
        }

       
        /*********************************Creating Provisioning Product********************************************/
        if(provWrapper.provProdWrapper!=null){
            System.debug('inside product wrapper'+provWrapper.provProdWrapper);
            for(provisioningProducts provProd :provWrapper.provProdWrapper ){
                if(prodLineVsProvGroup.containsKey(provProd.prodline) || provProd.prodline=='Workload Communication') {
                    Provisioning_Product__c product = new Provisioning_Product__c();
                    product.Quantity__c = 100;
                    product.Start_Date__c = System.today();

                    //SF end date should include start date value as well. So the SF end date should be 30 days including start date
                    product.End_Date__c = System.today().addDays(29);
                    product.Status__c = 'Trial';
                    product.Name = provProd.productName;
                    if(provProd.prodline=='Workload Communication'){
                        product.Provisioning_Group__c = ziaPg.Id;
                    }else{
                    product.Provisioning_Group__c = prodLineVsProvGroup.get(provProd.prodline).id;
                    }
                    if(provProd.productSKUId!=null){
                        product.Product__c=provProd.productSKUId;
                        //If Cross-Platform is selected then Cross Platform Product is sent to Broker
                        if(provWrapper.crossPlatformSelected!=null && Boolean.valueOf(provWrapper.crossPlatformSelected)==true){
                            product.Product__c=provWrapper.crossPlatformProductId;
                            product.Name = provWrapper.crossPlatformProductName;
                        }           
                        if(quoteLineDataMap.containsKey(provProd.productSKUId+provProd.prodline)){
                            string subscriptionLinesData = String.join(quoteLineDataMap.get(provProd.productSKUId+provProd.prodline), ',');
                            product.Subscription_Lines_Data__c = subscriptionLinesData;
                        }
                    }
                    
                    if(provProd.productAddonnID!=null){
                        product.Product__c=provProd.productAddonnID;
                    }
                    procProdListToUpdate.add(product);
                    System.debug('procProdListToUpdate'+procProdListToUpdate);
                }
            }
        }
        
        /******************************Creating Provisioning Contact********************************************/
        for(Provisioning_Group__c newPG: prodLineVsProvGroup.values()){
            if(provWrapper.provContactWrapper!=null){
                for(ProvisioningContacts provCont :provWrapper.provContactWrapper ){
                    Provisioning_Contact__c pcontact = new Provisioning_Contact__c();
                    pcontact.Contact__c = provCont.contactId;
                    //pcontact.type__c= provCont.contactType;
                    pcontact.Provisioning_Group__c=newPG.Id;
                    provContactListToUpdate.add(pcontact);
                }
            }
        }
        
        /**************************inserting Lists **************************************************/
        try{
        if(!provContactListToUpdate.isEmpty() && provContactListToUpdate.size()>0){
            System.debug('inserting contact');
            insert provContactListToUpdate;
        }
        
        if(!procProdListToUpdate.isEmpty() && procProdListToUpdate.size()>0){
            insert procProdListToUpdate;
            System.debug('inserting products');
        }
        
        List<Provisioning_Group__c> pgToreturn = new List<Provisioning_Group__c>([SELECT Id, Name, Product_Line__c, Provisioning_Type__c, Status__c, Approval_Status__c FROM Provisioning_Group__c WHERE Id IN :provGroupListCreated]);
        return pgToreturn;            
        }
        
        catch(Exception ex){
          ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupController','createInternalProvisioningDetails',ex);
            return null;

        }
    }
    
    @AuraEnabled
    public static List<Provisioning_Group__c> createProvisioningDetails(string jsonStr, List<string> selProd){//partially done
        Savepoint sp = Database.setSavepoint();
        System.debug('json-->'+jsonStr+' \n selProd :'+selProd);
        try{
            List<Provisioning_Group__c> provGroupListCreated= new List<Provisioning_Group__c>();
            List<Provisioning_Product__c> procProdListToUpdate = new List<Provisioning_Product__c>();
            List<Provisioning_Contact__c> provContactListToUpdate = new List<Provisioning_Contact__c>();
            Map<String,List<Provisioning_Product__c>> prodLineVsProvProduct = new Map<String,List<Provisioning_Product__c>>();
            Map<String,Provisioning_Group__c> prodLineVsProvGroup = new Map<String,Provisioning_Group__c>();
            List<Provisioning_Group__c> nonZIAPGs = new List<Provisioning_Group__c>();
            Provisioning_Group__c ziaPG = new Provisioning_Group__c();
            Map<String,List<String>> quoteLineDataMap = new Map<String,List<String>>();
            
            //Ram S - Code fix for 'System.JSONException: Illegal value for primitive' issue
            if(jsonStr.contains('"selectedPostureControlProducts":[],')){
                jsonStr = jsonStr.replace('"selectedPostureControlProducts":[],', '');
            }
            if(jsonStr.contains('"selectedPostureControlProdAddOn":[]')){
                jsonStr = jsonStr.replace('"selectedPostureControlProdAddOn":[],', '');
            }
            provisioningDetailsWrapper provWrapper = (provisioningDetailsWrapper)JSON.deserialize(jsonStr,provisioningDetailsWrapper.class);
            System.debug('provWrapper'+provWrapper);
            System.debug('provWrapper.withPrimaryQuoteProducts'+provWrapper.withPrimaryQuoteProducts);
            
            /*********************************Provisioning Group Creation for Workload Communcation*******************/
            Provisioning_Group__c workLoadCommPRG = new Provisioning_Group__c();
            Provisioning_Group__c prgGroup = new Provisioning_Group__c();
            if(provWrapper.workloadCommunicationOnly=='true'){
                System.debug('provWrapper.associatedcloud'+provWrapper.associatedcloud);
                prgGroup = fetchPGRelatedListsToClone(provWrapper.associatedcloud);
                workLoadCommPRG = prgGroup.clone(false , true , false , false);
                System.debug('prgGroupclone'+workLoadCommPRG);
                workLoadCommPRG.Nanolog_Cluster__c = null;
                workLoadCommPRG.Sandbox_Cluster__c =null;
                workLoadCommPRG.SMCDSS_DLP_Cluster__c = null;
                workLoadCommPRG.status__c = 'Initiated';
                workLoadCommPRG.Workload_Communication_Product_Included__c = true;
                workLoadCommPRG.PG_Request_Type__c = 'Replace';
                workLoadCommPRG.RecordTypeId = PGRecordTypeId;
                workLoadCommPRG.Renewed_From_Provisioning_Group__c = prgGroup.Id;
                prgGroup.status__c='Pending Archival';
                provGroupListCreated.add(workLoadCommPRG);
                System.debug('prgGroup'+workLoadCommPRG);
            }
            
            /*********************************Creating Provisioning Group********************************************/
            if(provWrapper!=null && provWrapper.withPrimaryQuoteProducts==false){
                System.debug('inside PG creatiion 1 ');
                for(String productlineselected:selProd){
                    if(productlineselected !='Workload Communication'){
                    Provisioning_Group__c newPG = preparePGRecord(provWrapper, productlineselected , selProd,false);
                    provGroupListCreated.add(newPG);
                    System.debug('PG List created'+provGroupListCreated);
                }
                    
                }
            }
            /*********************************Creating Provisioning Group from Primary Quote********************************************/
            else if(provWrapper!=null && provWrapper.withPrimaryQuoteProducts==true){
                System.debug('provWrapper.opportunityId :'+provWrapper.opportunityId);
                List<ProvisioningProducts>  provisioiningProducts =fillProductListFromPrimaryQuote(provWrapper.opportunityId);
                List<String> prodLineFromQuote= new List<String>();
                System.debug('provisioningProducts :'+provisioiningProducts);
                for(ProvisioningProducts pp:provisioiningProducts){
                    System.debug('prodLineFromQuote :'+prodLineFromQuote);
                    System.debug('pp.prodline :'+pp.prodline);
                    if(!prodLineFromQuote.contains(pp.prodline)){
                        prodLineFromQuote.add(pp.prodline);
                    }
                    
                    if(!quoteLineDataMap.containsKey(pp.productSKUId+pp.prodline)){
                        provWrapper.provProdWrapper.add(pp);
                        quoteLineDataMap.put(pp.productSKUId+pp.prodline, new List<String>{pp.quotelineData});
                    }
                    else{
                        quoteLineDataMap.get(pp.productSKUId+pp.prodline).add(pp.quotelineData);
                        quoteLineDataMap.get(pp.productSKUId+pp.prodline).sort();
                    }
                }
                for(String productlineselected:prodLineFromQuote){
                    if(productlineselected !='Workload Communication'){
                        Provisioning_Group__c newPG = preparePGRecord(provWrapper, productlineselected , selProd,false);
                    provGroupListCreated.add(newPG);
                        System.debug('PG List created'+provGroupListCreated);
                    }
                }
            }
            insert provGroupListCreated;
            System.debug('@@provGroupListCreated'+provGroupListCreated);

            if(prgGroup!=null && provWrapper.workloadCommunicationOnly=='true'){
                update prgGroup;
            }

            if(provWrapper.postureControlSelected!=null && Boolean.valueOf(provWrapper.postureControlSelected)==true){
                List<String> postureControlProductsList = new List<String>();
                if(provWrapper.selectedPostureControlProdAddOn!=null){
                    postureControlProductsList.addAll(provWrapper.selectedPostureControlProdAddOn);
                }
                
                if(provWrapper.selectedPostureControlProducts!=null){
                    postureControlProductsList.add(provWrapper.selectedPostureControlProducts);
                }
                System.debug('postureControlProductsList'+postureControlProductsList);

                List<ProvisioningProducts> provisionPostureControlProds=fillProductListFromPostureControl(postureControlProductsList);
                for(ProvisioningProducts pp:provisionPostureControlProds){
                    if(!quoteLineDataMap.containsKey(pp.productSKUId+pp.prodline)){
                        provWrapper.provProdWrapper.add(pp);
                        quoteLineDataMap.put(pp.productSKUId+pp.prodline, new List<String>{pp.quotelineData});
                    }
                    else{
                        quoteLineDataMap.get(pp.productSKUId+pp.prodline).add(pp.quotelineData);
                        quoteLineDataMap.get(pp.productSKUId+pp.prodline).sort();
                    }
               }
            }
      
            for(Provisioning_Group__c pg :provGroupListCreated){
                String prodLine = pg.Product_Line__c;
                System.debug('@@prodLine'+prodLine);
                System.debug('@@prodLineVsProvGroup'+prodLineVsProvGroup);
                prodLineVsProvGroup.put(prodLine, pg);
                System.debug('@@prodLineVsProvGroup2'+prodLineVsProvGroup);
                if(pg.Product_Line__c=='ZIA'){
                    ziaPG = pg;
                }
            }
      
            for(Provisioning_Group__c pg:provGroupListCreated){
                if(ziaPg!=null && pg.Product_Line__c!='ZIA'){
                    nonZIAPGs.add(new Provisioning_Group__c(id=pg.Id,Associated_Provisioning_Group__c =ziaPG.Id));
                }
            }

            if(!nonZIAPGs.isEmpty()){
                TriggerHandler.bypass('ProvisioningGroupTriggerHandler');
                update nonZIAPGs;
                TriggerHandler.clearBypass('ProvisioningGroupTriggerHandler');
            }

            MAP<String, List<ProvisioningProducts>> productCatMAP = categrorizeProducts(provWrapper.provProdWrapper);
            for(String prLine : productCatMAP.keyset()){
                List<ProvisioningProducts> ppList = productCatMAP.get(prLine);
                
                Boolean checkIFCBIProductExist = checkifCBIProductExist(ppList);
                Boolean checkifDeceptionProductExist = checkifDeceptionProductExist(ppList);
                
                /*******************************CBI***********************************************/
                if(checkIFCBiProductExist){
                    Provisioning_Group__c assciatedPG = prodLineVsProvGroup.get(prLine);
                    Provisioning_Group__c cbiPG = new Provisioning_Group__c();
                    Provisioning_Group__c deceptionPG = new Provisioning_Group__c();
                    List<Provisioning_Group__c> pgToInsert = new List<Provisioning_Group__c>(); 
                    cbiPG = prepareSpecialCasePGRecord(provWrapper, assciatedPG,'CBI');
                    if(cbiPG != null){
                        provGroupListCreated.add(cbiPG);
                        pgToInsert.add(cbiPG);
                    }
                    
                    if(!pgToInsert.isEmpty() && pgToInsert!=null){
                        insert pgToInsert;
                    }
                    
                    /*********************************Creating Provisioning Product for CBI********************************************/
                    for(provisioningProducts provProd : ppList ){
                        if(provProd.isCBI != null && provProd.isCBI == true){
                            Provisioning_Product__c product = new Provisioning_Product__c();
                            product.Quantity__c = 100;
                            product.Start_Date__c = System.today();

                            //SF end date should include start date value as well. So the SF end date should be 30 days including start date
                            product.End_Date__c = System.today().addDays(29);

                            product.Name = provProd.productName;
                            product.Provisioning_Group__c=cbiPG.Id;
                            if(cbiPG.recordtypeId == PGRecordTypeId){
                                product.Status__c = 'Trial';
                            }
                            
                            if(provProd.productSKUId!=null){
                                product.Product__c=provProd.productSKUId;
                                if(quoteLineDataMap.containsKey(provProd.productSKUId+provProd.prodline)){
                                    string subscriptionLinesData = String.join(quoteLineDataMap.get(provProd.productSKUId+provProd.prodline), ',');
                                    product.Subscription_Lines_Data__c = subscriptionLinesData;
                                }
                            }
                            
                            if(provProd.productAddonnID!=null){
                                product.Product__c=provProd.productAddonnID;
                            }
                            procProdListToUpdate.add(product);
                        }
                    }
                    
                    /*********************************Creating Provisioning Contact for CBI********************************************/
                    if(provWrapper.provContactWrapper!=null){
                        for(ProvisioningContacts provCont :provWrapper.provContactWrapper ){
                            Provisioning_Contact__c pcontact = new Provisioning_Contact__c();
                            pcontact.User__c = provCont.userId;
                            pcontact.Contact__c = provCont.contactId;
                            pcontact.type__c= provCont.contactType;
                            pcontact.Provisioning_Group__c=cbiPG.Id;
                            provContactListToUpdate.add(pcontact);
                        }
                    }
                }

                /****************************************Deception******************************************** */
                if(checkifDeceptionProductExist){
                    Provisioning_Group__c assciatedPG = prodLineVsProvGroup.get(prLine);
                    Provisioning_Group__c deceptionPG = new Provisioning_Group__c();
                    List<Provisioning_Group__c> pgToInsert = new List<Provisioning_Group__c>(); 
                    deceptionPG = prepareSpecialCasePGRecord(provWrapper, assciatedPG,'Deception');

                    if(deceptionPG != null){
                        provGroupListCreated.add(deceptionPG);
                        pgToInsert.add(deceptionPG);
                    }
                    
                    if(!pgToInsert.isEmpty()){
                        insert pgToInsert;
                        System.debug('inserting PG'+pgToInsert);
                    }
                    
                    /*********************************Creating Provisioning Product for Deception********************************************/
                    for(provisioningProducts provProd : ppList ){
                        if(provProd.isDeception != null &&  provProd.isDeception==true){
                            Provisioning_Product__c product = new Provisioning_Product__c();
                            product.Quantity__c = 100;
                            product.Start_Date__c = System.today();

                            //SF end date should include start date value as well. So the SF end date should be 30 days including start date
                            product.End_Date__c = System.today().addDays(29);
                            if(deceptionPG != null && deceptionPG.recordtypeId == PGRecordTypeId){
                                product.Status__c='Trial';
                            }
                            product.Name = provProd.productName;
                            product.Provisioning_Group__c=deceptionPG.Id;
                            
                            if(provProd.productSKUId!=null){
                                product.Product__c=provProd.productSKUId;
                                if(quoteLineDataMap.containsKey(provProd.productSKUId+provProd.prodline)){
                                    string subscriptionLinesData = String.join(quoteLineDataMap.get(provProd.productSKUId+provProd.prodline), ',');
                                    product.Subscription_Lines_Data__c = subscriptionLinesData;
                                }
                            }
                            
                            if(provProd.productAddonnID!=null){
                                product.Product__c=provProd.productAddonnID;
                            }
                            procProdListToUpdate.add(product);
                        }
                    }
                    
                    /*********************************Creating Provisioning Contact for Deception********************************************/
                    if(provWrapper.provContactWrapper!=null){
                        for(ProvisioningContacts provCont :provWrapper.provContactWrapper ){
                            Provisioning_Contact__c pcontact = new Provisioning_Contact__c();
                            pcontact.User__c = provCont.userId;
                            pcontact.Contact__c = provCont.contactId;
                            pcontact.type__c= provCont.contactType;
                            
                            if(deceptionPG!=null){
                                pcontact.Provisioning_Group__c=deceptionPG.Id;
                            }
                            provContactListToUpdate.add(pcontact);
                        }
                    }
                }
            }
      
            /*********************************Creating Provisioning Product********************************************/
            if(provWrapper.provProdWrapper!=null){
                for(provisioningProducts provProd :provWrapper.provProdWrapper ){
                    if((prodLineVsProvGroup.containsKey(provProd.prodline) && provProd.isDeception == false && provProd.isCBI == false) || provProd.prodline=='Workload Communication'){
                        Provisioning_Product__c product = new Provisioning_Product__c();
                        product.Quantity__c = 100;
                        product.Start_Date__c = System.today();

                        //SF end date should include start date value as well. So the SF end date should be 30 days including start date
                        product.End_Date__c = System.today().addDays(29);
                        product.Status__c = 'Trial';
                        product.Name = provProd.productName;
                        if(provProd.prodline=='Workload Communication'){
                            product.Provisioning_Group__c = ziaPg.Id;
                        }else{
                        product.Provisioning_Group__c = prodLineVsProvGroup.get(provProd.prodline).id;
                        }           
                        if(provProd.productSKUId!=null){
                            product.Product__c=provProd.productSKUId;
                            if(provWrapper.crossPlatformSelected!=null && Boolean.valueOf(provWrapper.crossPlatformSelected)==true){
                                product.Product__c=provWrapper.crossPlatformProductId;
                                product.Name = provWrapper.crossPlatformProductName;
                            }
                            
                            if(quoteLineDataMap.containsKey(provProd.productSKUId+provProd.prodline)){
                                string subscriptionLinesData = String.join(quoteLineDataMap.get(provProd.productSKUId+provProd.prodline), ',');
                                product.Subscription_Lines_Data__c = subscriptionLinesData;
                            }
                        }
                        
                        if(provProd.productAddonnID!=null){
                            product.Product__c=provProd.productAddonnID;
                        }
                        procProdListToUpdate.add(product);
                        System.debug('procProdListToUpdate'+procProdListToUpdate);
                    }
                }
                if(provWrapper.workloadCommunicationOnly=='true'){
                    List<Provisioning_Product__c> prodFromOldPRGToAdd = new List<Provisioning_Product__c>();
                    for(Provisioning_Product__c product :workLoadCommPRG.Provisioning_Products__r){
                        Provisioning_Product__c newPovProd = product.clone(false , true , false , false);
                        newPovProd.Provisioning_Group__c = workLoadCommPRG.Id;
                        newPovProd.name = product.name;
                        newPovProd.Zscaler_Cloud_ID__c = NULL;
                        prodFromOldPRGToAdd.add(newPovProd);
                    }
                    procProdListToUpdate.addAll(prodFromOldPRGToAdd);
                    System.debug('procProdListToUpdated'+procProdListToUpdate);
                }
            }
            
            /******************************Creating Provisioning Contact********************************************/
            Map<String,Provisioning_Contact__c>  typeWithContactMap = new Map<String,Provisioning_Contact__c>();
            
            for(Provisioning_Group__c newPG: prodLineVsProvGroup.values()){
                if(provWrapper.provContactWrapper!=null){
                    for(ProvisioningContacts provCont :provWrapper.provContactWrapper ){
                        Provisioning_Contact__c pcontact = new Provisioning_Contact__c();
                        pcontact.User__c = provCont.userId;
                        pcontact.Contact__c = provCont.contactId;
                        pcontact.type__c= provCont.contactType;
                        pcontact.Provisioning_Group__c=newPG.Id;
                        pcontact.Zscaler_Cloud_ID__c = NULL;
                        provContactListToUpdate.add(pcontact);
                        typeWithContactMap.put(pcontact.type__c, pcontact);
                    }
                }
                
            }

            if(provWrapper.workloadCommunicationOnly=='true'){
                for(Provisioning_Contact__c contact :workLoadCommPRG.Provisioning_Contacts__r){
                    if(typeWithContactMap!=null && !typeWithContactMap.containsKey(contact.type__c)){
                        Provisioning_Contact__c newPovCont = contact.clone(false , true , false , false);
                        newPovCont.Provisioning_Group__c = workLoadCommPRG.Id;
                        provContactListToUpdate.add(newPovCont);
                    }
                }
            }
            
            /**************************inserting Lists **************************************************/
            if(!provContactListToUpdate.isEmpty() && provContactListToUpdate.size()>0){
                System.debug('inserting contact');
                insert provContactListToUpdate;
            }
            if(!procProdListToUpdate.isEmpty() && procProdListToUpdate.size()>0){
                insert procProdListToUpdate;
                System.debug('inserting products');
            }
            
            List<Provisioning_Group__c> pgToreturn = new List<Provisioning_Group__c>([SELECT Id, Name, Product_Line__c, Provisioning_Type__c, Status__c, Approval_Status__c FROM Provisioning_Group__c WHERE Id IN :provGroupListCreated]);
            return pgToreturn;
             
        }catch(Exception ex){
            ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupController','createProvisioningDetails',ex);

            Database.rollback( sp );
            System.debug('---Exeption----'+(ex.getmessage()+ ex.getLineNumber()+ ex.getStackTraceString()));
            throw new AuraHandledException(ex.getmessage()+ ex.getLineNumber()+ ex.getStackTraceString());
        }
    }
//Start of ticket IBA-4735
    public static Decimal fetchNumberofUsersOpp(String oppId){
        Decimal numofusers ;
        if(oppId!=null){
            numofusers = [Select Proposed_Number_of_Users__c ,id from Opportunity where id=:oppId].Proposed_Number_of_Users__c;
           
        }
        return numofusers;
    }
//end of IBA-4735*/
    
    public static Provisioning_Group__c preparePGRecord(provisioningDetailsWrapper provWrapper, String productlineselected ,List<String> selProd , boolean internalProvisioning ){//partially done
        MAP<String, List<ProvisioningProducts>> productCatMAP = categrorizeProducts(provWrapper.provProdWrapper);
        System.debug('productCatMap:'+productCatMAP);
       // System.debug('---internalProvisioning--'+internalProvisioning);
        
        List<ProvisioningProducts> ppList = productCatMAP.get(productlineselected);
       
        if(productlineselected=='ZIA' && productCatMAP.containsKey('Workload Communication')){
            ppList.addAll(productCatMAP.get('Workload Communication'));
        }
       
        Decimal numofOpportunityUsers=fetchNumberofUsersOpp(provWrapper.opportunityId);
        //System.debug('fetchNumberofUsersOpp---->'+numofOpportunityUsers);
        Provisioning_Group__c newPG = new Provisioning_Group__c();
        if(internalProvisioning){
            newPG.recordtypeId = PGRecordTypeINTId;
        }else{
            newPG.recordtypeId = PGRecordTypeId;
        }
        
        
        newPG.status__c = 'Initiated';
        newPG.PG_Request_Type__c = 'Create';
        newPG.Approval_Status__c = 'Not Submitted';
        
        newPG.Opportunity__c = provWrapper.opportunityId;
        newPG.Account__c = provWrapper.accountId;
        newPG.Product_Line__c = productlineselected;
        
        if(provWrapper.preferredZIA!=null){
            newPG.Preferred_Cloud__c=provWrapper.preferredZIA;
        }
        
         //IBA-3581  
        if(provWrapper.exceptionToCluster!=null){  
            newPG.Exception_to_Cluster_assignment__c=provWrapper.exceptionToCluster;  
        }  
        //IBA-2924 START  
        if(productlineselected=='ZIA'){  
            if(provWrapper.nanoLogCluster != NULL){  
                newPG.Nanolog_Cluster__c = provWrapper.nanoLogCluster;  
            }  
            if(provWrapper.sandboxCluster != NULL){  
                newPG.Sandbox_Cluster__c = provWrapper.sandboxCluster;  
            }  
            if(provWrapper.SMCDSSCluster != NULL){  
                newPG.SMCDSS_DLP_Cluster__c = provWrapper.SMCDSSCluster;  
            }  
        }  
        //IBA-2924 END
        
        //Creating confict to fix issue
        if(provWrapper.exceptionToCluster!=null){
            newPG.Exception_to_Cluster_assignment__c=provWrapper.exceptionToCluster;
        }
    
        //IBA-2924 START
        if(productlineselected=='ZIA'){
            if(provWrapper.nanoLogCluster != NULL){
                newPG.Nanolog_Cluster__c = provWrapper.nanoLogCluster;
            }
            if(provWrapper.sandboxCluster != NULL){
                newPG.Sandbox_Cluster__c = provWrapper.sandboxCluster;
            }
            if(provWrapper.SMCDSSCluster != NULL){
                newPG.SMCDSS_DLP_Cluster__c = provWrapper.SMCDSSCluster;
            }
        }
        //IBA-2924 END

       

        if(productlineselected=='Posture Control'){
            newPG.Provisioning_Type__c='Manual';
            newPG.Manually_Processed__c=true;
            newPG.Preferred_Cloud__c= 'Posture Control Cloud';
            if(provWrapper.numberOfWorkloads!=null){
                newPG.No_of_Workloads__c = Integer.valueOf(provWrapper.numberOfWorkloads);
            }
        }
        newPG.Provisioning_Process__c = 'New Tenant';
        if(productlineselected == 'ZDX'){
            newPG.PG_Request_Type__c = 'Replace';
        }
        newPG.Organization_Domain__c=provWrapper.domain;
        
        // IBA-511 START    
        newPG.PG_For_Subscription__c = provWrapper.pgForSubscription == true ? true : false;
        // IBA-511 END
        
        if(provWrapper.additionalDomain!=null){
            newPG.Additional_Organization_domains__c=provWrapper.additionalDomain;
        }
        
        if(provWrapper.preferedZIAReason!=null){
            newPG.Preferred_cloud_change_reason__c = provWrapper.preferedZIAReason;
        }

        newPG.Send_Initial_Login_Credentials_To__c = provWrapper.assignedToCred;
        newPG.Initial_Login_Credentials_Receiver_Email__c = provWrapper.initialLoginCredentialsReceiverEmail;
        
        if(internalProvisioning){
            newPG.Provisioning_Type__c='Manual';
            newPG.Manually_Processed__c=true;
            newPG.Provisioning_Broker_Eligible__c = true;
            
            newPG.is_internal_provisioning__c=internalProvisioning;
            newPG.Consumer_Contact__c=provWrapper.selectedContactIntProv;
            newPG.Internal_Provisioning_Requestor__c=provWrapper.loggedInUserId;
            if(provWrapper.selectedContactIntProv!=null){
                User conUser=getConsumerUser(provWrapper.selectedContactIntProv);
                newPG.Consumer_User__c=conUser.id;
                if(conUser.ManagerId!=null){
                    newPG.Consumer_user_Manager__c=conUser.ManagerId;
                }
                if(conUser.ManagerId!=null){
                    //Ram S - Commented to resolve deployment issue from ZPRDEV
                    //newPG.Consumer_user_Manager__c=conUser.ManagerId;
                }                
            }
        }

        if(provWrapper.comments!=null){
            newPG.Comments__c=provWrapper.comments;
        }
         boolean istenantfromPR=false;

        if(provWrapper.associatedcloud!=null){
            List<Provisioning_Request__c> tenantPR =[Select id ,Organization_Domain__c , ZIA_Org_ID__c, Preferred_Cloud__c ,name, Zscaler_Cloud_ID__c from Provisioning_Request__c 
            where ZIA_Org_ID__c=:provWrapper.associatedcloud limit 1] ;
            System.debug('tenantPG :'+tenantPR);
            if(tenantPR!=null && tenantPR.size()>0){
                istenantfromPR=true;
            
            }
        }
       
        
        if(selProd.size()==1 && provWrapper.associatedcloud!=null && provWrapper.associatedcloud!='ZPA Only' && productlineselected=='ZPA'){
            newPG.Associated_ZIA_Zscaler_Cloud__c = provWrapper.associatedcloud;
            newPG.status__c='Initiated';
        }else if(selProd.size()>1 && provWrapper.associatedcloud!=null && provWrapper.associatedcloud=='Request New ZIA Tenant' && productlineselected!='ZIA' && selProd.contains('ZIA')){
            newPG.status__c='Waiting';
        }else if(selProd.size()>1 && provWrapper.associatedcloud!=null && provWrapper.associatedcloud!='Request New ZIA Tenant' && productlineselected!='ZIA' && selProd.contains('ZIA')){
            newPG.Associated_ZIA_Zscaler_Cloud__c = provWrapper.associatedcloud;
            newPG.status__c='Initiated';
        }else if(selProd.size()==1 && provWrapper.associatedcloud!=null && provWrapper.associatedcloud=='ZPA Only' && productlineselected=='ZPA' ){
            newPG.status__c='Initiated';
            newPG.is_ZPA_Only__c=true;
        }else if(provWrapper.associatedcloud!='Request New ZIA Tenant' && productlineselected=='ZDX'){
            newPG.Associated_ZIA_Zscaler_Cloud__c = provWrapper.associatedcloud;
        }else if(provWrapper.associatedcloud!=null && (productlineselected=='Workload Protection' || productlineselected=='Workload Segmentation' || productlineselected=='Workload Communication')){
            newPG.Associated_ZIA_Zscaler_Cloud__c = provWrapper.associatedcloud;

        }
        
        if(productlineselected=='ZPA'){
            newPG.ZPA_Preferred_Cloud__c=provWrapper.preferredZPA;
        }
        
        if(provWrapper.startDate!=null){
            newPG.Start_Date__c=Date.valueOf(provWrapper.startDate);
        }else{
            newPG.Start_Date__c=System.today();
        }
        
        
        if(!internalProvisioning){
            if(ppList != null){
                boolean provbrokereligibility = true;
                for(ProvisioningProducts provProd : ppList){
                    //if((provProd.isCBI!=true && provProd.brokerEligibility!=true && provProd.isDeception!=true) || internalProvisioning){
                    //IBA-2793
                    System.debug('---provProd--'+provProd.productCode);
                    System.debug('---provProd.isCBI--'+provProd.isCBI);
                    System.debug('---provProd.brokerEligibility--'+provProd.brokerEligibility);
                    System.debug('---provProd.isDeception--'+provProd.isDeception);
                    if((provProd.isCBI != true && provProd.isDeception !=true ) && provProd.brokerEligibility != true){                   
                        newPG.Provisioning_Type__c='Manual';
                        newPG.Manually_Processed__c=true;
                        provbrokereligibility=false;
                        break;                                                                                                                     
                    }
                }
                newPG.Provisioning_Broker_Eligible__c = provbrokereligibility;
            }
        }
        //start IBA-4735
        if(numofOpportunityUsers>10000){
            System.debug('inside numofOpportunityUsers'+numofOpportunityUsers);
            newPG.Provisioning_Type__c='Manual';
            newPG.Manually_Processed__c=true;
            newPG.Provisioning_Broker_Eligible__c = false;
        }//end IBA-4735

        //SF end date should include start date value as well. So the SF end date should be 30 days including start date
        if(internalProvisioning){
            if(Date.isLeapYear(newPG.Start_Date__c.year())){
                newPG.End_Date__c = newPG.Start_Date__c.addDays(729);
            }else{
                newPG.End_Date__c = newPG.Start_Date__c.addDays(728);
            }
        }else{
            newPG.End_Date__c = newPG.Start_Date__c.addDays(29);
        }

        //ZSCM end date should include start date value as well. So the ZSCM end date should be 365 days for leap year (or) 364 days for non leap year including start date
        if(Date.isLeapYear(newPG.Start_Date__c.year())){
            newPG.ZSCM_End_Date__c = newPG.Start_Date__c.addDays(365);
        }else{
            newPG.ZSCM_End_Date__c = newPG.Start_Date__c.addDays(364);
        }

        if(provWrapper.crossPlatformSelected != null){
            newPG.Cross_Platform_Selected__c=Boolean.valueOf(provWrapper.crossPlatformSelected);
        }

        if(istenantfromPR){
            newPG.Provisioning_Type__c='Manual';
            newPG.Status__c='Initiated';
        }

        //Filling Cross Platform Product instead of the preselected Platform SKU
        if(provWrapper.crossPlatformSelected!=null && provWrapper.crossPlatformSelected=='true' && provWrapper.crossPlatformProductId!=null){
            newPG.Cross_Platform_Product__c=provWrapper.crossPlatformProductId;
            for(provisioningProducts provProd :provWrapper.provProdWrapper ){
                if(productlineselected!=null && productlineselected=='ZDX' && provProd.prodline=='ZDX' && provProd.productAddonnID!=null){
                    newPG.Provisioning_Broker_Eligible__c = true;
                }else if(productlineselected!=null && productlineselected=='ZDX' && provProd.prodline=='ZDX' && provProd.productAddonnID==null){
                    newPG.Provisioning_Broker_Eligible__c = false;
                }
            }
        }
        
        System.debug('777 ===>> In preparePGRecord(), newPG val is: '+newPG);
        return newPG;
    }
    
    public static user getConsumerUser(String selectedcontactId){
        User usr = null;
        String conEmail=[Select id ,email from Contact where id=:selectedcontactId].email;
        if(conEmail!=null || conEmail!=''){
            usr = [Select id , email , ManagerId  from user where email=:conEmail limit 1];
        }
        return usr;
    }
    
    public static Provisioning_Group__c prepareSpecialCasePGRecord(provisioningDetailsWrapper provWrapper, Provisioning_Group__c assciatedPG, String productLineForPG){
        Provisioning_Group__c newPG = new Provisioning_Group__c();
        newPG.recordtypeId = PGRecordTypeId;
        newPG.status__c = 'Initiated';
        if(assciatedPG != null && assciatedPG.Provisioning_Process__c != null && assciatedPG.Provisioning_Process__c == 'New Tenant'){
            newPG.status__c = 'Waiting';
        }
        newPG.PG_Request_Type__c = 'Create';
        newPG.Provisioning_Type__c = 'Manual';
        newPG.Provisioning_Broker_Eligible__c=false;
        newPG.Approval_Status__c = 'Not Submitted';
        newPG.Provisioning_Process__c = 'New Tenant';
        if(assciatedPG!=null)
            newPG.Associated_Provisioning_Group__c = assciatedPG.Id;
        newPG.Opportunity__c = provWrapper.opportunityId;
        newPG.Account__c = provWrapper.accountId;
        newPG.Product_Line__c = productLineForPG;
        newPG.Organization_Domain__c = provWrapper.domain;
        newPG.Send_Initial_Login_Credentials_To__c = provWrapper.assignedToCred;
        newPG.Initial_Login_Credentials_Receiver_Email__c = provWrapper.initialLoginCredentialsReceiverEmail;
        
        // IBA-511 START    
        newPG.PG_For_Subscription__c = provWrapper.pgForSubscription == true ? true : false;
        // IBA-511 END
        
        if(provWrapper.additionalDomain!=null){
            newPG.Additional_Organization_domains__c=provWrapper.additionalDomain;
        }

        if(provWrapper.comments!=null){
            newPG.Comments__c=provWrapper.comments;
        }
        
        if(provWrapper.preferredZIA!=null){
            newPG.Preferred_Cloud__c=provWrapper.preferredZIA;
        }
        
        if(provWrapper.associatedcloud!=null 
            && provWrapper.associatedcloud!='Request New ZIA Tenant'
            && provWrapper.associatedcloud!='ZPA Only'){
            newPG.Associated_ZIA_Zscaler_Cloud__c = provWrapper.associatedcloud;
        }
        
        if(provWrapper.startDate!=null){
            newPG.Start_Date__c=Date.valueOf(provWrapper.startDate);
        }else{
            newPG.Start_Date__c=System.today();
        }

        //SF end date should include start date value as well. So the SF end date should be 30 days including start date
        newPG.End_Date__c = newPG.Start_Date__c.addDays(29);

        //ZSCM end date should include start date value as well. So the ZSCM end date should be 365 days for leap year (or) 364 days for non leap year including start date
        if(Date.isLeapYear(newPG.Start_Date__c.year())){
            newPG.ZSCM_End_Date__c = newPG.Start_Date__c.addDays(365);
        }else{
            newPG.ZSCM_End_Date__c = newPG.Start_Date__c.addDays(364);
        }
        
        System.debug('999 ===>> In prepareSpecialCasePGRecord(), newPG val is: '+newPG);
        return newPG;
    }
    
    //197
    @Auraenabled(Cacheable=false)
    public static String createDraftProvisioningRecords(String jsonStr , Id draftpgId , Id oppId){//done
        try{
        // IBA-511 START    
        provisioningDetailsWrapper provWrapper = (provisioningDetailsWrapper)JSON.deserialize(jsonStr,provisioningDetailsWrapper.class); 
        // IBA-511 END
        Provisioning_Group__c pg;
        if(draftpgId!=null){
            pg=[Select id , Draft_Request__c from Provisioning_Group__c where id=:draftpgId];
        }else{
            pg = new Provisioning_Group__c();
            pg.Opportunity__c=oppId;
            Id recId=Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
            pg.recordtypeId=recId;
            // IBA-511 START    
            pg.PG_For_Subscription__c = provWrapper.pgForSubscription == true ? true : false;  
            // IBA-511 END
        }
        pg.Draft_Request__c=jsonStr;

        upsert pg;

        return pg.id;
            
        }catch(Exception ex){
           ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupController','createDraftProvisioningRecords',ex);
      return null;
        }
    }
    
    @auraEnabled 
    public static Contact getDefaultContact(String email){
        System.debug('Priniting default contact'+email);
        Contact con = [Select id , Name from Contact where email=:email limit 1];
        return con;
    }

    @Auraenabled(Cacheable=true)
    public static Provisioning_Group__c getDraftJSON(String draftpgId, String random){//done
        Provisioning_Group__c draftPG = [SELECT Id, Draft_Request__c FROM Provisioning_Group__c WHERE Id = :draftpgId];
        return draftPG;
    }
    
    public static MAP<String, List<provisioningProducts>> categrorizeProducts(List<provisioningProducts> provProds){//done
        MAP<String, List<provisioningProducts>> returnMAP = new MAP<String, List<provisioningProducts>>();
        for(provisioningProducts provProd : provProds){
            List<provisioningProducts>  ppList = returnMAP.containsKey(provProd.prodline) 
                            ? returnMAP.get(provProd.prodline)
                            : new List<provisioningProducts>();
        ppList.add(provProd);
        returnMAP.put(provProd.prodline, ppList);
        }
        return returnMAP;
    }
  
    public static Boolean checkifCBIProductExist(List<provisioningProducts> provProds){// will check
        Boolean ifCBiExist = false;
        if(provProds!=null){
            for(provisioningProducts provProd : provProds ){
                if(provProd.isCBI != null && provProd.isCBI == true){
                    ifCBiExist = true;
                    break;
                }        
            }
        }
        return ifCBiExist;
    }

    public static Boolean checkifDeceptionProductExist(List<provisioningProducts> provProds){//will check
        Boolean ifDeceptionExist = false;
        if(provProds!=null){
            for(provisioningProducts provProd : provProds ){
                if(provProd.isDeception != null && provProd.isDeception == true){
                    ifDeceptionExist = true;
                    break;
                }               
            }
        }
        return ifDeceptionExist;
    }
    
    @AuraEnabled(Cacheable=true)
    public static Boolean checkifPrimaryQuoteExist(String opp){// will check
        Boolean primaryQuoteExist = false;
        Opportunity oppor = [Select id,SBQQ__PrimaryQuote__c from Opportunity where id=: opp limit 1];
        System.debug('oppor :'+oppor.SBQQ__PrimaryQuote__c);
        if(oppor.SBQQ__PrimaryQuote__c!=null){
            primaryQuoteExist=true;
        }
        return primaryQuoteExist;
    }

    @AuraEnabled(Cacheable=true)
    public static List<ProvisioningProducts> fillProductListFromPrimaryQuote(String opp){// will check done
        System.debug('opp :'+opp);
        //Boolean crossPlaformInPrimaryQuote = false;
        List<ProvisioningProducts> pocList = new List<ProvisioningProducts>();
        List<Product2> prodList = new List<Product2>();
        list<Id> crossPlatformList = new List<Id>();
        List<OpportunityLineItem> lineItemList = [select id, Product2Id,Quantity,Product2.Id,Product2.name,Product2.productcode,
                                                    Product2.Product_Line__c,Product2.Provisioning_Sub_Product_Line__c,Product2.Provisioning_Broker_Eligible__c,
                                                    SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c,SBQQ__QuoteLine__r.SBQQ__EndDate__c,SBQQ__QuoteLine__r.SBQQ__StartDate__c
                                                     from OpportunityLineItem 
                                                     where OpportunityId = :opp
                                                     and Product2.Product_Line__c not in ('Support','Service')
                                                     and 
                                                    (Product2.Provisioning_Product_Family__c='Addon' OR 
                                                     Product2.Provisioning_Product_Family__c='Bundles' OR
                                                     Product2.Provisioning_Product_Family__c='Package')];
        System.debug('lineItemList :'+lineItemList);
        for(OpportunityLineItem ql : lineItemList){
            if(ql.Product2Id != null && ql.Product2.Product_Line__c!='Cross Platform'){
                pocList.add(new ProvisioningProducts(ql));
            }
            if(ql.Product2.Product_Line__c=='Cross Platform'){
                crossPlatformList.add(ql.Product2Id);
            }
        }

        if(crossPlatformList!=null && !crossPlatformList.isEmpty()){
            prodList = [SELECT id, name, productcode, 
                            Product_Line__c, Provisioning_Sub_Product_Line__c,
                            Provisioning_Broker_Eligible__c,
                            (SELECT id,Product__c,
                            Cross_Platform_Exception__c,
                            License_Product_Line__c 
                            FROM Product_Licenses__r WHERE Cross_Platform_Exception__c = true)
                        FROM Product2 WHERE id IN :crossPlatformList];
                           if(prodList!=null && !prodList.isEmpty() && prodList[0].Product_Licenses__r!=null 
                           && !prodList[0].Product_Licenses__r.isEmpty() 
                           && prodList[0].Product_Licenses__r[0].License_Product_Line__c!=null){
                String str =prodList[0].Product_Licenses__r[0].License_Product_Line__c;
                List<String> lstProductLines = str.split(';');
                for(String prodLine:lstProductLines){
                    Product2 prod = new Product2(id=prodList[0].Id, Provisioning_Sub_Product_Line__c=prodList[0].Provisioning_Sub_Product_Line__c,Provisioning_Broker_Eligible__c=prodList[0].Provisioning_Broker_Eligible__c);
                    prod.Product_Line__c = prodLine;
                    pocList.add(new ProvisioningProducts(prod));
                }
            }
        }
        return pocList;
    }

    @AuraEnabled(Cacheable=true)
    public static List<ProvisioningProducts> fillProductListFromPostureControl(List<String> prodCodes){// will check done
        System.debug('prodCodes :'+prodCodes);
        List<ProvisioningProducts> pocList = new List<ProvisioningProducts>();
        List<Product2> prodList = new List<Product2>();
        if(prodCodes!=null && !prodCodes.isEmpty()){
            prodList = [SELECT id,name, productcode, 
                           Product_Line__c, Provisioning_Sub_Product_Line__c,
                           Provisioning_Broker_Eligible__c,
                           (SELECT id,Product__c,
                           Cross_Platform_Exception__c,
                           License_Product_Line__c 
                           FROM 
                           Product_Licenses__r)
                        FROM Product2 WHERE productcode in:prodCodes];
            System.debug('prodList :'+prodList);
            for(Product2 prod:prodList){
                pocList.add(new ProvisioningProducts(prod));
            } 
        }
        System.debug('pocList'+pocList);
        return pocList;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<String> fillProductListFromPrimaryQuoteforContact(String opp){//done
        List<String> pocList = new List<String>();
        List<OpportunityLineItem> lineItemList = [select id, Product2Id,Quantity,Product2.Id,Product2.name,Product2.productcode,
                                                    Product2.Product_Line__c,Product2.Provisioning_Sub_Product_Line__c,Product2.Provisioning_Broker_Eligible__c,ProductCode,
                                                    SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c,SBQQ__QuoteLine__r.SBQQ__EndDate__c,SBQQ__QuoteLine__r.SBQQ__StartDate__c
                                                     from OpportunityLineItem 
                                                     where OpportunityId = :opp
                                                     and Product2.Product_Line__c not in ('Support','Service')
                                                     and 
                                                    (Product2.Provisioning_Product_Family__c='Addon' OR 
                                                     Product2.Provisioning_Product_Family__c='Bundles' OR
                                                     Product2.Provisioning_Product_Family__c='Package')];
        for(OpportunityLineItem q : lineItemList){
          
            if(q.Product2Id != null){
                pocList.add(q.ProductCode);
            }
        }
        return pocList;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<String> fillProductLineForPrimaryQuote(String opp){//done
        set<String> pocList = new set<String>();
        List<String> pocListreturn = new List<String>();
        List<Product2> crossPlatformProducts = new List<Product2>();
        List<Product2> prodList = new List<Product2>();

        List<OpportunityLineItem> lineItemList = [select id, Product2Id,Quantity,Product2.Id,Product2.name,Product2.productcode,
                                                    Product2.Product_Line__c,Product2.Provisioning_Sub_Product_Line__c,Product2.Provisioning_Broker_Eligible__c,ProductCode,
                                                    SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c,SBQQ__QuoteLine__r.SBQQ__EndDate__c,SBQQ__QuoteLine__r.SBQQ__StartDate__c
                                                     from OpportunityLineItem 
                                                     where OpportunityId = :opp
                                                     and Product2.Product_Line__c not in ('Support','Service')
                                                     and 
                                                    (Product2.Provisioning_Product_Family__c='Addon' OR 
                                                     Product2.Provisioning_Product_Family__c='Bundles' OR
                                                     Product2.Provisioning_Product_Family__c='Package')];
        System.debug('>>lineItemList :'+lineItemList);
        for(OpportunityLineItem q : lineItemList){
          
            if(q.Product2Id != null && q.Product2.Product_Line__c!='Cross Platform'){
                pocList.add(q.Product2.Product_Line__c);
            }
            if(pocList!=null){
                pocListreturn.addAll(pocList);
            }
            if(q.Product2.Product_Line__c=='Cross Platform'){
                crossPlatformProducts.add(q.Product2);
            }
        }

        if(crossPlatformProducts!=null && !crossPlatformProducts.isEmpty()){
            prodList = [SELECT id,name, productcode, 
                       Product_Line__c, Provisioning_Sub_Product_Line__c,
                       Provisioning_Broker_Eligible__c,
                       (SELECT id,Product__c,
                       Cross_Platform_Exception__c,
                       License_Product_Line__c 
                       FROM 
                       Product_Licenses__r WHERE Cross_Platform_Exception__c=true
                       )
                       FROM Product2 WHERE id in:crossPlatformProducts];
            if(prodList!=null && !prodList.isEmpty() && prodList[0].Product_Licenses__r!=null 
                && !prodList[0].Product_Licenses__r.isEmpty() 
                && prodList[0].Product_Licenses__r[0].License_Product_Line__c!=null){
                        String str =prodList[0].Product_Licenses__r[0].License_Product_Line__c;
                        if(str.contains(';')){
                            List<String> lstProductLines = str.split(';');
                            for(String prodLine:lstProductLines){
                                pocListreturn.add(prodLine);
                            }
                }
        }
      }

      return pocListreturn;
  }
    

    @AuraEnabled(Cacheable=true)
    public static List<String> getAllProductLineForPrimaryQuote(String opp){//done
      set<String> pocList = new set<String>();
      List<String> pocListreturn = new List<String>();

      List<OpportunityLineItem> lineItemList = [select id, Product2Id,Quantity,Product2.Id,Product2.name,Product2.productcode,
                            Product2.Product_Line__c,Product2.Provisioning_Sub_Product_Line__c,Product2.Provisioning_Broker_Eligible__c,ProductCode,
                            SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c,SBQQ__QuoteLine__r.SBQQ__EndDate__c,SBQQ__QuoteLine__r.SBQQ__StartDate__c
                             from OpportunityLineItem 
                             where OpportunityId = :opp
                             and Product2.Product_Line__c not in ('Support','Service')
                                                         and Product2.Name!='Zscaler Work from Anywhere Business Edition'
                                                         and 
                            (Product2.Provisioning_Product_Family__c='Addon' OR 
                             Product2.Provisioning_Product_Family__c='Bundles' OR
                             Product2.Provisioning_Product_Family__c='Package')];
      System.debug('>>lineItemList :'+lineItemList);
      for(OpportunityLineItem q : lineItemList){
        
        if(q.Product2Id != null && q.Product2.Product_Line__c != null && !pocList.contains(q.Product2.Product_Line__c)){
          pocList.add(q.Product2.Product_Line__c);
        }
        if(pocList!=null){
          pocListreturn.addAll(pocList);
        }
        
      }
      return pocListreturn;
    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getRequiredContacts(List<String> selectedProduct){//done
      List<Product2> selProductData;
      System.debug('>>selectedProduct :'+selectedProduct);
      Set<String> requiredContactType= new Set<String>();
      List<String> listOfContactType= new List<String>();
      Set<String> contacttype = new Set<String>();
      if(selectedProduct!=null && selectedProduct.size()>0)
      selProductData=[Select id , ProductCode ,Provisioning_Contact_Type__c from Product2 where ProductCode IN:selectedProduct];
      System.debug('>>selProductData :'+selProductData);
      for(Product2 p :selProductData){
        if(p.Provisioning_Contact_Type__c!=null){
          contacttype.addAll(p.Provisioning_Contact_Type__c.split(';'));
        }
      }
       
      if(contacttype.size()>0){
        listOfContactType.addAll(contacttype);
      }
      return listOfContactType;
    }

    @auraenabled
    public static Contact searchAndCreateContactRecord(String seUserId,String accId){//defective
      List<Contact> existingcont=new List<Contact>();
      Contact newcont;
      String getEmail;
      User seuserDetails;
            try{
      if(seUserId!=null || seUserId!=''){
         seuserDetails=[Select id , firstname , lastname , Email,Phone from user where id=:seUserId];
        getEmail=seuserDetails.email;
      }
      System.debug('seuserDetails!=null :'+seuserDetails);
      if(seuserDetails!=null){
        existingcont=[Select id, firstname, lastname, email, phone, AccountId from Contact where email = :getEmail limit 1];
        if(existingcont.size()>0){
          return existingcont[0];
        }else{
          newcont= new Contact();
          newcont.FirstName=seuserDetails.FirstName;
          newcont.lastname=seuserDetails.lastname;
          newcont.AccountId=Test.isRunningTest() ? accId : System.Label.Account_of_Zscaler;
          newcont.Email=seuserDetails.email;
          //newcont.Phone=seuserDetails.Phone;
          insert newcont;
        }
      }
                if(newcont!=null){
                 return newcont;
                }else{
                    return null;
                }
                
            }catch(Exception ex){
             ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupController','searchAndCreateContactRecord',ex);
       return null;
            }
                
    }
    
    @auraenabled
    public static Boolean domainCheckWithExistingCloud(String domain,String preferredZIA){//done
      System.debug('domain :'+domain+' \npreferredZIA :'+preferredZIA);
      Boolean domainAlreadyPresent = false;
      List<String> fields= new List<String> ();
      fields.add('Zscaler_Cloud_Domain__c');
      fields.add('name');
      List<Zscaler_Cloud_ID__c> existingClouds=SearchController.search('Zscaler_Cloud_ID__c', fields, domain, null);
      System.debug('existingClouds :'+existingClouds);
      for(Zscaler_Cloud_ID__c clouds:existingClouds){
        if(clouds.Zscaler_Cloud_Domain__c!=null && clouds.name!=null && 
          domain!=null && preferredZIA!=null && 
          clouds.Zscaler_Cloud_Domain__c==domain && clouds.Name.containsIgnoreCase(preferredZIA)){
          domainAlreadyPresent=true;
        }
      }
      return domainAlreadyPresent;
    }

    /******************** Platform products/ Product Lines included in the selected Cross Platform Product*/
    @AuraEnabled(cacheable=true)
    public static Map<Id,String> productsInThisCrossPlatform(String prod){//defective
      System.debug('prod :'+prod);
      List<Product_License__c> productLicenseList =[select id,name, Provisioning_License__c from 
                              Product_License__c where Product__r.ProductCode =:prod 
                              and Cross_Platform_Bundle__c =true];
      System.debug('>>>productLicenseList :'+productLicenseList);
      List<String> provLicenseList = new List<String>();
      if(productLicenseList!=null){
        for(Product_License__c prodLicense : productLicenseList){
          provLicenseList.add(prodLicense.Provisioning_License__c);
        }
      }
      System.debug('provLicenseList :'+provLicenseList);
      List<Product_License__c> listToFetchPlatformSKUs = [SELECT  id,Provisioning_License__c, product__c,
                                Product__r.Product_Line__c, Product__r.Provisioning_Product_Family__c,
                                Product__r.Is_Applicable_for_POC__c, Product__r.isActive
                                from Product_License__c where Provisioning_License__c
                                IN : provLicenseList AND  Cross_Platform_Bundle__c=false
                                AND Product__r.Provisioning_Product_Family__c='Bundles'
                                AND Product__r.Is_Applicable_for_POC__c=true
                                AND Product__r.isActive=true ]; 
      Map<Id,String> productVsProdLine= new Map<Id,String>();
      if(listToFetchPlatformSKUs!=null){
        for(Product_License__c license:listToFetchPlatformSKUs){
          if(!productVsProdLine.containsKey(license.product__c)){
            productVsProdLine.put(license.product__c,license.product__r.Product_Line__c);
          }
        }
      }
      System.debug('productVsProdLine'+productVsProdLine);
      return productVsProdLine;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Product2> getCrossPlatformProduct(String prod){//done
      return [select id,productCode,name,Product_Line__c,POC_Products__c,
          IsActive,SKU_Type__c,Provisioning_Product_Family__c,Is_Applicable_for_POC__c,
          isBundle__c, Provisioning_Broker_Eligible__c from product2 where productCode =: prod limit 1];
    }

    @AuraEnabled(Cacheable=true)
    public static List<Product2> getCrossPlatformProductsToShow(){
      return [SELECT Id, Name, IsActive, ProductCode  FROM Product2 WHERE IsActive = true AND Is_Applicable_for_POC__c = true AND  Product_line__c = 'Cross Platform' and ProductCode!='ZS-WFA-BUS-EDITION'];
    }

    @AuraEnabled(Cacheable=true)
    public static Opportunity getPriceListFromOpp(String opp){
      return [SELECT Id, Name,Opp_Price_List__c  FROM Opportunity WHERE id=: opp];
    }

        @AuraEnabled(Cacheable=true)
    public static Provisioning_Group__c fetchPGRelatedListsToClone(String associatedcloudWithPRG){
      Provisioning_Group__c pg = [ SELECT Id, Account__c, Additional_Organization_domains__c, Approval_Comments__c, 
                                        Approval_Status__c, Associated_Provisioning_Group__c, Associated_ZIA_Zscaler_Cloud__c,
                                        Comments__c, Consumer_Contact__c, Consumer_User__c, Consumer_user_Manager__c, 
                                        Cross_Platform_Product__c, Cross_Platform_Selected__c, Draft_Request__c, End_Date__c, 
                                        Extension_Reason__c, Extension_Requested_On__c, Failure_Reason__c, 
                                        Initial_Login_Credentials_Receiver_Email__c, Integration_Status__c, 
                                        Internal_Provisioning_Requestor__c, Is_Internal_Provisioning__c, 
                                        Is_Jira_Ticket_Required__c, Jira_ticket_No__c, Manually_Processed__c, No_of_Workloads__c,
                                         Number_of_Extensions__c, Opportunity__c, Organization_Domain__c, 
                                         Original_Provisioning_Group__c, PG_Request_Type__c, PG_for_Subscription__c, 
                                         Preferred_Cloud__c, Preferred_cloud_change_reason__c, Product_Line__c, 
                                         Provisioning_Broker_Eligible__c, Provisioning_Extension_Status__c, Provisioning_Process__c, 
                                         Provisioning_Request__c, Provisioning_Submission_Date__c, Provisioning_Type__c, 
                                         Renewed_From_Provisioning_Group__c, SE_Manager_Email__c, SE__c, 
                                         Send_Initial_Login_Credentials_To__c, Source__c, Start_Date__c, Status__c, Sub_Status__c,
                                        Subscription_Id__c, Subscription_Name__c, Technical_Validation_Plan__c, 
                                        ZPA_Preferred_Cloud__c, ZSCM_End_Date__c, Zscaler_Cloud_ID__c, has_Cloud_NSS__c, 
                                        is_ZPA_Only__c, Account_Industry_Vertical__c, Account_Parent_Industry__c, Account_type__c,
                                        Default_Preferred_Cloud__c, Geo__c, Is_Active__c, Opportunity_Link__c, Proxy_Cloud__c, 
                                        ZDX_Org_Id__c, ZSCM_Tenant_Link__c, Nanolog_Cluster__c, Number_Of_Employees_Users__c, 
                                        SMCDSS_DLP_Cluster__c, Sandbox_Cluster__c, Send_for_Provisioning__c, 
                                        Exception_to_Cluster_assignment__c, TenantNumber__c, Is_ZDX_Present__c, ZDX_Cloud_URL__c,
                                        ZDX_Username__c, 
                                        (SELECT Contact__c, Email__c, Provisioning_Group__c, Type__c, User_Name__c, User__c,
                                        Zscaler_Cloud_ID__c  FROM Provisioning_Contacts__r),
                                        (SELECT Name,End_Date__c, Product_Category__c, 
                                        Product_Family__c, Product_Line__c, Product__c, Provisioning_Group__c, Quantity__c, SKU__c,
                                        Start_Date__c, Zscaler_Cloud_ID__c, Product_Name__c, Provisioning_Detail__c, has_Cloud_NSS__c,
                                        Provisioning_Broker_Eligible__c, Provisioning_Sub_Product_Line__c, Auto_Provisioning_Status__c,
                                        Subscription_Lines_Data__c, Status__c, Provisioning_Product_Family__c, ContinueTrialForFutureDatedSku__c
                                        FROM Provisioning_Products__r )  FROM Provisioning_Group__c
                                        WHERE Zscaler_Cloud_ID__c=:associatedcloudWithPRG AND Product_Line__c ='ZIA' AND 
                                        (Status__c='Provisioned' OR Status__c='Pending Archival') limit 1];
                     
                            return pg;
    }

    public class ProvisioningDetailsWrapper{
      @AuraEnabled
      public String domain;
      @AuraEnabled
      public String additionalDomain;
      @AuraEnabled
      public String preferedZIAReason;
      @AuraEnabled
      public String comments;
      @AuraEnabled
      public String startDate;
      @AuraEnabled
      public String opportunityId;
      @AuraEnabled
      public String accountId;
      @auraEnabled
      public String preferredZIA;
      @auraEnabled
      public String preferredZPA;
      @auraEnabled
      public String ziaCloudIdForZPA;
      @AuraEnabled
      public String associatedcloud;
      @AuraEnabled
      public String assignedToCred;
      @AuraEnabled
      public String initialLoginCredentialsReceiverEmail;
      @AuraEnabled
      public Boolean withPrimaryQuoteProducts;
      @AuraEnabled
      public String crossPlatformProductId;
      @AuraEnabled
      public String crossPlatformProductName;
      @AuraEnabled
      public String crossPlatformSelected;
      @AuraEnabled
      public String selectedContactIntProv;
      @AuraEnabled
      public String loggedInUserId;
      @AuraEnabled
      public String selectedPostureControlProducts;
      @AuraEnabled
      public List<String> selectedPostureControlProdAddOn;
      @AuraEnabled
      public String postureControlSelected;
      @AuraEnabled
      public String numberOfWorkloads;
      //IBA-3581 
      @AuraEnabled 
      public Boolean exceptionToCluster;
      //IBA-2924 START
      @AuraEnabled
      public String nanoLogCluster;
      @AuraEnabled
      public String sandboxCluster;
      @AuraEnabled
      public String SMCDSSCluster;
      //IBA-2924 END

      // IBA-511 START
      @AuraEnabled
      public Boolean pgForSubscription;
      //IBA-511 END

            @AuraEnabled
      public String workloadCommunicationOnly; //IBA-5219

      //Provistioning Product Details
      @AuraEnabled
      public List<ProvisioningProducts> provProdWrapper;
      
      //Provistioning Contacts Details
      @auraEnabled
      public List<ProvisioningContacts> provContactWrapper;
    }
    
    public class ProvisioningProducts{
      @AuraEnabled
      public String productName;
      @AuraEnabled
      public String productCode;
      @AuraEnabled
      public String prodline;
      @AuraEnabled
      public String subProdline;
      @AuraEnabled
      public String productAddonnID;
      @AuraEnabled
      public String productSKUId; 
      @AuraEnabled
      public Boolean isCBI;
      @AuraEnabled
      public Boolean isDeception;
      @AuraEnabled
      public String quantity;
      @AuraEnabled
      public Boolean brokerEligibility;
      @AuraEnabled
      public String quotelineData;

      public ProvisioningProducts(OpportunityLineItem oli){
        this.ProductCode = oli.Product2.productCode;
        this.prodline = oli.Product2.Product_Line__c;
        this.productSKUId = oli.Product2.Id;
        this.productName = oli.Product2.Name;
        this.isCBI = oli.Product2.Provisioning_Sub_Product_Line__c!=null && oli.Product2.Provisioning_Sub_Product_Line__c=='CBI'?true:false;
        this.isDeception = oli.Product2.Provisioning_Sub_Product_Line__c!=null && oli.Product2.Provisioning_Sub_Product_Line__c=='Deception'?true:false;
        this.brokerEligibility= oli.Product2.Provisioning_Broker_Eligible__c;
        this.quotelineData = String.valueOf(oli.SBQQ__QuoteLine__r.SBQQ__StartDate__c)+':' + String.valueOf(oli.SBQQ__QuoteLine__r.SBQQ__EndDate__c)+':' + String.valueOf(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c);
      }

      public ProvisioningProducts(Product2 prod){
        this.ProductCode = prod.productCode;
        this.prodline = prod.Product_Line__c;
        this.productSKUId = prod.Id;
        this.productName = prod.Name;
        this.isCBI = prod.Provisioning_Sub_Product_Line__c!=null && prod.Provisioning_Sub_Product_Line__c=='CBI'?true:false;
        this.isDeception = prod.Provisioning_Sub_Product_Line__c!=null && prod.Provisioning_Sub_Product_Line__c=='Deception'?true:false;
        this.brokerEligibility= prod.Provisioning_Broker_Eligible__c;
      }
    }
    
    public class ProvisioningContacts{
      @AuraEnabled
      public String contactType;
      @AuraEnabled
      public String name;
      @AuraEnabled
      public String title;
      @AuraEnabled
      public String email;
      @AuraEnabled
      public String phone;
      @AuraEnabled
      public String altPhone;
      @AuraEnabled
      public String contactId;
      @AuraEnabled
      public String userId;      
    }
  }