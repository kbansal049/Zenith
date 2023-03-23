/*****************************************************************************************
Name: DealRegTriggerHelper
Copyright © Zscaler
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
Purpose:
--------
Helper class for genericDealRegTrigger.
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
History
-------
1.Modified "beforeupdate" method as part of CR#3668
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal/Vijay            4-OCT-2016    Initial Development
2.0            Bharath                1/19/2022     CR# 3952 - Link DR with Partner and Distributor
3.0            Swathi                 2/25/2022     CR# 3744 - ProfessionalService Partner
4.0            Swathi                 3/21/2022     CR# 4500 - Commenting lines of Deal Reg expiartion date
5.0            Swathi                 3/22/2022     CR# 3360 - Distributor Account Owner
6.0            Swathi                 6/15/2022     CR# 4691 - modifying DealRegPartnerDeailsAutoFill for Tech Partners
7.0            Swathi                 4/28/2022     CR# 3849 - TechPartner RAM Assignment
8.0            Swathi                 6/14/2022     CR# 4863 - Focus Partner
9.0            Rajat J                11/17/2022    IBA-3278 - FY 23 Partner Program - DR rejected by RSM  
10.0           Swathi                 3/9/2023      IBA-7556 - Commenting Deal_Reg_Teaming_Tech_Partner__c,Deal_Reg_Partner_Teaming_Tech_Partner__c
******************************************************************************************/

Public class DealRegTriggerHelper{
    
    public static void beforeInsert(list<Deal_Reg__c> newDealList){
        set<string> endCustEmailSet = new set<string>();
        map<string, Lead> emailLeadMap = new map<string, Lead>();
        map<string, Contact> emailContactMap = new map<string, Contact>();
        map<string, string> conLeadIdUserIdMap = new map<string, string>(); 
        map<string, string> domainPartnerAccIdMap = new map<string, string>();  
        
        map<Id, Id> partnerAccEmailMap = new map<Id, Id>();
        map<Id, string> partnerAccManagerEmailMap = new map<Id, string>();
        map<Id, string> partnerAccSEEmailMap = new map<Id, string>();
        
        Map<String, String> geoLeadersMap = new Map<String, String>();
        Map<String,String> ConGeoEmailMap = new Map<String, String>();
        set<String> partnerDomainSet = new set<string>();
        set<Id> territoryIdSet = new set<Id>();
        
        // 8/23/2022 - start IBA-2112
        Map<Id,PatchTeam__c> salesTertIdvsSalesTertMap = new Map<Id,PatchTeam__c>();
        // 8/23/2022 - END IBA-2112
        //CR# 3952 - Start
        Map<Id,List<Partner_Incentive__c>> partnerAccVsPITransEnt = new Map<Id,List<Partner_Incentive__c>>();
        Map<Id,String> partnerAccVsPIManualReview = new Map<Id,String>();
        Set<Id> summitDistPartnerAcc = new Set<Id>();
        
        
        //CR# 3952 - End
        Set<String> partnerTypeSet = new set<string>();
        Map<ID, Account> mapAccountVsID = new map<ID, Account>();//CR#3744
        partnerTypeSet.add('Partner-SP');
        partnerTypeSet.add('Partner-Reseller');
        partnerTypeSet.add('Partner-Distributor');
        partnerTypeSet.add('Partner-Integrator');
        partnerTypeSet.add('Partner-DC-BW');
        partnerTypeSet.add('Global SP/SI Partner');
        
        //Added by Pankaj  : CR# 135 : Deal Reg Approvals  : Start
        partnerTypeSet.add('Technology Partner');
        
        //CR# 1039 - parth
        Set<Id> partnerAccountIds = new Set<Id>();
        
        for(Deal_Reg__c deal : newDealList){
            if(deal.End_Customer_Email__c != '' && deal.End_Customer_Email__c != null)
                endCustEmailSet.add(deal.End_Customer_Email__c);
            if(deal.Partner_Contact_Email__c != '' && deal.Partner_Contact_Email__c != null)
                partnerDomainSet.add((deal.Partner_Contact_Email__c.Split('@'))[1]);
            
            //CR# 1039
            if(deal.Partner_Account__c != null)
                partnerAccountIds.add(deal.Partner_Account__c);
        }
        System.debug('--partnerAccountIds--'+partnerAccountIds);
        System.debug('--endCustEmailSet--'+endCustEmailSet);
        System.debug('--partnerDomainSet--'+partnerDomainSet);
        
       
        for(Account acc : [Select ID, Domain__c, OwnerId,Owner.Email,Ultimate_Parent_Account__r.Account_Manager__r.ID,Service_Authorizations__c,Technology_Alliance_Manager__c,
                           Account_Manager__r.ID,Sales_Engineer__r.Email,Account_Manager__r.Email, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.OwnerId,Partner_Level__c,
                           Ultimate_Parent_Account__r.Owner.Email, Ultimate_Parent_Account__r.Sales_Engineer__r.Email,Ultimate_Parent_Account__r.Account_Manager__r.Email,
                           SummitDistribution__c,
                           (Select Id,Account__c,Transacting_Entity__c,Transacting_Location__c,Transacting_Entity__r.OwnerId
                                                  from Partner_Incentives__r 
                                                  where Transacting_Entity__c != null
                                                  AND Partner_Role__c = 'Reseller'
                                                  AND Active__c = true) 
                           from Account 
                           Where Id In :partnerAccountIds] )
        {
                               System.debug('--acc--'+acc + acc.Ultimate_Parent_Account__c );
                               mapAccountVsID.put(acc.Id,acc); //CR#3744
                               if(acc.Ultimate_Parent_Account__c != null) {
                                   domainPartnerAccIdMap.put(acc.Domain__c, acc.Ultimate_Parent_Account__c);
                                   partnerAccEmailMap.put(acc.Ultimate_Parent_Account__c, acc.Ultimate_Parent_Account__r.OwnerId);
                                   partnerAccManagerEmailMap.put(acc.Ultimate_Parent_Account__c, acc.Ultimate_Parent_Account__r.Owner.Email);
                                   partnerAccSEEmailMap.put(acc.Ultimate_Parent_Account__c, acc.Ultimate_Parent_Account__r.Sales_Engineer__r.Email);
                               }
                               else {
                                   domainPartnerAccIdMap.put(acc.Domain__c, acc.id);
                                   partnerAccEmailMap.put(acc.Id, acc.OwnerId);
                                   partnerAccManagerEmailMap.put(acc.ID, acc.owner.Email);
                                   partnerAccSEEmailMap.put(acc.Id, acc.Sales_Engineer__r.Email);
                               }
                               //CR# 3952 - Start
                               if(acc.SummitDistribution__c){
                                   summitDistPartnerAcc.add(acc.Id);
                                   if(acc.Partner_Incentives__r.size() > 0){
                                       partnerAccVsPITransEnt.put(acc.Id, acc.Partner_Incentives__r);
                                   }
                               }
                               //CR# 3952 - End
                           }
        
        System.debug('--partnerAccEmailMap--'+partnerAccEmailMap);
        System.debug('--partnerAccManagerEmailMap--'+partnerAccManagerEmailMap);
        System.debug('--partnerAccVsPITransEnt--'+partnerAccVsPITransEnt);
        
        Map<String, String> userEmailMap = new Map<String, String>();
        Map<String, String> EmailUserMap = new Map<String, String>();
        
        for (User userInfo : [SELECT Id, Email FROM User WHERE Id IN :partnerAccEmailMap.values() OR EMAIL IN :partnerAccManagerEmailMap.values()]) {
            userEmailMap.put(userInfo.Id, userInfo.Email);
            EmailUserMap.put( userInfo.Email,userInfo.Id);
        }
        System.debug('--userEmailMap--'+userEmailMap);
        System.debug('--EmailUserMap--'+EmailUserMap);
        
        
        //Prepare the GEO leaders map
        /*for (Deal_Reg_GEO_Leaders__c geoLeader : [SELECT SetupOwnerId, GEO__c FROM Deal_Reg_GEO_Leaders__c]) {
if (geoLeader.GEO__c.contains(';')) {
for (String geo : geoLeader.GEO__c.split(';')) {
geoLeadersMap.put(geo, geoLeader.SetupOwnerId);
}
} else {
geoLeadersMap.put(geoLeader.GEO__c, geoLeader.SetupOwnerId);
}
}*/
        
        for(Contact con : [Select Id, Email, Account_Manager__c, Channel_Manager__c, Territory__c,territory__r.theater__c,  Account.Market_Segment__c, (Select id from Campaignmembers Where Campaign.Name = 'Deal Registration')  from Contact Where Email IN: endCustEmailSet ORDER BY CreatedDate DESC]){
            
            ConGeoEmailMap.put(con.Email,con.territory__r.theater__c);
            
            if(emailContactMap != null){
                if(!emailContactMap.keyset().contains(con.Email))
                    emailContactMap.put(con.Email, con);
            }else
                emailContactMap.put(con.Email, con);
            
            if(con.Territory__c != null)
                territoryIdSet.add(con.Territory__c);    
        }
        
        set<string> convrtLeadEmailSet = new set<string>();
        for(Lead lead : [Select Id, Email, Account_Manager__c, Channel_Manager__c, Territory__c,Territory__r.theater__c, Market_Segment__c,  isConverted, (Select id from Campaignmembers Where Campaign.Name = 'Deal Registration') from Lead Where Email IN: endCustEmailSet ORDER BY CreatedDate DESC]){
            if(lead.Email != null && lead.isConverted)
                convrtLeadEmailSet.add(lead.Email);
            if(!convrtLeadEmailSet.contains(lead.Email)){
                if(emailLeadMap != null){
                    if(!emailLeadMap.keyset().contains(lead.Email))
                        emailLeadMap.put(lead.Email, lead);
                }else
                    emailLeadMap.put(lead.Email, lead);
                
                if(lead.Territory__c != null)
                    territoryIdSet.add(lead.Territory__c);            
            }
        }
        
        Map<String, Id> territorySalesUserIdMap = new Map<String, Id>();
        Map<Id,Focus_Partner__c> IdVsFocusPartnerMap = new Map<Id,Focus_Partner__c>();
        for(PatchTeam__c territory : [Select id, Name, Territory_type__c, Theater__c, (Select Id, Role__c, PatchTeam__c, User__c,User__r.ManagerId from PatchTeamMembers__r),(Select Id,Partner_Account__c,Partner_Account__r.Ultimate_Parent_Account__c ,RAM__c from Focus_Partners__r where Partner_Account__c IN :partnerAccEmailMap.keySet()) from PatchTeam__c where ID IN: territoryIdSet]){
         //IBA - 2112 - Start
            salesTertIdvsSalesTertMap.put(territory.id, territory);
            //IBA - 2112 - END
            for(PatchTeamMember__c salesTeam : territory.PatchTeamMembers__r){
                if(salesTeam.Role__c == 'Account Manager')
                    territorySalesUserIdMap.put(''+territory.id+'AccountManager', salesTeam.User__c);
                if(salesTeam.Role__c == 'Area Director')
                    territorySalesUserIdMap.put(''+territory.id+'AreaDirector', salesTeam.User__c);
                if(salesTeam.Role__c == 'Channel Manager')
                    territorySalesUserIdMap.put(''+territory.id+'ChannelManager', salesTeam.User__c);
                //CR-432 - Modified by Abhishek V - DR Approval Changes - Start
                if(salesTeam.Role__c == 'Geo VP')
                    territorySalesUserIdMap.put(''+territory.id+'GEOVP', salesTeam.User__c);  
                if(salesTeam.Role__c == 'Regional VP')
                    territorySalesUserIdMap.put(''+territory.id+'RegionalVP', salesTeam.User__c); 
                //CR-432 - Modified by Abhishek V - DR Approval Changes - End 
                //CR# 3849 - Start
                if(salesTeam.Role__c == 'Tech Partner Sales Manager'){
                    territorySalesUserIdMap.put(''+territory.id+'TechPartnerSalesManager', salesTeam.User__c);
                    territorySalesUserIdMap.put(''+territory.id+'TechPartnerSalesManagersManager', salesTeam.User__r.ManagerId);
                }
                if(salesTeam.Role__c == 'Tech Partner Solution Architect')
                    territorySalesUserIdMap.put(''+territory.id+'TechPartnerSolutionArchitect', salesTeam.User__c);
                //CR# 3849 - End
            }
            //CR-432 - Modified by Abhishek V - DR Approval Changes - Start
            //territorySalesUserIdMap.put('' + territory.Id + 'GEOVP', geoLeadersMap.get(territory.Theater__c));
            //CR-432 - Modified by Abhishek V - DR Approval Changes - End
            if((territory.Focus_Partners__r).size()>0){
                IdVsFocusPartnerMap.put(territory.Id,territory.Focus_Partners__r);
            }
        }
        
        System.debug('--emailContactMap--'+emailContactMap);
        System.debug('--emailLeadMap--'+emailLeadMap);
        System.debug('--territorySalesUserIdMap--'+territorySalesUserIdMap);
        System.debug('--IdVsFocusPartnerMap--'+IdVsFocusPartnerMap);
        
        map<string, Deal_Reg__c> emailDealForNewLeadMap = new map<String, Deal_Reg__c>(); 
        boolean newLead = false;
        
        set<Id> conIdSet = new set<Id>();
        set<Id> leadIdSet = new set<Id>();
        for(Deal_Reg__c deal : newDealList){
            
            if(deal.End_Customer_Email__c != '' && deal.End_Customer_Email__c != null){
                deal.End_Customer_Domain__c = (deal.End_Customer_Email__c.Split('@'))[1];
                if(emailContactMap.keyset().contains(deal.End_Customer_Email__c)){
                    deal.Contact__c = emailContactMap.get(deal.End_Customer_Email__c).Id;
                    deal.Sales_Territory__c = emailContactMap.get(deal.End_Customer_Email__c).Territory__c;
                    System.debug('--deal--'+deal);
                    if(mapEmailVsGeoTech.get(emailContactMap.get(deal.End_Customer_Email__c).Territory__r.Theater__c)!=null)
                        deal.Tech_Partner_Geo_Email__c =mapEmailVsGeoTech.get(emailContactMap.get(deal.End_Customer_Email__c).Territory__r.Theater__c);
                    deal.Account_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'AccountManager');
                    deal.Area_Director__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'AreaDirector'); 
                    //CR-432 - Modified by Abhishek V - DR Approval Changes - Start
                    deal.GEO_VP__c = territorySalesUserIdMap != null && !territorySalesUserIdMap.isEmpty() && territorySalesUserIdMap.containsKey('' + deal.Sales_Territory__c+'GEOVP') ? territorySalesUserIdMap.get('' + deal.Sales_Territory__c+'GEOVP') : null;
                    deal.Regional_VP__c = territorySalesUserIdMap != null && !territorySalesUserIdMap.isEmpty() && territorySalesUserIdMap.containsKey('' + deal.Sales_Territory__c+'RegionalVP') ? territorySalesUserIdMap.get('' + deal.Sales_Territory__c+'RegionalVP') : null;
                    //CR# 4863 - Start
                    if(deal.Partner_Type__c =='Partner'){
                        if(IdVsFocusPartnerMap.containskey(deal.Sales_Territory__c)){
                            deal.Channel_Manager__c = IdVsFocusPartnerMap.get(deal.Sales_Territory__c).RAM__c;
                        }else{
                            deal.Channel_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'ChannelManager');
                        }
                    }//CR# 4863 End // CR# 3849 - Start
                    else{
                        if(mapAccountVsID.containsKey(deal.Partner_Account__c) && mapAccountVsID.get(deal.Partner_Account__c).Partner_Level__c=='Tier 1: Strategic'){
                            deal.Tech_Partner_Sales_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'TechPartnerSalesManager');
                            deal.Tech_Partner_Sales_Manager_s_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'TechPartnerSalesManagersManager');							
                            deal.Tech_Partner_Solution_Architect__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'TechPartnerSolutionArchitect');
                        }
                    }
                    //CR# 3849 - End
                    deal.Market_Segment__c = emailContactMap.get(deal.End_Customer_Email__c).Account.Market_Segment__c;
                    if(emailContactMap.get(deal.End_Customer_Email__c).Campaignmembers.isEmpty())
                        conIdSet.add(deal.Contact__c);
                    
                }else if(emailLeadMap.keyset().contains(deal.End_Customer_Email__c)){
                    deal.Sales_Territory__c = emailLeadMap.get(deal.End_Customer_Email__c).Territory__c;
                    System.debug('--deal--'+deal);
                    if(mapEmailVsGeoTech.get(emailLeadMap.get(deal.End_Customer_Email__c).Territory__r.Theater__c)!=null)
                        deal.Tech_Partner_Geo_Email__c =mapEmailVsGeoTech.get(emailLeadMap.get(deal.End_Customer_Email__c).Territory__r.Theater__c);
                    deal.Account_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'AccountManager');
                    // CR# 4863 - Start
                    if(deal.Partner_Type__c =='Partner'){
                        if(IdVsFocusPartnerMap.containskey(deal.Sales_Territory__c)){
                            deal.Channel_Manager__c = IdVsFocusPartnerMap.get(deal.Sales_Territory__c).RAM__c;
                        }else{
                            deal.Channel_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'ChannelManager');
                        }
                    } //CR# 4863 End // CR# 3849 - Start
                    else{
                        if(mapAccountVsID.containsKey(deal.Partner_Account__c) && mapAccountVsID.get(deal.Partner_Account__c).Partner_Level__c=='Tier 1: Strategic'){
                            deal.Tech_Partner_Sales_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'TechPartnerSalesManager');
                            deal.Tech_Partner_Sales_Manager_s_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'TechPartnerSalesManagersManager');	
                            deal.Tech_Partner_Solution_Architect__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'TechPartnerSolutionArchitect');
                        }
                    }
                    //CR# 3849 - End
                    deal.Area_Director__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'AreaDirector');
                    //CR-432 - Modified by Abhishek V - DR Approval Changes - Start
                    deal.GEO_VP__c = territorySalesUserIdMap != null && !territorySalesUserIdMap.isEmpty() && territorySalesUserIdMap.containsKey('' + deal.Sales_Territory__c+'GEOVP') ? territorySalesUserIdMap.get('' + deal.Sales_Territory__c+'GEOVP') : null;
                    deal.Regional_VP__c = territorySalesUserIdMap != null && !territorySalesUserIdMap.isEmpty() && territorySalesUserIdMap.containsKey('' + deal.Sales_Territory__c+'RegionalVP') ? territorySalesUserIdMap.get('' + deal.Sales_Territory__c+'RegionalVP') : null;
                    deal.Lead__c = emailLeadMap.get(deal.End_Customer_Email__c).Id;
                    deal.Market_Segment__c = emailLeadMap.get(deal.End_Customer_Email__c).Market_Segment__c;
                    if(emailLeadMap.get(deal.End_Customer_Email__c).Campaignmembers.isEmpty())
                        leadIdSet.add(deal.Lead__c);
                    
                }else{
                    if(!convrtLeadEmailSet.Contains(deal.End_Customer_Email__c)){
                        newLead = true;
                        emailDealForNewLeadMap.put(deal.End_Customer_Email__c, deal);
                    }
                } 
            }
            
            if(deal.Partner_Contact_Email__c != '' && deal.Partner_Contact_Email__c != null){
                if(deal.Partner_Account__c == null){
                    deal.Partner_Account__c = domainPartnerAccIdMap.get((deal.Partner_Contact_Email__c.Split('@'))[1]);
                }
                deal.Partner_Domain__c = (deal.Partner_Contact_Email__c.Split('@'))[1];
            }
            
            if(partnerAccountIds != null && !partnerAccountIds.isEmpty() && deal.Partner_Account__c != null){
                deal.Partner_Account_Owner_Email__c = userEmailMap.get(partnerAccEmailMap.get(deal.Partner_Account__c));
                deal.Partner_Account_Owner__c = EmailUserMap.get(partnerAccManagerEmailMap.get(deal.Partner_Account__c));
                deal.Partner_Account_SE_Email__c = partnerAccSEEmailMap.get(deal.Partner_Account__c);
            }
            
            if(deal.Record_Type_Name__c != System.Label.Renewal_Deal_Reg)
                deal.DS_Review_Status__c = 'Pending';
            else{
                deal.DS_Review_Status__c = 'Complete';
                if(deal.Partner_Account_Id__c != null)
                    deal.Partner_Account__c = deal.Partner_Account_Id__c;
                if(deal.Renewal_Opportunity_Owner__c != null && deal.Renewal_Opportunity_Owner__c.startsWith('005')){
                    deal.OwnerId = deal.Renewal_Opportunity_Owner__c;
                    deal.Account_Manager__c = deal.Renewal_Opportunity_Owner__c;
                }
            }
            
            //CR# 3952 - Start
            if(summitDistPartnerAcc.contains(deal.Partner_Account__c) && partnerAccVsPITransEnt.containsKey(deal.Partner_Account__c)){
                String billingCountry = deal.End_Customer_Country__c;
                String nonStandardbillingCountry= '%'+billingCountry+'%';
                //if the billing country is not standardized then get the value from metadata
                List<CountryMappingSetting__mdt> countryList = [SELECT StandardCountryName__c,AlternativeCountryNames__c FROM CountryMappingSetting__mdt where AlternativeCountryNames__c Like :nonStandardbillingCountry];
                if(!countryList.isEmpty()){
                    billingCountry=countryList[0].StandardCountryName__c;
                }
                System.debug('billingCountry'+billingCountry);
                System.debug('partnerAccVsPITransEnt'+partnerAccVsPITransEnt);
                List<Partner_Incentive__c> piResults =  new List<Partner_Incentive__c>();
                piResults = partnerAccVsPITransEnt.get(deal.Partner_Account__c);
                Map<String,String> locationVsPI = new Map<String,String>();
                for(Partner_Incentive__c pi:partnerAccVsPITransEnt.get(deal.Partner_Account__c)){
                    if(locationVsPI.containsKey(pi.Account__c+'-'+pi.Transacting_Location__c) && locationVsPI.get(pi.Account__c+'-'+pi.Transacting_Location__c) == 'Unique'){
                        locationVsPI.put(pi.Account__c+'-'+pi.Transacting_Location__c,'NonUnique');
                    }else{
                        locationVsPI.put(pi.Account__c+'-'+pi.Transacting_Location__c,'Unique');
                    }
                    
                }
                System.debug('locationVsPI'+locationVsPI);
                for(Partner_Incentive__c piMatch:partnerAccVsPITransEnt.get(deal.Partner_Account__c)){
                    if(locationVsPI.get(piMatch.Account__c+'-'+piMatch.Transacting_Location__c) == 'Unique' && billingCountry == piMatch.Transacting_Location__c){
                        deal.Distributor__c	= piMatch.Transacting_Entity__c;
                        deal.Distributor_Account_Owner__c = piMatch.Transacting_Entity__r.OwnerId;//CR#3360
                    }
                }
            }
            //CR# 3952 - End
            //CR# 3744 - Start
            if(deal.Partner_Account__c != null && mapAccountVsID.containsKey(deal.Partner_Account__c) && mapAccountVsID.get(deal.Partner_Account__c).Service_Authorizations__c!=Null ){
                deal.Professional_Services_Certified__c = true;
            }
            //CR# 3744 - End
            if(deal.Partner_Type__c!='Partner'){
                deal.Technology_Alliance_Manager__c = (deal.Partner_Account__c != null && mapAccountVsID.containsKey(deal.Partner_Account__c) && mapAccountVsID.get(deal.Partner_Account__c).Technology_Alliance_Manager__c!=Null) ? mapAccountVsID.get(deal.Partner_Account__c).Technology_Alliance_Manager__c : Null;//CR# 3849
            }
            //IBA-2112 -- start
          //  String territoryName = salesTertIdvsSalesTertMap.get(deal.Sales_Territory__c).Name.toLowerCase();
            if((mapAccountVsID.containsKey(deal.Partner_Account__c) && deal.Partner_Type__c!='Technology Partner') && ( salesTertIdvsSalesTertMap.get(deal.Sales_Territory__c) != null) 
               && !salesTertIdvsSalesTertMap.get(deal.Sales_Territory__c).Name.contains('SMB') && salesTertIdvsSalesTertMap.get(deal.Sales_Territory__c).Territory_Type__c != 'Commercial'
               && !(salesTertIdvsSalesTertMap.get(deal.Sales_Territory__c).Name.contains('Comm') && salesTertIdvsSalesTertMap.get(deal.Sales_Territory__c).Territory_Type__c == 'Catch All')){
                //IBA-2112 -- end 
                deal.AW_POV_Partner_Intent__c = 'Interested';
            }
            System.debug('--deal--'+deal);
        }
        
        list<CampaignMember> campMemberInsertList = new list<CampaignMember>();
        string dealRegCampaignId = ZscalerSetting__c.getValues('DealRegCampaign').Value__c;
        
        for(id conId : conIdSet){
            campMemberInsertList.add(new CampaignMember(CampaignId = dealRegCampaignId, ContactId = conId, Status = 'Responded'));
        }
        for(id leadId : leadIdSet){
            campMemberInsertList.add(new CampaignMember(CampaignId = dealRegCampaignId, LeadId = leadId, Status = 'Responded'));
        }
        
        try{
            if(!campMemberInsertList.isEmpty()){
                database.insert(campMemberInsertList, false);
            }
        }catch(exception e){}
        //if(newLead)
        //    createLeadForDealReg(emailDealForNewLeadMap);
        
        TriggerUtility.dealRegBeforeInsertExecuted();    
    }
    /*
public static void createLeadForDealReg(map<string, Deal_Reg__c> emailDealMap){
createLeadForDealReg(emailDealMap, new Map<String, String>());
}

public static void createLeadForDealReg(map<string, Deal_Reg__c> emailDealMap, Map<String, String> geoLeadersMap){
list<Lead> leadInsertList = new list<Lead>();
for(Deal_Reg__c deal : emailDealMap.values()){
Lead tempLead = new Lead();
tempLead.FirstName = deal.End_Customer_Contact_Name__c;
tempLead.LastName = deal.End_Customer_Contact_Last_Name__c;
tempLead.Company = deal.End_Customer_Name__c;
tempLead.Email = deal.End_Customer_Email__c;
tempLead.Phone = deal.End_Customer_Phone__c;
tempLead.LeadSource = 'Deal Registration';
tempLead.HasOptedOutOfEmail = true;
//tempLead.Status = 'Not Attempted';
tempLead.Status = 'Pending Marketing Qualification';
tempLead.OrgDomain__c = deal.End_Customer_Domain__c;
tempLead.Street = deal.End_Customer_Street_Address__c;
tempLead.City = deal.End_Customer_City__c;
tempLead.PostalCode = deal.End_Customer_Postal_Code__c;
tempLead.Country = deal.End_Customer_Country__c;
tempLead.State = deal.End_Customer_State__c;
leadInsertList.add(tempLead);
}
if(!leadInsertList.isEmpty())
database.Insert(leadInsertList, false);
set<Id> leadIdSet = new set<Id>();
for(Lead le : leadInsertList){
if(le.Id != null)
leadIdSet.add(le.Id);
}
map<string, Id> emailAccManagerMap = new map<String, Id>();
map<string, Id> emailChannelManagerMap = new map<String, Id>();
map<string, Id> emailSalesTerritoryMap = new map<String, Id>();
if(!leadIdSet.isEmpty()){
for(Lead le : [Select id, email, Account_Manager__c, Channel_Manager__c, Territory__c  from Lead where ID IN: leadIdSet]){
emailAccManagerMap.put(le.Email,le.Account_Manager__c);
emailChannelManagerMap.put(le.Email,le.Channel_Manager__c);
emailSalesTerritoryMap.put(le.Email,le.Territory__c);

}
}

Map<String, Id> territorySalesUserIdMap = new Map<String, Id>();

for(PatchTeam__c territory : [Select id, Theater__c, (Select Id, Role__c, PatchTeam__c, User__c from PatchTeamMembers__r) from PatchTeam__c where ID IN: emailSalesTerritoryMap.Values()]){
for(PatchTeamMember__c salesTeam : territory.PatchTeamMembers__r){
if(salesTeam.Role__c == 'Area Director')
territorySalesUserIdMap.put(''+territory.id+'AreaDirector', salesTeam.User__c);
//CR-432 - Modified by Abhishek V - DR Approval Changes - Start
if(salesTeam.Role__c == 'Geo VP'){
territorySalesUserIdMap.put(''+territory.id+'GEOVP', salesTeam.User__c);
}
if(salesTeam.Role__c == 'Regional VP'){
territorySalesUserIdMap.put(''+territory.id+'RegionalVP', salesTeam.User__c);
}
}
//CR-432 - Modified by Abhishek V - DR Approval Changes - Start
//territorySalesUserIdMap.put(''+territory.Id + 'GEOVP', geoLeadersMap.get(territory.Theater__c));
}


list<CampaignMember> campMemberInsertList = new list<CampaignMember>();
string dealRegCampaignId = ZscalerSetting__c.getValues('DealRegCampaign').Value__c;
for(Lead le : leadInsertList){
if(le.Id != null){
emailDealMap.get(Le.Email).Lead__c = le.Id;
emailDealMap.get(Le.Email).Account_Manager__c = emailAccManagerMap.get(le.Email);
emailDealMap.get(Le.Email).Channel_Manager__c = emailChannelManagerMap.get(le.Email);
emailDealMap.get(Le.Email).Sales_Territory__c = emailSalesTerritoryMap.get(le.Email);
emailDealMap.get(le.Email).Area_Director__c = territorySalesUserIdMap.get(''+emailSalesTerritoryMap.get(le.Email)+'AreaDirector');
//CR-432 - Modified by Abhishek V - DR Approval Changes - Start
//emailDealMap.get(le.Email).GEO_VP__c = territorySalesUserIdMap.get(''+emailSalesTerritoryMap.get(le.Email)+'GEOVP');
emailDealMap.get(le.Email).GEO_VP__c = territorySalesUserIdMap != null && !territorySalesUserIdMap.isEmpty() && territorySalesUserIdMap.containsKey(''+emailSalesTerritoryMap.get(le.Email)+'GEOVP') ? territorySalesUserIdMap.get(''+emailSalesTerritoryMap.get(le.Email)+'GEOVP') : null;
emailDealMap.get(le.Email).Regional_VP__c = territorySalesUserIdMap != null && !territorySalesUserIdMap.isEmpty() && territorySalesUserIdMap.containsKey(''+emailSalesTerritoryMap.get(le.Email)+'RegionalVP') ? territorySalesUserIdMap.get(''+emailSalesTerritoryMap.get(le.Email)+'RegionalVP') : null;
campMemberInsertList.add(new CampaignMember(CampaignId  = dealRegCampaignId, LeadId = le.Id, Status = 'Responded'));
}
}
if(!campMemberInsertList.isEmpty()){
database.insert(campMemberInsertList, false);
}

}*/
    
    
    public static void afterInsert(list<Deal_Reg__c> newDealList){
        Set<Id> dealIdSet = new set<Id>();
        for(Deal_Reg__c deal : newDealList){
            dealIdSet.add(deal.Id);
            if(deal.Record_Type_Name__c == System.Label.Renewal_Deal_Reg){
                DealRegConversionLWCHelper.convertDRtoOpportunity(deal.Renewal_Opportunity__c, deal.Id);
            }
        } 
        CaseCreationForAccountAndOpportunity.dealRegCaseCreation(newDealList);
        
        if(!System.isFuture())
            changeDealRegOwner(dealIdSet);
        TriggerUtility.dealRegAfterInsertExecuted();    
    }
    
    @future(Callout=true)
    public static void changeDealRegOwner(set<id> dealRegIdSet){
        //IBA-4623- Send it for Approval for commerical deg reg where Territory is already populated.
        MAP<ID,Deal_Reg__c> dealRegUpdateMAPList = new MAP<ID,Deal_Reg__c>();
        //list<Deal_Reg__c> dealRegUpdatePartnerAccountManager = new list<Deal_Reg__c>();
        
        for(Deal_Reg__c deal: [Select Id,Geo__c,Tech_Partner_Geo_Email__c,/*Partner_Account_Manager__c,*/
                               Partner_Account__r.TYpe,Partner_Account__R.Account_Manager__C,
                               Partner_Account__R.Account_Manager__r.IsActive,ownerId,Area_Director__c,Area_Director__r.IsActive,
                               Account_Manager__c, Account_Manager__r.IsActive ,
                               Channel_Manager__c , Channel_Manager__r.IsActive, Sales_Territory__c,
                               Sales_Territory__r.Territory_type__c,DS_Review_Status__c,
                               Contact__c,Lead__c,Partner_Account__r.Partner_Type__c,
                               Summit_Distribution_Status__c	
                               FROM Deal_Reg__c WHERE Id IN: dealRegIdSet])
        {
            //if(deal.Account_Manager__c != null && deal.Account_Manager__r.IsActive)
            //dealRegUpdateList.add(new Deal_Reg__c(Id = deal.Id, OwnerId = deal.Account_Manager__c));
            //else if(deal.Channel_Manager__c != null && deal.Channel_Manager__r.IsActive)
            //dealRegUpdateList.add(new Deal_Reg__c(Id = deal.Id, OwnerId = deal.Channel_Manager__c));
            
            //Added by Pankaj  : CR# 135 : Deal Reg Approvals  : Start
            if(deal.Area_Director__c != null && deal.Area_Director__r.IsActive)
            {
                dealRegUpdateMAPList.put(deal.Id,new Deal_Reg__c(Id = deal.Id, OwnerId = deal.Area_Director__c));
            }
            //if(deal.Partner_Account__r.type=='Technology Partner' && deal.Partner_Account__R.Account_Manager__c != null && deal.Partner_Account__R.Account_Manager__r.IsActive)
            //{
            //    dealRegUpdatePartnerAccountManager.add(new Deal_Reg__c(Id = deal.Id, Partner_Account_Manager__c = deal.Partner_Account__R.Account_Manager__c,Tech_Partner_Geo_Email__c=mapEmailVsGeoTech.get(deal.geo__c)));
            //}
            
            //Added By Viral : IBA-4623
            if((deal.Contact__c != null || deal.Lead__c != null) && deal.Sales_Territory__c != null 
               && deal.Sales_Territory__r.Territory_type__c == 'Commercial' 
               && deal.Summit_Distribution_Status__c != 'Manual Review' && deal.Partner_Account__r.Partner_Type__c != 'Partner-Distributor') 
            {
                Deal_Reg__c drg = dealRegUpdateMAPList.containsKey(deal.Id) ? dealRegUpdateMAPList.get(deal.Id) :  new Deal_Reg__c(Id = deal.Id);
                drg.DS_Review_Status__c = 'Complete'; 
                dealRegUpdateMAPList.put(deal.Id,drg);
        }
        }
        system.debug('# dealRegUpdateMAPList : '+dealRegUpdateMAPList.values());
        if(!dealRegUpdateMAPList.isEmpty())
            update dealRegUpdateMAPList.values();
        
        //system.debug('# dealRegUpdatePartnerAccountManager : '+dealRegUpdatePartnerAccountManager);
        //if(!dealRegUpdatePartnerAccountManager.isEmpty())
        //    update dealRegUpdatePartnerAccountManager;
        //            database.update(dealRegUpdateList,false);
        
    }
    
    
    public static void beforeUpdate(Map<Id, Deal_Reg__c> oldMap, List<Deal_Reg__c> newList) {
         // IBA-2557 30 Aug 2022 -- START
        Map<Id,PatchTeam__c> salesTertIdvsSalesTertMap = new Map<Id,PatchTeam__c>();
        // IBA-2557 30 Aug 2022 -- END
        system.debug('inside beforeUpdate method ');
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        
        if(!TriggerUtility.isDRPendingNBMConvertedExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_DR_Pending_NBM_To_Converted') && tsmap.get('Execute_DR_Pending_NBM_To_Converted') != null && tsmap.get('Execute_DR_Pending_NBM_To_Converted').Execute__c){
            convertPendingNBMtoConverted(oldMap, newList);
        }
        
        if(!TriggerUtility.isDRCopyPriorStatusonExpExtensionExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_DR_Revert_Status_Exp_Extension') && tsmap.get('Execute_DR_Revert_Status_Exp_Extension') != null && tsmap.get('Execute_DR_Revert_Status_Exp_Extension').Execute__c){
            changeStatusonExpiryExtension(oldMap, newList);
        }
        
        if(!TriggerUtility.isDRPriorStatusCaptureExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_DR_Capture_Prior_Status') && tsmap.get('Execute_DR_Capture_Prior_Status') != null && tsmap.get('Execute_DR_Capture_Prior_Status').Execute__c){
            capturePriorStatus(oldMap, newList);
        }
        
        if(!TriggerUtility.isDRRemovalfromOppExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_DR_Removal_from_Opp') && tsmap.get('Execute_DR_Removal_from_Opp') != null && tsmap.get('Execute_DR_Removal_from_Opp').Execute__c){
            removeDRfromOpp(oldMap, newList);
        }
        
        if(!TriggerUtility.dontThrowErrorForConvertedDR){
            drStatusChangedFromConvertedDirectly(oldMap, newList);
        }
        
        String endCustomerDomain;
        Set<Id> partnerAccountIDSet = new Set<Id>();
        for (Deal_Reg__c dReg : newList) {
            system.debug('dReg '+dReg);
            system.debug('oldMap '+oldMap);
            if (oldMap.get(dReg.Id).Escalated_To_GEO_Leader__c == false && dReg.Escalated_To_GEO_Leader__c == true) {
                TriggerUtility.dealRegAfterUpdateReset();
            }
            // Added for CR#3109
            if(dReg.End_Customer_Domain__c != null ){
                endCustomerDomain = dReg.End_Customer_Domain__c;                
            }
            
            //Added for CR#3668
            if(dReg.Status__c != null && oldMap.get(dReg.Id).Status__c != dReg.Status__c && dReg.Status__c == 'Converted') {
                dReg.Deal_Reg_Conversion_Date__c = System.Date.today();
                /*commenting as part of CR#4500 start
if(dReg.NBM_Meeting_Date__c == null && dReg.Discovery_Meeting_Date__c != null && dReg.Deal_Reg_Type__c != Label.Deal_Reg_Type_Teaming && (dReg.Deal_Reg_Expiration_Date__c == null || dReg.Deal_Reg_Expiration_Date__c <= dReg.Discovery_Meeting_Date__c + 30)){
dReg.Deal_Reg_Expiration_Date__c =  dReg.Discovery_Meeting_Date__c + 30; 
} commenting as part of CR#4500 end*/
            }
            //CR#3360 Start
            if(dReg.Distributor__c!=Null && oldMap.get(dReg.Id).Distributor__c != dReg.Distributor__c ){
                dReg.Distributor_Account_Owner__c = [Select OwnerID from Account where Id=:dReg.Distributor__c].OwnerID;
            }
            //CR#3360 End
            //CR# 3849 - Start
            if((dReg.Partner_Account__c != null && (dReg.Partner_Account__c != oldMap.get(dReg.Id).Partner_Account__c ||
                                                    dReg.Sales_Territory__c != oldMap.get(dReg.Id).Sales_Territory__c ) && dReg.Partner_Type__c=='Technology Partner') || 
               (dReg.Partner_Account__c!=null && dReg.Partner_Type__c == 'Partner')){
                   partnerAccountIDSet.add(dReg.Partner_Account__c);
               }
            //CR# 3849 - END
        }
        //CR# 3849 - Start
        Map<Id, Account> partnerAccIdVSRecordMap = new Map<Id, Account>();
        if(!partnerAccountIDSet.isEmpty()){
            For(Account PRAcc : [Select Id,Technology_Alliance_Manager__c,Partner_Level__c,Ultimate_Parent_Account__c from Account where ID IN: partnerAccountIDSet]){
                partnerAccIdVSRecordMap.put(PRAcc.Id,PRAcc);
            }
        }
        //CR# 3849 - END
        List<Account> accList = new List<Account>();
        if(endCustomerDomain != null){
            accList=[SELECT Id,Global_2000_Rank__c,Type,Ultimate_Parent_Account__c,Ultimate_Parent_Account__r.Type,Ultimate_Parent_Account__r.Global_2000_Rank__c FROM Account 
                     WHERE 
                     (Domain__c = :endCustomerDomain or Additional_Organization_Domains__c = :endCustomerDomain)  ORDER BY CreatedDate DESC LIMIT 1];
        }
        set<id> salesTerritoryIdSet = new set<id>();
        Set<ID> partnerAccountIds = New Set<Id>();
        for(Deal_Reg__c deal : newList){
            if((deal.Sales_Territory__c != null && deal.Sales_Territory__c != oldMap.get(deal.Id).Sales_Territory__c && deal.Partner_Type__c!='Partner') ||
               (deal.Sales_Territory__c != null && deal.Sales_Territory__c != oldMap.get(deal.Id).Sales_Territory__c && deal.Partner_Type__c=='Partner' && deal.DS_Review_Status__c =='Complete') ||
               (deal.Sales_Territory__c != null && deal.DS_Review_Status__c != oldMap.get(deal.Id).DS_Review_Status__c && deal.Partner_Type__c=='Partner' && deal.DS_Review_Status__c =='Complete')){
                   salesTerritoryIdSet.add(deal.Sales_Territory__c);
                   if(partnerAccIdVSRecordMap.containsKey(deal.Partner_Account__c) && partnerAccIdVSRecordMap.get(deal.Partner_Account__c).Ultimate_Parent_Account__c != null){
                       partnerAccountIds.add(partnerAccIdVSRecordMap.get(deal.Partner_Account__c).Ultimate_Parent_Account__c );
                   }else{
                       partnerAccountIds.add(deal.Partner_Account__c);
                   }
               }
             // IBA-2557 30 Aug 2022 -- START
               if(deal.Sales_Territory__c != null){
                 if(deal.Sales_Territory__c != oldMap.get(deal.Id).Sales_Territory__c && deal.Status__c != 'Converted'){
                    salesTerritoryIdSet.add(deal.Sales_Territory__c);
               }
            }
            // IBA-2557 30 Aug 2022 -- END
            //CR# 3849 - Start
            if(partnerAccIdVSRecordMap.containsKey(deal.Partner_Account__c) && deal.Partner_Type__c=='Technology Partner'){
                deal.Technology_Alliance_Manager__c = partnerAccIdVSRecordMap.get(deal.Partner_Account__c).Technology_Alliance_Manager__c !=Null ? partnerAccIdVSRecordMap.get(deal.Partner_Account__c).Technology_Alliance_Manager__c : Null;
            }
            //CR# 3849 - End
            // Added for CR#3109  -Start
            if(accList.size() > 0){
                
                if(deal.DS_Review_Status__c =='Complete' && accList.get(0).Ultimate_Parent_Account__c != null) {
                    deal.Account__c  =   accList.get(0).Ultimate_Parent_Account__c; 
                }
                if(deal.DS_Review_Status__c =='Complete' && accList.get(0).Ultimate_Parent_Account__c == null){
                    deal.Account__c  =   accList.get(0).Id;                   
                }
                // Not to change the Account Type value once the value is captured 
                if( deal.DS_Review_Status__c =='Complete' && accList.get(0).Ultimate_Parent_Account__c != null && deal.Account_Type__c == null ){
                    deal.Account_Type__c  = accList.get(0).Ultimate_Parent_Account__r.Type; 
                }
                if( deal.DS_Review_Status__c =='Complete' &&  accList.get(0).Ultimate_Parent_Account__c == null && deal.Account_Type__c == null ){
                    deal.Account_Type__c  = accList.get(0).Type; 
                }
                
            } /* End for CR#3109  */
        }
        
        Map<String, Id> territorySalesUserIdMap = new Map<String, Id>();
        Map<Id,Focus_Partner__c> IdVsFocusPartnerMap = new Map<Id,Focus_Partner__c>();
        if(!salesTerritoryIdSet.isEmpty()){
            for(PatchTeam__c territory : [Select Id, Name, Territory_Type__c, (Select Id, Role__c, PatchTeam__c, User__c,User__r.ManagerId from PatchTeamMembers__r),(Select Id,Partner_Account__c,RAM__c,Partner_Account__r.Ultimate_Parent_Account__c from Focus_Partners__r where Partner_Account__c IN :partnerAccountIds) from PatchTeam__c where ID IN: salesTerritoryIdSet]){
                // IBA-2557 30 Aug 2022 -- START
                salesTertIdvsSalesTertMap.put(territory.Id, territory);
                // IBA-2557 30 Aug 2022 -- END
                for(PatchTeamMember__c salesTeam : territory.PatchTeamMembers__r){
                    if(salesTeam.Role__c == 'Account Manager')
                        territorySalesUserIdMap.put(''+territory.id+'AccountManager', salesTeam.User__c);
                    if(salesTeam.Role__c == 'Area Director')
                        territorySalesUserIdMap.put(''+territory.id+'AreaDirector', salesTeam.User__c);
                    if(salesTeam.Role__c == 'Channel Manager')
                        territorySalesUserIdMap.put(''+territory.id+'ChannelManager', salesTeam.User__c);
                    if(salesTeam.Role__c == 'Geo VP')
                        territorySalesUserIdMap.put(''+territory.id+'GEOVP', salesTeam.User__c); 
                    if(salesTeam.Role__c == 'Regional VP')
                        territorySalesUserIdMap.put(''+territory.id+'RegionalVP', salesTeam.User__c);
                    if(salesTeam.Role__c == 'Tech Partner Sales Manager'){
                        territorySalesUserIdMap.put(''+territory.id+'TechPartnerSalesManager', salesTeam.User__c);
                        territorySalesUserIdMap.put(''+territory.id+'TechPartnerSalesManagersManager', salesTeam.User__r.ManagerId);
                    }
                    if(salesTeam.Role__c == 'Tech Partner Solution Architect')
                        territorySalesUserIdMap.put(''+territory.id+'TechPartnerSolutionArchitect', salesTeam.User__c);
                }
                if((territory.Focus_Partners__r).size()>0){
                    IdVsFocusPartnerMap.put(territory.Id,territory.Focus_Partners__r);
                }
            }
            System.debug('IdVsFocusPartnerMap '+IdVsFocusPartnerMap);
            System.debug('territorySalesUserIdMap '+territorySalesUserIdMap);
            for(Deal_Reg__c deal : newList){
                deal.Area_Director__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'AreaDirector');
                deal.Account_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'AccountManager');
                if(deal.Partner_Type__c =='Partner'){
                    System.debug('inside');
                    if(IdVsFocusPartnerMap.containskey(deal.Sales_Territory__c)){
                        deal.Channel_Manager__c = IdVsFocusPartnerMap.get(deal.Sales_Territory__c).RAM__c;
                    }else{
                        deal.Channel_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'ChannelManager');
                    }
                }
                else if(partnerAccIdVSRecordMap.containsKey(deal.Partner_Account__c) && partnerAccIdVSRecordMap.get(deal.Partner_Account__c).Partner_Level__c=='Tier 1: Strategic'){
                    deal.Tech_Partner_Sales_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'TechPartnerSalesManager');
                    deal.Tech_Partner_Sales_Manager_s_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'TechPartnerSalesManagersManager');
                    deal.Tech_Partner_Solution_Architect__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'TechPartnerSolutionArchitect');
                }
                deal.GEO_VP__c = territorySalesUserIdMap != null && !territorySalesUserIdMap.isEmpty() && territorySalesUserIdMap.containsKey('' + deal.Sales_Territory__c+'GEOVP') ? territorySalesUserIdMap.get('' + deal.Sales_Territory__c+'GEOVP') : null;
                deal.Regional_VP__c = territorySalesUserIdMap != null && !territorySalesUserIdMap.isEmpty() && territorySalesUserIdMap.containsKey('' + deal.Sales_Territory__c+'RegionalVP') ? territorySalesUserIdMap.get('' + deal.Sales_Territory__c+'RegionalVP') : null;
                
                   // IBA-2557 30 Aug 2022 -- START
            
            if(salesTertIdvsSalesTertMap.get(deal.Sales_Territory__c) != null && (salesTertIdvsSalesTertMap.get(deal.Sales_Territory__c).Id != oldMap.get(deal.Id).Sales_Territory__c) && deal.Status__c != 'Converted'){
                String territoryName = salesTertIdvsSalesTertMap.get(deal.Sales_Territory__c).Name.toLowerCase();
                if(!territoryName.contains(' smb ') && !(territoryName.contains('comm') && salesTertIdvsSalesTertMap.get(deal.Sales_Territory__c).Territory_Type__c == 'Catch All') && (salesTertIdvsSalesTertMap.get(deal.Sales_Territory__c).Territory_Type__c != 'Commercial')){
                    deal.AW_POV_Partner_Intent__c = 'Interested';
                }else if(territoryName.contains(' smb ') || (territoryName.contains('comm') && salesTertIdvsSalesTertMap.get(deal.Sales_Territory__c).Territory_Type__c == 'Catch All') || (salesTertIdvsSalesTertMap.get(deal.Sales_Territory__c).Territory_Type__c == 'Commercial')){
                    deal.AW_POV_Partner_Intent__c = '';
                } 
            }
            // IBA-2557 30 Aug 2022 -- END
            }
        }
    }    
    
    public static void afterUpdate(Map<Id, Deal_Reg__c> oldMap, List<Deal_Reg__c> newList) {
        system.debug('inside after Updated method');
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();

        if(!TriggerUtility.isDRRejectApprovalExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_DR_Reject_Approval') && tsmap.get('Execute_DR_Reject_Approval') != null && tsmap.get('Execute_DR_Reject_Approval').Execute__c){
            system.debug('before calling RejectDRinApproval method');
            RejectDRinApproval(oldMap, newList);
        }
        
        List<Approval.ProcessSubmitRequest> approvalProcessRequestList = new List<Approval.ProcessSubmitRequest>();
        List<Approval.ProcessResult> approvalProcessResultList = new List<Approval.ProcessResult>();
        Map<Id, Deal_Reg__c> smbdealRegMap = new  Map<Id, Deal_Reg__c>();
        Map<String, Id> smbDealRegDomainMap = new Map<String, Id>();
        Map<String, Id> geoLeadersMap = new Map<String, Id>();
        Map<Id, Deal_Reg__c> dealRegToUpdateList = new Map<Id, Deal_Reg__c>();
        Set<Id> dealRegIdsToRecallApproval = new Set<Id>();
        Map<Id, Id> dealRegNewPartnerMap = new Map<Id, Id>();
        List<Id> newPartnerAccountsList = new List<Id>();
        
        //CR# 135
        Set<Id> dealIdSet = new set<Id>();
        
        //Query the Sales Ops Administrator user's SF Id
        
        //Changes by Gurjinder :CR# 320 :Start
        String SalesOpsSystemAdminUser= ZscalerCustomSetting__c.getInstance('SalesOpsSystemAdminUserID')!=null && ZscalerCustomSetting__c.getInstance('SalesOpsSystemAdminUserID').Value__c!=null ? ZscalerCustomSetting__c.getInstance('SalesOpsSystemAdminUserID').Value__c:'00570000002GeGO';
        id sfAdminUser=id.valueof(SalesOpsSystemAdminUser);
        
        //User sfAdminUser = [SELECT Id, Name, UserName FROM User WHERE Name = 'Sales Ops System Admin' AND IsActive = TRUE LIMIT 1];
        //Changes by Gurjinder :CR# 320 :End
        
        
        //Prepare the GEO leaders map
        /*for (Deal_Reg_GEO_Leaders__c geoLeader : [SELECT SetupOwnerId, GEO__c FROM Deal_Reg_GEO_Leaders__c]) {
if (geoLeader.GEO__c.contains(';')) {
for (String geo : geoLeader.GEO__c.split(';')) {
geoLeadersMap.put(geo, geoLeader.SetupOwnerId);
}
} else {
geoLeadersMap.put(geoLeader.GEO__c, geoLeader.SetupOwnerId);
}
}*/
        Map<Id,Deal_Reg__c> dealRegIdWithObjectMap = new Map<Id,Deal_Reg__c>();
        
        for (Deal_Reg__c record : newList) {
          
            if((oldmap.get(record.id).Area_Director__C!= record.Area_Director__c && record.Area_Director__c!=null) || (record.Area_Director__c!=record.OwnerID) ||(record.partner_type__c=='Technology Partner'))
            {
                dealIdSet.add(record.id);
            }
            //Identify the records that has Market Segment = 'SMB' and has been reviewed by DS team
            if ('Complete' != oldMap.get(record.Id).DS_Review_Status__c
                && 'Complete' == record.DS_Review_Status__c && record.Record_Type_Name__c != Label.Renewal_Deal_Reg)
            {
                //If Territory Type is GB or Territory Type is All and Market Segment is SMB or SOHO
                //Then consider the deal for Auto-approval
                //Proceed only if the Partner Account is found. Otherwise, automatically reject it.
                if (null != record.Partner_Account__c) {
                    System.debug('record.Territory_Type__c'+ record.Territory_Type__c + record.Market_Segment__c);  
                    //Commented as part of CR# 3086
                    /*if ((/* 'Corporate Sales'== record.Territory_Type__c
|| 'Territory Sales'== record.Territory_Type__c */ //Commented as a part of CR# 737
                    /* 'Commercial'== record.Territory_Type__c 
|| 'All' == record.Territory_Type__c)
&& ('SOHO' == record.Market_Segment__c
|| 'SMB' == record.Market_Segment__c)
) {
smbDealRegDomainMap.put(record.End_Customer_Domain__c, record.Id);
smbdealRegMap.put(record.Id, record);
}

else {*/
                    Approval.ProcessSubmitRequest newApprovalRequest = new Approval.ProcessSubmitRequest();
                    newApprovalRequest.setComments('Submit for Manager\'s approval');
                    newApprovalRequest.setObjectId(record.Id);
                    newApprovalRequest.setSubmitterId(sfAdminUser);
                    
                    approvalProcessRequestList.add(newApprovalRequest);
                    //}
                } else {
                    dealRegToUpdateList.put(record.Id, 
                                            new Deal_Reg__c(Id = record.Id,
                                                            Status__c = 'Rejected',
                                                            Approval_Status__c = 'No Partner Account Found'
                                                           ));
                }
            }
            
            //Added by Varun for CR# 2555 - Start
            if(record.Deal_Reg_Type__c!=null && (oldmap.get(record.id).Deal_Reg_Type__c!= record.Deal_Reg_Type__c) 
               && ((record.Deal_Reg_Type__c=='Sourced' && oldmap.get(record.id).Deal_Reg_Type__c=='Teaming'))||
               (record.Deal_Reg_Type__c=='Teaming' && oldmap.get(record.id).Deal_Reg_Type__c=='Sourced'))
            {
                
                dealRegIdWithObjectMap.put(record.id,record);
            }
            //Added by Varun for CR# 2555 - End
            
            /**
* Commenting out this block due to requirement change.
* New Requirements:
* - GEO VP will now be just notified through Workflow
* - Sales team's rejection will be the final rejection
*/
            //Identify the list of records that got escalated to Geo Leader
            //if (true == record.Escalated_To_GEO_Leader__c
            //    && false == oldMap.get(record.Id).Escalated_To_GEO_Leader__c
            //    && ('Complete' == record.DS_Review_Status__c
            //        || 'APAC' == record.GEO__c
            //        || 'EMEA' == record.GEO__c
            //        || 'AMERICAS' == record.GEO__c
            //        || 'CHANNEL' == record.GEO__c)) {
            //    Boolean skipGeoLeaderReview = false;
            
            //    if ('channel manager rejected' == record.Approval_Status__c.toLowerCase()
            //        && record.Channel_Manager__c == geoLeadersMap.get(record.GEO__c)) {
            //        skipGeoLeaderReview = true;
            //    } else if ('account manager rejected' == record.Approval_Status__c.toLowerCase()
            //        && record.Account_Manager__c == geoLeadersMap.get(record.GEO__c)) {
            //        skipGeoLeaderReview = true;
            //    } else if ('area director rejected' == record.Approval_Status__c.toLowerCase()
            //        && record.Area_Director__c == geoLeadersMap.get(record.GEO__c)) {
            //        skipGeoLeaderReview = true;
            //    }
            
            //    if (true == skipGeoLeaderReview) {
            //        dealRegToUpdateList.put(record.Id, new Deal_Reg__c(
            //                                Id = record.Id,
            //                                Approval_Status__c = 'Rejected',
            //                                Status__c = 'Rejected'
            //                            ));
            //        break;
            //    }
            
            //    dealRegIdsToRecallApproval.add(record.Id);
            
            //    Approval.ProcessSubmitRequest newApprovalRequest = new Approval.ProcessSubmitRequest();
            //    newApprovalRequest.setComments('Escalate to GEO Leader');
            //    newApprovalRequest.setObjectId(record.Id);
            //    newApprovalRequest.setSubmitterId(sfAdminUser.Id);
            //    newApprovalRequest.setNextApproverIds(new Id[] { geoLeadersMap.get(record.GEO__c) });
            //    newApprovalRequest.setProcessDefinitionNameOrId('GEO_Leader_Escalation_Deal_Reg_Approval');
            
            //    approvalProcessRequestList.add(newApprovalRequest);
            //}
            
            //Identify the records whose partner account has been updated
            if (record.Partner_Account__c != oldMap.get(record.Id).Partner_Account__c) {
                newPartnerAccountsList.add(record.Partner_Account__c);
                dealRegNewPartnerMap.put(record.Id, record.Partner_Account__c);
            }
            
            //Update the deal reg with appropriate GEO VP based on the Deal Reg Geo
            /*if (null != record.GEO__c
&& record.GEO__c != oldMap.get(record.Id).GEO__c) {
if (dealRegToUpdateList.containsKey(record.Id)) {
dealRegToUpdateList.get(record.Id).GEO_VP__c = geoLeadersMap.get(record.GEO__c);
} else {
dealRegToUpdateList.put(record.Id, new deal_Reg__c(
Id = record.Id, 
GEO_VP__c = geoLeadersMap.get(record.GEO__c)
));
}
}*/
        }
        if(!System.isFuture() && !dealIdSet.isEmpty() && !system.isBatch())
        {
            changeDealRegOwner(dealIdSet);
        }
        
        //Query the deal reg opportunities which are still open for 2 weeks and prepare the list of deal reg to be auto-approved
        Map<Id, List<Id>> dealRegOpportunitiesMap = new Map<Id, List<Id>>();
        Map<Id, List<Id>> dealRegistrationsMap = new Map<Id, List<Id>>();
        
        for (Opportunity dealRegOppty : [SELECT Id, Account.Domain__c, CreatedDate, Deal_Reg__c, isClosed FROM Opportunity 
                                         WHERE isClosed = False 
                                         AND Account.Domain__c IN :smbDealRegDomainMap.keySet()]) 
        {
            //Commenting this date check condition as all the open opportunities have to be considered
            //Integer dateDiff = dealRegOppty.CreatedDate.Date().daysBetween(smbdealRegMap.get(smbDealRegDomainMap.get(dealRegOppty.Account.Domain__c)).CreatedDate.Date());
            //if (dateDiff < 14) {
            if (dealRegOpportunitiesMap.containsKey(smbDealRegDomainMap.get(dealRegOppty.Account.Domain__c))) {
                dealRegOpportunitiesMap.get(smbDealRegDomainMap.get(dealRegOppty.Account.Domain__c)).add(dealRegOppty.Id);
            } else {
                List<Id> matchingOpptyList = new List<Id>();
                matchingOpptyList.add(dealRegOppty.Id);
                dealRegOpportunitiesMap.put(smbDealRegDomainMap.get(dealRegOppty.Account.Domain__c), matchingOpptyList);
            }
            //}
        }
        
        for (Deal_Reg__c dealRegObj : [SELECT Id, End_Customer_Domain__c FROM Deal_Reg__c 
                                       WHERE End_Customer_Domain__c IN :smbDealRegDomainMap.keySet() 
                                       AND Id NOT IN :smbDealRegDomainMap.values()])
        {
            if (dealRegistrationsMap.containsKey(smbDealRegDomainMap.get(dealRegObj.End_Customer_Domain__c))) {
                dealRegistrationsMap.get(smbDealRegDomainMap.get(dealRegObj.End_Customer_Domain__c)).add(dealRegObj.Id);
            } else {
                List<Id> matchingDealRegList = new List<Id>();
                matchingDealRegList.add(dealRegObj.Id);
                dealRegistrationsMap.put(smbDealRegDomainMap.get(dealRegObj.End_Customer_Domain__c), matchingDealRegList);
            }
        }
        
        for (Deal_Reg__c dealRegObj : [SELECT Id FROM Deal_Reg__c WHERE Id IN :smbDealRegDomainMap.values()]) {
            //If the end customer has any other deal registrations or any open opportunities whose created date is less than 2 weeks
            if ((dealRegOpportunitiesMap.isEmpty() || null == dealRegOpportunitiesMap.get(dealRegObj.Id) || dealRegOpportunitiesMap.get(dealRegObj.Id).isEmpty())
                && (dealRegistrationsMap.isEmpty() || null == dealRegistrationsMap.get(dealRegObj.Id) || dealRegistrationsMap.get(dealRegObj.Id).isEmpty())) {
                    dealRegToUpdateList.put(dealRegObj.Id, new Deal_Reg__c(Id = dealRegObj.Id,
                                                                           Approval_Status__c = 'Auto-approved',
                                                                           Status__c = 'Approved'
                                                                          ));
                } else {
                    Approval.ProcessSubmitRequest newApprovalRequest = new Approval.ProcessSubmitRequest();
                    newApprovalRequest.setComments('Submit for Manager\'s approval');
                    newApprovalRequest.setObjectId(dealRegObj.Id);
                    newApprovalRequest.setSubmitterId(sfAdminUser);
                    approvalProcessRequestList.add(newApprovalRequest);
                }
        }
        
        /**
* Commenting out this block due to requirement change.
* New Requirements:
* - GEO VP will now be just notified through Workflow
* - Sales team's rejection will be the final rejection
*/
        //Map<Id, ProcessInstance> mapProcessInstances = new Map<Id, ProcessInstance>([SELECT Id, ProcessDefinitionId, ProcessDefinition.Name, TargetObjectId, Status 
        //                                               FROM ProcessInstance 
        //                                              WHERE Status IN ('Pending') 
        //                                                AND TargetObjectId IN :dealRegIdsToRecallApproval 
        //                                                AND ProcessDefinitionId IN (
        //                                                    SELECT Id FROM ProcessDefinition 
        //                                                     WHERE Name IN ('CHANNEL Deal Reg Approval Process', 'EMEA Geo Deal Reg Approval Process',
        //                                                     'APAC Geo Deal Reg Approval Process', 'AMERICAS Geo Deal Reg Approval Process') 
        //                                                AND State = 'Active')]);
        
        //for (ProcessInstanceWorkItem workItem : [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstanceId 
        //                                          FROM ProcessInstanceWorkItem 
        //                                         WHERE ProcessInstanceId IN :mapProcessInstances.keySet()]) {
        //    Approval.ProcessWorkItemRequest pwir = new Approval.ProcessWorkitemRequest();
        //    pwir.setWorkItemId(workItem.Id);
        //    pwir.setComments('AUTO: Recalling this approval request as the 3 days SLA has been breached.');
        //    pwir.setAction('Removed');
        
        //    Approval.process(pwir);
        //}
        
        //Update the account owner's email id
        Set<String> partnerTypeSet = new set<string>();
        partnerTypeSet.add('Partner-SP');
        partnerTypeSet.add('Partner-Reseller');
        partnerTypeSet.add('Partner-Distributor');
        partnerTypeSet.add('Partner-Integrator');
        partnerTypeSet.add('Partner-DC-BW');
        partnerTypeSet.add('Global SP/SI Partner');
        partnerTypeSet.add('Technology Partner');
        
        Map<String, String> partnerAccountOwnerMap = new Map<String, String>();
        Map<String, String> partnerAccountSEEmailMap = new Map<String, String>();
        Map<String, String> userEmailMap = new Map<String, String>();
        Map<String, String> EmailUserMap = new Map<String, String>();
        
        //CR# 1039
        //for(Account acc : [Select ID, Domain__c, OwnerId, Sales_Engineer__r.Email, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.OwnerId, Ultimate_Parent_Account__r.Sales_Engineer__r.Email from Account Where Id IN :dealRegNewPartnerMap.values() AND Partner_Type__c IN: partnerTypeSet ] ){
        for(Account acc : [Select ID, Domain__c, OwnerId, Sales_Engineer__r.Email, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.OwnerId, Ultimate_Parent_Account__r.Sales_Engineer__r.Email from Account Where Id IN :dealRegNewPartnerMap.values()] ){
            if(acc.Ultimate_Parent_Account__c != null) {
                partnerAccountOwnerMap.put(acc.Ultimate_Parent_Account__c, acc.Ultimate_Parent_Account__r.OwnerId);
                partnerAccountSEEmailMap.put(acc.Ultimate_Parent_Account__c, acc.Ultimate_Parent_Account__r.Sales_Engineer__r.Email);
            }
            else {
                partnerAccountOwnerMap.put(acc.Id, acc.OwnerId);
                partnerAccountSEEmailMap.put(acc.Id, acc.Sales_Engineer__r.Email);
            }
        }
        
        for (User userInfo : [SELECT Id, Email FROM User WHERE Id IN :partnerAccountOwnerMap.values()]) {
            userEmailMap.put(userInfo.Id, userInfo.Email);
            EmailUserMap.put(userInfo.Email,Userinfo.id);
        }
        
        for (Id dealRegId : dealRegNewPartnerMap.keySet()) {
            if (dealRegToUpdateList.containsKey(dealRegId)) {
                Deal_Reg__c dealRegObj = dealRegToUpdateList.get(dealRegId);
                dealRegObj.Partner_Account_Owner_Email__c = userEmailMap.get(partnerAccountOwnerMap.get(dealRegNewPartnerMap.get(dealRegId)));
                dealRegObj.Partner_Account_Owner__c = partnerAccountOwnerMap.get(dealRegNewPartnerMap.get(dealRegId));
                dealRegObj.Partner_Account_SE_Email__c = partnerAccountSEEmailMap.get(dealRegNewPartnerMap.get(dealRegId));
            } else {
                dealRegToUpdateList.put(dealRegId, new Deal_Reg__c(
                    Id = dealRegId,
                    Partner_Account_Owner_Email__c = userEmailMap.get(partnerAccountOwnerMap.get(dealRegNewPartnerMap.get(dealRegId))),
                    Partner_Account_Owner__c= partnerAccountOwnerMap.get(dealRegNewPartnerMap.get(dealRegId)),
                    Partner_Account_SE_Email__c = partnerAccountSEEmailMap.get(dealRegNewPartnerMap.get(dealRegId))
                ));
            }
        }
        //update dealRegToUpdateList.values();
        try {
            update dealRegToUpdateList.values();
        } catch (Exception ex) {
            System.debug('Exception: ' + ex.getMessage() + '; \r\n' + ex.getStackTraceString());
        }
        
        //Submit the escalated deal reg records to Geo Leader for review
        if (approvalProcessRequestList.size() > 0) {
            try {
                for (Approval.ProcessSubmitRequest processRequest : approvalProcessRequestList) {
                    Approval.ProcessResult result = Approval.process(processRequest);
                }
            } catch (Exception ex) {
                System.debug('Exception: ' + ex.getMessage() + '; \r\n' + ex.getStackTraceString());
            }
        }
        
        //Added by Varun for CR# 2555 - Start  
        Map<Id,List<String>> dealRegMapWithEmails  = new Map<Id,List<String>>();
        Map<Id,Set<Id>> dealRegMapWithIds  = new Map<Id,Set<Id>>();
        Set<Id> userIdsAll = new Set<Id>();
        for(Deal_Reg__c record: dealRegIdWithObjectMap.values()){
            Set<Id> userIds = new Set<Id>();
            
            IF(record.Channel_Manager__c!=null){
                userIds.add(record.Channel_Manager__c);
                userIdsAll.add(record.Channel_Manager__c);
            }
            IF(record.Channel_Manager_2__c!=null){
                userIds.add(record.Channel_Manager_2__c);
                userIdsAll.add(record.Channel_Manager_2__c);
            }
            IF(record.Channel_Manager_3__c!=null){
                userIds.add(record.Channel_Manager_3__c);
                userIdsAll.add(record.Channel_Manager_3__c);
            }IF(record.Channel_Manager_4__c!=null){
                userIds.add(record.Channel_Manager_4__c);
                userIdsAll.add(record.Channel_Manager_4__c);
            }
            IF(record.Regional_Alliance_Manager_5__c!=null){
                userIds.add(record.Regional_Alliance_Manager_5__c);
                userIdsAll.add(record.Regional_Alliance_Manager_5__c);
            }
            IF(record.Partner_Account_Owner__c!=null){
                userIds.add(record.Partner_Account_Owner__c);
                userIdsAll.add(record.Partner_Account_Owner__c);
            }
            //CR#3360 Start 
            IF(record.Distributor_Account_Owner__c!=null){
                userIds.add(record.Distributor_Account_Owner__c);
                userIdsAll.add(record.Distributor_Account_Owner__c);
            }
            //CR#3360 End
            dealRegMapWithIds.put(record.id, userIds);
            
        }
        List<String> sendTo = new List<String>();
        
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Email,Manager.Email FROM User where id in :userIdsAll]); 
        
        list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
        
        if(!dealRegMapWithIds.isEmpty()){
            List<EmailTemplate> emailTemplateList = [SELECT Id,Subject,HtmlVAlue FROM EmailTemplate where DeveloperName='Deal_Registration_Type_is_changed'];
            emailList.addall(getEmailMessages(dealRegMapWithIds,userMap, emailTemplateList[0].id));
        } 
        if(emailList.size()>0){
            try{
                Messaging.sendEmail(emailList);
            }catch(Exception e){}
        }
        //Added by Varun for CR# 2555 - End
        
        changeLeadContactStatus(oldMap,newList);
        TriggerUtility.dealRegAfterUpdateExecuted();
    }
    
    public static void changeLeadContactStatus(Map<Id, Deal_Reg__c> dealRegOldMap, list<Deal_Reg__c> dealRegNewList){
        map<Id, Deal_Reg__c> dealRegMap = new map<Id, Deal_Reg__c>();
        list<Lead> leadUpdateList = new list<Lead>();
        list<Contact> contactUpdateList = new list<Contact>();
        String LeadConversionStatus= ZscalerCustomSetting__c.getInstance('LeadConversionStatus')!=null && ZscalerCustomSetting__c.getInstance('LeadConversionStatus').Value__c!=null ? ZscalerCustomSetting__c.getInstance('LeadConversionStatus').Value__c:'Actively Engaged';
        for(Deal_Reg__c deal : [Select Id, Lead__c, Contact__c, Lead__r.Status, Contact__r.Contact_Lead_Status__c from Deal_Reg__c where ID IN: dealRegOldMap.keySet()]){
            dealRegMap.put(deal.Id, deal);
        }
        //Added by Gurjinder : CR#163 :Replace VO with Actively Engaged at line 617,619
        for(Deal_Reg__c deal : dealRegNewList){
            if(deal.Status__c == 'Approved' && deal.Status__c != dealRegOldMap.get(deal.Id).Status__c){
                if(deal.Lead__c != null && dealRegMap.get(deal.Id).Lead__r.Status != 'Marketing Qualified: Sales Accepted' && dealRegMap.get(deal.Id).Lead__r.Status != 'Actively Engaged' && dealRegMap.get(deal.Id).Lead__r.Status != 'Actively Engaged')
                    leadUpdateList.add(new lead(Id = deal.Lead__c, Status = 'Marketing Qualified: Sales Accepted'));
                if(deal.Contact__c != null && dealRegMap.get(deal.Id).Contact__r.Contact_Lead_Status__c != 'Marketing Qualified: Sales Accepted' && dealRegMap.get(deal.Id).Contact__r.Contact_Lead_Status__c != 'Actively Engaged' && dealRegMap.get(deal.Id).Contact__r.Contact_Lead_Status__c != 'Actively Engaged' && dealRegMap.get(deal.Id).Contact__r.Contact_Lead_Status__c != 'Actively Engaged')
                    contactUpdateList.add(new Contact(Id = deal.Contact__c, Contact_Lead_Status__c = 'Marketing Qualified: Sales Accepted'));
            }
        }
        try{
            if(!leadUpdateList.isEmpty())
                database.Update(leadUpdateList, false);
            if(!contactUpdateList.isEmpty())
                database.update(contactUpdateList,false);
        }catch(Exception e){}
    }
    
    public static void capturePriorStatus(Map<Id, Deal_Reg__c> oldMap, List<Deal_Reg__c> newList){
        List<Id> drlsttoProcess = new List<Id>();
        for(Deal_Reg__c dr: newList){
            if(oldMap != null && dr.Status__c != oldMap.get(dr.Id).Status__c){
                dr.Prior_Status__c = oldMap.get(dr.Id).Status__c;
            }
        }
        TriggerUtility.DRPriorStatusCaptureExecuted();
    }
    
    public static void convertPendingNBMtoConverted(Map<Id, Deal_Reg__c> oldMap, List<Deal_Reg__c> newList){
        List<Id> drlsttoProcess = new List<Id>();
        for(Deal_Reg__c dr: newList){
            if(oldMap != null && dr.NBM_Meeting_Date__c != null && dr.NBM_Meeting_Date__c != oldMap.get(dr.Id).NBM_Meeting_Date__c && dr.Status__c == Label.DR_Pending_NBM){
                dr.Status__c = dr.Prior_Status__c;
            }
        }
        TriggerUtility.DRPendingNBMConvertedExecuted();
    }
    
    public static void drStatusChangedFromConvertedDirectly(Map<Id, Deal_Reg__c> oldMap, List<Deal_Reg__c> newList){
        List<Id> drlsttoProcess = new List<Id>();
        for(Deal_Reg__c dr: newList){
            if(oldMap != null && !String.isEmpty(dr.partner_type__c) &&  dr.partner_type__c== 'Technology Partner' && dr.Status__c != oldMap.get(dr.Id).Status__c && oldMap.get(dr.Id).Status__c=='Converted'){
                dr.addError('Deal Reg Type cannot be modified once converted for Tech Partners. It has to go through approval for Expiration.' );            }
        }
    }
    
    public static void changeStatusonExpiryExtension(Map<Id, Deal_Reg__c> oldMap, List<Deal_Reg__c> newList){
        List<Id> drlsttoProcess = new List<Id>();
        for(Deal_Reg__c dr: newList){
            if(oldMap != null && dr.Deal_Reg_Expiration_Date__c != oldMap.get(dr.Id).Deal_Reg_Expiration_Date__c && (dr.Status__c == Label.DR_Pending_NBM || dr.Status__c == Label.DR_Pending_Conversion)){
                dr.Status__c = dr.Prior_Status__c;
            }
        }
        TriggerUtility.DRCopyPriorStatusonExpExtensionExecuted();
    }
    
    public static void removeDRfromOpp(Map<Id, Deal_Reg__c> oldMap, List<Deal_Reg__c> newList){
        set<Id> drlsttoProcess = new set<Id>();
        for(Deal_Reg__c dr: newList){
            if(oldMap != null && dr.Status__c != oldMap.get(dr.Id).Status__c && (dr.Status__c == Label.DR_Pending_Expiration || dr.Status__c == Label.DR_Expired)){
                drlsttoProcess.add(dr.Id);  
            }
        }
        List<Opportunity> opplst = new list<Opportunity>();
        for(Opportunity opp: [Select Id, Deal_Reg__c,/* Deal_Reg_Teaming_Tech_Partner__c,*/ Deal_Reg_Teaming_Reseller__c, Deal_Reg_Partner_Teaming_Reseller__c, /*Deal_Reg_Partner_Teaming_Tech_Partner__c,*/ Deal_Reg_Margin__c from Opportunity where (Deal_Reg__c in  :drlsttoProcess or Deal_Reg_Teaming_Reseller__c = :drlsttoProcess /*or Deal_Reg_Teaming_Tech_Partner__c = :drlsttoProcess*/) and StageName not in (:Label.Stage_6_Closed_Won, :Label.Stage_5A_Opportunity, :Label.Stage_5B_Opportunity, :Label.Stage_5C_Opportunity)]){
            if(opp.Deal_Reg__c != null && drlsttoProcess.contains(opp.Deal_Reg__c)){
                opp.Deal_Reg__c = null;
                opp.Deal_Reg_Margin__c = null;
            }
            /*if(opp.Deal_Reg_Teaming_Tech_Partner__c != null && drlsttoProcess.contains(opp.Deal_Reg_Teaming_Tech_Partner__c)){
                opp.Deal_Reg_Partner_Teaming_Tech_Partner__c = null;
                opp.Deal_Reg_Teaming_Tech_Partner__c = null;
            }*/
            if(opp.Deal_Reg_Teaming_Reseller__c != null && drlsttoProcess.contains(opp.Deal_Reg_Teaming_Reseller__c)){
                opp.Deal_Reg_Partner_Teaming_Reseller__c = null;
                opp.Deal_Reg_Teaming_Reseller__c = null;
            }
            opplst.add(opp);
        }
        
        Database.update(opplst, false);
        TriggerUtility.DRRemovalfromOppExecuted();
    }
    
    public static void RejectDRinApproval(Map<Id, Deal_Reg__c> oldMap, List<Deal_Reg__c> newList){
        List<Id> drlsttoProcess = new List<Id>();
        system.debug('inside RejectDRinApproval method');
        for(Deal_Reg__c dr: newList){
            //Changes Added by Gurjinder : CR# 3627 :Start
            /* if(oldMap != null && dr.Status__c != oldMap.get(dr.Id).Status__c && dr.Status__c == Label.DR_Rejected && oldmap.get(dr.Id).status__c == Label.DR_Pending_Final_Review){
system.debug('inside first if');
drlsttoProcess.add(dr.Id);
} */
            if(oldMap != null && dr.Status__c != oldMap.get(dr.Id).Status__c && dr.Status__c == Label.DR_Expired && oldmap.get(dr.Id).status__c == Label.DR_Pending_Final_Review){
                system.debug('inside second if');
                drlsttoProcess.add(dr.Id);
            }
            //Changes Added by Gurjinder : CR# 3627 : End
        }
        system.debug('drlsttoProcess '+drlsttoProcess);
        if(!drlsttoProcess.isEmpty()){
            genericApprovalActionController.approveRejectRecord('Removed', Label.DR_Final_Review_Approval_Rejection_Reason, drlsttoProcess);
        }
        TriggerUtility.DRRejectApprovalExecuted();
    }
    
    public static void submitDRforFinalReview(Map<Id, Deal_Reg__c> oldMap, List<Deal_Reg__c> newList){
        String SalesOpsSystemAdminUser= ZscalerCustomSetting__c.getInstance('SalesOpsSystemAdminUserID')!=null && ZscalerCustomSetting__c.getInstance('SalesOpsSystemAdminUserID').Value__c!=null ? ZscalerCustomSetting__c.getInstance('SalesOpsSystemAdminUserID').Value__c:'00570000002GeGO';
        id sfAdminUser=id.valueof(SalesOpsSystemAdminUser);
        List<Id> drlsttoProcess = new List<Id>();
        List<genericApprovalActionController.SubmitRecordWrapper> reqList = new List<genericApprovalActionController.SubmitRecordWrapper>();
        for(Deal_Reg__c dr: newList){
            if(oldMap != null && dr.Status__c != oldMap.get(dr.Id).Status__c && dr.Status__c == Label.DR_Pending_Final_Review){
                drlsttoProcess.add(dr.Id);
                genericApprovalActionController.SubmitRecordWrapper ctrl = new genericApprovalActionController.SubmitRecordWrapper();
                ctrl.comment = Label.DR_Final_Review_Approval_Submission_Reason;
                ctrl.recordId = dr.Id;
                ctrl.skipEntryCriteria = false;
                ctrl.submitterId = sfAdminUser;
                reqList.add(ctrl);
            }
        }
        if(!drlsttoProcess.isEmpty()){
            genericApprovalActionController.approveRejectRecord('Reject', Label.DR_Initial_Approval_Rejection_Reason, drlsttoProcess);  
            genericApprovalActionController.submitRecord(reqList);  
            TriggerUtility.DRFinalReviewExecuted();
        }
        
    }
//IBA-3278 Rajat J -- START
 public static void checkRejectionReasonValidation(Map<Id, Deal_Reg__c> oldMap, List<Deal_Reg__c> newList, String SessionId){
    List<Deal_Reg__c> drtoUpdate = new List<Deal_Reg__c>();
    System.debug('inside checkRejectionReasonValidation');
    for(Deal_Reg__c dr : newList){

        if((dr.Status__c == Label.DR_Pending_Final_Review && dr.Status__c != oldMap.get(dr.Id).Status__c && dr.Time_Submitted_for_Approval__c > Datetime.now().addDays(-7) && dr.Rejection_Reason__c == null) || (dr.Status__c == Label.DR_Rejected && dr.Status__c != oldMap.get(dr.Id).Status__c && dr.Rejection_Reason__c == null)){
            System.debug('inside checkRejectionReasonValidation33');
                if(SessionId != null){
                dr.addError(Label.Deal_Reg_Rejection_Reason_Mandatory);
            }else{
                dr.Rejection_Reason__c = 'Rejected over Email';
                
            }
        }
           
        }
        Database.update(drtoUpdate);
    }
    //IBA-3278 Rajat J -- END

    //Added by Ayush Kangar as part of CR#2952 - Start
    //Modified by Swathi as part of CR# 4691 - Start
    public static void DealRegPartnerDeailsAutoFill(List<Deal_Reg__c> newList) {
        List<Id> partnerContactIdSet = new List<Id>();
        Map<String, Deal_Reg__c> partnerContactEmailMap = new Map<String, Deal_Reg__c>();
        for(Deal_Reg__c d : newList){
            partnerContactIdSet.add(d.Partner_Contact__c);
            if(d.Partner_Type__c == 'Technology Partner' && d.Partner_Contact_Email__c!=Null)
                partnerContactEmailMap.put(d.Partner_Contact_Email__c.toLowerCase(),d);
        }
        System.debug('partnerContactIdSet===='+partnerContactIdSet);
        System.debug('partnerContactEmailMap===='+partnerContactEmailMap);
        System.debug('newList===='+newList);
        Map<Id, Contact> Con = new Map<Id, Contact>();
        Map<String, Contact> ConEmail = new Map<String, Contact>();
        for(Contact cont : [Select Id, FirstName,LastName,Email from Contact where Id in :partnerContactIdSet or Email in:partnerContactEmailMap.keySet() ]){
            if(!partnerContactIdSet.isEmpty())
                Con.put(cont.Id,cont);
            if(!partnerContactEmailMap.isEmpty() && partnerContactEmailMap.containsKey(cont.Email))
                ConEmail.put(cont.Email,cont);
        }
        if(ConEmail.isEmpty() && !partnerContactEmailMap.isEmpty()){
            List<Contact> contactList = new List<Contact>();
            for(Deal_Reg__c DealReg : partnerContactEmailMap.Values()){
                Contact conrecord = new Contact();
                conrecord.FirstName = partnerContactEmailMap.get((DealReg.Partner_Contact_Email__c).toLowerCase()).Partner_Contact_Name__c;
                conrecord.LastName = partnerContactEmailMap.get((DealReg.Partner_Contact_Email__c).toLowerCase()).Partner_Contact_Last_Name__c;
                conrecord.Email = partnerContactEmailMap.get((DealReg.Partner_Contact_Email__c).toLowerCase()).Partner_Contact_Email__c;
                conrecord.AccountId = partnerContactEmailMap.get((DealReg.Partner_Contact_Email__c).toLowerCase()).Partner_Account__c;
                conrecord.LeadSource = 'Impartner';
                contactList.add(conrecord);
                ConEmail.put(conrecord.Email,conrecord);
                System.debug('ConEmail' + ConEmail);
            }
            if(!contactList.isEmpty())
                insert contactList;  
        }
        if((!partnerContactIdSet.isEmpty() && !Con.isEmpty()) || (!partnerContactEmailMap.isEmpty() && !ConEmail.isEmpty())){
            System.debug('Con==='+con);
            for (Deal_Reg__c d : newList) {
                if(d.Partner_Type__c == 'Technology Partner'){
                    If(d.Partner_Contact_Email__c!=null && ConEmail.containsKey((d.Partner_Contact_Email__c).toLowerCase())){
                        d.Partner_Contact_Name__c = ConEmail.get((d.Partner_Contact_Email__c).toLowerCase()).FirstName;
                        d.Partner_Contact_Last_Name__c = ConEmail.get((d.Partner_Contact_Email__c).toLowerCase()).LastName;
                        d.Partner_Contact_Email__c = ConEmail.get((d.Partner_Contact_Email__c).toLowerCase()).Email;
                        d.Partner_Contact__c = ConEmail.get((d.Partner_Contact_Email__c).toLowerCase()).Id;
                    }
                    else if (d.Partner_Contact__c!=null && Con.containsKey(d.Partner_Contact__c)){
                        d.Partner_Contact_Name__c = Con.get(d.Partner_Contact__c).FirstName;
                        d.Partner_Contact_Last_Name__c = Con.get(d.Partner_Contact__c).LastName;
                        d.Partner_Contact_Email__c = Con.get(d.Partner_Contact__c).Email;
                    }
                    else{
                        d.Partner_Contact_Name__c = null;
                        d.Partner_Contact_Last_Name__c = null;
                        d.Partner_Contact_Email__c = null;
                    }
                }
                else if(!partnerContactIdSet.isEmpty() && !Con.isEmpty()){
                    If(d.Partner_Contact__c!=null){
                        d.Partner_Contact_Name__c = Con.get(d.Partner_Contact__c).FirstName;
                        d.Partner_Contact_Last_Name__c = Con.get(d.Partner_Contact__c).LastName;
                        d.Partner_Contact_Email__c = Con.get(d.Partner_Contact__c).Email;
                    }else{
                        d.Partner_Contact_Name__c = null;
                        d.Partner_Contact_Last_Name__c = null;
                        d.Partner_Contact_Email__c = null;
                    }
                }
            }
        }  
    }
    //Modified by Swathi as part of CR# 4691 - End
    //Added by Ayush Kangar as part of CR#2952 - End
    
    //Added by Varun for CR# 2555 - Start
    private static List<Messaging.SingleEmailMessage> getEmailMessages(MAP<ID, Set<ID>>  dealRegMapWithIds, Map<Id, User> userMap, ID templateID){
        
        OrgWideEmailAddress owa  =  [select id, Address,IsAllowAllProfiles from OrgWideEmailAddress where Address = 'z-deal-registrations@zscaler.com'];
        
        list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
        
        for(Id dealRegId: dealRegMapWithIds.keyset()){
            if(dealRegMapWithIds.get(dealRegId) != null){
                //Fill CC List
                List<String> ccList = new List<String>();
                for(ID userid : dealRegMapWithIds.get(dealRegId)){
                    if(userMap.containskey(userid)){
                        ccList.add(userMap.get(userid).email);
                        ccList.add(userMap.get(userid).Manager.Email);
                    }
                }
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(templateID), Null, String.valueOf(dealRegId));
                
                mail.setToAddresses(ccList);
                mail.setOrgWideEmailAddressId(owa.Id);
                mail.setTreatBodiesAsTemplate(True);
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setsaveAsActivity(false);
                emailList.add(mail);
            }
        }  
        return emailList;
    }
    //Added by Varun for CR# 2555 - End
    
    public static  Map<String,String> mapEmailVsGeoTech {
        get {
            if(mapEmailVsGeoTech == null){
                mapEmailVsGeoTech = new Map<String,String>();
                for(Deal_Reg_Geo_Leader_Tech__mdt drgl : [SELECT Id,UserID__c,Email__c,Geo__c,Partner_TYpe__C  FROM Deal_Reg_Geo_Leader_Tech__mdt])
                {
                    mapEmailVsGeoTech.put(drgl.Geo__c, drgl.Email__c);
                }
            }
            return mapEmailVsGeoTech;
        }
        set;
    }   
}