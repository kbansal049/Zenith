@isTest
public class ManageCIOControllerTest {
    
    static testmethod void test1(){
        
        Account acc= new account(Name='TestAccount1',Type='Prospect',Domain__c='zscaler.com', Additional_Organization_Domains__c='Zscaler.in',Override_CTM_Domain__c=false);
        insert acc;
        
        List<Contact> ContactList= new List<Contact>();
        Contact con= new Contact(accountid = acc.Id,lastname = 'testContact1', email='testContact1@abc.com',Contacts_that_matter__c = true,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
        ContactList.add(con);
        Contact con2= new Contact(accountid = acc.Id,lastname = 'testContact2', email='testContact2@zscaler.com',Contacts_that_matter__c = true,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
        ContactList.add(con2);
        Contact con3= new Contact(accountid = acc.Id,lastname = 'testContact3', email='testContact3@zscaler.in',Contacts_that_matter__c = true,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
        ContactList.add(con3);
        Contact con4= new Contact(accountid = acc.Id,lastname = 'testContact4', email='testContact1@pqr.com',Contacts_that_matter__c = true,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
        ContactList.add(con4);
        
        insert ContactList;
        
        
        Case caseRec = new Case();
        caseRec.AccountId = acc.id;
        caseRec.Subject = 'New Case for Domain verification is Created for Account:'+acc.name+' / '+acc.id + ' and for the Contact : '+ con.name + ' / ' + con.Id;
        caseRec.Description = 'Please verify the domain on contact and please add it to additional Organization domains on Account if Valid.';
        caseRec.Case_Category__c = 'Accounts';
        caseRec.Case_Sub_Category__c = 'Email Domain Verification';
        caseRec.Status = 'New';
        Insert caseRec;
        
        
        ManageCIOController.CIODetails cioDet =  ManageCIOController.getCIODetails(acc.id);
        ManageCIOController.getCIODetailsUncached(caseRec.id);
        ManageCIOController.getCIODetailsUncached('');
        
        //Create Case
        for(ManageCIOController.ContactDetail cd : cioDet.conList){
            if(cd.con.id == con4.id){
                cd.Send_Exec_Insights = 'Send delayed';
            }else{
                cd.Send_Exec_Insights = 'Send delayed';
            }
        }
        ManageCIOController.CustomResult csr = ManageCIOController.saveContactRecords(JSON.serialize(cioDet));
        
        
        cioDet.conList = null;
        ManageCIOController.saveContactRecords(JSON.serialize(cioDet));
        ManageCIOController.saveContactRecords('test');   
    }
    
    
    static testmethod void test2(){
        
        Account acc= new account(Name='TestAccount1',Type='Prospect',Domain__c='zscaler.com', Additional_Organization_Domains__c='Zscaler.in',Override_CTM_Domain__c=false);
        insert acc;
        
        List<Contact> ContactList= new List<Contact>();
        Contact con= new Contact(accountid = acc.Id,lastname = 'testContact1', email='testContact1@abc.com',Contacts_that_matter__c = true,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
        ContactList.add(con);
        Contact con2= new Contact(accountid = acc.Id,lastname = 'testContact2', email='testContact2@zscaler.com',Contacts_that_matter__c = true,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
        ContactList.add(con2);
        Contact con3= new Contact(accountid = acc.Id,lastname = 'testContact3', email='testContact3@zscaler.in',Contacts_that_matter__c = true,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
        ContactList.add(con3);
        Contact con4= new Contact(accountid = acc.Id,lastname = 'testContact4', email='testContact1@pqr.com',Contacts_that_matter__c = true,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
        ContactList.add(con4);
        
        insert ContactList;
        
        
        Case caseRec = new Case();
        caseRec.AccountId = acc.id;
        caseRec.Subject = 'New Case for Domain verification is Created for Account:'+acc.name+' / '+acc.id + ' and for the Contact : '+ con.name + ' / ' + con.Id;
        caseRec.Description = 'Please verify the domain on contact and please add it to additional Organization domains on Account if Valid.';
        caseRec.Case_Category__c = 'Accounts';
        caseRec.Case_Sub_Category__c = 'Email Domain Verification';
        caseRec.Status = 'New';
        Insert caseRec;
        
        
        
        ManageCIOController.getCIODetailForContactUncached(caseRec.id);
        ManageCIOController.getCIODetailForContactUncached('');
        
        ManageCIOController.CIODetail cioDet =  ManageCIOController.getCIODetailForContact(con.id);
        ManageCIOController.CIODetail cioDet1 =  ManageCIOController.getCIODetailForContact(con2.id);
        ManageCIOController.CIODetail cioDet2 =  ManageCIOController.getCIODetailForContact(con4.id);
        
        
        //Create Case
        cioDet.conDetail.Send_Exec_Insights = 'Send delayed';
        cioDet1.conDetail.Send_Exec_Insights = 'Send delayed';
        cioDet2.conDetail.Send_Exec_Insights = 'Send delayed';
        
        ManageCIOController.CustomResultContact csr = ManageCIOController.saveContactInformation(JSON.serialize(cioDet));
        ManageCIOController.CustomResultContact csr1 = ManageCIOController.saveContactInformation(JSON.serialize(cioDet1));
        
        System.debug('---csr2---'+JSON.serializePretty( cioDet2));
        
        ManageCIOController.CustomResultContact csr2 = ManageCIOController.saveContactInformation(JSON.serialize(cioDet2));
        
        
        cioDet.conDetail = null;
        ManageCIOController.saveContactInformation(JSON.serialize(cioDet));
        ManageCIOController.saveContactInformation('test');   
    }
}