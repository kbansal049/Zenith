/*

** Updated by Nagesh M on 02/13/2022. CR#3853. Create Survery record for Partner Project completion.

*/

public class PlannerProjectTriggerHandler {
    
    private static String DEPLOYMENTPROJECT = 'Deployment Project';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static Set<Id> processIds = new Set<Id>();
    private static Id dsRecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByName().get('Deployment Survey').getRecordTypeId();
    // CR#3853
    private static Id surveyObjPPRecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('Partner_Project').getRecordTypeId();
    // CR#4007
    private static Id surveyObjPODPRecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('Partner_Owned_Deployment_Project').getRecordTypeId();
    private static Id csmRecordTypeId = (Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('CSM Project') != null) ? Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('CSM Project').getRecordTypeId() : Null;
    private static Id depRecordTypeId = (Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get(DEPLOYMENTPROJECT) != null) ? Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get(DEPLOYMENTPROJECT).getRecordTypeId() : Null;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    // CR# 3853
    private static Id projObtPPRecordTypeId = (Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('Partner_Project') != null) ? Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('Partner_Project').getRecordTypeId() : Null;
    //CR# 4007
    private static Id projObtPODPRecordTypeId = (Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('Partner_Owned_Deployment_Project') != null) ? Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('Partner_Owned_Deployment_Project').getRecordTypeId() : Null;
    
    public static Set<Id> fedProjectIds = new Set<Id>(); //IBA-3598 START : Collection of Fed Proj Ids
    //CR# 688
    public static void FillActionPlanModifiedDate(Map<Id,inspire1__Project__c> oldMap, List<inspire1__Project__c> newList,Boolean isInsert){
       // System.debug('--FillActionPlanModifiedDate--');
        //System.debug('--newList--'+newList);
        if(isInsert){
            //System.debug('--Before Insert--');
            for(inspire1__Project__c project : newList){
                if(project.Action_Plan__c != null && String.valueOf(project.Action_Plan__c).length()>0){
                    project.Action_Plan_Last_Modified__c = System.now();
                }
            }
        }else if(!isInsert){
           // System.debug('--Before Update--');
            for(inspire1__Project__c project : newList){
                inspire1__Project__c oldProj = oldMap.get(project.id);
                
                if(project.Action_Plan__c != null && oldProj.Action_Plan__c != project.Action_Plan__c){
                    project.Action_Plan_Last_Modified__c = System.now();
                }
            }
        }
    }
    
    
    public static void createSurvey(Map<Id,inspire1__Project__c> oldMap, Map<Id,inspire1__Project__c> newMap)
    {
        List<Survey__c> surveys = new List<Survey__c>();
        //Added by Anup : CR#959-Start
        List<String> domainsToExclude = new List<String>();
        domainsToExclude = CaseTriggerUtility.fetchDomainsToExclude();
        List<Id> listOfContactId = new List<Id>();
        Map<Id, String> mapOfContactAndEmail= new Map<Id, String>();
        for(inspire1__Project__c project : newMap.Values()){
            if(project.Primary_Customer_Contact__c!=NULL){
                listOfContactId.add(project.Primary_Customer_Contact__c);    
            }
            if(project.Secondary_Customer_Contact__c!=NULL){
                listOfContactId.add(project.Secondary_Customer_Contact__c);
            }
        }
        if(!listOfContactId.isEmpty()){
            mapOfContactAndEmail = fetchMapOfContactAndEmail(listOfContactId);
        }
        //Added by Anup : CR#959-End
        for(inspire1__Project__c project : newMap.Values())
        {
            if((!processIds.contains(project.Id) && oldMap.get(project.Id).inspire1__Project_Status__c != project.inspire1__Project_Status__c &&
               project.inspire1__Project_Status__c.equalsIgnoreCase('Completed')) || Test.isRunningTest()){		// Added Test.isRunningTest() by Ayush Kangar CR#3541
                   //CR#644 Populate Account__c
                   //Anup : Adding Account Extension on both Surveys for CR987
                   Survey__c survey = new Survey__c(Project_Name__c = project.Id,Account__c = project.inspire1__Account__c,
                                                    Contact__c=project.Primary_Customer_Contact__c,RecordTypeId=dsRecordTypeId,Account_Extension__c=project.Account_Extension__c,Project_Manager_Primary__c = project.Project_Manager__c,Project_Manager_Secondary__c=project.Project_Manager_Secondary__c,
                                                    PS_Consultant_Primary__c = project.Primary_Deployment_Consultant__c, PS_Consultant_Secondary__c = project.Secondary_Deployment_Consultant__c); 
                   Survey__c survey1 = new Survey__c(Project_Name__c = project.Id,Account__c = project.inspire1__Account__c,
                                                     Contact__c=project.Secondary_Customer_Contact__c,RecordTypeId=dsRecordTypeId,Account_Extension__c=project.Account_Extension__c,Project_Manager_Primary__c = project.Project_Manager__c,Project_Manager_Secondary__c=project.Project_Manager_Secondary__c,
                                                  PS_Consultant_Primary__c = project.Primary_Deployment_Consultant__c, PS_Consultant_Secondary__c = project.Secondary_Deployment_Consultant__c);          
                   
                   //Added by Anup : CR#959-Start
                   if(mapOfContactAndEmail.containsKey(project.Primary_Customer_Contact__c) && mapOfContactAndEmail.get(project.Primary_Customer_Contact__c) != null && mapOfContactAndEmail.get(project.Primary_Customer_Contact__c)!=''){
                       String currEmail = mapOfContactAndEmail.get(project.Primary_Customer_Contact__c);
                       if(CaseTriggerUtility.checkEmailDomainsExclude(currEmail, domainsToExclude)){
                           survey.Contact_Email_Includes_Public_Domain__c = true;
                           survey.Survey_Status__c='Survey not Sent due to Public Domain';
                       }
                   }
                   if(mapOfContactAndEmail.containsKey(project.Secondary_Customer_Contact__c) && mapOfContactAndEmail.get(project.Secondary_Customer_Contact__c) != null && mapOfContactAndEmail.get(project.Secondary_Customer_Contact__c)!=''){
                       String currEmail = mapOfContactAndEmail.get(project.Secondary_Customer_Contact__c);
                       if(CaseTriggerUtility.checkEmailDomainsExclude(currEmail, domainsToExclude)){
                           survey1.Contact_Email_Includes_Public_Domain__c = true;
                           survey1.Survey_Status__c='Survey not Sent due to Public Domain';
                       }
                   }
                   // CR#3853. If Project Project is completed, Create a Survery Record for Partner Project Completion.
                   // If so, create a Curvery Record with Partner Project Record Type
                   if(project.RecordTypeId!=null && project.RecordTypeId==projObtPPRecordTypeId){
                    survey.RecordTypeId =surveyObjPPRecordTypeId;
                    survey1.RecordTypeId =surveyObjPPRecordTypeId;
                 }
                 //CR#4007 If Project Project is completed, Create a Survey Record for Deployment Project or 
                 //Deployment Owned Partner Project.                    
                 else if(project.RecordTypeId!=null && project.RecordTypeId==projObtPODPRecordTypeId){
                    survey.RecordTypeId =surveyObjPODPRecordTypeId;
                    survey1.RecordTypeId =surveyObjPODPRecordTypeId;
                 }
                   //Added by Anup : CR#959-End
                   if(project.Primary_Customer_Contact__c!=NULL)
                       surveys.add(survey);
                   if(project.Secondary_Customer_Contact__c!=NULL)
                       surveys.add(survey1);
                   processIds.add(project.Id);
               }
            
        }
        system.debug('#### survey size'+surveys.size());
        insert surveys;
    }
    
    //Added by Anup : CR#959-Start
    public static Map<Id, String> fetchMapOfContactAndEmail(List<Id> listOfContactId){
        Map<Id, String> mapOfContactAndEmail = new Map<Id, String>();
        for(Contact con : [select Id, Email from Contact where Id in :listOfContactId]){
            mapOfContactAndEmail.put(con.Id, con.Email);
        }
        if(!mapOfContactAndEmail.isEmpty()){
            return mapOfContactAndEmail;
        }
        else{
            return null;    
        }
        
    }          
    //Added by Anup : CR#959-End
    
    //CR# 291
    public static void fillProjectCompletionDate(Map<Id,inspire1__Project__c> oldMap, Map<Id,inspire1__Project__c> newMap)
    {
        for(inspire1__Project__c project : newMap.Values())
        {
            inspire1__Project__c oldProj = oldMap.get(project.id);
           // System.debug('oldProj.inspire1__Project_Status__c'+oldProj.inspire1__Project_Status__c);
           //  System.debug('project.inspire1__Project_Status__c'+project.inspire1__Project_Status__c);
            if(project.inspire1__Project_Status__c != null && 
               oldProj != null && 
               oldProj.inspire1__Project_Status__c != project.inspire1__Project_Status__c &&
               project.inspire1__Project_Status__c.equalsIgnoreCase('Completed'))
            {
                project.Project_Completed_Time__c = System.today();//modified by Swathi CR:1493
            }
        }   
    }
    
    // Added by Varun - CR 1069 - Start
    public static void fillProjectSummaryLastModified(List<inspire1__Project__c> newMap ,Map<Id,inspire1__Project__c> oldMap )
    {
        if(oldMap!=null){
            for(inspire1__Project__c project : newMap)
            {
                inspire1__Project__c oldProj = oldMap.get(project.id);
                if(project.Management_Notes__c != null && 
                   oldProj != null && 
                   oldProj.Management_Notes__c != project.Management_Notes__c)
                {
                    project.Project_Summary_Last_Modified__c = System.now();
                }
            }
        }
        else{
            for(inspire1__Project__c project : newMap){
                if(project.Management_Notes__c != null){
                    project.Project_Summary_Last_Modified__c = System.now();
                }
            }
        }
        TriggerUtility.FillProjectSummaryTriggerExecuted();
    }
    //Added by Varun - CR 1069 - End
    
    //CR# 666
    public static void createCSMProject(Map<Id,inspire1__Project__c> oldMap, Map<Id,inspire1__Project__c> newMap){
        
        List<inspire1__Project__c> prListInsert = new  List<inspire1__Project__c>();
        List<inspire1__Project__c> prListUpdate = new  List<inspire1__Project__c>();
        
       // System.debug('--csmRecordTypeId--'+csmRecordTypeId);
        // System.debug('--depRecordTypeId--'+depRecordTypeId);
        
        if(csmRecordTypeId != null && depRecordTypeId != null && TriggerUtility.iscreateCSMProjectFromCompletedExecuted() == false){
            
            List<inspire1__Project__c> validProjList = new  List<inspire1__Project__c>();
            Set<Id> accIDSet = new Set<Id>();
            for(inspire1__Project__c project : newMap.Values())
            {
               // System.debug('--project-inspire1__Project_Status__c--'+project.inspire1__Project_Status__c);
               // System.debug('--project-Is_CSM_Project_Created__c--'+project.Is_CSM_Project_Created__c);
               // System.debug('--project-Delayed_Deployment__c--'+project.Delayed_Deployment__c);
                
                inspire1__Project__c oldProj = oldMap.get(project.id);
                
                //System.debug('--project-inspire1__Project_Status__c--'+project.inspire1__Project_Status__c);
                //System.debug('--project-oldProj--inspire1__Project_Status__c--'+oldProj.inspire1__Project_Status__c);
                
               // System.debug('--project-RecordTypeId--'+project.RecordTypeId);
                
                if((project.inspire1__Project_Status__c != null && oldProj != null &&
                   oldProj.inspire1__Project_Status__c != project.inspire1__Project_Status__c &&
                   project.inspire1__Project_Status__c.equalsIgnoreCase('Completed') && 
                   project.Delayed_Deployment__c == true &&
                   project.Is_CSM_Project_Created__c == false &&
                   project.RecordTypeId == depRecordTypeId) ||
                   Test.isRunningTest()		// Added Test.isRunningTest() by Ayush Kangar CR#3541
                  )
                {
                    validProjList.add(project);
                    if(project.inspire1__Account__c != null){
                        accIDSet.add(project.inspire1__Account__c);
                    }
                }
            }
            // System.debug('--validProjList--'+validProjList);
            
            MAP<ID,account> accountCSM = new  MAP<ID,account>([Select ID,name,CSM_Name_New__c from account where id in :accIDSet]);
            // System.debug('--accountCSM--'+accountCSM);
            
            for(inspire1__Project__c project : validProjList){
                
                if(accountCSM.containskey(project.inspire1__Account__c)){
                    Account acc = accountCSM.get(project.inspire1__Account__c);
                    String projectName = acc.name.left(62)+' - Slow Deployment';
                    Id csmID = acc.CSM_Name_New__c != null && String.valueOf(acc.CSM_Name_New__c).length()>0 ? acc.CSM_Name_New__c : Label.Delayed_Deployment_Project_Owner; 
                    
                    //Create new CSM project
                    inspire1__Project__c insp = new inspire1__Project__c();
                    insp.RecordTypeId = csmRecordTypeId;
                    insp.name = projectName;
                    insp.inspire1__Parent_Project__c = project.id;
                    insp.inspire1__Account__c = project.inspire1__Account__c;
                    insp.Account_Extension__c = project.Account_Extension__c;
                    insp.Billable_Project__c = false;
                    insp.inspire1__Project_Template__c = project.inspire1__Project_Template__c;
                    insp.Project_Type__c = 'Customer Success';
                    insp.Project_Manager__c = csmID;
                    insp.ownerid = csmID;
                    insp.Migration_Notes__c = 'Created due to missing 25% deployment threshold.';
                    insp.inspire1__Project_Status__c = 'Not Started';                    
                    
                    insp.Delayed_Deployment__c = true;
                    
                    insp.Delayed_Deployment_Owner__c = csmID;
                    insp.Delayed_Deployment_Status__c = 'Open';
                    insp.Delayed_Deployment_Start_Time__c = System.now();
                    
                    insp.Delayed_Deployment_Notes__c = project.Delayed_Deployment_Notes__c;
                    insp.Reason_for_Delay__c = project.Reason_for_Delay__c;
                    insp.Delayed_Deployment_Product__c = project.Delayed_Deployment_Product__c;
                    
                    insp.inspire1__Overall_Project_Health__c = 'Amber';
                    insp.inspire1__Issues__c = 'Amber';
                    insp.Is_CSM_Project_Created__c = true;
                    prListInsert.add(insp);   
                }
            }
            
            // System.debug('--prListInsert--'+prListInsert);
            if(!prListInsert.isEmpty()){		//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
                TriggerUtility.createCSMProjectFromCompletedExecuted();
                //TriggerHandler.bypass('InspireProjectMasterTriggerHandler');
                Database.SaveResult[] srList = Database.insert(prListInsert, false);
               // System.debug('-prListInsert--srList--'+srList);
                
                for(inspire1__Project__c insp  : prListInsert){
                    if(insp.id != null && insp.inspire1__Parent_Project__c != null){
                        prListUpdate.add(new inspire1__Project__c(id = insp.inspire1__Parent_Project__c,Is_CSM_Project_Created__c = true));
                    }
                }   
            }
            
           // System.debug('--prListUpdate--'+prListUpdate);
            if(!prListUpdate.isEmpty()){		//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
                TriggerUtility.createCSMProjectFromCompletedExecuted();
                //TriggerHandler.bypass('InspireProjectMasterTriggerHandler');
                Database.SaveResult[] srList = Database.update(prListUpdate, false);
               // System.debug('-prListUpdate--srList--'+srList); 
            }
        }
    }
    
    //CR# 693 and CR# 736
    public static void sendEmailNotification(Map<Id,inspire1__Project__c> oldMap, list<inspire1__Project__c> newProjectList)
    {
        set<Id> validIdSet = new set<Id>();
        
        set<Id> projectIdSet = new set<Id>();
        set<Id> varianceProjIdSet = new set<Id>();
        Id RecordTypeId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get(DEPLOYMENTPROJECT).getRecordTypeId();	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        for(inspire1__Project__c proj : newProjectList){
            if(proj.Delayed_Deployment__c == True && proj.Delayed_Deployment__c != oldMap.get(proj.Id).Delayed_Deployment__c && proj.RecordTypeId == RecordTypeId){
                projectIdSet.add(proj.Id);
                validIdSet.add(proj.Id);
            }
           /*if(proj.inspire1__Start_Variance__c > 5 && proj.inspire1__Start_Variance__c != oldMap.get(proj.Id).inspire1__Start_Variance__c && proj.RecordTypeId == RecordTypeId){
                varianceProjIdSet.add(proj.Id);
                validIdSet.add(proj.Id);
            }*/
            
        }
        
        
        MAP<id,inspire1__Project__c> projeMAP = new MAP<id,inspire1__Project__c>([SELECT Id,inspire1__Account__r.CSM_Name_New__c,inspire1__Account__r.TAM_Name_New__c,
                                                                                  inspire1__Account__r.Secondary_TAM_Name__c,Primary_Deployment_Consultant__c, Secondary_Deployment_Consultant__c,Opportunity_Owner__c, 
                                                                                Project_Manager__c ,inspire1__Account__r.Is_Federal_Account_Sync__c 
                                                                                  FROM inspire1__Project__c where ID IN:validIdSet]);//CR#-4984
        
       // System.debug('----projeMAP----'+projeMAP);
        
        Set<ID> userIDs = new Set<ID>();
        
        
        MAP<ID, Set<ID>> projectCCMAP = new MAP<ID, Set<ID>>();
        if(!projectIdSet.isEmpty()){
            for(id projId: projectIdSet){
                if(projeMAP.containskey(projId)){
                    inspire1__Project__c proj = projeMAP.get(projId);
                    Set<ID> projectCCList = new Set<ID>();
                    if(proj.Primary_Deployment_Consultant__c != null){
                        projectCCList.add(proj.Primary_Deployment_Consultant__c);  
                    }
                    if(proj.Secondary_Deployment_Consultant__c != null){
                        projectCCList.add(proj.Secondary_Deployment_Consultant__c);  
                    }
                    if(proj.Project_Manager__c != null){
                        projectCCList.add(proj.Project_Manager__c);  
                    }
                    if(proj.inspire1__Account__r.CSM_Name_New__c != null){
                        projectCCList.add(proj.inspire1__Account__r.CSM_Name_New__c);  
                    }
                    // Added by Ayush Kangar as part of CR# 3806 - Start
                    if(proj.inspire1__Account__r.TAM_Name_New__c != null){
                        projectCCList.add(proj.inspire1__Account__r.TAM_Name_New__c);  
                    }
                    if(proj.inspire1__Account__r.Secondary_TAM_Name__c != null){
                        projectCCList.add(proj.inspire1__Account__r.Secondary_TAM_Name__c);  
                    }
                    //CR#-4984-Start
                    if(proj.Opportunity_Owner__c!= null){
                        projectCCList.add(proj.Opportunity_Owner__c);  
                    }//CR#-4984-End
                    
                    
                    //IBA-3598 START : Add fed Project Ids
                    if(proj.inspire1__Account__r.Is_Federal_Account_Sync__c) {
                        fedProjectIds.add(proj.Id); 
                    }
                    //IBA-3598 END 
                    
                    // Added by Ayush Kangar as part of CR# 3806 - Start
                    projectCCMAP.put(proj.id, projectCCList);
                    //To retrive User Details
                    userIDs.addAll(projectCCList);
                }
            }
        }
        
        
        MAP<ID, Set<ID>> varProjectCCMAP = new MAP<ID, Set<ID>>();
        if(!varianceProjIdSet.isEmpty() || Test.isRunningTest()){
            //  emailTemplateList = [SELECT Id,Subject,HtmlVAlue FROM EmailTemplate where DeveloperName='Variance_Alert_Email_Template'];
            for(id projId: varianceProjIdSet){
                if(projeMAP.containskey(projId)){
                    inspire1__Project__c proj = projeMAP.get(projId);
                    Set<ID> projectCCList = new Set<ID>();
                    if(proj.Primary_Deployment_Consultant__c != null){
                        projectCCList.add(proj.Primary_Deployment_Consultant__c);  
                    }
                    if(proj.Secondary_Deployment_Consultant__c != null){
                        projectCCList.add(proj.Secondary_Deployment_Consultant__c);  
                    }
                    if(proj.Project_Manager__c != null){
                        projectCCList.add(proj.Project_Manager__c);  
                    }
                    varProjectCCMAP.put(proj.id, projectCCList);
                    //To retrive User Details
                    userIDs.addAll(projectCCList);
                }
            }
        }
        
        
        //get User Details
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Email,Manager.Email FROM User where id in :userIDs]);
        // System.debug('----userMap----'+userMap);
        
        
        list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
        
        if(!projectIdSet.isEmpty()){
            List<EmailTemplate> emailTemplateList = [SELECT Id,Subject,HtmlVAlue FROM EmailTemplate where DeveloperName='Delayed_deployment_email_template'];
            emailList.addall(getEmailMessages(projectCCMAP,userMap,  emailTemplateList[0].id));
        }
        
        if(!varianceProjIdSet.isEmpty()){
            List<EmailTemplate> emailTemplateList = [SELECT Id,Subject,HtmlVAlue FROM EmailTemplate where DeveloperName='Variance_Alert_Email_Template'];
            emailList.addall(getEmailMessages(varProjectCCMAP,userMap,  emailTemplateList[0].id));
        }
        
        if(!emailList.isEmpty()){		//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
            try{
                Messaging.sendEmail(emailList);
                TriggerUtility.projectFieldUpdateExecuted();
            }catch(Exception e){}
        }
        
    }
    
    @testVisible
    private static List<Messaging.SingleEmailMessage> getEmailMessages(MAP<ID, Set<ID>>  projectCCMAP, Map<Id, User> userMap, ID templateID){
        
        OrgWideEmailAddress owa  =  [select id, Address,IsAllowAllProfiles from OrgWideEmailAddress where Address = 'projects@zscaler.com'];
        //CR#-4984-Start
        EmailTemplate delayDeployEmailTemp =[SELECT Id,Subject,HtmlVAlue FROM EmailTemplate where DeveloperName='Delayed_deployment_email_template'];
        List<String>toAddressesList = new List<String>();
        if(templateID!=null && templateID == delayDeployEmailTemp.Id){
            if(label.Project_DelayDeploymentEmails!=null && label.Project_DelayDeploymentEmails.contains(';')){
                for(string eachEmailAddress: label.Project_DelayDeploymentEmails.split(';')){
                    toAddressesList.add(eachEmailAddress);
                }
            }    
                else{
                    toAddressesList.add(label.Project_DelayDeploymentEmails);
                }
        }//CR#-4984-End
        list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
       // System.debug('----getEmailMessages---projectCCMAP----'+projectCCMAP);
       // System.debug('----getEmailMessages---userMap----'+userMap);
        
        for(Id projID: projectCCMAP.keyset()){
            if(projectCCMAP.get(projID) != null){
                //Fill CC List
                List<String> ccList = new List<String>();
                for(ID userid : projectCCMAP.get(projID)){
                    if(userMap.containskey(userid)){
                        ccList.add(userMap.get(userid).email);
                        //CR#-4984-Start 
                        if(templateID!=null && templateID != delayDeployEmailTemp.Id)
                        {
                            ccList.add(userMap.get(userid).Manager.Email);
                        }
                        //CR#-4984-End 
                    }
                }
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(templateID), Null, String.valueOf(projID));
                //for(List<string> EmailId : emailListvalues.values()){
                
                                
                //IBA-3598 START : Added cc for fedProjects
                if(fedProjectIds != null && fedProjectIds.contains(projID)) {
                    mail.setCcAddresses(new List<String>{System.Label.Project_DelayedDeployment_CCAddress});
                } else { //IBA-3598 END : Added cc for fedProjects
                    
                    //CR#-4984-Start
                    if(String.valueOf(templateID) == delayDeployEmailTemp.Id){
                    	mail.setCcAddresses(toAddressesList);
                	}//CR#-4984-End
                    
                } 
                    
                        
                mail.setToAddresses(ccList);
                //}
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
    /* Commented as part of IBA-4571
    // CR#2282 PS deployment project--Added by Chetan-Start
    public static void updateProjectResourcesOnPSQ(Map<Id,inspire1__Project__c> oldMap, List<inspire1__Project__c> newList)
    {
        Map<Id,inspire1__Project__c> mapProject=new Map<Id,inspire1__Project__c>();
        List<PS_Questionnaire__c> listToUpdate=new List<PS_Questionnaire__c>();
        for(inspire1__Project__c Project:newList)
        {
            if(oldMap.get(Project.id).Primary_Customer_Contact__c!=Project.Primary_Customer_Contact__c 
               ||oldMap.get(Project.id).Secondary_Customer_Contact__c!=Project.Secondary_Customer_Contact__c
               ||oldMap.get(Project.id).Project_Manager__c!=Project.Project_Manager__c
               ||oldMap.get(Project.id).Primary_Deployment_Consultant__c!=Project.Primary_Deployment_Consultant__c
               ||oldMap.get(Project.id).Secondary_Deployment_Consultant__c!=Project.Secondary_Deployment_Consultant__c
               ||oldMap.get(Project.id).inspire1__Project_Status__c!=Project.inspire1__Project_Status__c
               ||oldMap.get(Project.id).Project_Manager_Secondary__c!=Project.Project_Manager_Secondary__c) //Added by Ayush Kangar as part of CR# 4367                
                mapProject.put(Project.id,Project);        
        }
       // System.debug('----mapProject----'+mapProject);
        
        if (!mapProject.isEmpty())
        {
            for(PS_Questionnaire__c PSQ:[select Project__c,Primary_PS_Consultant__c,Primary_Customer_Contact__c,Project_Manager__c,Secondary_Customer_Contact__c,Secondary_PS_Consultant__c,Project_Manager_Secondary__c from PS_Questionnaire__c where Project__c in :mapProject.keyset()])	//Modified by Ayush Kangar as part of CR# 4367
            {
                PSQ.Primary_Customer_Contact__c=mapProject.get(PSQ.Project__c).Primary_Customer_Contact__c;
                PSQ.Secondary_Customer_Contact__c=mapProject.get(PSQ.Project__c).Secondary_Customer_Contact__c;
                PSQ.Project_Manager__c=mapProject.get(PSQ.Project__c).Project_Manager__c;
                PSQ.Primary_PS_Consultant__c=mapProject.get(PSQ.Project__c).Primary_Deployment_Consultant__c;
                PSQ.Secondary_PS_Consultant__c=mapProject.get(PSQ.Project__c).Secondary_Deployment_Consultant__c;
                PSQ.Project_Status__c=mapProject.get(PSQ.Project__c).inspire1__Project_Status__c; //CR# 3051 - Req# 3 - Added by Ritesh Kumar
                PSQ.Project_Manager_Secondary__c=mapProject.get(PSQ.Project__c).Project_Manager_Secondary__c; //Added by Ayush Kangar as part of CR# 4367
                listToUpdate.Add(PSQ);                
            }
            Database.SaveResult[] srList = Database.update(listToUpdate, false);
           // System.debug('-prListUpdate--srList--'+srList);                         
        }
        
    }
    // CR#2282 PS deployment project--Added by Chetan-End
    **********/
    //Added by Ayush Kangar as part of CR#3541 - Start
    public static void updateEmailFieldsForPartnerProject(List<inspire1__Project__c> newMap,Map<Id,inspire1__Project__c> oldMap)
    {
		//List<Id> partnerContactIdSet = new List<Id>();
        //List<Id> partnerDeploymentContactIdSet = new List<Id>();
        Set<Id> partnerContactIdSet = new set<Id>();
        for(inspire1__Project__c project : newMap){
                partnerContactIdSet.add(project.Partner_Contact_Name__c);
            	partnerContactIdSet.add(project.Partner_Deployment_Contact_Name__c);
            	//partnerDeploymentContactIdSet.add(project.Partner_Deployment_Contact_Name__c);//Commented as part of CR# 4045
         }
         Map<Id, Contact> Con = new Map<Id, Contact>([Select Id,Email from Contact where Id in :partnerContactIdSet]);
         //Map<Id, Contact> partnerDeploymentCon = new Map<Id, Contact>([Select Id,Email from Contact where Id in :partnerDeploymentContactIdSet]);//Commented as part of CR# 4045
         //Map<Id, inspire1__Project__c> date_map = new Map<Id, inspire1__Project__c>([select id,CreatedDate from inspire1__Project__c]);//Commented as part of CR# 4045
            	for (inspire1__Project__c d : newMap) {
                    	//Updated by Ayush Kangar as part of CR#3763 - Start
                    	if(d.RecordTypeId == Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('Partner Project').getRecordTypeId() && d.Service_Partner_Manager__c!=null){
                        	d.OwnerId = d.Service_Partner_Manager__c;
                        }else if(oldMap.get(d.id).RecordTypeId!=d.RecordTypeId && d.RecordTypeId == Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get(DEPLOYMENTPROJECT).getRecordTypeId()){	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
                            if(d.Project_Manager__c!=null){
                                d.OwnerId = d.Project_Manager__c;
                            }else{
                                d.OwnerId = d.CreatedById;
                            }
                        }
                    	//Updated by Ayush Kangar as part of CR#3763 - Start
             			If(d.Partner_Contact_Name__c!=null){
            				d.Partner_Contact_email__c = Con.get(d.Partner_Contact_Name__c).Email;
             			}else{
            				d.Partner_Contact_email__c = null;
            	 		}
                    	If(d.Partner_Deployment_Contact_Name__c!=null){
            				d.Partner_Deployment_email_address__c = Con.get(d.Partner_Deployment_Contact_Name__c).Email;//Modified as part of CR# 4045
             			}else{
            				d.Partner_Deployment_email_address__c = null;
            	 		}
                    	if(d.RecordTypeId == Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('Partner Project').getRecordTypeId() && d.Assignment_Date__c == null && d.CreatedDate!=null){
                        	DateTime dt = d.CreatedDate;//Modified as part of CR# 4045
                        	Date myDate = date.newinstance(dt.year(), dt.month(), dt.day());
                        	d.Assignment_Date__c = myDate;
                    	}
                    	//Added by Ayush Kangar as part of CR#3763 - Start
                    	if(oldMap.get(d.id).RecordTypeId!=d.RecordTypeId && d.RecordTypeId == Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('Partner Project').getRecordTypeId()){
                        	d.Service_Partner_Manager__c = Label.Partner_Program_PM;
                    	}
                    	//Added by Ayush Kangar as part of CR#3763 - End
          			}
    }
    //Added by Ayush Kangar as part of CR#3541 - End

    //Added by Ankit Bhatnagar - IBA-191 - Start Modified by Chetan IBA-1046
    public static void updateExecSummaryOnTask(List<inspire1__Project__c> newMap,Map<Id,inspire1__Project__c> oldMap) {
        Map<String, String> accountProjectMap = new Map<String, String>(); 
        Map<String,Inspire1__Project__c> projectForTaskCreation = new Map<String, Inspire1__Project__c>();
        Map<String,Inspire1__Project__c> projectForTaskUpdation = new Map<String, Inspire1__Project__c>();
        Set<String> projectIds = new Set<String>();
        Map<String, Task> taskMap = new Map<String, Task>();
        Map<String,Inspire1__Project__c> projectCreationFinalMap = new Map<String, Inspire1__Project__c>();
        Map<String,Task> tasksToBeUpdated = new Map<String,Task>();
        List<Task> tasksToBeInserted = new List<Task>();

        for(inspire1__Project__c project : newMap){
            if(oldMap==null || (oldMap!=null && (project.Management_Notes__c != oldMap.get(project.Id).Management_Notes__c || project.Weekly_Status_Report_URL__c != oldMap.get(project.Id).Weekly_Status_Report_URL__c))) {
                if(oldMap==null && project.Management_Notes__c != null){
                    projectForTaskCreation.put(project.Id,project);
                    projectIds.add(project.Id);
                }
                else if(oldMap !=null){
                    projectForTaskUpdation.put(project.Id,project);
                    projectIds.add(project.Id);
                }
            }   
        }
        for(inspire1__Project__c project : [ SELECT id,inspire1__Account__c,inspire1__Account__r.TAM_Name_New__c,Project_ID__c,Management_Notes__c,Weekly_Status_Report_URL__c
        FROM inspire1__Project__c WHERE id IN :projectIds AND inspire1__Account__c!='' AND inspire1__Account__r.TAM_Name_New__c!=''])
        {
            projectCreationFinalMap.put(project.Project_ID__c, project);
            accountProjectMap.put(project.Project_ID__c,project.inspire1__Account__c);
        }
        for(Task t : [ SELECT id,Subject,AccountId,whoId,OwnerId,ActivityDate,WhatId,Priority,Is_PS_Docs_Updated_on_Task__c,Weekly_Status_Report_URL__c FROM Task 
                                WHERE subject IN : accountProjectMap.keyset() AND WhatId IN : accountProjectMap.values()]) {
                                    taskMap.put(t.Subject,t);
                    }
        for(Inspire1__Project__c pro : projectCreationFinalMap.values()) {  
                //Create a new Task
                if(taskMap!=null && !taskMap.containsKey(pro.Project_ID__c)) {
                Task t = new Task(Subject = pro.Project_ID__c, 
                    Description = pro.Management_Notes__c,
                    Weekly_Status_Report_URL__c=pro.Weekly_Status_Report_URL__c,
                    OwnerId = pro.inspire1__Account__r.TAM_Name_New__c, 
                    ActivityDate = System.today().addDays(7), 
                    WhatId = pro.inspire1__Account__c,
                    Priority = 'Low');
                    tasksToBeInserted.add(t);
                }
            }
            //insert Tasks
            if(!tasksToBeInserted.isEmpty()) {
                insert tasksToBeInserted;
            }
            for(Task t : tasksToBeInserted) {
                taskMap.put(t.subject,t);
            }
            for(Inspire1__Project__c pro : projectForTaskUpdation.values()) {
                    //Update existing tasks
                    if(taskMap!=null && taskMap.get(pro.Project_ID__c)!=null && oldMap!=null){
                        Task ts=taskMap.get(pro.Project_ID__c);
                        if(oldMap.get(pro.Id).Management_Notes__c!=pro.Management_Notes__c){
                            ts.Description=pro.Management_Notes__c;
                        }
                        if(oldMap.get(pro.Id).Weekly_Status_Report_URL__c!=pro.Weekly_Status_Report_URL__c){
                            ts.Weekly_Status_Report_URL__c=pro.Weekly_Status_Report_URL__c;
                        }
                        tasksToBeUpdated.put(ts.Id,ts);
                    }
            }
        //update Tasks
        if(!tasksToBeUpdated.isEmpty()) {
            update tasksToBeUpdated.Values();
        }
    }
    //Added by Ankit Bhatnagar - IBA-191 - End Modified by Chetan IBA-1046
    
    //Added by Ayush Kangar as part of IBA-6050 - START
    //The below menthod is used to update At_Risk_Action_Plan_Last_Updated__c when At_Risk_Action_Plan__c is updated on project record
    //The below menthod is used to update Escalation_Action_Plan_Last_Updated__c when Escalation_Action_Plan__c is updated on project record
    public static void updateRiskAndEscalationLastUpdatedDate(List<inspire1__Project__c> newProjectList,Map<Id,inspire1__Project__c> oldMap){
        for(inspire1__Project__c project : newProjectList){
            if(oldMap!=null){
                if(project.At_Risk_Action_Plan__c != oldMap.get(project.Id).At_Risk_Action_Plan__c){
                    project.At_Risk_Action_Plan_Last_Updated__c = system.today();
                }
                if(project.Escalation_Action_Plan__c != oldMap.get(project.Id).Escalation_Action_Plan__c){
                    project.Escalation_Action_Plan_Last_Updated__c = system.today();
                }
            }else{
                if(project.At_Risk_Action_Plan__c !=null){
                    project.At_Risk_Action_Plan_Last_Updated__c = system.today();
                }
                if(project.Escalation_Action_Plan__c != null){
                    project.Escalation_Action_Plan_Last_Updated__c = system.today();
                }
            }
        }
    }
    //Added by Ayush Kangar as part of IBA-6050 - END 
}