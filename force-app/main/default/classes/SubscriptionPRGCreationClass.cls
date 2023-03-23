/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 06-16-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class SubscriptionPRGCreationClass {
    
    public static Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
    public static List<String> prProdutFamilyList = new List<String>{'ZIA', 'ZPA', 'ZDX','ZWS','Workload Protection','Cross Platform'};
    public static Id subsPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Subscription').getRecordTypeId();
    public List<string> LicenseSet = new List<string>();
    Public static Boolean proxyPortPresentInOrder =  FALSE;
    Public static Boolean proxyPortPresentInPRG = FALSE;
    
    //Method to be called from the FLOW 'CreateSubscriptionPRG_ContractDetail'.
    
    @InvocableMethod(label='CreateSubscriptionPRG')
    public static void CreateSubscriptionPRG(List<Id> recIds ){
        Map<String, List<Provisioning_Group__c>> trialPRGMapFromOpp = new Map<String, List<Provisioning_Group__c>>();
        Map<Id, List<Provisioning_Product__c>> provisioningGroupWithProductsMap = new Map<Id, List<Provisioning_Product__c>>(); 
        Map<String, List<Contract_Detail__c>> conDetailMap = new Map<String, List<Contract_Detail__c>>();
        Map<Id, Contract_Detail__c> prodConDetailMap = new Map<Id, Contract_Detail__c>();
        Map<Id, Provisioning_Group__c> provGroupInsertMap = new Map<Id, Provisioning_Group__c>();
        Map<Contract_Detail__c, Provisioning_Product__c> CrossProvproductsInsertMap = new Map<Contract_Detail__c, Provisioning_Product__c>();
        List<Provisioning_Product__c> provProductsInsertList = new List<Provisioning_Product__c>();
        List<Provisioning_Product__c> CrossprovProductsInsertList = new List<Provisioning_Product__c>();
        List<Provisioning_Contact__c> provContactsInsertList = new List<Provisioning_Contact__c>();
        Map<Id,Date> maxEndDateMap = new Map<Id,Date>();
        Map<Id,Date> minStartDateMap = new Map<Id,Date>();
        Boolean autoBoolean = FALSE;
        Id OppId;
        Contract_Detail__c conDetail = [SELECT Id, Opportunity__c,Opportunity__r.StageName,Opportunity__r.Name, Sales_Order__c, Sales_Order_Name__c FROM Contract_Detail__c WHERE Id =: recIds[0]];
        // add method here
        if(conDetail.Opportunity__c != NULL){
            //getTrialPRGs and its Products Map from opportunity
            trialPRGMapFromOpp = CreateTrialPRGsMap(conDetail.Opportunity__c);
            OppId = conDetail.Opportunity__c;
        }
        else if(conDetail.Sales_Order_Name__c != NULL){
            // Find the right opportunity based on SalesOrder and getTrialPRGs and its Products Map
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Netsuite_Sales_Order_Number__c =: conDetail.Sales_Order_Name__c]; 
            if(opp.id != NULL){
                trialPRGMapFromOpp = CreateTrialPRGsMap(opp.id);
                OppId = opp.id;
            }
        }
        if(!trialPRGMapFromOpp.isEmpty() && trialPRGMapFromOpp.keySet() != NULL){
            //Get all the contract details based on sales order only if Trial prgs are present.
            conDetailMap = CreateConDetailMap(conDetail.Sales_Order_Name__c);
            if(!conDetailMap.keyset().contains('Cross Platform')){
                for(string prodFamily : conDetailMap.keySet()){
                    //Single tenant per Product family
                    if(trialPRGMapFromOpp.containsKey(prodFamily) && trialPRGMapFromOpp.get(prodFamily).size() == 1 ){
                        if(prodFamily == 'ZIA'){
                            getPGAndRelatedProvisioningProducts(trialPRGMapFromOpp.get(prodFamily));
                        }
                        Provisioning_Group__c clonedProvisioningGroup = CreateSubscriptionPRG(trialPRGMapFromOpp.get(prodFamily)[0]);
                        for(Contract_Detail__c cd : conDetailMap.get(prodFamily)){
                            Provisioning_Product__c prd = CreateProvisioningProd(cd);
                            prd.Provisioning_Group__c = trialPRGMapFromOpp.get(prodFamily)[0].Id;
                            provProductsInsertList.add(prd);
                        }
                        maxEndDateMap = maxDateMapMethod(provProductsInsertList);
                        minStartDateMap = minStartDateMapMethod(provProductsInsertList);
                        clonedProvisioningGroup.Start_Date__c = minStartDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c);
                        clonedProvisioningGroup.End_Date__c = maxEndDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c);
                        clonedProvisioningGroup.Provisioning_Submission_Date__c = minStartDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c);
                        clonedProvisioningGroup.ZSCM_End_Date__c = clonedProvisioningGroup.End_Date__c;
                        if(proxyPortPresentInPRG == TRUE && proxyPortPresentInOrder == FALSE){
                            clonedProvisioningGroup.Provisioning_Type__c = 'Manual';   
                        }
                        provGroupInsertMap.put(trialPRGMapFromOpp.get(prodFamily)[0].Id, clonedProvisioningGroup);
                        autoBoolean = TRUE;
                    }
                    else if(trialPRGMapFromOpp.containsKey(prodFamily) && trialPRGMapFromOpp.get(prodFamily).size() > 1 ){
                        //MultiTenant Scenarios
                        provisioningGroupWithProductsMap = getPGAndRelatedProvisioningProducts(trialPRGMapFromOpp.get(prodFamily));
                        for (Provisioning_Group__c provisioningGroup : trialPRGMapFromOpp.get(prodFamily)) {
                            Provisioning_Group__c clonedProvisioningGroup = CreateSubscriptionPRG(provisioningGroup);
                            List<Provisioning_Product__c> tempProductsList = provisioningGroupWithProductsMap.containsKey(provisioningGroup.Id) ? provisioningGroupWithProductsMap.get(provisioningGroup.Id) : new List<Provisioning_Product__c>();
                            
                            for (Provisioning_Product__c provisioningProduct : tempProductsList) {
                                Provisioning_Product__c clonedProvisioningProduct = provisioningProduct.clone(false, true, false, false);
                                if(clonedProvisioningProduct.Subscription_Lines_Data__c != null) {
                                    List<String> subscriptionsData = clonedProvisioningProduct.Subscription_Lines_Data__c.split(',');
                                    List<String> fieldsData = subscriptionsData[0].split(':');
                                    clonedProvisioningProduct.Start_Date__c = Date.valueOf(fieldsData[0]);
                                    clonedProvisioningProduct.End_Date__c   = Date.valueOf(fieldsData[1]);
                                    clonedProvisioningProduct.Quantity__c   = Decimal.valueOf(fieldsData[2]);
                                    clonedProvisioningProduct.Status__c     = 'Subscribed';
                                    provProductsInsertList.add(clonedProvisioningProduct);
                                    if(subscriptionsData.size() > 1) {
                                        for(String subsData: subscriptionsData) {
                                            fieldsData = subsData.split(':');
                                            if(clonedProvisioningProduct.Start_Date__c < Date.valueOf(fieldsData[0])) {
                                                Provisioning_Product__c clonedProvisioningProduct1 = provisioningProduct.clone(false, true, false, false);
                                                clonedProvisioningProduct1.Start_Date__c = Date.valueOf(fieldsData[0]);
                                                clonedProvisioningProduct1.End_Date__c   = Date.valueOf(fieldsData[1]);
                                                clonedProvisioningProduct1.Quantity__c   = Decimal.valueOf(fieldsData[2]);
                                                provProductsInsertList.add(clonedProvisioningProduct1);
                                            }
                                        }
                                    }
                                }
                            }
                            maxEndDateMap = maxDateMapMethod(provProductsInsertList);
                            minStartDateMap = minStartDateMapMethod(provProductsInsertList);   
                            clonedProvisioningGroup.Start_Date__c = minStartDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c);
                            clonedProvisioningGroup.End_Date__c = maxEndDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c);
                            clonedProvisioningGroup.Provisioning_Submission_Date__c = minStartDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c);
                            clonedProvisioningGroup.ZSCM_End_Date__c = clonedProvisioningGroup.End_Date__c;
                            clonedProvisioningGroup.Provisioning_Type__c = 'Manual';
                            provGroupInsertMap.put(clonedProvisioningGroup.Original_Provisioning_Group__c,clonedProvisioningGroup);
                        } 
                    }       
                }       
            }
            else{
                Contract_Detail__c cd = conDetailMap.get('Cross Platform')[0];
                Product_License__c licenseRec = [SELECT ID,License_Product_Line__c,Product__c FROM Product_License__c WHERE Product__c =: cd.Product_Name__c][0];
                List<string> LicenseSet = new List<string>{'ZIA','ZPA','ZDX'};
                for(string str : LicenseSet){
                    if(trialPRGMapFromOpp.containsKey(str) && trialPRGMapFromOpp.get(str).size()>1){
                        Provisioning_Group__c clonedProvisioningGroup = CreateSubscriptionPRG(trialPRGMapFromOpp.get(str)[0]);
                        clonedProvisioningGroup.Original_Provisioning_Group__c = trialPRGMapFromOpp.get(str)[0].Id;
                        clonedProvisioningGroup.Provisioning_Type__c = 'Manual';
                        provGroupInsertMap.put(trialPRGMapFromOpp.get(str)[0].Id, clonedProvisioningGroup);
                        if(conDetailMap!= NULL && conDetailMap.containskey(str)){
                            for(Contract_Detail__c cde : conDetailMap.get(str)){
                                Provisioning_Product__c prd = CreateProvisioningProd(cde);
                                prd.Provisioning_Group__c = trialPRGMapFromOpp.get(str)[0].Id;
                                provProductsInsertList.add(prd);
                            }    
                        }    
                    }
                    else if(trialPRGMapFromOpp.containsKey(str)){
                    	Provisioning_Group__c clonedProvisioningGroup = CreateSubscriptionPRG(trialPRGMapFromOpp.get(str)[0]);
                        if(!conDetailMap.isEmpty() && conDetailMap.containsKey(str)){
                        	for(Contract_Detail__c cde : conDetailMap.get(str)){
                                Provisioning_Product__c prd = CreateProvisioningProd(cde);
                                prd.Provisioning_Group__c = trialPRGMapFromOpp.get(str)[0].Id;
                                provProductsInsertList.add(prd);
                            }
                        }
                        if(provProductsInsertList!= NULL && !provProductsInsertList.isEmpty()){
                            maxEndDateMap = maxDateMapMethod(provProductsInsertList);
                            minStartDateMap = minStartDateMapMethod(provProductsInsertList);       
                        }
                        clonedProvisioningGroup.Original_Provisioning_Group__c = trialPRGMapFromOpp.get(str)[0].Id;
                        clonedProvisioningGroup.Provisioning_Type__c = 'Auto';
                        clonedProvisioningGroup.Start_Date__c = minStartDateMap.containsKey(clonedProvisioningGroup.Original_Provisioning_Group__c)?(cd.Start_Date__c<minStartDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c)?cd.Start_Date__c:minStartDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c)):cd.Start_Date__c;
                        clonedProvisioningGroup.End_Date__c = maxEndDateMap.containsKey(clonedProvisioningGroup.Original_Provisioning_Group__c)?(cd.End_Date__c>maxEndDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c)?cd.End_Date__c:maxEndDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c)):cd.End_Date__c;
                        clonedProvisioningGroup.Provisioning_Submission_Date__c = minStartDateMap.containsKey(clonedProvisioningGroup.Original_Provisioning_Group__c)?(cd.Start_Date__c<minStartDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c)?cd.Start_Date__c:minStartDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c)):cd.Start_Date__c;
                        clonedProvisioningGroup.ZSCM_End_Date__c = clonedProvisioningGroup.End_Date__c;
                        provGroupInsertMap.put(trialPRGMapFromOpp.get(str)[0].Id, clonedProvisioningGroup);    
                    }
                }
                Provisioning_Product__c prd = CreateProvisioningProd(cd);
                CrossProvproductsInsertMap.put(cd,prd);
            }
            
            //Insert subscription PRGs
            if(provGroupInsertMap != NULL){
                try{
                    Insert provGroupInsertMap.values();   
                }
                catch(Exception ex){
                    ProvisioningErrorHandler.exceptionHandler('SubscriptionPRGCreationClass','CreateSubscriptionPRG',ex);    
                }
            }
            //Insert Provisioning products
            if(!provProductsInsertList.isEmpty() && provProductsInsertList != NULL){
                for(Provisioning_Product__c prd : provProductsInsertList){
                    prd.Provisioning_Group__c =  provGroupInsertMap.get(prd.Provisioning_Group__c).Id;   
                }
                try{
        			Insert provProductsInsertList;   
        		}
        		catch(Exception ex){
        			ProvisioningErrorHandler.exceptionHandler('SubscriptionPRGCreationClass','CreateSubscriptionPRG',ex);    
        		}
                
                if(autoBoolean){
                    createOTTRecord(OppId);     
                }
            }
            for(Provisioning_Group__c prg : provGroupInsertMap.values()){
                if(!CrossProvproductsInsertMap.isEmpty() && CrossProvproductsInsertMap != NULL){
                    Provisioning_Product__c prd =  CrossProvproductsInsertMap.get(conDetailMap.get('Cross Platform')[0]);
                    Provisioning_Product__c crossPrd = prd.clone(false, true, false, false);
                    crossPrd.Provisioning_Group__c = prg.Id;
                    CrossprovProductsInsertList.add(crossPrd);    
                }
            }
            if(!CrossprovProductsInsertList.isEmpty() && CrossprovProductsInsertList != NULL){
                try{
                	Insert CrossprovProductsInsertList;  
        		}
        		catch(Exception ex){
        			ProvisioningErrorHandler.exceptionHandler('SubscriptionPRGCreationClass','CreateSubscriptionPRG',ex);    
        		}
            }
            //Method to insert Provisioning Contacts
            List<Provisioning_Contact__c> existingList = new List<Provisioning_Contact__c>();
            if(provGroupInsertMap != NULL && !provGroupInsertMap.isEmpty()){
                existingList = CreateProvisioningContacts(provGroupInsertMap.keySet());
                if(!existingList.isEmpty() && existingList != NULL){
                    for(Provisioning_Contact__c con : existingList){
                        Provisioning_Contact__c clonedProvisioningContact = con.clone(false, true, false, false);
                        clonedProvisioningContact.Provisioning_Group__c = provGroupInsertMap.get(clonedProvisioningContact.Provisioning_Group__c).Id;
                        provContactsInsertList.add(clonedProvisioningContact);
                    }
                    try{
                		Insert provContactsInsertList;  
        			}
        			catch(Exception ex){
        				ProvisioningErrorHandler.exceptionHandler('SubscriptionPRGCreationClass','CreateSubscriptionPRG',ex);    
        			}
                }    
            } 
        }
    }
    
    // Method to create the map of trial PRGS and its Provisioning Products.
    public static Map<String, List<Provisioning_Group__c>> CreateTrialPRGsMap(Id oppId){
        List<Provisioning_Group__c> PRList = new List<Provisioning_Group__c>();
        Map<String, List<Provisioning_Group__c>> trialPRGMap = new Map<String, List<Provisioning_Group__c>>();
        String provGroupFields = getFieldNamesOfSObject('Provisioning_Group__c');
        String provProductFields = getFieldNamesOfSObject('Provisioning_Product__c');
        String queryString;
        String recordTypeValue = 'Trial';
        String statusValue = 'Provisioned';
        queryString = 'SELECT '+ provGroupFields + ',(SELECT ' + provProductFields + ' FROM Provisioning_Products__r) FROM Provisioning_Group__c';
        queryString = queryString + ' WHERE Opportunity__c =: oppId AND Recordtype.Developername =: recordTypeValue AND PG_for_Subscription__c = TRUE AND Status__c =: statusValue';
        PRList = Database.query(queryString);
        if(!PRList.isEmpty() && PRList != NULL){
            for(Provisioning_Group__c prg : PRList){
                if(!trialPRGMap.containsKey(prg.Product_Line__c)){
                    trialPRGMap.put(prg.Product_Line__c , new List<Provisioning_Group__c>{prg});   
                }
                else{
                    trialPRGMap.get(prg.Product_Line__c).add(prg);    
                }           
            }       
        }
        return trialPRGMap;
    }
    
    // Method to create the map of Product family and its contractDetails.
    public static Map<String, List<Contract_Detail__c>> CreateConDetailMap(String salesOrderName){
        List<Contract_Detail__c> conDetailList = new List<Contract_Detail__c  >();
        Map<String, List<Contract_Detail__c>> conDetailMap = new Map<String, List<Contract_Detail__c>>();
        String conDetailFields = getFieldNamesOfSObject('Contract_Detail__c');
        String queryString;
        queryString = 'SELECT '+ conDetailFields + ', Product_Name__r.Product_Line__c, Product_Name__r.Name,Product_Name__r.ProductCode FROM Contract_Detail__c';
        queryString = queryString + ' WHERE Sales_Order_Name__c =: salesOrderName AND Product_Name__r.Product_Line__c IN: prProdutFamilyList AND Product_Name__r.Product_Line__c not in (\'Support\',\'Service\')';
        queryString = queryString + ' AND Product_Name__r.Is_Applicable_for_POC__c =true AND (Product_Name__r.Provisioning_Product_Family__c=\'Addon\' OR ';
        queryString = queryString + 'Product_Name__r.Provisioning_Product_Family__c=\'Bundles\' OR Product_Name__r.Provisioning_Product_Family__c=\'Package\')';
        conDetailList = Database.query(queryString);
        if(!conDetailList.isEmpty() && conDetailList != NULL){
            for(Contract_Detail__c Cd : conDetailList){
                if(Cd.Product_Name__r.ProductCode == 'Z-PROXYPORT'){
                    proxyPortPresentInOrder = TRUE;     
                }
                if(!conDetailMap.containsKey(Cd.Product_Name__r.Product_Line__c)){
                    conDetailMap.put(Cd.Product_Name__r.Product_Line__c , new List<Contract_Detail__c>{Cd});   
                }
                else{
                    conDetailMap.get(Cd.Product_Name__r.Product_Line__c).add(Cd);    
                }           
            }       
        }
        return conDetailMap;
    }
    
    // Method to create the cloned Provisioning Group for a Subscription PRG.
    public static Provisioning_Group__c CreateSubscriptionPRG(Provisioning_Group__c PRG){
        Provisioning_Group__c clonedProvisioningGroup = PRG.clone(false, true, false, false);
        clonedProvisioningGroup.RecordTypeId = subsPGRecordTypeId;
        clonedProvisioningGroup.Status__c = 'Waiting';
        clonedProvisioningGroup.Sub_Status__c = 'Waiting for Order';
        clonedProvisioningGroup.PG_Request_Type__c = 'Replace';
        clonedProvisioningGroup.Provisioning_Process__c ='Convert Trial to Subscription';
        clonedProvisioningGroup.Original_Provisioning_Group__c = PRG.Id;
        clonedProvisioningGroup.PG_for_Subscription__c = false;
        clonedProvisioningGroup.Subscription_Id__c = '';
        clonedProvisioningGroup.Subscription_Name__c = '';
        clonedProvisioningGroup.Initial_Login_Credentials_Receiver_Email__c=PRG.Initial_Login_Credentials_Receiver_Email__c;
        return clonedProvisioningGroup;
    }
    
    // Method to create the Provisioning Product based on Contract Detail record.
    public static Provisioning_Product__c CreateProvisioningProd(Contract_Detail__c Cd){
        Provisioning_Product__c prd = new Provisioning_Product__c();
        prd.End_Date__c  = Cd.End_Date__c ;
        prd.Product__c  = Cd.Product_Name__c;
        prd.Quantity__c  = Cd.Quantity__c;
        prd.Start_Date__c  = Cd.Start_Date__c;
        prd.Status__c  ='Subscribed';
        prd.Name = Cd.Product_Name__r.Name;
        return prd;
    }
    
    // Method to create the Provisioning contacts based on PRG records.
    public static List<Provisioning_Contact__c> CreateProvisioningContacts(set<Id> prgIds){
        List<Provisioning_Contact__c> contactList = new List<Provisioning_Contact__c>();
        String provConFields = getFieldNamesOfSObject('Provisioning_Contact__c');
        String queryString;
        queryString = 'SELECT '+ provConFields + ' FROM Provisioning_Contact__c WHERE Provisioning_Group__c IN : prgIds'; 
        contactList = Database.query(queryString);
        return contactList;
    }
    
    //Method to get provisioning products Map
    private static Map<Id, List<Provisioning_Product__c>> getPGAndRelatedProvisioningProducts(List<Provisioning_Group__c> provisioningGroupList) {
        String provisioningProductFields = getFieldNamesOfSObject('Provisioning_Product__c');
        String query = 'SELECT ' +  provisioningProductFields + ',Product__r.ProductCode FROM Provisioning_Product__c ' + 
            'WHERE Provisioning_Group__c IN :provisioningGroupList';
        List<Provisioning_Product__c> provisioningProductsList = Database.query(query);
        
        Map< Id, List<Provisioning_Product__c>> pgIdToProvisioningProductsMap = new Map<Id, List<Provisioning_Product__c>>();
        for (Provisioning_Product__c provisioningProduct : provisioningProductsList) {
            if(provisioningProduct.Product__r.ProductCode == 'Z-PROXYPORT'){
                proxyPortPresentInPRG = TRUE;       
            }
            if (!pgIdToProvisioningProductsMap.containsKey(provisioningProduct.Provisioning_Group__c)) {
                pgIdToProvisioningProductsMap.put(provisioningProduct.Provisioning_Group__c, new List<Provisioning_Product__c>());
            }
            pgIdToProvisioningProductsMap.get(provisioningProduct.Provisioning_Group__c).add(provisioningProduct);
        }
        return pgIdToProvisioningProductsMap;
    }
    
    //Method to get maxDateMap
    public static Map<Id,Date> maxDateMapMethod(List<Provisioning_Product__c> provProductsInsertList){
        Map<Id,Date> maxEndDateMap = new Map<Id,Date>();
        for(Provisioning_Product__c provisioningProduct : provProductsInsertList){
            if(!maxEndDateMap.containsKey(provisioningProduct.Provisioning_Group__c)){
                maxEndDateMap.put(provisioningProduct.Provisioning_Group__c,provisioningProduct.End_Date__c);               
            }
            else{
                if(provisioningProduct.End_Date__c > maxEndDateMap.get(provisioningProduct.Provisioning_Group__c)){
                    maxEndDateMap.put(provisioningProduct.Provisioning_Group__c,provisioningProduct.End_Date__c);       
                }           
            }   
        }
        return maxEndDateMap;
    }
    
    //Method to get minDateMap 
    public static Map<Id,Date> minStartDateMapMethod(List<Provisioning_Product__c> provProductsInsertList){
        Map<Id,Date> minStartDateMap = new Map<Id,Date>();
        for(Provisioning_Product__c provisioningProduct : provProductsInsertList){
            if(!minStartDateMap.containsKey(provisioningProduct.Provisioning_Group__c)){
                minStartDateMap.put(provisioningProduct.Provisioning_Group__c,provisioningProduct.Start_Date__c);       
            }
            else{
                if(provisioningProduct.Start_Date__c < minStartDateMap.get(provisioningProduct.Provisioning_Group__c)){
                    minStartDateMap.put(provisioningProduct.Provisioning_Group__c,provisioningProduct.Start_Date__c);       
                }      
            }    
        }
        return minStartDateMap;
    }
    
    //Method to get all fields for a particular sObject.
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
    
    public static void createOTTRecord(ID oppID){
        
        Order_Tracker__c ottRecord = null;
        
        for(Order_Tracker__c ott : [Select id from Order_Tracker__c where Opportunity__c = :oppID]){
            ottRecord = ott;
        }
        sendOTTEmail(ottRecord, oppID);   
    }
    
    public static void sendOTTEmail(Order_Tracker__c ott, Id oppID){
        
        String htmlBody = '<p>Dear {{userName}}</p>'+
            '<p>Your provisioning request group to complete order provisioning is now ready for processing in SFDC. This is an automated email </p>'+
            '<p>Thanks</p>'+
            '<p>Provisioning Automation</p>';
        
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
        
        String messageId = ottRecord.Message_Id__c;
        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toCC = new List<String>();
        if(Label.Orders_Mail_Box.contains(',')){
            toCC.addAll(Label.Orders_Mail_Box.split(','));
        }else{
            toCC.add(Label.Orders_Mail_Box);
        }
        
        mail.setToAddresses(new String[]{userinfo.getUserEmail()});
        mail.setCcAddresses(toCC);
        
        if(messageId != null){
            mail.setReferences(messageId);
        }
        
        mail.setSubject('Sales Wizard : Ready for Provisioning : '+ ottRecord.Ticket__c);
        
        htmlBody = htmlBody.replace('{{userName}}', userInfo.getFirstName() + ' '+ userinfo.getLastName());
        
        String quoteName = ottRecord.Opportunity__r.Primary_Quote_Source__c == 'CPQ' ? 
            ottRecord.Opportunity__r.SBQQ__PrimaryQuote__r.name : 
        '';    
        
        mail.setHtmlBody(htmlBody);
        
        if(!Test.isRunningTest())
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        
    }
}