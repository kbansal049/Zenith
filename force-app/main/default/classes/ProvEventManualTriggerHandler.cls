public without sharing class ProvEventManualTriggerHandler {
    
    public static Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
    
    public static void ProvEventManualProcessing(List<Provisioning_Event_Manual__e> prvEvnt) {
        System.debug('--ProvEventManualProcessing--ProvEventAPICallout called---');
        
        Set<Id> pgIdSet = new Set<Id>();
        Map<Id,String> mapPgidvsCount = new Map<Id,String>();
        for(Provisioning_Event_Manual__e event:prvEvnt){
            System.debug('event.Retry_Count__c '+event.Retry_Count__c );
            System.debug('');
            if(event.PG_ID__c !=null && (event.Retry_Count__c ==null 
                                         || Integer.valueOf(System.label.Max_Platfrom_Event_Retry) > Integer.valueOf(event.Retry_Count__c))){
                                             // pgIdSet.add(event.PG_ID__c);
                                             mapPgidvsCount.put(event.PG_ID__c,event.Retry_Count__c);
                                         }
        }
        System.debug('--ProvEventManualProcessing--pgIdSet---'+pgIdSet);
        if(mapPgidvsCount.size()>0){
            processMannual(mapPgidvsCount); 
            // processMannual(pgIdSet,mapPgidvsCount); 
        }  
    }
    
    
    //For CBI Craete Case
    private static void processMannual( Map<Id,String> mapPgidvsCount){ //Set<ID> pgIDs,
        
        if(mapPgidvsCount != null && !mapPgidvsCount.isEmpty()) {
            
            MAP<ID, Provisioning_Group__c> pgMAP = new MAP<ID, Provisioning_Group__c> ([Select id,name,Product_Line__c,Provisioning_Request__c,Proxy_Cloud__c,
                                                                                        Recordtype.Name,Failure_Reason__c,opportunity__r.SE_Name__r.email,
                                                                                        PG_for_Subscription__c,Cross_Platform_Selected__c,
                                                                                        Opportunity__c 
                                                                                        from Provisioning_Group__c where id in :mapPgidvsCount.keySet()]);
            
            MAP<ID, Provisioning_Integration_Log__c> piRecordUpdateMAP = new MAP<ID, Provisioning_Integration_Log__c>();
            
            
            List<Provisioning_Group__c> createCaseRecord = new List<Provisioning_Group__c>();
            List<Provisioning_Group__c> createOTTRecord = new List<Provisioning_Group__c>();
            for(Provisioning_Group__c pgRecord : pgMAP.values()){
                if(mapPgidvsCount.containskey(pgRecord.id)){
                    if( mapPgidvsCount.get(pgRecord.id) ==null 
                       || Integer.valueOf(System.label.Max_Platfrom_Event_Retry) > Integer.valueOf(mapPgidvsCount.get(pgRecord.id))){
                           if(pgRecord.PG_for_Subscription__c == true && pgRecord.Cross_Platform_Selected__c == false){
                               createOTTRecord.add(pgRecord);
                           }else{
                               switch on pgRecord.Recordtype.Name {
                                   when  'Trial'{
                                       createCaseRecord.add(pgRecord);
                                   }
                                   when 'Subscription'{
                                       createOTTRecord.add(pgRecord);
                                   }
                                   when 'Internal Provisioning'{
                                       createCaseRecord.add(pgRecord);
                                   }
                               }
                           }
                       }
                }
            }
            System.debug('----createCaseRecord---'+createCaseRecord);
            if(!createCaseRecord.isEmpty()){
                generateCaseRecordsForTrial(createCaseRecord,mapPgidvsCount);
            }
            
            System.debug('----createOTTRecord---'+createOTTRecord);
            if(!createOTTRecord.isEmpty()){
                generateOTTRecordsForTrial(createOTTRecord);
            }
        }
    }
    
    
    
    public static void generateCaseRecordsForTrial(List<Provisioning_Group__c> pgRecords, Map<Id,String> mapPgidvsCount){
        System.debug('Inside method generateCaseRecordsForTrial');
        MAP<ID, Provisioning_Group__c> pgMAP = new MAP<ID, Provisioning_Group__c>(pgRecords);
        
        Set<Id> accountIdList = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        List<Provisioning_Group__c> prGrpList = [select id,RecordTypeId,RecordType.Name,Proxy_Cloud__c,
                                                 PG_Request_Type__c,Product_Line__c,
                                                 Preferred_Cloud__c,Associated_ZIA_Zscaler_Cloud__c,Associated_ZIA_Zscaler_Cloud__r.name,
                                                 Name,Status__c,Organization_Domain__c,Start_Date__c,End_Date__c, 
                                                 Approval_Status__c,Failure_Reason__c,
                                                 Provisioning_Request__c,
                                                 Provisioning_Request__r.Preferred_Cloud__c,
                                                 Opportunity__c,opportunity__r.SE_Name__r.email,
                                                 Opportunity__r.Name,opportunity__r.Type,
                                                 Account__c,
                                                 Account__r.BillingCountry,Account__r.ZIA_Customer_Id__c,Account__r.BillingStreet,Account__r.BillingState,Account__r.BillingPostalCode,
                                                 Account__r.name,Account__r.Parent.name,Account__r.Operational_HQ__c,Account__r.billingAddress, 
                                                 Account__r.Area__c , Account__r.Type, Account__r.No_of_Employees_Users__c,Account__r.Industry,
                                                 Zscaler_Cloud_ID__c,
                                                 Zscaler_Cloud_ID__r.Name,
                                                 (select id,Contact__c,Email__c,Type__c,Provisioning_Group__c,User__c,User_Name__c from Provisioning_Contacts__r),
                                                 (select id,SKU__c,Product__r.name,Quantity__c,Product_Line__c from Provisioning_Products__r),
                                                 (select id,NS_Sales_Order_Number__c, Type, Order_Date__c, EffectiveDate, EndDate, Status from Orders__r),
                                                 Comments__c,
                                                 CreatedDate,
                                                 ownerID,
                                                 owner.Email,
                                                 Owner.Name
                                                 from Provisioning_Group__c 
                                                 where id IN: pgMAP.keyset() 
                                                 and Account__c != null
                                                ];
        
        if(prGrpList !=null && prGrpList.size()>0){
            for(Provisioning_Group__c provGrp :prGrpList ){
                accountIdList.add(provGrp.Account__c);
            }
        }
        if(!accountIdList.isEmpty() && accountIdList.size()>0){           
            conList=[Select Id,AccountId,Email from Contact where AccountId IN : accountIdList limit 1000];    
        }
        
        List<Provisioning_Group__c> pgList = new List<Provisioning_Group__c>();
        
        MAP<Id, Case> pgCaseMAP = new MAP<Id, Case>();
        for(Provisioning_Group__c pg : prGrpList){
            if(pg.RecordType.Name =='Trial'){
                case tCase =  createCase(pg,conList,'Provisioning Broker processing failed');
                if(tCase != null){
                    pgCaseMAP.put(pg.ID,tCase);
                }
                
                
            }
            if(pg.RecordType.Name =='Internal Provisioning'){
                case intCase =  createCase(pg,conList,'Internal Provisioning Case');
                if(intCase != null){
                    pgCaseMAP.put(pg.ID,intCase);
                }
            }
        }
        System.debug('---pgCaseMAP--'+pgCaseMAP);
        if(pgCaseMAP.values().size()>0){
            List<Provisioning_Event_Manual__e> pgevntManualList = new list<Provisioning_Event_Manual__e>();
            
            TriggerHandler.bypass('AccountTriggerHandler');
            Database.SaveResult[] rsList =  Database.insert(pgCaseMAP.values(), false);
            boolean isError = false;
            Database.Error err;
            integer i=0;
            Set<Id> erroredPgSet = new Set<Id>();
            for (Database.SaveResult sr : rsList) {
                if (!sr.isSuccess()){
                    Case cs = pgCaseMAP.values()[i];
                    if(!test.isRunningTest()){
                        for(Database.Error errObj : sr.getErrors()) {
                            String Errormessage = String.valueOf(errObj.getStatusCode());
                            if(Errormessage.contains('UNABLE_TO_LOCK_ROW')) //   REQUIRED_FIELD_MISSING
                                erroredPgSet.add(cs.Provisioning_Group__c);                    
                            System.debug(errObj.getStatusCode() + ': ' + errObj.getMessage());
                        }
                    } else {
                        Provisioning_Group__c pgtest = [select id from Provisioning_Group__c limit 1];
                        erroredPgSet.add(pgtest.id);
                    }
                    isError = true;
                    err = sr.getErrors()[0];
				 }
                 i++;
            }
            if(isError)
                ProvisioningErrorHandler.databaseExceptionHandler('ProvEventManualTriggerHandler','generateOTTRecordsForTrial',err);
            System.debug('erroredPgSet=='+erroredPgSet);
            if(erroredPgSet !=null){
                for(Id pgID : erroredPgSet){ //pgCaseMAP.keyset()
                    Case cs = pgCaseMAP.get(pgID);
                    if(cs.ID == null){
                        System.debug('Count before='+mapPgidvsCount.get(pgID));
                         String count = String.valueOf( mapPgidvsCount.get(pgID)!=null ? Integer.valueOf(mapPgidvsCount.get(pgID))+1 : 1);
                        System.debug('Count after='+count);
                        pgevntManualList.add(new Provisioning_Event_Manual__e(PG_ID__c= pgID,Retry_Count__c= count));
                    }
                }
            }
            System.debug('---pgevntManualList--'+pgevntManualList);
            if(pgevntManualList.size()>0){
                EventBus.publish(pgevntManualList);
            }
        }
    }
    
    
    
    
    @testVisible
    public static void generateOTTRecordsForTrial(List<Provisioning_Group__c> pgRecords){
        MAP<ID, Provisioning_Group__c> pgMAP = new MAP<ID, Provisioning_Group__c>(pgRecords);
        
        
        Set<Id> oppIdList = new Set<Id>();
        for(Provisioning_Group__c pg : pgMAP.values()){
            if(pg.Opportunity__c != null){
                oppIdList.add(pg.Opportunity__c);
            }
        }
        
        MAP<ID, opportunity> oppMAP = new  MAP<ID, opportunity>(getOppRecord(oppIDList));
        
        
        List<Provisioning_Group__c> pgList = new List<Provisioning_Group__c>();
        List<Email_Tracker__c> ettRecordList = new List<Email_Tracker__c>();
        for(Provisioning_Group__c pg : [select id,RecordTypeId,RecordType.Name,PG_Request_Type__c,Product_Line__c,Proxy_Cloud__c,
                                        Associated_ZIA_Zscaler_Cloud__c,Associated_ZIA_Zscaler_Cloud__r.name,
                                        Name,Status__c,Organization_Domain__c,Start_Date__c,End_Date__c, 
                                        Approval_Status__c,
                                        Provisioning_Request__c,
                                        Opportunity__c,
                                        Opportunity__r.Name,opportunity__r.Type,
                                        opportunity__r.OwnerID,opportunity__r.Owner.Email,
                                        Account__c,Failure_Reason__c,Account__r.ZIA_Customer_Id__c,
                                        Account__r.name,Account__r.Parent.name,Account__r.Operational_HQ__c,Account__r.billingAddress, 
                                        Account__r.Area__c , Account__r.Type, Account__r.No_of_Employees_Users__c,Account__r.Industry,
                                        Zscaler_Cloud_ID__c,
                                        Zscaler_Cloud_ID__r.Name,opportunity__r.SE_Name__r.email,
                                        Comments__c,
                                        CreatedDate,
                                        ownerid,
                                        owner.email
                                        from Provisioning_Group__c 
                                        where id IN: pgMAP.keyset() 
                                        and Account__c != null
                                       ])
        {
            //if(oppMAP.containsKey(pg.Opportunity__c)){
            //opportunity opp = oppMAP.get(pg.Opportunity__c);
            ettRecordList.add(createETTRecord(pg));
            //}
        }
        try{
            insert ettRecordList;
            System.debug('---ettRecordList---'+ettRecordList);
        } catch(Exception e){
            ProvisioningErrorHandler.exceptionHandler('ProvEventManualTriggerHandler','generateOTTRecordsForTrial',e);
        }
        
    }
    
    
    
    @testvisible
    private static Email_Tracker__c createETTRecord(Provisioning_Group__c pg)
    {
        //IBA-3511
        String fromEmail = pg.Opportunity__c != null ? pg.Opportunity__r.Owner.Email : pg.owner.email;
        Email_Tracker__c ottRecord = null;
        ottRecord = new Email_Tracker__c();
        ottRecord.From__c = fromEmail;
        ottRecord.Email_Category__c = 'License activation/migration';
        ottRecord.Email_Subject__c = 'PRG Broker : Provisioning Failed :'+pg.Name;
        ottRecord.body__c = 'PRG Record : '+pg.Name+ '\n'+'\n'+ 'Failure Reason :'+pg.Failure_Reason__c+'\n';
        ottRecord.isNewFlag__c = true;
        ottrecord.Requester_Org__c = 'Provisioning';
        ottrecord.Priority__c = 'High';
        ottrecord.Requester_Name__c = fromEmail;
        ottrecord.Status__c = 'Not Started';
        ottrecord.BOT_Email_Id__c = System.label.Orders_Mail_Box;
        if( pg.id !=null)
            ottRecord.Provisioning_Group__c = pg.id;
        return ottRecord;
    }
    
    
    
    
    public static Case createCase(Provisioning_Group__c pg,List<Contact> accConatact, String sub){
        
        Map<String, DefaultData__c> ddmap = DefaultData__c.getAll();
        if(ddmap != null && !ddmap.isEmpty() && ddmap.containsKey('PRCaseCreationDefault') && pg.id != null){
            DefaultData__c dd = ddmap.get('PRCaseCreationDefault');
            
            List<Provisioning_Contact__c> pgContactList = pg.Provisioning_Contacts__r;
            List<Provisioning_Product__c> pgProductsList = pg.Provisioning_Products__r;
            String provProd = getProvProducts(pgProductsList);
            Provisioning_Contact__c seRecord = retriveSEProvContact(pgContactList);
            
            Case cs = new Case(RecordTypeId = caseSupportRT);
            // cs.Provisioning_Request__c = pg.Provisioning_Request__c;
            cs.Provisioning_Group__c = pg.Id;
            if(pg.Product_Line__c != null && pg.Product_Line__c.containsignorecase('ZPA')){
                cs.Product_New__c='ZPA';
            }else{
                cs.Product_New__c ='ZIA';
            }   
            cs.Case_Type__c = dd.Type__c;
            cs.Case_Category__c = dd.Category__c;
            cs.Subject = ' New POC is requested for '+pg.Product_Line__c+' Tenant : '+pg.Name+' : '+pg.Account__r.Name ;
            cs.Status = dd.Stage_Status__c;
            cs.Priority = dd.Priority__c;
            if(!test.isRunningTest())
             cs.AccountId = System.label.zscaler_provisioning_account_Id; //pg.Account__c;  
            else 
                 cs.AccountId = pg.Account__c;
            
            String products = provProd != null ? provProd  :' ';
            String comments = pg.Comments__c!=null?pg.Comments__c:' ';
            String existingTenant = pg.Zscaler_Cloud_ID__c != null && pg.Zscaler_Cloud_ID__r.name!=null?pg.Zscaler_Cloud_ID__r.name: '-NA-';
            
            cs.Description = 'Organisation Domain: '+pg.Organization_Domain__c
                +'\n Provisioning Request Group Number: '+ pg.Name
                +'\n Preferred Cloud: '+pg.Preferred_Cloud__c
                +'\n Product Line: '+pg.Product_Line__c
                +'\n Billing Address: '+pg.Account__r.BillingStreet+' '+pg.Account__r.BillingState+' '+pg.Account__r.BillingCountry+' '+pg.Account__r.BillingPostalCode
                +'\n Account Name: '+pg.Account__r.Name 
                +'\n Existing tenant id: '+existingTenant
                +'\n Associated ZIA Cloud: '+pg.Associated_ZIA_Zscaler_Cloud__r.name
                +'\n Failure Reason: '+pg.Failure_Reason__c;
            if(pg.Account__r.ZIA_Customer_Id__c !=null && pg.Account__r.ZIA_Customer_Id__c !='')
                cs.Description =   cs.Description+'\n Customer Id : '+pg.Account__r.ZIA_Customer_Id__c ;
                //start changes added for IBA-5202
            if(pg.Product_Line__c=='ZPA'){
                cs.Description =   cs.Description+'\n Proxy Cloud : '+pg.Proxy_Cloud__c;
            }//end changes added for IBA-5202
            
            cs.ContactId=retriveContactFromProvContacts(pg, pgContactList, accConatact);
            cs.SE_Email__c = pg.opportunity__r.SE_Name__r.email;
            
            //If nothing is Satisfied
            if(cs.ContactId == null && pg.Owner.Name != null) {
                TriggerHandler.bypass('ContactTriggerHandler');
                String fullname = pg.Owner.Name;
                System.debug('---fullname--'+fullname);
                Integer i = fullname.lastIndexOf(' '); 
                String firstname = fullname.substring(0, i);
                String lastname = fullname.substring(i+1);
                
                Contact con= new Contact(LastName=lastname,FirstName=firstname,AccountId=System.Label.Account_of_Zscaler,Project_Role__c='Other',LeadSource='Zscaler Employee',Email= pg.Owner.Email);
                TriggerUtility.SkipContactTriggerExecuted();
                try{
                    insert con;
                } catch(Exception e){
                    ProvisioningErrorHandler.exceptionHandler('ProvEventManualTriggerHandler','generateOTTRecordsForTrial',e);
                }
                cs.ContactId = con.id;
            }
            
            cs.Opportunity_Name__c = pg.Opportunity__c;
            System.debug('return case');
            return cs;
        }
        return null;
    }
    
    
    
    @testVisible
    private static Id retriveContactFromProvContacts(Provisioning_Group__c pg, List<Provisioning_Contact__c> conList,  List<Contact> accContacts){
        ID contactID = null;
        String seEmail = null;
        String zsaccId = System.label.Zscaler_Account_Id;
        for(Provisioning_Contact__c pCon : conList){
            if(pCon.Type__c == 'SALES_ENGINEER' && pCon.User__c != null){
                seEmail = pCon.Email__c;
            }
        }
        Contact cn;
        if( !Test.isRunningTest())
            cn = [select id , email from Contact where AccountId =:zsaccId and email =: seEmail limit 1];
        else 
            cn = [select id, email from Contact limit 1];
        if(cn !=null)
            return cn.id;
        /* for(Contact con : accContacts){
if(con.email == seEmail){
return con.id;
}
}

String userEmail = UserInfo.getUserEmail();
for(Contact con : accContacts){
if(pg.Account__c ==  con.AccountID && con.email == userEmail){
return con.id;
}
} */
        return contactID;
    }
    
    
    @testVisible
    private Static String getProvProducts(List<Provisioning_Product__c> pgProductsList){
        String products = null;
        Set<String> prodSKU = new Set<String>();
        for(Provisioning_Product__c poc : pgProductsList){
            prodSKU.add(poc.SKU__c);
        }
        return products;
    }
    
    @testVisible
    private static Provisioning_Contact__c retriveSEProvContact(List<Provisioning_Contact__c> conList){
        for(Provisioning_Contact__c pCon : conList){
            if(pCon.Type__c == 'SALES_ENGINEER'){
                return pCon;
            }
        }
        return null;
    }   
    
    @testVisible
    private static List<Opportunity> getOppRecord(Set<Id> oppIDList){
        List<Opportunity> opp = [SELECT Id, Name,Amount,Type,StageName,
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
                                 PO_Source__c
                                 
                                 FROM Opportunity WHERE Id in :oppIDList];
        return opp;
    }
}