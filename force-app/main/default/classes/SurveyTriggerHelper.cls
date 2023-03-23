/*
 * Trigger on Survey Object
 *  Author              Version     Description
 *  Raghu Manchiraju    v1.0        Initial Trigger Helper. 
 * 
 */ 
public class SurveyTriggerHelper 
{
    
    public static boolean skipTrigger = false;
    public static Id tamAuditRT = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('TAM_Meeting_Audit').getRecordTypeId();

    public void OnBeforeInsert(List<Survey__c> newSurveys)
    {
        //updateExtension(newSurveys, null); //Anup : Commenting for CR987
        /*for(Survey__c sv : newSurveys)
        {
            Date currentDate = date.newinstance(sv.CreatedDate.year(), sv.CreatedDate.month(), sv.CreatedDate.day());
            sv.Reminder_1_Sent_Date__c = currentDate.addDays(5);
            sv.Reminder_2_Sent_Date__c = currentDate.addDays(8);
        }*/
        
        // Prashant's Code 
        //updateCaseOwnerManager(newSurveys); //Anup : Commenting as per CR987.
        //checking public domain for partner owned deployment project type survey
        //added by Pranav IBA 4445
        PublicDomainCheckHelper.publicDomainCheck(newSurveys);
        //IBA 4445 End
        //Added by Chetan IBA-5284 Start
        updateMailSentToCustomer(newSurveys);
        updateAccountStage(newSurveys);
        //Added by Chetan IBA-5284 End     
    }
    
    
    
    public void OnAfterInsert(List<Survey__c> newSurveys)
    {
       
     
    }
    
    public void OnBeforeUpdate(Map<Id,Survey__c> oldSurveys,Map<Id,Survey__c> newSurveys)
    {
        //Raviraj Added
        /*List<Survey__c> surveyList = new List<Survey__c>();
        for(Survey__c sur:newSurveys.values()){
            surveyList.add(sur);
        }
        updateCaseOwnerManager(surveyList);*/ //Anup : Commenting as per CR987.
        //Raviraj Added
        List<ID> userIDs = new List<ID>(); // added by Swathi CR:1640
        Map<Id, String> mapOfUserAndEmail= new Map<Id, String>();// added by Swathi CR:1640
        List<Survey__c> dsatneededlst = new List<Survey__c>();
        for(Survey__c sury : newSurveys.values())
        {
            Date currentDate = date.newinstance(sury.CreatedDate.year(), sury.CreatedDate.month(), sury.CreatedDate.day());
            sury.Reminder_1_Sent_Date__c = currentDate.addDays(5);
            sury.Reminder_2_Sent_Date__c = currentDate.addDays(8);
            //Added By Swathi: CR 1640 start
            if(sury.Project_Manager_Primary__c!=NULL){
                userIDs.add(sury.Project_Manager_Primary__c);    
            }
            if(sury.Project_Manager_Secondary__c!=Null){
                userIDs.add(sury.Project_Manager_Secondary__c);
            }
            if(sury.PS_Consultant_Primary__c!=Null){
                userIDs.add(sury.PS_Consultant_Primary__c);
            }
            if(sury.PS_Consultant_Secondary__c!=Null){
                userIDs.add(sury.PS_Consultant_Secondary__c);
            }
        	if(!userIDs.isEmpty()){
            	mapOfUserAndEmail = fetchMapOfUserAndEmail(userIDs);
        	}
            if(mapOfUserAndEmail.containsKey(sury.Project_Manager_Primary__c) && mapOfUserAndEmail.get(sury.Project_Manager_Primary__c) != null && mapOfUserAndEmail.get(sury.Project_Manager_Primary__c)!=''){
            	sury.Manager_of_Project_Manager_Primary__c = mapOfUserAndEmail.get(sury.Project_Manager_Primary__c);
            }
            if(mapOfUserAndEmail.containsKey(sury.Project_Manager_Secondary__c) && mapOfUserAndEmail.get(sury.Project_Manager_Secondary__c) != null && mapOfUserAndEmail.get(sury.Project_Manager_Secondary__c)!=''){
            	sury.Manager_of_Project_Manager_Secondary__c = mapOfUserAndEmail.get(sury.Project_Manager_Secondary__c);
            }
            if(mapOfUserAndEmail.containsKey(sury.PS_Consultant_Primary__c) && mapOfUserAndEmail.get(sury.PS_Consultant_Primary__c) != null && mapOfUserAndEmail.get(sury.PS_Consultant_Primary__c)!=''){
            	sury.Manager_of_PS_Consultant_Primary__c = mapOfUserAndEmail.get(sury.PS_Consultant_Primary__c);
            }
            if(mapOfUserAndEmail.containsKey(sury.PS_Consultant_Secondary__c) && mapOfUserAndEmail.get(sury.PS_Consultant_Secondary__c) != null && mapOfUserAndEmail.get(sury.PS_Consultant_Secondary__c)!=''){
            	sury.Manager_of_PS_Consultant_Secondary__c = mapOfUserAndEmail.get(sury.PS_Consultant_Secondary__c);
            }
            //Added By Swathi: CR 1640 end
            
            //Added By Arsh: CR 4513, CR 4692 start
            //Survey Response completion fields updates
            
            if((sury.Recommend_Zscaler_to_a_Friend__c != null && oldSurveys.get(sury.Id).Recommend_Zscaler_to_a_Friend__c == null)  //CS Survey field
              || (sury.Will_you_recommend_Zscaler__c != null && oldSurveys.get(sury.Id).Will_you_recommend_Zscaler__c == null ) ){ // partner, deployment, partner owned dep Survey field 
				sury.Completed_Date_Time__c = System.Now();
                sury.Survey_Response_Received__c = true;
                sury.Survey_Status__c = 'Response Received';
            }
            //Added By Arsh: CR 4513, CR 4692 end
            
            if(sury.Will_you_recommend_Zscaler__c != null) //&& oldSurveys.get(sury.Id).Will_you_recommend_Zscaler__c == null
            {
                sury.Survey_Response_Received__c = true;
                sury.Survey_Status__c = 'Response Received';
                
                //NPS
                if(sury.Will_you_recommend_Zscaler__c <=6)
                {
                    sury.NPS_Category__c='Detractor';
                }
                else if(sury.Will_you_recommend_Zscaler__c == 7 || sury.Will_you_recommend_Zscaler__c ==8)
                {
                    sury.NPS_Category__c= 'Passive';
                }
                else
                {
                    sury.NPS_Category__c= 'Promoter';
                }
                
                //CES
                if(sury.Easy_to_handle_Issue__c == '1 - Strongly Disagree' ||sury.Easy_to_handle_Issue__c == '2 - Disagree'
                   || sury.Easy_to_handle_Issue__c == '3 - Somewhat Disagree' || sury.Easy_to_handle_Issue__c == '4 - Neutral')
                {
                    sury.CES_Category__c = 'Detractor';
                }
                else if(sury.Easy_to_handle_Issue__c == '5 - Somewhat Agree')
                {
                    sury.CES_Category__c = 'Passive';
                }
                else
                {
                    sury.CES_Category__c = 'Promoter';
                }
                
                //CSAT
                if(sury.Rate_your_experience__c <=3)
                {
                    sury.CSAT_Category__c = 'Not Satisfied';
                    
                }
                else if(sury.Rate_your_experience__c >3 && sury.Rate_your_experience__c <=5)
                {
                    sury.CSAT_Category__c = 'Satisfied';
                }
                
                if((sury.Will_you_recommend_Zscaler__c >= 8 || sury.Rate_your_experience__c >3 || 
                  sury.Easy_to_handle_Issue__c == '6 - Agree' || sury.Easy_to_handle_Issue__c == '7 - Strongly Agree') &&
                   (sury.Survey_Outcome__c != 'DSAT Ticket Needed' && sury.Survey_Outcome__c != 'DSAT Ticket Created'))
                {
                    sury.Survey_Outcome__c = 'Positive Survey';
                }
                
                if(sury.Areas_that_could_have_been_handle_better__c != null){
                    sury.Areas_to_Improve__c = '';
                    sury.Areas_to_Improve_Other_Comments__c = '';
                     List<String> pickvals = sObjectPicklistValuesHelper.getPickListValues('Survey__c', 'Areas_to_Improve__c');
                     System.debug(pickvals);
                     if(!pickvals.isEmpty()){
                         //Added by Tirth Patel CR# 1055
                         sury.Areas_to_Improve_Other_Comments__c = sury.Areas_that_could_have_been_handle_better__c;
                         for(String s : pickvals)  {
                             if(sury.Areas_to_Improve_Other_Comments__c.contains(s))  {
                                 sury.Areas_to_Improve__c += s + ';';
                                 sury.Areas_to_Improve_Other_Comments__c = sury.Areas_to_Improve_Other_Comments__c.replace(s, '');
                             }  
                         } 
                         sury.Areas_to_Improve_Other_Comments__c = sury.Areas_to_Improve_Other_Comments__c.replace('|#|,','');
                         sury.Areas_to_Improve_Other_Comments__c = sury.Areas_to_Improve_Other_Comments__c.replace('|#|','');
                     }
                }
                
                if((sury.Will_you_recommend_Zscaler__c <=6 || sury.Easy_to_handle_Issue__c == '1 - Strongly Disagree' ||sury.Easy_to_handle_Issue__c == '2 - Disagree'
                   || sury.Easy_to_handle_Issue__c == '3 - Somewhat Disagree' || sury.Easy_to_handle_Issue__c == '4 - Neutral'
                  ||sury.Rate_your_experience__c <=3) &&
                   sury.DSAT_Ticket_Number__c == null)
                {
                    sury.Survey_Outcome__c = 'DSAT Ticket Needed';
                    dsatneededlst.add(sury);
                }
            }
            
        }
        if(!dsatneededlst.isEmpty() && !TriggerUtility.isDSATCaseCreationExecuted()){
            createDSATCases(dsatneededlst);
            TriggerUtility.DSATCaseCreationExecuted();
        }  
        updateExtension(newSurveys.values(), oldSurveys);
        
        //checking public domain for partner owned deployment project type survey
        //added by pranav IBA 4445
		PublicDomainCheckHelper.publicDomainCheck(newSurveys.values(), oldSurveys);
        //IBA 4445 End
    }
    //CR#-5100-Start
    @future(callout=true)
    public static void callGoogleTranslateAPI(String surveyData){
        Survey__c eachSurvey = (Survey__c)JSON.deserialize(surveyData,Survey__c.class);
        SurveyResponseTranslationController.makeGoogleApiCallout(eachSurvey);
    }
    //CR#-5100-End

    //Added By Swathi: CR 1640 start
	public static Map<Id, String> fetchMapOfUserAndEmail(List<Id> userIDs){
        Map<Id, String> mapOfUserAndEmail = new Map<Id, String>();
        for(User useremail : [select Id,Manager.Email from User where Id in :userIDs]){
            mapOfUserAndEmail.put(useremail.Id, useremail.Manager.Email);
        }
        if(!mapOfUserAndEmail.isEmpty()){
            return mapOfUserAndEmail;
        }
        else{
            return null;    
        }
        
    }     
    //Added By Swathi: CR 1640 end
    public void createDSATCases(List<Survey__c> surlst){
        Id caseDSATRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DSAT_Ticket').getRecordTypeId();
        List<Case> cslst = new List<Case>();
        Map<String, DefaultData__c> ddmap = DefaultData__c.getAll();
        
        String SurveyDefaultowner= ZscalerCustomSetting__c.getInstance('SurveyDefaultowner')!=null && ZscalerCustomSetting__c.getInstance('SurveyDefaultowner').Value__c!=null ? ZscalerCustomSetting__c.getInstance('SurveyDefaultowner').Value__c:'0050g00000665LtAAI';
        
        for(Survey__c sur: surlst){
            if(ddmap != null && !ddmap.isEmpty() && ddmap.containsKey('SurveyCaseDefaults')){
                DefaultData__c dd = ddmap.get('SurveyCaseDefaults');
                Case cs = new Case(RecordTypeId = caseDSATRT);
                cs.Case_Category__c = dd.Category__c;
                if(sur.Project_Name__c != null){
                    cs.Subject = 'Customer : ' ;
                    if(sur.Project_Customer_Name__c != null){
                        cs.Subject += sur.Project_Customer_Name__c  + ' ';
                    }
                    cs.Subject += 'is completely Dissatisfied on the Project - ' + sur.Project_Id__c;
                    //cs.Product_New__c = sur.Case_Product__c;
                    //cs.ParentId = sur.Case__c;
                    cs.Project__c = sur.Project_Name__c;
                    if(sur.Project_Manager_s_Manager__c != null){
                        cs.OwnerId = sur.Project_Manager_s_Manager__c; 
                    }else{
                        cs.OwnerId = id.valueof(SurveyDefaultowner);
                    } 
                }else{
                    //cs.Subject = 'Customer : ' + sur.Account_Name__c + ' is completely Dissatisfied.'; // Kiran C: Commented as part of DSAT Closed loop feedback
                    cs.Subject = 'DSAT from ' + sur.Account_Name__c + ' : Survey Feedback.';
                    cs.Product_New__c = sur.Case_Product__c;
                    cs.ParentId = sur.Case__c;
                    if(sur.Case_Owner_Manager__c!=null){
                        cs.OwnerId = sur.Case_Owner_Manager__c; 
                    }else{
                        cs.OwnerId = id.valueof(SurveyDefaultowner);
                    }  
                }
                
                cs.Status = dd.Stage_Status__c;
                cs.Priority = dd.Priority__c;
                cs.AccountId = dd.Account_Id__c;
                              
                cs.ContactId = sur.Contact__c;
                cs.Survey__c = sur.Id;
                //cs.DSAT_Survey_Reference__c = sur.id;
                cs.Will_you_recommend_Zscaler__c = sur.Will_you_recommend_Zscaler__c;   
                cs.How_can_we_make_you_happier__c = sur.How_can_we_make_you_happier__c; 
                cs.Easy_to_handle_Issue__c = sur.Easy_to_handle_Issue__c;   
                cs.Rate_your_experience__c = sur.Rate_your_experience__c;   
                cs.How_was_the_Zscaler_portal_Experience__c = sur.How_was_the_Zscaler_portal_Experience__c; 
                cs.One_thing_we_could_do_to_make_it_easy__c = sur.One_thing_we_could_do_to_mak__c;  
                cs.Your_Comments__c = sur.Your_Comments__c; 
                
                cs.Areas_to_Improve__c   = sur.Areas_to_Improve__c ;
                cs.Areas_to_Improve_Other_Comments__c  = sur.Areas_to_Improve_Other_Comments__c ;
                //Added By Anup : CR#788 - Start
                cs.Did_we_meet_your_project_timeline__c  = sur.Did_we_meet_your_project_timeline__c;
                //Added By Anup : CR#788 - End
                cs.Assignee_Manager__c= sur.Assignee_Manager__c;    
                cs.Survey_Case_Owner_Manager__c= sur.Case_Owner_Manager__c; //added by Gurjinder : CR# 177: DSAT notifications issue
                cs.Case_Owner_Manager_s_Manager__c = sur.Case_Owner_Manager_s_Manager__c;
                cs.Ticket_Owner__c = sur.Parent_Case_Owner__c;
                cslst.add(cs);
            }
        }
        insert cslst;
        Id DSATCaseRT = Schema.SObjectType.Action_Plan__c.getRecordTypeInfosByDeveloperName().get('DSAT').getRecordTypeId();
       
        // CR 1183 start 
        List<Action_Plan__c> actionPlanList = new List<Action_Plan__c>();
        for(case singleCase : cslst){
            String areaToImproves =  singleCase.Areas_to_Improve__c;
            if(String.isNotBlank(areaToImproves)) {
               List<String> areaimproveList = areaToImproves.split(';');
                for(String singleArea : areaimproveList){
                    if(singleArea.equalsIgnoreCase('other'))  {
                        continue;
                    }
                    Action_Plan__c actionPlanObject = new Action_Plan__c();
                    actionPlanObject.Case__c = singleCase.Id;
                    actionPlanObject.OwnerId = singleCase.OwnerId; 
                    actionPlanObject.Name = singleArea;
                    actionPlanObject.recordTypeId = DSATCaseRT;
                    actionPlanList.add(actionPlanObject);
                }
            }   		
        }
       insert actionPlanList;
        
        // CR 1183 end
        List<Action_Plan__c> actionPlanOtherCommentList = new List<Action_Plan__c>();
        for(case singleCase : cslst) {
            if(singleCase.Areas_to_Improve_Other_Comments__c !=null && !String.isBlank(singleCase.Areas_to_Improve_Other_Comments__c)){
                 Action_Plan__c actionPlanObject = new Action_Plan__c();
                    actionPlanObject.Case__c = singleCase.Id;
                    actionPlanObject.Name = 'Other Improvements';
                actionPlanObject.Customer_Comment__c  = singleCase.Areas_to_Improve_Other_Comments__c;
                    actionPlanObject.recordTypeId = DSATCaseRT;
                    actionPlanObject.OwnerId = singleCase.OwnerId; 
                    actionPlanOtherCommentList.add(actionPlanObject);
            }
        }
        insert actionPlanOtherCommentList;
        Map<Id,Id> surIdMap = new Map<Id,Id>();
        for(Case cs:cslst){
            surIdMap.put(cs.Survey__c, cs.Id);
        }
        for(Survey__c s:surlst){
            if(surIdMap.containsKey(s.Id)){
                s.DSAT_Case_Reference__c = surIdMap.get(s.id);
            }
        }
        //update surlst;
    }
    
    public void onAfterUpdate(Map<Id,Survey__c> oldSurveys,Map<Id,Survey__c> newSurveys)
    {
        //CR#-5100-Start
        List<String>languagesList = new List<String>();
         if(String.isNotBlank(Label.SurveyTranslatorLanguages) && label.SurveyTranslatorLanguages.contains(';')){   
          for(String eachLanguage: label.SurveyTranslatorLanguages.split(';')){  
            languagesList.add(eachLanguage);
         }   
      }
        for(Survey__c eachSurvey: newSurveys.values()){
           
            if(!System.isFuture() && !System.isBatch() && String.isNotBlank(eachSurvey.Language_code__c)
                && eachSurvey.Language_code__c != oldSurveys.get(eachSurvey.id).Language_code__c 
                && languagesList!=null && !languagesList.isEmpty() && languagesList.size()>0 && languagesList.contains(eachSurvey.Language_code__c)){
                callGoogleTranslateAPI(JSON.serialize(eachSurvey));
            } 
        }
       //CR#-5100-End
    }
    
    public void onBeforeDelete(Map<Id,Survey__c> oldSurveys)
    {
        
    }
    
    public void onAfterDelete(Map<Id,Survey__c> oldSurveys)
    {
        
    }
    
    public void onAfterUndelete(Map<Id,Survey__c> newSurveys)
    {
        
    }
    
    public static void updateExtension(List<Survey__c> lstSurvey, Map<Id,Survey__c> mapOldSurveys){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll(); 
        
        if(tsmap != null && !tsmap.isEmpty() &&
           tsmap.containsKey('SurveyBeforInsertAccountExHandler') && tsmap.get('SurveyBeforInsertAccountExHandler') != null &&
           tsmap.get('SurveyBeforInsertAccountExHandler').Execute__c)  {
               Map<Id, Id> extMap = new Map<Id, Id>();
               Set<String> extIdSet = new Set<String>();
               for(Survey__c su : lstSurvey){
                   if(mapOldSurveys == null || (mapOldSurveys.get(su.Id).Account__c != su.Account__c))  {
                       extIdSet.add(su.Account__c);
                   }
               }
               
               if(extIdSet.size() > 0){
                   List<Account_Extension__c> accExList = new List<Account_Extension__c>();
                   for(Account_Extension__c ae :  [select Id, Account__c from Account_Extension__c where Account__c IN :extIdSet])  {
                       extMap.put(ae.Account__c, ae.id);
                       
                   }
                   
                   for(Survey__c sr : lstSurvey){
                       if(mapOldSurveys == null || (mapOldSurveys.get(sr.Id).Account__c != sr.Account__c))  {
                           sr.Account_Extension__c = extMap.get(sr.Account__c);
                       }
                   }
               }
           }
    }
   
    
    
    
    //Anup : Commenting updateCaseOwnerManager method as per CR987.
    /*
    public void updateCaseOwnerManager(List<Survey__c> newSurveys){
        List<id> userIds =new list<id>();
        Map<Id,user> casevaluemap= new map<Id,user>();
        for(Survey__c surLst: newSurveys){
            userIds.add(surLst.Case_Owner_Manager__c);
            }
        casevaluemap=new map<Id,user>([select id,managerId from user where id In: userIds ]);
        for(Survey__c sur : newSurveys){
            If(casevaluemap.containsKey(sur.Case_Owner_Manager__c))
            {
              sur.Case_Owner_Manager_s_Manager__c=casevaluemap.get(sur.Case_Owner_Manager__c).managerId;
            }
          
          }
        List<id> caseIds =new list<id>();
        List<id> parentIds =new list<id>();
        List<case> caseLists =new list<case>();
        Map<Id,Case> parentCaseUsermap= new map<Id,Case>();
        system.debug('newSurveys--->> '+newSurveys);
        for(Survey__c surLst: newSurveys){
            caseIds.add(surLst.Case__c);
        }
        system.debug('caseIds>>> '+caseIds);
        caseLists=[select id,Parent_Case_Owner__c,ParentId from Case where id In: caseIds];
        system.debug('caseLists>>> '+caseLists);
        for(case caseLst:caseLists)
        {
           //parentIds.add(caseLst.ParentId);
           parentIds.add(caseLst.Id);
           system.debug('parent owner>>'+caseLst.Parent_Case_Owner__c);
        }
        parentCaseUsermap=new map<Id,Case>([select id,OwnerId,Owner.Id,Case_Owner__c from Case where id In: parentIds ]);
        system.debug('parentCaseUsermap>>> '+parentCaseUsermap);
        for(Survey__c sur : newSurveys){
            for(String caseId : parentCaseUsermap.keySet()){
                system.debug('parentCaseUsermap.KeySet()>>> '+caseId);
                String Owner = parentCaseUsermap.get(caseId).OwnerId;
                system.debug('parent id'+ parentCaseUsermap.get(caseId).OwnerId);
                system.debug('case user'+ parentCaseUsermap.get(caseId).Case_Owner__c);
                if(Owner.startsWith('005')){
                sur.Parent_Case_Owner__c=parentCaseUsermap.get(caseId).OwnerId;
                }
            }
          }
    }*/
    //Added by Chetan IBA-5284 Start
    public void updateMailSentToCustomer(List<Survey__c> newSurveys){
        Set<Id> meetingIds= new Set<Id>();
        Map<Id,EmailMessage> emailMap=new Map<Id,EmailMessage>();
        for(Survey__c sur:newSurveys){
            if(sur.RecordTypeId==tamAuditRT){
                meetingIds.add(sur.TAM_Meeting__c);
            }
        }
        if(!meetingIds.isEmpty()){
            for(EmailMessage em:[Select id,RelatedToId from EmailMessage where RelatedToId IN :meetingIds]){
                emailMap.put(em.RelatedToId,em);
            }
        }
        if(!emailMap.isEmpty()){
            for(Survey__c sur:newSurveys){
                if(emailMap!=null && emailMap.get(sur.TAM_Meeting__c)!=null){
                    sur.Was_the_meeting_mail_sent_to_customer__c = true;	
                }
            }
        }
    }

    public void updateAccountStage(List<Survey__c> newSurveys){
        Set<Id> accIds= new Set<Id>();
        Map<Id,List<String>> finalMap=new Map<Id,List<String>>();
        for(Survey__c sur:newSurveys){
            if(sur.RecordTypeId==tamAuditRT){
                accIds.add(sur.Account__c);
            }
        }
        if(!accIds.isEmpty()){
            List<AggregateResult> maxStages = [SELECT MAX(Stage__c) stage,Product__c,Account__c from TAM_Engagement__c where Account__c IN :accIds GROUP BY Account__c,Product__c];
            for(AggregateResult result:maxStages){
                Id Account = String.valueOf(result.get('Account__c'));
                String Product = String.valueOf(result.get('Product__c'));
                String Stage = String.valueOf(result.get('stage'));
                String ProductStage = String.valueOf(result.get('Product__c'))+ '-' + String.valueOf(result.get('stage')) + '\n';
                if(!finalMap.containsKey(Account)){
                    finalMap.put(Account,new List<String>());
                }
                finalMap.get(Account).add(ProductStage);
            }
        }
        if(!finalMap.isEmpty()){
            for(Survey__c sur:newSurveys){
                List<String> ls = new List<String>();
                ls = finalMap.get(sur.Account__c);
                String finalString = string.join(ls,',');
                sur.Account_Stage__c = finalString;
            }
        }
    }
    //Added by Chetan IBA-5284 Start
}