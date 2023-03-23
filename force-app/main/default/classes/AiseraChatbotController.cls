public class AiseraChatbotController {
    /*@AuraEnabled(cacheable=true)
    public static String accessChatbot(){
        try {
            String result = '';
            system.debug('Access Chatbot called');
            String currentUserId = UserInfo.getUserId();
            User usr = [select id, Contact.Account.Aisera_Chatbot_Visible__c from User where Id=:currentUserId limit 1];
            if(usr!= null && usr.Contact.Account.Aisera_Chatbot_Visible__c){
                result = 'true';
            }else{
                result = 'false';
            }
            return result;
        } catch (Exception e) {
            system.debug(e);
            return 'false';
        }
    }*/
    
    /*@AuraEnabled(cacheable=true)
    public static String createCaseEnabled(){
        try {
            String result = '';
            String currentUserId = UserInfo.getUserId();
            Customer_Portal_Session_Id__c cs = Customer_Portal_Session_Id__c.getOrgDefaults();
            User usr = [select id, Contact.Account.Disable_Create_Case__c from User where Id=:currentUserId limit 1];
            if(usr!= null && usr.Contact.Account.Disable_Create_Case__c){
                result = cs.Session_Id__c;
            }else{
                result = 'No Session Id';
            }
            return result;
        } catch (Exception e) {
            system.debug(e);
            return 'false';
        }
    }*/

    
    @AuraEnabled
    public static userDetails getUserDetails(){
        String currentUserId = UserInfo.getUserId(); 
        User usr = [select id, Email,Email__c, Name, ContactId, AccountId from User where Id=:currentUserId limit 1];
       // Customer_Portal_Session_Id__c cs = Customer_Portal_Session_Id__c.getOrgDefaults();
       //String customSessionId=cs.Session_Id__c;
        CreateCaseController.PortalDetail portalDetails = CreateCaseController.getZscalerPortalDetails(); 
        userDetails usrDetail = new userDetails(usr.Email__c, usr.Name, usr.accountId, usr.contactId, portalDetails);
        return usrDetail;

    }

    @AuraEnabled
    public static String getUserTimezone(){
        TimeZone currentUserTZ = UserInfo.getTimeZone();
        String tz = currentUserTZ.toString();
        return tz;
    }

    public class userDetails{
        @AuraEnabled
        public String email; 
        @AuraEnabled
        public String fullName;
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String contactId;
        @AuraEnabled
        public CreateCaseController.PortalDetail portalDetails;
       

        public userDetails(String usrEmail, String name, String account, String contact, CreateCaseController.PortalDetail portalDetail){
            email = usrEmail;
            fullName = name;
            accountId = account;
            contactId = contact;
            portalDetails = portalDetail;
        }
    }

   /* @AuraEnabled(cacheable=true) 
    public static Customer_Portal_Session_Id__c getSessionCustomSettings(){
        Customer_Portal_Session_Id__c cs = Customer_Portal_Session_Id__c.getOrgDefaults();
        return cs;
    }*/
    
}