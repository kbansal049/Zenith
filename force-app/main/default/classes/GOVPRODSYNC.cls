@RestResource(urlMapping='/GOVPRODSYNC/*')
global with sharing class GOVPRODSYNC {
    global static Boolean avoidtriggers = false;
    @HttpGet
    global static Map<String, String> doGet() {
        Integer lim;
        RestRequest req = RestContext.request;
        Map<String, String> result = new map<String, String>();
        Map<String, String> resultLean = new map<String, String>();
        Map<String,String> parmap = new Map<String, String>();
        System.debug(req.params);
        System.debug(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8'));
        system.debug(Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')));
        if(req.params!= null && req.params.containskey('type') && EncodingUtil.urlDecode(req.params.get('type'),'UTF-8') == 'get_leads'){
            
            if(req.params.containskey('Start_Date') && EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8') != '' && req.params.containskey('End_Date') && EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8') != '' && Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) && Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8'))){
                List<Lead> leadlst = new List<Lead>();
                lim = [Select count() from lead where Federal_Change__c >= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) and Federal_Change__c <= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8')) and Moved_to_Fedramp_Date__c != today];
                if(req.params.containskey('limit')){
                    if(lim > Integer.valueOf(EncodingUtil.urlDecode(req.params.get('limit'),'UTF-8'))){
                        lim = Integer.valueOf(EncodingUtil.urlDecode(req.params.get('limit'),'UTF-8'));
                    }
                }
                system.debug(lim);
                for(Lead ld: [Select Id, Lead_Contact_Account_Type__c  , Billing_Address__c, Geo__c , Area__c  , Title, Moved_to_Fedramp_Date__c , mkto71_Lead_Score__c, MQL_Date__c, mkto2__Lead_Score__c, Moved_to_FedRamp__c, CreatedDate, Most_Recent_Campaign_Name__c, Most_Recent_Campaign2__c, FirstName, LastName, Company, Status,  Phone, Email, LeadSource,  Closed_Reason__c, Project_Role__c,   Market_Segment__c, No_Employees_Users__c,    Territory__c, Territory_Name__c, ZPA_Manager__c, ZPA_Manager__r.Email, ZPA_SE__c, ZPA_SE__r.Email, Street, City, State, PostalCode, Country /*, (Select Id, CampaignId, Campaign.Name from CampaignMembers order by createddate ASC limit 1) */ from Lead where Federal_Change__c >= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) and Federal_Change__c <= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8')) and Moved_to_Fedramp_Date__c != today limit :lim]){
                    leadlst.add(ld);
                }
                for(Lead ld: [Select Id, LeanData__Reporting_Matched_Account__r.Name  from Lead where Federal_Change__c >= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) and Federal_Change__c <= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8')) and Moved_to_Fedramp_Date__c != today limit :lim]){
                    resultLean.put(ld.Id,ld.LeanData__Reporting_Matched_Account__r.Name);
                }
                system.debug('leadlst ' + leadlst);
                system.debug('resultLean ' + resultLean );

                if(!leadlst.isEmpty()){
                    result.put('leadresults', JSON.serialize(leadlst));
                    result.put('resultLean',  JSON.serialize(resultLean));

                    System.enqueueJob(new ProcessLeadsinPROD(leadlst));
                }
            }
        }
        return result;
    }
  
    @HttpPost
    global static Map<String, String> doPost(Map<String,Account> acclst, List<Opportunity> opptylst, List<Partner> oppartlst, Boolean isparentUPsame) {
        avoidtriggers = true;
        Map<String, String> mapresult = new Map<String, String>();
        Account newAcc = new Account();

        if(acclst != null){
            //create a set of Account Ids that don't yet exist in Commercial SFDC
            Set<Id> accids = new set<Id>();
            for(Account acc: acclst.values()){
                accids.add(acc.Id);
                accids.add(acc.ParentId);
                accids.add(acc.Ultimate_Parent_Account__c);
            }
            for(Account acc: [Select Id from Account where Id in :accids]){
                accids.remove(acc.Id);
            }
            
            //for each imported account
            for(Account acc: acclst.values()){
                //set record type and lock patch
                if(acc.recordtypeId != null && Schema.SObjectType.Account.RecordTypeInfosByName.containskey(acc.RecordType.Name)){
                    acc.RecordtypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get(acc.RecordType.Name).RecordTypeId;
                }
                acc.PatchLocked__c  = true;

                //set Id of any accounts were importing to null
                if(accids.contains(acc.Id)){
                    acc.Id = null;
                }
                if(accids.contains(acc.ParentId)){
                    acc.ParentId = null;
                }
                if(accids.contains(acc.Ultimate_Parent_Account__c)){
                    acc.Ultimate_Parent_Account__c = null;
                }
                acc.Is_Federal_Account_Sync__c = true;
                newAcc=acc;
            }
            TriggerUtility.accTerritoryPatchExecuted();
            TriggerUtility.accSalesTeamExecuted();

            upsert acclst.values();
            
            //for each imported account
            for(string s: acclst.keyset()){
                //add the imported account to our result map to return later
                if(acclst.get(s) != null){
                    mapresult.put(s,acclst.get(s).Id);
                }
                
                if((s == 'Parent' || s == 'Account') && acclst.get(s) != null){
                    if(acclst.get(s).ParentId == null){
                        String s1 = s == 'Parent'? 'Ultimate Parent':'Parent';
                        if(acclst.containskey(s1) && acclst.get(s1) != null){
                            acclst.get(s).ParentId = acclst.get(s1).Id;
                        }
                    }

                    if(acclst.containskey('Ultimate Parent') && acclst.get('Ultimate Parent') != null && acclst.get(s).Ultimate_Parent_Account__c == null){
                        acclst.get(s).Ultimate_Parent_Account__c = acclst.get('Ultimate Parent').Id;
                    }else if(isparentUPsame && s != 'Parent' && acclst.get(s).Ultimate_Parent_Account__c == null && acclst.containskey('Parent') && acclst.get('Parent') != null){
                        acclst.get(s).Ultimate_Parent_Account__c = acclst.get('Parent').Id;
                    }
                }
            }
            update acclst.values();
            
            
            
             /////////////////////////////
            try{
            callCustomerScroreCardCreate(newAcc);
            }
            catch(Exception e){
                System.debug('in catch callCustomerScroreCardCreate' + e.getMessage());
            }
            ////////////////////////////
       
       
       
            System.debug(mapresult);
            if(!opptylst.isEmpty()){
                for(Opportunity opp: opptylst){
                    if(opp.recordtypeid != null && Schema.SObjectType.Opportunity.RecordTypeInfosByName.containskey(opp.RecordType.Name)){
                        opp.RecordtypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get(opp.RecordType.Name).RecordTypeId;
                    }
                    opp.AccountId = acclst != null && acclst.containskey('Account') && acclst.get('Account') != null ? acclst.get('Account').Id: null;
                    opp.PatchLocked__c = true;
                    opp.Is_Federal_Opportunity_Sync__c = true;
                    opp.Applied_Price_List_Name__c = Label.Applied_PL_for_FED;
                }
                insert opptylst;
                mapresult.put('oppid',opptylst[0].Id);
                
                //create OpportunityPartners for the new opp using imported partner data
                List<Opportunity_Partner__c> newOppPartners = new List<Opportunity_Partner__c>();
                for(Partner part: oppartlst){
                    Opportunity_Partner__c newOppPartner = new Opportunity_Partner__c();
                    newOppPartner.Account__c = part.AccountToId;
                    newOppPartner.Opportunity__c = opptylst[0].Id;
                    newOppPartner.Is_Primary__c = part.IsPrimary;
                    newOppPartner.Partner_Type__c = part.Role;

                    //if ceating DR partner, use partner program from Opp for OppPartner as well, and also verify that it is a valid picklist option
                    if(newOppPartner.Partner_Type__c == 'Deal Reg'){
                        List<Schema.PicklistEntry> partnerProgramsOptions = Opportunity_Partner__c.Partner_Program__c.getDescribe().getPicklistValues();
                        for(Schema.PicklistEntry partnerProgramOption: partnerProgramsOptions){
                            if(partnerProgramOption.getValue() == opptylst[0].Primary_Partner_Program__c){
                                newOppPartner.Partner_Program__c = opptylst[0].Primary_Partner_Program__c;
                            }
                        }
                    }


                    newOppPartners.add(newOppPartner);
                }

                insert newOppPartners;

            }
        }
        avoidtriggers = false;
        return mapresult;
        
    }
    
    public class ProcessLeadsinPROD implements Queueable{
        List<Lead> ldlst = new List<Lead>();
        Set<String> federalterset = new Set<String>();
        public ProcessLeadsinPROD(List<Lead> ll){
            ldlst.addAll(ll);
            for(Federal_territories__c ft: Federal_territories__c.getAll().values()){
                federalterset.add(ft.Territory_Name__c);
            }
        }
        public void execute(QueueableContext context) {
            for(Lead ld: ldlst){
                if(ld.Area__c == 'US Federal'){
                    ld.Status = 'Moved to FedRamp';
                    ld.Moved_to_FedRamp__c = true;
                    ld.Moved_to_Fedramp_Date__c = system.now();
                }else if(ld.Status == 'Moved to FedRamp' || ld.Moved_to_FedRamp__c ){
                    ld.Status = 'Pending Marketing Qualification';
                    ld.Moved_to_FedRamp__c = false;
                    ld.Moved_to_Fedramp_Date__c = system.now();
                }
            }
            leadTriggerHelper.skipTrigger = true;
            update ldlst;
        }
    }
    
    
     public static void callCustomerScroreCardCreate(Account newAcc){
        List<Customer_Score_Card__c> listCommCustomerScoreCard = new List<Customer_Score_Card__c>();
        List<Customer_Score_Card__c> numberOfScoreCard = [Select id from Customer_Score_Card__c where Account__c = :newAcc.Id ];
        System.debug('numberOfScoreCard ' + numberOfScoreCard);

        try {
            if (numberOfScoreCard.size()==0){
                Customer_Score_Card__c c = new Customer_Score_Card__c(Account__c=newAcc.Id);
                listCommCustomerScoreCard.add(c);
                Database.insert(listCommCustomerScoreCard, true);
            }
        } catch(Exception e){
            System.debug('in catch' + e.getMessage());
        }
    }
}