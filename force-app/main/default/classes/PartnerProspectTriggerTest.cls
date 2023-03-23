@isTest
public class PartnerProspectTriggerTest {
    @testSetup
    public static void testData(){
        User u = [select id FROM user where profile.name = 'System Administrator' AND IsActive=True LIMIT 1];
        List<PatchTeam__c> salesTerritoryList= new List<PatchTeam__c>();
        salesTerritoryList.add(new PatchTeam__c(Name = 'Channel - Disty South', Area__c = 'AMS South',Region__c ='AMS', Account_Manager__c = u.Id, Channel_Manager__c = u.Id));
        salesTerritoryList.add(new PatchTeam__c(Name = 'Channel South LATAM', Area__c = 'LATAM',Region__c ='AMS', Account_Manager__c = u.Id, Channel_Manager__c = u.Id));
        salesTerritoryList.add(new PatchTeam__c(Name = 'Channel South LATAM', Area__c = 'India',Region__c ='APJ', Account_Manager__c = u.Id, Channel_Manager__c = u.Id));
        insert salesTerritoryList;
        List<Partner_Prospect__c> PPList = New List<Partner_Prospect__c>();
        Partner_Prospect__c pp = new Partner_Prospect__c();
        pp.Source__c = 'Long Form';
        pp.Company_Name__c = 'Test Partner Account1111';
        pp.Partner_Admin_Email__c = 'abc@pqr.com';
        pp.Partner_Admin_Last_Name__c = 'lastName123';
        pp.Authorized_Signer_Email__c = 'auth@sign.com';
        pp.Authorized_Signer_First_Name__c = 'auth';
        pp.Authorized_Signer_Last_Name__c = 'sign';
        pp.Renewal_Contact_First_Name__c = 'rene';
        pp.Renewal_Contact_Last_Name__c = 'wal';
        pp.Renewal_Contact_Email__c = 'rene@wal.com';
        pp.Application_Status__c = 'Submitted';
        pp.Country__c = 'Argentina';
        pp.State_Province__c = 'North Carolina';
        pp.Program_Type__c = 'Reseller';
        pp.Partner_Type__c = 'VAR';
        pp.Partner_Tier__c = 'Alpine';
        pp.Email_Address__c = 'test@testing.com'; 
        pp.Primary_Partner_Contact_Email__c = 'Primary_Partner_Contact_Email__c@test.com';
        pp.Primary_Partner_Contact_Last_Name__c = 'Not Null';
        pp.Last_Name__c = 'not a null';
        PPList.add(pp);
        Partner_Prospect__c pp2 = new Partner_Prospect__c();
        pp2.Source__c = 'Long Form';
        pp2.Company_Name__c = 'Test Partner Account33333';
        pp2.Renewal_Contact_Email__c = 'abc@pq1r.com';
        pp2.Renewal_Contact_Last_Name__c = 'lastName1234';
        pp2.Application_Status__c = 'Submitted';
        pp2.Country__c = 'United States';
        pp2.State_Province__c = 'North Carolina';
        pp2.Program_Type__c = 'Reseller';
        pp2.Partner_Type__c = 'VAR';
        pp2.Partner_Tier__c = 'Alpine';
        pp2.Email_Address__c = 'test@testing.com';
        PPList.add(pp2);
        insert PPList;
    }
    @isTest
    static void test(){
        Partner_Prospect__c ppTest = [Select ID,Partner_On_Boarding_Status__c, Partner_Type__c from Partner_Prospect__c where Company_Name__c = 'Test Partner Account1111' Limit 1];
        System.debug('ppTest-->'+ ppTest);
        ppTest.Application_Status__c = 'Approved';
        update ppTest;
        try {
            ppTest.Approval_Status__c = 'D-RAM Approval Completed';
            update ppTest;
            //ppTest.Sell_To_Territory__c = 'Sell to terittory Test';
        } catch (Exception e) {
            system.debug('Testing validation');
        }
        try {
            ppTest.Partner_Level__c = 'Tier 1';
            update ppTest;
        } catch (Exception e) {
            system.debug('Testing validation');
        }
        ppTest.Sell_To_Territory__c = 'Sell to terittory Test';
        ppTest.Terms_and_Conditions_Agreed__c = True;
        update ppTest;

        Partner_Prospect__c ppRecallRec = [Select ID,Partner_Tier__c from Partner_Prospect__c where Company_Name__c = 'Test Partner Account33333' Limit 1];
        ppRecallRec.Partner_Tier__c = 'Zenith';
        PatchTeam__c STRec = [SELECT Id FROM PatchTeam__c WHERE Region__c = 'APJ' LIMIT 1];
        ppRecallRec.Sales_Territory__c = STRec.Id;
        update ppRecallRec;

        PartnerOnboardingUtility.insertIntegrationLog(new List<Contact> {new contact(LastName='Test For Insert Log')}, 'process_Name');
    }
    
}