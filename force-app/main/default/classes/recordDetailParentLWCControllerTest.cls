@isTest
public class recordDetailParentLWCControllerTest {

    static testmethod void test1(){
        test.startTest();
        recordDetailParentLWCController.getSObjetFieldsFromFieldSet('Customer_Success','Account');
        test.stopTest();
        
    }
    static testmethod void test2(){
        test.startTest();
        recordDetailParentLWCController.getSObjetFieldsFromFieldSet('test','');
        recordDetailParentLWCController.getSObjetFieldsFromFieldSet('','Account');
        recordDetailParentLWCController.getSObjetFieldsFromFieldSet('test','Account');
        test.stopTest();
    }
    
    
    static testmethod void test4(){
        Account acc = new Account(name='test');
        insert acc;
        Account_Extension__c accExt = new Account_Extension__c();
        accExt.Account__c = acc.Id;
        
        List<String> fldList = new List<String>();
        fldList.add('Name');
        List<String> exceptionFldList = new List<String>();
        exceptionFldList.add('ABC');
        test.startTest();
        SObject acc1 = recordDetailParentLWCController.getSObjectDetailsNew(acc.id, fldList);
        recordDetailParentLWCController.getSObjectDetailsNew(acc.id, exceptionFldList);
        SObject acc2 = recordDetailParentLWCController.getSObjectDetails(acc.id, fldList);
        recordDetailParentLWCController.getSObjectDetails(acc.id, exceptionFldList);
        test.stopTest();
        
        system.assert(acc1 != null);
        system.assert(acc2 != null);
    }
}