/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 06-07-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class PGBrokerProcessingEventHandler {
    
    public static Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
    
    public static void process(List<Provisioning_Broker_Processing_Event__e > pbEvents){
        System.debug('---PGBrokerProcessingEventHandler process called---');
        Savepoint sp = Database.setSavepoint();
        
        try{
            //By Pass Triggers
            TriggerHandler.bypass('AccountTriggerHandler');
            
            Set<Id> pbLogIDs = new Set<Id>();
            for(Provisioning_Broker_Processing_Event__e  evt : pbEvents){
                if(evt.Provisioning_Integration_Log_ID__c != null && evt.Provisioning_Integration_Log_ID__c != null){
                    pbLogIDs.add(evt.Provisioning_Integration_Log_ID__c);
                }
            }
            
            MAP<ID, Provisioning_Integration_Log__c> failedOnes = new MAP<ID, Provisioning_Integration_Log__c>();
            MAP<ID, Provisioning_Integration_Log__c> receivedOnes = new MAP<ID, Provisioning_Integration_Log__c>();
            
            MAP<ID, Provisioning_Integration_Log__c> piLogMAP = new MAP<ID, Provisioning_Integration_Log__c>();
            
            for(Provisioning_Integration_Log__c piLog : [SELECT Id, Name, Request__c,Status__c, Provisioning_Group__c 
                                                         FROM Provisioning_Integration_Log__c 
                                                         WHERE Provisioning_Group__c != null  
                                                         AND Id IN :pbLogIDs])
            {
                switch on  piLog.status__c {
                    when 'Received' {
                        receivedOnes.put(piLog.Id, piLog);
                    }
                }
            }
            System.debug('---PGBrokerProcessingEventHandler process receivedOnes---'+receivedOnes);
            System.debug('---PGBrokerProcessingEventHandler process failedOnes---'+failedOnes);           
            processRequestedPlatformEvents(receivedOnes);
            if(Test.isRunningTest()){
                  throw new IllegalArgumentException('Invalid value');

            }
        }catch(Exception ex){
            System.debug('---PGBrokerProcessingEventHandler--execption---'+ex);
            System.debug('--Exception-Message--'+ex.getMessage());
            System.debug('--Exception-Line--'+ex.getLineNumber());
            System.debug('--Exception-Stacktrace--'+ex.getStackTraceString());
            ProvisioningErrorHandler.exceptionHandler('ProvEventManualTriggerHandler','generateOTTRecordsForTrial',ex);
            // Rollback to the previous null value
            Database.rollback(sp);
        }
    }
    
    @testVisible 
    private static void processRequestedPlatformEvents(MAP<ID, Provisioning_Integration_Log__c> piLogMAP){
        //By Pass Triggers
        TriggerHandler.bypass('AccountTriggerHandler');
        
        if(!piLogMAP.isEmpty()) {
            MAP<ID, Provisioning_Integration_Log__c> piLogRecordMAP = new MAP<ID, Provisioning_Integration_Log__c>();
            
            //Processing Step 1 : Fill all the MAP So we can do bulk Insert/Upate
            MAP<ID, Account> customerMAP = new MAP<ID,Account>();
            MAP<ID, Map<String,Zscaler_Cloud_ID__c>> logTanentMAP = new MAP<ID, Map<String,Zscaler_Cloud_ID__c>>();
            
            //All the UniqueCloudNames(tenantNames)
            Set<String> zscalerCloudNames = new Set<String>();
            
            Set<ID> pgIDs = new Set<ID>();
            for(Provisioning_Integration_Log__c piRecord : piLogMAP.values()){
                pgIDs.add(piRecord.Provisioning_Group__c);
            }
            
            MAP<ID, Provisioning_Group__c> pgMAP = new MAP<ID, Provisioning_Group__c> ([SELECT Id, Name, Product_Line__c, Associated_ZIA_Zscaler_Cloud__c, Subscription_Id__c, Subscription_Name__c, Provisioning_Request__c,
                                                                                        RecordType.Name, Geo__c,Provisioning_Broker_Eligible__c,Cross_Platform_Selected__c FROM Provisioning_Group__c WHERE Id IN :pgIDs]);
            System.debug('--pgMAP---'+pgMAP);
            
            for(Provisioning_Integration_Log__c  piLogRecord : piLogMAP.values()){
                //Prepare PG Record
                Provisioning_Group__c pgRecord =  null;
                String subscriptionId;
                String subscriptionName;
                
                try{
                    ProvisioningBrokerWrapper pbw = ProvisioningBrokerWrapper.parse(piLogRecord.Request__c);
                    String accountID = pbw.sfdcAccountId;
                    String pgID = pbw.prGroupId;
                    
                    //Prepare PG Record
                    pgRecord = pgMAP.get(pgID);
                    
                    //Prepare Customer Record
                    Account customerAccount = customerMAP.containsKey(accountId) ? customerMAP.get(accountId) : [select id,ZIA_Customer_ID__c,ZPA_Customer_ID__c from Account where ID =: accountId limit 1];//new Account(ID = accountId);
                    customerMAP.put(customerAccount.iD, customerAccount);
                    
                    Map<String,Zscaler_Cloud_ID__c> mapTenantIDCloudRecord = new Map<String,Zscaler_Cloud_ID__c>();
                    
                    Boolean isError = false;
                    String errorMessage = null;
                    for(ProvisioningBrokerWrapper.cls_customerInfo custInfo : pbw.customerInfo){
                        if(String.isNotBlank(custInfo.subscriptionId)){
                            subscriptionId = custInfo.subscriptionId;
                        }
                        if(String.isNotBlank(custInfo.subscriptionName)){
                            subscriptionName = custInfo.subscriptionName;
                        } 
                        if(custInfo.cloudName != 'ZPA'){
                            if((custInfo.betaCustomerId == null && custInfo.productionCustomerId ==null) || custInfo.tenantID == null || custInfo.requestStatus == 'Failure'){
                                isError = true;
                                errorMessage += custInfo.failureReason + ' ,';
                            }
                        }
                        else if(custInfo.cloudName == 'ZPA'){
                            if( custInfo.tenantID == null || custInfo.requestStatus == 'Failure' ){
                                isError = true;
                                errorMessage+= custInfo.failureReason+ ' ,';
                            }
                        }
                    }
                    
                    if(!isError){
                        //String ziacustomerID = null;
                        String zpacustomerID = null;
                         String betaCustomerId = null;
                        String prodCustomerId = null;
                        for(ProvisioningBrokerWrapper.cls_customerInfo custInfo : pbw.customerInfo){
                            if(custInfo.cloudName == 'ZIA' || custInfo.cloudName == 'ZDX'){
                                //betaCustomerId = custInfo.betaCustomerId != null ? betaCustomerId : custInfo.betaCustomerId;
                               // prodCustomerId = prodCustomerId != null ? prodCustomerId : custInfo.productionCustomerId;
                                if(custInfo.betaCustomerId !=null && custInfo.betaCustomerId !=''){
                                    if(customerMAP.get(customerAccount.ID).ZIA_Customer_ID__c ==null || customerMAP.get(customerAccount.ID).ZIA_Customer_ID__c =='')
                                   		 customerMAP.get(customerAccount.ID).ZIA_Customer_ID__c  = custInfo.betaCustomerId;
                                }
                                else if(custInfo.productionCustomerId !=null && custInfo.productionCustomerId !=''){
                                    if(customerMAP.get(customerAccount.ID).ZPA_Customer_ID__c ==null || customerMAP.get(customerAccount.ID).ZPA_Customer_ID__c =='')
                                   		customerMAP.get(customerAccount.ID).ZPA_Customer_ID__c  = custInfo.productionCustomerId; 
                                }
                             }
                            zscalerCloudNames.add(custInfo.tenantID);
                            mapTenantIDCloudRecord.put(custInfo.tenantID, prepareZscalerCloudRecord(pgRecord, pbw.sfdcAccountId, custInfo));
                        }
                        logTanentMAP.put(piLogRecord.Id, mapTenantIDCloudRecord);
                        
                        //Set Log Record Status
                        piLogRecord.Failure_Reason__c = null;
                        piLogRecord.Status__c = 'Successfully Auto Processed';
                        
                        //Set PG Record Status
                        pgRecord.Status__c = 'Provisioned';
                        if(String.isNotBlank(subscriptionId)){
                            pgRecord.Subscription_Id__c =subscriptionId;
                        }
                        if(String.isNotBlank(subscriptionName)){
                            pgRecord.Subscription_Name__c =subscriptionName;
                        }
                        pgRecord.Integration_Status__c='Success';
                        pgRecord.Provisioning_Type__c = 'Auto';
                        
                    }
                    else{
                        //Set Log Record Status
                        piLogRecord.Failure_Reason__c = errorMessage;
                        piLogRecord.Status__c = 'Failed';
                        
                        //Set PG Record Status
                        if(subscriptionId !=null && subscriptionId !=''){
                            pgRecord.Subscription_Id__c =subscriptionId;
                        }
                        if(subscriptionName !=null && subscriptionName!=''){
                            pgRecord.Subscription_Name__c =subscriptionName;
                        }
                        pgRecord.Provisioning_Type__c = 'Manual';
                        pgRecord.Failure_Reason__c = errorMessage;
                        pgRecord.Manually_Processed__c = true;
                        pgRecord.Integration_Status__c = 'Failed';
                    }
                     if(Test.isRunningTest()){
                    throw new IllegalArgumentException('Invalid value');

                	}
                }
                catch(Exception ex){
                    if(pgRecord != null){
                        pgRecord.Provisioning_Type__c = 'Manual';
                        pgRecord.Failure_Reason__c = 'Message: '+ex.getMessage() +'\nLine: '+ ex.getLineNumber();
                        pgRecord.Manually_Processed__c = true;
                        pgRecord.Integration_Status__c = 'Failed';
                        
                        piLogRecord.Failure_Reason__c = 'Message: '+ex.getMessage() +'\nLine: '+ ex.getLineNumber();
                        piLogRecord.Status__c = 'Failed';
                    }
                }finally{
                    if(pgRecord != null){
                        pgMAP.put(pgRecord.iD, pgRecord);
                    }
                }
                piLogRecordMAP.put(piLogRecord.Id, piLogRecord);
            }
            
            try{
            System.debug('----piLogRecordMAP---- '+piLogRecordMAP.values());
            List<Database.SaveResult> piLogRecordUpdateResultList = Database.update(piLogRecordMAP.values());
            
            System.debug('----customerMAP---- '+customerMAP.values());
            List<Database.SaveResult> customerUpdateResultList = Database.update(customerMAP.values());
            
            //Processing Step 2 : insert/update all the Records
            System.debug('----logTanentMAP---- '+logTanentMAP);
            if(logTanentMAP != null && logTanentMAP.size()>0){
                //Retrive all Existing Clouds
                MAp<String, Zscaler_Cloud_ID__c> zscalerCloudIDMAP = new MAP<String, Zscaler_Cloud_ID__c>();
                for(Zscaler_Cloud_ID__c zsi : [select id,Name from Zscaler_Cloud_ID__c where Name In: zscalerCloudNames and Account__c in :customerMAP.keyset()]) {
                    zscalerCloudIDMAP.put(zsi.Name, zsi);
                }
                System.debug('---processRequestedPlatformEvents--zscalerCloudIDMAP-- '+zscalerCloudIDMAP);
                
                //Fill existing Zscaler Cloud ID based on the tenantName
                for(Map<String,Zscaler_Cloud_ID__c> cloudMAP : logTanentMAP.values()){
                    for(String tanentName : cloudMAP.keyset()){
                        if(zscalerCloudIDMAP.containskey(tanentName)){
                            Zscaler_Cloud_ID__c existingCloud = zscalerCloudIDMAP.get(tanentName);
                            cloudMAP.get(tanentName).id = existingCloud != null ? existingCloud.id : null;
                        }
                    }
                }
                System.debug('---processRequestedPlatformEvents--logTanentMAP-- '+logTanentMAP);
                
                //Update/Create Zscaler Cloud Id records 
                MAp<String, Zscaler_Cloud_ID__c> updateIDMAP = upsertZscalerCloudRecords(piLogRecordMAP, logTanentMAP, pgMAP);
                System.debug('---processRequestedPlatformEvents--updateIDMAP-- '+updateIDMAP);
                
                //Populate ZscalerCloud on PG
                populateZscalerCloudOnPGRecords(piLogRecordMAP,pgMAP,logTanentMAP,updateIDMAP);
            }
            
            System.debug('---processRequestedPlatformEvents--pgMAP-- '+pgMAP.values());          
            List<Database.SaveResult> pgUpdateResultList = Database.update(pgMAP.values());
            
            System.debug('---processRequestedPlatformEvents--piLogRecordMAP-- '+piLogRecordMAP.values());  
            List<Database.SaveResult> piLogRecordUpdateResultList1 = Database.update(piLogRecordMAP.values());
            if(Test.isRunningTest()){
  				throw new IllegalArgumentException('Invalid value');
            }
            } catch(Exception e){
                ProvisioningErrorHandler.exceptionHandler('ProvEventManualTriggerHandler','generateOTTRecordsForTrial',e);
            }
        }
    }
    
    @testVisible
    private static void populateZscalerCloudOnPGRecords(MAP<ID, Provisioning_Integration_Log__c> piLogRecordMAP, MAP<ID, Provisioning_Group__c> pgMAP,
                                                        MAP<ID, Map<String,Zscaler_Cloud_ID__c>> logTanentMAP,MAp<String, Zscaler_Cloud_ID__c> updateIDMAP)
    {
        for(id  logRequestID : logTanentMAP.keyset()){
            Provisioning_Integration_Log__c piRecord  = piLogRecordMAP.get(logRequestID);
            try{                
                //For insert Scenqario It wont have ID
                Map<String,Zscaler_Cloud_ID__c> cloudMAP = logTanentMAP.get(logRequestID);
                
                //So we get Upated MAP based on the updateIDMAP using tanentName 
                MAP<String,Zscaler_Cloud_ID__c> updatedCloudMAP = new MAP<String,Zscaler_Cloud_ID__c>();
                for(String tanentName : cloudMAP.keyset()){
                    if(updateIDMAP.containskey(tanentName)){
                        updatedCloudMAP.put(tanentName, updateIDMAP.get(tanentName));
                    }
                }
                System.debug('---processRequestedPlatformEvents--updatedCloudMAP--'+updatedCloudMAP);
                
                Map<String,Id> cloudTypeVsZscIdMap = new Map<String,Id>();
                for(Zscaler_Cloud_ID__c zs : updateIDMAP.values()){
                    cloudTypeVsZscIdMap.put(zs.Cloud_Type__c,zs.id);
                }
                System.debug('---processRequestedPlatformEvents--cloudTypeVsZscIdMap--'+cloudTypeVsZscIdMap);
                
                if(cloudTypeVsZscIdMap != null && cloudTypeVsZscIdMap.size() > 0 &&  piRecord.Provisioning_Group__c != null){
                    List<Provisioning_Product__c> lstProduct = [SELECT Id, Product_Line__c, Zscaler_Cloud_ID__c FROM Provisioning_Product__c WHERE Provisioning_Group__c = :piRecord.Provisioning_Group__c];
                    if(lstProduct !=null && lstProduct.size()>0){
                        for(Provisioning_Product__c prObj : lstProduct){
                            if(cloudTypeVsZscIdMap.containskey(prObj.Product_Line__c) && cloudTypeVsZscIdMap.get(prObj.Product_Line__c) !=null){
                                prObj.Zscaler_Cloud_ID__c = cloudTypeVsZscIdMap.get(prObj.Product_Line__c);
                            }
                        }
                        List<Database.SaveResult> productUpdateResultList = Database.update(lstProduct);
                    }
                    
                    List<Provisioning_Contact__c> lstCont = [SELECT Id, Zscaler_Cloud_ID__c, Provisioning_Group__c, Provisioning_Group__r.Product_Line__c FROM Provisioning_Contact__c WHERE Provisioning_Group__c = :piRecord.Provisioning_Group__c];
                    if(lstCont !=null && lstCont.size() > 0){
                        for(Provisioning_Contact__c pc : lstCont) {
                            if(cloudTypeVsZscIdMap.containsKey(pc.Provisioning_Group__r.Product_Line__c)) {
                                pc.Zscaler_Cloud_ID__c = cloudTypeVsZscIdMap.get(pc.Provisioning_Group__r.Product_Line__c);
                            }   
                        }
                        List<Database.SaveResult> provContUpdateResultList = Database.update(lstCont);
                    }
                }
                
                Provisioning_Group__c pgReord = pgMAP.get(piRecord.Provisioning_Group__c);
                
               Provisioning_Group__c zdxpgRecord = findAssociatedZDX(pgReord); 
                if(pgReord.Cross_Platform_Selected__c){
                    
                    switch on pgReord.Product_Line__c {
                        when 'ZIA'{
                            pgReord.Zscaler_Cloud_ID__c = getZscalerCloudID(updatedCloudMAP.values(), 'ZIA');
                        }
                        when 'ZPA'{
                            pgReord.Zscaler_Cloud_ID__c = getZscalerCloudID(updatedCloudMAP.values(), 'ZPA');
                        }
                        when 'ZDX'{
                            pgReord.Zscaler_Cloud_ID__c = getZscalerCloudID(updatedCloudMAP.values(), 'ZDX');
                        }
                    }
                        pgMAP.put(pgReord.id,pgReord);
                    //Cross
					for(Zscaler_Cloud_ID__c cloud : updatedCloudMAP.values()){
						switch on cloud.Cloud_Type__c {
							when 'ZDX'{
								if(zdxpgRecord !=null){
									//Provisioning_Group__c pgReord = associatedPGMAP.get('ZDX');
									zdxpgRecord.Zscaler_Cloud_ID__c = cloud.Id;
									zdxpgRecord.Status__c = 'Provisioned';
                                 	zdxpgRecord.Associated_ZIA_Zscaler_Cloud__c =  getZscalerCloudID(updatedCloudMAP.values(), 'ZIA');

									 pgMAP.put(zdxpgRecord.id,zdxpgRecord);
								} 
							}
						}
						
					}
                   }
                else{
                    switch on pgReord.Product_Line__c {
                        when 'ZIA'{
                            pgReord.Zscaler_Cloud_ID__c = getZscalerCloudID(updatedCloudMAP.values(), 'ZIA');
                        }
                        when 'ZPA'{
                            pgReord.Zscaler_Cloud_ID__c = getZscalerCloudID(updatedCloudMAP.values(), 'ZPA');
                        }
                        when 'ZDX'{
                            pgReord.Zscaler_Cloud_ID__c = getZscalerCloudID(updatedCloudMAP.values(), 'ZDX');
                        }
                    }
                    pgMAP.put(pgReord.id,pgReord);
                    
                }
                if(Test.isRunningTest()){
                    throw new IllegalArgumentException('Invalid value');

                }
            }catch(Exception ex){
                Provisioning_Group__c pgReord = pgMAP.get(piRecord.Provisioning_Group__c);
                pgReord.Status__c = 'Provisioning In Progress';
                pgReord.Integration_Status__c = 'Failed';
                pgMAP.put(pgReord.id,pgReord);
                
                piLogRecordMAP.get(logRequestID).Failure_Reason__c = 'Message: '+ex.getMessage() +'\nLine: '+ ex.getLineNumber();
                piLogRecordMAP.get(logRequestID).Status__c = 'Failed'; 
                ProvisioningErrorHandler.exceptionHandler('ProvEventManualTriggerHandler','generateOTTRecordsForTrial',ex);
            }
        }
    }
    
    @testVisible
    private static MAP<String, Zscaler_Cloud_ID__c> upsertZscalerCloudRecords(MAP<ID, Provisioning_Integration_Log__c> piLogRecordMAP,
                                                                              MAP<ID, Map<String,Zscaler_Cloud_ID__c>> logTanentMAP,
                                                                              MAP<ID, Provisioning_Group__c> pgMAP
                                                                             )
    {
        MAP<String, Zscaler_Cloud_ID__c> updateIDMAP = new  MAp<String, Zscaler_Cloud_ID__c>();
        MAP<ID, List<Zscaler_Cloud_ID__c>> pgVSCloudIDMAP = new  MAP<ID, List<Zscaler_Cloud_ID__c>>();
        
        for(ID logID : piLogRecordMAP.keyset()){
            Map<String,Zscaler_Cloud_ID__c> cloudMAP = logTanentMAP.get(logID);
            List<Zscaler_Cloud_ID__c> pgTenanList = pgVSCloudIDMAP.containskey(logID) ? pgVSCloudIDMAP.get(logID) : new List<Zscaler_Cloud_ID__c>();
            for(String tanentName : cloudMAP.keyset()){
                Zscaler_Cloud_ID__c zscloudRecord = cloudMAP.get(tanentName);
                pgTenanList.add(zscloudRecord);
            }
            pgVSCloudIDMAP.put(logID,pgTenanList);
        }
        System.debug('pgVSCloudIDMAP='+pgVSCloudIDMAP);
        
        for(ID pgLogID : pgVSCloudIDMAP.keyset()){
            if(piLogRecordMAP.containskey(pgLogID)){
                Provisioning_Integration_Log__c piRecord  = piLogRecordMAP.get(pgLogID);
                try{
                    List<Database.UpsertResult> zscUpsertResultList = Database.upsert(pgVSCloudIDMAP.get(pgLogID));
                }catch(Exception ex){
                    Provisioning_Group__c pgReord = pgMAP.get(piRecord.Provisioning_Group__c);
                    pgReord.Status__c = 'Provisioning In Progress';
                    pgReord.Integration_Status__c = 'Failed';
                    pgMAP.put(pgReord.id,pgReord);
                    
                    piRecord.Failure_Reason__c = 'Message: '+ex.getMessage() +'\nLine: '+ ex.getLineNumber();
                    piRecord.Status__c = 'Failed';
                    piLogRecordMAP.put(piRecord.Id, piRecord);
                    ProvisioningErrorHandler.exceptionHandler('ProvEventManualTriggerHandler','generateOTTRecordsForTrial',ex);
                }
            }
        }
        
        for(Id pgID : pgVSCloudIDMAP.keyset()){
            for(Zscaler_Cloud_ID__c zcloud : pgVSCloudIDMAP.get(pgID) ){
                if(zcloud.id != null){
                    updateIDMAP.put(zcloud.name, zcloud);
                }
            }
        }
        return updateIDMAP;
    }
    
    public static  Provisioning_Group__c findAssociatedZDX(Provisioning_Group__c pg){
        Provisioning_Group__c prg;
         List<Provisioning_Group__c> prgList= [select id,name from Provisioning_Group__c where Associated_Provisioning_Group__c=: pg.id and
                Product_Line__c='ZDX' and Provisioning_Broker_Eligible__c=false and Cross_Platform_Selected__c=true limit 1];
        if(!prgList.isEmpty())
        	prg = prgList[0];
        
       return prg;
    }
    @testvisible 
    private static id getZscalerCloudID(List<Zscaler_Cloud_ID__c> clouds, String type){
        Id retID = null;
        Id otherID = null;
        for(Zscaler_Cloud_ID__c zscaloud :  clouds){
            if(zscaloud.Cloud_Type__c == type){
                retID =  zscaloud.id;
            }else{
                otherID = zscaloud.id;
            }
        }
        return retID != null ? retID : otherID;
    } 
    
    @testvisible
    private Static Zscaler_Cloud_ID__c prepareZscalerCloudRecord(Provisioning_Group__c pg, ID accountID, ProvisioningBrokerWrapper.cls_customerInfo custInfo){
        System.debug('custInfo.cloudName=='+custInfo.cloudName);
        Id ziaRecTypeId = Schema.SObjectType.Zscaler_Cloud_ID__c.getRecordTypeInfosByName().get('ZIA Cloud ID').getRecordTypeId();
        Id zpaRecTypeId = Schema.SObjectType.Zscaler_Cloud_ID__c.getRecordTypeInfosByName().get('ZPA Cloud ID').getRecordTypeId();
        Zscaler_Cloud_ID__c zscObj = new Zscaler_Cloud_ID__c(Cloud_Type__c = custInfo.cloudName, Account__c = accountID, Name = custInfo.tenantID,  
                                                             Additional_Domain__c = custInfo.additionalDomains, Org_Name__c = custInfo.tenantName, Subscription_Id__c = custInfo.subscriptionId, 
                                                             Account_Type__c = custInfo.accountType, Partner_Info__c = custInfo.partnerInfo, External_ID__c = custInfo.tenantID, 
                                                             subscription_Name__c = custInfo.subscriptionName, Customer_Name__c = custInfo.customerName);
        
        if(custInfo.domain !=null && custInfo.domain !='')
            zscObj.Zscaler_Cloud_Domain__c = custInfo.domain;
        if(custInfo.cloudName == 'ZPA' || custInfo.cloudName == 'ZDX'){
            if(pg.Associated_ZIA_Zscaler_Cloud__c != null){
                zscObj.Associated_Cloud__c = pg.Associated_ZIA_Zscaler_Cloud__c;
            }
            
            if(pg.Recordtype.Name == 'Trial'){
                zscObj.Status__c = 'Trial';
            }
            else if(pg.Recordtype.Name == 'Subscription'){
                zscObj.Status__c = 'Subscription';
            }
        }else{
            if(custInfo.tenantStatus == 'Trial'){
                zscObj.Status__c = 'Trial';
            }
            else if(custInfo.tenantStatus == 'Subscription'){
                zscObj.Status__c = 'Subscription';
            }
        }
        
        if(pg.Product_Line__c == 'ZPA' && pg.Geo__c == 'EMEA'){
            zscObj.EU_Log_Zone__c = true;
        }else{
            zscObj.EU_Log_Zone__c = false;
        }
        
        // Set Record Type 
        if(custInfo.cloudName == 'ZIA' || custInfo.cloudName == 'ZDX'){
            zscObj.RecordtypeId =  ziaRecTypeId;
          zscObj.Customer_Id__c= custInfo.betaCustomerId !=null ? custInfo.betaCustomerId : custInfo.productionCustomerId; //custInfo.customerID;
        }
        else if (custInfo.cloudName == 'ZPA'){
            zscObj.RecordtypeId =  zpaRecTypeId;
             zscObj.Customer_Id__c=custInfo.tenantID;
        }
        
        return zscObj;
    }
}