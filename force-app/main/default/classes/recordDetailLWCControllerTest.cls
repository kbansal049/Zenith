@isTest
public class recordDetailLWCControllerTest {

    static testmethod void test1(){
        recordDetailLWCController.getSObjetFieldsFromFieldSet('Customer_Success','Account');
    }
    static testmethod void test2(){
        recordDetailLWCController.getSObjetFieldsFromFieldSet('test','');
        recordDetailLWCController.getSObjetFieldsFromFieldSet('','Account');
        recordDetailLWCController.getSObjetFieldsFromFieldSet('test','Account');
    }
    
    static testmethod void test3(){
        Account acc = new Account(name='test');
        insert acc;
        List<String> fldList = new List<String>();
        fldList.add('Name');
        recordDetailLWCController.getSObjectDetails(acc.id, fldList);
    }
    
    static testmethod void test4(){
        Account acc = new Account(name='test');
        insert acc;
        Account_Extension__c accExt = new Account_Extension__c();
        accExt.Account__c = acc.Id;
        List<String> fldList = new List<String>();
        fldList.add('Name');
        recordDetailLWCController.getSObjectDetailsNew(acc.id, fldList);
    }
}