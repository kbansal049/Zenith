/*──────────────────────────────────────────────────────────────────────────────────────────────────
* @description       : This AccountTriggerUpdateCls called from AccountTriggerHandler.
* @author			  : Mahesh T
*──────────────────────────────────────────────────────────────────────────────────────────────────
* Modifications Log 
* Ver   Date         			Author        Modification
* 1.0   11-03-2022   			Mahesh T      Initial Version to get Priary CTM Name on Account(CR#3775)
  2.0	09-14-2022(mm-dd-yyyy)  Mahesh T      IBA-3060
  3.0   11-29-2022              Mahesh T      IBA-4825
*──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class AccountTriggerUpdateCls {
    
    private static AccountTriggerUpdateCls instance;    
    
    public static AccountTriggerUpdateCls getInstance() {
        if (instance == NULL) {
            instance = new AccountTriggerUpdateCls();
        }
        
        return instance;
    }
      
   /* Commented as it is no longer used
    //Added for CR#3775
    public  void primaryCTMupdate(list<Account> accList){
        // System.debug('Inside PrimaryCTM');
        Set<Id> contactIds = new Set<Id>();
        List<Account> acctsList =new List<Account>();
        
        for (Account acc: accList) {
            
            if(contactIds.size()==0){
                acc.Primary_CTM_Name__c= '';
            }  
            //  System.debug('inside'+accList);
            if(acc.Head_of_Architecture__c!= null && acc.HeadOfArchitecture_Primary__c == true){
                
                contactIds.add(acc.Head_of_Architecture__c);
                acctsList.add(acc);
            }
            if(acc.HeadOfSecurity__c!= null && acc.HeadOfSecurity_Primary__c == true){
                
                contactIds.add(acc.HeadOfSecurity__c);   
                acctsList.add(acc);
            }
            if(acc.HeadOfNetworking__c!= null && acc.HeadOfNetworking_Primary__c == true){
                
                contactIds.add(acc.HeadOfNetworking__c); 
                acctsList.add(acc);                
            }
            if(acc.HeadOfIT__c!= null && acc.HeadOfIT_CIO_Primary__c == true){
                
                contactIds.add(acc.HeadOfIT__c); 
                acctsList.add(acc);
            }
        }
        if(contactIds.size()>0 ) {
            List<Contact> con = [select Name from Contact where Id in :contactIds limit 1 ];
            For(Account accts:acctsList){
                accts.Primary_CTM_Name__c= con.get(0).Name;
            }
        }
        
    }   */
    
    public  void isPartnerUpdate(List<Account> accList){
        
        for (Account acc: accList) {
          //  System.debug('acc.Type'+acc.Type);
            if( acc.IsPartner == false && (acc.Type == 'Technology Partner' || acc.Type == 'Partner' || acc.Type == 'Ex - Partner') ){
                acc.IsPartner = true;
            }       
        }  
    } 
    
    public  void populateRAMEmail(List<Account> accList, Map<Id,Account> oldAccountMap){
        Set<Id> usrId= new Set<Id>();
        for(Account acc: accList){
            usrId.add(acc.Channel_Manager__c);
        }
       Map<Id,User> userMap= new Map<Id,User>([SELECT Id, Name,Email__c FROM User where Id=:usrId ]);
        
       for (Account acc: accList) {
            System.debug('acc.Channel_Manager__c'+acc.Channel_Manager__c);
            if( (acc.Regional_Alliance_Manager_Email__c == null && acc.Channel_Manager__c != null) || (acc.Channel_Manager__c != null && acc.Channel_Manager__c != oldAccountMap.get(acc.Id).Channel_Manager__c ) ){
               System.debug('acc.Channel_Manager__c'+userMap.get(acc.Channel_Manager__c).Email__c);
                if(acc.Channel_Manager__c ==userMap.get(acc.Channel_Manager__c).Id ){
                		acc.Regional_Alliance_Manager_Email__c = userMap.get(acc.Channel_Manager__c).Email__c;
                }
            }       
        }   
    }
    
    
}