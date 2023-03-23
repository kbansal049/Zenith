public class MeetingTriggerUtility {  
    /*Priyanka - CR# 2374 - 05/07/2021 - Below method auto creates action plan for the first time whenever TAM is inserted*/
    public static void createDefaultActionPlan(List<Meeting__c> newList){
        List<Action_Plan__c> actPlanList = new List<Action_Plan__c>();
        List<Meeting__c> mtIds = new List<Meeting__c>();
        List<Id> accIdList = new List<Id>();
        Map<String, Boolean> acExtMap =new Map<String,Boolean>();
        List<Account_Extension__c> extListUpdate = new List<Account_Extension__c>();
        //Added by Ankit Bhatnagar in CR# 3413 -Start
        Map<Id,Central_Content__c> bulkActionsMap = new Map<Id,Central_Content__c>([SELECT id,name,Detail_TAM_Notes__c,Due_Date__c,
                                                                                    Expiry_Date__c,is_Active__c,Priority__c,tcc_Number__c 
                                                                                    FROM Central_Content__c 
                                                                                    WHERE RecordType.DeveloperName = 'Bulk_Actions' AND is_Active__c = true]);
        Set<String> activeBulkActionsNameSet = new Set<String>();
        Map<Id, List<String>> accActionPlans = new Map<Id,List<String>>();
        //Added by Ankit Bhatnagar in CR# 3413 -End
        if(newList.size() > 0){
            for(Meeting__c meetRec: newList){
                if(meetRec.Customer_Name__c != null){
                    accIdList.add(meetRec.Customer_Name__c);
                }               
            }
            if(accIdList.size() > 0){
                List<Account> accList = new List<Account>();  
                //Added by Ankit Bhatnagar in CR# 3413 -Start
                if(!bulkActionsMap.isEmpty()) {
                    for(Central_Content__c tc : bulkActionsMap.values()) {
                        activeBulkActionsNameSet.add(tc.tcc_Number__c);
                    }
                }
                for(Action_Plan__c ap : [SELECT id,name,Status__c,tcc_Number__c,customer__c FROM Action_Plan__c WHERE Customer__c IN :accIdList AND tcc_Number__c IN :activeBulkActionsNameSet]) {
                    if(!accActionPlans.containsKey(ap.customer__c)) {
                        accActionPlans.put(ap.customer__c, new List<String>());
                    }
                    List<String> apNames = accActionPlans.get(ap.customer__c);
                    apNames.add(ap.tcc_Number__c);
                    accActionPlans.put(ap.customer__c, apNames);
                }
                //Added by Ankit Bhatnagar in CR# 3413 -End
                
                for(Account acc: [Select Id, Name, (Select Id, Action_Plan_Created__c from Account_Extensions__r) 
                                  from Account where Id IN :accIdList]){ 
                                      List<Account_Extension__c> extList = new List<Account_Extension__c>();                    
                                      extList = acc.Account_Extensions__r;
                                      for(Account_Extension__c accExt : extList){
                                          if(!accExt.Action_Plan_Created__c){
                                              acExtMap.put(acc.Id, true); 
                                              accExt.Action_Plan_Created__c = true;
                                              extListUpdate.add(accExt);
                                          }
                                      }                             
                                  }
                if(extListUpdate.size() > 0){
                    TriggerUtility.UpdateAccountExtensionmethodsetfalse();
                    update extListUpdate;
                    TriggerUtility.UpdateAccountExtensionmethodsettrue();
                }                
            }
            for(Meeting__c meetRec: newList){
                //Added by Ankit Bhatnagar in CR# 3413 -Start
                if((accActionPlans.isEmpty() || accActionPlans.containsKey(meetRec.Customer_Name__c)) && !bulkActionsMap.isEmpty()) {
                    for(Central_Content__c tcc : bulkActionsMap.values()) {
                        if(accActionPlans.isEmpty() || !accActionPlans.get(meetRec.Customer_Name__c).contains(tcc.tcc_Number__c)) {
                            Action_Plan__c acPlan2 = new Action_Plan__c();
                            acPlan2.Name = tcc.Name;
                            acPlan2.Status__c = 'New';
                            acPlan2.tcc_Number__c = tcc.tcc_Number__c;
                            acPlan2.Detail_TAM_Notes__c = tcc.Detail_TAM_Notes__c;
                            acPlan2.Due_Date__c = tcc.Due_Date__c;
                            acPlan2.Priority__c = tcc.Priority__c;
                            acPlan2.Owner__c = '<Automated Action>';
                            acPlan2.Meeting__c =  meetRec.Id;
                            acPlan2.Customer__c = meetRec.Customer_Name__c;
                            actPlanList.add(acPlan2);
                        }
                    }
                }
                //Added by Ankit Bhatnagar in CR# 3413 -End
                
                if(meetRec.Customer_Name__c != null && acExtMap.containsKey(meetRec.Customer_Name__c) && acExtMap.get(meetRec.Customer_Name__c)) {    
                    Action_Plan__c acPlan = new Action_Plan__c();
                    acPlan.Name = 'New Zscaler IP ranges on ZIA';
                    acPlan.Status__c = 'New';
                    acPlan.Detail_TAM_Notes__c = '<p>Zscaler will be expanding its global data center (DC) footprint and will soon be offering services from new or expanded locations. The following data centers expansions will be available anytime after June 13, 2021. We recommend all customers add the IP ranges listed below to your access lists, firewalls, and destination application whitelists to avoid service disruption. The IPs from these ranges can be put in use by Zscaler to Web and Internet Application communication and dynamic service resolution at any time after June 13, 2021. <br />'+
                        '<br />Americas <br /><br />'+'136.226.54.0/23 <br/>'+'136.226.56.0/23 <br/>'+'136.226.58.0/23 <br/>'+'136.226.60.0/23 <br/>'+'136.226.62.0/23 <br/>'+'136.226.64.0/23 <br/><br />'+'Europe<br/><br />'+'147.161.224.0/23<br/>'+'147.161.226.0/23<br/>'+'147.161.228.0/23<br/>'+'147.161.230.0/23<br/>'+'147.161.232.0/23<br/>'+'147.161.234.0/23<br/><br /></p>';
                    acPlan.Due_Date__c = Date.newInstance(2021, 6, 13);
                    acPlan.Priority__c = TRUE;
                    acPlan.Owner__c = '<Customer Contact>';
                    acPlan.Meeting__c =  meetRec.Id;
                    acPlan.Customer__c = meetRec.Customer_Name__c;
                    actPlanList.add(acPlan);
                }                
            }
            if(actPlanList.size() > 0){
                insert actPlanList;
            }
        }
    }
    public static void createObjectivesWithMeasures(List<Meeting__c> newList){
        Set<Id> accIds = new Set<Id>();
        String accqueryfields = '';
        String customerscorecardfields = '';
        Decimal sscalculation;
        Map<Id, Account> accmap = new Map<Id, Account>();
        Map<Id, Customer_Score_Card__c> cscmap = new Map<Id, Customer_Score_Card__c>();
        Map<Id, Integer> p1p2openmap = new map<Id, Integer>();
        Map<Id, Integer> mastercase = new map<Id, Integer>();
        Map<Id, Integer> bugmap = new map<Id, Integer>();
        Map<Id, Decimal> parentlocationmap = new map<Id, Decimal>();
        Map<Id, Decimal> clientconnectormap = new map<Id, Decimal>();
        Map<Id, Decimal> sslmap = new map<Id, Decimal>();
        List<Meeting__c> meettoprocess = new List<Meeting__c>();
        Map<String, String> centralcontent = new Map<String, String>();
        for(Meeting__c meet: newList){
            if(meet.Customer_Name__c != null){
                accIds.add(meet.Customer_Name__c);
                meettoprocess.add(meet);
            }
        }
        
        
        Map<String, Objectives_List_For_Meeting__mdt> mapobjlst = new MAP<String,Objectives_List_For_Meeting__mdt>();						   
        for(Objectives_List_For_Meeting__mdt mdt : [Select label,Field_Name__c,Calculations__c,Is_Local_Breakouts__c,Is_ZAPP__c,Object_Name__c,
                                                    Plan__c, Recommended_Alerts_for_Weekly_Discussion__c,
                                                    Record_Label__c, Template_Reference_Label__c from Objectives_List_For_Meeting__mdt]){
                                                        mapobjlst.put(mdt.label, mdt);
                                                    }
        
        for(Objectives_List_For_Meeting__mdt obl : mapobjlst.values()){
            if(obl.Object_Name__c == 'account'){
                if(obl.Field_Name__c != null && !accqueryfields.contains(obl.Field_Name__c)){
                    accqueryfields += obl.Field_Name__c + ', ';
                }
                if(obl.Plan__c != null && !accqueryfields.contains(obl.Plan__c)){
                    accqueryfields += obl.Plan__c + ', ';
                }
                if(obl.Calculations__c != null && !accqueryfields.contains(obl.Calculations__c)){
                    accqueryfields += obl.Calculations__c + ', ';
                }
            }
            if(obl.Object_Name__c == 'Customer_Score_Card__c'){
                if(obl.Field_Name__c != null && !customerscorecardfields.contains(obl.Field_Name__c)){
                    customerscorecardfields += obl.Field_Name__c + ', ';
                }
                if(obl.Plan__c != null && !customerscorecardfields.contains(obl.Plan__c)){
                    customerscorecardfields += obl.Plan__c + ', ';
                }
                if(obl.Calculations__c != null && !customerscorecardfields.contains(obl.Calculations__c)){
                    customerscorecardfields += obl.Calculations__c + ', ';
                }
            }
        }
        if(!mapobjlst.isEmpty()){
            if(!accIds.isEmpty()){
                String accquery = 'Select Id, ' + accqueryfields + ' Employee_Locations__c, (Select Id, AccountId, Master_case__c, isclosed, priority from cases where ((IsClosed = false and Priority in (\'Urgent (P1)\',\'High (P2)\')) or Master_Case__c != null) and Recordtype.Name = \'Support\') from Account where Id in :accIds';
                String customerscorecardquery = 'Select ' + customerscorecardfields + ' Account__c , Id from Customer_Score_Card__c where Account__c in :accIds';
                accmap = new Map<Id, Account>((List<Account>)Database.query(accquery));
                for(Customer_Score_Card__c csc: (List<Customer_Score_Card__c>)Database.query(customerscorecardquery)){
                    cscmap.put(csc.Account__c, csc);
                }
                //Query modified by swathi:CR#1190
                for(AggregateResult aggr: [Select Account__c, SUM(Parent_Location__c) parloc from Monthly_Policy_Configurations__c where Account__c in :accIds and Monthly_Config_Date__c = LAST_MONTH group by Account__c]){
                    parentlocationmap.put((Id)aggr.get('Account__c'), (Decimal)aggr.get('parloc'));
                }
                
                //Query modified by swathi:CR#1190
                for(AggregateResult aggr: [Select Cloud_ID__r.Account__c acc, SUM(Total_Unique_Users__c) client from BWC_Data__c where Cloud_ID__r.Account__c in :accIds and Monthly_Usage__c = LAST_MONTH group by Cloud_ID__r.Account__c]){
                    clientconnectormap.put((Id)aggr.get('acc'), (Decimal)aggr.get('client'));
                }
                //Added by Chetan #CR2328-Start,Modified the query as a part of CR#3069
                for(AggregateResult aggr: [Select Account__c acc,SUM(total_ssl_inspected_bytes__c) inspectedssl,SUM(total_ssl_bytes__c) ssl,SUM(Total_Office_365_Kb__c) office from Cloud_Usage__c where Account__c in :accIds and total_ssl_inspected_bytes__c!=null and total_ssl_bytes__c!=null and Total_Office_365_Kb__c!=null and Usage_Pull_Date__c= LAST_N_DAYS:30 group by Account__c]){
                    sscalculation=((Decimal)aggr.get('inspectedssl')/((Decimal)aggr.get('ssl')-(((Decimal)aggr.get('office')*1024))))*100;
                    sslmap.put((Id)aggr.get('acc'),sscalculation);
                    system.debug(sslmap);
                }
                //Added by Chetan #CR2328-End
                if(!accmap.isEmpty() && !accmap.values().isEmpty() && !accmap.values().Cases.isEmpty()){
                    for(Case cs : accmap.values().Cases){
                        if(!cs.IsClosed && (cs.Priority == 'Urgent (P1)' || cs.Priority == 'High (P2)')){
                            if(p1p2openmap.containsKey(cs.AccountId)){
                                Integer count = p1p2openmap.get(cs.AccountId);
                                p1p2openmap.put(cs.AccountId, count++);
                            }else{
                                p1p2openmap.put(cs.AccountId, 1);
                            }
                        }
                        if(cs.Master_Case__c != null){
                            if(mastercase.containsKey(cs.AccountId)){
                                Integer count = mastercase.get(cs.AccountId);
                                mastercase.put(cs.AccountId, count++);
                            }else{
                                mastercase.put(cs.AccountId, 1);
                            }
                        }
                    }
                }
                
                for(AggregateResult aggr : [Select AccountId, count(Id) cntcase from case where AccountId in :accIds and Jira_Id__c != null and Recordtype.Name = 'Support' group by AccountId]){
                    bugmap.put((String)aggr.get('AccountId'), (Integer)aggr.get('cntcase'));
                }
            }
            
            for(Central_Content__c con: [Select id, Name, API_Name__c, Content__c from Central_Content__c where API_Name__c != null order by createddate desc]){
                if(!centralcontent.containskey(con.API_Name__c.tolowerCase())){
                    centralcontent.put(con.API_Name__c.tolowerCase(), con.content__c);
                }
            }
        }
        List<Objective__c> objlst = new List<Objective__c>();
        for(Meeting__c meet: meettoprocess){
            
            for(Objectives_List_For_Meeting__mdt obl : mapobjlst.values()){
                Objective__c obj = new objective__c(Meeting_ID__c = meet.id, Name=obl.Record_Label__c, visible_In_Doc__c=true); 
                //Recommended_Alerts_for_Weekly_Discussion__c
                obj.Recommended_Alerts_for_Weekly_Discussion__c =  obl.Recommended_Alerts_for_Weekly_Discussion__c;
                
                if(obl.Is_Local_Breakouts__c){
                    if(parentlocationmap != null && !parentlocationmap.isEmpty() && parentlocationmap.containskey(meet.customer_name__c)){
                        obj.Measurable__c = (Decimal)parentlocationmap.get(meet.customer_name__c);
                    }
                    if(accmap != null && !accmap.isEmpty() && accmap.containskey(meet.customer_name__c)){
                        Account acc = accmap.get(meet.customer_name__c);
                        obj.Plan__c = acc.Employee_Locations__c;
                    }
                    if(obj.Measurable__c != null && obj.Plan__c > 0 && obj.Plan__c != null){
                        obj.Calculations__c = (((obj.Measurable__c / obj.Plan__c) * 100) < 100) ? ((obj.Measurable__c / obj.Plan__c) * 100) : 100 ;//modified by Swathi : CR1221
                    }
                }else if(obl.Is_ZAPP__c){
                    if(clientconnectormap != null && !clientconnectormap.isEmpty() && clientconnectormap.containskey(meet.customer_name__c)){
                        obj.Measurable__c = (Decimal)clientconnectormap.get(meet.customer_name__c);
                    }
                    if(accmap != null && !accmap.isEmpty() && accmap.containskey(meet.customer_name__c)){
                        Account acc = accmap.get(meet.customer_name__c);
                        obj.Plan__c = acc.No_of_Platform_Seats__c == 0 ? acc.Users_ZPA_Platform__c : acc.No_of_Platform_Seats__c;
                    }
                    if(obj.Measurable__c != null && obj.Plan__c > 0 && obj.Plan__c != null){
                        obj.Calculations__c = (((obj.Measurable__c / obj.Plan__c) * 100) < 100 ) ? ((obj.Measurable__c / obj.Plan__c) * 100) : 100;//modified by Swathi : CR1221
                    }
                    //obj.Calculations__c = obl.Calculations__c != null && obl.Calculations__c != '' ? (Decimal)csc.get(obl.Calculations__c.tolowerCase()) : null;
                    //obj.Plan__c = obl.Plan__c != null && obl.Plan__c != '' ? (Decimal)csc.get(obl.Plan__c.tolowerCase()) : null;
                }else if(obl.Object_Name__c.tolowerCase() == 'customer_score_card__c' && cscmap != null && !cscmap.isEmpty() && cscmap.containskey(meet.customer_name__c)){
                    Customer_Score_Card__c csc = cscmap.get(meet.customer_name__c);
                    //obj.Measurable__c = obl.Field_Name__c != null && obl.Field_Name__c != '' ? (Decimal)csc.get(obl.Field_Name__c.tolowerCase()) : null;
                    //obj.Calculations__c = obl.Calculations__c != null && obl.Calculations__c != '' ? ((Decimal)csc.get(obl.Calculations__c.tolowerCase()) < 100 ? (Decimal)csc.get(obl.Calculations__c.tolowerCase()) : 100) : null; // Modified by Swathi : CR1221
                    //Added by Chetan--CR#2328 Start (Modified for CR#3089)                    
                    obj.Calculations__c= sslmap.get(meet.customer_name__c) < 100 ? sslmap.get(meet.customer_name__c) :100 ;
                    obj.Measurable__c= sslmap.get(meet.customer_name__c) < 100 ? sslmap.get(meet.customer_name__c) :100;                                
                    //Added by Chetan--CR#2328 End (Modified for CR#3089) 
                    obj.Plan__c = obl.Plan__c != null && obl.Plan__c != '' ? (Decimal)csc.get(obl.Plan__c.tolowerCase()) : null;
                }else if(obl.Object_Name__c.tolowerCase() == 'account' && accmap != null && !accmap.isEmpty() && accmap.containskey(meet.customer_name__c)){
                    Account acc = accmap.get(meet.customer_name__c);
                    obj.Measurable__c = obl.Field_Name__c != null && obl.Field_Name__c != '' ? (Decimal)acc.get(obl.Field_Name__c.tolowerCase()) : null;
                    system.debug((Decimal)acc.get(obl.Calculations__c.tolowerCase()));
                    system.debug(acc.get(obl.Calculations__c.tolowerCase()));
                    //added by Swathi : CR1221 Start 
                    if(obl.Field_Name__c == 'Authenticated_Users_Deployed__c' || obl.Field_Name__c == 'ZPA_Enrolled_Users_L31D__c'){
                        obj.Calculations__c = obl.Calculations__c != null && obl.Calculations__c != '' ? ((Decimal)acc.get(obl.Calculations__c.tolowerCase()) < 100 ? (Decimal)acc.get(obl.Calculations__c.tolowerCase()) : 100): null;
                    }
                    //added by Swathi : CR1221 End
                    else
                        obj.Calculations__c = obl.Calculations__c != null && obl.Calculations__c != '' ? (Decimal)acc.get(obl.Calculations__c.tolowerCase()): null;
                    obj.Plan__c = obl.Plan__c != null && obl.Plan__c != '' ? (Decimal)acc.get(obl.Plan__c.tolowerCase()) : null;
                }else if(obl.Object_Name__c.tolowerCase() == 'case'){
                    if(obl.Field_Name__c.tolowerCase() == 'p1p2open'){
                        obj.Measurable__c = p1p2openmap.get(meet.Customer_Name__c);
                    }else if(obl.Field_Name__c.tolowerCase() == 'mastercases'){
                        obj.Measurable__c = mastercase.get(meet.Customer_Name__c);
                    }else if(obl.Field_Name__c.tolowerCase() == 'jiracases'){
                        obj.Measurable__c = bugmap.get(meet.Customer_Name__c);
                    } 
                }else if(obl.Object_Name__c.tolowerCase() == 'centralcontent'){
                    obj.TAM_Notes__c = centralcontent.get(obl.Field_Name__c.tolowerCase());
                }
                obj.Calculations__c = obj.Calculations__c != null ? obj.Calculations__c.setScale(2) : obj.Calculations__c;
                objlst.add(obj);
            }
            
        }
        if(!objlst.isEmpty()){
            insert objlst;
        }
    }
    //Added by Chetan : CR# 3357-Start
    public static void validateCompletedStatus(List<Meeting__c> newList,Map<id,Meeting__c> oldMap)
    {
        Map<Id, List<String>> mapOfMeetingAndEmailAddress = new Map<Id, List<String>>();
        Map<Id, List<String>> mapOfMeetingAndParticipants = new Map<Id, List<String>>();
        List<String> listOfParticipants = new List<String>();
        List<String> listOfExternalParticipants = new List<String>();
        List<Id> listOfScopeId = new List<Id>();
        
        for(Meeting__c meet: newList){
            if(meet.Status__c=='Completed' && oldMap.get(meet.Id).Status__c !=meet.Status__c && meet.Participants__c!=null){
                listOfScopeId.add(meet.Id);
                listOfParticipants = meet.Participants__c.split(',');
                for(string email:listOfParticipants)
                {
                    if(!email.contains('@zscaler.com')){
                        listOfExternalParticipants.add(email);
                    }
                }
                if(!listOfExternalParticipants.isEmpty()){
                    if(!mapOfMeetingAndParticipants.containsKey(meet.id)){
                        mapOfMeetingAndParticipants.put(meet.id,new List<String>());
                    }
                    
                    mapOfMeetingAndParticipants.get(meet.id).addAll(listOfExternalParticipants);
                }
                
            }
        }
        if(!listOfScopeId.isEmpty()){
            for(EmailMessage em: [select id ,RelatedToId,ToAddress, CCAddress,Incoming from EmailMessage where RelatedToId IN:listOfScopeId and Incoming=false]){
                List<String> listOfEmails = new List<String>(); 
                if(em.ToAddress!=null){
                    for(String str : em.ToAddress.split(';')){
                        listOfEmails.add(str.trim());
                    }  
                }
                if(em.CcAddress!=null){
                    for(String str : em.CCAddress.split(';')){
                        listOfEmails.add(str.trim());
                    }          
                }             
                if(!mapOfMeetingAndEmailAddress.containsKey(em.RelatedToId)){
                    mapOfMeetingAndEmailAddress.put(em.RelatedToId, new List<String>());
                }
                mapOfMeetingAndEmailAddress.get(em.RelatedToId).addAll(listOfEmails);
            }
            
            for(Meeting__c meet:newList){
                Boolean emailSent=false;
                if(meet.Status__c=='Completed' && oldMap.get(meet.Id).Status__c !=meet.Status__c){
                    System.debug('mapOfMeetingAndParticipants' + mapOfMeetingAndParticipants);
                    System.debug('mapOfMeetingAndEmailAddress' + mapOfMeetingAndEmailAddress);
                    System.debug('Statement 1');
                    if(mapOfMeetingAndParticipants.containsKey(meet.Id) && mapOfMeetingAndParticipants.get(meet.Id)!=null && mapOfMeetingAndEmailAddress.containsKey(meet.Id)){
                        System.debug('Statement 2');
                        for(String email: mapOfMeetingAndParticipants.get(meet.Id)){
                            List<String> listOfEmail = mapOfMeetingAndEmailAddress.get(meet.Id);
                            System.debug('List Emails '+listOfEmail);
                            System.debug('Email to be checked '+email);
                            if(listOfEmail.contains(email)){
                                System.debug('Email'+ email);
                                //System.debug('Error Executed');
                                emailSent = true;
                            }
                        }
                        if(!emailSent){
                            meet.addError(Label.TAM_Meeting_Error);
                        }
                    }else{
                        System.debug('No Email Sent Error');
                        meet.addError(Label.TAM_Meeting_Error);
                    }
                }
                
            }
        }
        TriggerUtility.executeValidateCompletedStatusExecuted();     
    }
    //Added by Chetan : CR# 3357-Start

    public static void updateParticipants(List<Meeting__c> newList)
    {
        Set<Id> accountIds=new Set<Id>();
        Map<Id,Meeting__c> mapParticipants= new Map<Id,Meeting__c>();
        for(Meeting__c meet:newList){
            accountIds.add(meet.Customer_Name__c);
        }
        if(!accountIds.isEmpty()){
            for(Account acc :[SELECT Id, (select id,Participants__c from Meetings__r order by CreatedDate DESC Limit 1) FROM Account where Id IN : accountIds]){
                if(!mapParticipants.containsKey(acc.Id) && acc.Meetings__r.size()>0){
                    mapParticipants.put(acc.Id,acc.Meetings__r);
                }
            }     
        }
        System.debug('Participants Map '+ mapParticipants);
        if(mapParticipants.size() > 0){
            for(Meeting__c meet:newList){
                if(meet.Customer_Name__c!=null && mapParticipants.get(meet.Customer_Name__c)!=null && mapParticipants.containskey(meet.Customer_Name__c) && meet.Copy_CC_List_From_Previous_TAM_Meeting__c==true){
                    System.debug('Inside final loop');
                    if(meet.Participants__c!=null){
                       meet.Participants__c+=','+ mapParticipants.get(meet.Customer_Name__c).Participants__c; 
                    }else{
                       meet.Participants__c = mapParticipants.get(meet.Customer_Name__c).Participants__c; 
                    }
                }
            }
        }
        TriggerUtility.executeUpdateParticipantsExecuted();
    }
}