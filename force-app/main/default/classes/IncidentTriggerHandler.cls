/**
 * Name : IncidentTriggerHandler
 * Description : Handler class for IncidentTrigger
 * Test Class : 
 * Initial Author : Ankit Bhatnagar
 */
  
public class IncidentTriggerHandler extends TriggerHandler{
    
    public override void beforeInsert(){
        //{Severity -> {Region -> CCList}}
        Id cloudIncRecordTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('Cloud_Incident').getRecordTypeId();
        Map<String, Map<String, String>> ccListConfig = new Map<String, Map<String, String>>();
        List<String> allConfigEmails=new List<String>();
        List<String> allCCEmails=new List<String>();
        for(Incident_CC_List_Configurations__mdt meta : [SELECT id,Region__c,Severity__c, CC_List__c FROM Incident_CC_List_Configurations__mdt]) {
            allConfigEmails.add(meta.CC_List__c);
            if(!ccListConfig.containsKey(meta.severity__c)) {
                ccListConfig.put(meta.severity__c, new Map<String, String>());
            }
            if(!ccListConfig.get(meta.severity__c).containsKey(meta.Region__c)) {
                ccListConfig.get(meta.severity__c).put(meta.Region__c, meta.CC_List__c);
            }
        }
        if(!allConfigEmails.isEmpty()) {
            for(String s:allConfigEmails){
                List<String> splittedCCEmails=new List<String>();
                splittedCCEmails =s.split(';');
                allCCEmails.addAll(splittedCCEmails);
            }
        }
        List<Entitlement> ents = new List<Entitlement>([Select Id, Name from Entitlement where Name Like '%Incident%' AND EndDate = null and Status = 'Active']);
        List<BusinessHours> hours = new List<BusinessHours>([SELECT Id, Name, IsActive, IsDefault FROM BusinessHours WHERE Name Like '%Default%']);
        for(Incident inc : (List<Incident>)Trigger.new) {
            //set business Hours and Entitlement on Incident - start
            if(inc.RecordTypeId == cloudIncRecordTypeId) {
                if(!hours.isEmpty()) {
                    inc.BusinessHoursId = hours.get(0).id;
                }
                if(!ents.isEmpty()) {
                    inc.EntitlementId = ents.get(0).id;
                }
                //set business Hours and Entitlement on Incident - end
                if(ccListConfig.containsKey(inc.priority) && ccListConfig.get(inc.priority).containsKey(inc.Region__c)) {
                    setCCList(inc, null, ccListConfig.get(inc.priority).get(inc.Region__c),allCCEmails);
                }
                //Added by Hitesh - IBA-1671 Start
                Boolean externalEmailFlag = checkMailDomain(inc ,null);
                if(externalEmailFlag) {
                    inc.addError('All the Incident Collaborator emails must belong to Zscaler domain');
                }
                //Added by Hitesh - IBA-1671 End
                setImpact(inc, null);
            }
        }
    }

    public override void afterInsert() {
        List<Incident> cloudIncidents = new List<Incident>();
        Id cloudIncRecordTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('Cloud_Incident').getRecordTypeId();
        for(Incident inc : (List<Incident>)Trigger.new) {
            if(inc.recordTypeId == cloudIncRecordTypeId) {
                cloudIncidents.add(inc);
            }
        }
        if(!cloudIncidents.isEmpty()) {
            CustomNotificationFromApex.sendNotifications(cloudIncidents, null);
        }
    }
    
    public override void beforeUpdate(){
        Id cloudIncRecordTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('Cloud_Incident').getRecordTypeId();
        //{Severity -> {Region -> CCList}}
        Map<String, Map<String, String>> ccListConfig = new Map<String, Map<String, String>>();
        List<String> allConfigEmails=new List<String>();
        List<String> allCCEmails=new List<String>();
        for(Incident_CC_List_Configurations__mdt meta : [SELECT id,Region__c,Severity__c, CC_List__c FROM Incident_CC_List_Configurations__mdt]) {
            allConfigEmails.add(meta.CC_List__c);
            if(!ccListConfig.containsKey(meta.severity__c)) {
                ccListConfig.put(meta.severity__c, new Map<String, String>());
            }
            if(!ccListConfig.get(meta.severity__c).containsKey(meta.Region__c)) {
                ccListConfig.get(meta.severity__c).put(meta.Region__c, meta.CC_List__c);
            }
        }
        if(!allConfigEmails.isEmpty()) {
            for(String s:allConfigEmails) {
                List<String> splittedCCEmails=new List<String>();
                splittedCCEmails =s.split(';');
                allCCEmails.addAll(splittedCCEmails);
            }
        }
        
        for(Incident inc : (List<Incident>)Trigger.new) {
            if(inc.RecordTypeId == cloudIncRecordTypeId) {
                if(ccListConfig.containsKey(inc.priority) && ccListConfig.get(inc.priority).containsKey(inc.Region__c)) {
                    setCCList(inc, (Incident)Trigger.oldMap.get(inc.id), ccListConfig.get(inc.priority).get(inc.Region__c),allCCEmails);
                }
                //Added by Ankit - Start
                if((inc.RCA_Status__c != ((Incident)Trigger.oldMap.get(inc.id)).RCA_Status__c && String.isNotBlank(inc.RCA_Status__c)) || 
                    (inc.Status != ((Incident)Trigger.oldMap.get(inc.id)).Status && String.isNotBlank(inc.Status))) {
                    setResolutionDetails(inc, (Incident)Trigger.oldMap.get(inc.id));
                }
                //Added by Ankit - End
    
                //Added by Hitesh - IBA-1671 Start
                Boolean externalEmailFlag = checkMailDomain(inc ,(Incident)Trigger.oldMap.get(inc.id));
                if(externalEmailFlag) {
                    inc.addError('All the Incident Collaborator emails must belong to Zscaler domain');
                } 
                //Added by Hitesh - IBA-1671 End
                setImpact(inc, (Incident)Trigger.oldMap.get(inc.id));
            }
        }
        logTicketUpdate((List<Incident>)Trigger.new, (Map<Id, Incident>)Trigger.oldMap);
    }

    public override void afterUpdate() {
        List<Incident> cloudIncidents = new List<Incident>();
        Id cloudIncRecordTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('Cloud_Incident').getRecordTypeId();
        for(Incident inc : (List<Incident>)Trigger.new) {
            if(inc.recordTypeId == cloudIncRecordTypeId) {
                cloudIncidents.add(inc);
            }
        }
        if(!cloudIncidents.isEmpty()) {
            CustomNotificationFromApex.sendNotifications(cloudIncidents, (Map<Id,Incident>)Trigger.oldMap);
            completeMilestones((List<Incident>)Trigger.new, (Map<Id, Incident>)Trigger.oldMap);
        }
    }

    public void setCCList(Incident inc, Incident incOld, String ccList, List<String> allCCEmails) {
        List<String> ccEmails = new List<String>();
        List<String> incCCEmails = new List<String>();
        if(String.isNotBlank(ccList)) {
            ccEmails = ccList.split(';');
        }
        if(String.isNotBlank(inc.CC_List__c)) {
            incCCEmails = inc.CC_List__c.split(';');
        }
        if(!allCCEmails.isEmpty()){
            for(String s:incCCEmails){
                if(!allCCEmails.contains(s)){
                    ccEmails.add(s);
                }
            }
        }
        if(incOld == null || (incOld != null && (inc.priority != incOld.priority) || (inc.Region__c != incOld.Region__c))) {
            if(!ccEmails.isEmpty()) {
                inc.CC_List__c = String.join(ccEmails,';');
            }
        }
    }

    public void logTicketUpdate(List<Incident> incidents, Map<Id, Incident> oldIncidents) {
        Id cloudIncRecordTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('Cloud_Incident').getRecordTypeId();
        List<Incident_Update__c> incidentUpdates = new List<Incident_Update__c>();
        for(Incident inc : incidents) {
            if(inc.RecordTypeId == cloudIncRecordTypeId) {
                if(inc.Ticket_update__c != oldIncidents.get(inc.id).Ticket_update__c && String.isNotBlank(inc.Ticket_update__c)) {
                    if(inc.Ticket_update__c != inc.Last_Update__c) {
                        inc.Last_Update__c = inc.Ticket_update__c;
                        inc.Last_Update_Time__c = System.now();
                        incidentUpdates.add(
                            new Incident_Update__c(Incident__c = inc.id, Update__c = inc.Last_Update__c, type__c = 'Internal')
                        );
                    }
                    inc.Ticket_update__c = '';
                }
                if(inc.Customer_Update__c != oldIncidents.get(inc.id).Customer_Update__c && String.isNotBlank(inc.Customer_Update__c)) {
                    if(inc.Customer_Update__c != inc.Last_Customer_Update__c) {
                        inc.Last_Customer_Update__c = inc.Customer_Update__c;
                        inc.Last_Customer_Update_Time__c = System.now();
                        incidentUpdates.add(
                            new Incident_Update__c(Incident__c = inc.id, Update__c = inc.Last_Customer_Update__c, type__c = 'Customer')
                        );
                    }
                    inc.Customer_Update__c = '';
                }
            }
        }
        if(!incidentUpdates.isEmpty()) {
            Database.insert(incidentUpdates, false);
        }
    }

    //Added by Hitesh - IBA-1671 Start
    public Boolean checkMailDomain(Incident inc, Incident incOld) {
        Boolean extEmailFlag = false ;
        if(incOld == null || (incOld != null && (inc.CC_List__c != incOld.CC_List__c))) {
            List<String> cclist = new List<String>();
            if(String.isNotBlank(inc.CC_List__c)) {
                cclist = inc.CC_List__c.split(';');
            }
            for(String str : cclist) {
                if(!str.endsWith('@zscaler.com')) {
                    extEmailFlag = true;
                    break;
                } 
            }  
        }
        return extEmailFlag;
    }
    //Added by Hitesh - IBA-1671 End

    public void completeMilestones(List<Incident> incidents, Map<Id, Incident> oldIncidents) {
        Id cloudIncRecordTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('Cloud_Incident').getRecordTypeId();
        Set<String> incidentIds = new Set<String>();
        for(Incident inc : incidents) {
            if(inc.RecordTypeId == cloudIncRecordTypeId) {
                if(oldIncidents.containsKey(inc.id) && inc.status != oldIncidents.get(inc.id).status) {
                    if(inc.status == 'Closed' || inc.status == 'Resolved' || 
                    inc.status == 'RCA in Progress' || inc.status == 'RCA Complete' ||
                    inc.status == 'Workaround Provided') {
                        incidentIds.add(inc.id);
                    }
                }
            }
        }  
        if(!incidentIds.isEmpty()) {
            List<EntityMilestone> entityMilestones = [SELECT Id, completionDate FROM EntityMilestone WHERE ParentEntityId in :incidentIds AND completionDate = null];
            if(!entityMilestones.isEmpty()){
                for(EntityMilestone em : entityMilestones){
                    em.completionDate = System.now();
                }
                update entityMilestones;
            }
        }    
    }   

    //Added by Ankit - Start
    //Set up Resolution Details
    public void setResolutionDetails(Incident inc, Incident incOld) {
        if(incOld == null || (incOld != null && (inc.status != incOld.status))) { 
            if(inc.status == 'RCA in Progress') {
                inc.ResolvedById = UserInfo.getUserId();
            }
        }
        if(incOld == null || (incOld != null && (inc.RCA_Status__c != incOld.RCA_Status__c))) { 
            if(inc.RCA_Status__c == 'Internal in progress') {
                inc.ResolutionDateTime = System.now();
            }
        }
    }
    //Added by Ankit - End

    //Added by Ankit - Start
    //Set Impact
    public void setImpact(Incident inc, Incident incOld) {
        if(incOld == null || (incOld != null && (inc.priority != incOld.priority))) { 
            if(inc.priority=='SEV-1') {
                inc.impact = 'Critical';
            }
            else if(inc.priority=='SEV-2') {
                inc.impact = 'High';
            }
            else if(inc.priority=='SEV-3') {
                inc.impact = 'Medium';
            }
            else if(inc.priority=='SEV-4') {
                inc.impact = 'Low';
            }
        }
    }
    //Added by Ankit - End
}