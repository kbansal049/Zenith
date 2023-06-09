/*****************************************************************************************
Name: SCIExternalAttendeeTriggerHelper
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Trigger helper class for genericSCIExternalAttendeeTrigger.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            4-Nov-2016    Initial Development
******************************************************************************************/



public class SCIExternalAttendeeTriggerHelper{
    
    /**
*@purpose : Method to SCI Engagement Type based external atendee on SCI
*@param :  Old list of SCI External Attendee.
*@return : None
**/
    public static void udpateSCIforEngagement(list<SCI_External_Attendee__c> oldSCIExtAttendeeList){
        set<Id> sciIdSet = new set<Id>();
        string attendeesType = '';
        set<String> attendeesTypeSet = new set<string>();
        
        list<Significant_Customer_Interaction__c> sciUpdateList = new list<Significant_Customer_Interaction__c>();
        
        for(SCI_External_Attendee__c sciExt : oldSCIExtAttendeeList){
            sciIdSet.add(sciExt.Significant_Customer_Interaction__c);
        }
        
        for(Significant_Customer_Interaction__c sci : [Select id, (Select id, Attendee_Name__c, Head_of_networking__c, Head_Of_It__c,
                                                                   Head_of_Security__c, Procurement_Contact__c, Budget_Authority__c
                                                                   from SCI_External_Attendee__r)
                                                       from Significant_Customer_Interaction__c where Id IN: sciIdSet]){
                                                           attendeesTypeSet = new set<String>();
                                                           for(SCI_External_Attendee__c attendee : sci.SCI_External_Attendee__r){
                                                               if(attendee.Head_Of_It__c)
                                                                   attendeesTypeSet.add('Head of IT;');
                                                               if(attendee.Head_of_networking__c)
                                                                   attendeesTypeSet.add('Head of Networking;');
                                                               if(attendee.Head_of_Security__c)
                                                                   attendeesTypeSet.add('Head of Security;');
                                                               // if(attendee.Budget_Authority__c)
                                                               //     attendeesTypeSet.add('Budget Authority;');
                                                               // if(attendee.Procurement_Contact__c)
                                                               //     attendeesTypeSet.add('Procurement Contact;');
                                                           }
                                                           
                                                           for(String str : attendeesTypeSet)
                                                               attendeesType += str;
                                                           sciUpdateList.add(new Significant_Customer_Interaction__c(id = sci.id, Area_of_Influence__c = attendeesType));
                                                           
                                                       }
        if(!sciUpdateList.isEmpty())
            database.update(sciUpdateList, false);
        TriggerUtility.udpateSCIforEngagementExecuted();
    }
    
    public static void updatePartnerAccountForSCI(List<SCI_External_Attendee__c> lstOldAttendees) {
        Set<Id> sciIds = new Set<Id>();
        Map<Id, Id> mapSciAndAccountIds = new Map<Id, Id>();
        
        for (SCI_External_Attendee__c attendee : lstOldAttendees) {
            sciIds.add(attendee.Significant_Customer_Interaction__c);
        }
        
        for (SCI_External_Attendee__c existingAttendee : [SELECT Id, Attendee_Name__r.AccountId, Significant_Customer_Interaction__c FROM SCI_External_Attendee__c
                                                          WHERE Significant_Customer_Interaction__c IN :sciIds
                                                          AND Attendee_Name__r.Account.Type = 'Partner'
                                                          ORDER BY Date_Created__c DESC]) {
                                                              if (!mapSciAndAccountIds.containsKey(existingAttendee.Significant_Customer_Interaction__c)) {
                                                                  mapSciAndAccountIds.put(existingAttendee.Significant_Customer_Interaction__c, existingAttendee.Attendee_Name__r.AccountId);
                                                              }
                                                          }
        
        List<Significant_Customer_Interaction__c> lstSCIsToUpdate = new List<Significant_Customer_Interaction__c>();
        
        for (Id sciId : sciIds) {
            if (mapSciAndAccountIds.containsKey(sciId)) {
                lstSCIsToUpdate.add(new Significant_Customer_Interaction__c(Id = sciId, Partner_Account__c = mapSciAndAccountIds.get(sciId)));
            } else {
                lstSCIsToUpdate.add(new Significant_Customer_Interaction__c(Id = sciId, Partner_Account__c = null));
            }
        }
        
        if (lstSCIsToUpdate.size() > 0) {
            Database.update(lstSCIsToUpdate, false);
            TriggerUtility.updatePartnerAccountForSCIExecuted();
        }
    }
    //UpdateContactSCICount
    public static void updateContactSCICount(List<SCI_External_Attendee__c> lstOfAttendees){
        Triggers_Switch__c tsmap = Triggers_Switch__c.getInstance('Execute_UpdateContactSCICount');
        if(tsmap != null && tsmap.Execute__c){
            Set<Id> contactIds = new Set<Id>();
            for(SCI_External_Attendee__c attendee : lstOfAttendees){
                contactIds.add(attendee.Attendee_Name__c);
            }
            List<Contact> conList = [SELECT id,SCI_Count__c,(SELECT Id FROM SCI_External_Attendee__r) FROM Contact WHERE ID IN :contactIds];
            List<Contact> contactToUpdate = new List<Contact>();
            for(Contact con : conList){
                List<SCI_External_Attendee__c> externalAttendees = con.SCI_External_Attendee__r;
                if(externalAttendees.isEmpty() && con.SCI_Count__c != 0){
                    con.SCI_Count__c = 0;
                    contactToUpdate.add(con);
                }else{
                    if(con.SCI_Count__c != externalAttendees.size()){
                        con.SCI_Count__c = externalAttendees.size();
                        contactToUpdate.add(con);
                    }
                }
            }
            ContactTriggerHelper.skipTrigger = true;
            Triggerhandler.bypass('ContactTriggerHandler');
            List<Database.SaveResult> srList1 = database.update(contactToUpdate, false);
            for (Database.SaveResult sr : srList1) {
                if (!sr.isSuccess()) {
                    String errmsg = 'Error for ContactId: ' + sr.getId() + '. ';
                    for(Database.Error err: sr.getErrors()){
                        errmsg += err.getMessage();
                        ZscalerErrorLogsUtility.insertLogs('SCIExternalAttendeeTriggerHelper', 'updateContactSCICount', 'Apex',userInfo.getUserId(),'Sales cloud', err.getMessage(), err.getMessage(), err.getMessage());
                    }
                }
            }
        }
        TriggerUtility.updateContactCountSCIExecuted();
    }
    
}