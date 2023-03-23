@isTest
public class updateChannelManagersBatchTest{
    
    static testmethod void test1(){
        
        PatchTeam__c salesTrtty = new PatchTeam__c();
        salesTrtty.Channel_Manager__c = UserInfo.getUserId();
        //salesTrtty.Channel_Manager_2__c = UserInfo.getUserId();
        //salesTrtty.Channel_Manager_3__c = UserInfo.getUserId();
        //salesTrtty.Channel_Manager_4__c = UserInfo.getUserId();
        //salesTrtty.Channel_Manager_5__c = UserInfo.getUserId();
        
        insert salesTrtty;
        
        PatchTeamMember__c teamMember = new PatchTeamMember__c();
        teamMember.PatchTeam__c = salesTrtty.Id;
        teamMember.User__c = UserInfo.getUserId();
        teamMember.Role__c = 'Channel Manager';
        
        insert teamMember;
        
        List<Deal_Reg__c> lstDealReg = new List<Deal_Reg__c>();
        
        //Id recordTypeId = Schema.SObjectType.Deal_Reg__c.getRecordTypeInfosByDeveloperName().get('Submitted Deal Reg').getRecordTypeId();
        
        Deal_Reg__c dr = new Deal_Reg__c();
        //dr.RecordTypeId = recordTypeId;
        dr.End_Customer_Domain__c = 'test.com';
        dr.End_Customer_Email__c = 'example@test.com';
        dr.Source__c = 'Zscaler Website';
        dr.Sales_Territory__c = salesTrtty.Id;
        lstDealReg.add(dr);
        
        Deal_Reg__c dr1 = new Deal_Reg__c();
        //dr1.RecordTypeId = recordTypeId;
        dr1.End_Customer_Domain__c = 'test1.com';
        dr1.End_Customer_Email__c = 'example1@test.com';
        dr1.Source__c = 'Zscaler Website';
        dr1.Sales_Territory__c = salesTrtty.Id;
        lstDealReg.add(dr1);
        
        TriggerUtility.dealRegBeforeInsertExecuted();
        TriggerUtility.dealRegAfterInsertExecuted();
        insert lstDealReg;
        
        Test.StartTest();
        Database.executeBatch(new updateChannelManagersBatch('SELECT Id, Sales_Territory__c, RecordType.Name, Status__c  FROM Deal_Reg__c WHERE Sales_Territory__c != null AND Channel_Manager__c = null and Partner_Type__c !=\'Technology Partner\' '));
        Test.StopTest();
    }
    
    static testmethod void test2(){
        updateChannelManagersBatchSch m = new updateChannelManagersBatchSch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('Test', sch, m);
    }
    
}