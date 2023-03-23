public class SelectSCITypeCtrl {
    
    
    @AuraEnabled
    public static List<RecordType> fetchRecordTypeNameDescription(){
        return [SELECT Id,Name,Description, 
                DeveloperName, IsActive 
                FROM RecordType 
                WHERE SobjectType = 'Significant_Customer_Interaction__c' AND 
                IsActive = TRUE AND 
                Name != 'Master'];
    }
    
    @AuraEnabled
    public static Significant_Customer_Interaction__c fatchRecordTypeId(String sciId, String recTypeId){
            Significant_Customer_Interaction__c sci = [SELECT Id,RecordTypeId from Significant_Customer_Interaction__c where Id=:sciId ];
            sci.RecordTypeId = recTypeId;
            update sci;
            return sci;
    }
    
    @AuraEnabled
    public static List<String> fetchInternalAttendee(String sciId){
        if(String.isNotBlank(sciId)){
            id sciNewId = sciId;
            List<SCI_Zscaler_Attendee__c> sciList = new List<SCI_Zscaler_Attendee__c>();
            List<string> returnSciList = new List<string>();
            sciList = [SELECT Attendee_Department__c, Organizer__c, Participation__c,Attendee_Name__c, Attendee_Name__r.Name,Attendee_Name__r.Account.Name,Attendee_Name__r.GCS_Role__c,Attendee_Name__r.Email,Attendee_Name__r.Phone,Attendee_Name__r.UserRole.Name,Significant_Customer_Interaction__c
                        FROM SCI_Zscaler_Attendee__c 
                        WHERE Significant_Customer_Interaction__c =:sciNewId];
            if(!sciList.isEmpty()){
                for(SCI_Zscaler_Attendee__c sciData: sciList){
                    String currentSci = '{"Id":"'+sciData.Attendee_Name__c+'","AccountName__c":"'+sciData.Attendee_Name__r.Account.Name+'","Title":"'+sciData.Attendee_Name__r.GCS_Role__c+'","Email":"'+sciData.Attendee_Name__r.Email+'","Phone":"'+sciData.Attendee_Name__r.Phone+'","Name":"'+sciData.Attendee_Name__r.Name+'","Department":"'+sciData.Attendee_Name__r.UserRole.Name+'","attendeeType":false,"Participation":"'+sciData.Participation__c+'","parentRecordId":"'+sciData.Significant_Customer_Interaction__c+'","recId":"'+sciData.Id+'"}';
                    String target = 'null';
                    String replacement = '';
                    string newSci = currentSci.replace(target, replacement);
                    returnSciList.add(newSci);
                }
                return returnSciList;
            }else{
                return null;
            }
        }else{
            return null;
        }
        
    }
    
    @AuraEnabled
    public static void deleteSciOnCancel(id recId){
        Significant_Customer_Interaction__c sciRecord = [Select id,Name from Significant_Customer_Interaction__c where id = :recId];
        delete sciRecord;
    }
    @AuraEnabled
    public static List<User> suggestedAttendees(string accID,List<String> userIds){       
       	if(String.isNotBlank(accID)){
            List<Account> accList = [Select Id,sales_territory__c FROM Account WHERE Id =: accID and sales_territory__c!=null Limit 1];
             String patchTeamId = '';
             if(!accList.isEmpty()){
                patchTeamId = accList[0].sales_territory__c;
             }
             if(String.isNotBlank(patchTeamId)){
                List<User> userList = [SELECT Id, Name, Department 
                                FROM User 
                            WHERE Id IN (SELECT User__c 
                                FROM PatchTeamMember__c 
                            WHERE PatchTeam__c = :patchTeamId)
                            AND Id NOT IN :userIds];
                if(!userList.isEmpty()){
                    return userList;
                }else{
                    return null;
                }
             }else{
                return null;
             }
        }else{
            return null;
        }
    }
        
    
    
    @AuraEnabled
    public static List<Significant_Customer_Interaction__c> fetchSignificantCustomer(date currentDate, String accId){
            date startDate,endDate;
            id userInfo = UserInfo.getUserId();
            startDate = currentDate.addDays(-1);
            endDate = currentDate.addDays(1);
            List<Significant_Customer_Interaction__c> sciList = [select id,name,internal_attendee__c,Record_Type__c,RecordTypeId, Date__c,Meeting_Notes__c,Meeting_Location__c,Method_of_Interaction__c,Organizer__c,orgAttendeeExist__c,orgAttendeeTrueFalse__c ,Opportunity_Name__c, Account_Name__c, Lead__c, Deal_Reg__c, Campaign__c, Primary_Topic_Covered__c, Interaction_With__c,(SELECT Id, Attendee_Name__c, Attendee_Name__r.Name, Organizer__c FROM SCI_Zscaler_Attendee__r WHERE Attendee_Name__c = :userInfo OR Organizer__c = true)from Significant_Customer_Interaction__c WHERE Date__c >= :startDate AND Date__c <= :endDate AND Account_Name__c!=null AND Account_Name__c=:accId];
            for(Significant_Customer_Interaction__c sci: sciList){
                sci.orgAttendeeExist__c = 'No';
                for (SCI_Zscaler_Attendee__c internalAttendee : sci.SCI_Zscaler_Attendee__r){
                    sci.orgAttendeeExist__c = 'No';
                    if(internalAttendee.Organizer__c == true){
                        sci.Organizer__c = internalAttendee.Attendee_Name__r.Name;
                        sci.internal_attendee__c = internalAttendee.Attendee_Name__r.id;
                    }
                    if (userInfo == internalAttendee.Attendee_Name__c){
                        sci.orgAttendeeTrueFalse__c = true;
                        sci.orgAttendeeExist__c = 'Yes';
                    }
                }
            }
            
            
            return sciList;    
    }

    @AuraEnabled
    public static List<String> addLoginUser(String sciId){
        try{
            List<SCI_Zscaler_Attendee__c> existingAttendeesList = [Select Id,Attendee_Name__c,Significant_Customer_Interaction__c From SCI_Zscaler_Attendee__c Where Significant_Customer_Interaction__c=:sciId];
            
            
            Set<Id> attendeeIds = new Set<Id>();
            if(!existingAttendeesList.isEmpty()){
                for(SCI_Zscaler_Attendee__c exAtt : existingAttendeesList){
                    attendeeIds.add(exAtt.Attendee_Name__c);
                }
            }
            
            String returnWrapper = EnterSCIDetailsCtrl.fetchPushData(String.valueof(UserInfo.getUserId()));
            
            
            List<String> sciExisting = new List<String>();
            if(String.isNotBlank(returnWrapper) && String.isNotBlank(sciId)){
                EnterSCIDetailsCtrl.userWrapper userAttendees =  (EnterSCIDetailsCtrl.userWrapper)JSON.deserialize(returnWrapper, EnterSCIDetailsCtrl.userWrapper.class);
               
                
                if(!attendeeIds.isEmpty()){
                    if(!attendeeIds.contains(userAttendees.Id)){
                        sciExisting = EnterSCIDetailsCtrl.fetchInternalAttendeeData(sciId);
                        sciExisting.add(returnWrapper);
                    }
                }else{
                    sciExisting.add(returnWrapper);
                }
                
                List<SCI_Zscaler_Attendee__c> zList = new List<SCI_Zscaler_Attendee__c>();
                if(!sciExisting.isEmpty()){
                    zList = EnterSCIDetailsCtrl.insertZscalarAttendees('['+String.join(sciExisting,',')+']',sciId);
                }
                
               
                
                if(!zList.isEmpty()){
                    List<String> finalData = fetchInternalAttendee(sciId);
                    
                    return finalData;
                }else{
                    return null;
                }
            }else{
                return null;
            }
        }catch(Exception ee){
            //System.debug('error--->'+ee.getMessage()+' at line '+ee.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled 
    public static Significant_Customer_Interaction__c submitSCIAction(String sciMethodOfInteraction,String typeOfInteraction,String sciDate){
        Significant_Customer_Interaction__c sciObj = new Significant_Customer_Interaction__c();
        sciObj.Date__c = date.valueOf(sciDate);
        sciObj.Method_of_Interaction__c = sciMethodOfInteraction;
        sciObj.Type_of_Interaction__c = typeOfInteraction;
        insert sciObj;
        return sciObj;
    }

}