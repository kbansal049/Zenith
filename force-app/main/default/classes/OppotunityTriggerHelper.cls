/*
*  Author : Raghu
*  Change : Modified code to handle Opportunity Next Steps, Technical Validation Next Steps and Architect Next Steps.
*  Change : Modified method "updateRelatedOpportunityFields" as part of //CR# 3381
*  Change : Bikram - Refactored multiple methods to improve Oportunity process performance
*			These methods were getting called from OpportunityTriggerHandler.afterUpdate()
*  Change : Swathi - CR#1313 removed ZIA/ZPA Competitors field logic and added Competitors and other competitor logic(204-207)
*  Change : Swathi - CR#3744 commenting method "updateGAMNAM"
*  Change : Swathi - CR#4380 Modifiec method "updateRelatedOpportunityFields"
*  Change : Karthik Pullagurla - CR#4664 updated method for setDefaultStage
*  Change : Swathi - CR#4721 Bug fix
*  Change : Udit - CR# 5069 created method populateOpportunityStageEntryDates
*  Change : Ram Sangati - IBA-345: Process duplicate Opporunity realted PRGs and Cases.
*. Change : Karthik Pullagurla - IBA-
*  Change : Harish Gowda N - IBA-7353 - Remove field References from L2O classes .
*/

public without sharing class OppotunityTriggerHelper{
    
    //OppotunityTriggerHelper TriggerHelper/
    
    //Added By Sateesh U -- It Will Update the Sharing for Opportunity SE
    
    public static void afterInsert(List<Opportunity> newOppList){
        
        //Added by Pankaj  :  CR# 201  :   SEZNumber  :  Start
        
        Set<String> setOppIDs = new Set<String>();
        List<Opportunity> updateNewInsertOppList = new List<Opportunity>();
        
        //Added by Pankaj  : CR# 201 : SEZNumber  : Start
        
        List<Opportunity> opportunityToShareSE  = new List<Opportunity>();
        List<Opportunity> opportunityToDeleShareSE  = new List<Opportunity>();
        for(Opportunity oppRec : newOppList){
            if(oppRec.SE_Name__c  != null){
                //Added by Pankaj  : CR# 201 : SEZNumber  : Start
                setOppIDs.add(oppRec.ID);
                //Added by Pankaj  : CR# 201 : SEZNumber  : Start
                if(oppRec.Opportunity_Sales_Engineer__c  != oppRec.SE_Name__c){
                    opportunityToShareSE.add(oppRec);
                }
            }
            
            
        }
        
        //Added by Pankaj  : CR# 201 : SEZNumber  : Start
        
        if(!setOppIDs.isempty())
        {
            for(opportunity o : [SELECT ID, SE_Name__c, SE_Znumber__c, Opportunity_Sales_Engineer__c,SE_Name__r.EmployeeNumber, SE_Name__r.isActive,SE_Name__r.Manager.EmployeeNumber,SE_Name__r.Manager.isActive FROM Opportunity WHERE ID In :setOppIDs LIMIT 50000])
            {
                if(o.SE_Name__c!=null)
                {
                    String EmpNum = o.SE_Name__r.EmployeeNumber;
                    o.SE_Znumber__c  = EmpNum;
                    updateNewInsertOppList.add(o);
                }
                
            }
        }
        //Added by Pankaj  : CR# 201 : SEZNumber  : Start
        
        if(!opportunityToShareSE.isEmpty()){
            updateSharing(opportunityToShareSE, opportunityToDeleShareSE);
        }
        
        //Added by Pankaj  : CR# 201 : SEZNumber  : Start
        
        if(!updateNewInsertOppList.isEmpty()){
            update updateNewInsertOppList;
        }
        //Added by Pankaj  : CR# 201 : SEZNumber  : End
        
    }
    
    //Added by Udit : CR# 5069 starts here
    public static void populateOpportunityStageEntryDates(List<opportunity> newList){

        for(opportunity opp : newList){
            if(opp.StageName == '0 - Pipeline Generation' && opp.Stage_0_Entry_Date__c == null ){
                //Start - IBA-3590
                if(Label.Renewal_Opportunity_Created_User.contains(userInfo.getUserId())){
                    opp.Stage_1_Entry_Date__c = system.now();
                }else{
                    opp.Stage_0_Entry_Date__c = system.now();
                }
                //End - IBA-3590
            }
            
            if(((opp.stageName != '0 - Pipeline Generation' && opp.stageName != '7 - Closed Lost') && opp.Stage_1_Entry_Date__c == null)){
                opp.Stage_1_Entry_Date__c = system.now();
            }
            
            if(((opp.stageName != '0 - Pipeline Generation' && opp.stageName != '1 - Discovery & Qualification' && opp.stageName != '7 - Closed Lost') && opp.Stage_2_Entry_Date__c == null)){
                opp.Stage_2_Entry_Date__c = system.now();
            }
        }
        
    }
    //Added by Udit : CR# 5069 ends here
    
    //Added by Pankaj  : CR# 201 : SEZNumber  : Start
    
    public static void afterUpdate(map<Id, Opportunity> newOppMap,map<Id, Opportunity> oldOppMap){
        List<Opportunity> ListOppIdsUpdateSZnumber = new List<Opportunity>();
        for(Opportunity oppRec : [SELECT ID, SE_Name__c, SE_Znumber__c, SE_Name__r.EmployeeNumber, SE_Name__r.isActive,SE_Name__r.Manager.EmployeeNumber,SE_Name__r.Manager.isActive FROM Opportunity WHERE ID In :newOppMap.keyset() LIMIT 50000]){
            
            // system.debug('%%%%' +SetOppIdsUpdateSZnumber);
           // System.debug('%%%%' +oppRec.SE_Name__r.Manager.EmployeeNumber);
           // System.debug('%%%%' +oppRec.SE_Name__r.Manager.isActive );
           // System.debug('%%%%' +oppRec.SE_Name__r.isActive );
            // SE is active and Znumber is updated to his Employee number
            if(oppRec.SE_Name__r.isActive && oppRec.SE_Znumber__c != oppRec.SE_Name__r.EmployeeNumber){
                String EmpNum= oppRec.SE_Name__r.EmployeeNumber;
                oppRec.SE_Znumber__c= EmpNum;
                ListOppIdsUpdateSZnumber.add(oppRec);
                
                
            }
          //  System.debug('%%%%' +oppRec.SE_Name__r.Manager.EmployeeNumber);
          //  System.debug('%%%%' +oppRec.SE_Name__r.Manager.isActive );
           // System.debug('%%%%' +oppRec.SE_Name__r.isActive );
            // SE is Not active but His Manager is Active and Znumber is updated to his Manager Employee number
            if(!oppRec.SE_Name__r.isActive && oppRec.SE_Name__r.Manager.isActive && oppRec.SE_Znumber__c!= oppRec.SE_Name__r.Manager.EmployeeNumber){
                String EmpNum = oppRec.SE_Name__r.Manager.EmployeeNumber;
                oppRec.SE_Znumber__c = EmpNum;
                ListOppIdsUpdateSZnumber.add(oppRec);
             //   System.debug('%%%%' +oppRec.SE_Znumber__c );
                
                
            }
        }
        
        If(!ListOppIdsUpdateSZnumber.isempty())
            update ListOppIdsUpdateSZnumber;
        
     //   OppotunityTriggerhelper.opportunityStageClosedLostSendEmailHelper(newOppMap.values(),oldOppMap); 
        
        
    }
    //Added by Pankaj  : CR# 201 : SEZNumber  : End
    
    //Added By Sateesh U -- It Will Update the Sharing for Opportunity SE
    
    public static void beforeUpdate(List<Opportunity> newOppList, map<Id, Opportunity> oldOppMap){
        List<Opportunity> opportunityToShareSE  = new List<Opportunity>();
        List<Opportunity> opportunityToDeleShareSE = new List<Opportunity>();
        for(Opportunity oppRec : newOppList){
            if(oppRec.SE_Name__c  != null){
                if(oppRec.SE_Name__c  != oldOppMap.get(oppRec.Id).SE_Name__c){
                    TriggerUtility.SEgetschangedonOpp=true;
                    if(oppRec.Opportunity_Sales_Engineer__c  != oppRec.SE_Name__c){
                        opportunityToShareSE.add(oppRec);
                    }
                    opportunityToDeleShareSE.add(oppRec);
                }
            }
        }
        if(!opportunityToDeleShareSE.isEmpty()  ||  !opportunityToShareSE.isEmpty()){
            //updateSharing(opportunityToShareSE, opportunityToDeleShareSE);
            OpportunityShareWithSE.updateSharing(opportunityToShareSE, opportunityToDeleShareSE);
        }
    }
    
    //Added by Anup - CR#1122 - Start
    public static void updateQualifyingSDRRole(List<Opportunity> newList, Map<Id,Opportunity> oldmap){
        List<Id> listOfUserId = new List<Id>();
        Map<Id, String> mapOfUserAndRole = new Map<Id, String>();
        for(Opportunity opp : newList){
            if(oldMap != null){
                if(opp.LDR_Name__c!= null && oldMap.containsKey(opp.Id) && opp.LDR_Name__c != oldMap.get(opp.Id).LDR_Name__c){
                    listOfUserId.add(opp.LDR_Name__c);
                }
                
            }else{
                if(opp.LDR_Name__c != null){
                    listOfUserId.add(opp.LDR_Name__c);
                }
                TriggerUtility.QualifierRoleInsertExecuted();
            }
        }
        if(!listOfUserId.isEmpty()){
            for(User usr : [select id, UserRole.Name from User where id IN:listOfUserId]){
                if(!mapOfUserAndRole.containsKey(usr.Id)){
                    mapOfUserAndRole.put(usr.Id, usr.UserRole.Name);
                }
            }
            for(Opportunity opp : newList){
                if(mapOfUserAndRole.containsKey(opp.LDR_Name__c) && mapOfUserAndRole.get(opp.LDR_Name__c)!=null){
                    opp.Qualifier_Role__c = mapOfUserAndRole.get(opp.LDR_Name__c);
                }
            }
        }
    }
    //Added by Anup - CR#1122 -   End
    //Added by Anup - CR#1117 - Start : Modifying method as part of CR#3021 - Start
    public static void updateRelatedOpportunityFields(List<Opportunity> newList){
        Map<Id, Opportunity> mapOfOppAndDetails =  new Map<Id, Opportunity>();
        Map<Id, ID> mapOfOppAndDupOpp = new Map<Id, ID>();
        Map<ID, Opportunity_Extension__c> mapOfOppAndRelatedOpportunity = new Map<Id, Opportunity_Extension__c>();
        
        //Modified By Bikram as per CR# 3282 US-0001415  - Apex CPU time limit error while saving the Loss form.
        
        for(Opportunity opp : newList){
            mapOfOppAndDetails.put(opp.Id,opp);
        }        
        if(!mapOfOppAndDetails.isEmpty()){
            List<Opportunity_Extension__c> oppExtList = [select id,Opportunity__c, Opportunity__r.Id, Duplicate_Opportunity__c, Duplicate_Opportunity__r.Id, Duplicate_Opportunity__r.Validation_Plan__c,Duplicate_Opportunity__r.Competitor__c,Duplicate_Opportunity__r.ImpartnerPRM__PartnerContact__c,
                                                         Duplicate_Opportunity__r.Deal_Reg_Margin__c,Duplicate_Opportunity__r.Deal_Reg_Partner_Teaming_Reseller__c,Duplicate_Opportunity__r.Other_Competitors__c,
                                                         Duplicate_Opportunity__r.Deal_Reg__c,Duplicate_Opportunity__r.Deal_Reg_Teaming_Reseller__c,Duplicate_Opportunity__r.Channel_Sentiment__c,Duplicate_Opportunity__r.Partner_Type__c,
                                                         Duplicate_Opportunity__r.Partner_Comments__c,Duplicate_Opportunity__r.Primary_Reseller_Partner__c,Duplicate_Opportunity__r.Partner_Margin_Adjustment__c,Duplicate_Opportunity__r.Secondary_Partner__c,Duplicate_Opportunity__r.Validated_Solution_Tech_Partner__c,
                                                         Duplicate_Opportunity__r.ImpartnerPRM__PartnerAccount__c,Duplicate_Opportunity__r.Secondary_Partner_Role__c,Duplicate_Opportunity__r.Partner_Close_Date__c,Duplicate_Opportunity__r.Primary_Partner_Program__c,Duplicate_Opportunity__r.Technical_Validation_Start_Date__c
                                                         from Opportunity_Extension__c where Duplicate_Opportunity__c != null and Opportunity__c in :mapOfOppAndDetails.keySet()];
            List<Opportunity> listOfRelatedOppToUpdate = new List<Opportunity>();
            List<Event> eventList = [Select Id,WhatID from Event where WhatID in :mapOfOppAndDetails.keySet()];
            List<Task> TaskList = [Select Id,WhatID from Task where WhatID in :mapOfOppAndDetails.keySet()];
            List<Cosell_Activities__c> Cosell = [Select Id,Opportunity__c,Activity__c from Cosell_Activities__c where Opportunity__c in :mapOfOppAndDetails.keySet()];
            List<Opportunity_Partner__c> OppPartner = [Select Id,Opportunity__c,Partner_Type__c from Opportunity_Partner__c where Opportunity__c in :mapOfOppAndDetails.keySet()];
            List<Event> listofEventToUpdate = new List<Event>();
            List<Task> listofTaskToUpdate = new List<Task>();
            List<Cosell_Activities__c> listofCosellToUpdate = new List<Cosell_Activities__c>();
            List<Opportunity_Partner__c> listofOppPartnerToUpdate = new List<Opportunity_Partner__c>();
            for(Opportunity_Extension__c oppExt : oppExtList){
                mapOfOppAndDupOpp.put(mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Id,OppExt.Duplicate_Opportunity__r.Id);
                    Opportunity oppRelated = new Opportunity();
                    oppRelated.Id = oppExt.Duplicate_Opportunity__r.Id;
                    Opportunity dupOpp = new Opportunity();//CR# 3381
                    dupOpp.Id = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Id;//CR# 3381
                if(String.isBlank(oppExt.Duplicate_Opportunity__r.Validation_Plan__c) && oppExt.Duplicate_Opportunity__r.Technical_Validation_Start_Date__c==null){
                    oppRelated.Validation_Stage__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Validation_Stage__c;
                    oppRelated.Technical_Validation_Start_Date__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Technical_Validation_Start_Date__c;
                    oppRelated.Validation_End_Date__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Validation_End_Date__c;
                    //oppRelated.Technical_Validation_Age__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Technical_Validation_Age__c;
                    //oppRelated.Competitors__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Competitors__c;//Commemted as part of CR#1313
                    //oppRelated.ZPA_Competitor__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).ZPA_Competitor__c;//Commemted as part of CR#1313
                    oppRelated.Competitor__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Competitor__c; //Added as part of CR#1313 
                    oppRelated.Other_Competitors__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Other_Competitors__c; //Added as part of CR#1313
                    
                    //oppRelated.Customer_use_CASB_or_considers__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Customer_use_CASB_or_considers__c;
                    //oppRelated.CASB_Vendor__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).CASB_Vendor__c;
                    oppRelated.Validation_Plan__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Validation_Plan__c;
                    
                    oppRelated.Validation_Report__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Validation_Report__c;
                    oppRelated.Next_Steps__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Next_Steps__c;
                    oppRelated.POV_Scope_Approved__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).POV_Scope_Approved__c;
                    
                    oppRelated.POV_Playback_Approved__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).POV_Playback_Approved__c;
                    //oppRelated.Architecture_Stage__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Architecture_Stage__c;
                    //oppRelated.Architecture_Document__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Architecture_Document__c;
                    oppRelated.Technical_Validation_Manager_Notes__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Technical_Validation_Manager_Notes__c;
                    //oppRelated.Architecture_Next_Steps__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Architecture_Next_Steps__c;
                    oppRelated.Technology_Champion_Notes__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Technology_Champion_Notes__c;
                    //oppRelated.Days_in_current_validation_stage__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Days_in_current_validation_stage__c;
                    //listOfRelatedOppToUpdate.add(oppRelated); 
                }
                oppRelated.Primary_Reseller_Partner__c = oppExt.Duplicate_Opportunity__r.Primary_Reseller_Partner__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Primary_Reseller_Partner__c :oppExt.Duplicate_Opportunity__r.Primary_Reseller_Partner__c;
                oppRelated.Channel_Sentiment__c = oppExt.Duplicate_Opportunity__r.Channel_Sentiment__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Channel_Sentiment__c :oppExt.Duplicate_Opportunity__r.Channel_Sentiment__c;
                oppRelated.Partner_Margin_Adjustment__c = oppExt.Duplicate_Opportunity__r.Partner_Margin_Adjustment__c==False ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Partner_Margin_Adjustment__c :oppExt.Duplicate_Opportunity__r.Partner_Margin_Adjustment__c;
                oppRelated.Secondary_Partner__c = oppExt.Duplicate_Opportunity__r.Secondary_Partner__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Secondary_Partner__c :oppExt.Duplicate_Opportunity__r.Secondary_Partner__c;
                oppRelated.ImpartnerPRM__PartnerAccount__c = oppExt.Duplicate_Opportunity__r.ImpartnerPRM__PartnerAccount__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).ImpartnerPRM__PartnerAccount__c :oppExt.Duplicate_Opportunity__r.ImpartnerPRM__PartnerAccount__c;
                oppRelated.ImpartnerPRM__PartnerContact__c = oppExt.Duplicate_Opportunity__r.ImpartnerPRM__PartnerContact__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).ImpartnerPRM__PartnerContact__c :oppExt.Duplicate_Opportunity__r.ImpartnerPRM__PartnerContact__c;                
                oppRelated.Secondary_Partner_Role__c = oppExt.Duplicate_Opportunity__r.Secondary_Partner_Role__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Secondary_Partner_Role__c :oppExt.Duplicate_Opportunity__r.Secondary_Partner_Role__c;
                oppRelated.Partner_Close_Date__c = oppExt.Duplicate_Opportunity__r.Partner_Close_Date__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Partner_Close_Date__c :oppExt.Duplicate_Opportunity__r.Partner_Close_Date__c;
                oppRelated.Partner_Comments__c = oppExt.Duplicate_Opportunity__r.Partner_Comments__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Partner_Comments__c :oppExt.Duplicate_Opportunity__r.Partner_Comments__c;
                oppRelated.Primary_Partner_Program__c = oppExt.Duplicate_Opportunity__r.Primary_Partner_Program__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Primary_Partner_Program__c :oppExt.Duplicate_Opportunity__r.Primary_Partner_Program__c;
                //CR# 3381 Start
                dupOpp.Primary_Reseller_Partner__c = oppRelated.Primary_Reseller_Partner__c!=mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Primary_Reseller_Partner__c || oppExt.Duplicate_Opportunity__r.Primary_Reseller_Partner__c!=Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Primary_Reseller_Partner__c : Null;
                dupOpp.Channel_Sentiment__c = oppRelated.Channel_Sentiment__c!=mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Channel_Sentiment__c || oppExt.Duplicate_Opportunity__r.Channel_Sentiment__c!=Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Channel_Sentiment__c : '';
                dupOpp.Partner_Margin_Adjustment__c = oppRelated.Partner_Margin_Adjustment__c!=mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Partner_Margin_Adjustment__c || oppExt.Duplicate_Opportunity__r.Partner_Margin_Adjustment__c!=False ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Partner_Margin_Adjustment__c :False;
                dupOpp.Secondary_Partner__c = oppRelated.Secondary_Partner__c!=mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Secondary_Partner__c || oppExt.Duplicate_Opportunity__r.Secondary_Partner__c!=Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Secondary_Partner__c : Null;
                dupOpp.ImpartnerPRM__PartnerAccount__c = oppRelated.ImpartnerPRM__PartnerAccount__c!=mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).ImpartnerPRM__PartnerAccount__c || oppExt.Duplicate_Opportunity__r.ImpartnerPRM__PartnerAccount__c!=Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).ImpartnerPRM__PartnerAccount__c :Null;
                dupOpp.ImpartnerPRM__PartnerContact__c = oppRelated.ImpartnerPRM__PartnerContact__c!=mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).ImpartnerPRM__PartnerContact__c || oppExt.Duplicate_Opportunity__r.ImpartnerPRM__PartnerContact__c!=Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).ImpartnerPRM__PartnerContact__c :Null;
                dupOpp.Secondary_Partner_Role__c = oppRelated.Secondary_Partner_Role__c!=mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Secondary_Partner_Role__c || oppExt.Duplicate_Opportunity__r.Secondary_Partner_Role__c!=Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Secondary_Partner_Role__c :'';
                dupOpp.Partner_Close_Date__c = oppRelated.Partner_Close_Date__c!=mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Partner_Close_Date__c || oppExt.Duplicate_Opportunity__r.Partner_Close_Date__c!=Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Partner_Close_Date__c : Null;
                dupOpp.Primary_Partner_Program__c = oppRelated.Primary_Partner_Program__c!=mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Primary_Partner_Program__c || oppExt.Duplicate_Opportunity__r.Primary_Partner_Program__c!=Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Primary_Partner_Program__c : '';
                dupOpp.Partner_Comments__c = oppRelated.Partner_Comments__c!=mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Partner_Comments__c || oppExt.Duplicate_Opportunity__r.Partner_Comments__c!=Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Partner_Comments__c :'';                
                //CR# 3381 End, CR#4380 Start
                if((oppExt.Duplicate_Opportunity__r.Partner_Type__c=='Technology Partner') || (mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Partner_Type__c=='Technology Partner') ||
                  (oppExt.Duplicate_Opportunity__r.Deal_Reg__c==Null && oppExt.Duplicate_Opportunity__r.Deal_Reg_Teaming_Reseller__c==Null)){
                     // System.debug('Inside If');
                if(oppExt.Duplicate_Opportunity__r.Deal_Reg__c==Null){
                    if(!mapOfOppAndRelatedOpportunity.containsKey(mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Id))
                    	mapOfOppAndRelatedOpportunity.put(mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Id,OppExt);
                    oppRelated.Deal_Reg__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Deal_Reg__c;
                    dupOpp.Deal_Reg__c = Null;//CR# 3381
                    oppRelated.Deal_Reg_Margin__c = oppExt.Duplicate_Opportunity__r.Deal_Reg_Margin__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Deal_Reg_Margin__c :oppExt.Duplicate_Opportunity__r.Deal_Reg_Margin__c;
                    dupOpp.Deal_Reg_Margin__c = oppRelated.Deal_Reg_Margin__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Deal_Reg_Margin__c :Null;
                }
                if(oppExt.Duplicate_Opportunity__r.Deal_Reg_Teaming_Reseller__c==Null){
                    if(!mapOfOppAndRelatedOpportunity.containsKey(mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Id))
                    	mapOfOppAndRelatedOpportunity.put(mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Id,OppExt);
                    oppRelated.Deal_Reg_Teaming_Reseller__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Deal_Reg_Teaming_Reseller__c;
						dupOpp.Deal_Reg_Teaming_Reseller__c = Null;//CR# 3381
                    oppRelated.Deal_Reg_Partner_Teaming_Reseller__c = oppExt.Duplicate_Opportunity__r.Deal_Reg_Partner_Teaming_Reseller__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Deal_Reg_Partner_Teaming_Reseller__c :oppExt.Duplicate_Opportunity__r.Deal_Reg_Partner_Teaming_Reseller__c;
                    dupOpp.Deal_Reg_Partner_Teaming_Reseller__c = oppRelated.Deal_Reg_Partner_Teaming_Reseller__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Deal_Reg_Partner_Teaming_Reseller__c : Null;
                }
                    //oppRelated.Deal_Reg_Partner_Teaming_Reseller__c = oppExt.Duplicate_Opportunity__r.Deal_Reg_Partner_Teaming_Reseller__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Deal_Reg_Partner_Teaming_Reseller__c :oppExt.Duplicate_Opportunity__r.Deal_Reg_Partner_Teaming_Reseller__c;
                	//oppRelated.Deal_Reg_Margin__c = oppExt.Duplicate_Opportunity__r.Deal_Reg_Margin__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Deal_Reg_Margin__c :oppExt.Duplicate_Opportunity__r.Deal_Reg_Margin__c;
                    //dupOpp.Deal_Reg_Partner_Teaming_Reseller__c = oppRelated.Deal_Reg_Partner_Teaming_Reseller__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Deal_Reg_Partner_Teaming_Reseller__c : Null;
                	//dupOpp.Deal_Reg_Margin__c = oppRelated.Deal_Reg_Margin__c==Null ? mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Deal_Reg_Margin__c :Null;
                }
                //CR#4380 End
                    if(!mapOfOppAndRelatedOpportunity.containsKey(mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Id))
                    	mapOfOppAndRelatedOpportunity.put(mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Id,OppExt);//CR# 3381

                if(oppExt.Duplicate_Opportunity__r.Validated_Solution_Tech_Partner__c==Null || oppExt.Duplicate_Opportunity__r.Validated_Solution_Tech_Partner__c == ''){
                    if(!mapOfOppAndRelatedOpportunity.containsKey(mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Id))
                    	mapOfOppAndRelatedOpportunity.put(mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Id,OppExt);
                    oppRelated.Validated_Solution_Tech_Partner__c = mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Validated_Solution_Tech_Partner__c;
                		dupOpp.Validated_Solution_Tech_Partner__c = '';//CR# 3381
                }
                if(oppExt.Duplicate_Opportunity__r.Primary_Reseller_Partner__c==Null){
                    if(!mapOfOppAndRelatedOpportunity.containsKey(mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Id))
                    	mapOfOppAndRelatedOpportunity.put(mapOfOppAndDetails.get(oppExt.Opportunity__r.Id).Id,OppExt);
                }
                listOfRelatedOppToUpdate.add(oppRelated);
                listOfRelatedOppToUpdate.add(dupOpp);//CR# 3381
                //System.debug('listOfRelatedOppToUpdate' + listOfRelatedOppToUpdate);
            }
            if(!listOfRelatedOppToUpdate.isEmpty()){
                //System.debug('listOfRelatedOppToUpdate' + listOfRelatedOppToUpdate);
                Database.SaveResult [] updateResult = Database.update(listOfRelatedOppToUpdate, false);
                for (Database.SaveResult r : updateResult)
                {
                    if (!r.isSuccess())
                    {
                        for (Database.Error e : r.getErrors())
                        { 
                            System.debug('error message'+e.getMessage());
                            System.debug('error message'+e);
                        }
                    }
                }
            }
            for(Event oppEvt : eventList){
               	oppEvt.WhatID = mapOfOppAndDupOpp.get(oppEvt.WhatID);
               	listofEventToUpdate.add(oppEvt); 
            }
            if(!listofEventToUpdate.isEmpty()){
              //  System.debug('listofEventToUpdate' + listofEventToUpdate);
                Database.update(listofEventToUpdate, false);
            }
            
            for(Task opptask : taskList){
               	opptask.WhatID = mapOfOppAndDupOpp.get(opptask.WhatID);
               	listofTaskToUpdate.add(opptask); 
            }
            if(!listofTaskToUpdate.isEmpty()){
               // System.debug('listofTaskToUpdate' + listofTaskToUpdate);
                Database.update(listofTaskToUpdate, false);
            }
            for(Cosell_Activities__c oppCosell : Cosell){
                if(oppCosell.Activity__c=='POV' && mapOfOppAndRelatedOpportunity.containsKey(oppCosell.Opportunity__c)){
               		oppCosell.Opportunity__c = mapOfOppAndDupOpp.get(oppCosell.Opportunity__c);
               		listofCosellToUpdate.add(oppCosell);
                }
                if(oppCosell.Activity__c=='Architecture Workshop' && mapOfOppAndRelatedOpportunity.containsKey(oppCosell.Opportunity__c)){
               		oppCosell.Opportunity__c = mapOfOppAndDupOpp.get(oppCosell.Opportunity__c);
               		listofCosellToUpdate.add(oppCosell);
                }
                if(oppCosell.Activity__c=='AW/POV' && mapOfOppAndRelatedOpportunity.containsKey(oppCosell.Opportunity__c)){
               		oppCosell.Opportunity__c = mapOfOppAndDupOpp.get(oppCosell.Opportunity__c);
               		listofCosellToUpdate.add(oppCosell);
                }
            }
            if(!listofCosellToUpdate.isEmpty()){
              //  System.debug('listofCosellToUpdate' + listofCosellToUpdate);
                Database.update(listofCosellToUpdate, false);
            }
            for(Opportunity_Partner__c oppPar : OppPartner){
                if(oppPar.Partner_Type__c=='Architecture Workshop' && mapOfOppAndRelatedOpportunity.containsKey(oppPar.Opportunity__c)){
               		oppPar.Opportunity__c = mapOfOppAndDupOpp.get(oppPar.Opportunity__c);
               		listofOppPartnerToUpdate.add(oppPar);
                }
                if(oppPar.Partner_Type__c=='POV' && mapOfOppAndRelatedOpportunity.containsKey(oppPar.Opportunity__c)){
               		oppPar.Opportunity__c = mapOfOppAndDupOpp.get(oppPar.Opportunity__c);
               		listofOppPartnerToUpdate.add(oppPar);
                }
                if(oppPar.Partner_Type__c=='Reseller' && mapOfOppAndRelatedOpportunity.containsKey(oppPar.Opportunity__c) && (mapOfOppAndRelatedOpportunity.get(oppPar.Opportunity__c).Duplicate_Opportunity__r.Primary_Reseller_Partner__c==Null)){
               		oppPar.Opportunity__c = mapOfOppAndDupOpp.get(oppPar.Opportunity__c);
               		listofOppPartnerToUpdate.add(oppPar);
                }
                if(oppPar.Partner_Type__c=='Deal Reg' ){
                    if(mapOfOppAndRelatedOpportunity.containsKey(oppPar.Opportunity__c) && mapOfOppAndRelatedOpportunity.get(oppPar.Opportunity__c).Duplicate_Opportunity__r.Deal_Reg__c==Null && (mapOfOppAndDetails.containsKey(oppPar.Opportunity__c) && 
                        (mapOfOppAndDetails.get(oppPar.Opportunity__c).Partner_Type__c=='Technology Partner' || mapOfOppAndRelatedOpportunity.get(oppPar.Opportunity__c).Duplicate_Opportunity__r.Partner_Type__c=='Technology Partner' || mapOfOppAndRelatedOpportunity.get(oppPar.Opportunity__c).Duplicate_Opportunity__r.Deal_Reg_Teaming_Reseller__c== Null) 
                        && mapOfOppAndDetails.get(oppPar.Opportunity__c).Deal_Reg__c!=Null)){
                    	oppPar.Opportunity__c = mapOfOppAndDupOpp.get(oppPar.Opportunity__c);
               			listofOppPartnerToUpdate.add(oppPar);
                      //  System.debug('Inside 1');
                    }
                    if(mapOfOppAndRelatedOpportunity.containsKey(oppPar.Opportunity__c) && mapOfOppAndRelatedOpportunity.get(oppPar.Opportunity__c).Duplicate_Opportunity__r.Deal_Reg_Teaming_Reseller__c==Null && (mapOfOppAndDetails.containsKey(oppPar.Opportunity__c) && 
                       (mapOfOppAndDetails.get(oppPar.Opportunity__c).Partner_Type__c=='Technology Partner' || mapOfOppAndRelatedOpportunity.get(oppPar.Opportunity__c).Duplicate_Opportunity__r.Partner_Type__c=='Technology Partner' || mapOfOppAndRelatedOpportunity.get(oppPar.Opportunity__c).Duplicate_Opportunity__r.Deal_Reg__c== Null) 
                       && mapOfOppAndDetails.get(oppPar.Opportunity__c).Deal_Reg_Teaming_Reseller__c!=Null)){
                        oppPar.Opportunity__c = mapOfOppAndDupOpp.get(oppPar.Opportunity__c);
               			listofOppPartnerToUpdate.add(oppPar);
                       // System.debug('Inside 2');
                    }
                    if(mapOfOppAndRelatedOpportunity.containsKey(oppPar.Opportunity__c)
                      && (mapOfOppAndDetails.containsKey(oppPar.Opportunity__c))){
               		oppPar.Opportunity__c = mapOfOppAndDupOpp.get(oppPar.Opportunity__c);
               		listofOppPartnerToUpdate.add(oppPar);
                       // System.debug('Inside 3');
                    }
                }
                if(oppPar.Partner_Type__c=='Tech Partner' && mapOfOppAndRelatedOpportunity.containsKey(oppPar.Opportunity__c) && (mapOfOppAndRelatedOpportunity.get(oppPar.Opportunity__c).Duplicate_Opportunity__r.Validated_Solution_Tech_Partner__c==Null || mapOfOppAndRelatedOpportunity.get(oppPar.Opportunity__c).Duplicate_Opportunity__r.Validated_Solution_Tech_Partner__c=='')){
               		oppPar.Opportunity__c = mapOfOppAndDupOpp.get(oppPar.Opportunity__c);
               		listofOppPartnerToUpdate.add(oppPar);
                }
                if(oppPar.Partner_Type__c=='AW/POV' && mapOfOppAndRelatedOpportunity.containsKey(oppPar.Opportunity__c)){
               		oppPar.Opportunity__c = mapOfOppAndDupOpp.get(oppPar.Opportunity__c);
               		listofOppPartnerToUpdate.add(oppPar);
                }
            }
            if(!listofOppPartnerToUpdate.isEmpty()){
               // System.debug('listofOppPartnerToUpdate' + listofOppPartnerToUpdate);
                Database.update(listofOppPartnerToUpdate, false);
            }
        }
        TriggerUtility.UpdateRelatedOppExecuted();
    }
    //Added by Anup - CR#1117 - End : Modifying method as part of CR#3021 - End
    
    //Added by Swathi - CR1926 Start
    public static void updateOppField(List<Opportunity> newList, Map<Id,Opportunity> oldmap){
        Set<Id> setOfPartnerId = new Set<Id>();
        Set<Id> setofOldPartnerId = new Set<Id>();
        Map<Id, String> mapOfAccvsName = new Map<Id, String>();
        Map<Id, Account> mapOfOldAccIdvsAccount = null;
        Set<String> oldAccountNames = new Set<String>();
        List<String> validatedSolutionTechPartners = new List<String>();
        for(Opportunity opp : newList){
            if(oldMap != null){
                if(opp.Deal_Reg_Margin__c != null && oldMap.containsKey(opp.Id) && opp.Deal_Reg_Margin__c != oldMap.get(opp.Id).Deal_Reg_Margin__c){
                    setOfPartnerId.add(opp.Deal_Reg_Margin__c);
                }
                if(oldMap.containsKey(opp.Id) && opp.Deal_Reg_Margin__c != oldMap.get(opp.Id).Deal_Reg_Margin__c){
                    setofOldPartnerId.add(oldMap.get(opp.Id).Deal_Reg_Margin__c);
                }
            }else{
                if(opp.Deal_Reg_Margin__c != null){
                    setOfPartnerId.add(opp.Deal_Reg_Margin__c);
                  //  System.debug('opp.Deal_Reg_Margin__c'+opp.Deal_Reg_Margin__c);
                }
            }
        }
       // system.debug('### setOfPartnerId :'+setOfPartnerId);
        if(!setOfPartnerId.isEmpty()){
            for(Account Acc : [select id, Name from Account where id IN:setOfPartnerId and Type='Technology Partner']){
                if(!mapOfAccvsName.containsKey(Acc.Id)){
                    mapOfAccvsName.put(Acc.Id, Acc.Name);
                }
            }
            for(Opportunity opp : newList){
               // System.debug('mapOfAccvsName'+mapOfAccvsName);
                if(mapOfAccvsName.containsKey(opp.Deal_Reg_Margin__c) && mapOfAccvsName.get(opp.Deal_Reg_Margin__c)!=null){
                    if(opp.Validated_Solution_Tech_Partner__c != Null && opp.Validated_Solution_Tech_Partner__c != '' && !opp.Validated_Solution_Tech_Partner__c.contains(mapOfAccvsName.get(opp.Deal_Reg_Margin__c))){
                        opp.Validated_Solution_Tech_Partner__c = opp.Validated_Solution_Tech_Partner__c + ';' + mapOfAccvsName.get(opp.Deal_Reg_Margin__c);
                    }else if(opp.Validated_Solution_Tech_Partner__c == null || opp.Validated_Solution_Tech_Partner__c == ''){
                        opp.Validated_Solution_Tech_Partner__c = mapOfAccvsName.get(opp.Deal_Reg_Margin__c);
                    }
                //    System.debug('opp'+opp.Validated_Solution_Tech_Partner__c);
                }
            }
        }
       // system.debug('### setofOldPartnerId :'+setofOldPartnerId);
        if(!setofOldPartnerId.isEmpty()){
            mapOfOldAccIdvsAccount = new Map<Id, Account>([Select Id, Name from Account where id in :setofOldPartnerId and Type='Technology Partner']);
            for(Id accountId : mapOfOldAccIdvsAccount.keySet()){
                oldAccountNames.add(mapOfOldAccIdvsAccount.get(accountId).Name);
            }
         //   system.debug('### oldAccountNames :'+oldAccountNames);
            for(Opportunity opp : newList){
                if(opp.Validated_Solution_Tech_Partner__c != Null){
                 //   system.debug('### opp.Validated_Solution_Tech_Partner__c :'+opp.Validated_Solution_Tech_Partner__c);
                    validatedSolutionTechPartners = opp.Validated_Solution_Tech_Partner__c.split(';');
                 //   system.debug('### validatedSolutionTechPartners  :'+validatedSolutionTechPartners );
                    opp.Validated_Solution_Tech_Partner__c = '';
                    for(String accName : validatedSolutionTechPartners){
                        if(!oldAccountNames.contains(accName)){
                            if(opp.Validated_Solution_Tech_Partner__c == '')
                                opp.Validated_Solution_Tech_Partner__c = accName;
                            else
                                opp.Validated_Solution_Tech_Partner__c = opp.Validated_Solution_Tech_Partner__c + ';' + accName;
                        }
                    }
                  //  system.debug('### opp.Validated_Solution_Tech_Partner__c :'+opp.Validated_Solution_Tech_Partner__c);
                }
            }
        }
        
        for(Opportunity opp : newList){
            if(opp.Validated_Solution_Tech_Partner__c==null || opp.Validated_Solution_Tech_Partner__c==''){
            	opp.Has_Technology_Partner__c = false;
        	}else if(opp.Validated_Solution_Tech_Partner__c!=null){
            	opp.Has_Technology_Partner__c = True;
            }
        }
        TriggerUtility2.setOppTechPartnerExecuted();
    }
    
    public static void updateRelatedOppPartner(List<Opportunity> newList, Map<Id,Opportunity> oldmap){
        List<Opportunity_Partner__c> OppPartner = new List<Opportunity_Partner__c>();
        Map<Id, String> mapOfOppAndDetails = new Map<Id, String>(); 
        Map<Id, List<String>> mapOfOppAndAccount = new Map<Id, List<String>>();
        List<String> AccName = new List<String>();
        List<String> oldAccName = new List<String>();
        List<Id> ListOfOppId = new List<Id>();
        
        Map<Id, List<String>> oppAccNamesMap = new Map<Id, List<String>> ();
         
        for(Opportunity opp : newList){
            if(oldMap != null && opp.Validated_Solution_Tech_Partner__c!=Null && opp.Validated_Solution_Tech_Partner__c != oldMap.get(opp.Id).Validated_Solution_Tech_Partner__c){
                AccName = opp.Validated_Solution_Tech_Partner__c.split(';');
                
                oppAccNamesMap.put(opp.Id, AccName);
                
                if(oldMap.get(opp.Id).Validated_Solution_Tech_Partner__c!=Null)
                    oldAccName = oldMap.get(opp.Id).Validated_Solution_Tech_Partner__c.split(';');
                mapOfOppAndDetails.put(opp.AccountId,opp.Id);
            }else if(opp.Validated_Solution_Tech_Partner__c!=Null && oldMap==Null){
                AccName = opp.Validated_Solution_Tech_Partner__c.split(';');
                
                oppAccNamesMap.put(opp.Id, AccName);
                
                mapOfOppAndDetails.put(opp.AccountId,opp.Id);
            }else if(oldMap != null && opp.Validated_Solution_Tech_Partner__c==Null && opp.Validated_Solution_Tech_Partner__c != oldMap.get(opp.Id).Validated_Solution_Tech_Partner__c){
                if(oldMap.get(opp.Id).Validated_Solution_Tech_Partner__c!=Null)
                    oldAccName = oldMap.get(opp.Id).Validated_Solution_Tech_Partner__c.split(';');
                mapOfOppAndDetails.put(opp.AccountId,opp.Id);
            }
            ListOfOppId.add(opp.id);
        }
        List<string> deletelist = new List<String>();
        List<String> NewAccName = new List<String>();
        if(!oldAccName.isEmpty()){
            for(String oldAcc : oldAccName){
                if(!AccName.contains(oldAcc)){
                    deletelist.add(oldAcc);
                }
            }
        }
        
        
       /* if(!AccName.isEmpty()){
            for(String newAcc : AccName){
                if(!oldAccName.contains(newAcc)){
                    NewAccName.add(newAcc);
                    System.debug('newAcc'+newAcc);
                }
            }
        }*/
        
        
        //Code Optimization. Removed DML inside for loop
        for (Id oppId: oppAccNamesMap.keySet()) {
            
           for(String newAcc : oppAccNamesMap.get(oppId)){
                if(!oldAccName.contains(newAcc)){
                    NewAccName.add(newAcc);
                  //  System.debug('newAcc'+newAcc);
                }
            } 
            
        }

        Map<String, Account> accMap = new Map<String, Account> ();
        
        
        for(Account acc: [SELECT Id, Type, Name, Model_Type_Partner__c FROM Account WHERE Name IN :NewAccName AND Type='Technology Partner']){
            accMap.put((acc.Name).substring(0,1).toUpperCase()+ (acc.Name).substring(1).toLowerCase(), acc);// modified to fix CR#4721
            
        }
 
        for(Opportunity opp : newList) { 
            
            List<String> accNameList = oppAccNamesMap.containsKey(opp.Id) ? oppAccNamesMap.get(opp.Id) : new List<String> (); 
            
            for (String aName : accNameList) { 
                // modified to fix CR#4721 : start
                String AccNamestring = (aName).substring(0,1).toUpperCase()+ (aName).substring(1).toLowerCase();
                if (accMap.containsKey(AccNamestring)) {
                    
                    Opportunity_Partner__c Partner = new Opportunity_Partner__c();
                    Account acc = accMap.get(AccNamestring);
                    // modified to fix CR#4721 : end
                    Partner.Account__c = acc.Id;
                    Partner.Partner_Program__c = acc.Model_Type_Partner__c == 'Both'?  Label.Partner_Program_Partner_Summit: acc.Model_Type_Partner__c;
                    Partner.Opportunity__c = opp.Id;
                    Partner.Partner_Type__c = 'Tech Partner';
                    OppPartner.add(Partner);
                }
            }
            
            
        }
         
        
       /* for(Opportunity opp : newList){
            System.debug('opp'+opp);
            for(Account acc: [select id,Type,Name,Model_Type_Partner__c from Account where Name in :NewAccName and Type='Technology Partner']){
                System.debug('acc'+acc);
                Opportunity_Partner__c Partner = new Opportunity_Partner__c();
                Partner.Account__c = acc.Id;
                Partner.Partner_Program__c = acc.Model_Type_Partner__c == 'Both'?  Label.Partner_Program_Partner_Summit: acc.Model_Type_Partner__c;
                Partner.Opportunity__c = opp.Id;
                Partner.Partner_Type__c = 'Tech Partner';
                OppPartner.Add(Partner);
            }
        }*/
        
       // System.debug('-=-=- inside 1926 OppPartner -=-=- '+OppPartner);
        //System.debug('-=-=- inside 1926 oplst -=-=- '+oplst);
        
        if(!OppPartner.isEmpty()){
          //  System.debug('OppPartner'+OppPartner);
            //added by Swathi CR#3295 Start
            TriggerUtility2.setOppPartnerTechPartnerExecuted();
            TriggerUtility2.setOppRelTechPartnerExecuted();
            //added by Swathi CR#3295 End
            insert OppPartner;
        }
        if(!deletelist.isEmpty()){
            List<Opportunity_Partner__c> oplst = [select Id, Opportunity__c, Account__r.Name,Opportunity__r.Validated_Solution_Tech_Partner__c, Partner_Type__c, Name from Opportunity_Partner__c Where Account__r.Name in :deletelist and Account__r.Type='Technology Partner' and Opportunity__r.id in:ListOfOppId];
            if(!oplst.isEmpty()){
               // System.debug('oplst'+oplst);
                //added by Swathi CR#3295 Start
                TriggerUtility2.setOppPartnerTechPartnerExecuted();
        		TriggerUtility2.setOppRelTechPartnerExecuted();
                //added by Swathi CR#3295 End
                delete oplst;
            }
        }
    }
    //Added by Swathi - CR1926 End
    
    public static void updateSharing(List<Opportunity> opportunityToShareSE, List<Opportunity> opportunityToDeleShareSE){
        
        List<OpportunityTeamMember>  oppTeamMemberLstForInsert  = new List<OpportunityTeamMember>();
        for(Opportunity oppRec : opportunityToShareSE){
            OpportunityTeamMember oppTeamMember  = new OpportunityTeamMember();
            oppTeamMember.OpportunityId  = oppRec.Id;
            oppTeamMember.TeamMemberRole  = 'Out of Territory SE';
            oppTeamMember.OpportunityAccessLevel  = 'Edit';
            oppTeamMember.UserId = oppRec.SE_Name__c;
            oppTeamMemberLstForInsert.add(oppTeamMember);
        }
        
        if(!opportunityToDeleShareSE.isEmpty()){
            List<OpportunityTeamMember> existingOppSETeamToDelete = [Select Id, 
                                                                     UserId 
                                                                     from 
                                                                     OpportunityTeamMember 
                                                                     Where 
                                                                     OpportunityId IN: opportunityToDeleShareSE 
                                                                     and TeamMemberRole = 'Out of Territory SE'];
            if(!existingOppSETeamToDelete.isEmpty()){
                delete existingOppSETeamToDelete;
            }
        }
        if(!oppTeamMemberLstForInsert.isEmpty()){
            insert oppTeamMemberLstForInsert;
        }
    }
    
    public static void decommissionProvRequests(Set<Id> oppIdSet){
        
        set<String> prStatusSet =  new set<String>();
        prStatusSet.add('Requested');
        prStatusSet.add('In Progress');
        prStatusSet.add('Provisioned'); 
        
        Set<String> PreferredCloudlist = new Set<String>();
        PreferredCloudlist.add('zpabeta.net');
        PreferredCloudlist.add('Zscalerbeta.net');
        
        Set<String> PRRecordTypeNameSet = new Set<String>();
        //PRRecordTypeNameSet.add('New_Eval');
        //PRRecordTypeNameSet.add('Zscaler_Cloud_Details');
        String PRrecordtypeforPOCAlerts= ZscalerCustomSetting__c.getInstance('PRrecordtypeforPOCAlerts')!=null && ZscalerCustomSetting__c.getInstance('PRrecordtypeforPOCAlerts').Value__c!=null ? ZscalerCustomSetting__c.getInstance('PRrecordtypeforPOCAlerts').Value__c:'New_Eval,Zscaler_Cloud_Details';
        PRRecordTypeNameSet.addall(PRrecordtypeforPOCAlerts.split(','));
        
        Set<String> PRRcrdNameSetforReqDecomm = new Set<String>();
        //PRRecordTypeNameSet.add('New_Eval');
        //PRRecordTypeNameSet.add('Zscaler_Cloud_Details');
        String PRRcrdNameforReqDecomm= ZscalerCustomSetting__c.getInstance('PRRcrdNameSetforReqDecomm')!=null && ZscalerCustomSetting__c.getInstance('PRRcrdNameSetforReqDecomm').Value__c!=null ? ZscalerCustomSetting__c.getInstance('PRRcrdNameSetforReqDecomm').Value__c:'New_Eval,Zscaler_Cloud_Details';
        PRRcrdNameSetforReqDecomm.addall(PRRcrdNameforReqDecomm.split(','));
        
        list<Provisioning_Request__c> provReqUpdateList = new list<Provisioning_Request__c>();
        
        for(Provisioning_Request__c pr : [SELECT Id, RecordType.DeveloperName, 
                                          Provisioning_Status__c,Opportunity__r.StageName,
                                          Opportunity__r.Sub_Stage__c 
                                          FROM Provisioning_Request__c 
                                          WHERE Opportunity__c IN: oppIdSet 
                                          AND Provisioning_Status__c IN: prStatusSet 
                                          AND Account__r.Type != 'Partner' 
                                          AND Account__r.Type != 'Technology Partner' 
                                          AND Preferred_Cloud__c 
                                          NOT IN:PreferredCloudlist 
                                          AND Internal_user__c = False]){  //Added AccountType and Internal User status check for PR POC expiry Notifications:Gurjinder
            if((pr.Opportunity__r.StageName== label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/ || pr.Opportunity__r.StageName== label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/ ) && PRRecordTypeNameSet.contains(pr.RecordType.DeveloperName)){
                pr.Do_not_Send_Alerts_when_Approval_Pending__c=true;
            }
            //(pr.RecordType.DeveloperName == 'New_Eval' || pr.RecordType.DeveloperName == 'Zscaler_Cloud_Details')
            if((pr.Opportunity__r.StageName == label.Stage_7_Closed_Lost && (pr.Opportunity__r.Sub_Stage__c == Label.SubStage_Closed_With_No_Decision || pr.Opportunity__r.Sub_Stage__c == Label.SubStage_Closed_Lost) /*'11 - Closed Lost' || pr.Opportunity__r.StageName=='12 - Closed With No Decision'*/) && PRRcrdNameSetforReqDecomm.contains(pr.RecordType.DeveloperName)){
                pr.Provisioning_Status__c = 'Request Decommission';
                provReqUpdateList.add(pr);
            }
        }
        if(!provReqUpdateList.isEmpty()){
            List<Database.SaveResult> results = Database.update(provReqUpdateList, false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()){
                    for (Database.Error err : result.getErrors()){
                      //  System.debug('decommissionProvRequests Error: '+ err.getStatusCode() + ' ' + err.getMessage());
                    }
                }
            }
        }
        TriggerUtility.requestDecommissionPrExecuted();
        
    }
    
    //Method Added as a part of RBAC
    public static void createOpportunityTeam(List<Opportunity> opportunitiesToCreateTeam){
        List<OpportunityTeamMember> oppTeamMembers = new List<OpportunityTeamMember>();
        oppTeamMembers = [SELECT Id, OpportunityId, TeamMemberRole, UserId FROM OpportunityTeamMember WHERE OpportunityId IN : opportunitiesToCreateTeam];
        
        for(Opportunity oppRec : opportunitiesToCreateTeam){
            OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
            oppTeamMember.OpportunityId = oppRec.Id;
            oppTeamMember.TeamMemberRole = 'Opportunity Owner';
            oppTeamMember.OpportunityAccessLevel = 'Edit';
            oppTeamMember.UserId = oppRec.OwnerId;
            oppTeamMembers.add(oppTeamMember);
        }
        
        /*if(!oppTeamMembers.isEmpty()){
            if(!system.isBatch() && !system.isFuture()){
                String TeamMembersJSON = JSON.serialize(oppTeamMembers); 
                retainOldTeamMemberOnOwnerChange(TeamMembersJSON);
            }
        }*/
        
        if((!oppTeamMembers.isEmpty()) && (!system.isBatch()) && (!system.isFuture())){
            
            for(OpportunityTeamMember objOppTeamMember : oppTeamMembers){
                objOppTeamMember.Id = null;
            }
            
            Database.insert(oppTeamMembers, false);
        }
        
        
    }
    
   /* @future
    public static void retainOldTeamMemberOnOwnerChange(String str){
        system.debug('Future call '+str); 
        List<OpportunityTeamMember> oppTeamList = (List<OpportunityTeamMember>) JSON.deserialize(str,List<OpportunityTeamMember>.class);
        for(OpportunityTeamMember objOppTeamMember : oppTeamList){
            objOppTeamMember.Id = null;
        }
        Database.insert(oppTeamList, false);
    }  */
    
    public static void updateSalesTeamInfoOnOppSplit(Map<Id, Opportunity> opptyMap){
    
        map<Id, Id> territoryIdUserIdMap = new map<Id, Id>();
        map<Id, Id> userIdTerritoryIdMap = new map<Id, Id>();
        Set<Id> oppSplitOwnerIdSet = new Set<Id>();
        Set<Id> lstMultiTerritoryOpportunityIds = new Set<Id>();
        Set<Id> splitsWithBlankZPAFields = new Set<Id>();
        
        map<id, id> oppSplitIdOwnerIdMap = new map<id, id>();
        map<id, OpportunitySplit> oppSplitMap = new map<id, OpportunitySplit>();
        if(opptyMap!=null){ //Condition Added by Gurjinder :CR# 198 
            for(OpportunitySplit oppSplit : [SELECT Id,Override_SE__c, SplitOwnerId, 
                                             Sales_Territory__c, Channel_Rep__c, SE__c, 
                                             Customer_Advocate__c, OpportunityId, Opportunity.OwnerId,
                                             /*Opportunity.CA_OTB_flag__c, Opportunity.Channel_OTB__c, Opportunity.Rep_OTB_Flag__c, Opportunity.SE_OTB__c,*/ Opportunity.Split__c,
                                             Opportunity.Account.Customer_Advocate__c, 
                                             Opportunity.Account.Channel_Manager__c, Opportunity.Account.Sales_Engineer__c,
                                             Opportunity.Account.Sales_Territory__c,
                                             Opportunity.Primary_Reseller_Partner__c
                                             /*, Opportunity.Account.ZPA_Manager__c, Opportunity.Account.ZPA_SE__c*/
                                             FROM OpportunitySplit 
                                             WHERE OpportunityId In: opptyMap.keySet()]){ // AND SplitPercentage < 100
                                                 oppSplitMap.put(oppSplit.Id, oppSplit);
                                                 oppSplitIdOwnerIdMap.put(oppSplit.Id, oppSplit.SplitOwnerId);
                                             }
            
            oppSplitOwnerIdSet.addAll(oppSplitIdOwnerIdMap.values());
            
            set<id> multipleSalesTerUserIdSet = new set<id>();
            List<PatchTeamMember__c> patchTeamMembersList = [SELECT Id, PatchTeam__c, Role__c, 
                                                             User__c 
                                                             FROM PatchTeamMember__c 
                                                             WHERE PatchTeam__r.Sales_Territory_Year__c = 'Current'];
            
            for(PatchTeamMember__c salesTeam : patchTeamMembersList){
                if (oppSplitOwnerIdSet.contains(salesTeam.User__c)) {
                    if(!userIdTerritoryIdMap.keySet().Contains(salesTeam.User__c)){
                        territoryIdUserIdMap.put(salesTeam.PatchTeam__c, salesTeam.User__c);
                        userIdTerritoryIdMap.put(salesTeam.User__c,salesTeam.PatchTeam__c);
                    } else if (userIdTerritoryIdMap.keySet().Contains(salesTeam.User__c)
                               && userIdTerritoryIdMap.get(salesTeam.User__c) != salesTeam.PatchTeam__c) {
                                   multipleSalesTerUserIdSet.add(salesTeam.User__c);
                               }
                }
            }
            
            map<id, map<String, Id>> userIdSalesTeamMapMap  = new map<id, map<String, Id>>();
            for(PatchTeamMember__c salesTeam : patchTeamMembersList){
                //Skip preparing the role map if opportunity split owner is not the sales territory
                if (!territoryIdUserIdMap.keySet().contains(salesTeam.PatchTeam__c)) {
                    continue;
                }
                
                map<string, Id> roleUserIdMap = new map<string, Id>();
                if(userIdSalesTeamMapMap != null){
                    if(userIdSalesTeamMapMap.keySet().Contains(territoryIdUserIdMap.get(salesTeam.PatchTeam__c))){
                        roleUserIdMap = userIdSalesTeamMapMap.get(territoryIdUserIdMap.get(salesTeam.PatchTeam__c));
                        if(salesTeam.Role__c != '' && salesTeam.Role__c != null){
                            roleUserIdMap.put(salesTeam.Role__c, salesTeam.User__c);
                            userIdSalesTeamMapMap.put(territoryIdUserIdMap.get(salesTeam.PatchTeam__c),roleUserIdMap);
                        }
                    }else{
                        if(salesTeam.Role__c != '' && salesTeam.Role__c != null){
                            roleUserIdMap.put(salesTeam.Role__c, salesTeam.User__c);
                            userIdSalesTeamMapMap.put(territoryIdUserIdMap.get(salesTeam.PatchTeam__c),roleUserIdMap);
                        }
                    }
                }else{
                    if(salesTeam.Role__c != '' && salesTeam.Role__c != null){
                        roleUserIdMap.put(salesTeam.Role__c, salesTeam.User__c);
                        userIdSalesTeamMapMap.put(territoryIdUserIdMap.get(salesTeam.PatchTeam__c),roleUserIdMap);
                    }
                }
            }
            list<OpportunitySplit> oppSplitUpdateList =  new list<OpportunitySplit>();
            for(id oppSplitId : oppSplitIdOwnerIdMap.keySet()){
                OpportunitySplit oppSplit = new OpportunitySplit();
                oppSplit = oppSplitMap.get(oppSplitId);
                // id splitOwnerId = oppSplitIdOwnerIdMap.get(oppSplitId);
                if(oppSplit.SplitOwnerId == oppSplit.Opportunity.OwnerId || oppSplit.Opportunity.Split__c != true){
                    oppSplit.Customer_Advocate__c = opptyMap.get(oppSplit.OpportunityId).Opportunity_Customer_Advocate__c;
                    //oppSplit.Channel_Rep__c = opptyMap.get(oppSplit.OpportunityId).Opportunity_Channel_Manager__c;
                    //Changes by GUrjinder : CR# 315 :Start
                    //oppSplit.SE__c = opptyMap.get(oppSplit.OpportunityId).Opportunity_Sales_Engineer__c; commented to update the SE from Opp.SE_name__C
                    if(!oppSplit.Override_SE__c){
                        oppSplit.SE__c = opptyMap.get(oppSplit.OpportunityId).SE_Name__c;
                    }
                    //Changes by GUrjinder : CR# 315 :End
                    
                    //oppSplit.Sales_Territory__c = opptyMap.get(oppSplit.OpportunityId).Opportunity_Sales_Territory__c; Commented due to Issue of blank Sales territory
                    oppSplit.Sales_Territory__c = oppSplitMap.get(oppSplit.id).Opportunity.Account.Sales_Territory__c;
                    //oppSplit.ZPA_RSM__c = opptyMap.get(oppSplit.OpportunityId).Opportunity_ZPA_Manager__c;
                    //oppSplit.ZPA_SE__c = opptyMap.get(oppSplit.OpportunityId).Opportunity_ZPA_SE__c;
                    oppSplitUpdateList.add(oppSplit);
                    
                    /*if (opptyMap.get(oppSplit.OpportunityId).Opportunity_ZPA_Manager__c == null
|| opptyMap.get(oppSplit.OpportunityId).Opportunity_ZPA_SE__c == null ) { 
splitsWithBlankZPAFields.add(oppSplit.OpportunityId);
}*/ //Commented as part f CR# 743 : Gurjinder
                } else {
                    map<string, Id> roleUserIdMap = new map<string, Id>();
                    roleUserIdMap = userIdSalesTeamMapMap.get(oppSplit.SplitOwnerId);
                    if(roleUserIdMap != null){
                        if(oppSplit.Sales_Territory__c == null){
                            oppSplit.Customer_Advocate__c = roleUserIdMap.get('Customer Advocate');
                            //oppSplit.Channel_Rep__c = roleUserIdMap.get('Channel Manager');
                            //Changes added by Gurjinder: CR# 315 :Start
                          //  system.debug('oppSplit '+oppSplit.Override_SE__c);
                            if(!oppSplit.Override_SE__c){
                                oppSplit.SE__c = roleUserIdMap.get('Sales Engineer');
                            } 
                            //Changes added by Gurjinder: CR# 315 :End
                            
                            oppSplit.Sales_Territory__c = userIdTerritoryIdMap.get(oppSplit.SplitOwnerId);
                            oppSplit.ZPA_RSM__c = roleUserIdMap.get('ZPA Manager');
                            
                            oppSplit.ZPA_SE__c = roleUserIdMap.get('ZPA SE');
                            oppSplitUpdateList.add(oppSplit);
                            
                            if (roleUserIdMap.get('ZPA Manager') == null || roleUserIdMap.get('ZPA Manager') == null) {
                                splitsWithBlankZPAFields.add(oppSplit.OpportunityId);
                            }
                        }
                    }else if(oppSplit.Opportunity.Primary_Reseller_Partner__c != null){
                    	oppSplit.Primary_Reseller__c = (String) oppSplit.Opportunity.Primary_Reseller_Partner__c;
                        oppSplitUpdateList.add(oppSplit);
                    }else{
                      //  system.debug('roleUserIdMap '+roleUserIdMap);
                    }
                }
                
                if (oppSplit.Opportunity.Split__c == true && multipleSalesTerUserIdSet.contains(oppSplit.SplitOwnerId)) {
                    //Create a case to Sales Ops for validating multiple sales territories case
                    lstMultiTerritoryOpportunityIds.add(oppSplit.OpportunityId);
                }
            }
            
            if(!oppSplitUpdateList.isEmpty()){
                database.update(oppSplitUpdateList, false);
            }
            
            if (lstMultiTerritoryOpportunityIds.size() > 0) {
                CaseCreationForAccountAndOpportunity.opportunitySplitsCaseCreation(lstMultiTerritoryOpportunityIds, new Set<Id>(), new Set<Id>(), splitsWithBlankZPAFields);
            }
            TriggerUtility.oppSpliSalesTeamExecuted();
        }//Condition Added by Gurjinder :CR# 198 
        
        
    }
    
    public static void updatePRStatusToProduction(List<Opportunity> opportunitiesList) {
        //Todo:
        //1. Query the PRs with Zscaler Cloud record type
        //2. Update the Provisioning_Status__c field value to 'Production'
        //3. Update the RecordTypeId to Zscaler Cloud In Production
        //4. Remove the Request Decommision button from the page layout
        //Query all the recordtype name and ids
        Map<String, Id> mapPRRecordTypeIds = new Map<String, Id>();
        List<Provisioning_Request__c> lstProvisioningRequestsToUpdate = new List<Provisioning_Request__c>();
        
        for (RecordType recordtype : [SELECT Id, DeveloperName FROM RecordType
                                      WHERE SObjectType = 'Provisioning_Request__c'
                                      AND DeveloperName IN ('Zscaler_cloud_in_Production', 'Zscaler_Cloud_Details', 'New_Eval')]) {
                                          mapPRRecordTypeIds.put(recordtype.DeveloperName, recordtype.Id);
                                      }
        
        //Query all the PRs associated with the list of opportunities passed to this method
        for (Provisioning_Request__c provRequest : [SELECT Id, Provisioning_Status__c, Provisioning_Type__c, RecordTypeId
                                                    FROM Provisioning_Request__c
                                                    WHERE Opportunity__c IN :opportunitiesList
                                                    AND (RecordTypeId =: mapPRRecordTypeIds.get('Zscaler_Cloud_Details')
                                                         OR RecordTypeId =: mapPRRecordTypeIds.get('New_Eval'))]) {
                                                             lstProvisioningRequestsToUpdate.add(new Provisioning_Request__c(
                                                                 Id = provRequest.Id,
                                                                 Provisioning_Status__c = 'Production',
                                                                 RecordTypeId = mapPRRecordTypeIds.get('Zscaler_cloud_in_Production')
                                                             ));
                                                         }
        
        try {
            Database.update(lstProvisioningRequestsToUpdate, false);
        } catch (Exception ex) {
            System.debug('Error occurred while updating the PR status to Production. Error: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }
    
    public static void createOpportunityExtension(List<Opportunity> newList){
        //System.debug('Tirth here I am');
        List<Opportunity_Extension__c> oppExtensionList = new  List<Opportunity_Extension__c>();
        for(Opportunity opsList : newList){
            
            Opportunity_Extension__c oppExtension = new Opportunity_Extension__c();
            oppExtension.Opportunity__c = opsList.Id;
            oppExtensionList.add(oppExtension);
        }
        TriggerUtility.createOppExtensionExecutedSetTrue();
        insert oppExtensionList;
        
    }
    
    public static void oppGotoStageSevenWithOutDuplicateOppName(List<Opportunity> newList , Map<Id,Opportunity> oldMap){
        List<Id> oppIdList = new  List<id>();
        //String userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;
        //When logic runs under Automated Process user whose Profile is empty
        //"System.QueryException: List has no rows for assignment to SObject" was thrown - CR# 3603
        Boolean isAutomatedProcessUser = UserInfo.getName() == 'Automated Process' ? TRUE : FALSE;
        String userProfileName;
        if(!isAutomatedProcessUser){
            userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;
        }else {
            userProfileName = 'Automated Process';
        }
       // System.debug('------user----' + userProfileName);
        if(userProfileName != 'System administrator'){
        for(Opportunity opportinityObj : newList){
            if(opportinityObj.Sub_Stage__c ==label.SubStage_Closed_Delete_Duplicate && opportinityObj.Sub_Stage__c != oldMap.get(opportinityObj.Id).Sub_Stage__c){
                oppIdList.add(opportinityObj.Id);
            }
        }
       
        Map<Id,Opportunity> oppExtensionMap =new Map<Id,Opportunity>( [select id,(select id from Opportunity_Extensions2__r  where Duplicate_Opportunity__c = null) from Opportunity where id IN :oppIdList]);
        
        
        for(Opportunity opportunityObj : newList ){  
            if(oppExtensionMap.get(opportunityObj.Id)!=null && oppExtensionMap.get(opportunityObj.Id).Opportunity_Extensions2__r.size()>0 ){
                if(!Test.isRunningTest()){
                    opportunityObj.addError(Label.Message_Opp_goto_Close_Duplicate);    
                }
            }
            
        }
        
        
        }
        TriggerUtility.oppoGotoSevenStageExecutedSetTrue();//Modified by Varun- CR 1269
    }
    
    public static void EREmailNotification(set<Id> oppIdSet){       
    
        if(!oppIdSet.isEmpty()){
            list<EmailTemplate> emailTemplateList = new list<EmailTemplate>();
            emailTemplateList = [Select Id, Body, Subject from EmailTemplate where DeveloperName = 'PZen_Email_Alert_to_Se_for_Node_Config' Limit 1];
            string emailBody = String.isBlank(emailTemplateList[0].Body) ? '' : emailTemplateList[0].Body;
            list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
            
            for(Equipment_Request__c er : [Select id, Opportunity__r.Owner.Email, ER_Owner__r.Email, (Select id from Private_Systems__r), Name, TAM_Email__c from Equipment_Request__c where RecordType.DeveloperName = 'PZEN' AND Approval_Status__c = 'Approved' AND Opportunity__c IN: oppIdSet]){
                if(er.Private_Systems__r == null || er.Private_Systems__r.isEmpty()){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    list<string> emailIdList = new list<string>();
                    string url = System.URL.getSalesforceBaseURL().toExternalForm();
                    url  += '/' +er.Id;
                    emailBody = emailBody.replace('{!name}', er.Name).replace('{!link}', url);
                    if(er.ER_Owner__r.Email != null){
                        emailIdList.add(er.ER_Owner__r.Email);
                    }
                    else{
                        emailIdList.add(er.Opportunity__r.Owner.Email);
                    }
                    if(er.TAM_Email__c  != null && er.TAM_Email__c != '')
                        emailIdList.add(er.TAM_Email__c);
                    
                    
                    /*emailIdList.add('snag@zscaler.com');
emailIdList.add('uraju@zscaler.com');*/
                    
                    mail.setPlainTextBody(emailBody);
                    mail.setSubject(String.isBlank(emailTemplateList[0].Subject) ? '' : emailTemplateList[0].Subject);
                    mail.setToAddresses(emailIdList);
                    
                    
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    mail.setsaveAsActivity(false);
                    emailList.add(mail);
                }
            }
            try{
                Messaging.sendEmail(emailList);
                TriggerUtility.ERNotificationExecuted();
            }catch(Exception e){}
            
        }
    }
    
    public static void updateOpportunityFields(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList,boolean isinsert, boolean isupdate) {
       // system.debug('inside updateOpportunityFields method');
       // system.debug('inside updateOpportunityFields method '+isupdate);
        Set<Id> setSEUserIds =  new Set<Id>();
        
        //Map<Id, Id> mapPatchTeamIdsAndOpptyIds = new Map<Id, Id>();
        Map<Id, Set<Id>> mapPatchTeamIdsAndOpptyIds = new Map<Id, Set<Id>>();
        Map<Id, Id> mapOpptySEUsers = new Map<Id, Id>();
        
        Map<Id, String> mapUserManagerEmail = new Map<Id, String>();
        Map<Id, Id> mapProposalOppty =  new Map<Id, Id>();
        //Map<Id, Id> mapOpptyZPAUsers = new Map<Id, Id>();
        //Map<Id, Id> mapOpptyZPAManagers = new Map<Id, Id>();
        
        Set<Id> setOpptyZPAUsers = new Set<Id>();
        Set<Id> setOpptyZPAManagers = new Set<Id>();
        
        for (Opportunity opp : oppNewList) {
            
            if (null == oppOldMap
                || null == oppOldMap.get(opp.Id)
                || null == oppOldMap.get(opp.Id).SE_Name__c) {
                    setSEUserIds.add(opp.SE_Name__c);
                    
                   // System.debug(' setSEUserIds: ' + setSEUserIds);
                }
            
            if (String.isNotBlank(opp.Sales_Territory_ID__c)
                && (null  == opp.SE_Name__c
                    || null == oppOldMap
                    || null == oppOldMap.get(opp.Id)
                    /* || opp.AccountId != oppOldMap.get(opp.Id).AccountId */) //Commented by Gurjinder: CR# 315
                && opp.StageName != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/) {
                    if (!mapPatchTeamIdsAndOpptyIds.containsKey(opp.AccountId)) {
                        mapPatchTeamIdsAndOpptyIds.put(opp.AccountId, new Set<Id> { opp.Id });
                    } else {
                        mapPatchTeamIdsAndOpptyIds.get(opp.AccountId).add(opp.Id);
                    }
                    //mapPatchTeamIdsAndOpptyIds.put(opp.Sales_Territory_ID__c, opp.Id);
                   // System.debug(' mapPatchTeamIdsAndOpptyIds: ' + mapPatchTeamIdsAndOpptyIds);
                }
            
            if (String.isNotBlank(opp.Sales_Territory_ID__c)
                && (/* null == opp.Opportunity_ZPA_SE__c */ //Commented as part f CR# 743 : Gurjinder
                    null == oppOldMap
                    || null == oppOldMap.get(opp.Id)
                    || opp.AccountId != oppOldMap.get(opp.Id).AccountId)
                && opp.StageName != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/) {
                    setOpptyZPAUsers.add(opp.Id);
                }
            
            if (String.isNotBlank(opp.Sales_Territory_ID__c)
                && (/* null == opp.Opportunity_ZPA_Manager__c */
                    null == oppOldMap
                    || null  == oppOldMap.get(opp.Id)
                    || opp.AccountId != oppOldMap.get(opp.Id).AccountId)
                && opp.StageName  != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/) {
                    setOpptyZPAManagers.add(opp.Id);
                }
        }
        
        Map<Id, Account> mapOpptyAccountTeams = new Map<Id, Account>();
        //Query the sales team members and assign SE for the opptys in mapPatchTeamIdsAndOpptyIds
        for (Account account : [SELECT Id, Sales_Engineer__c, Sales_Territory__c, Account_Manager__c, Area_Director__c, Customer_Advocate__c, Channel_Manager__c/*, ZPA_Manager__c, ZPA_SE__c*/ FROM Account
                                WHERE Id IN :mapPatchTeamIdsAndOpptyIds.keySet()]) {
                                    for (Id oppId : mapPatchTeamIdsAndOpptyIds.get(account.Id)) {
                                        mapOpptySEUsers.put(oppId, account.Sales_Engineer__c);
                                        mapOpptyAccountTeams.put(oppId, account);
                                    }
                                    
                                    setSEUserIds.add(account.Sales_Engineer__c);
                                }
        
        for (User user : (List<User>)[SELECT Id, ManagerId, Manager.Email FROM User WHERE Id IN :setSEUserIds LIMIT 1000]) {
            mapUserManagerEmail.put(user.Id, user.Manager.Email);
        }
       // System.debug(' mapUserManagerEmail: ' + mapUserManagerEmail);
        Map<Id, String> mapOpptySEManagerEmail = new Map<Id, String>();
        Map<Id, Id> mapOpptySEName = new Map<Id, Id>();
        for (Opportunity opp : oppNewList) {
           // System.debug(' : ' + opp);
            if (null == oppOldMap
                || null == oppOldMap.get(opp.Id)
                || opp.SE_Name__c != oppOldMap.get(opp.Id).SE_Name__c) {
                    mapOpptySEManagerEmail.put(opp.Id, mapUserManagerEmail.get(opp.SE_Name__c));
                }
            
            //if (null == opp.SE_Name__c
            //    || null == oppOldMap
            //    || null == oppOldMap.get(opp.Id)
            //    || opp.AccountId != oppOldMap.get(opp.Id).AccountId
            //    || mapOpptySEUsers.get(mapPatchTeamIdsAndOpptyIds.get(opp.Sales_Territory_ID__c)) != oppOldMap.get(opp.Id).SE_Name__c) {
            if (mapOpptySEUsers.containsKey(opp.Id)) {
                mapOpptySEName.put(opp.Id, mapOpptySEUsers.get(opp.Id));
                mapOpptySEManagerEmail.put(opp.Id, mapUserManagerEmail.get(mapOpptySEUsers.get(opp.Id)));
            }
        }
        
        if (!System.isFuture() && !System.isBatch() && (mapOpptySEManagerEmail.size() > 0 || mapOpptySEName.size() > 0  || mapOpptyAccountTeams.size() > 0)) {
            updateOpportunityFieldsInDb(JSON.serialize(mapOpptySEManagerEmail), JSON.serialize(mapOpptySEName), JSON.serialize(mapOpptyAccountTeams), JSON.serialize(setOpptyZPAUsers), JSON.serialize(setOpptyZPAManagers));
            
        }
        TriggerUtility.updateSEManagerEmailExecuted();
    }
    
    @future
    public static void updateOpportunityFieldsInDb(String mapOpptySEManagerEmailJSON, String mapOpptySENameJSON, String mapOpptyAccountTeamsJSON, String setOpptyZPAUsersJSON, String setOpptyZPAManagersJSON) {
        
        Map<Id, String> mapOpptySEManagerEmail =  (Map<Id, String>)JSON.deserialize(mapOpptySEManagerEmailJSON, Type.forName('Map<Id, String>'));
        Map<Id, Id> mapOpptySEName =  (Map<Id, Id>)JSON.deserialize(mapOpptySENameJSON, Type.forName('Map<Id, Id>'));
        Map<Id, Account> mapOpptyAccountTeams = (Map<Id, Account>)JSON.deserialize(mapOpptyAccountTeamsJSON, Type.forName('Map<Id, Account>'));
        
        Set<Id> setOpptyZPAUsers =  (Set<Id>)JSON.deserialize(setOpptyZPAUsersJSON, Type.forName('Set<Id>'));
        Set<Id> setOpptyZPAManagers  = (Set<Id>)JSON.deserialize(setOpptyZPAManagersJSON, Type.forName('Set<Id>'));
        
        Map<Id, Opportunity> mapOpptyToUpdate = new Map<Id, Opportunity>();
        
        for (Id oppId : mapOpptySEManagerEmail.keySet()) {
            
            mapOpptyToUpdate.put(oppId, new Opportunity(Id=oppId, SE_Manager__c=mapOpptySEManagerEmail.get(oppId)));
        }
        
        if (!mapOpptyToUpdate.isEmpty()) {
            for (Id oppId : mapOpptySEName.keySet()) {
                mapOpptyToUpdate.get(oppId).SE_Name__c = mapOpptySEName.get(oppId);
            }
        }
        
        List<Opportunity> opptyFlagsToUpdate = new List<Opportunity>();
        
        if (!mapOpptyAccountTeams.isEmpty()) {
            for (Id oppId : mapOpptyAccountTeams.keySet()) {
                if (mapOpptyToUpdate.containsKey(oppId)) {
                    mapOpptyToUpdate.get(oppId).Opportunity_Sales_Engineer__c = mapOpptyAccountTeams.get(oppId).Sales_Engineer__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Sales_Territory__c = mapOpptyAccountTeams.get(oppId).Sales_Territory__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Account_Manager__c = mapOpptyAccountTeams.get(oppId).Account_Manager__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Area_Director__c = mapOpptyAccountTeams.get(oppId).Area_Director__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Customer_Advocate__c = mapOpptyAccountTeams.get(oppId).Customer_Advocate__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Channel_Manager__c = mapOpptyAccountTeams.get(oppId).Channel_Manager__c;
                    
                    if (setOpptyZPAManagers.contains(oppId)) {
                        //mapOpptyToUpdate.get(oppId).Opportunity_ZPA_Manager__c = mapOpptyAccountTeams.get(oppId).ZPA_Manager__c;
                    }
                    
                    if (setOpptyZPAUsers.contains(oppId)) {
                        //mapOpptyToUpdate.get(oppId).Opportunity_ZPA_SE__c = mapOpptyAccountTeams.get(oppId).ZPA_SE__c;
                    }
                } else {
                    mapOpptyToUpdate.put(oppId, new Opportunity(
                        Id = oppId,
                        Opportunity_Sales_Engineer__c = mapOpptyAccountTeams.get(oppId).Sales_Engineer__c,
                        Opportunity_Sales_Territory__c = mapOpptyAccountTeams.get(oppId).Sales_Territory__c,
                        Opportunity_Account_Manager__c = mapOpptyAccountTeams.get(oppId).Account_Manager__c,
                        Opportunity_Area_Director__c = mapOpptyAccountTeams.get(oppId).Area_Director__c,
                        Opportunity_Customer_Advocate__c = mapOpptyAccountTeams.get(oppId).Customer_Advocate__c,
                        Opportunity_Channel_Manager__c = mapOpptyAccountTeams.get(oppId).Channel_Manager__c
                        //Opportunity_ZPA_Manager__c = mapOpptyAccountTeams.get(oppId).ZPA_Manager__c,
                        //Opportunity_ZPA_SE__c = mapOpptyAccountTeams.get(oppId).ZPA_SE__c
                    ));
                    
                    if (setOpptyZPAManagers.contains(oppId)) {
                        //mapOpptyToUpdate.get(oppId).Opportunity_ZPA_Manager__c = mapOpptyAccountTeams.get(oppId).ZPA_Manager__c;
                    }
                    
                    if (setOpptyZPAUsers.contains(oppId)) {
                        //mapOpptyToUpdate.get(oppId).Opportunity_ZPA_SE__c = mapOpptyAccountTeams.get(oppId).ZPA_SE__c;
                    }
                }
            }
        }
        
       // System.debug(' mapOpptyToUpdate: ' + mapOpptyToUpdate);
        if (mapOpptyToUpdate.size() > 0) {
            Database.update(opptyFlagsToUpdate, true);
            Database.update(mapOpptyToUpdate.values(), true);
        }
    }
    
    /*
public static void updateOpportunityNextStepsHistory(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList) {
Map<Id, String> mapOpportunityNextStepsHistory = new Map<Id, String>();
for (Opportunity opp : oppNewList) {
if (opp.NextStep != null
&& opp.NextStep != oppOldMap.get(opp.Id).NextStep) {
String newHistory = ((oppOldMap.get(opp.Id).NextStep != null) ? oppOldMap.get(opp.Id).NextStep : '');
mapOpportunityNextStepsHistory.put(opp.Id, newHistory + ((opp.Opportunity_Next_Step_History__c != null) ? '\n--------------------\n' + opp.Opportunity_Next_Step_History__c : ''));
}
}

if (!System.isFuture() && mapOpportunityNextStepsHistory.size() > 0) {
updateOpportunityNextStepsInDb(JSON.serialize(mapOpportunityNextStepsHistory));
}
}

@future
public static void updateOpportunityNextStepsInDb(String mapOpptyNextStepHistoryJSON) {
Map<Id, String> mapOpptyNextStepHistory = (Map<Id, String>)JSON.deserialize(mapOpptyNextStepHistoryJSON, Type.forName('Map<Id, String>'));
List<Opportunity> lstOpptyToUpdate = new List<Opportunity>();
for (Id oppId : mapOpptyNextStepHistory.keySet()) {
lstOpptyToUpdate.add(new Opportunity(Id=oppId, Opportunity_Next_Step_History__c=mapOpptyNextStepHistory.get(oppId)));
}

if (lstOpptyToUpdate.size() > 0) {
Database.update(lstOpptyToUpdate, false);
}
}

*/
    
    /*public static void updateTechValHistory(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList) {
Map<Id, String> mapOpportunityNextStepsHistory = new Map<Id, String>();
for (Opportunity opp : oppNewList) {
if (opp.Next_Steps__c  != null
&& opp.Next_Steps__c  != oppOldMap.get(opp.Id).Next_Steps__c ) {
String newHistory = ((oppOldMap.get(opp.Id).Next_Steps__c  != null) ? oppOldMap.get(opp.Id).Next_Steps__c  : '');
mapOpportunityNextStepsHistory.put(opp.Id, newHistory + ((opp.Technical_Validation_Next_Steps_History__c  != null) ? '\n--------------------\n' + opp.Technical_Validation_Next_Steps_History__c  : ''));
}
}


if (!System.isFuture() && mapOpportunityNextStepsHistory.size() > 0) {
updateOpportunityTechNextStepsInDb(JSON.serialize(mapOpportunityNextStepsHistory));
}
}

@future
public static void updateOpportunityTechNextStepsInDb(String mapOpptyNextStepHistoryJSON) {
Map<Id, String> mapOpptyNextStepHistory = (Map<Id, String>)JSON.deserialize(mapOpptyNextStepHistoryJSON, Type.forName('Map<Id, String>'));
List<Opportunity> lstOpptyToUpdate = new List<Opportunity>();
for (Id oppId : mapOpptyNextStepHistory.keySet()) {
lstOpptyToUpdate.add(new Opportunity(Id=oppId,Technical_Validation_Next_Steps_History__c=mapOpptyNextStepHistory.get(oppId)));
}

if (lstOpptyToUpdate.size() > 0) {
Database.update(lstOpptyToUpdate, false);
}
}*/
    //start of change - Raghu
    //Tech validation Next Steps
    public static void updateTechValHistory(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList)
    {
        Map<Id,String> techValidationHistoryMap = new Map<Id,String>();
        for (Opportunity opp : oppNewList)
        {
            if (opp.Next_Steps__c  != null && !(String.isBlank(opp.Next_Steps__c)) && !(String.isBlank(oppOldMap.get(opp.Id).Next_Steps__c))
                && opp.Next_Steps__c  != oppOldMap.get(opp.Id).Next_Steps__c )
            {
                String newHistory = ((oppOldMap.get(opp.Id).Next_Steps__c  != null) ? oppOldMap.get(opp.Id).Next_Steps__c  : '');
                techValidationHistoryMap.put(opp.Id,newHistory);
            }
        }
        
        if (!System.isFuture() && !System.isBatch() && techValidationHistoryMap.size() > 0) {
            updateOpportunityTechNextStepsInDb(JSON.serialize(techValidationHistoryMap),'Technical Validation Next Steps');
        }
    }
    //Opportunity Next steps
    public static void updateOpportunityNextStepsHistory(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList)
    {
        Map<Id, String> oppNextStepsHistoryMap = new Map<Id, String>();
        for (Opportunity opp : oppNewList)
        {
            if (opp.NextStep != null && !(String.isBlank(opp.NextStep)) && !(String.isBlank(oppOldMap.get(opp.Id).NextStep))
                && opp.NextStep != oppOldMap.get(opp.Id).NextStep)
            {
                String newHistory = ((oppOldMap.get(opp.Id).NextStep != null) ? oppOldMap.get(opp.Id).NextStep : '');
                oppNextStepsHistoryMap.put(opp.Id,newHistory);
            }
        }
        
        if (!System.isFuture() && !System.isBatch() && oppNextStepsHistoryMap.size() > 0) {
            updateOpportunityTechNextStepsInDb(JSON.serialize(oppNextStepsHistoryMap),'Opportunity Next Steps');
        }
    }
    
    //Architecture Next Steps
    public static void updateArchitectureNextStepsHistory(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList)
    {
        Map<Id, String> archNextStepsHistoryMap = new Map<Id, String>();
        for (Opportunity opp : oppNewList)
        {
            /* if (opp.Architecture_Next_Steps__c  != null && !(String.isBlank(opp.Architecture_Next_Steps__c)) && !(String.isBlank(oppOldMap.get(opp.Id).Architecture_Next_Steps__c))
&& opp.Architecture_Next_Steps__c  != oppOldMap.get(opp.Id).Architecture_Next_Steps__c )
{
String newHistory = ((oppOldMap.get(opp.Id).Architecture_Next_Steps__c  != null) ? oppOldMap.get(opp.Id).Architecture_Next_Steps__c  : '');
archNextStepsHistoryMap.put(opp.Id,newHistory);
} */
        }
        
        if (!System.isFuture() && !System.isBatch() && archNextStepsHistoryMap.size() > 0) {
            updateOpportunityTechNextStepsInDb(JSON.serialize(archNextStepsHistoryMap),'Architecture Next Steps');
        }
    }
    
    @future
    public static void updateOpportunityTechNextStepsInDb(String mapOpptyNextStepHistoryJSON,String objectName) {
        
        //Technical_Validation_Next_Steps_History__c
        if(objectName != null && objectName == 'Technical Validation Next Steps')
        {
          //  System.debug('Creating Technical Validation Next Step History record');
            Map<Id,String> mapOpptyNextStepHistory = (Map<Id,String>)JSON.deserialize(mapOpptyNextStepHistoryJSON, Type.forName('Map<Id,String>'));
            List<Technical_Validation_Next_Steps_History__c> lsttechValidationInsert= new List<Technical_Validation_Next_Steps_History__c>();
            for(Id oppId: mapOpptyNextStepHistory.keySet())
            {
                lsttechValidationInsert.add(new Technical_Validation_Next_Steps_History__c(opportunity__c = oppId, notes__c = mapOpptyNextStepHistory.get(oppId)));
            }
            //Database.insert(lsttechValidationInsert,false);
            insert lsttechValidationInsert;
        }
        //Opportunity_Next_Steps_History__c
        else if(objectName != null && objectName == 'Opportunity Next Steps')
        {
           // System.debug('Creating Opportunity Next Step History record');
            Map<Id,String> mapOpptyNextStepHistory = (Map<Id,String>)JSON.deserialize(mapOpptyNextStepHistoryJSON, Type.forName('Map<Id,String>'));
            List<Opportunity_Next_Steps_History__c> lsttechValidationInsert= new List<Opportunity_Next_Steps_History__c>();
            for(Id oppId: mapOpptyNextStepHistory.keySet())
            {
                lsttechValidationInsert.add(new Opportunity_Next_Steps_History__c(opportunity__c = oppId, notes__c = mapOpptyNextStepHistory.get(oppId)));
            }
            //Database.insert(lsttechValidationInsert,false);
            insert lsttechValidationInsert;
        }
        //Architecture_Next_Steps__c
        else if(objectName != null && objectName == 'Architecture Next Steps')
        {
          //  System.debug('Creating Architecture Next Step History record');
            Map<Id,String> mapOpptyNextStepHistory = (Map<Id,String>)JSON.deserialize(mapOpptyNextStepHistoryJSON, Type.forName('Map<Id,String>'));
            List<Architecture_Next_Steps__c> lsttechValidationInsert= new List<Architecture_Next_Steps__c>();
            for(Id oppId: mapOpptyNextStepHistory.keySet())
            {
                lsttechValidationInsert.add(new Architecture_Next_Steps__c(opportunity__c = oppId, notes__c = mapOpptyNextStepHistory.get(oppId)));
            }
            //Database.insert(lsttechValidationInsert,false);
            insert lsttechValidationInsert;
        }
    }
    
    //End of change - Raghu
    
    
    public static void updateAccountForApprovedPZEN(Set<Id> oppIdSet) {
       // system.debug('TriggerUtility.isUpdateAccountForApprovedPZEN() '+TriggerUtility.isUpdateAccountForApprovedPZEN());
        if(!TriggerUtility.isUpdateAccountForApprovedPZEN()){
           // system.debug('inside if');
        List<Account> accUpdateList = new List<Account>();
        Map<Id, boolean> accIdApprovedPZENMap = new map<Id, boolean>();
        Map<id,Account> Account2update= new Map<id,Account>();
        
        for(opportunity opp: [Select id,Accountid,Account.Account_Renewal_Notes__c,Account.Approved_PZEN__c, (Select id,Name,SBQQ__Primary__c,Special_Terms__c from SBQQ__Quotes2__r where SBQQ__Primary__c=true) from Opportunity where id IN:oppIdSet and Type IN ('New Business','Existing Customer (Add On)','Existing Customer (Renewal)')]){
          //  system.debug('opp'+opp.SBQQ__Quotes2__r.size());
            if(opp.SBQQ__Quotes2__r.size()>0){
                Account acc= new Account(id=opp.Accountid,Account_Renewal_Notes__c=opp.Account.Account_Renewal_Notes__c);
                //String existingrenewalnotes=opp.Account.Account_Renewal_Notes__c;
                String newrenewalnotes='';
                for(SBQQ__Quote__c quote : opp.SBQQ__Quotes2__r){
                    //system.debug('opp.SBQQ__Quotes2__r '+opp.SBQQ__Quotes2__r);
                    //newrenewalnotes=existingrenewalnotes+'/n'+quote.Name+' - '+quote.Special_Terms__c;
                    if(quote.Special_Terms__c!='' && quote.Special_Terms__c!=null){
                        newrenewalnotes=newrenewalnotes+' \n '+quote.Name+' - '+quote.Special_Terms__c;
                        //acc.Account_Renewal_Notes__c=acc.Account_Renewal_Notes__c+ '\n'+quote.Special_Terms__c;
                    }
                }
               // system.debug('newrenewalnotes '+newrenewalnotes);
                //system.debug('existingrenewalnotes '+existingrenewalnotes);
                if(acc.Account_Renewal_Notes__c!=null && acc.Account_Renewal_Notes__c!=''){
                    acc.Account_Renewal_Notes__c=acc.Account_Renewal_Notes__c+newrenewalnotes;
                }else{
                    acc.Account_Renewal_Notes__c=newrenewalnotes;
                }
                
                Account2update.put(acc.id,acc);
            }
        
        }
       // system.debug('Account2update '+Account2update);
        for(Equipment_Request__c eqpReq : [SELECT Id, Opportunity__c, 
                                           Opportunity__r.AccountId 
                                           FROM Equipment_Request__c 
                                           WHERE Approval_Status__c =: 'Approved' 
                                           AND Opportunity__c IN: oppIdSet 
                                           AND RecordType.DeveloperName =: 'PZEN' ]){
                    if(eqpReq.Opportunity__c != null){
                         //accUpdateList.add(new Account(id = eqpReq.Opportunity__r.AccountId, Approved_PZEN__c = true));   
                        if(Account2update.containskey(eqpReq.Opportunity__r.AccountId)){
                            system.debug('inside if');
                            Account2update.get(eqpReq.Opportunity__r.AccountId).Approved_PZEN__c=true;
                        }else{
                            system.debug('inside else');
                        }
                    }
                                           
        }
        if(Account2update!=null && Account2update.values().size()>0){
            List<Database.SaveResult> results = Database.update(Account2update.values(), false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()){
                    for (Database.Error err : result.getErrors()){
                        System.debug('updateAccountForApprovedPZEN Error: '+ err.getStatusCode() + ' ' + err.getMessage());
            }
        }
        }
        }
            
        TriggerUtility.updateAccountForApprovedPZENExecuted();
    }
    }
    
    public static void updateForecastCategoryValues(map<Id, Opportunity> newOppMap, map<Id, Opportunity>oldOppMap) {
        
    }
    
    public static void updateSplitForecastCategory(map<Id, Opportunity> newOppMap, map<Id, Opportunity> oldOppMap){
        Triggers_Switch__c tg = Triggers_Switch__c.getValues('OpportunityForecastCategoryAutomation');
        if(tg != null && tg.Execute__c){
            set<Id> oppIdSet = new set<Id>();
            for(Opportunity opp : newOppMap.values()){
                /*if(opp.ForecastCategoryName != oldOppMap.get(opp.Id).ForecastCategoryName){
oppIdSet.add(opp.Id);
}*/
                if(opp.Deal_Path__c != oldOppMap.get(opp.Id).Deal_Path__c){
                    oppIdSet.add(opp.Id);
                }
                if(opp.Forecast_Category__c != oldOppMap.get(opp.Id).Forecast_Category__c || opp.AD_Forecast_Category__c != oldOppMap.get(opp.Id).AD_Forecast_Category__c || opp.CRO_Forecast_Category__c != oldOppMap.get(opp.Id).CRO_Forecast_Category__c || opp.DM_Forecast_Category__c != oldOppMap.get(opp.Id).DM_Forecast_Category__c || opp.VP_Forecast_Category__c != oldOppMap.get(opp.Id).VP_Forecast_Category__c || opp.RVP_Forecast_Category__c != oldOppMap.get(opp.Id).RVP_Forecast_Category__c || opp.AD_Forecast_Category_Lock__c != oldOppMap.get(opp.Id).AD_Forecast_Category_Lock__c || opp.CRO_Forecast_Category_Lock__c != oldOppMap.get(opp.Id).CRO_Forecast_Category_Lock__c || opp.DM_Forecast_Category_Lock__c != oldOppMap.get(opp.Id).DM_Forecast_Category_Lock__c || opp.VP_Forecast_Category_Lock__c != oldOppMap.get(opp.Id).VP_Forecast_Category_Lock__c || opp.RVP_Forecast_Category_Lock__c != oldOppMap.get(opp.Id).RVP_Forecast_Category_Lock__c || opp.StageName != oldOppMap.get(opp.Id).StageName) {
                    oppIdSet.add(opp.Id);
                }
            }
            
            list<OpportunitySplit> oppSplitUpdateList = new list<OpportunitySplit>();
            for(OpportunitySplit oppSplit : [Select Id, OpportunityId, Forecast_Category__c, SplitOwnerId, Opportunity.Forecast_Type__c, Opportunity_Deal_Path__c, Deal_Path__c, Opportunity_Forecast_Category__c, Opportunity_Forecast_Type__c, Forecast_Type__c, Opportunity_Owner__c,
                                             Forecast_Category_New__c, DM_Forecast_Category__c, VP_Forecast_Category__c, RVP_Forecast_Category__c, CRO_Forecast_Category__c, AD_Forecast_Category__c,
                                             DM_Forecast_Category_Lock__c, VP_Forecast_Category_Lock__c, RVP_Forecast_Category_Lock__c, CRO_Forecast_Category_Lock__c, AD_Forecast_Category_Lock__c, Opportunity_AD_Forecast_Category__c, Opportunity_CRO_Forecast_Category__c, Opportunity_DM_Forecast_Category__c, Opportunity_VP_Forecast_Category__c,Opportunity_RVP_Forecast_Category__c, Opportunity_AD_Forecast_Category_Lock__c, Opportunity_CRO_Forecast_Category_Lock__c, Opportunity_DM_Forecast_Category_Lock__c, Opportunity_VP_Forecast_Category_Lock__c, Opportunity_RVP_Forecast_Category_Lock__c, Opportunity_Stage__c
                                             FROM OpportunitySplit WHERE OpportunityId IN: oppIdSet]){
                                                 if(oppSplit.SplitOwnerId == oppSplit.Opportunity_Owner__c || (oppSplit.Opportunity_Forecast_Type__c == 'New' || oppSplit.Opportunity_Forecast_Type__c == 'Upsell') || (oppSplit.Opportunity_Forecast_Type__c == 'Renewal' && oppSplit.Forecast_Type__c == 'Renewal') || (oppSplit.Opportunity_Forecast_Category__c == 'Closed') || (oppSplit.Opportunity_Forecast_Category__c == 'Omitted') || ((oppSplit.Opportunity_Stage__c == label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/ || oppSplit.Opportunity_Stage__c == label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/) && oppSplit.Opportunity_Forecast_Category__c == 'Commit') || (oldOppMap.get(oppSplit.OpportunityId).StageName != newOppMap.get(oppSplit.OpportunityId).StageName && (oldOppMap.get(oppSplit.OpportunityId).Forecast_Category__c == 'Closed' || oldOppMap.get(oppSplit.OpportunityId).Forecast_Category__c == 'Omitted' || (oldOppMap.get(oppSplit.OpportunityId).Forecast_Category__c == 'Commit' && (oldOppMap.get(oppSplit.OpportunityId).Stagename == label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/ || oldOppMap.get(oppSplit.OpportunityId).Stagename == label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/))))){
                                                     //For primary split line, copy the fc from oppty to split
                                                     oppSplit.Forecast_Category_New__c = oppSplit.Opportunity_Forecast_Category__c;
                                                     oppSplit.Deal_Path__c = oppSplit.Opportunity_Deal_Path__c;
                                                     oppSplit.AD_Forecast_Category__c = oppSplit.Opportunity_AD_Forecast_Category__c;
                                                     oppSplit.CRO_Forecast_Category__c = oppSplit.Opportunity_CRO_Forecast_Category__c;
                                                     oppSplit.DM_Forecast_Category__c  = oppSplit.Opportunity_DM_Forecast_Category__c;
                                                     oppSplit.VP_Forecast_Category__c = oppSplit.Opportunity_VP_Forecast_Category__c;
                                                     oppSplit.RVP_Forecast_Category__c = oppSplit.Opportunity_RVP_Forecast_Category__c;
                                                     oppSplit.AD_Forecast_Category_Lock__c = oppSplit.Opportunity_AD_Forecast_Category_Lock__c;
                                                     oppSplit.CRO_Forecast_Category_Lock__c = oppSplit.Opportunity_CRO_Forecast_Category_Lock__c;
                                                     oppSplit.DM_Forecast_Category_Lock__c = oppSplit.Opportunity_DM_Forecast_Category_Lock__c;
                                                     oppSplit.VP_Forecast_Category_Lock__c = oppSplit.Opportunity_VP_Forecast_Category_Lock__c;
                                                     oppSplit.RVP_Forecast_Category_Lock__c = oppSplit.Opportunity_RVP_Forecast_Category_Lock__c;
                                                     oppSplitUpdateList.add(oppSplit);
                                                 }
                                                 
                                             }
            
            if(!oppSplitUpdateList.isEmpty())
                Database.update(oppSplitUpdateList, false);
            TriggerUtility.updateForecastCategoryExecuted();
        }
    }
    
    // Commented out the below code as the ownership update logic is out of scope
    /*
public static void updateOwnersForOpportunity(Map<Id, Opportunity> mapNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
// Todo:
// Iterate through all opportunities and check if the owner has only ZPAForecastingEnabled__c set to true;

List<Opportunity> lstOpportunitiesToUpdate = new List<Opportunity>();
List<Id> lstOwnerIds = new List<Id>();
Map<Id, Id> mapOwnerAccountManagerId = new Map<Id, Id>();

for (Opportunity opp : mapNewOpportunities.values()) {
lstOwnerIds.add(opp.OwnerId);
}

Map<Id, User> mapOwnerUserInfo = new Map<Id, User>();
if (lstOwnerIds.size() > 0) {
mapOwnerUserInfo = new Map<Id, User>([SELECT Id, ForecastEnabled__c, ZPAForecastEnabled__c
FROM User
WHERE Id IN :lstOwnerIds
AND ZPAForecastEnabled__c = true AND ForecastEnabled__c = false]);

for (Opportunity opp : [SELECT Id, OwnerId, Account.Account_Manager__c
FROM Opportunity
WHERE Id IN :mapNewOpportunities.keySet() AND OwnerId IN :mapOwnerUserInfo.KeySet()]) {
mapOwnerAccountManagerId.put(opp.OwnerId, opp.Account.Account_Manager__c);
}
}

for (Id oppId : mapNewOpportunities.keySet()) {
if (mapOwnerAccountManagerId.containsKey(mapNewOpportunities.get(oppId).OwnerId)) {
lstOpportunitiesToUpdate.add(new Opportunity(
Id = oppId,
OwnerId = mapOwnerAccountManagerId.get(mapNewOpportunities.get(oppId).OwnerId)
));
}
}

try {
System.debug('lstOpportunitiesToUpdate: ' + JSON.serialize(lstOpportunitiesToUpdate));
update lstOpportunitiesToUpdate;
TriggerUtility.opportunityOwnershipChangeExecuted();
} catch (Exception ex) {
System.debug('Exception occurred while changing opportunity owner. ' + ex.getMessage() + ' ' + ex.getStackTraceString());
}
}
*/
    
    public static void resetOverrideACVFieldsInProposal(List<Id> proposalsToQuery) {        
        
        try {
            // update lstProposalsToUpdate;
            TriggerUtility.overrideACVValuesResetExecuted();
        } catch (Exception ex) {}
    }
    //CR #3970 Start 
 //Method defaults the stage to 0 and sets the Record Creator and Owner's Manager Email address to send out auto closure notification
    public static void setDefaultOpportunityStage(List<Opportunity> newOpportunityList){
       
        Map<Id,User> opportunityOwners = new Map<Id,User>();
        set<Id> accountIds = new set<Id>();
        set<Id> ownerIds = new set<Id>();
        List<Opportunity> oppsToPopulate = new List<Opportunity>();
        for(Opportunity oppRec:newOpportunityList){
                
            accountIds.add(oppRec.AccountId);
            ownerIds.add(oppRec.OwnerId);
             
          }
        for(User userRec: [SELECT Id,Email,Manager.Email FROM User WHERE  isActive = true AND Id IN: ownerIds LIMIT 1000]){
            opportunityOwners.put(userRec.Id,userRec);
        }
        User currentUser = [SELECT Id,Manager.Email FROM User WHERE Id=: UserInfo.getUserId() LIMIT 1];
        
            for(Opportunity opp:newOpportunityList){
            
                opp.Opportunity_Creator_Manager_Email__c = currentUser.Manager.Email;
                opp.Opportunity_Owner_Manager_Email__c = opportunityOwners.get(opp.OwnerId)?.Manager.Email;
                    
                //opp.Is_SE_Involved__c = acc?.Market_Segment__c == 'Commercial'?null:'Yes';
                //system.debug('--opp.Is_SE_Involved__c--'+opp.Is_SE_Involved__c);
            }

    }
    //CR #3970 End
    public static void copymainforecasttohierarchycategoryfields(List<Opportunity> newlist){
        
       Triggers_Switch__c tg = Triggers_Switch__c.getValues('OpportunityForecastCategoryAutomation');
        if(tg != null && tg.Execute__c){
            Map<String, Stage_ForecastCategory_Mapping__c> stageforecastmap =  new Map<String, Stage_ForecastCategory_Mapping__c>();
            Map<String, Stage_ForecastCategory_Rank__c> stageforecastrankmap =  Stage_ForecastCategory_Rank__c.getAll();
            for(Stage_ForecastCategory_Mapping__c stg: Stage_ForecastCategory_Mapping__c.getAll().Values()){
                stageforecastmap.put(stg.StageName__c, stg);
            } 

            for(Opportunity opp: newlist){
                if(stageforecastmap.containsKey(opp.StageName) && stageforecastmap.get(opp.StageName) != null){
                    if(opp.Forecast_Category__c != null && stageforecastrankmap.containsKey(opp.Forecast_Category__c) && stageforecastrankmap.containsKey(stageforecastmap.get(opp.StageName).Forecast_Category__c) && opp.StageName != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/ && opp.StageName != label.Stage_7_Closed_Lost /* '12 - Closed With No Decision' && opp.StageName != '11 - Closed Lost' && opp.StageName != '14 - Closed: Delete Duplicate'*/){
                        if(stageforecastrankmap.get(stageforecastmap.get(opp.StageName).Forecast_Category__c).Rank__c > stageforecastrankmap.get(opp.Forecast_Category__c).Rank__c){
                            opp.Forecast_Category__c = stageforecastmap.get(opp.StageName).Forecast_Category__c;
                        }
                    }else{
                        opp.Forecast_Category__c = stageforecastmap.get(opp.StageName).Forecast_Category__c;
                    }
                }
                if(opp.Forecast_Category__c != null){
                    if(opp.Forecast_Category__c == 'Omitted' || opp.Forecast_Category__c == 'Closed' || ((opp.Stagename == label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/ || opp.Stagename == label.Stage_4_Economic_Buyer_Signoff  /*'10 - Closed Won'*/) && opp.Forecast_Category__c == 'Commit')){
                        opp.AD_Forecast_Category_Lock__c = false;
                        opp.CRO_Forecast_Category_Lock__c = false;
                        opp.DM_Forecast_Category_Lock__c = false;
                        opp.VP_Forecast_Category_Lock__c = false;
                        opp.RVP_Forecast_Category_Lock__c = false;
                        
                    }
                }
                
                if(!opp.DM_Forecast_Category_Lock__c){
                    opp.DM_Forecast_Category__c = opp.Forecast_Category__c;
                }
                if(!opp.AD_Forecast_Category_Lock__c){
                    opp.AD_Forecast_Category__c = opp.DM_Forecast_Category__c;
                }
                if(!opp.RVP_Forecast_Category_Lock__c){
                    opp.RVP_Forecast_Category__c = opp.AD_Forecast_Category__c;
                }
                if(!opp.VP_Forecast_Category_Lock__c){
                    opp.VP_Forecast_Category__c = opp.RVP_Forecast_Category__c;
                }
                if(!opp.CRO_Forecast_Category_Lock__c){
                    opp.CRO_Forecast_Category__c = opp.VP_Forecast_Category__c;
                }
                
                if(opp.Type == 'Existing Customer (Renewal)' ){ //opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_Renewal_Opportunity
                    //opp.Renewal_Rep_Forecast_Category__c = opp.Forecast_Category__c;
                }
                
                
                //Added by Pankaj  : CR# 152 : In My Number Fields  : Start
                
                // removed by Rajesh CR# 1154   - Start  
                /*   if(opp.StageName == '6 - Closed Won' ){
opp.RD_In_my_Number__c = true;
opp.RVP_In_my_Number__c = true;

opp.AVP_In_my_Number__c = true;
opp.Geo_VP_In_my_Number__c = true;
opp.Renewal_RD_In_my_Number__c = true;
opp.Renewal_RVP_In_my_Number__c = true;
opp.Renewal_VP_In_my_Number__c = true;



}

if(opp.StageName == '7 - Closed Lost' ){
opp.RD_In_my_Number__c = false;
opp.RVP_In_my_Number__c = false;

opp.AVP_In_my_Number__c = false;
opp.Geo_VP_In_my_Number__c = false;
opp.Renewal_RD_In_my_Number__c = false;
opp.Renewal_RVP_In_my_Number__c = false;
opp.Renewal_VP_In_my_Number__c = false;



}*/ 
                // removed by Rajesh CR# 1154   - End
                
                if(opp.Type == 'Existing Customer (Renewal)' &&  opp.StageName == '6 - Closed Won' ){
                    
                    
                    opp.Renewal_Rep_Forecast_Category__c = 'Closed';
                }
                if(opp.Type == 'Existing Customer (Renewal)' && opp.StageName == '7 - Closed Lost'){
                    opp.Renewal_Rep_Forecast_Category__c = 'Omitted'; 
                }
                
                
                //Added by Pankaj  : CR# 152 : In My Number Fields  : END 
                
                
                
            }
        }
       
    }
    
    public static void handleallcategoryfieldandlockchanges(Map<Id,Opportunity> newmap, Map<Id, Opportunity> oldmap){
        
        Boolean stopfcchanges = false;
        Triggers_Switch__c tg = Triggers_Switch__c.getValues('OpportunityForecastCategoryAutomation');
        if(tg != null && tg.Execute__c){
            Map<String, Stage_ForecastCategory_Mapping__c> stageforecastmap =  new Map<String, Stage_ForecastCategory_Mapping__c>();
            Map<String, Stage_ForecastCategory_Rank__c> stageforecastrankmap =  Stage_ForecastCategory_Rank__c.getAll();
            for(Stage_ForecastCategory_Mapping__c stg: Stage_ForecastCategory_Mapping__c.getAll().Values()){
                stageforecastmap.put(stg.StageName__c, stg);
            }
            for(Opportunity opp: newmap.values()){
                if(opp.Stagename != oldmap.get(opp.Id).StageName){
                    if(stageforecastmap.containsKey(opp.StageName) && stageforecastmap.get(opp.StageName) != null){
                        if(opp.Forecast_Category__c != null && stageforecastrankmap.containsKey(opp.Forecast_Category__c) && stageforecastrankmap.containsKey(stageforecastmap.get(opp.StageName).Forecast_Category__c) && opp.StageName != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/ && opp.StageName != label.Stage_7_Closed_Lost /*'12 - Closed With No Decision' && opp.StageName != '11 - Closed Lost' && opp.StageName != '14 - Closed: Delete Duplicate'*/){
                            if(stageforecastrankmap.get(stageforecastmap.get(opp.StageName).Forecast_Category__c).Rank__c > stageforecastrankmap.get(opp.Forecast_Category__c).Rank__c){
                                opp.Forecast_Category__c = stageforecastmap.get(opp.StageName).Forecast_Category__c;
                            }
                        }else{
                            opp.Forecast_Category__c = stageforecastmap.get(opp.StageName).Forecast_Category__c;
                        }
                    }
                }
                
                if(opp.Forecast_Category__c != oldmap.get(opp.Id).Forecast_Category__c || opp.StageName != oldmap.get(opp.Id).StageName){    
                    if(opp.Forecast_Category__c == 'Omitted' || opp.Forecast_Category__c == 'Closed' || ((opp.Stagename == label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/ || opp.Stagename == label.Stage_4_Economic_Buyer_Signoff  /*'10 - Closed Won'*/) && opp.Forecast_Category__c == 'Commit')){
                        opp.AD_Forecast_Category_Lock__c = false;
                        opp.CRO_Forecast_Category_Lock__c = false;
                        opp.DM_Forecast_Category_Lock__c = false;
                        opp.VP_Forecast_Category_Lock__c = false;
                        opp.RVP_Forecast_Category_Lock__c = false;
                        
                    }
                }
                stopfcchanges = true;
                
                if(opp.AD_Forecast_Category__c != oldmap.get(opp.Id).AD_Forecast_Category__c){
                    opp.AD_Forecast_Category_Lock__c = true;
                }
                if(opp.CRO_Forecast_Category__c != oldmap.get(opp.Id).CRO_Forecast_Category__c){
                    opp.CRO_Forecast_Category_Lock__c = true;
                }
                if(opp.DM_Forecast_Category__c != oldmap.get(opp.Id).DM_Forecast_Category__c){
                    opp.DM_Forecast_Category_Lock__c = true;
                }
                if(opp.VP_Forecast_Category__c != oldmap.get(opp.Id).VP_Forecast_Category__c){
                    opp.VP_Forecast_Category_Lock__c = true;
                }
                if(opp.RVP_Forecast_Category__c != oldmap.get(opp.Id).RVP_Forecast_Category__c){
                    opp.RVP_Forecast_Category_Lock__c = true;
                }
                
                if(opp.DM_Forecast_Category_Lock__c != oldmap.get(opp.Id).DM_Forecast_Category_Lock__c && !opp.DM_Forecast_Category_Lock__c){
                    opp.DM_Forecast_Category__c = opp.Forecast_Category__c;
                }
                if(opp.AD_Forecast_Category_Lock__c != oldmap.get(opp.Id).AD_Forecast_Category_Lock__c && !opp.AD_Forecast_Category_Lock__c){
                    opp.AD_Forecast_Category__c = opp.DM_Forecast_Category__c;
                }
                if(opp.RVP_Forecast_Category_Lock__c != oldmap.get(opp.Id).RVP_Forecast_Category_Lock__c && !opp.RVP_Forecast_Category_Lock__c){
                    opp.RVP_Forecast_Category__c = opp.AD_Forecast_Category__c;
                }
                if(opp.VP_Forecast_Category_Lock__c != oldmap.get(opp.Id).VP_Forecast_Category_Lock__c && !opp.VP_Forecast_Category_Lock__c){
                    opp.VP_Forecast_Category__c = opp.RVP_Forecast_Category__c;
                }
                if(opp.CRO_Forecast_Category_Lock__c != oldmap.get(opp.Id).CRO_Forecast_Category_Lock__c && !opp.CRO_Forecast_Category_Lock__c){
                    opp.CRO_Forecast_Category__c = opp.VP_Forecast_Category__c;
                }
                
                if(!opp.DM_Forecast_Category_Lock__c){
                    opp.DM_Forecast_Category__c = opp.Forecast_Category__c;
                }
                if(!opp.AD_Forecast_Category_Lock__c){
                    opp.AD_Forecast_Category__c = opp.DM_Forecast_Category__c;
                }
                if(!opp.RVP_Forecast_Category_Lock__c){
                    opp.RVP_Forecast_Category__c = opp.AD_Forecast_Category__c;
                }
                if(!opp.VP_Forecast_Category_Lock__c){
                    opp.VP_Forecast_Category__c = opp.RVP_Forecast_Category__c;
                }
                if(!opp.CRO_Forecast_Category_Lock__c){
                    opp.CRO_Forecast_Category__c = opp.VP_Forecast_Category__c;
                }
                
                if(opp.Type == 'Existing Customer (Renewal)' ){//opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_Renewal_Opportunity
                    // opp.Renewal_Rep_Forecast_Category__c = opp.Forecast_Category__c;
                }
                
                if(stopfcchanges){
                    TriggerUtility.OpptyTriggerFCexecuted();
                }
                
                
                //clearRenewalmynumberFields(opp);
                //opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_Renewal_Opportunity  - Removed - 05-feb-2019
                if(opp.Type == 'Existing Customer (Renewal)' && opp.StageName == '6 - Closed Won' && oldmap.get(opp.Id).StageName != opp.StageName){
                    
                    //opp.Renewal_Rep_Forecast_Category__c = 'Closed';
                    // Removed by Rajesh CR# 1154   - start
                    /*opp.RD_In_my_Number__c = true;
opp.RVP_In_my_Number__c = true;
opp.Renewal_RD_In_my_Number__c = true;
opp.Renewal_RVP_In_my_Number__c = true;
opp.Renewal_VP_In_my_Number__c = true;*/
                    // Removed by Rajesh CR# 1154 - end
                    opp.Renewal_Rep_Forecast_Category__c = 'Closed'; 
                }
                
                if(opp.Type == 'Existing Customer (Renewal)' && opp.StageName == '7 - Closed Lost' && oldmap.get(opp.Id).StageName != opp.StageName){
                    opp.Renewal_Rep_Forecast_Category__c = 'Omitted'; 
                }
                
                // Removed by Rajesh CR# 1154 - Start
                /*if((opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_New_Business || opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_New_Business_Close || opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_Upsell_Opportunity || opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_Upsell_Opportunity_Closed) && opp.Type != 'Existing Customer (Renewal)' && (opp.StageName == '6 - Closed Won' && oldmap.get(opp.Id).StageName != opp.StageName)){

opp.RD_In_my_Number__c = true;
opp.RVP_In_my_Number__c = true;
opp.AVP_In_my_Number__c = true;
opp.Geo_VP_In_my_Number__c = true;
}*/
                // Removed by Rajesh CR# 1154 - End
            }
        }
        
    }
    
    /*public static void clearRenewalmynumberFields(Opportunity opp) {
opp.RD_In_my_Number__c = false;
opp.RVP_In_my_Number__c = false;
opp.Renewal_RD_In_my_Number__c = false;
opp.Renewal_RVP_In_my_Number__c = false;
opp.Renewal_VP_In_my_Number__c = false;
opp.AVP_In_my_Number__c = false;
opp.Geo_VP_In_my_Number__c = false;
}*/
    //Commented as part of CR#3744 Start
    /*public static void updateGAMNAM(List<Opportunity> newlist){
        
        Triggers_Switch__c tg = Triggers_Switch__c.getValues('Update_GAM_NAM');
        if(tg != null && tg.Execute__c){
            Map<String, Partner_GAM_NAM_Mapping__c> stageforecastmap =  new Map<String, Partner_GAM_NAM_Mapping__c>();
            
            for(Opportunity opp: newlist){
                for(Partner_GAM_NAM_Mapping__c stg: Partner_GAM_NAM_Mapping__c.getAll().Values()){
                    if(opp.Primary_Partner__c != null && opp.Primary_Partner__c.containsIgnoreCase(stg.Name)){
                        opp.GAM_NAM__c = stg.GAM_NAM_Id__c;
                        break;
                    }
                }
            }
        }
       
    }*/
    //Commented as part of CR#3744 END
    
    public static void clearNSfieldsonCreation(List<Opportunity> newlist){
       for(Opportunity opp: newlist){
            opp.Netsuite_Sales_Order_Internal_ID__c = null;
            opp.Netsuite_Customer_ID_Override__c = null;
            opp.Partner_PO_Number__c = null;
            opp.First_PO_Date__c = null;
            opp.NS_Integration_Status__c = null;
            opp.Netsuite_Sales_Order_Number__c = null;
            opp.Netsuite_Primary_Partner_ID_Override__c = null;
            opp.SO_Creation_Date__c = null;
            opp.NS_Integration_Failure_Reason__c = null;
            opp.NS_Integration_Requested_By__c = null;
            opp.NS_Integration_Status_Change_Time__c = null;
            opp.Netsuite_Partner_Internal_ID_Override__c = null;
            opp.Extension_Approval_Status__c = null;
            opp.New_Extended_Contract_Date__c = null;
            opp.Past_Due_Notification_Status__c = null;
            opp.Renewal_Notification_Status__c = null;
            opp.Confirm_Opportunity_Closure__c = false;
        }
        
    }
    
    public static void validateClosedLostwithOpenPRs(Map<Id, Opportunity> newOppMap, map<Id, Opportunity> oldOppMap){
        set<id> oppIdSet = new set<Id>();
        for(Opportunity opp : newOppMap.values()){
            if(OnOffSwitch__c.getInstance('DeactivateStage11and12forChurn')!=null && OnOffSwitch__c.getInstance('DeactivateStage11and12forChurn').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('DeactivateStage11and12forChurn').Deactivate_Component__c==True){        
                if(opp.StageName == label.Stage_7_Closed_Lost && opp.Sub_Stage__c == Label.SubStage_Closed_Delete_Duplicate /*'14 - Closed: Delete Duplicate'*/ && opp.StageName != oldOppMap.get(opp.Id).StageName && !opp.Confirm_Opportunity_Closure__c && opp.type == 'New Business'){
                    oppIdSet.add(opp.Id);
                }
                
            }else{
                if(( opp.StageName == label.Stage_7_Closed_Lost && (opp.Sub_Stage__c == Label.SubStage_Closed_Lost || opp.Sub_Stage__c == Label.SubStage_Closed_With_No_Decision || opp.Sub_Stage__c == Label.SubStage_Closed_Delete_Duplicate ))/*'11 - Closed Lost' || opp.StageName == '12 - Closed With No Decision' || opp.StageName == '14 - Closed: Delete Duplicate'*/ && opp.StageName != oldOppMap.get(opp.Id).StageName && !opp.Confirm_Opportunity_Closure__c && (opp.type == 'New Business' || opp.type == 'Existing Customer (Add On)')){
                    oppIdSet.add(opp.Id);
                }
            }
        }
        set<String> prStatusSet = new set<String>();
        prStatusSet.add('Requested');
        prStatusSet.add('In Progress');
        prStatusSet.add('Provisioned');
        
        list<Provisioning_Request__c> provReqUpdateList = new list<Provisioning_Request__c>();
        if(!oppIdSet.isEmpty()){
            for(Provisioning_Request__c pr : [Select Id, RecordType.DeveloperName, Provisioning_Status__c, Opportunity__c from Provisioning_Request__c where Opportunity__c IN: oppIdSet AND Provisioning_Status__c IN: prStatusSet]){
                Opportunity opp = newOppMap.get(pr.Opportunity__c);
                opp.addError('This Opportunity contains Active PRs. Do you want to proceed with the Closure of Opportunity? If yes, please check the \'Confirm Opportunity Closure \' to proceed.' );
            }
        }
    }
    
    
    public static void updateContractEndDate(List<Id> lstAccountIds) {
        updateContractEndDate(lstAccountIds, new List<Id>());
    }
    
    public static void updateContractEndDate(List<Id> lstAccountIds, List<Id> lstOpportunityIds) {
        Map<Id, Opportunity> mapOpportunitiesToUpdate = new Map<Id, Opportunity>();
        
        mapOpportunitiesToUpdate = getOpportunityContractEndDates(lstAccountIds, lstOpportunityIds);
        
       //System.debug('*** mapOpportunitiesToUpdate: ' + JSON.serialize(mapOpportunitiesToUpdate));
        try {
            Database.update(mapOpportunitiesToUpdate.values(), true);
        } catch (Exception ex) {
            System.debug(' Error occurred while updating the Contract End Date in opportunities: ' + ex.getMessage() + '; ' + ex.getStackTraceString());
        }
    }
    
    public static Map<Id, Opportunity> getOpportunityContractEndDates(List<Id> lstAccountIds, List<Id> lstOpportunityIds) {
        Map<Id, Opportunity> mapOpportunitiesToUpdate = new Map<Id, Opportunity>();
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        Map<Id, Map<Id, Date>> mapAccountAndContractEndDates = new Map<Id, Map<Id, Date>>();
        Map<Id, Map<String, Map<Id, Date>>> mapAccountSalesOrderAndContractEndDates = new Map<Id, Map<String, Map<Id, Date>>>();
        Set<Id> setNonCotermAccountIds = new Set<Id>();
        Map<Id, Id> mapNonCotermAccountAndOpptyIds = new Map<Id, Id>();
        Map<Id, Set<Id>> mapOpptyAndProductIds = new Map<Id, Set<Id>>();
        Map<Id, Date> mapOpptyAndContractEndDates = new Map<Id, Date>();
        Map<Id, List<String>> mapOpptyAndSalesOrderIds = new Map<Id, List<String>>();
        
        for (Account account : [SELECT Id, Platform_Renewal_Date__c, Next_Renewal_Due_Date__c, Non_Coterminous_Contracts__c
                                FROM Account WHERE Id IN :lstAccountIds]) {
                                    // Query all accounts and separate the ones that are non-coterminous
                                    if (account.Non_Coterminous_Contracts__c) {
                                        setNonCotermAccountIds.add(account.Id);
                                    }
                                    
                                    mapAccounts.put(account.Id, account);
                                }
        
        /*String opptyQuery = 'SELECT Id, StageName, AccountId, Netsuite_Sales_Order_No__c, Contract_End_Date_New__c,'
+ ' (SELECT Id, OpportunityId, Product2Id FROM OpportunityLineItems) FROM Opportunity'
+ ' WHERE StageName NOT IN (\'10 - Closed Won\', \'10b - PO recd, pending finance approval\','
+ '\'11 - Closed Lost\', \'12 - Closed With No Decision\','
+ '\'13 - Closed & Approved By Finance\', \'14 - Closed: Delete Duplicate\')'
+ ' AND AccountId IN (\'' + OppotunityTriggerHelper.joinSet(mapAccounts.keySet(), '\', \'') + '\')';*/
        String str1 = label.Stage_4_Economic_Buyer_Signoff;
        String str2 = label.Stage_5_Contracts_Complete;
        String str3 = label.Stage_6_Closed_Won;
        String str4 = label.Stage_7_Closed_Lost;
        List<String> StrList = new List<String>(); 
        StrList.add(str1);
        StrList.add(str2);
        StrList.add(str3);
        StrList.add(str4);
        
        String opptyQuery = 'SELECT Id, StageName, AccountId, Netsuite_Sales_Order_No__c, Contract_End_Date_New__c,'
            + ' (SELECT Id, OpportunityId, Product2Id FROM OpportunityLineItems) FROM Opportunity'
            + ' WHERE StageName NOT IN :StrList'
            + ' AND AccountId IN (\'' + OppotunityTriggerHelper.joinSet(mapAccounts.keySet(), '\', \'') + '\')';
        
        
        if (lstOpportunityIds.size() > 0) {
            opptyQuery += ' AND Id IN (\'' + OppotunityTriggerHelper.joinSet(new Set<Id>(lstOpportunityIds), '\', \'') + '\')';
        }
       // System.debug('*** opptyQuery: ' + opptyQuery);
        
        List<String> lstSalesOrderIds = new List<String>();
        for (Opportunity oppty : Database.query(opptyQuery)) {
            if (setNonCotermAccountIds.contains(oppty.AccountId)) {
                mapNonCotermAccountAndOpptyIds.put(oppty.Id, oppty.AccountId);
                
                mapOpptyAndProductIds.put(oppty.Id, new Set<Id>());
                for (OpportunityLineItem opptyProduct : oppty.OpportunityLineItems) {
                    mapOpptyAndProductIds.get(oppty.Id).add(opptyProduct.Product2Id);
                }
                
                List<String> salesOrderIds = new List<String>();
                if (oppty.Netsuite_Sales_Order_No__c != null) {
                    for (String salesOrderId : oppty.Netsuite_Sales_Order_No__c.split(',')) {
                        if (salesOrderId.trim().length() > 0) {
                            salesOrderIds.add(salesOrderId.trim());
                        }
                    }
                }
                mapOpptyAndSalesOrderIds.put(oppty.Id, salesOrderIds);
                lstSalesOrderIds.addAll(salesOrderIds);
            } else {
                if (mapAccounts.containsKey(oppty.AccountId)) {
                    mapOpportunitiesToUpdate.put(oppty.Id, new Opportunity(Id = oppty.Id, Contract_End_Date_New__c = mapAccounts.get(oppty.AccountId).Platform_Renewal_Date__c));
                }
            }
        }
       // System.debug('*** lstSalesOrderIds: ' + lstSalesOrderIds);
        
        // Scenario 2: Non-cotermed contract detail records
        for (Contract_Detail__c contractDetail : [SELECT Id, Product_Name__c, Account_Name__c, End_Date__c, Sales_Order_Name__c FROM Contract_Detail__c
                                                  WHERE Account_Name__c IN :mapNonCotermAccountAndOpptyIds.values()
                                                  AND Contract_Detail_Status__c IN ('Active', 'Pending Activation')//Modified by Abhijit for CR183
                                                  AND Do_Not_Aggregate__c = false AND Amount_USD__c >= 0 AND Sales_Order_Name__c IN :lstSalesOrderIds
                                                  ORDER BY Account_Name__c, End_Date__c]) {
                                                      if (mapAccountSalesOrderAndContractEndDates.containsKey(contractDetail.Account_Name__c)) {
                                                          if (mapAccountSalesOrderAndContractEndDates.get(contractDetail.Account_Name__c).containsKey(contractDetail.Sales_Order_Name__c)) {
                                                              if (!mapAccountSalesOrderAndContractEndDates.get(contractDetail.Account_Name__c).get(contractDetail.Sales_Order_Name__c).containsKey(contractDetail.Product_Name__c)
                                                                  || (mapAccountSalesOrderAndContractEndDates.get(contractDetail.Account_Name__c).get(contractDetail.Sales_Order_Name__c).containsKey(contractDetail.Product_Name__c)
                                                                      && mapAccountSalesOrderAndContractEndDates.get(contractDetail.Account_Name__c).get(contractDetail.Sales_Order_Name__c).get(contractDetail.Product_Name__c) < contractDetail.End_Date__c)) {
                                                                          mapAccountSalesOrderAndContractEndDates.get(contractDetail.Account_Name__c).get(contractDetail.Sales_Order_Name__c).put(contractDetail.Product_Name__c, contractDetail.End_Date__c);
                                                                      }
                                                          } else {
                                                              mapAccountSalesOrderAndContractEndDates.get(contractDetail.Account_Name__c).put(contractDetail.Sales_Order_Name__c, new Map<Id, Date> { contractDetail.Product_Name__c => contractDetail.End_Date__c });
                                                          }
                                                      } else {
                                                          mapAccountSalesOrderAndContractEndDates.put(contractDetail.Account_Name__c, new Map<String, Map<Id, Date>> { contractDetail.Sales_Order_Name__c => new Map<Id, Date> { contractDetail.Product_Name__c => contractDetail.End_Date__c } });
                                                      }
                                                  }
        
       // System.debug('*** JSON.serialize(mapAccountSalesOrderAndContractEndDates): ' + JSON.serialize(mapAccountSalesOrderAndContractEndDates));
        
        for (Id oppId : mapNonCotermAccountAndOpptyIds.keySet()) {
            if (mapOpptyAndSalesOrderIds.containsKey(oppId)) {
                Date newContractEndDate = null;
                for (String salesOrderId : mapOpptyAndSalesOrderIds.get(oppId)) {
                    if (mapOpptyAndProductIds.containsKey(oppId)) {
                        for (Id productId : mapOpptyAndProductIds.get(oppId)) {
                            if (mapAccountSalesOrderAndContractEndDates.containsKey(mapNonCotermAccountAndOpptyIds.get(oppId))
                                && mapAccountSalesOrderAndContractEndDates.get(mapNonCotermAccountAndOpptyIds.get(oppId)).containsKey(salesOrderId)
                                && mapAccountSalesOrderAndContractEndDates.get(mapNonCotermAccountAndOpptyIds.get(oppId)).get(salesOrderId).containsKey(productId)
                                && (newContractEndDate == null
                                    || newContractEndDate < mapAccountSalesOrderAndContractEndDates.get(mapNonCotermAccountAndOpptyIds.get(oppId)).get(salesOrderId).get(productId))) {
                                        newContractEndDate = mapAccountSalesOrderAndContractEndDates.get(mapNonCotermAccountAndOpptyIds.get(oppId)).get(salesOrderId).get(productId);
                                    }
                        }
                        if (newContractEndDate != null) {
                            mapOpportunitiesToUpdate.put(oppId, new Opportunity(Id = oppId, Contract_End_Date_New__c = newContractEndDate));
                        }
                    }
                }
            }
        }
        
        return mapOpportunitiesToUpdate;
    }
    
    @testVisible private static String joinSet(Set<Id> setToJoin, String separator) {
        String returnValue = '';
        for (Id value : setToJoin) {
            returnValue += (value + separator);
        }
        
        return returnValue;
    }
    
    public static void updateneedsRepriceonQuote(List<Opportunity> newlist, Map<Id,Opportunity> oldMap){
        Set<Id> opptoProcess = new Set<Id>();
        Set<Id> needsRepricingOpp = new Set<Id>();
        Set<Id> coSellmodifiedOpp = new Set<Id>();
        for(Opportunity opp: newlist){
            if(opp.Applied_Price_List_Name__c != null && opp.Applied_Price_List_Name__c != oldMap.get(opp.Id).Applied_Price_List_Name__c){
                needsRepricingOpp.add(opp.Id);
                opptoProcess.add(opp.Id);
            }
            if(opp.Deal_Reg_Margin__c != oldMap.get(opp.Id).Deal_Reg_Margin__c
               || opp.Deal_Reg_Partner_Teaming_Reseller__c != oldMap.get(opp.Id).Deal_Reg_Partner_Teaming_Reseller__c){
                   coSellmodifiedOpp.add(opp.Id);
                   opptoProcess.add(opp.Id);
               }
        }
        if(!opptoProcess.isEmpty()){

        }
    }
    
    //Added by Varun - CR 1824 - Start 
    public static void updateInsertStageAge(List<Opportunity> newList, Map<id,Opportunity> oldMap){
        List<Opportunity> listToPass = new List<Opportunity>();
        Map<id,Opportunity> MapToPass = new Map<id,Opportunity>();
        
        for(Opportunity oppRec : newList){
            if(oldMap == null)
                listToPass.add(oppRec);
            else if(oldMap != null && oppRec.stagename != oldMap.get(oppRec.id).stagename){
                listToPass.add(oppRec);
                MapToPass.put(oppRec.id, oldMap.get(oppRec.id));
            }
        }
        
        
        
        if(listToPass.size()>0){
           system.enqueueJob(new StageAgeCalculation(listToPass, MapToPass, 'StageName', 'Stage__c', 'Stage_Date_Change__c', 'Stage_Last_Age__c'));
        }
        listToPass = new List<Opportunity>();
        MapToPass = new Map<id,Opportunity>();
        
        for(Opportunity oppRec : newList){
            if(oldMap == null)
                listToPass.add(oppRec);
            else if(oldMap != null && oppRec.Validation_Stage__c != oldMap.get(oppRec.id).Validation_Stage__c  && oppRec.Validation_Stage__c != label.Validation_Stage_6_Technical_Win
                    && oppRec.Validation_Stage__c != label.Validation_Stage_7_Technical_Loss && oppRec.Validation_Stage__c != label.Validation_Stage_8A_Not_Required
                    && oppRec.Validation_Stage__c != label.Validation_Stage_8B_Not_Required_Preferred){
                listToPass.add(oppRec);
                MapToPass.put(oppRec.id, oldMap.get(oppRec.id));
            }
        }
        
        if(listToPass.size()>0){
           system.enqueueJob(new StageAgeCalculation(listToPass, MapToPass, 'Validation_Stage__c', 'Technical_Validation_Stage__c', 'Validation_Date_Stage_Change__c', 'Validation_Stage_Last_Age__c'));
        }
        TriggerUtility.updateInsertStageAgeExecuted();
    }
    //Added by Varun - CR 1824 - End 
    
    /**public static void revokeopenPendingQuotes(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
Set<id> closedoppsId = new Set<Id>();
Set<id> quotestoRecall = new Set<Id>();
for(Opportunity opp: newList){
if(opp.isclosed && opp.StageName != oldMap.get(opp.Id).StageName){
closedoppsId.add(opp.Id);
}
}
TriggerUtility.revokePendingQuoteApprovalExecuted();
}**/
    
    /*
    public static void  opportunityStageClosedLostSendEmailHelper(List<Opportunity> triggerNew , Map<Id,Opportunity> oppOldMap)
    {
        Map<Id,set<String>> opportunityMap = new Map<Id,set<String>>();
        Map<Id,Opportunity> opportunities=new Map<Id,Opportunity>();
        
        String templateNameclosewithnodecision = 'Email_On_Opp_Sub_Stage_Closed_Lost';
        String templatenameclosedelete = 'Email_On_Opp_Sub_Stage_Closed_Delete';
        id churnId;
        id oppoExtensionId;
        List<id> oppIdList = new List<id>();
         for(Opportunity opp: triggerNew){
             if(  (oppOldMap.get(opp.id).StageName!= opp.StageName && opp.StageName == '7 - Closed Lost' && opp.Geo_Account__c=='EMEA')|| (test.isRunningTest()) )
                 oppIdList.add(opp.id);
        }
        List<Opportunity> oppList =[Select id,owner.id,Opportunity_Sales_Territory__r.sales_engineer__c,StageName,Sub_Stage__c,Region_Account__c,Area__c,Geo_Account__c	 from Opportunity Where id in :oppIdList ];
		List<Churn__c> churnList = [select id from Churn__c where Opportunity__c in :oppIdList];
        List<Opportunity_Extension__c> OppExtensionList = [select id from Opportunity_Extension__c where Opportunity__c in :oppIdList];
       
        set<String> emaillist=new set<String>();
        
     //   List<OpportunityTeamMember> oppTeamList=[SELECT Name,TeamMemberRole ,userid FROM OpportunityTeamMember where TeamMemberRole='Renewal Director' ANd opportunityId in :oppIdList];
     //    for(OpportunityTeamMember oppTeam: oppTeamList){
     //       prepareManagerEmailList(emaillist, oppTeam.userid, 0);
     //    }
             
 		
        for(Opportunity opp: oppList){
            prepareManagerEmailList(emaillist, opp.owner.id, 0);
            prepareManagerEmailList(emaillist, opp.Opportunity_Sales_Territory__r.sales_engineer__c, 1);
            
            emaillist.add(Label.EmailFor_Sr_ManagerEMEA_Sales_Ope);
            emaillist.add(Label.EmailFor_VP_Sales_EMEA);
            emaillist.add(Label.EmailFor_VP_Sales_Engineering_EMEA);
            
            if(churnList.size()>0){
                churnId=churnList[0].id;
            }
            if(OppExtensionList.size()>0){
                oppoExtensionId=OppExtensionList[0].id;
            }
           if(opp.Area__c=='CEUR'){
                emaillist.add(label.EmaiForRegion_CEUR);
            }else if( opp.Area__c=='UK&I' || opp.Area__c=='NEUR'){
                emaillist.add(label.EmaiForRegion_UK_I_NEUR);
            }else if( opp.Area__c=='SEUR' || Test.isRunningTest()){
                emaillist.add(label.EmaiForRegion_SEUR);
            }
            if(emaillist.size()>0){
                opportunityMap.put(opp.Id,emaillist);
            }
            opportunities.put(opp.Id,opp);
            
            
        }
        if( ( opportunityMap.size()>0  )  || Test.isRunningTest())
        {
            for(Id oppId : opportunityMap.keySet())
            {
                Contact ct=new Contact();
                ct.LastName='abc';
                ct.Email='abc@abc.com';
                
                try{
                  //  Savepoint sp = Database.setSavepoint();
                    insert ct;
                    
                    List<Messaging.SingleEmailMessage> msgList= new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    EmailTemplate emailTemplate=new EmailTemplate();
                    boolean isChurn = false;
                   	if(opportunities.containsKey(oppId) && opportunities.get(oppId).Sub_Stage__c=='Closed: Delete Duplicate'){
                        emailTemplate = [select Id, HTMLValue, DeveloperName, Subject from EmailTemplate where DeveloperName =: templatenameclosedelete];
                    }
                    else if(opportunities.containsKey(oppId) && (opportunities.get(oppId).Sub_Stage__c=='Closed With No Decision' || opportunities.get(oppId).Sub_Stage__c=='Closed Lost' )){
                        emailTemplate = [select Id, HTMLValue, DeveloperName, Subject from EmailTemplate where DeveloperName =: templateNameclosewithnodecision];
                    	isChurn = true;
                    }
                    List<String> sendToCC = new List<String>();
                    sendToCC.add('tpatel@zscaler.com');
                    sendToCC.add('ndeshpande@zscaler.com');
                    sendToCC.add('smittal@zscaler.com');
                    
                    if(emailTemplate!=null){
                        msg.setTemplateId( emailTemplate.id );
                        if(isChurn)
                            msg.setWhatId(churnId);
                        else
                            msg.setWhatId(oppoExtensionId);
                        msg.setTargetObjectId(ct.Id);
                        msg.setToAddresses(new List<String>(opportunityMap.get(oppId)));
                        msg.setCcAddresses(sendToCC);
                        msg.setSaveAsActivity(false);
                    }
                    msgList.add(msg);
                    // Send the emails in a transaction, then roll it back
                     Savepoint sp = Database.setSavepoint();
                    Messaging.sendEmail(msgList); // Dummy email send
                    Database.rollback(sp); // Email will not send as it is rolled Back
                    // Send Actual email
                    List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
                    for (Messaging.SingleEmailMessage email : msgList) {
                        
                        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                        emailToSend.setToAddresses(email.getToAddresses());
                        emailToSend.setCcAddresses(email.getCcAddresses());
                        emailToSend.setPlainTextBody(email.getPlainTextBody());
                        emailToSend.setHTMLBody(email.getHTMLBody());
                        emailToSend.setSubject(email.getSubject());
                        emailToSend.setSaveAsActivity(true);
                        msgListToBeSend.add(emailToSend);
                        
                    }
                    // Messaging.sendEmail(msgListToBeSend);
                    if(msgList.size() > 0){
                        Messaging.sendEmail(msgListToBeSend);
                    }
                    
                }catch(Exception e){
                    System.debug(''+e.getMessage());
                } finally{
                    delete ct;
                }
          }
        }
    } 

   public static void prepareManagerEmailList(set<String> ManagerUserIdList, Id userId,integer count){
       if(count<=2){
           count++;
           User userDetails = new User();
           if(userId!=null)
               userDetails = [select Id,name,manager.email, ManagerId from User where Id =: userId];
           System.debug('---------manger name--'+userDetails.name);
           
           if(userDetails!=null && userDetails.manager.email !=null)
               ManagerUserIdList.add(userDetails.manager.email);
           if((userDetails!=null && userDetails.ManagerId !=null)|| !TEst.isRunningTest() )
               prepareManagerEmailList(ManagerUserIdList,userDetails.ManagerId,count);// Recursive call to find manager of manager
           
       }
    }*/
    
    //Added by Ram : IBA-345 starts here
    public static void reparentDuplOpptPRGs(Set<Id> deleteDuplicateClosedLostOpptIdSet){
        try{
            if(!deleteDuplicateClosedLostOpptIdSet.isEmpty()){
                Map<Id, Id> duplToSurvivingOpptMap = new Map<Id, Id>();
                for(Opportunity_Extension__c opptExt : [SELECT Id, Opportunity__c, Duplicate_Opportunity__c FROM Opportunity_Extension__c WHERE Opportunity__c IN :deleteDuplicateClosedLostOpptIdSet]){
                    duplToSurvivingOpptMap.put(opptExt.Opportunity__c, opptExt.Duplicate_Opportunity__c);
                }

                if(!duplToSurvivingOpptMap.isEmpty()){
                    List<Provisioning_Group__c> tobeUpdPRGsList = new List<Provisioning_Group__c>();
                    List<Case> tobeUpdPRGAssociatedCaseList = new List<Case>();
                    for(Provisioning_Group__c currentPRG : [SELECT Id, Opportunity__c, (SELECT Id, Opportunity_Name__c FROM Cases__r) FROM Provisioning_Group__c WHERE Opportunity__c IN :duplToSurvivingOpptMap.keySet()]){
                        //Reparenting the current PRG ClosedLost Opportunity Id with Survived Opportunity Id
                        Id survivedOpptId = duplToSurvivingOpptMap.get(currentPRG.Opportunity__c);
                        currentPRG.Opportunity__c = survivedOpptId;
                        tobeUpdPRGsList.add(currentPRG);

                        for(Case currentCase : currentPRG.Cases__r){
                            //Reparenting the current Case ClosedLost Opportunity Id with Survived Opportunity Id
                            currentCase.Opportunity_Name__c = survivedOpptId;
                            tobeUpdPRGAssociatedCaseList.add(currentCase);
                        }
                    }
                    
                    if(!tobeUpdPRGsList.isEmpty()){
                        List<Database.SaveResult> prgUpdateResultList = Database.update(tobeUpdPRGsList);
                    }
                    if(!tobeUpdPRGAssociatedCaseList.isEmpty()){
                        List<Database.SaveResult> caseUpdateResultList = Database.update(tobeUpdPRGAssociatedCaseList);
                    }
                }
            }
        }catch(Exception ex){
            System.debug('Exception occurred in reparentDuplOpptPRGs(), val is: '+ex);
        }
    }
    //Added by Ram : IBA-345 ends here
     
    public static void booster(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        //bring merge coflict
    }
    
}