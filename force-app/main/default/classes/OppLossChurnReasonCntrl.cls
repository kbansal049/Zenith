public class OppLossChurnReasonCntrl { 
    
    @AuraEnabled 
    public static initdata getInitData(string oppId){
        initdata initRecord = new initdata(); 
        try{
            initRecord.isZIAproduct = Util_ChurnReasonMethods.isZIApresent(oppId);
            initRecord.isZPAproduct = Util_ChurnReasonMethods.isZPApresent(oppId);
            initRecord.opportunityRecordType = Util_ChurnReasonMethods.getOpportunityRecordType(oppId);
            initRecord.activeEncloserQuestion = isActivePRpresentOnOpp(oppId);

            
            Opportunity oppObj = [SELECT Id, Name,Account.Name,Geo_Account__c, Opportunity_Territory_Type__c,
                                  (select ProductCode from OpportunityLineItems),Amount, recordType.Name,
                                  StageName,Validation_Stage__c,Confirm_Opportunity_Closure__c, Owner.Name, Type,Primary_Partner__c
                                  FROM Opportunity WHERE Id =: oppId]; 
            if(oppObj != null){
                initRecord.Accountname = oppObj.Account.Name;
                initRecord.Opportunityname = oppObj.Name;
                initRecord.oppType = oppObj.Type;
                initRecord.oppStage = oppObj.StageName;
                initRecord.technicalStage = oppObj.Validation_Stage__c;
                initRecord.primaryPartner = oppObj.Primary_Partner__c;
                if(oppObj.Amount != null){
                    initRecord.lostAmount = oppObj.Amount.setScale(2);
                }
                initRecord.geo = oppObj.Geo_Account__c;
                initRecord.territoryType = oppObj.Opportunity_Territory_Type__c; 
                initRecord.owner = oppObj.Owner.Name; 
                initRecord.oppCloser = oppObj.Confirm_Opportunity_Closure__c; 
                
                string productsLost = '';
                if(oppObj.OpportunityLineItems != null)
                    for(OpportunityLineItem rec:oppObj.OpportunityLineItems){
                        if(productsLost == '' ){
                            productsLost = rec.ProductCode;
                        }
                        else{
                            productsLost = productsLost + ',' + rec.ProductCode;
                        }
                    }
                initRecord.productLost=productsLost;
            }
            
        }catch(Exception e){
            throw new AuraHandledException('Error Exception happend'+e.getMessage()); 
        }
        return initRecord;         
    }
    
    
    @AuraEnabled
    public static pickListWrap getPickListData(string oppId){
        pickListWrap pickListWrapRecord = new pickListWrap();
        try{
            if(getPicklistValues('Churn__c','Opp_Loss_Primary_Reason__c') != null){
                pickListWrapRecord.primaryReasonList = getPicklistValues('Churn__c','Opp_Loss_Primary_Reason__c');
                pickListWrapRecord.secondaryReasonList = getPicklistValues('Churn__c','Opp_Loss_Primary_Reason__c');
            }
            pickListWrapRecord.ZIAprimaryReasonList = getPicklistValues('Churn__c','ExperienceFeaturesZIAPrimaryReason__c');
            pickListWrapRecord.ZIAsecondaryReasonList = getPicklistValues('Churn__c','ExperienceFeaturesZIASecondaryReason__c');
            pickListWrapRecord.ZPAprimaryReasonList = getPicklistValues('Churn__c','ExperienceFeaturesZPAPrimaryReason__c');
            pickListWrapRecord.ZPAsecondaryReasonList = getPicklistValues('Churn__c','ExperienceFeaturesZPASecondaryReason__c');
            pickListWrapRecord.OtherPrimaryReasonList = getPicklistValues('Churn__c','Other_Primary_Reason__c');
            pickListWrapRecord.OthersecondaryReasonList = getPicklistValues('Churn__c','Other_Secondary_Reason__c');
            pickListWrapRecord.LifeTimePrimaryReasonList = getPicklistValues('Churn__c','Lifetime_Value_Primary_Reason__c');
            pickListWrapRecord.LifeTimesecondaryReasonList = getPicklistValues('Churn__c','Lifetime_Value_Secondary_Reason__c');
            pickListWrapRecord.RenewalQuestionList = getPicklistValues('Churn__c','Renewalquestion__c');
            pickListWrapRecord.ZIAPrimaryCompetitorsList = getPicklistValues('Churn__c','ZIA_Primary_Competitor__c');
            pickListWrapRecord.ZIASecondaryCompetitorsList = pickListWrapRecord.ZIAPrimaryCompetitorsList;
            pickListWrapRecord.ZPAPrimaryCompetitorsList = getPicklistValues('Churn__c','ZPA_Primary_Competitor__c');
            pickListWrapRecord.ZPASecondaryCompetitorsList = pickListWrapRecord.ZPAPrimaryCompetitorsList;
            
            pickListWrapRecord.DonotrenewSupportList = getPicklistValues('Churn__c','DonotrenewSupportProducts__c');
            pickListWrapRecord.DonotrenewZIAList = getPicklistValues('Churn__c','DonotrenewZIAProducts__c');
            pickListWrapRecord.DonotrenewZPAList = getPicklistValues('Churn__c','DonotrenewZPAProducts__c');
            pickListWrapRecord.PriceAsAFactor = getPicklistValues('Churn__c','Price_As_A_Factor__c');
            pickListWrapRecord.LostCallList = getPicklistValues('Churn__c','Lost_Analysis_Call__c');   
        }catch(Exception e){
            throw new AuraHandledException('Error Exception happend'+e.getMessage()); 
        }
        return pickListWrapRecord;
    }
    
    @AuraEnabled
    public static List<Significant_Customer_Interaction__c> getSCIrecords(String oppId){
        List<Significant_Customer_Interaction__c> sciList = new List<Significant_Customer_Interaction__c>();
        for(Significant_Customer_Interaction__c sciObj : [SELECT Id,Name,Date__c,Organizer__c,Type_of_Interaction__c,
                                                          Primary_Topic_Covered__c
                                                          FROM Significant_Customer_Interaction__c 
                                                          WHERE Opportunity_Name__c =: oppId])
        {
            sciList.add(sciObj);
        }   
        if(sciList != null && !sciList.isEmpty())
            return sciList;
        else
            return null;
    }
    
    
    @AuraEnabled
    public static List<SCIWrap> getSCIWraprecords(String oppId){
        List<SCIWrap> sciList = new List<SCIWrap>();
        for(Significant_Customer_Interaction__c sciObj : [SELECT Id,Name,Date__c,Organizer__c,Type_of_Interaction__c,
                                                          Primary_Topic_Covered__c
                                                          FROM Significant_Customer_Interaction__c 
                                                          WHERE Opportunity_Name__c =: oppId])
        {
            SCIWrap rec = new SCIWrap();
            rec.isChecked = false;
            rec.SCIRecord = sciObj;
            sciList.add(rec);
        }   
        if(sciList != null && !sciList.isEmpty())
            return sciList;
        else
            return null;
    }
    
    
    public class SCIWrap{
        @AuraEnabled public boolean isChecked{get;set;}
        @AuraEnabled public Significant_Customer_Interaction__c SCIRecord{get;set;}
    }
    
    
    
    public static list<pickList> getPicklistValues(String str, String fld){
        sObject obj = Schema.getGlobalDescribe().get(str).newSObject();
        list<pickList> options = new list<pickList>();
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType(); 
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values)
        { 
            options.add(new pickList(string.valueOf(a.getLabel()), string.valueOf(a.getValue()))); 
        }
        return options;
    }
    
    
    public static Boolean isActivePRpresentOnOpp(String oppId){
        Set<String> prStatusSet = new Set<String>();
        prStatusSet.add('Requested');
        prStatusSet.add('In Progress');
        prStatusSet.add('Provisioned');
        
        List<Provisioning_Request__c> countActivePR = [SELECT Id 
                                                       FROM Provisioning_Request__c 
                                                       WHERE Opportunity__c =: oppId AND Provisioning_Status__c IN: prStatusSet];
        
        //Integer countActivePR = [SELECT count() 
        //FROM Provisioning_Request__c 
        //WHERE Opportunity__c =: oppId AND Provisioning_Status__c IN: prStatusSet];
        return (countActivePR.size() != 0 && countActivePR != null) ? true :false;
    }
    
    @AuraEnabled
    public static saveResponse saveRecord(
        string recordId,
        String oppId,
        string SCINumber,
        boolean confirmEncloser,
        boolean isReductionCheck,
        boolean isDowngradingCheck,
        boolean isRenewAdvancedCheck,
        boolean isOtherCheck,
        Churn__c churnObj){
        system.debug(churnObj);
        Savepoint sp = Database.setSavepoint();
        saveResponse responseValue = new saveResponse();  
        try{
            Opportunity opp = [SELECT Id,Name,Stagename,recordType.Name, Confirm_Opportunity_Closure__c FROM Opportunity WHERE Id =: oppId LIMIT 1];
            if(oppId != null){
                if(opp.recordType.Name == 'Renewal Opportunity'){
                    churnObj.Type__c = 'Churn';
                }
                else{
                    churnObj.Type__c = 'Loss';
                }
                churnObj.Opportunity__c = oppId;
                //churnObj.Name = opp.Name+'_'+churnObj.Type__c;
                churnObj.Name__c = opp.Name + '_' + churnObj.Type__c;
                if(confirmEncloser == true){
                    opp.Confirm_Opportunity_Closure__c = true;
                }
                if(recordId != null && recordId != ''){
                    churnObj.Id = recordId;
                }
                
                if(churnObj.Lost_Analysis_Call__c == 'Call Conducted'){
                    if(SCINumber != null &&  SCINumber != ''){
                        churnObj.SCINumber__c = SCINumber;
                    }
                    else{
                        churnObj.SCINumber__c = null;
                    }
                }
                else{
                    churnObj.SCINumber__c = null;
                } 
                
                Set<String> churnTypes = new Set<String>();
                if(isReductionCheck == true){
                    churnTypes.add('Reduction in Seats');
                }
                if(isDowngradingCheck == true){
                    churnTypes.add('Downgrading to a Lower Bundle');
                }
                if(isRenewAdvancedCheck == true){
                    churnTypes.add('Did not Renew Advanced features');
                }
                if(isOtherCheck == true){
                    churnTypes.add('Other (If other, state reason)');
                }
                churnObj.Type_of_Churn__c = '';
                for(string churnType : churnTypes){
                    if(churnObj.Type_of_Churn__c != ''){
                        churnObj.Type_of_Churn__c = churnObj.Type_of_Churn__c + ';' + churnType;
                    }
                    else{
                        churnObj.Type_of_Churn__c = churnType;
                    }
                }
                if(churnObj.ZIA_Primary_Competitor__c != 'Other'){
                    churnObj.ZIA_Other_Primary_Competitor__c = '';
                }
                 if(churnObj.ZIA_Secondary_Competitor__c != 'Other'){
                    churnObj.ZIA_Other_Secondary_Competitor__c = '';
                }
                if(churnObj.ZPA_Primary_Competitor__c != 'Other'){
                    churnObj.ZPA_Other_Primary_Competitor__c = '';
                }
                if(churnObj.ZPA_Secondary_Competitor__c != 'Other'){
                    churnObj.ZPA_Other_Secondary_Competitor__c = '';
                }
                if(churnObj.Renewalquestion__c != 'Other'){
                    churnObj.Renewal_Question_Notes__c = '';
                }
                
                
                Id RecordTypeIdChurn = Schema.SObjectType.Churn__c.getRecordTypeInfosByName().get('Renewals').getRecordTypeId();
                churnObj.RecordTypeId = RecordTypeIdChurn;
                upsert churnObj;
                //update opp;
                system.debug('#LOG:'+churnObj.Id);
                
                if(recordId != null && recordId != ''){
                    //return churnObj.Id;
                    responseValue.result = churnObj.Id;
                    responseValue.status = true;
                }
                else{
                    //return opp.Id;
                    responseValue.result = opp.Id;
                    responseValue.status = true;
                }
            }
        }
        catch(Exception e){
            //ApexPages.addMessages(e);system.debug('here Form error: '+ e);
            //return e.getMessage();
            Database.rollback(sp);
            system.debug('the Exception is' + e.getMessage());
            String errorMsg = '';
            if(e.getMessage().contains('A Primary Technology Partner is Required to Move Stages')){
                errorMsg = 'A Primary Technology Partner is Required to Move Stages';
            }
            else{
                errorMsg = e.getMessage();
            }
            responseValue.exceptionMsg = errorMsg;
            responseValue.status = false;
        }
        return responseValue;
    }
    
    
  	@AuraEnabled
    public static Churn__c getChuran(String recordId){
        List<Churn__c> churnLst = new List<Churn__c>();
        churnLst = [Select id,Name
                            ,Type__c
                            ,Opportunity__c
                            ,Opportunity__r.StageName
                            //,TransformationPrimaryReason__c
                            //,TransformationSecondaryReason__c
                            ,ExperienceFeaturesZPAPrimaryReason__c
                            ,ExperienceFeaturesZPASecondaryReason__c
                            ,ExperienceFeaturesZIAPrimaryReason__c
                            ,ExperienceFeaturesZIASecondaryReason__c
                            ,Engagement_Primary_Reason__c
                            ,Engagement_Secondary_Reason__c
                            ,Other_Primary_Reason__c
                            ,Other_Secondary_Reason__c
                            ,Lifetime_Value_Primary_Reason__c
                            ,Lifetime_Value_Secondary_Reason__c
                            ,ExperienceMissingfunctionality__c
                            ,PrimaryCompetitor__c
                            ,Secondary_Competitors__c
                            ,AdditionalNotes__c
                            ,Renewalquestion__c
                            ,SCINumber__c
                            ,LossAnalysisCall__c
                            ,Apps_Moved_To_The_Cloud__c
                            ,Branch_Breakout__c
                            ,Engagement__c
                            ,Executive_Engagement__c
                            ,Had_Internal_Champion__c
                            ,Implementing_Zero_Trust__c
                            ,Opp_Loss_Secondary_Reason__c
                            ,Opp_Loss_Primary_Reason__c
                            ,Price_Were_Low__c
                            ,QBRs_Were_Held_Regularly__c
                            ,Regular_Meeting__c
                            ,Relationships_With_Teams__c
                            ,SSL_inspection__c
                            ,Zapp_deployments__c
                            ,Features_ZIA_Primary_Reason_Notes__c
                            ,Features_ZPA_Primary_Reason_Notes__c
                            ,Lifetime_Value_Primary_Reason_Notes__c
                            ,Opp_Loss_Primary_Reason_Notes__c
                            ,Other_Primary_Reason_Notes__c
                            //,Transformation_Primary_Reason_Notes__c
                            ,SCINumber__r.Name
                    		,Opp_Loss_OtherPrimary_Notes__c
                    		,Opp_Loss_OtherSecondary_Notes__c
							,Opp_Loss_Secondary_Reason_Notes__c
							,Others__c
							,Other_Secondary_Reason_Notes__c
							,Type_of_Churn__c
							,ZIA_Other_Primary_Competitor__c
							,ZIA_Other_Secondary_Competitor__c
							,ZIA_Primary_Competitor__c
							,ZIA_Secondary_Competitor__c
							,ZPA_Other_Primary_Competitor__c
							,ZPA_Other_Secondary_Competitor__c
							,ZPA_Primary_Competitor__c
							,ZPA_Secondary_Competitor__c
							,Features_ZIA_Secondary_Reason_Notes__c
							,Features_ZPA_Secondary_Reason_Notes__c
							,Lifetime_Value_Secondary_Reason_Notes__c
							,Name__c
							,DowngradingFrom__c
							,DowngradingTo__c
							,DonotrenewZIAProducts__c
							,DonotrenewZPAProducts__c
							,DonotrenewSupportProducts__c
							,Price_As_A_Factor__c
							,Lost_Analysis_Call__c
                    		,Renewal_Question_Notes__c
							From Churn__c Where id=:recordId];
        if(!churnLst.isEmpty()){
            return churnLst[0];
        }
        else{
            return new Churn__c();        
        }
    }     
    
    public class initdata {
        @AuraEnabled public boolean isZIAproduct{get;set;} 
        @AuraEnabled public boolean isZPAproduct{get;set;} 
        @AuraEnabled public string SCINumber{get;set;} 
        @AuraEnabled public string opportunityRecordType{get;set;} 
        @AuraEnabled public Opportunity oppObj{get;set;} 
        @AuraEnabled public boolean activeEncloserQuestion{get;set;} 
        @AuraEnabled public string Accountname{get;set;} 
        @AuraEnabled public string Opportunityname{get;set;} 
        @AuraEnabled public string oppType{get;set;} 
        @AuraEnabled public string oppStage{get;set;} 
        @AuraEnabled public string technicalStage{get;set;} 
        @AuraEnabled public string primaryPartner{get;set;} 
        @AuraEnabled public decimal lostAmount{get;set;} 
        @AuraEnabled public string geo{get;set;} 
        @AuraEnabled public string territoryType{get;set;} 
        @AuraEnabled public string owner{get;set;} 
        @AuraEnabled public string productLost{get;set;} 
        @AuraEnabled public boolean oppCloser{get;set;} 
        //@AuraEnabled public string oppType{get;set;}
        
    }
    
    public class pickListWrap{
        @AuraEnabled public list<pickList> primaryReasonList{get;set;} 
        @AuraEnabled public list<pickList> secondaryReasonList{get;set;} 
        @AuraEnabled public list<pickList> ZIAprimaryReasonList{get;set;} 
        @AuraEnabled public list<pickList> ZIAsecondaryReasonList{get;set;} 
        @AuraEnabled public list<pickList> ZPAprimaryReasonList{get;set;} 
        @AuraEnabled public list<pickList> ZPAsecondaryReasonList{get;set;} 
        @AuraEnabled public list<pickList> OtherPrimaryReasonList{get;set;} 
        @AuraEnabled public list<pickList> OthersecondaryReasonList{get;set;} 
        @AuraEnabled public list<pickList> LifeTimePrimaryReasonList{get;set;} 
        @AuraEnabled public list<pickList> LifeTimesecondaryReasonList{get;set;}
        @AuraEnabled public list<pickList> RenewalQuestionList{get;set;} 
        @AuraEnabled public list<pickList> ZIAPrimaryCompetitorsList{get;set;}
        @AuraEnabled public list<pickList> ZIASecondaryCompetitorsList{get;set;}
        @AuraEnabled public list<pickList> ZPAPrimaryCompetitorsList{get;set;}
        @AuraEnabled public list<pickList> ZPASecondaryCompetitorsList{get;set;}
        @AuraEnabled public list<pickList> downgradingList{get;set;}
        
        @AuraEnabled public list<pickList> DonotrenewSupportList{get;set;}
        @AuraEnabled public list<pickList> DonotrenewZIAList{get;set;}
        @AuraEnabled public list<pickList> DonotrenewZPAList{get;set;}
        @AuraEnabled public list<pickList> PriceAsAFactor{get;set;}
        @AuraEnabled public list<pickList> LostCallList{get;set;}
    }
    
    public class pickList{
        @AuraEnabled public string label{get;set;} 
        @AuraEnabled public string value{get;set;} 
        public pickList(string label,string value){
            this.label = label;
            this.value = value;
        }
    }
    public class saveResponse{
        @AuraEnabled public boolean status{get;set;} 
        @AuraEnabled public string exceptionMsg{get;set;} 
        @AuraEnabled public string result{get;set;} 
    }
}