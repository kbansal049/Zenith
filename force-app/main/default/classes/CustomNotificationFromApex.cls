/**
 * Name : CustomNotificationFromApex
 * Description : Send out notifications from Apex
 * Test Class : 
 * Initial Author : Chetan Sunil Pednekar
 */

public without sharing class CustomNotificationFromApex {

    public static void SendNotifications(List<Incident> incidentList,Map<Id,Incident> incidentOldMap){
        Id cloudIncRecordTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('Cloud_Incident').getRecordTypeId();
        String groupId = '';
        String groupIdCritical = '';
        for(Group g : [SELECT id,DeveloperName FROM Group WHERE DeveloperName = 'Incident_Group' OR DeveloperName = 'Incident_Group_Critical']) {
            if(g.DeveloperName == 'Incident_Group') {
                groupId = g.id;
            }
            else if(g.DeveloperName == 'Incident_Group_Critical') {
                groupIdCritical = g.id;
            }
        }
        CustomNotificationType notificationType =[SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Incident_Logged'];
        for(Incident inc:incidentList){
            if(inc.recordTypeId == cloudIncRecordTypeId) {
                Set<String> incNotificationRecipients = new Set<String>{groupId};
                if(inc.Priority == 'SEV-1' && String.isNotBlank(groupIdCritical)) {
                    incNotificationRecipients.add(groupIdCritical);
                }
                if(Trigger.isUpdate){
                    if((inc.Status !=null && inc.Status !=incidentOldMap.get(inc.Id).Status) || Test.isRunningTest()) {
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        String title='Incident ('+inc.IncidentNumber+') '+ 'updated!';
                        String body='Status of '+ inc.IncidentNumber + ' ('+ inc.Subject + ') is updated to '+inc.status+'.' + 'Click here to navigate to Incident record.';
                        notification.setTitle(title);
                        notification.setBody(body);
                        notification.setNotificationTypeId(notificationType.Id);
                        notification.setTargetId(inc.Id);
                        try {
                            notification.send(incNotificationRecipients);
                        }
                        catch (Exception e) {
                            System.debug('## Problem sending notification: ' + e.getMessage());
                        }
                    }
                }
                if(Trigger.isInsert){
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    String title='New Incident ('+inc.IncidentNumber+') '+ 'logged!';
                    String body='Subject: '+ inc.subject + ' | Severity: '+ inc.priority +' | Category: '+inc.category +'. Please click to go to the Incident Record Page.';
                    notification.setTitle(title);
                    notification.setBody(body);
                    notification.setNotificationTypeId(notificationType.Id);
                    notification.setTargetId(inc.Id);
                    try {
                        notification.send(incNotificationRecipients);
                    }
                    catch (Exception e) {
                        System.debug('## Problem sending notification: ' + e.getMessage());
                    }
                }
            }
        }
    }

    public static void notifyUsersOnIncidentSendUpdates(Map<String, String> incidentUpdateTypeMap){
        if(!incidentUpdateTypeMap.isEmpty()) {
            String groupId = '';
            String groupIdCritical = '';
            for(Group g : [SELECT id,DeveloperName FROM Group WHERE DeveloperName = 'Incident_Group' OR DeveloperName = 'Incident_Group_Critical']) {
                if(g.DeveloperName == 'Incident_Group') {
                    groupId = g.id;
                }
                else if(g.DeveloperName == 'Incident_Group_Critical') {
                    groupIdCritical = g.id;
                }
            }
            CustomNotificationType notificationType =[SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Incident_Logged'];
            for(Incident inc: [SELECT id,Priority,IncidentNumber FROM Incident WHERE Id IN : incidentUpdateTypeMap.keySet() AND RecordType.DeveloperName = 'Cloud_Incident']){
                Set<String> incNotificationRecipients = new Set<String>{groupId};
                if(inc.Priority == 'SEV-1' && String.isNotBlank(groupIdCritical)) {
                    incNotificationRecipients.add(groupIdCritical);
                }
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                String title=incidentUpdateTypeMap.get(inc.Id)+' update sent on Incident ('+inc.IncidentNumber+')';
                String body='An '+incidentUpdateTypeMap.get(inc.Id)+' update has been sent on Incident ('+inc.IncidentNumber+').' + ' Please click to go to the Incident Record Page.';
                notification.setTitle(title);
                notification.setBody(body);
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(inc.Id);
                try {
                    notification.send(incNotificationRecipients);
                }
                catch (Exception e) {
                    System.debug('## Problem sending notification: ' + e.getMessage());
                }
            }
        }
    }
}