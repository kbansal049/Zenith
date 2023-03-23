/**
 * Name : TAMTaskOpportunityCmpCtrlTest
 * Description : Test Class of TAMTaskOpportunityCmp
 * Initial Author: Hitesh Sachdeva
 * Story : IBA-2844
 */

@isTest
public class TAMTaskOpportunityCmpCtrlTest {

    @isTest 
    static void test_Method() {
        List<Task> TaskList = new List<Task>();
        List<Opportunity> OppList = new List<Opportunity>();
        Account acc = new Account(Name='Test Account');
        insert acc;
        TaskList.add(new Task(WhatId = acc.id,Subject = 'PRJ#1'));
        OppList.add(new Opportunity(AccountId = acc.id,Name='Test',StageName='2 - Architecture & Alignment',CloseDate=Date.parse('11/2/2022'),X3_Why__c='Text1@zscaler.com'));
        insert TaskList;
        insert OppList;
        TAMTaskOpportunityCmpCtrl cons = new TAMTaskOpportunityCmpCtrl();
        if((!TaskList.isEmpty()) || (!OppList.isEmpty())) {
            TAMTaskOpportunityCmpCtrl.getTaskRequestData(acc.id);
            TAMTaskOpportunityCmpCtrl.getOpportunityRequestData(acc.id);
        }
        TAMTaskOpportunityCmpCtrl.getTaskRequestData('');
        TAMTaskOpportunityCmpCtrl.getOpportunityRequestData('');
    }
}