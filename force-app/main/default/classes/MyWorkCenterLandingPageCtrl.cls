public class MyWorkCenterLandingPageCtrl {
    
    @AuraEnabled
    public static List<ResultWrapper> getMyWorkCenterRecord(Id loggedInUserId){
        Set<Id> loggedInUserIdSet = new Set<Id>();
        List<ResultWrapper> resultWrapperList = new List<ResultWrapper>();
        List<My_WorkCenter__c> myWorkCenterList = [SELECT Id,Name,User_Lookup__c,Manager__c 
                                                   FROM My_WorkCenter__c
                                                   WHERE User_Lookup__c = : loggedInUserId LIMIT 1];
        if(myWorkCenterList.isEmpty()){
            loggedInUserIdSet.add(loggedInUserId);
            
            resultWrapperList = createMyWorkCenterRecord(loggedInUserIdSet);
        }else {
            ResultWrapper resultWarpperObj = new ResultWrapper();
            resultWarpperObj.isSuccess = TRUE;
            resultWarpperObj.recordId = myWorkCenterList[0].Id;
            
            resultWrapperList.add(resultWarpperObj);
        }
        System.debug('resultWrapperList : ' + resultWrapperList);
        return  resultWrapperList;
    }
    
    @AuraEnabled
    public static List<My_WorkCenter__c> getTeamWorkCenterRecords(Id loggedInUserId){
        return  [SELECT Id,Name,User_Lookup__c,Manager__c 
                 FROM My_WorkCenter__c
                 WHERE Manager__c = : loggedInUserId LIMIT 50000];
    }
    
    @AuraEnabled
    public static Boolean isLoggedInUserAManager(Id loggedInUserId){
        Boolean isManager = FALSE;
        List<AggregateResult> groupedResultList = [SELECT Count(Id)total 
                                                   FROM My_WorkCenter__c
                                                   WHERE Manager__c = : loggedInUserId];
        if(!groupedResultList.isEmpty()){
            isManager = (Integer)groupedResultList[0].get('total') > 0 ? TRUE : FALSE;
        }
        
        return isManager;
    }
    
    public static Map<Id,User> getUserRecordDetails(Set<Id> loggedInUserIdSet){
        return new Map<Id,User>([SELECT Id,Name,Profile.UserLicense.Name,
                                 ManagerId,Manager.Name
                                 FROM User 
                                 WHERE Id IN : loggedInUserIdSet]);
    }
    
    public static List<ResultWrapper> createMyWorkCenterRecord(Set<Id> loggedInUserIdSet){
        List<ResultWrapper> resultWrapperList = new List<ResultWrapper>();
        List<My_WorkCenter__c> myWorkCenterList = new List<My_WorkCenter__c>();
        Map<Id,User> userDetailMap = getUserRecordDetails(loggedInUserIdSet);
        for(User usrRecord : userDetailMap.values()){
            if(!usrRecord.Name.contains('integration') &&
               usrRecord.Profile.UserLicense.Name == 'Salesforce'){
                   My_WorkCenter__c myWorkCenterObj = new My_WorkCenter__c();
                   myWorkCenterObj.Name = usrRecord.Name;
                   myWorkCenterObj.Manager__c = usrRecord.ManagerId;
                   myWorkCenterObj.OwnerId = usrRecord.Id;
                   myWorkCenterObj.User_Lookup__c = usrRecord.Id;
                   
                   myWorkCenterList.add(myWorkCenterObj);
               }
        }
        
        List<Database.SaveResult> myWorkCenterInsertResultList = Database.insert(myWorkCenterList, FALSE);
        
        for (Database.SaveResult srRecord : myWorkCenterInsertResultList) {
            if (srRecord.isSuccess()) {
                System.debug('Successfully inserted record ID: ' + srRecord.getId());
                ResultWrapper resultWarpperObj = new ResultWrapper();
                resultWarpperObj.isSuccess = TRUE;
                resultWarpperObj.recordId = srRecord.getId();
                
                resultWrapperList.add(resultWarpperObj);                
            } else {
                for(Database.Error objErr : srRecord.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                    System.debug('Oject field which are affected by the error:' 
                                 + objErr.getFields());
                    ResultWrapper resultWarpperObj = new ResultWrapper();
                    resultWarpperObj.isSuccess = FALSE;
                    resultWarpperObj.errorMessage = objErr.getStatusCode() + ': ' + objErr.getMessage() +
                        ' Object field which are affected by the error:' + objErr.getFields();
                    
                    resultWrapperList.add(resultWarpperObj);
                }
            }
        }
        return resultWrapperList;        
    }
    
    public class ResultWrapper{
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public Id recordId;
    }
}