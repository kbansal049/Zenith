@isTest
public class knowledgeHandlerTest{
    
    @testSetup
    static void testData(){
         try{
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId =UserInfo.getUserId();
            psa.PermissionSetId = System.Label.Knowledge_Base_Article_Owner_Access;
            insert psa;
        }catch(Exception e){}
    }
    
    static testmethod void test1(){
        knowledgeHandler.articleStatusCheck('Draft');
        knowledgeHandler.articleStatusCheck('Ready for Review');
        knowledgeHandler.articleStatusCheck('In Review');
        knowledgeHandler.articleStatusCheck('Pending Approval');
        knowledgeHandler.articleStatusCheck('Approved');
        knowledgeHandler.articleStatusCheck('Published');
        knowledgeHandler.articleStatusCheck('Test');
        knowledgeHandler.getArticleStatus(1);
        knowledgeHandler.getArticleStatus(2);
        knowledgeHandler.getArticleStatus(3);
        knowledgeHandler.getArticleStatus(4);
        knowledgeHandler.getArticleStatus(5);
        knowledgeHandler.getArticleStatus(6);
        knowledgeHandler.getArticleStatus(7);
        
        
        
        Triggers_Switch__c trg = new Triggers_Switch__c();
        trg.Name = 'Execute_Kb_Trigger';
        trg.Object_Name__c = 'KB__kav';
        trg.Execute__c = true;
        insert trg;
        
        KB__kav know = new KB__kav();
        know.RecordTypeId = Schema.SObjectType.KB__kav.getRecordTypeInfosByName().get('Problems').getRecordTypeId();
        know.Title = 'Test';
        know.UrlName = 'Test9768235466';
        insert know;
        
        know.Article_Status__c = 'Ready for Review';
        update know;
        
        
    }
    
    static testmethod void test2(){
        try{
        
        Triggers_Switch__c trg = new Triggers_Switch__c();
        trg.Name = 'Execute_Kb_Trigger';
        trg.Object_Name__c = 'KB__kav';
        trg.Execute__c = true;
        insert trg;
        
            KB__kav know = new KB__kav();
        know.RecordTypeId = Schema.SObjectType.KB__kav.getRecordTypeInfosByName().get('Problems').getRecordTypeId();
        know.Title = 'Test';
        know.UrlName = '1Test9768235466';
        know.Article_Status__c = 'Approved';
        insert know;
        }
        catch(Exception e){
            
        }
    }
}