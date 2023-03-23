/*****************************************************************************************
Name: DealRegConversionController
Copyright © Zscaler
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            NA                      NA                Initial Development
2.0            Bharath                 1/19/2022         CR# 3952 - Link DR with Partner and Distributor
3.0            Swathi                  2/25/2022         CR#3744 - ProfessionalService Partner
4.0            Swathi                  3/21/2022         CR#4500 - Commenting lines of Deal Reg expiartion date
5.0            Mahesh T		       	   3/21/2022         CR#3334 - To populate Target Customer on Opp
6.0            Swathi                  7/22/2022         CR#4932/IBA-1511 and IBA-1599
7.0            Ram S                   8/15/2022         Refactored the entire class to resolve too many SOQL : 101 error
******************************************************************************************/
public class DealRegConversionController {
    public static String dealRegId;
    public static String convertedOppId;
    public static String selectedOppId;
    public static Deal_Reg__c dealReg;
    public static Opportunity opp;
    public static List<OpportunityListWrapper> oppWrapperList;
    public static List<Opportunity> oppList = new list<Opportunity>();
    public static Map<id, id> oppIdAccountIdMap = new map<id, id>();
    public static Map<String, Id> oppPartTypetoOppPartID = new Map<String, Id>();
    public static Map<String, Id> cosellOppPartTypetoOppPartID = new Map<String, Id>();
    public static Map<Id, Map<String, Opportunity_Partner__c>> mapOpptoOppPart = new Map<Id, Map<String, Opportunity_Partner__c>>();
    public static Map<Id, List<Opportunity_Partner__c>> existingdealReg = new Map<Id, List<Opportunity_Partner__c>>();
    public static Map<Id,Opportunity_Partner__c> existingTechnologyDRs = new Map<Id,Opportunity_Partner__c>();
    
    private static void initializeVariables(String dealRegIdfromLWC){
        System.debug('1 ===>> In initializeVariables(), dealRegIdfromLWC is: '+dealRegIdfromLWC);
        dealReg = new Deal_Reg__c();
        oppList = new list<Opportunity>();
        oppWrapperList = new  list<OpportunityListWrapper>();
        if(String.isNotBlank(dealRegIdfromLWC)){
            dealRegId = dealRegIdfromLWC;
        }else{
            dealRegId = ApexPages.currentPage().getParameters().get('Id');
        }
        System.debug('### dealRegId: '+dealRegId);
        //Modified by Abhishek  : CR# 39 : Partner Margin : Start
        
        if(String.isNotBlank(dealRegId)){
            //CR# 3952 - Updated Query fields for Deal Reg
			//CR# 3744 - Updated Query fields to add Delivery_Intent__c and Service_Authorizations__c
            dealReg = [SELECT Id, Name, Partner_Type__c, Deal_Reg_Type__c, Delivery_Intent__c, NBM_Meeting_Date__c, Discovery_Meeting_Date__c, Deal_Reg_Expiration_Date__c, Partner_Contact__c, Partner_Contact_Email__c, 
                        Account_Manager__c, AW_Partner_Intent__c, POV_Partner_Intent__c,AW_POV_Partner_Intent__c, Partner_Account_Program__c, Partner_Program__c, Partner_Category__c, End_Customer_Name__c,  
                        Partner_Account__c, Estimated_Amount__c, Expected_Close_Date__c,Partner_Company_Name__c, Lead__c, Contact__c, Contact__r.AccountId, OwnerId, End_Customer_Domain__c, 
                        End_Customer_Street_Address__c, End_Customer_City__c, End_Customer_State__c, End_Customer_Country__c, End_Customer_Postal_Code__c, Record_Type_Name__c,Account_Type__c, 
                        Distributor__c, Partner_Account__r.SummitDistribution__c, Partner_Account__r.Service_Authorizations__c, Target_Customer__r.Name, AVP_Approval__c,
                        Sales_Engineer_Email__c, Sales_Engineer_Name__c, Sales_Rep_Email__c, Sales_Rep_Name__c ,Partner_Account__r.Name,Status__c
                        FROM Deal_Reg__c WHERE ID = :dealRegId];
            String domain = dealReg.End_Customer_Domain__c;
            
            Set<String> stagetoExclude = new Set<String>{
                	Label.Stage_5_Contracts_Complete, 
                    Label.Stage_5A_Opportunity, 
                    Label.Stage_5B_Opportunity, 
                    Label.Stage_5C_Opportunity
			};

            Set<String> typetoExclude = new Set<String>{
                	Label.Opportunity_Type_New_Business, 
                    Label.Opportunity_Type_Upsell
			};
            
            String query = 'SELECT Id, Name, AccountId, Account.Name, OwnerId, Owner.Name, StageName, CloseDate, Amount, Type, Deal_Reg__c, Deal_Reg_Teaming_Reseller__c,'
                    + ' Deal_Reg__r.Name, Deal_Reg__r.Partner_Account__c, Deal_Reg__r.Partner_Account__r.Name,'
                    + ' Deal_Reg__r.Partner_Type__c, Deal_Reg__r.Deal_Reg_Type__c, Deal_Reg__r.Status__c,RecordType.Name,'
                    + ' Deal_Reg_Teaming_Reseller__r.Name, Deal_Reg_Teaming_Reseller__r.Partner_Account__c, Deal_Reg_Teaming_Reseller__r.Partner_Account__r.Name,'
                    + ' Deal_Reg_Teaming_Reseller__r.Partner_Type__c, Deal_Reg_Teaming_Reseller__r.Deal_Reg_Type__c, Deal_Reg_Teaming_Reseller__r.Status__c,'
                    //+ ' Renewal_Deal_Registration__r.Name, Renewal_Deal_Registration__r.Partner_Account__c, Renewal_Deal_Registration__r.Partner_Account__r.Name,'
                    //+ ' Renewal_Deal_Registration__r.Partner_Type__c, Renewal_Deal_Registration__r.Deal_Reg_Type__c, Renewal_Deal_Registration__r.Status__c,'
                    + ' (SELECT Id, Opportunity__c, Account__c,Account__r.Name,Deal_Registration__c,Deal_Registration__r.Name,Deal_Reg_Status__c,Deal_Reg_Partner_Type__c,Deal_Reg_Type__c, Is_Primary__c, Partner_Type__c FROM Opportunity_Partners__r WHERE Partner_Type__c IN (\'Reseller\', \'Tech Partner\', \'System Integrator\', \'Distributor\', \'Deal Reg\',\'Professional Services\')),'
                    + ' (SELECT Id, Activity__c, Age_in_Current_Status__c, Deal_Reg__c, Opportunity__c, Partner__c, Partner_Contact__c, Status__c FROM Opportunity_Cosell_Partners__r)'
                    + ' FROM Opportunity'
                	+ ' WHERE Account.Domain__c = :domain AND isClosed = false AND StageName NOT IN :stagetoExclude';
            for(Opportunity opp : Database.query(query)){
                oppList.add(opp);
                Map<String, Opportunity_Partner__c> mapOppPartners = new Map<String, Opportunity_Partner__c>();
                List<Opportunity_Partner__c> existingDRs = new List<Opportunity_Partner__c>();
                for(Opportunity_Partner__c op: opp.Opportunity_Partners__r){
                    if(op.Is_Primary__c && !mapOppPartners.containsKey(op.Partner_Type__c)){
                        mapOppPartners.put(op.Partner_Type__c, op);
                    }
                    if(op.Partner_Type__c == 'Deal Reg'){
                        existingDRs.add(op);
                    }
                    if(op.Opportunity__c != null && op.Partner_Type__c != null && op.Account__c != null){
                        oppPartTypetoOppPartID.put('' + op.Opportunity__c + op.Account__c + op.Partner_Type__c, op.Id);
                    }
                    if(op.Partner_Type__c == 'Deal Reg' && op.Deal_Reg_Status__c == 'Converted' && op.Deal_Reg_Partner_Type__c == 'Technology Partner' && op.Deal_Reg_Type__c == 'Teaming'){
                        existingTechnologyDRs.put(op.Opportunity__c,op);
                    }
                }
                System.debug('### mapOppPartners: '+mapOppPartners);
                System.debug('### existingTechnologyDRs: '+existingTechnologyDRs);
                
                if(!existingDRs.isEmpty()){
                    existingdealReg.put(opp.Id, existingDRs);
                }
                
                if(!mapOppPartners.isEmpty()){
                    mapOpptoOppPart.put(opp.Id, mapOppPartners);
                }
                
                for(Cosell_Activities__c op : opp.Opportunity_Cosell_Partners__r){
                    if(op.Opportunity__c != null && op.Activity__c != null && op.Partner__c != null){
                        cosellOppPartTypetoOppPartID.put('' + op.Opportunity__c + op.Partner__c + op.Activity__c, op.Id);
                    }
                }
            }
        }
        System.debug('### mapOpptoOppPart: '+mapOpptoOppPart);   
        //Modified by Abhishek  : CR# 39 : Partner Margin : End
    }
    
    public static PageReference convertDealReg(String dealRegIdToConvert) {
        System.debug('DealRegConversionController.convertDealReg(), dealRegIdToConvert val is: '+dealRegIdToConvert);
        System.debug('In DealRegConversionController.convertDealReg() Beginning, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        
        System.debug('DealRegConversionController.convertDealReg() Before Intitialize, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        initializeVariables(dealRegIdToConvert);
        System.debug('DealRegConversionController.convertDealReg() Afetr Intitialize, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        
        PageReference pageRef = null;
        if(dealReg != null){
            if(!oppList.isEmpty()){
                if(dealReg.Deal_Reg_Type__c != Label.Deal_Reg_Type_Teaming){
                    oppWrapperList.add(new OpportunityListWrapper(true, 'Create a New Opportunity'));
                }
                for(Opportunity opp : oppList){
                    oppIdAccountIdMap.put(opp.Id, opp.AccountId);
                    if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming && dealReg.Partner_Type__c == 'Technology Partner')
                    	oppWrapperList.add(new OpportunityListWrapper(false, opp,existingTechnologyDRs.get(opp.Id)));
                    else{
                        oppWrapperList.add(new OpportunityListWrapper(false, opp,Null));
                    }
                }
            }else if(dealReg.Deal_Reg_Type__c != Label.Deal_Reg_Type_Teaming){
                System.debug('In else condition');
                if(dealReg.Lead__c != null){
                    System.debug('In lead conversion method');
                    pageRef = leadConversion(dealReg.Lead__c);
                }else if(dealReg.Contact__c != null){
                    System.debug('In contact conversion method');
                   pageRef = contactConversion();
                }else if(null == dealReg.Lead__c && null == dealReg.Contact__c){
                    System.debug('In opportunity conversion method');
                    pageRef = opportunityConversion();
                }
            }
        }
        System.debug('In DealRegConversionController.convertDealReg() Ending, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        return pageRef;
    }

    public static PageReference opportunityConversion() {
        System.debug('000(A) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() Beginning, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        //1. If no contact or lead is found, create a new account and an opportunity with all existing mappings per contactConversion() method
        //2. If an account matches with the same domain, do not create a new one
        //   Also, if an opportunity matches with deal reg, let the user tag the existing one or create a new one - This is handled in the constructor and action method

        Id customerAccountId;
        Boolean isFederalAccountSync;
        System.debug('000(B) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() Before Customer Account SOQL, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        List<Account> accList = [SELECT Id, Is_Federal_Account_Sync__c FROM Account WHERE Domain__c = :dealReg.End_Customer_Domain__c ORDER BY CreatedDate DESC LIMIT 1];
        for (Account account : accList) {
            customerAccountId = account.Id;
            isFederalAccountSync = account.Is_Federal_Account_Sync__c;
        }
        System.debug('customerAccountId: '+customerAccountId);
        System.debug('isFederalAccountSync: '+isFederalAccountSync);

        if (null == customerAccountId) {
            Account newAccount = new Account(
                                        Name = dealReg.End_Customer_Name__c,
                                        BillingStreet = dealReg.End_Customer_Street_Address__c,
                                        BillingCity = dealReg.End_Customer_City__c,
                                        BillingState = dealReg.End_Customer_State__c,
                                        BillingCountry = dealReg.End_Customer_Country__c,
                                        BillingPostalCode = dealReg.End_Customer_Postal_Code__c,
                                        Domain__c = dealReg.End_Customer_Domain__c
                                    );
            System.debug('newAccount: '+newAccount);
            System.debug('000(C) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() Before Account Creation, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
            insert newAccount;
            System.debug('000(D) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() After Account Creation, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());

            customerAccountId = newAccount.Id;
        }
        
        System.debug('000(E) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() Before Oppt rec Prepation, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        opp = createOpportunity(customerAccountId, isFederalAccountSync);
        System.debug('000(F) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() After Oppt rec Prepation, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());

        TriggerUtility.OppBeforeInsertExecuted();
        TriggerUtility.OppAfterInsertExecuted();
        TriggerUtility.OppBeforeUpdateExecuted();
        TriggerUtility.OppAfterUpdateExecuted();
        
        System.debug('000(G) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() Before Oppt rec Creation, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        insert opp;
        System.debug('000(H) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() After Oppt rec Creation, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());

        //Modified by Abhishek  : CR# 39 : Partner Margin : Start
        if (null != dealReg.Partner_Account__c) {
            System.debug('000(I) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() Before Oppt Partner rec Creation, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
            createOpportunityPartner(dealReg.Partner_Account__c, opp.Id, dealRegId);
            System.debug('000(J) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() After Oppt Partner rec Creation, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        }
        //Modified by Abhishek  : CR# 39 : Partner Margin : End

        //Modified by Abhishek  : Partner Portal : Start
        if (null != dealReg.Partner_Account__c) {
            System.debug('000(K) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() Before Cosell rec Creation, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
            createCosellActivity(opp.Id, dealRegId);
            System.debug('000(L) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() After Cosell rec Creation, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        }
        //Modified by Abhishek  : Partner Portal : End

        System.debug('000(M) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() Before DR status updation, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        updateDealStatustoConverted(dealRegId);
        System.debug('000(N) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() After DR status updation, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());

        PageReference opportunityDetailPage = new PageReference('/' + opp.Id);
        convertedOppId = opp.Id;
        System.debug('000(O) ==>>> DealRegConversionController.opportunityConversion().opportunityConversion() Ending, SOQLs: '+Limits.getQueries()+'; DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        return opportunityDetailPage;
    }
    
    public static PageReference leadConversion(Id leadId){
        System.debug('DealRegConversionController.leadConversion(), leadId val is: '+leadId);
        System.debug('1010(A) ==>>> DealRegConversionController.leadConversion() Beginning, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        PageReference pageRef = null;
        try{
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadId);
            //Modified by Abhishek  : CR# 432 : Start
            //lc.setOwnerId(dealReg.OwnerId);
            lc.setOwnerId(dealReg.Account_Manager__c);
            //Modified by Abhishek  : CR# 432 : Start
            //lc.ConvertedStatus = 'Converted - New Opportunity';
            
            //added by Gurjinder : CR#163 :Start
            String LeadConversionStatus= ZscalerCustomSetting__c.getInstance('LeadConversionStatus')!=null && ZscalerCustomSetting__c.getInstance('LeadConversionStatus').Value__c!=null ? ZscalerCustomSetting__c.getInstance('LeadConversionStatus').Value__c:'Actively Engaged';
            //lc.ConvertedStatus = 'VO';
            lc.ConvertedStatus = LeadConversionStatus;
            //added by Gurjinder : CR#163 :End
            
            list<Account> accList = new list<Account>();
            accList = [SELECT Id,Is_Federal_Account_Sync__c FROM Account WHERE Domain__c = : dealReg.End_Customer_Domain__c  Order By CreatedDate DESC LIMIT 1];
            if(!accList.isEmpty()){
                lc.setAccountId(accList[0].Id);
            }
            //lc.setOpportunityName('');
            
            //System.debug('333(B1B) ==>> lc is: '+lc);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            //System.debug('333(B2B) ==>> lcr is: '+lcr);
            
            //Modified by Abhishek  : CR# 39 : Partner Margin : Start
            Opportunity op = [SELECT id,closeDate FROM Opportunity WHERE Id =:lcr.getOpportunityId()];
            Opportunity opp = new Opportunity(Id =lcr.getOpportunityId(), StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Amount = dealReg.Estimated_Amount__c, Type = 'New Business');
            /*if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming && dealReg.Partner_Type__c == Label.Partner_Type_Tech_Partner){
                opp.Deal_Reg_Partner_Teaming_Tech_Partner__c = dealReg.Partner_Account__c;
                opp.Deal_Reg_Teaming_Tech_Partner__c = dealReg.Id;
            }else */
            if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming && dealReg.Partner_Type__c != Label.Partner_Type_Tech_Partner){
                opp.Deal_Reg_Partner_Teaming_Reseller__c = dealReg.Partner_Account__c;
                opp.Deal_Reg_Teaming_Reseller__c = dealReg.Id;
            }else if(dealReg.Deal_Reg_Type__c != Label.Deal_Reg_Type_Teaming){
                opp.Deal_Reg_Margin__c = dealReg.Partner_Account__c;
                opp.Deal_Reg__c = dealReg.Id;
            }
            
            String partnerIncent = '';  
            String defaultFederal = ''; 
            String federalIncent = '';  
            Boolean isIncentive = false;    
            for(Partner_Incentive__c incent : [SELECT id,Account__c,Active__c,Partner_Program__c,Partner_Role__c,Partner_Tier__c,Effective_End_Date__c,Effective_Start_Date__c,Default__c FROM Partner_Incentive__c WHERE Account__c =:dealReg.Partner_Account__c AND Active__c = true]){   
                if(incent.Partner_Program__c == 'Summit - Federal' && accList[0].Is_Federal_Account_Sync__c == true){   
                    if(incent.Default__c == true){  
                        defaultFederal = incent.Partner_Program__c; 
                    }else if(op.CloseDate != null && incent.Effective_Start_Date__c <= op.CloseDate && incent.Effective_End_Date__c >= op.CloseDate){   
                        federalIncent = incent.Partner_Program__c;  
                    }   
                }else if(incent.Default__c == true){    
                    partnerIncent = incent.Partner_Program__c;  
                }   
                isIncentive = true; 
            }
            
            Map<String, Opportunity_Partner__c> existingOppPartners = mapOpptoOppPart.containskey(lcr.getOpportunityId()) ? mapOpptoOppPart.get(lcr.getOpportunityId()) : new Map<String, Opportunity_Partner__c>();
            if((existingOppPartners.isEmpty() || !existingOppPartners.containsKey('Reseller')) && isIncentive == true){ 
                opp.Primary_Partner_Program__c = String.isNotBlank(defaultFederal) ? defaultFederal :  String.isNotBlank(federalIncent) ? federalIncent : partnerIncent;    
            }
            
            //System.debug('333(C1C) ==>> opp is: '+opp);
            Database.SaveResult updateResult = Database.update(opp);
            //System.debug('333(C2C) ==>> updateResult is: '+updateResult);
            
            if(dealReg.Partner_Account__c != null){
            	createOpportunityPartner(dealReg.Partner_Account__c, lcr.getOpportunityId(), dealRegId);
            }
            
            createCosellActivity(lcr.getOpportunityId(), dealRegId);
            //Modified by Abhishek  : CR# 39 : Partner Margin : End

            updateDealStatustoConverted(dealRegId);

            convertedOppId = lcr.getOpportunityId();
            pageRef = new PageReference('/'+lcr.getOpportunityId());
        }catch(Exception ex){
            System.debug('In leadConversion(), Exception is: '+ex);
        }
        System.debug('1010(A) ==>>> DealRegConversionController.leadConversion() Ending, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        return pageRef;
    }
    
    public static void leadConversionWithAccAndOpp(Id leadId,Id accId, id selectedOppId){
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadId);
        //Modified by Abhishek  : CR# 432 : Start
        //lc.setOwnerId(dealReg.OwnerId);
        lc.setOwnerId(dealReg.Account_Manager__c);
        //Modified by Abhishek  : CR# 432 : Start
        
        //added by Gurjinder : CR#163 :Start
        
        String LeadConversionStatus= ZscalerCustomSetting__c.getInstance('LeadConversionStatus')!=null && ZscalerCustomSetting__c.getInstance('LeadConversionStatus').Value__c!=null ? ZscalerCustomSetting__c.getInstance('LeadConversionStatus').Value__c:'Actively Engaged';
        lc.ConvertedStatus = LeadConversionStatus;
        //added by Gurjinder : CR#163 :End
        lc.setAccountId(accId);
        lc.setDoNotCreateOpportunity(true);
        if(!Test.isRunningTest()){
            Database.LeadConvertResult lcr = Database.convertLead(lc);
        }

        updateDealStatustoConverted(dealRegId);
    }
    
    public static PageReference contactConversion(){
        System.debug('2020(A) ==>>> DealRegConversionController.contactConversion() Beginning, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        Opportunity opp = new Opportunity();
        opp = createOpportunity();
        insert opp;

        //Modified by Abhishek  : CR# 39 : Partner Margin : Start
        if(dealReg.Partner_Account__c != null){
            createOpportunityPartner(dealReg.Partner_Account__c, opp.Id, dealRegId);
        }
        createCosellActivity(opp.Id, dealRegId);
        //Modified by Abhishek  : CR# 39 : Partner Margin : End

        updateDealStatustoConverted(dealRegId);
        
        convertedOppId = opp.Id;
        PageReference pageRef = new PageReference('/'+opp.Id);
        System.debug('2020(A) ==>>> DealRegConversionController.contactConversion() Ending, SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        return pageRef;
    }
    
    //Ram S - Converted this regular method to future method to avoid 'too many soql: 101' error
    @future
    public static void updateDealStatustoConverted(String dealRegId){
        if(String.isNotBlank(dealRegId)){
            Deal_Reg__c deal = new Deal_Reg__c(Id = dealRegId, Status__c = 'Converted');
            //CR# 2572 - Chandan Panigrahy
            deal.Deal_Reg_Conversion_Date__c = System.Date.today();
            update deal;
            System.debug('updated deal: '+deal);
        }
    }
    
    //modified by Raghu as part of Primary Partner project
    //Modified by Abhishek  : CR# 39 : Partner Margin : End
    public static void createOpportunityPartner(id accId, id OppId, String dealRegId){
        if(String.isNotBlank(dealRegId)){
            List<Opportunity_Partner__c> oppPartnerlst = new List<Opportunity_Partner__c>();
            System.debug('### accId: '+accId);
            System.debug('### OppId: '+OppId);
            List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();
            System.debug('### dealReg.Record_Type_Name__c: '+dealReg.Record_Type_Name__c);
            
            //CR# 3952 - Updated Query to get Opportunity details
            //if(opp == null){ commenting to resolve CR#5226
                opp = [SELECT id, Account.Is_Federal_Account_Sync__c,  CloseDate,
                            Primary_Reseller_Partner__r.SummitDistribution__c,
                            Primary_Quote_Source__c 
                       	FROM Opportunity 
                       	WHERE id = :OppId];
            //}commenting to resolve CR#5226
            
            String partnerIncent = '';
            String partnerIncentProgram = '';
            String defaultFederal = '';
            String defaultFederalProgram = '';
            String federalIncent = '';
            String federalIncentProgram = '';
            Boolean isIncentive = false;
            String finalPartnerIncent = '';
            String finalPartnerIncentProgram = '';
            
            for(Partner_Incentive__c incent : [SELECT id,Account__c,Active__c,Partner_Program__c,Partner_Role__c,Partner_Tier__c,Effective_End_Date__c,Effective_Start_Date__c,Default__c FROM Partner_Incentive__c WHERE Account__c =:accId AND Active__c = true]){
                if(incent.Partner_Program__c == 'Summit - Federal' && opp.Account.Is_Federal_Account_Sync__c == true){  
                    if(incent.Default__c == true){  
                        defaultFederal = incent.Id; 
                        defaultFederalProgram = incent.Partner_Program__c;  
                    }else if(incent.Effective_Start_Date__c <= opp.CloseDate && incent.Effective_End_Date__c >= opp.CloseDate){ 
                        federalIncent = incent.Id;  
                        federalIncentProgram = incent.Partner_Program__c;   
                    }   
                }else if(incent.Default__c == true){    
                    partnerIncent = incent.Id;  
                    partnerIncentProgram = incent.Partner_Program__c;   
                }   
                isIncentive = true; 
            }   
            if(isIncentive == true){    
                finalPartnerIncent = String.isNotBlank(defaultFederal) ? defaultFederal : String.isNotBlank(federalIncent) ? federalIncent : partnerIncent; 
                finalPartnerIncentProgram = String.isNotBlank(defaultFederalProgram) ? defaultFederalProgram : String.isNotBlank(federalIncentProgram) ? federalIncentProgram : partnerIncentProgram;   
            }
            
            if(dealReg.Record_Type_Name__c != Label.Renewal_Deal_Reg){
                Opportunity_Partner__c nonDRpartner = getOppPartner(accId, OppId, 
                                                        dealReg.Partner_Category__c == 'Partner-Distributor' 
                                                            ? 'Distributor' 
                                                            : dealReg.Partner_Category__c == 'Partner-Integrator' 
                                                                ? 'System Integrator' 
                                                                : dealReg.Partner_Category__c == 'Technology Partner' 
                                                                    ? 'Tech Partner' 
                                                                    : 'Reseller',
                                                        finalPartnerIncent, finalPartnerIncentProgram);
                System.debug('### nonDRpartner: '+nonDRpartner);
                System.debug('### Opp Detail: '+opp);
                System.debug('### DR Detail: '+dealReg);
                
                if(nonDRpartner != null){
                    //CR# 3952 - Start
                    Id distributorId;
                    if(dealReg.Distributor__c != null && nonDRpartner.Partner_Type__c == 'Reseller'){
                        distributorId = dealReg.Distributor__c;
                    }else{
                        distributorId = accId;
                    }
                    nonDRpartner.Distributor__c = distributorId;
                    //CR# 3952 - End

                    oppPartnerlst.add(nonDRpartner);
                }
                System.debug('### oppPartnerlst: '+oppPartnerlst);
            }
            
            //CR#3744 Start
            if(dealReg.Delivery_Intent__c == 'Interested' && dealReg.Partner_Account__r.Service_Authorizations__c != Null){
                Opportunity_Partner__c PSpartner = getOppPartner(accId, OppId, 'Professional Services', finalPartnerIncent, finalPartnerIncentProgram);
                System.debug('### PSpartner: '+PSpartner);
                if(PSpartner != null){
                    oppPartnerlst.add(PSpartner);
                }
            }
            //CR#3744 End
    
            Opportunity_Partner__c DRpartner = getOppPartner(accId, OppId, 'Deal Reg', finalPartnerIncent, finalPartnerIncentProgram);
            if(DRpartner != null){
                oppPartnerlst.add(DRpartner);
            }
    
            //CR# 3952 - Start
            if(dealReg.Distributor__c != null && dealReg.Partner_Account__r.SummitDistribution__c){
                System.debug('Inside Distri###');
                Opportunity_Partner__c DistriPartner = getOppPartner(dealReg.Distributor__c, OppId, 'Distributor', finalPartnerIncent, finalPartnerIncentProgram);
                if(opp.Primary_Quote_Source__c != 'None'){
                    DistriPartner.Is_Primary__c = false;
                }
                if(DistriPartner != null){
                    oppPartnerlst.add(DistriPartner);
                }
                System.debug('### oppPartnerlst after Distri:'+oppPartnerlst);
            }
            //CR# 3952 - End
    
            insert oppPartnerlst;
            
            if(accId != null && OppId != null){ 
                for(SBQQ__Quote__c quote : [SELECT id,SBQQ__Account__c,Show_Banner__c,SBQQ__Opportunity2__c,SBQQ__Partner__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =:OppId AND SBQQ__Partner__c =: accId]){
                    quote.Show_Banner__c = true;    
                    quoteToUpdate.add(quote);   
                }   
                System.debug('quoteToUpdate'+quoteToUpdate);    
                if(!quoteToUpdate.isEmpty()){   
                    update quoteToUpdate;
                }   
            }
            
            List<Opportunity_Partner__c> existingDRlst = existingdealReg.containskey(oppId) ? existingdealReg.get(oppId) : new List<Opportunity_Partner__c>();
            System.debug('line 306....existingDRlst.isEmpty()'+existingDRlst.isEmpty());
            if(!existingDRlst.isEmpty()){
                for(Opportunity_Partner__c opart: existingDRlst){
                    opart.Is_Primary__c = false;
                }
            }
            Database.update(existingDRlst, false);
        }
    }

    public static Opportunity_Partner__c getOppPartner(id accId, id OppId, String parttype, String finalPartnerIncent, String finalPartnerIncentProgram){
        System.debug('### accId: '+accId);
        System.debug('### OppId: '+OppId);
        System.debug('### parttype: '+parttype);
        
        Boolean createPartner = true;
        Boolean createPrimaryPartner = true;
        Opportunity_Partner__c oppPartner;
        List<Opportunity_Partner__c> oppPartnerToUpdate = new List<Opportunity_Partner__c>();
        
        if(parttype != 'Deal Reg'){
            for(Opportunity_Partner__c opPartner : [SELECT id,Account__c,Deal_Registration__c,Is_Primary__c,Opportunity__c,Opportunity__r.SBQQ__PrimaryQuote__c,Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Partner__c,Opportunity__r.SBQQ__PrimaryQuote__r.Partner_Incentive__c,Partner_Incentive__c,Partner_Program__c,Partner_Type__c FROM Opportunity_Partner__c WHERE Opportunity__c =: OppId AND Partner_Type__c=:parttype]){
                System.debug('opPartner.Partner_Incentive__c'+opPartner.Partner_Incentive__c+'finalPartnerIncent'+finalPartnerIncent+'opPartner.Opportunity__r.SBQQ__PrimaryQuote__c'+opPartner.Opportunity__r.SBQQ__PrimaryQuote__c+'opPartner.Is_Primary__c'+opPartner.Is_Primary__c+'opPartner.Account__c'+opPartner.Account__c+'accId'+accId);
                if(opPartner.Opportunity__r.SBQQ__PrimaryQuote__c != null){
                    createPrimaryPartner = false;
                }
                if(String.isNotBlank(finalPartnerIncent) && opPartner.Partner_Incentive__c == finalPartnerIncent && opPartner.Opportunity__r.SBQQ__PrimaryQuote__c != null && opPartner.Account__c == accId){
                    createPartner = false;
                }else if(opPartner.Opportunity__r.SBQQ__PrimaryQuote__c != null && opPartner.Account__c == accId && parttype == 'Professional Services'){
                    createPartner = false;
                }else if(opPartner.Opportunity__r.SBQQ__PrimaryQuote__c == null && opPartner.Account__c == accId && parttype == 'Professional Services'){
                    if(opPartner.Is_Primary__c == false){
                        opPartner.Is_Primary__c = true;
                        oppPartnerToUpdate.add(opPartner);
                    }
                    createPartner = false;
                }else if(String.isNotBlank(finalPartnerIncent) && opPartner.Partner_Incentive__c == finalPartnerIncent && opPartner.Opportunity__r.SBQQ__PrimaryQuote__c == null && opPartner.Account__c == accId){
                    if(opPartner.Is_Primary__c == false){
                        opPartner.Is_Primary__c = true;
                        oppPartnerToUpdate.add(opPartner);
                    }
                    createPartner = false;
                }else if(String.isNotBlank(finalPartnerIncent) && opPartner.Partner_Incentive__c != finalPartnerIncent && opPartner.Opportunity__r.SBQQ__PrimaryQuote__c == null && opPartner.Is_Primary__c == true){
                    opPartner.Is_Primary__c = false;
                    oppPartnerToUpdate.add(opPartner);
                }
            }
        }
        System.debug('oppPartnerToUpdate'+oppPartnerToUpdate);
        if(!oppPartnerToUpdate.isEmpty()){
            update oppPartnerToUpdate;
        }
        if(parttype == 'Deal Reg' || createPartner == true || parttype == 'Distributor'){
            oppPartner = new Opportunity_Partner__c();
            oppPartner.Account__c = accId;
            oppPartner.Opportunity__c = oppId;
            oppPartner.Partner_Type__c = parttype;
            oppPartner.Partner_Program__c = finalPartnerIncentProgram;
            if(parttype != 'Deal Reg'){
                oppPartner.Partner_Incentive__c = String.isNotBlank(finalPartnerIncent) ? finalPartnerIncent : null;
                oppPartner.Is_Primary__c = createPrimaryPartner;
            }
            if(parttype == 'Deal Reg'){
                oppPartner.Deal_Registration__c = dealReg.Id;
                oppPartner.Is_Primary__c = true;
                //Added by Rakesh Nayini for IBA-4746
                oppPartner.Sales_Engineer_Name__c = dealReg.Sales_Engineer_Name__c;
                oppPartner.Sales_Engineer_Email__c = dealReg.Sales_Engineer_Email__c;
                oppPartner.Sales_Rep_Name__c = dealReg.Sales_Rep_Name__c;
                oppPartner.Sales_Rep_Email__c = dealReg.Sales_Rep_Email__c;
                // End IBA-4746
            }
            if(Test.isRunningTest()	|| parttype == 'Distributor'){
                oppPartner.Partner_Incentive__c = String.isNotBlank(finalPartnerIncent) ? finalPartnerIncent : null;
                oppPartner.Deal_Registration__c = dealReg.Id;
                oppPartner.Is_Primary__c = true;
            }
            System.debug('### parttype: '+parttype);
            System.debug('### oppPartner: '+oppPartner);
        }
        return oppPartner;
    }
    //Modified by Abhishek  : CR# 39 : Partner Margin : End
    //Modified by Abhishek  : Partner Portal : End

    public static void createCosellActivity(Id oppId, String dealRegId){
        if(String.isNotBlank(dealRegId)){
            List<Cosell_Activities__c> oppPartnerlst = new List<Cosell_Activities__c>();
            if(dealReg.AW_Partner_Intent__c == Label.Deal_Reg_Cosell_Interested){
                Cosell_Activities__c awpartner = getCosellActivity(oppId, 'Architecture Workshop');
                if(awpartner != null){
                    oppPartnerlst.add(awpartner);
                }
            }   
            if(dealReg.POV_Partner_Intent__c == Label.Deal_Reg_Cosell_Interested){
                Cosell_Activities__c povpartner = getCosellActivity(oppId, 'POV');
                if(povpartner != null){
                    oppPartnerlst.add(povpartner);
                }
            }   
        
            //CR# 2556 - Added by Ritesh - START
            if(dealReg.AW_POV_Partner_Intent__c == Label.Deal_Reg_Cosell_Interested){
                Cosell_Activities__c awpovpartner = getCosellActivity(oppId, 'AW/POV');
                if(awpovpartner != null){
                    oppPartnerlst.add(awpovpartner);
                }
            }
            //CR# 2556 - Added by Ritesh - END
            insert oppPartnerlst;
        }
    }
    
    public static Cosell_Activities__c getCosellActivity(id OppId, String type){
        if(dealReg.Partner_Account__c == null || OppId == null){
            return null;
        }

        String oppparttype = '' + OppId + dealReg.Partner_Account__c + type;
        if(String.isNotBlank(oppparttype) && cosellOppPartTypetoOppPartID != null && !cosellOppPartTypetoOppPartID.isEmpty() && cosellOppPartTypetoOppPartID.containsKey(oppparttype)){
            return null;
        }
        
        Cosell_Activities__c oppPartner = new Cosell_Activities__c();
        oppPartner.Activity__c = type;
        oppPartner.Deal_Reg__c = dealReg.Id;
        oppPartner.OwnerId = dealReg.OwnerId;
        oppPartner.Opportunity__c = OppId;
        oppPartner.Partner__c = dealReg.Partner_Account__c;
        if(dealReg.Partner_Contact__c != null){
            oppPartner.Partner_Contact__c = dealReg.Partner_Contact__c;
        }else if(dealReg.Partner_Contact_Email__c != null){
            List<contact> conlst = [SELECT Id FROM contact WHERE email = :dealReg.Partner_Contact_Email__c AND AccountId = :dealReg.Partner_Account__c AND OKTA_User_ID__c != null];
            if(!conlst.isEmpty()){
                oppPartner.Partner_Contact__c = conlst[0].Id;
            }
        }
        oppPartner.Partner_Contact_Email__c = dealReg.Partner_Contact_Email__c;
        //CR#4932 - start
        if(dealReg.Partner_Type__c!='Technology Partner'){
        	Integer countofAWPOVcompleted = 0;
        	Set<String> statustoQuery = new Set<String>();
        	statustoQuery.add(Label.Cosell_Invited);
        	statustoQuery.add(Label.Cosell_Completed);
        	List<Cosell_Activities__c> cosellListToUpdate = new List<Cosell_Activities__c>();
        	for(Cosell_Activities__c cosellrecord : [SELECT Id,Status__c FROM Cosell_Activities__c WHERE Opportunity__c = :OppId AND Status__c IN :statustoQuery AND Activity__c = 'AW/POV']){
            	if(cosellrecord.Status__c == Label.Cosell_Completed ){
                	countofAWPOVcompleted = countofAWPOVcompleted + 1;
            	}
            	if(cosellrecord.Status__c == Label.Cosell_Invited){
                	cosellrecord.Status__c= Label.Cosell_Withdrawn;
                	cosellListToUpdate.add(cosellrecord);
            	}
        	}
        	if(countofAWPOVcompleted > 0){
        		oppPartner.Status__c = Label.Cosell_Interested;
        	}
        	else{
        		oppPartner.Status__c = Label.Cosell_Invited;
        	}
        	if(!cosellListToUpdate.IsEmpty()){
            	update cosellListToUpdate;
        	}
        }else{
            oppPartner.Status__c = Label.Cosell_Interested;
        }
        //CR#4932 - End
		
        return oppPartner;
    }
    //Modified by Abhishek  : Partner Portal : End

    public static Opportunity createOpportunity(){
        return createOpportunity(null, false);
    }
    
    public static Opportunity createOpportunity(Id customerAccountId, Boolean isFederalAccountSync){
        Opportunity opp = new Opportunity();
        opp.Name = dealReg.End_Customer_Name__c+'Deal Reg';
        opp.AccountId = (null != customerAccountId) ? customerAccountId : dealReg.Contact__r.AccountId;
        if(dealReg.Account_Manager__c != null){//Updated by Minkesh for CR# 422
            opp.OwnerId = dealReg.Account_Manager__c;//Updated by Minkesh for CR# 422
        }
        opp.StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        opp.CloseDate = dealReg.Expected_Close_Date__c;
        if(dealReg.Account_Type__c != null && dealReg.Account_Type__c == 'Customer'){  // Added for CR# 3109
            opp.Type = 'Existing Customer (Add On)';
        }else{
            opp.Type = 'New Business';
        }
        opp.Source__c = 'Partners';

        //Added for 3334
        if(dealReg.Partner_Type__c == 'Partner'){
              opp.Deal_Reg_Target_Customer_Name__c = dealReg.Target_Customer__r.Name;
        }else{
            opp.Deal_Reg_Target_Customer_Name__c = '';
        }

        //Modified by Abhishek  : CR# 631 : Partner Margin : Start
        /*if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming && dealReg.Partner_Type__c == Label.Partner_Type_Tech_Partner){
            opp.Deal_Reg_Partner_Teaming_Tech_Partner__c = dealReg.Partner_Account__c;
            opp.Deal_Reg_Teaming_Tech_Partner__c = dealReg.Id;
        }else */
		if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming && dealReg.Partner_Type__c != Label.Partner_Type_Tech_Partner){
            opp.Deal_Reg_Partner_Teaming_Reseller__c = dealReg.Partner_Account__c;
            opp.Deal_Reg_Teaming_Reseller__c = dealReg.Id;
        }else if(dealReg.Deal_Reg_Type__c != Label.Deal_Reg_Type_Teaming){
            opp.Deal_Reg_Margin__c = dealReg.Partner_Account__c;
            opp.Deal_Reg__c = dealReg.Id;
        }

        //Modified by Abhishek  : CR# 631 : Partner Margin : End
        if(customerAccountId == null && opp.AccountId != null){
            Account acc = [SELECT id,Is_Federal_Account_Sync__c FROM Account WHERE id = :opp.AccountId];
            isFederalAccountSync = acc.Is_Federal_Account_Sync__c;
        }
        //Modified by Abhishek  : CR# 39 : Partner Margin : Start

        String partnerIncent = '';
        String defaultFederal = '';
        String federalIncent = '';
        Boolean isIncentive = false;
        for(Partner_Incentive__c incent : [SELECT id,Account__c,Active__c,Partner_Program__c,Partner_Role__c,Partner_Tier__c,Effective_End_Date__c,Effective_Start_Date__c,Default__c FROM Partner_Incentive__c WHERE Account__c =:dealReg.Partner_Account__c AND Active__c = true]){
            if(incent.Partner_Program__c == 'Summit - Federal' && isFederalAccountSync == true){
                if(incent.Default__c == true){
                    defaultFederal = incent.Partner_Program__c;
                }else if(opp.CloseDate != null && incent.Effective_Start_Date__c <= opp.CloseDate && incent.Effective_End_Date__c >= opp.CloseDate){
                    federalIncent = incent.Partner_Program__c;
                }
            }else if(incent.Default__c == true){
                partnerIncent = incent.Partner_Program__c;
            }
            isIncentive = true;
        }
        if(isIncentive == true){
            opp.Primary_Partner_Program__c = String.isNotBlank(defaultFederal) ? defaultFederal : String.isNotBlank(federalIncent) ? federalIncent : partnerIncent;
        }
        //Modified by Abhishek  : CR# 39 : Partner Margin : End

        opp.Amount = dealReg.Estimated_Amount__c;
        opp.LeadSource = 'Deal Registration';

        //CR# 3407 START : Bikram 22nd Oct
        opp.ImpartnerPRM__PartnerContact__c = dealReg.Partner_Contact__c;
        //CR# 3407 END : Bikram 22nd Oct

        return opp;
    }
    
    public static void markNonPrimaryResellerPartner(){
        if(dealRegId != null){
            List<Opportunity_Partner__c> existingResellerPartners = [SELECT Id, Name, Is_Primary__c FROM Opportunity_Partner__c WHERE Opportunity__c = :selectedOppId AND Account__c != :dealReg.Partner_Account__c AND (Partner_Type__c = 'Reseller' OR Partner_Type__c = 'Deal Reg')];
            if(!existingResellerPartners.isEmpty()){
                for(Opportunity_Partner__c partner : existingResellerPartners){
                    partner.Is_Primary__c = false;
                }
                update existingResellerPartners;
            }
        }
    }
    
    public static PageReference associateDealToOpp(String selOppId, String drId){
        PageReference pageRef;
        selectedOppId = selOppId;
        initializeVariables(drId);
        System.debug('# selectedOppId'+selectedOppId);
        
        if(selectedOppId != '' && selectedOppId != null){
            System.debug('# selectedOppId'+selectedOppId);
            list<Opportunity> oppList = new List<Opportunity>();
            
            //Modified by Abhishek  : CR# 39 : Partner Margin : Start
            opp = new Opportunity(Id = selectedOppId);
            
            //Modified by Abhishek  : CR# 631 : Partner Margin : Start
            /*if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming && dealReg.Partner_Type__c == Label.Partner_Type_Tech_Partner){
                opp.Deal_Reg_Partner_Teaming_Tech_Partner__c = dealReg.Partner_Account__c;
                opp.Deal_Reg_Teaming_Tech_Partner__c = dealReg.Id;
            }else*/
			if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming && dealReg.Partner_Type__c != Label.Partner_Type_Tech_Partner){
                opp.Deal_Reg_Partner_Teaming_Reseller__c = dealReg.Partner_Account__c;
                opp.Deal_Reg_Teaming_Reseller__c = dealReg.Id;
            }
            //CR# 1499 start
            /*else if(Test.isRunningTest() || dealReg.Deal_Reg_Type__c == 'Renewal'){
                opp.Renewal_Deal_Reg_Partner__c = dealReg.Partner_Account__c;
                opp.Renewal_Deal_Registration__c = dealReg.Id;
            }*/
            //edn CR# 1499
            else if(dealReg.Deal_Reg_Type__c != Label.Deal_Reg_Type_Teaming){
                opp.Deal_Reg_Margin__c = dealReg.Partner_Account__c;
                opp.Deal_Reg__c = dealReg.Id;
            }
            
            //Added for CR#3334
            if(dealReg.Partner_Type__c == 'Partner'){
                opp.Deal_Reg_Target_Customer_Name__c = dealReg.Target_Customer__r.Name;
            }else{
                opp.Deal_Reg_Target_Customer_Name__c = '';
            }
            //Modified by Abhishek  : CR# 631 : Partner Margin : End
            //
            System.debug('### mapOpptoOppPart.containskey(selectedOppId): '+mapOpptoOppPart.containskey(selectedOppId));
            Map<String, Opportunity_Partner__c> existingOppPartners = mapOpptoOppPart.containskey(selectedOppId) ? mapOpptoOppPart.get(selectedOppId) : new Map<String, Opportunity_Partner__c>();
            System.debug('### existingOppPartners: '+existingOppPartners);
            if(existingOppPartners.isEmpty() || !existingOppPartners.containsKey('Reseller')){
                String partnerIncent = '';
                String defaultFederal = '';
                String federalIncent = '';
                Boolean isIncentive = false;
            	Opportunity op = [SELECT id,closeDate,Account.Is_Federal_Account_Sync__c FROM Opportunity WHERE id=:selectedOppId];
                for(Partner_Incentive__c incent : [SELECT id,Account__c,Active__c,Partner_Program__c,Partner_Role__c,Partner_Tier__c,Effective_End_Date__c,Effective_Start_Date__c,Default__c FROM Partner_Incentive__c WHERE Account__c =:dealReg.Partner_Account__c AND Active__c = true]){
                    if(incent.Partner_Program__c == 'Summit - Federal' && op.Account.Is_Federal_Account_Sync__c == true){
                        if(incent.Default__c == true){
                            defaultFederal = incent.Partner_Program__c;
                        }else if(op.CloseDate != null && incent.Effective_Start_Date__c <= op.CloseDate && incent.Effective_End_Date__c >= op.CloseDate){
                            federalIncent = incent.Partner_Program__c;
                        }
                    }else if(incent.Default__c == true){
                        partnerIncent = incent.Partner_Program__c;
                    }
                    isIncentive = true;
                }
                if(isIncentive == true){
                    opp.Primary_Partner_Program__c = String.isNotBlank(defaultFederal) ? defaultFederal : String.isNotBlank(federalIncent) ? federalIncent : partnerIncent;
                }
            }
            update opp;
            
            if(dealReg.Partner_Account__c != null){
                createOpportunityPartner(dealReg.Partner_Account__c, selectedOppId, dealRegId);
            }
            //Modified by Abhishek  : CR# 39 : Partner Margin : End
			
            createCosellActivity(selectedOppId, dealRegId);
            
            updateDealStatustoConverted(dealRegId);
            
            if(dealReg.Lead__c != null){
                leadConversionWithAccAndOpp(dealReg.Lead__c, oppIdAccountIdMap.get(selectedOppId), selectedOppId);
            }
            convertedOppId = selectedOppId; 
            
            if(dealReg.Record_Type_Name__c == 'Renewal Deal Reg'){
                markNonPrimaryResellerPartner();
            }
            pageRef = new PageReference('/'+selectedOppId);
        }else{
            //New Opportunity Logic
            if(dealReg.Lead__c != null){
                pageRef = leadConversion(dealReg.Lead__c);
            }else if(dealReg.Contact__c != null){
                pageRef = contactConversion();
            } else if (null == dealReg.Lead__c
                && null == dealReg.Contact__c) {
                pageRef = opportunityConversion();
            }
        }       
        return pageRef;    
    }
    
    public class OpportunityListWrapper{
        @AuraEnabled
        public boolean isSelected {get;set;}
        @AuraEnabled
        public id oppId {get;set;}
        @AuraEnabled
        public String oppName {get;set;}
        @AuraEnabled
        public string accName {get; set;}
        @AuraEnabled
        public decimal amount {get; set;}
        @AuraEnabled
        public string stageName {get; set;}
        @AuraEnabled
        public date closeDate {get; set;}
        @AuraEnabled
        public string type {get; set;}
        @AuraEnabled
        public string dealRegName {get; set;}
        @AuraEnabled
        public string dealRegId {get; set;}
        @AuraEnabled
        public string dealRegType {get; set;}
        @AuraEnabled
        public string dealRegStatus {get; set;}
        @AuraEnabled
        public string dealRegPartnerType {get; set;}
        @AuraEnabled
        public string dealRegPartnerId {get; set;}
        @AuraEnabled
        public string dealRegPartnerName {get; set;}
        @AuraEnabled
        public string teamingResellerdealRegName {get; set;}
        @AuraEnabled
        public string teamingResellerdealRegId {get; set;}
        @AuraEnabled
        public string teamingResellerdealRegType {get; set;}
        @AuraEnabled
        public string teamingResellerdealRegStatus {get; set;}
        @AuraEnabled
        public string teamingResellerdealRegPartnerType {get; set;}
        @AuraEnabled
        public string teamingResellerdealRegPartnerId {get; set;}
        @AuraEnabled
        public string teamingResellerdealRegPartnerName {get; set;}
        @AuraEnabled
        public string teamingTechPartnerdealRegName {get; set;}
        @AuraEnabled
        public string teamingTechPartnerdealRegId {get; set;}
        @AuraEnabled
        public string teamingTechPartnerdealRegType {get; set;}
        @AuraEnabled
        public string teamingTechPartnerdealRegStatus {get; set;}
        @AuraEnabled
        public string teamingTechPartnerdealRegPartnerType {get; set;}
        @AuraEnabled
        public string teamingTechPartnerdealRegPartnerId {get; set;}
        @AuraEnabled
        public string teamingTechPartnerdealRegPartnerName {get; set;}
        @AuraEnabled
        public Opportunity opp {get;set;}
        @AuraEnabled
        public string oppUrl {get; set;}
        @AuraEnabled
        public string sourcedDealRegUrl {get; set;}
        @AuraEnabled
        public string teamingResellerdealRegUrl {get; set;}
        @AuraEnabled
        public string teamingTechPartnerdealRegUrl {get; set;}
        @AuraEnabled
        public string srcexpirationLink {get; set;}
        @AuraEnabled
        public string teamingResellerexpirationLink {get; set;}
        @AuraEnabled
        public string teamingTechPartnerexpirationLink {get; set;}
        @AuraEnabled
        public string renewaldealRegName {get; set;}
        //@AuraEnabled
        //public string renewaldealRegId {get; set;}
        @AuraEnabled
        public string renewaldealRegType {get; set;}
        @AuraEnabled
        public string renewaldealRegStatus {get; set;}
        @AuraEnabled
        public string renewaldealRegPartnerType {get; set;}
        @AuraEnabled
        public string renewaldealRegPartnerId {get; set;}
        @AuraEnabled
        public string renewaldealRegPartnerName {get; set;}
        //@AuraEnabled
        //public string renewaldealRegUrl {get; set;}
        @AuraEnabled
        public string oppRecordType {get; set;}

        public OpportunityListWrapper(boolean s,Opportunity o,Opportunity_Partner__c oppRecord){
            this.isSelected = s;
            this.opp = o;
            this.oppName = o.Name;
            this.oppId = o.Id;
            this.accName = o.Account.Name;
            this.amount = o.Amount != null ? o.Amount : 0;
            this.StageName = o.StageName;
            this.closeDate = o.CloseDate;
            this.dealRegId = o.Deal_Reg__c;
            this.dealRegName = o.Deal_Reg__r.Name;
            this.dealRegStatus = o.Deal_Reg__r.Status__c;
            this.dealRegPartnerId = o.Deal_Reg__r.Partner_Account__c;
            this.dealRegPartnerName = o.Deal_Reg__r.Partner_Account__r.Name;
            this.dealRegPartnerType = o.Deal_Reg__c == null ? null : o.Deal_Reg__r.Partner_Type__c == Label.Partner_Type_Tech_Partner ? o.Deal_Reg__r.Partner_Type__c : Label.Partner_Type_Reseller;
            this.dealRegType = o.Deal_Reg__c == null ? null : o.Deal_Reg__r.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming ? Label.Deal_Reg_Type_Teaming : Label.Deal_Reg_Type_Sourced;
            if(oppRecord==Null){
            	this.teamingResellerdealRegId = o.Deal_Reg_Teaming_Reseller__c;
            	this.teamingResellerdealRegName = o.Deal_Reg_Teaming_Reseller__r.Name;
            	this.teamingResellerdealRegStatus = o.Deal_Reg_Teaming_Reseller__r.Status__c;
            	this.teamingResellerdealRegPartnerId = o.Deal_Reg_Teaming_Reseller__r.Partner_Account__c;
            	this.teamingResellerdealRegPartnerName = o.Deal_Reg_Teaming_Reseller__r.Partner_Account__r.Name;
            	this.teamingResellerdealRegPartnerType = o.Deal_Reg_Teaming_Reseller__c == null ? null : o.Deal_Reg_Teaming_Reseller__r.Partner_Type__c == Label.Partner_Type_Tech_Partner ? o.Deal_Reg_Teaming_Reseller__r.Partner_Type__c : Label.Partner_Type_Reseller;
            	this.teamingResellerdealRegType = o.Deal_Reg_Teaming_Reseller__c == null ? null : o.Deal_Reg_Teaming_Reseller__r.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming ? Label.Deal_Reg_Type_Teaming : Label.Deal_Reg_Type_Sourced;
            }//IBA-7556 - Start
            else if(oppRecord!=Null){
                this.teamingTechPartnerdealRegId = oppRecord.Deal_Registration__c;
            	this.teamingTechPartnerdealRegName = oppRecord.Deal_Registration__r.Name;
            	this.teamingTechPartnerdealRegStatus = oppRecord.Deal_Reg_Status__c;
            	this.teamingTechPartnerdealRegPartnerId = oppRecord.Account__c;
            	this.teamingTechPartnerdealRegPartnerName = oppRecord.Account__r.Name;
            	this.teamingTechPartnerdealRegPartnerType = oppRecord.Deal_Reg_Partner_Type__c == Label.Partner_Type_Tech_Partner ? oppRecord.Deal_Reg_Partner_Type__c : Label.Partner_Type_Reseller;
            	this.teamingTechPartnerdealRegType = oppRecord.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming ? Label.Deal_Reg_Type_Teaming : Label.Deal_Reg_Type_Sourced;
            }
            //IBA-7556 - End
            this.oppUrl = '/' + this.oppId;
            this.sourcedDealRegUrl = '/' + this.dealRegId;
            this.teamingResellerdealRegUrl = '/' + this.teamingResellerdealRegId;
            this.teamingTechPartnerdealRegUrl = '/' + this.teamingTechPartnerdealRegId;
            this.srcexpirationLink = '/apex/DealRegExpirationPage?id=' + this.dealRegId;
            this.teamingResellerexpirationLink = '/apex/DealRegExpirationPage?id=' + this.teamingResellerdealRegId;
            this.teamingTechPartnerexpirationLink = '/apex/DealRegExpirationPage?id=' + this.teamingTechPartnerdealRegId;
            this.Type = o.Type;
            //this.renewaldealRegName = o.Renewal_Deal_Registration__r.Name;
            //this.renewaldealRegStatus = o.Renewal_Deal_Registration__r.Status__c;
            //this.renewaldealRegId = o.Renewal_Deal_Registration__c;
            //this.renewaldealRegPartnerId = o.Renewal_Deal_Registration__r.Partner_Account__c;
            //this.renewaldealRegPartnerName = o.Renewal_Deal_Registration__r.Partner_Account__r.Name;
            //this.renewaldealRegPartnerType = o.Renewal_Deal_Registration__r.Partner_Type__c;
            //this.renewaldealRegType = o.Renewal_Deal_Registration__r.Deal_Reg_Type__c;
            //this.renewaldealRegUrl = '/' + this.renewaldealRegId;
            this.oppRecordType = o.RecordType.Name;
        }
        
        public OpportunityListWrapper(boolean s,string newOppName){
            this.isSelected = s;
            this.oppName = newOppName;
            this.oppId = null;
        }
    }
}