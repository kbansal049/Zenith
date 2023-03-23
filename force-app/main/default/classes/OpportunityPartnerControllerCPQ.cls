public with sharing class OpportunityPartnerControllerCPQ {
    
    /**
        Updated BY : Sateesh U 
        This method is used To get All Opportunity Partners data
    **/
    @AuraEnabled
    public static InnerClass GetOppPartnersDetais(String OppId){
        List<Opportunity_Partner__c> OppPartnersList = new List<Opportunity_Partner__c>();
        boolean IsResellerPresent = false;
        boolean IsTechPartnerPresent = false;
    
    //CR#670
        boolean IsEventTechPartnerPresent = false;
        
    boolean IsIntegratorPresent = false;
        boolean IsDistributorPresent = false;
        //Modified by Abhishek  : CR# 39 : Partner Margin : Start
        boolean isDealRegPresent = false;
        boolean isArchPresent = false;
        boolean isPOVPresent = false;
        
        if(OppId != null){
            OppPartnersList = [Select Id,Name,Account__c, Account__r.Model_Type_Partner__c, Partner_Program__c, 
                               Account__r.Name,Is_Primary__c,Opportunity__c,Opportunity__r.Name,Partner_Type__c,
                               Account__r.Partner_Type__c,Deal_Registration__c,
                               Deal_Reg_Type__c, Deal_Registration__r.Name, Deal_Reg_Status__c, 
                               Deal_Reg_Partner_Type__c,Meeting_Date__c,Partner_Incentive__c from Opportunity_Partner__c where Opportunity__c = :OppId];
            
            List<Opportunity> opplst = [Select Id, Deal_Reg__r.Partner_Category__c, StageName, CreatedDate, Is_Federal_Opportunity_Sync__c, Region_Account__c from Opportunity where Id = :OppId];
            //Modified by Abhishek  : CR# 39 : Partner Margin : End
            for(Opportunity_Partner__c OppPartner:OppPartnersList){
                if(OppPartner.Partner_Type__c == 'Distributor'){
                    IsDistributorPresent = true;
                }
                if(OppPartner.Partner_Type__c == 'System Integrator'){
                    IsIntegratorPresent = true;
                }
                if(OppPartner.Partner_Type__c == 'Tech Partner'){
                    IsTechPartnerPresent = true;
                }
                if(OppPartner.Partner_Type__c == 'Reseller'){
                    IsResellerPresent = true;
                }
                //Modified by Abhishek  : CR# 39 : Partner Margin : Start
                if(OppPartner.Partner_Type__c == 'Deal Reg'){
                    isDealRegPresent = true;
                }
                if(OppPartner.Partner_Type__c == 'Architecture Workshop'){
                    isArchPresent = true;
                }
                if(OppPartner.Partner_Type__c == 'POV'){
                    isPOVPresent = true;
                }
                //Modified by Abhishek  : CR# 39 : Partner Margin : End
        
        //CR# 670
                if(OppPartner.Partner_Type__c == 'Tech Partner' && OppPartner.Meeting_Date__c != null){
                    IsEventTechPartnerPresent = true;
                }
            }
            InnerClass Inn = new InnerClass();
            Inn.PartnersList = OppPartnersList;
            Inn.IsResellerPresent = IsResellerPresent;
            Inn.IsTechPartnerPresent = IsTechPartnerPresent;
            Inn.IsEventTechPartnerPresent = IsEventTechPartnerPresent;
            Inn.IsIntegratorPresent = IsIntegratorPresent;
            Inn.IsDistributorPresent = IsDistributorPresent;
            //Modified by Abhishek  : CR# 39 : Partner Margin : Start
            Inn.isDealRegPresent = isDealRegPresent;
            Inn.isPOVPresent = isPOVPresent;
            Inn.isArchPresent = isArchPresent;
            Inn.partnerProgramPickvals = sObjectPicklistValuesHelper.getPickListValues('Opportunity_Partner__c', 'Partner_Program__c');
            Boolean showactions = false;
            if(!opplst.isEmpty()){
                if(opplst[0].Stagename != Label.Stage_5_Contracts_Complete && opplst[0].Stagename != Label.Stage_6_Closed_Won && opplst[0].Stagename != Label.Stage_7_Closed_Lost){
                    showactions =  true;
                }else{
                    Show_Actions_on_Manage_Partner__c proftoskip = Show_Actions_on_Manage_Partner__c.getInstance(Userinfo.getProfileId());
                    Show_Actions_on_Manage_Partner__c usertoskip = Show_Actions_on_Manage_Partner__c.getInstance(Userinfo.getUserId());
                    if(proftoskip.Id != null || usertoskip.Id != null){
                        showactions = true;
                    }
                }
                if((opplst[0].Is_Federal_Opportunity_Sync__c || opplst[0].Region_Account__c == System.Label.Federal) && Date.valueOf(opplst[0].CreatedDate) >= Date.valueOf(System.Label.Cut_Off_Date_for_Federal)){    
                    Inn.isFederal = true;   
                }
            }
            
            Show_Actions_on_Manage_Partner__c proftoskip = Show_Actions_on_Manage_Partner__c.getInstance(Userinfo.getProfileId());
            Show_Actions_on_Manage_Partner__c usertoskip = Show_Actions_on_Manage_Partner__c.getInstance(Userinfo.getUserId());
            if(proftoskip.Id != null || usertoskip.Id != null){
                Inn.isAdmin = true;
            }
            
            Inn.showEditandDelete = showactions;
            //Modified by Abhishek  : CR# 39 : Partner Margin : End
            return Inn;
        }
        return null;
    }
    //Modified by Abhishek  : CR# 39 : Partner Margin : Start
    public class InnerClass{
        @AuraEnabled
        public List<Opportunity_Partner__c> PartnersList{get;set;}
        @AuraEnabled
        public List<String> partnerProgramPickvals{get;set;}
        @AuraEnabled
        public boolean IsResellerPresent{get;set;}
        @AuraEnabled
        public boolean IsTechPartnerPresent{get;set;}
        @AuraEnabled
        public boolean IsEventTechPartnerPresent{get;set;}
        @AuraEnabled
        public boolean IsIntegratorPresent{get;set;}
        @AuraEnabled
        public boolean IsDistributorPresent{get;set;}
        @AuraEnabled
        public boolean isDealRegPresent{get;set;}
        @AuraEnabled
        public boolean isPOVPresent{get;set;}
        @AuraEnabled
        public boolean isArchPresent{get;set;}
        @AuraEnabled
        public boolean showEditandDelete{get;set;}
        @AuraEnabled
        public boolean isAdmin{get;set;}
        @AuraEnabled    
        public boolean isFederal{get;set;}
    }
    //Modified by Abhishek  : CR# 39 : Partner Margin : End
    /**
        Updated BY : Sateesh U 
        This method is used To get Opportunity details
    **/
    @AuraEnabled
    public static Opportunity GetOpportunity(String OppId){
        Opportunity Opprec = new Opportunity();
        if(OppId != null){
            Opprec = [Select Id,Name from Opportunity where Id=:OppId];
        }
        return Opprec;
    }
    /*Added by Priyanka*/
    @AuraEnabled
    public static Boolean checkAddDealPermission(){
        Boolean haveDealAccess = false;
        List<String> profileList = new List<String>();
        if(System.Label.DealReg_ProfileAccess.contains(',')){
            profileList = System.Label.DealReg_ProfileAccess.split(',');
        }
        else{
            profileList.add(System.Label.DealReg_ProfileAccess);
        }
        Map<Id,Profile> profileMap = new Map<Id,Profile>([Select Id from Profile where Name in :profileList]);
        List<String> userIdList = new List<String>();
        if(System.Label.DealReg_UserAccess.contains(',')){
            userIdList = System.Label.DealReg_UserAccess.split(',');
        }
        else{
            userIdList.add(System.Label.DealReg_UserAccess);
        }
        Map<Id,User> userMap = new Map<Id,User>([Select Id from User where Id in :userIdList]);
        System.debug('userIdList::'+userIdList);
        System.debug('userinfo.getUserId()::'+userinfo.getUserId());
        if(profileMap.containsKey(userinfo.getProfileId()) || userMap.containsKey(userinfo.getUserId())){
            haveDealAccess = true;
        }
        System.debug('haveDealAccess::'+haveDealAccess);
        return haveDealAccess;
    }
    
    /**
        Updated BY : Sateesh U 
        This method is used To save the selected partner records.
    **/
    //Modified by Abhishek  : CR# 39 : Partner Margin : Start
    @AuraEnabled
    public static Map<string,string> SavePartnerRec(string OppId, string PartnerRecords, string PartnerType){
        Map<string,string> ResultMap = new Map<string,string>();
        Map<string,string> IdvsTypeMap = new Map<string,string>();
        Map<string,string> resellerPartnerVsTypeMap = new Map<string,string>();
        List<Opportunity_Partner__c> oppparttoDelete = new List<Opportunity_Partner__c>();
        Map<Id, Opportunity> opptoUpdate = new Map<Id, Opportunity>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> dealAccIdSet = new Set<Id>();
        Map<Id, String> accNamemap = new Map<Id, String>();
        List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();
        Boolean isPrimaryResellerPresent = false;
        Boolean isPrimaryDistributorPresent = false;
        if(PartnerType == 'FederalReseller'){   
            PartnerType = 'Reseller';
        }
        List<Opportunity_Partner__c> OppPartnersList = [Select Id,Name,Account__c,Account__r.Name,Is_Primary__c,Opportunity__c,Opportunity__r.Name,Partner_Type__c,Partner_Program__c,Partner_Incentive__c,Partner_Incentive__r.Partner_Role__c from Opportunity_Partner__c where Opportunity__c = :OppId];
        for(Opportunity_Partner__c OppPartner:OppPartnersList){
            if(OppPartner.Partner_Type__c != 'Reseller'){
                IdvsTypeMap.put(OppPartner.Account__c+'-'+OppPartner.Partner_Type__c,OppPartner.Id);
            }else if(OppPartner.Partner_Type__c == 'Reseller'){
                if(OppPartner.Is_Primary__c == true){
                    isPrimaryResellerPresent = true;
                }
                resellerPartnerVsTypeMap.put(OppPartner.Account__c+'-'+OppPartner.Partner_Incentive__c,OppPartner.Id);
            }else if(OppPartner.Partner_Type__c == 'Distributor'){
                if(OppPartner.Is_Primary__c == true){
                    isPrimaryDistributorPresent = true;
                }
            }
            if(OppPartner.Partner_Type__c == PartnerType && (PartnerType == 'Deal Reg' || PartnerType == 'Architecture Workshop' || PartnerType == 'POV')){
                oppparttoDelete.add(OppPartner);
            }
        }
        system.debug('resellerPartnerVsTypeMap'+resellerPartnerVsTypeMap+'IdvsTypeMap'+IdvsTypeMap);
        boolean IsSameAccount = false;
        boolean IsPrimarySelected = false;
        string SelectedPrimaryPartner = '';
        string SelectedPrimaryAccount = '';
        
        //List<Apttus_Proposal__Proposal__c> PrimaryProposalList = [Select Id,Name from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c=:OppId and Apttus_Proposal__Primary__c = true];
        List<SBQQ__Quote__c> PrimaryProposalList = [Select Id,Name from SBQQ__Quote__c where SBQQ__Opportunity2__c=:OppId and SBQQ__Primary__c = true];
        /*if(PrimaryProposalList.size()>0 && PartnerType == 'Reseller'){
            ResultMap.put('State', 'Validation');
            ResultMap.put('Message','You can not change the Primary Reseller Partner if Opportunity has Primary Proposal. You can change the Primary Reseller from the Proposal');
        }else{*/
            //try{
                list<WrapperClass> PartnerRecsList = new list<WrapperClass>();
                
                PartnerRecsList = (List<WrapperClass>)System.JSON.deserialize(PartnerRecords, List<WrapperClass>.class); 
                               
                List<Opportunity_Partner__c> PartnersList = new List<Opportunity_Partner__c>();
                Set<Id> accIds = new Set<Id>();
                Map<Id, String> accpartnermap = new Map<Id, String>();
                for(WrapperClass Wrap: PartnerRecsList){
                    if(Wrap.SelectedRecord != null){
                        accIds.add(Wrap.SelectedRecord.Id);
                    }
                }
                if(!accIds.isEmpty()){
                    for(Account acc: [Select Id,Name, Model_Type_Partner__c from account where id in :accIds]){
                        accpartnermap.put(acc.id, acc.Model_Type_Partner__c == 'Both'?  Label.Partner_Program_Partner_Summit: acc.Model_Type_Partner__c);
                        accNamemap.put(acc.id,acc.Name);
                    }
                }
                for(WrapperClass Wrap:PartnerRecsList){
                    system.debug('Wrap.PartnerIncentiveId'+Wrap.PartnerIncentiveId);
                    //if((String.isNotBlank(Wrap.PartnerIncentiveId) && (resellerPartnerVsTypeMap.isEmpty() || (!resellerPartnerVsTypeMap.isEmpty() && resellerPartnerVsTypeMap.get(Wrap.SelectedRecord.Id+'-'+Wrap.PartnerIncentiveId) == null))) || (String.isBlank(Wrap.PartnerIncentiveId) && (IdvsTypeMap.isEmpty() || (!IdvsTypeMap.isEmpty() && IdvsTypeMap.get(Wrap.SelectedRecord.Id+'-'+PartnerType) == null)))){
                     if((String.isNotBlank(Wrap.PartnerIncentiveId) && (resellerPartnerVsTypeMap.isEmpty() || (!resellerPartnerVsTypeMap.isEmpty() && resellerPartnerVsTypeMap.get(Wrap.SelectedRecord.Id+'-'+Wrap.PartnerIncentiveId) == null)) && (IdvsTypeMap.isEmpty() || (!IdvsTypeMap.isEmpty() && IdvsTypeMap.get(Wrap.SelectedRecord.Id+'-'+PartnerType) == null))) || (String.isBlank(Wrap.PartnerIncentiveId) && (IdvsTypeMap.isEmpty() || (!IdvsTypeMap.isEmpty() && IdvsTypeMap.get(Wrap.SelectedRecord.Id+'-'+PartnerType) == null)))){   
                    //if((!IdvsTypeMap.isEmpty() && IdvsTypeMap.get(Wrap.SelectedRecord.Id+'-'+PartnerType) == null) || (!resellerPartnerVsTypeMap.isEmpty() && resellerPartnerVsTypeMap.get(Wrap.SelectedRecord.Id+'-'+Wrap.PartnerIncentiveId) == null)){
                        
                        Opportunity_Partner__c Partner = new Opportunity_Partner__c();
                        if(Wrap.SelectedRecord != null){
                            Partner.Account__c = Wrap.SelectedRecord.Id;
                            if(Partner.Account__c != null && accpartnermap.containsKey(Partner.Account__c)){
                                //Partner.Partner_Program__c = accpartnermap.get(Partner.Account__c);
                                /*if(Wrap.IsRadioChecked == true && PartnerType == 'Reseller'){
                                    if(Partner.Partner_Program__c == 'Both')
                                    {
                                        opptoUpdate.put(OppId, new Opportunity(Id = OppId, Primary_Partner_Program__c = Label.Partner_Program_Partner_Summit));
                                    }
                                    else
                                    {
                                        opptoUpdate.put(OppId, new Opportunity(Id = OppId, Primary_Partner_Program__c = Partner.Partner_Program__c));
                                    }
                                }*/
                            }
                            
                        }
                        Partner.Is_Primary__c = Wrap.IsRadioChecked;
                        system.debug('isPrimaryResellerPresent'+isPrimaryResellerPresent+'isPrimaryDistributorPresent'+isPrimaryDistributorPresent);
                        if(String.isNotBlank(Wrap.PartnerIncentiveId) && PartnerType == 'Reseller'){
                            if(isPrimaryResellerPresent == false){
                                Partner.Is_Primary__c = true;
                                isPrimaryResellerPresent = true;
                                opptoUpdate.put(OppId, new Opportunity(Id = OppId, Primary_Partner_Program__c = Wrap.PartnerProgram));
                            }
                            Partner.Partner_Incentive__c = Wrap.PartnerIncentiveId;
                            Partner.Partner_Program__c = Wrap.PartnerProgram;
                            
                        }
                        if(PartnerType == 'Distributor'){
                            if(isPrimaryDistributorPresent == false){
                                Partner.Is_Primary__c = true;
                                isPrimaryDistributorPresent = true;
                            }
                        }
                        if(Wrap.IsRadioChecked == true){
                            IsPrimarySelected = true;
                            SelectedPrimaryPartner = PartnerType;
                            SelectedPrimaryAccount = Wrap.SelectedRecord.Id;
                        }
                        if(PartnerType == 'Deal Reg' || PartnerType == 'Architecture Workshop' || PartnerType == 'POV'){
                            Partner.Is_Primary__c = true;
                            if(PartnerType == 'Deal Reg'){
                                if(opptoUpdate.containskey(OppId)){
                                    Opportunity opp = opptoUpdate.get(OppId);
                                    opp.Deal_Reg_Margin__c = Wrap.SelectedRecord.Id;
                                    opptoUpdate.put(OppId, opp);
                                }else{
                                    opptoUpdate.put(OppId, new Opportunity(Id = OppId, Deal_Reg_Margin__c = Wrap.SelectedRecord.Id));
                                }
                                //accountIdSet.add(Wrap.SelectedRecord.Id);
                            } /*else if(PartnerType == 'Architecture Workshop'){
                                if(opptoUpdate.containskey(OppId)){
                                    Opportunity opp = opptoUpdate.get(OppId);
                                    opp.Architectural_Workshop_Margin__c = Wrap.SelectedRecord.Id;
                                    opptoUpdate.put(OppId, opp);
                                }else{
                                    opptoUpdate.put(OppId, new Opportunity(Id = OppId, Architectural_Workshop_Margin__c = Wrap.SelectedRecord.Id));
                                }
                                accountIdSet.add(Wrap.SelectedRecord.Id);
                            }else if(PartnerType == 'POV'){
                                if(opptoUpdate.containskey(OppId)){
                                    Opportunity opp = opptoUpdate.get(OppId);
                                    opp.POV_Margin__c = Wrap.SelectedRecord.Id;
                                    opptoUpdate.put(OppId, opp);
                                }else{
                                    opptoUpdate.put(OppId, new Opportunity(Id = OppId, POV_Margin__c = Wrap.SelectedRecord.Id));
                                }
                                accountIdSet.add(Wrap.SelectedRecord.Id);
                            }*/
                            
                        }else{
                            //Partner.Is_Primary__c = Wrap.IsRadioChecked;
                        }
                        Partner.Opportunity__c = OppId;
                        Partner.Partner_Type__c = PartnerType;
                        PartnersList.Add(Partner);
                        TriggerUtility2.setOppRelTechPartnerExecuted();
                        system.debug('PartnersList in 314'+PartnersList);
                        IdvsTypeMap.put(Wrap.SelectedRecord.Id+'-'+PartnerType,Wrap.SelectedRecord.Id);
                    }else{
                        system.debug('in else');
                        IsSameAccount = true;
                    }
                }
                
                if(PrimaryProposalList.size()>0 && PartnerType == 'Reseller' && IsPrimarySelected == true){
                    ResultMap.put('State', 'Validation');
                    ResultMap.put('Message','You can not change the Primary Reseller Partner if Opportunity has Primary Quote. You can change the Primary Reseller from the Quote');
                }else if(PrimaryProposalList.size()>0 && PartnerType == 'Distributor' && IsPrimarySelected == true){
                    ResultMap.put('State', 'Validation');
                    ResultMap.put('Message','You can not change the Primary Distributor Partner if Opportunity has Primary Quote. You can change the Primary Distributor from the Quote');
                }else if(IsSameAccount == false){
                    if(PartnersList.size()>0){
                        if(IsPrimarySelected == true){
                            List<Opportunity_Partner__c> Partners = [Select Id,Name,Account__c,Account__r.Name,Is_Primary__c,Opportunity__c,Opportunity__r.Name,Partner_Type__c from Opportunity_Partner__c where Opportunity__c = :OppId and Partner_Type__c = :SelectedPrimaryPartner And Account__c != :SelectedPrimaryAccount];
                            for(Opportunity_Partner__c OppPartner:Partners){
                                OppPartner.Is_Primary__c = false;
                            }
                            update Partners;
                        }
                        system.debug('PartnersList'+PartnersList);
                        insert PartnersList;
                    }
                    if(!oppparttoDelete.isEmpty()){
                        DeleteOpportunityPartner.deleteopppart(oppparttoDelete);
                    }
                    if(opptoUpdate != null && !opptoUpdate.isEmpty()){
                        update opptoUpdate.values();
                    }
                    ResultMap.put('State','Success');
                    ResultMap.put('Message','Partner Added Successfully');
                }else{
                    ResultMap.put('State','Validation');
                    ResultMap.put('Message', 'Same Partner Already Added. Please select another Partner');
                }
            /*}Catch(Exception ex){
                ResultMap.put('State','Error');
                ResultMap.put('Message',ex.getMessage());
            }*/
                system.debug('accountIdSet'+accountIdSet);
                if(!accountIdSet.isEmpty()){
                    for(SBQQ__Quote__c quote : [Select id,SBQQ__Account__c,Show_Banner__c,SBQQ__Status__c,SBQQ__Opportunity2__c,SBQQ__Partner__c,Partner_Program__c from SBQQ__Quote__c where SBQQ__Opportunity2__c =: OppId and SBQQ__Partner__c IN :accountIdSet and Partner_Program__c = 'Summit - Discount']){
                        if(quote.SBQQ__Status__c == 'Approved'){
                            quote.SBQQ__Status__c = 'Draft';
                        }
                        quote.Show_Banner__c = true;
                        quoteToUpdate.add(quote);
                    }
                    system.debug('quoteToUpdate'+quoteToUpdate);
                    if(!quoteToUpdate.isEmpty()){
                        update quoteToUpdate;
                    }
                }
        //}
        return ResultMap;
    }
    /**
        Author : Priyanka Jalluri 
        Created Date: 01/02/2021
        Description: This method is used to save the selected deal partner records.
    **/
    @AuraEnabled
    public static Map<string,string> SaveDealRec(string OppId, string dealRecId){
        Map<string,string> ResultMap = new Map<string,string>();
        Set<Id> dealRegIdSet = new Set<Id>();
        Set<id> updateDealIdSet = new Set<id>();
        List<Deal_Reg__c> updateDealList = new List<Deal_Reg__c>();
        Deal_Reg__c selectedDeal = [Select id, Deal_Reg_Type__c from Deal_Reg__c where id=:dealRecId LIMIT 1];
        List<Opportunity_Partner__c> OppPartnersList = [Select Id,Name,Is_Primary__c,Opportunity__c,Opportunity__r.Name,Partner_Type__c,
                                                        Deal_Registration__c,Deal_Reg_Status__c, Deal_Reg_Type__c 
                                                        from Opportunity_Partner__c 
                                                        where Opportunity__c = :OppId];
        for(Opportunity_Partner__c OppPartner:OppPartnersList){
            dealRegIdSet.add(OppPartner.Deal_Registration__c);
            if(selectedDeal.Deal_Reg_Type__c == OppPartner.Deal_Reg_Type__c){
                if(OppPartner.Deal_Registration__c!=null)
                    updateDealIdSet.add(OppPartner.Deal_Registration__c);
            }
        }
        if(dealRegIdSet.isEmpty() || (!dealRegIdSet.isEmpty() && !dealRegIdSet.contains(dealRecId))){
            DealRegConversionLWCHelperCPQ.convertDRtoOpportunity(OppId, dealRecId);
            if(!updateDealIdSet.isEmpty()){
                for(Id dealId : updateDealIdSet){
                    Deal_Reg__c drObj = new Deal_Reg__c(id=dealId, Status__c='Expired');
                    updateDealList.add(drObj);
                }
                update updateDealList;
            }
            ResultMap.put('State','Success'); 
            ResultMap.put('Message','Deal Registration Added Successfully');
        }
        else{
            ResultMap.put('State','Validation');
            ResultMap.put('Message', 'Same Deal Registration Already Added. Please select another Deal Reg');
        }
        return ResultMap;
    }
    
    /*@AuraEnabled
    public static Map<string,string> updatePartnerProgram(String PartnerId, String Program, String OppId){
        Map<string,string> ResultMap = new Map<string,string>();
        if(PartnerId != null && PartnerId != ''){
            List<Opportunity_Partner__c> oppPartlst = [Select Id from Opportunity_Partner__c where Id = :PartnerId and Is_Primary__c = true];
            Opportunity_Partner__c opPart = new Opportunity_Partner__c(Id=PartnerId, Partner_Program__c=Program);
            update opPart;
            if(OppId != null && OppId != '' && !oppPartlst.isEmpty()){
                String programDate = '';
                if(Program == 'Both')
                {
                    programDate = Label.Partner_Program_Partner_Summit;
                }
                else {
                    programDate = Program;
                }
                Opportunity opp = new Opportunity(Id = OppId, Primary_Partner_Program__c=programDate);
                update opp;
            }
            ResultMap.put('State','Success');
            ResultMap.put('Message','Partner Program Updated Successfully');
        }
        return ResultMap;
    }*/
    @AuraEnabled
    public static Map<string,string> updatePartnerProgram(String PartnerId, String Program, String OppId, String incentiveId){
        Map<string,string> ResultMap = new Map<string,string>();
        if(PartnerId != null && PartnerId != ''){
            //List<Opportunity_Partner__c> oppPartlst = [Select Id from Opportunity_Partner__c where Id = :PartnerId and Is_Primary__c = true];
            Opportunity_Partner__c oppPart = [Select Id,Partner_Incentive__c,Partner_Program__c,Is_Primary__c from Opportunity_Partner__c where Id = :PartnerId];
            if(String.isNotBlank(incentiveId)){
                oppPart.Partner_Incentive__c = incentiveId;
            }if(String.isNotBlank(Program)){
                oppPart.Partner_Program__c = Program;
            }
            update oppPart;
            if(String.isNotBlank(OppId) && oppPart.Is_Primary__c == true){
                /*String programDate = '';
                if(Program == 'Both')
                {
                    programDate = Label.Partner_Program_Partner_Summit;
                }
                else {
                    programDate = Program;
                }*/
                Opportunity opp = new Opportunity(Id = OppId, Primary_Partner_Program__c=Program);
                update opp;
            }
            ResultMap.put('State','Success');
            ResultMap.put('Message','Partner Program Updated Successfully');
        }
        return ResultMap;
    }
    
    
    /**
        Updated BY : Sateesh U 
        This method is used To delete the Selected partner record.
    **/
    @AuraEnabled
    public static Map<string,string> DeletePartnerRec(string PartnerId){
        Map<string,string> ResultMap = new Map<string,string>();
        List<Opportunity> opptoUpdate = new List<Opportunity>();
        try{
            if(PartnerId != null){
                List<Opportunity_Partner__c> oplst = [select Id, Opportunity__c, Account__r.Name,Opportunity__r.Validated_Solution_Tech_Partner__c, Partner_Type__c, Name from Opportunity_Partner__c Where Id=:PartnerId];
                if(!oplst.isEmpty()){
                    /*if(oplst[0].Opportunity__c != null && oplst[0].Partner_Type__c == 'Architecture Workshop'){
                        Opportunity opp = new Opportunity(Id = oplst[0].Opportunity__c, Architectural_Workshop_Margin__c = null);
                        opptoUpdate.add(opp);
                    } else if(oplst[0].Opportunity__c != null && oplst[0].Partner_Type__c == 'POV'){
                        Opportunity opp = new Opportunity(Id = oplst[0].Opportunity__c, POV_Margin__c = null);
                        opptoUpdate.add(opp);
                    }*/
                    if(!opptoUpdate.isEmpty()){
                        update opptoUpdate;
                    }
                    DeleteOpportunityPartner.deleteopppart(oplst);
                }
                ResultMap.put('State','Success');
                ResultMap.put('Message','Partner Removed Successfully');
            }
        }Catch(Exception ex){
            ResultMap.put('State','Error');
            ResultMap.put('Message',ex.getMessage());
        }
        return ResultMap;
    }
    //Modified by Abhishek  : CR# 39 : Partner Margin : End
    public class WrapperClass{
        
        @AuraEnabled
        public Account SelectedRecord{get;set;}
        @AuraEnabled
        public String PartnerRole{get;set;}
        @AuraEnabled
        public String PartnerProgram{get;set;}
        @AuraEnabled
        public String PartnerIncentiveId{get;set;}
        @AuraEnabled
        public boolean IsRadioChecked{get;set;}
        //Priyanka
        @AuraEnabled
        public Deal_Reg__c SelectedDealRec{get;set;}
    }
    
    /**
       Updated BY : Sateesh U
       This method is used To Make the selected partner as primary
       Reseller and Distributor partners are selected as primary only when no Primary proposal is created. If primary proposal created they can make changes from partner selection page on quote.
    **/
    @AuraEnabled
    public static Map<string,string> UpdatePrimaryPartner(string PartnerId,string Type,string OppId){
        Map<string,string> ResultMap = new Map<string,string>();
        Opportunity_Partner__c OppPartnerRec = new Opportunity_Partner__c();
        List<Opportunity_Partner__c> OppPartnerList = new List<Opportunity_Partner__c>();
        
        if(PartnerId != null && OppId != null){
            //List<Apttus_Proposal__Proposal__c> PrimaryProposalList = [Select Id,Name from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c=:OppId and Apttus_Proposal__Primary__c = true];
            List<SBQQ__Quote__c> PrimaryProposalList = [Select Id,Name from SBQQ__Quote__c where SBQQ__Opportunity2__c=:OppId and SBQQ__Primary__c = true];
            if(PrimaryProposalList.size()>0 && Type == 'Reseller'){
                ResultMap.put('State','Validation');
                ResultMap.put('Message','You can not change the Primary Reseller Partner if Opportunity has Primary Quote. You can change the Primary Reseller from the Quote');
            }else if(PrimaryProposalList.size()>0 && Type == 'Distributor'){
                ResultMap.put('State','Validation');
                ResultMap.put('Message','You can not change the Primary Distributor Partner if Opportunity has Primary Quote. You can change the Primary Distributor from the Quote');
            }else{
                try{
                    OppPartnerList = [Select Id,Name,Account__c,Is_Primary__c,Opportunity__c,Partner_Type__c from Opportunity_Partner__c where Opportunity__c=:OppId and Is_Primary__c = true And Partner_Type__c=:Type];
                    for(Opportunity_Partner__c OppPartner:OppPartnerList){
                        OppPartner.Is_Primary__c = false;
                    }
                    update OppPartnerList;
                    OppPartnerRec = [Select Id,Name,Account__c,Is_Primary__c,Opportunity__c,Partner_Type__c, Partner_Program__c from Opportunity_Partner__c where Id=:PartnerId];
                    OppPartnerRec.Is_Primary__c = true;
                    update OppPartnerRec;
                    //Modified by Abhishek  : CR# 39 : Partner Margin : Start
                    Opportunity opp = new Opportunity(Id=OppId, Primary_Partner_Program__c=OppPartnerRec.Partner_Program__c);
                    update opp;
                    //Modified by Abhishek  : CR# 39 : Partner Margin : End
                    ResultMap.put('State','Success');
                    ResultMap.put('Message','Partner Updated Successfully');
                }catch(exception ex){
                    ResultMap.put('State','Error');
                    ResultMap.put('Message',ex.getMessage());
                }
            }
        }
        return ResultMap;
    }
    
    @AuraEnabled
    public static Map<string,string> UuncheckPrimaryPartner(string PartnerId,string Type,string OppId){
        Map<string,string> ResultMap = new Map<string,string>();
        Opportunity_Partner__c OppPartnerRec = new Opportunity_Partner__c();
        List<Opportunity_Partner__c> OppPartnerList = new List<Opportunity_Partner__c>();
        
        if(PartnerId != null && OppId != null){
            try{
                OppPartnerRec = [Select Id,Name,Account__c,Is_Primary__c,Opportunity__c,Partner_Type__c from Opportunity_Partner__c where Id=:PartnerId];
                OppPartnerRec.Is_Primary__c = false;
                update OppPartnerRec;
                ResultMap.put('State','Success');
                ResultMap.put('Message','Partner Updated Successfully');
            }catch(exception ex){
                ResultMap.put('State','Error');
                ResultMap.put('Message',ex.getMessage());
            }
        }
        return ResultMap;
    }
    
    /**
    *  @description      : Fetch active Partner Incentives for the given account.
    *  @name             : loadPartnerIncentiveData
    *  @param            : String accountId, String opportunityId
    *  @throws exception : No
    **/
    @AuraEnabled
    public static List<Partner_Incentive__c> loadPartnerIncentiveData(String accountId, String opportunityId,Boolean showAllIncentives) {
        system.debug('inside loadPartnerIncentiveData');
        List<Partner_Incentive__c> partnerIncentiveList = new List<Partner_Incentive__c>();
        try {
            Opportunity opp = [SELECT id,CloseDate FROM Opportunity WHERE Id =:opportunityId];
            if(showAllIncentives == true){
                partnerIncentiveList = new List<Partner_Incentive__c>([SELECT id,Account__c,Active__c,Partner_Program__c,Partner_Role__c,Partner_Tier__c,Effective_End_Date__c,Effective_Start_Date__c FROM Partner_Incentive__c WHERE Account__c=: accountId AND Active__c = true AND Effective_Start_Date__c <= :opp.CloseDate AND Effective_End_Date__c >=: opp.CloseDate]);
            }
            system.debug('partnerIncentiveList====>'+partnerIncentiveList);
            if(partnerIncentiveList.isEmpty()){
                partnerIncentiveList = new List<Partner_Incentive__c>([SELECT id,Account__c,Active__c,Partner_Program__c,Partner_Role__c,Partner_Tier__c,Effective_End_Date__c,Effective_Start_Date__c,Default__c FROM Partner_Incentive__c WHERE Account__c=: accountId AND Active__c = true AND Default__c = true]);
            }
        }catch (Exception e) {
            system.debug('error'+e.getMessage());
        }
        return partnerIncentiveList;
    }
}