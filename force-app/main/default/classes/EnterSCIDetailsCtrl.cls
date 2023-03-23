public with sharing class EnterSCIDetailsCtrl {
    
    @AuraEnabled
    public static List<contact> displayConRecord(String accId){
        List<contact> conList = new List<contact>();
        conList =  [SELECT Id,Name,AccountId,Account.Name,Title,
        IT_Executive__c, Head_of_Security_Account__c, Head_of_Networking_CTO_Account__c, Budget_Authority__c, Procurement_Contact__c, Cloud_Architect__c, Service_Owner__c,Email,Phone from Contact where AccountId = :accId];   
        return conList;
    }
    
    
    @AuraEnabled
    public static List<contact> displayDataConRecord(String accId, String dataRec){
        
        List<Contact> dataContactsList = (List<Contact>) JSON.deserialize(dataRec, List<Contact>.class);
        set<Id> dataId = new set<Id>();
        for(Contact dataCon: dataContactsList){
            dataId.add(dataCon.id);
        }
        List<contact> conList = new List<contact>();
        conList =  [SELECT Id,Name,AccountId,Account.Name,Title,
        IT_Executive__c, Head_of_Security_Account__c, Head_of_Networking_CTO_Account__c, Budget_Authority__c, Procurement_Contact__c, Cloud_Architect__c, Service_Owner__c,Email,Phone from Contact where AccountId = :accId AND Id NOT IN :dataId];   
        return conList;
    }

    @AuraEnabled
    public static List<contact> displayCMTConRecord(String accId){
        List<contact> conList = new List<contact>();
        if(accId != null){
            List<Account> accList=[Select HeadOfIT__c, Head_of_Architecture__c , HeadOfNetworking__c, HeadOfSecurity__c from Account 
            where id=:accId ];
            if(!accList.isEmpty()){
                Account acc = accList[0];
                Set<Id> accFieldIdSet=new Set<Id>();
            
                if(acc.HeadOfIT__c !=null){
                    accFieldIdSet.add(acc.HeadOfIT__c);
                }
                if(acc.Head_of_Architecture__c !=null){
                    accFieldIdSet.add(acc.Head_of_Architecture__c);
                }
                if(acc.HeadOfNetworking__c != null){
                    accFieldIdSet.add(acc.HeadOfNetworking__c);
                }
                if(acc.HeadOfSecurity__c!=null){
                    accFieldIdSet.add(acc.HeadOfSecurity__c);
                }
            
            conList = [SELECT Id, Name, Account.Name, Account.Type, Email, Phone, Title,
            IT_Executive__c, Head_of_Security_Account__c, Service_Owner__c, Cloud_Architect__c, Head_of_Networking_CTO_Account__c, Budget_Authority__c, Procurement_Contact__c
                                            FROM Contact WHERE AccountId = :accId AND Id IN: accFieldIdSet LIMIT 100];
        //conList =  [SELECT Id,Name,AccountId,Account.Name,Title,
        //IT_Executive__c, Head_of_Security_Account__c, Head_of_Networking_CTO_Account__c, Budget_Authority__c, Procurement_Contact__c, Cloud_Architect__c, Service_Owner__c,Email,Phone from Contact where AccountId = :accId];   
            }
        }
        return conList;

    }

    @AuraEnabled
    public static List<contact> displayDataCMTConRecord(String accId,String dataRec){
        List<Contact> dataContactsList = (List<Contact>) JSON.deserialize(dataRec, List<Contact>.class);
        set<Id> dataId = new set<Id>();
        for(Contact dataCon: dataContactsList){
            dataId.add(dataCon.id);
        }
        List<contact> conList = new List<contact>();
        if(accId != null){
            List<Account> accList=[Select HeadOfIT__c, Head_of_Architecture__c , HeadOfNetworking__c, HeadOfSecurity__c from Account 
            where id=:accId ];
            if(!accList.isEmpty()){
                Account acc = accList[0];
                Set<Id> accFieldIdSet=new Set<Id>();
            
                if(acc.HeadOfIT__c !=null){
                    accFieldIdSet.add(acc.HeadOfIT__c);
                }
                if(acc.Head_of_Architecture__c !=null){
                    accFieldIdSet.add(acc.Head_of_Architecture__c);
                }
                if(acc.HeadOfNetworking__c != null){
                    accFieldIdSet.add(acc.HeadOfNetworking__c);
                }
                if(acc.HeadOfSecurity__c!=null){
                    accFieldIdSet.add(acc.HeadOfSecurity__c);
                }
            
            conList = [SELECT Id, Name, Account.Name, Account.Type, Email, Phone, Title,
            IT_Executive__c, Head_of_Security_Account__c, Service_Owner__c, Cloud_Architect__c, Head_of_Networking_CTO_Account__c, Budget_Authority__c, Procurement_Contact__c
                                            FROM Contact WHERE (AccountId = :accId AND Id IN: accFieldIdSet) AND id NOT IN :dataId LIMIT 100];
        	}
        }
        return conList;
    }
    
    @AuraEnabled 
    public static List<user> displayUserRecord(String usrId){
        List<user> usr =  new List<user>();
        usr = [SELECT Id,Name,AccountId,Account.Name,GCS_Role__c,UserRoleId,UserRole.Name,Email,Phone from User where id = :usrId];
        return usr;
    }

    @AuraEnabled
    public static String fetchPushData(String usrId){
        User u = [Select Id, Name,UserRoleId, UserRole.Name,Account.Name,GCS_Role__c,Email,Phone From User Where Id=:usrId];
        String returnWrapper = '';
        if(u.UserRoleId!=null){
            returnWrapper = '{"Id":"'+u.Id+'","AccountName__c":"'+u.Account.Name+'","Title":"'+u.GCS_Role__c+'","Email":"'+u.Email+'","Phone":"'+u.Phone+'","Name":"'+u.Name+'","Department":"'+u.UserRole.Name+'","attendeeType":false,"Participation":"In Person"}';
        }else{
            returnWrapper = '{"Id":"'+u.Id+'","AccountName__c":"'+u.Account.Name+'","Title":"'+u.GCS_Role__c+'","Email":"'+u.Email+'","Phone":"'+u.Phone+'","Name":"'+u.Name+'","Department":"","attendeeType":false,"Participation":"In Person"}';
        }
        String target = 'null';
        String replacement = '';
        string newWrapper = returnWrapper.replace(target, replacement);
        return newWrapper;
    }

    @AuraEnabled
    public static List<String> fetchInternalAttendeeData(String sciId){
        try{
            List<SCI_Zscaler_Attendee__c> existingExternalAttendees = [SELECT Id, Name,Attendee_Name__c,Account_Name__c,Attendee_Name__r.GCS_Role__c,Attendee_Name__r.Email,Attendee_Name__r.Phone,Attendee_Name__r.Name,Attendee_Name__r.UserRole.Name,Participation__c,Significant_Customer_Interaction__c
                                FROM SCI_Zscaler_Attendee__c Where Significant_Customer_Interaction__c=:sciId LIMIT 10000];
            List<String> existingExternalAttendeesData = new List<String>();
            for(SCI_Zscaler_Attendee__c u : existingExternalAttendees){
                String returnWrapper='';
                returnWrapper = '{"Id":"'+u.Attendee_Name__c+'","AccountName__c":"'+u.Account_Name__c+'","Title":"'+u.Attendee_Name__r.GCS_Role__c+'","Email":"'+u.Attendee_Name__r.Email+'","Phone":"'+u.Attendee_Name__r.Phone+'","Name":"'+u.Attendee_Name__r.Name+'","Department":"'+u.Attendee_Name__r.UserRole.Name+'","attendeeType":false,"Participation":"'+u.Participation__c+'","parentRecordId":"'+u.Significant_Customer_Interaction__c+'"}';
                String target = 'null';
                String replacement = '';
                string newWrapper = returnWrapper.replace(target, replacement);
                existingExternalAttendeesData.add(newWrapper);
            }


            if(!existingExternalAttendeesData.isEmpty()){
                return existingExternalAttendeesData;
            }else{
                return null;
            }
        }catch(Exception ee){
            //System.debug('error--->'+ee.getMessage()+' at line '+ee.getLineNumber());
        }
        return null;
        
    }

    @AuraEnabled
    public static Contact fetchContactData(String conId){
        Contact newExternalAttendee = [SELECT Id, Name, AccountId, Account.Name,AccountName__c, Account.Type, Email, Phone, Title,
                    IT_Executive__c, Head_of_Security_Account__c, Head_of_Networking_CTO_Account__c, Budget_Authority__c, Procurement_Contact__c, Cloud_Architect__c, Service_Owner__c
                                             FROM Contact Where Id=:conId LIMIT 1];
        if(newExternalAttendee!=null){
            return newExternalAttendee;
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static List<String> fetchExistingExternalAttendees(String sciId){
        List<SCI_External_Attendee__c> existingExternalAttendees = [SELECT Id, Name, Attendee_Name__c,Attendee_Name__r.Name,Attendee_Name__r.Email,Attendee_Name__r.Phone,Account__c,External_Attendee_Title__c,
                                                            Type__c,Account_Type__c,Significant_Customer_Interaction__c,Significant_Customer_Interaction__r.Name
                                                            FROM SCI_External_Attendee__c Where Significant_Customer_Interaction__c=:sciId LIMIT 10000];
        List<String> existingExternalAttendeesData = new List<String>();
        for(SCI_External_Attendee__c u : existingExternalAttendees){
            String returnWrapper='';
            returnWrapper = '{"Id":"'+u.Attendee_Name__c+'","AccountName__c":"'+u.Account__c+'","Title":"'+u.External_Attendee_Title__c+'","Email":"'+u.Attendee_Name__r.Email+'","Phone":"'+u.Attendee_Name__r.Phone+'","Name":"'+u.Attendee_Name__r.Name+'","parentRecordId":"'+u.Significant_Customer_Interaction__c+'","type":"'+u.Type__c+'","recId":"'+u.Id+'"}';
            String target = 'null';
            String replacement = '';
            string newWrapper = returnWrapper.replace(target, replacement);
            existingExternalAttendeesData.add(newWrapper);
        }
        

        if(!existingExternalAttendeesData.isEmpty()){
            return existingExternalAttendeesData;
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static Lead fetchLeadData(String leadId){
        Lead newExternalAttendee = [SELECT Id, Name, Email, Phone, Title FROM Lead Where Id=:leadId LIMIT 1];
        if(newExternalAttendee!=null){
            return newExternalAttendee;
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static List<SCI_Zscaler_Attendee__c> insertZscalarAttendees(String result,String sciRecId){
        
        try{
            List<SCI_Zscaler_Attendee__c> existingAttendeesList = [Select Id,Attendee_Name__c,Significant_Customer_Interaction__c From SCI_Zscaler_Attendee__c Where Significant_Customer_Interaction__c=:sciRecId];
            Set<Id> attendeeIds = new Set<Id>();
            if(!existingAttendeesList.isEmpty()){
                for(SCI_Zscaler_Attendee__c exAtt : existingAttendeesList){
                    attendeeIds.add(exAtt.Attendee_Name__c);
                }
            }
            
            List<userWrapper> userAttendees =  (List<userWrapper>)JSON.deserialize(result, List<userWrapper>.class);
            List<SCI_Zscaler_Attendee__c> attendeesToInsert = new List<SCI_Zscaler_Attendee__c>();
            Set<Id> removeAttendeeIdSet = attendeeIds;
            for( userWrapper userAttandeeItem : userAttendees){
                SCI_Zscaler_Attendee__c attendee = new SCI_Zscaler_Attendee__c();
                if(!attendeeIds.isEmpty()){
                    if(userAttandeeItem.recId != null && String.isNotBlank(userAttandeeItem.recId)){
                        
                        attendee.Id = String.valueOf(userAttandeeItem.recId);
                        attendee.Attendee_Name__c = userAttandeeItem.Id;
                        attendee.Organizer__c = userAttandeeItem.attendeeType;
                        attendee.Participation__c = userAttandeeItem.participation;
                        if(attendeeIds.contains(userAttandeeItem.Id)){
                            
                            removeAttendeeIdSet.remove(userAttandeeItem.Id);
                        }
                    }else{
                        if(!attendeeIds.contains(userAttandeeItem.Id)){
                            attendee.Attendee_Name__c = userAttandeeItem.Id;
                            attendee.Organizer__c = userAttandeeItem.attendeeType;
                            attendee.Participation__c = userAttandeeItem.participation;
                            attendee.Significant_Customer_Interaction__c = sciRecId;
                        }
                        if(attendeeIds.contains(userAttandeeItem.Id)){
                            removeAttendeeIdSet.remove(userAttandeeItem.Id);
                        }
                    }
                }else{
                    if(userAttandeeItem.recId != null && String.isNotBlank(userAttandeeItem.recId)){
                        attendee.Id = String.valueOf(userAttandeeItem.recId);
                        attendee.Attendee_Name__c = userAttandeeItem.Id;
                        attendee.Organizer__c = userAttandeeItem.attendeeType;
                        attendee.Participation__c = userAttandeeItem.participation;
                    }else{
                        attendee.Attendee_Name__c = userAttandeeItem.Id;
                        attendee.Organizer__c = userAttandeeItem.attendeeType;
                        attendee.Participation__c = userAttandeeItem.participation;
                        attendee.Significant_Customer_Interaction__c = sciRecId;
                    }
                }
                if(attendee!=new SCI_Zscaler_Attendee__c()){
                    attendeesToInsert.add(attendee);
                }
            }
            
            if(!removeAttendeeIdSet.isEmpty()){
                List<SCI_Zscaler_Attendee__c> deleteAttendees = [Select Id,Attendee_Name__c from SCI_Zscaler_Attendee__c where Attendee_Name__c IN: removeAttendeeIdSet AND Significant_Customer_Interaction__c=:sciRecId];
               
                delete deleteAttendees;
            }
            if(attendeesToInsert.isEmpty()){
                return null;
            }
           
            upsert attendeesToInsert;
            
            return attendeesToInsert;
        }catch(Exception ee){
            
        }
        return null;
    }

    @AuraEnabled
    public static List<SCI_External_Attendee__c> insertExternalAttendees(String result,String sciRecId){
        try{
            List<externalWrapper> userAttendees =  (List<externalWrapper>)JSON.deserialize(result, List<externalWrapper>.class);
            List<SCI_External_Attendee__c> attendeesToInsert = new List<SCI_External_Attendee__c>();
            for( externalWrapper userAttandeeItem : userAttendees){
                SCI_External_Attendee__c attendee = new SCI_External_Attendee__c();
                if(userAttandeeItem.recId!=null && String.isNotBlank(userAttandeeItem.recId)){
                    attendee.Id = userAttandeeItem.recId;
                }else{
                    attendee.Significant_Customer_Interaction__c = userAttandeeItem.parentRecordId;
                }
                Id myId = Id.valueOf(userAttandeeItem.Id);
                String sObjName = myId.getSObjectType().getDescribe().getName();
                if(sObjName == 'Contact'){
                    attendee.Attendee_Name__c = userAttandeeItem.Id;
                }else{
                    attendee.Attendee_user__c = userAttandeeItem.Id;
                }
                attendee.Type__c = userAttandeeItem.type;
                attendeesToInsert.add(attendee);
            }
            if(!attendeesToInsert.isEmpty()){
                upsert attendeesToInsert;
                return attendeesToInsert;
            }else{
                return null;
            }
        }catch(Exception ee){
            
        }
        return null;
    }


    public class externalWrapper{
        String Id{get; set;}
        String Name{get;set;}
        String AccountId{get;set;}
        String Email{get;set;}
        String Phone{get;set;}
        String Title{get;set;}
        /*Boolean IT_Executive__c{get;set;}
        Boolean Head_of_Security_Account__c{get;set;}
        Boolean Budget_Authority__c{get;set;}
        Boolean Procurement_Contact__c{get;set;}
        Boolean Cloud_Architect__c{get;set;}
        Boolean Service_Owner__c{get;set;}*/
        String parentRecordId{get;set;}
        String type{get;set;}
        String recId { get; set; }
    }

    

    public class userWrapper{
        public String Id { get; set; }
        String Name { get; set; }
        String DepartName { get; set; }
        Boolean attendeeType { get; set; }
        String participation { get; set; }
        String parentRecordId { get; set; }
        String recId { get; set; }


    }
}