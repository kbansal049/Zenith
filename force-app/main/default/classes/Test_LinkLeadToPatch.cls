@isTest
private class Test_LinkLeadToPatch {
    
    @TestSetup static void setuprecs(){
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='AMERICAS';
        pateam.Region__c ='US West';
        pateam.Area__c ='US South West';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        
        PatchTeam__c pateam2 = new PatchTeam__c();
        pateam2.Name = 'patchteam2';
        pateam2.Theater__c='AMERICAS';
        pateam2.Region__c ='US West';
        pateam2.Area__c ='US South West';
        pateam2.Territory_Type__c ='Channel';
        insert pateam2;
        
        Lead lead=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry', ZPA_Interactive_Lead__c = true, Territory__c = pateam.Id);
        insert lead;
        
        Catch_All_Territory_List__c cl = new Catch_All_Territory_List__c();
        cl.Name = 'tst';
        cl.Record_Id__c = pateam.Id;
        insert cl;
        
        
        Task t1 =new Task();
        t1.WhoId = lead.id;
        insert t1;
        
    }
    
    static testMethod void test() {
        
        Test.startTest();
        List<PatchTeam__c> patchT = [select id from PatchTeam__c];
        Lead leadObj = [select id,Territory__c,ZPA_Interactive_Lead__c,Qualification_Status__c,ZB2B_Interactive_Prospect__c from Lead where Company='Test'];
        
        leadObj.Territory__c = patchT[1].Id;
        leadObj.OwnerId =UserInfo.getUserId();
        leadObj.ZPA_Interactive_Lead__c = false;
        leadObj.ZB2B_Interactive_Prospect__c = true;
        leadObj.mkto2__Lead_Score__c =80;
        //leadObj.IsConverted = true;
        leadObj.ZPA_Manager__c =UserInfo.getUserId();
        leadObj.No_Employees_Users__c = '0 - 99';
        leadObj.Qualifying_SDR__c = userInfo.getUserId();
        update leadObj;
        
        delete leadObj;
        undelete leadObj;
        update leadObj;
        Test.stopTest();
    }
   
    
}