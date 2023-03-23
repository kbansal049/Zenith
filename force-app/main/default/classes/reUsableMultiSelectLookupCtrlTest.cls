@isTest
public class reUsableMultiSelectLookupCtrlTest {
 
    @isTest
    static void testData(){
       
       Account acc= new Account(Name='Test Account', Type='Industry Analyst');
       insert acc; 
       
       List<Contact> conList = new List<Contact>();
       List<Id> conIdList = new List<Id>();
       for(integer i=0; i<5; i++){
      	 Contact con = new Contact();
         con.AccountId =acc.Id;
         con.FirstName='Test'+i;
         con.LastName='Demo'+i;
         con.Title='Developer';
         conList.add(con);
       }
       insert conList;
       System.debug('contact List>>> '+conList); 
        
       for(Contact con:conList){
          conIdList.add(con.Id);
       }
       
       Security_Requests__c ciso = new Security_Requests__c(Account_Name__c=acc.Id, CISO_Name__c=conList[0].Name,CISO_Request_Type__c='Customer Policy Review', Contact_Attendee_Role__c='[{}]');
       insert ciso;
        
       Id conId = ciso.Id;
       System.debug('Contact Id>>> '+conId);
        
       reUsableMultiSelectLookupCtrl cntlAttr = new reUsableMultiSelectLookupCtrl();
       reUsableMultiSelectLookupCtrl.fetchLookUpValues('Test', 'Contact', conIdList);
       reUsableMultiSelectLookupCtrl.fetchAssignedContact(conId);
       reUsableMultiSelectLookupCtrl.saveAssignedContacts(ciso);
    }
}