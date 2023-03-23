@isTest
public class recordDetailminiLWCControllerTest {
  @isTest
    static  void test1(){
        recordDetailminiLWCController.getSObjetFieldsFromFieldSet('Customer_Success','Account');
    }
    @isTest
    static  void test2(){
        recordDetailminiLWCController.getSObjetFieldsFromFieldSet('test','');
        recordDetailminiLWCController.getSObjetFieldsFromFieldSet('','Account');
        recordDetailminiLWCController.getSObjetFieldsFromFieldSet('test','Account');
    }
    @isTest
    static void test3(){
        Account acc = new Account(name='test');
        insert acc;
        List<String> fldList = new List<String>();
        fldList.add('Name');
        recordDetailminiLWCController.getSObjectDetails(acc.id, fldList,'Account','name','name');
    }
}