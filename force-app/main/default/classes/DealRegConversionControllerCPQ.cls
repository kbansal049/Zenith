// Commenting Deal_Reg_Teaming_Tech_Partner__c,Deal_Reg_Partner_Teaming_Tech_Partner__c as part of IBA-7556
public class DealRegConversionControllerCPQ {

    public string dealRegId {get;set;}
    public static string dealRegIdfromLWC {get;set;}
    public string convertedOppId {get;set;}
    public Deal_Reg__c dealReg {get;set;}
    public string selectedOppId {get;set;}
    public string reasonforExp {get;set;}
    //public string partnerId ;
    map<id, id> oppIdAccountIdMap = new map<id, id>();
    public list<OpportunityListWrapper> oppWrapperList {get; set;}
    list<Opportunity> oppList = new list<Opportunity>();
    Map<Id, Map<String, Opportunity_Partner__c>> mapOpptoOppPart = new Map<Id, Map<String, Opportunity_Partner__c>>();
    Map<String, Id> oppPartTypetoOppPartID = new Map<String, Id>();
    Map<String, Id> CosellOppPartTypetoOppPartID = new Map<String, Id>();
    Map<Id, List<Opportunity_Partner__c>> existingdealReg = new Map<Id, List<Opportunity_Partner__c>>();
    
    public DealRegConversionControllerCPQ (){
        //dealRegId = '';
        //partnerId= '';
        dealReg = new Deal_Reg__c();
        selectedOppId = '';
        oppList = new list<Opportunity>();
        oppWrapperList = new  list<OpportunityListWrapper>();
        System.debug('dealRegIdfromLWC....'+dealRegIdfromLWC);
        if(dealRegIdfromLWC != null){
            dealRegId = dealRegIdfromLWC;
        }else{
            dealRegId = ApexPages.currentPage().getParameters().get('Id');
        }
        //Modified by Abhishek  : CR# 39 : Partner Margin : Start
        system.debug('### line no 30. dealRegId :'+dealRegId);
        if(dealRegId != null && dealRegId != ''){
            dealReg = [Select Id, Name, Partner_Type__c, Deal_Reg_Type__c, NBM_Meeting_Date__c, Discovery_Meeting_Date__c, Deal_Reg_Expiration_Date__c, Partner_Contact__c, Partner_Contact_Email__c,Account_Manager__c, AW_Partner_Intent__c, POV_Partner_Intent__c, Partner_Account_Program__c, Partner_Program__c, Partner_Category__c, End_Customer_Name__c , Partner_Account__c, Estimated_Amount__c,Expected_Close_Date__c,
                        Partner_Company_Name__c , Lead__c, Contact__c, Contact__r.AccountId, OwnerId, End_Customer_Domain__c, End_Customer_Street_Address__c, End_Customer_City__c, End_Customer_State__c, End_Customer_Country__c, End_Customer_Postal_Code__c, Record_Type_Name__c from Deal_Reg__c where ID =: dealRegId];
            Set<String> stagetoExclude = new Set<String>{Label.Stage_5_Contracts_Complete, Label.Stage_5A_Opportunity, Label.Stage_5B_Opportunity, Label.Stage_5C_Opportunity};
            Set<String> typetoExclude = new Set<String>{Label.Opportunity_Type_New_Business, Label.Opportunity_Type_Upsell};
            string domain = dealReg.End_Customer_Domain__c;
            
            String query = 'Select Id, Name, AccountId, Account.Name, OwnerId, Owner.Name, StageName, CloseDate, Amount, Type, Deal_Reg__c, Deal_Reg_Teaming_Reseller__c, '
                    + ' Deal_Reg__r.Name, Deal_Reg__r.Partner_Account__c, Deal_Reg__r.Partner_Account__r.Name, '
                    + ' Deal_Reg__r.Partner_Type__c, Deal_Reg__r.Deal_Reg_Type__c, Deal_Reg__r.Status__c, '
                    + ' Deal_Reg_Teaming_Reseller__r.Name, Deal_Reg_Teaming_Reseller__r.Partner_Account__c, Deal_Reg_Teaming_Reseller__r.Partner_Account__r.Name, '
                    + ' Deal_Reg_Teaming_Reseller__r.Partner_Type__c, Deal_Reg_Teaming_Reseller__r.Deal_Reg_Type__c, Deal_Reg_Teaming_Reseller__r.Status__c, '
                    //+ ' Renewal_Deal_Registration__r.Name, Renewal_Deal_Registration__r.Partner_Account__c, Renewal_Deal_Registration__r.Partner_Account__r.Name, '
                    //+ ' Renewal_Deal_Registration__r.Partner_Type__c, Renewal_Deal_Registration__r.Deal_Reg_Type__c, Renewal_Deal_Registration__r.Status__c, '
                    + ' (Select id, AccountTo.Name from OpportunityPartnersFrom where IsPrimary = true limit 1), '
                    + ' (Select Id, Opportunity__c, Account__c, Is_Primary__c, Partner_Type__c from Opportunity_Partners__r where Partner_Type__c in (\'Reseller\', \'Tech Partner\', \'System Integrator\', \'Distributor\', \'Deal Reg\')), '
                    + ' (Select Id, Activity__c, Age_in_Current_Status__c, Deal_Reg__c, Opportunity__c, Partner__c, Partner_Contact__c, Status__c from Opportunity_Cosell_Partners__r) '
                    + ' from Opportunity Where Account.Domain__c = :domain AND isClosed = false and StageName not in :stagetoExclude';
            //CR# 1499 start
            /*if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming){
                query += ' and Type in :typetoExclude';
            }*/
            //end of CR# 1499
            
            List<Opportunity> oppQuerylist= Database.query(query);

            for(Opportunity opp : oppQuerylist){
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
                }
                if(!existingDRs.isEmpty()){
                    existingdealReg.put(opp.Id, existingDRs);
                }
                system.debug('### mapOppPartners :'+mapOppPartners);
                if(!mapOppPartners.isEmpty()){
                    mapOpptoOppPart.put(opp.Id, mapOppPartners);
                }
                for(Cosell_Activities__c op: opp.Opportunity_Cosell_Partners__r){
                    if(op.Opportunity__c != null && op.Activity__c != null && op.Partner__c != null){
                        CosellOppPartTypetoOppPartID.put('' + op.Opportunity__c + op.Partner__c + op.Activity__c, op.Id);
                    }
                }
            }
        }
        system.debug('### mapOpptoOppPart :'+mapOpptoOppPart);   
        //Modified by Abhishek  : CR# 39 : Partner Margin : End
    }
    
    public PageReference convertDealReg() {
        PageReference pageRef;
        if(dealReg != null){
            if(!oppList.isEmpty()){
                if(dealReg.Deal_Reg_Type__c != Label.Deal_Reg_Type_Teaming){
                    oppWrapperList.add(new OpportunityListWrapper(true, 'Create a New Opportunity'));
                }
                for(Opportunity opp : oppList){
                    oppIdAccountIdMap.put(opp.Id, opp.AccountId);
                    oppWrapperList.add(new OpportunityListWrapper(false, opp));
                }
            }else if(dealReg.Deal_Reg_Type__c != Label.Deal_Reg_Type_Teaming){
                system.debug('in else condition');
                if(dealReg.Lead__c != null){
                    system.debug('in lead conversion method');
                    pageRef = leadConversion(dealReg.Lead__c);
                }else if(dealReg.Contact__c != null){
                    system.debug('in contact conversion method');
                   pageRef =  contactConversion();
                } else if (null == dealReg.Lead__c
                    && null == dealReg.Contact__c) {
                        system.debug('in opportunity conversion method');
                    pageRef = opportunityConversion();
                }
            }
            return pageRef;
        }else{
            return null;
        }
        
    }

    public PageReference opportunityConversion() {
        //1. If no contact or lead is found, create a new account and an opportunity with all existing mappings per contactConversion() method
        //2. If an account matches with the same domain, do not create a new one
        //   Also, if an opportunity matches with deal reg, let the user tag the existing one or create a new one - This is handled in the constructor and action method
        Opportunity newOpportunity;

        Id customerAccountId;
        List<Account> accList=[SELECT Id FROM Account WHERE Domain__c = :dealReg.End_Customer_Domain__c ORDER BY CreatedDate DESC LIMIT 1];
        for (Account account : accList) {
            customerAccountId = account.Id;
        }

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
            System.debug('newAccount '+newAccount);
            insert newAccount;

            customerAccountId = newAccount.Id;
        }
        newOpportunity = createOpportunity(customerAccountId);
        TriggerUtility.OppBeforeInsertExecuted();
        TriggerUtility.OppAfterInsertExecuted();
        TriggerUtility.OppBeforeUpdateExecuted();
        TriggerUtility.OppAfterUpdateExecuted();
        insert newOpportunity;
        //Modified by Abhishek  : CR# 39 : Partner Margin : Start
        if (null != dealReg.Partner_Account__c) {
            createOpportunityPartner(dealReg.Partner_Account__c, newOpportunity.Id);
        }
        //Modified by Abhishek  : CR# 39 : Partner Margin : End
        //Modified by Abhishek  : Partner Portal : Start
        if (null != dealReg.Partner_Account__c) {
            createCosellActivity(newOpportunity.Id);
        }
        //Modified by Abhishek  : Partner Portal : End
        updateDealStatustoConverted();

        PageReference opportunityDetailPage = new PageReference('/' + newOpportunity.Id);
        convertedOppId = newOpportunity.Id;
        return opportunityDetailPage;
    }
    
    public PageReference leadConversion(Id leadId){
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
        accList = [select Id,Is_Federal_Account_Sync__c from Account where Domain__c = : dealReg.End_Customer_Domain__c  Order By CreatedDate DESC Limit 1];
        if(!accList.isEmpty())
            lc.setAccountId(accList[0].Id);
        
        //lc.setOpportunityName('');
        Database.LeadConvertResult lcr = Database.convertLead(lc); 
        //Modified by Abhishek  : CR# 39 : Partner Margin : Start
        Opportunity op = [Select id,closeDate from Opportunity where Id =:lcr.getOpportunityId()];
        Opportunity opp = new Opportunity(Id =lcr.getOpportunityId(), StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Amount = dealReg.Estimated_Amount__c, Type = 'New Business');
        /*if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming && dealReg.Partner_Type__c == Label.Partner_Type_Tech_Partner){
            opp.Deal_Reg_Partner_Teaming_Tech_Partner__c = dealReg.Partner_Account__c;
            opp.Deal_Reg_Teaming_Tech_Partner__c = dealReg.Id;
        }else */
        if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming){
            opp.Deal_Reg_Partner_Teaming_Reseller__c = dealReg.Partner_Account__c;
            opp.Deal_Reg_Teaming_Reseller__c = dealReg.Id;
        }else{
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
        update opp;
        if(dealReg.Partner_Account__c != null)
        createOpportunityPartner(dealReg.Partner_Account__c, lcr.getOpportunityId());
        createCosellActivity(lcr.getOpportunityId());
        //Modified by Abhishek  : CR# 39 : Partner Margin : End
        updateDealStatustoConverted();
        convertedOppId = lcr.getOpportunityId();
        PageReference pageRef = new PageReference('/'+lcr.getOpportunityId());
        return pageRef;
    }
    
    public void leadConversionWithAccAndOpp(Id leadId,Id accId, id selectedOppId){
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
        if(!Test.isRunningTest())
            Database.LeadConvertResult lcr = Database.convertLead(lc); 
        updateDealStatustoConverted();
    }
    
    
    public PageReference contactConversion(){
        Opportunity opp = new Opportunity();
        opp = createOpportunity();
        system.debug('--opp--'+opp);
        insert opp; 
        //Modified by Abhishek  : CR# 39 : Partner Margin : End
        if(dealReg.Partner_Account__c != null)
        createOpportunityPartner(dealReg.Partner_Account__c, opp.Id);
        createCosellActivity(opp.Id);
        //Modified by Abhishek  : CR# 39 : Partner Margin : End
        updateDealStatustoConverted();
        convertedOppId = opp.Id;
        PageReference pageRef = new PageReference('/'+opp.Id);
        return pageRef;
    }
    
    public void updateDealStatustoConverted(){
        Deal_Reg__c deal = new Deal_Reg__c(Id= dealReg.Id, Status__c = 'Converted');
        
         /**
         * CR# 2572 - Chandan Panigrahy
         */
         deal.Deal_Reg_Conversion_Date__c = System.Date.today();
        
        
        if(dealReg.NBM_Meeting_Date__c == null && dealReg.Discovery_Meeting_Date__c != null && dealReg.Deal_Reg_Type__c != Label.Deal_Reg_Type_Teaming && (dealReg.Deal_Reg_Expiration_Date__c == null || dealReg.Deal_Reg_Expiration_Date__c <= dealReg.Discovery_Meeting_Date__c + 30)){
            deal.Deal_Reg_Expiration_Date__c =  dealReg.Discovery_Meeting_Date__c + 30; 
        }
        update deal;
        System.debug('updated deal'+deal);

    }
    
    public void updateDealStatustoExpired(id dealRegId){
        Deal_Reg__c deal = new Deal_Reg__c(Id= dealRegId, Status__c = Label.DR_Pending_Conversion, Reason_for_Expiration__c = reasonforExp, Expiration_Requested_By__c = UserInfo.getUserId(), Expiration_Requested_Date__c = System.now());
        update deal;
    }
    
    // modified by Raghu as part of Primary Partner project
    //Modified by Abhishek  : CR# 39 : Partner Margin : End
    public void createOpportunityPartner(id accId, id OppId){
        
        List<Opportunity_Partner__c> oppPartnerlst = new List<Opportunity_Partner__c>();
        //system.debug('### partnerProgram :'+partnerProgram);
        system.debug('### accId :'+accId);
        system.debug('### OppId :'+OppId);
        List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();
        system.debug('### dealReg.Record_Type_Name__c :'+dealReg.Record_Type_Name__c);
        
        Opportunity opp = [Select id,Account.Is_Federal_Account_Sync__c,CloseDate from Opportunity where id =:OppId];   
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
            Opportunity_Partner__c nonDRpartner = getOppPartner(accId, OppId, dealReg.Partner_Category__c == 'Partner-Distributor' ? 'Distributor' : dealReg.Partner_Category__c == 'Partner-Integrator' ? 'System Integrator' : dealReg.Partner_Category__c == 'Technology Partner'? 'Tech Partner' : 'Reseller',finalPartnerIncent,finalPartnerIncentProgram);
            system.debug('### nonDRpartner :'+nonDRpartner);
            if(nonDRpartner != null){
                oppPartnerlst.add(nonDRpartner);
            }
            system.debug('### oppPartnerlst :'+oppPartnerlst);
        }
        Opportunity_Partner__c DRpartner = getOppPartner(accId, OppId, 'Deal Reg',finalPartnerIncent,finalPartnerIncentProgram);
        if(DRpartner != null){
            oppPartnerlst.add(DRpartner);
        }
        insert oppPartnerlst;

        if(accId != null && OppId != null){ 
            for(SBQQ__Quote__c quote : [Select id,SBQQ__Account__c,Show_Banner__c,SBQQ__Opportunity2__c,SBQQ__Partner__c from SBQQ__Quote__c where SBQQ__Opportunity2__c =:OppId and SBQQ__Partner__c =: accId]){   
                quote.Show_Banner__c = true;    
                quoteToUpdate.add(quote);   
            }   
            system.debug('quoteToUpdate'+quoteToUpdate);    
            if(!quoteToUpdate.isEmpty()){   
                update quoteToUpdate;   
            }   
        }
        
        /*Map<String, Opportunity_Partner__c> existingOppPartners = existingdealReg.containskey(oppId) ? existingdealReg.get(oppId) : new Map<String, Opportunity_Partner__c>();
        if(!existingOppPartners.isEmpty() && existingOppPartners.containsKey('Deal Reg')){
            List<Opportunity_Partner__c> lsttoDelete = new List<Opportunity_Partner__c>();
            lsttoDelete.add(existingOppPartners.get('Deal Reg'));
            DeleteOpportunityPartner.deleteopppart(lsttoDelete);
        }*/
        
        List<Opportunity_Partner__c> existingDRlst = existingdealReg.containskey(oppId) ? existingdealReg.get(oppId) : new List<Opportunity_Partner__c>();
        System.debug('line 306....existingDRlst.isEmpty()'+existingDRlst.isEmpty());
        if(!existingDRlst.isEmpty()){
            for(Opportunity_Partner__c opart: existingDRlst){
                opart.Is_Primary__c = false;
            }
        }
        Database.update(existingDRlst, false); 
        /*
        Partner oppPartner = new Partner();
        oppPartner.AccountToId = accId;
        oppPartner.OpportunityId = oppId;
        oppPartner.isPrimary = true;
        insert oppPartner;
        */
    }
    public Opportunity_Partner__c getOppPartner(id accId, id OppId, String parttype,String finalPartnerIncent,String finalPartnerIncentProgram){
        system.debug('### accId :'+accId);
        system.debug('### OppId :'+OppId);
        system.debug('### parttype :'+parttype);
        //system.debug('### partnerProgram :'+partnerProgram);
        //Map<String, Opportunity_Partner__c> existingOppPartners = mapOpptoOppPart.containskey(oppId) ? mapOpptoOppPart.get(oppId) : new Map<String, Opportunity_Partner__c>();
        Boolean createPartner = true;
        Boolean createPrimaryPartner = true;
        Opportunity_Partner__c oppPartner = new Opportunity_Partner__c();
        List<Opportunity_Partner__c> oppPartnerToUpdate = new List<Opportunity_Partner__c>();
        /*String oppparttype = '' + OppId + accId + parttype;
        if(oppparttype != null && oppparttype != '' && oppPartTypetoOppPartID != null && !oppPartTypetoOppPartID.isEmpty() && oppPartTypetoOppPartID.containsKey(oppparttype) && parttype != 'Deal Reg'){
            return null;
        }*/
        if(parttype != 'Deal Reg'){
            for(Opportunity_Partner__c opPartner : [Select id,Account__c,Deal_Registration__c,Is_Primary__c,Opportunity__c,Opportunity__r.SBQQ__PrimaryQuote__c,Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Partner__c,Opportunity__r.SBQQ__PrimaryQuote__r.Partner_Incentive__c,Partner_Incentive__c,Partner_Program__c,Partner_Type__c from Opportunity_Partner__c where Opportunity__c =: OppId and Partner_Type__c=:parttype]){
                system.debug('opPartner.Partner_Incentive__c'+opPartner.Partner_Incentive__c+'finalPartnerIncent'+finalPartnerIncent+'opPartner.Opportunity__r.SBQQ__PrimaryQuote__c'+opPartner.Opportunity__r.SBQQ__PrimaryQuote__c+'opPartner.Is_Primary__c'+opPartner.Is_Primary__c+'opPartner.Account__c'+opPartner.Account__c+'accId'+accId);
                if(opPartner.Opportunity__r.SBQQ__PrimaryQuote__c != null){
                    createPrimaryPartner = false;
                }
                if(String.isNotBlank(finalPartnerIncent) && opPartner.Partner_Incentive__c == finalPartnerIncent && opPartner.Opportunity__r.SBQQ__PrimaryQuote__c != null && opPartner.Account__c == accId){
                    createPartner = false;
                }else if(String.isNotBlank(finalPartnerIncent) && opPartner.Partner_Incentive__c == finalPartnerIncent && opPartner.Opportunity__r.SBQQ__PrimaryQuote__c == null && opPartner.Account__c == accId){
                    if(opPartner.Is_Primary__c == false){
                        opPartner.Is_Primary__c = true;
                        oppPartnerToUpdate.add(opPartner);
                    }
                    createPartner = false;
                }else if(String.isNotBlank(finalPartnerIncent) && opPartner.Partner_Incentive__c != finalPartnerIncent && opPartner.Opportunity__r.SBQQ__PrimaryQuote__c == null && opPartner.Is_Primary__c == true){
                    opPartner.Is_Primary__c = false;
                    createPartner = false;
                    oppPartnerToUpdate.add(opPartner);
                }
        }
        }
        system.debug('oppPartnerToUpdate'+oppPartnerToUpdate);
        if(!oppPartnerToUpdate.isEmpty()){
            update oppPartnerToUpdate;
        }
        if(parttype == 'Deal Reg' || createPartner == true){
        
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
        }
            /*if(partnerProgram != null && partnerProgram == 'Both')
        {
            oppPartner.Partner_Program__c = Label.Partner_Program_Partner_Summit;
        }
        else
        {
            oppPartner.Partner_Program__c = partnerProgram;
            }*/
            //system.debug('### existingOppPartners :'+existingOppPartners);
        system.debug('### parttype :'+parttype);
            /*if(!existingOppPartners.isEmpty() && existingOppPartners.containsKey(parttype) && parttype != 'Deal Reg'){
            oppPartner.Is_Primary__c = false;
            }else{*/
                
            //}
        system.debug('### oppPartner :'+oppPartner);
        }
        return oppPartner;
        /*
        Partner oppPartner = new Partner();
        oppPartner.AccountToId = accId;
        oppPartner.OpportunityId = oppId;
        oppPartner.isPrimary = true;
        insert oppPartner;
        */
    }
    //Modified by Abhishek  : CR# 39 : Partner Margin : End

    //Modified by Abhishek  : Partner Portal : End
    public void createCosellActivity(Id oppId){
        
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
        insert oppPartnerlst;
    }
    
    public Cosell_Activities__c getCosellActivity(id OppId, String type){
        if(dealReg.Partner_Account__c == null){
            return null;
        }

        if(OppId == null){
            return null;
        }

        String oppparttype = '' + OppId + dealReg.Partner_Account__c + type;
        if(oppparttype != null && oppparttype != '' && CosellOppPartTypetoOppPartID != null && !CosellOppPartTypetoOppPartID.isEmpty() && CosellOppPartTypetoOppPartID.containsKey(oppparttype)){
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
            List<contact> conlst = [Select Id from contact where email = :dealReg.Partner_Contact_Email__c and AccountId = :dealReg.Partner_Account__c and OKTA_User_ID__c != null];
            if(!conlst.isEmpty()){
                oppPartner.Partner_Contact__c = conlst[0].Id;
            }
        }
        oppPartner.Partner_Contact_Email__c = dealReg.Partner_Contact_Email__c;
        oppPartner.Status__c = Label.Cosell_Interested;
        return oppPartner;
        
    }
    //Modified by Abhishek  : Partner Portal : End

    public Opportunity createOpportunity(){
        return createOpportunity(null);
    }
    
    public Opportunity createOpportunity(Id customerAccountId){
        Opportunity opp = new Opportunity();
        opp.Name = dealReg.End_Customer_Name__c+'Deal Reg';
        Opp.AccountId = (null != customerAccountId) ? customerAccountId : dealReg.Contact__r.AccountId;
        If(dealReg.Account_Manager__c != null)//Updated by Minkesh for CR# 422
            Opp.OwnerId = dealReg.Account_Manager__c;//Updated by Minkesh for CR# 422
        opp.StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        opp.CloseDate = dealReg.Expected_Close_Date__c;
        opp.Type = 'New Business';
        opp.Source__c = 'Partners';
        //Modified by Abhishek  : CR# 631 : Partner Margin : Start
        /*if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming && dealReg.Partner_Type__c == Label.Partner_Type_Tech_Partner){
            opp.Deal_Reg_Partner_Teaming_Tech_Partner__c = dealReg.Partner_Account__c;
            opp.Deal_Reg_Teaming_Tech_Partner__c = dealReg.Id;
        }else 
		*/if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming){
            opp.Deal_Reg_Partner_Teaming_Reseller__c = dealReg.Partner_Account__c;
            opp.Deal_Reg_Teaming_Reseller__c = dealReg.Id;
        }else{
            opp.Deal_Reg_Margin__c = dealReg.Partner_Account__c;
            opp.Deal_Reg__c = dealReg.Id;
        }
        //Modified by Abhishek  : CR# 631 : Partner Margin : End
        List<Account> acc = [Select id,Is_Federal_Account_Sync__c from Account where id=:Opp.AccountId];
        //Modified by Abhishek  : CR# 39 : Partner Margin : Start
        String partnerIncent = '';
        String defaultFederal = '';
        String federalIncent = '';
        Boolean isIncentive = false;
        for(Partner_Incentive__c incent : [SELECT id,Account__c,Active__c,Partner_Program__c,Partner_Role__c,Partner_Tier__c,Effective_End_Date__c,Effective_Start_Date__c,Default__c FROM Partner_Incentive__c WHERE Account__c =:dealReg.Partner_Account__c AND Active__c = true]){
            if(incent.Partner_Program__c == 'Summit - Federal' && acc[0]?.Is_Federal_Account_Sync__c == true){
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
        return opp;
    }
    
    public void markNonPrimaryResellerPartner(){
        if(dealRegId != null){
            List<Opportunity_Partner__c> existingResellerPartners = [Select Id, Name, Is_Primary__c from Opportunity_Partner__c where Opportunity__c = :selectedOppId and Account__c != :dealReg.Partner_Account__c and (Partner_Type__c = 'Reseller' OR Partner_Type__c = 'Deal Reg')];
            if(!existingResellerPartners.isEmpty()){
                for(Opportunity_Partner__c partner : existingResellerPartners){
                    partner.Is_Primary__c = false;
                }
                update existingResellerPartners;
            }
        }
    }
    
    public PageReference associateDealToOpp(){
        PageReference pageRef ;
        system.debug('# selectedOppId'+selectedOppId);
        if(selectedOppId != '' && selectedOppId != null){
            system.debug('# selectedOppId'+selectedOppId);
            list<Opportunity> oppList = new List<Opportunity>();
            /*oppList = [Select Id, Deal_Reg__c from Opportunity Where Id =: selectedOppId];
            if(!oppList.isEmpty()){
                if(oppList[0].Deal_Reg__c != null && oppList[0].Deal_Reg__c != dealRegId)
                    updateDealStatustoExpired(oppList[0].Deal_Reg__c);
            }*/
            //Modified by Abhishek  : CR# 39 : Partner Margin : Start
            Opportunity op = [Select id,closeDate,Account.Is_Federal_Account_Sync__c from Opportunity where id=:selectedOppId];
            Opportunity opp = new Opportunity(Id = selectedOppId);
            
            //Modified by Abhishek  : CR# 631 : Partner Margin : Start
            /*if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming && dealReg.Partner_Type__c == Label.Partner_Type_Tech_Partner){
                opp.Deal_Reg_Partner_Teaming_Tech_Partner__c = dealReg.Partner_Account__c;
                opp.Deal_Reg_Teaming_Tech_Partner__c = dealReg.Id;
            }else */
            if(dealReg.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming){
                opp.Deal_Reg_Partner_Teaming_Reseller__c = dealReg.Partner_Account__c;
                opp.Deal_Reg_Teaming_Reseller__c = dealReg.Id;
            }
            //CR# 1499 start
            /*else if(dealReg.Deal_Reg_Type__c == 'Renewal'){
                opp.Renewal_Deal_Reg_Partner__c = dealReg.Partner_Account__c;
                //opp.Renewal_Deal_Registration__c = dealReg.Id;
            }*/
            //end CR# 1499
            else{
                opp.Deal_Reg_Margin__c = dealReg.Partner_Account__c;
                opp.Deal_Reg__c = dealReg.Id;
            }
            //Modified by Abhishek  : CR# 631 : Partner Margin : End
            system.debug('### mapOpptoOppPart.containskey(selectedOppId) :'+mapOpptoOppPart.containskey(selectedOppId));
            Map<String, Opportunity_Partner__c> existingOppPartners = mapOpptoOppPart.containskey(selectedOppId) ? mapOpptoOppPart.get(selectedOppId) : new Map<String, Opportunity_Partner__c>();
            system.debug('### existingOppPartners :'+existingOppPartners);
            if(existingOppPartners.isEmpty() || !existingOppPartners.containsKey('Reseller')){
                String partnerIncent = '';
                String defaultFederal = '';
                String federalIncent = '';
                Boolean isIncentive = false;
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
                //opp.Primary_Partner_Program__c = dealReg.Partner_Program__c;
            }
            update opp;
            if(dealReg.Partner_Account__c != null)
                createOpportunityPartner(dealReg.Partner_Account__c, selectedOppId);
            //Modified by Abhishek  : CR# 39 : Partner Margin : End
            createCosellActivity(selectedOppId);
            updateDealStatustoConverted();
            
            if(dealReg.Lead__c != null){
                leadConversionWithAccAndOpp(dealReg.Lead__c, oppIdAccountIdMap.get(selectedOppId), selectedOppId);
            }else if(dealReg.Contact__c != null){
                //contactConversion();
               // createDealRegOpp(dealReg.Id, opp.Id);
                
            } else if (null == dealReg.Lead__c
                && null == dealReg.Contact__c) {
                //opportunityConversion();
            }
            convertedOppId = selectedOppId; 
            if(dealReg.Record_Type_Name__c == 'Renewal Deal Reg')
                markNonPrimaryResellerPartner();
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

        public OpportunityListWrapper(boolean s,Opportunity o){
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
            this.teamingResellerdealRegId = o.Deal_Reg_Teaming_Reseller__c;
            this.teamingResellerdealRegName = o.Deal_Reg_Teaming_Reseller__r.Name;
            this.teamingResellerdealRegStatus = o.Deal_Reg_Teaming_Reseller__r.Status__c;
            this.teamingResellerdealRegPartnerId = o.Deal_Reg_Teaming_Reseller__r.Partner_Account__c;
            this.teamingResellerdealRegPartnerName = o.Deal_Reg_Teaming_Reseller__r.Partner_Account__r.Name;
            this.teamingResellerdealRegPartnerType = o.Deal_Reg_Teaming_Reseller__c == null ? null : o.Deal_Reg_Teaming_Reseller__r.Partner_Type__c == Label.Partner_Type_Tech_Partner ? o.Deal_Reg_Teaming_Reseller__r.Partner_Type__c : Label.Partner_Type_Reseller;
            this.teamingResellerdealRegType = o.Deal_Reg_Teaming_Reseller__c == null ? null : o.Deal_Reg_Teaming_Reseller__r.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming ? Label.Deal_Reg_Type_Teaming : Label.Deal_Reg_Type_Sourced;
            //this.teamingTechPartnerdealRegId = o.Deal_Reg_Teaming_Tech_Partner__c;
            //this.teamingTechPartnerdealRegName = o.Deal_Reg_Teaming_Tech_Partner__r.Name;
            //this.teamingTechPartnerdealRegStatus = o.Deal_Reg_Teaming_Tech_Partner__r.Status__c;
            //this.teamingTechPartnerdealRegPartnerId = o.Deal_Reg_Teaming_Tech_Partner__r.Partner_Account__c;
            //this.teamingTechPartnerdealRegPartnerName = o.Deal_Reg_Teaming_Tech_Partner__r.Partner_Account__r.Name;
            //this.teamingTechPartnerdealRegPartnerType = o.Deal_Reg_Teaming_Tech_Partner__c == null ? null : o.Deal_Reg_Teaming_Tech_Partner__r.Partner_Type__c == Label.Partner_Type_Tech_Partner ? o.Deal_Reg_Teaming_Tech_Partner__r.Partner_Type__c : Label.Partner_Type_Reseller;
            //this.teamingTechPartnerdealRegType = o.Deal_Reg_Teaming_Tech_Partner__c == null ? null : o.Deal_Reg_Teaming_Tech_Partner__r.Deal_Reg_Type__c == Label.Deal_Reg_Type_Teaming ? Label.Deal_Reg_Type_Teaming : Label.Deal_Reg_Type_Sourced;
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
            //.renewaldealRegId = o.Renewal_Deal_Registration__c;
            //this.renewaldealRegPartnerId = o.Renewal_Deal_Registration__r.Partner_Account__c;
            //this.renewaldealRegPartnerName = o.Renewal_Deal_Registration__r.Partner_Account__r.Name;
            //this.renewaldealRegPartnerType = o.Renewal_Deal_Registration__r.Partner_Type__c;
            //this.renewaldealRegType = o.Renewal_Deal_Registration__r.Deal_Reg_Type__c;
            //this.renewaldealRegUrl = '/' + this.renewaldealRegId;
        }
        
        public OpportunityListWrapper(boolean s,string newOppName){
            this.isSelected = s;
            this.oppName = newOppName;
            this.oppId = null;
        }
    }
}