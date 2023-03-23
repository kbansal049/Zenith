/**
* Name : KnowledgeTriggerHandler
* Description : Handler of KnowledgeTrigger 
* Test Class : KnowledgeTriggerHandlerTest
* 
*/

public with sharing class KnowledgeTriggerHandler {
    public KnowledgeTriggerHandler() {}
    
    public static void beforeInsert(List<KB__kav> newKbList){
        setValidationStatusAsDraft(newKbList);
    }
    
    public static void beforeUpdate(List<KB__kav> newKbList, Map<Id, KB__kav> oldKbMap){
        beforeUpdateMethod(newKbList, oldKbMap);
    }
    
    public static void setValidationStatusAsDraft(List<KB__kav> newKbList){
        for(KB__kav knowledge : newKbList ) {
            //Set the notice message on new Records
            setKBMessage(knowledge);
            if(knowledge.publishStatus == 'Draft') {
                knowledge.validationStatus = 'Draft';
                knowledge.Review_Article_By__c = null;
                knowledge.author__c = UserInfo.getUserId();
                knowledge.Technical_Reviewer__c = null;
                knowledge.Editorial_Reviewer__c = null;
                knowledge.Article_Publisher__c = null;
                knowledge.IsVisibleInPkb = false;
                knowledge.IsVisibleInCsp = false;
            }
            if(knowledge.push_to_draft__c) {
                pushToDraft(knowledge);
            } 
        }
    }
    
    public static void beforeUpdateMethod(List<KB__kav> newKbList, Map<Id, KB__kav> oldKbMap){
        //Map<ID, Schema.RecordTypeInfo> mapKBRTs = new Map<ID, Schema.RecordTypeInfo>(Schema.SObjectType.KB__kav.getRecordTypeInfosById());
            
        for(KB__kav knowledge : newKbList ) {
            Id userId = UserInfo.getUserId();     
            User usr=  [Select Id, ManagerId FROM User WHERE Id = :userId];
        
            //Set validation Status as draft if the Publish Status is Draft
            if(knowledge.publishStatus == 'Draft' && knowledge.publishStatus != oldKbMap.get(knowledge.id).publishStatus) {
                knowledge.validationStatus = 'Draft';
            }
            /*if(knowledge.publishStatus == 'Archived' && knowledge.publishStatus != oldKbMap.get(knowledge.id).publishStatus) {
            knowledge.validationStatus = 'Draft';
            }*/
            //Populate Author, Tech Reviewer, Editorial Reviewer and Publisher
            if(knowledge.validationStatus == 'Ready for Tech Review' && knowledge.validationStatus != oldKbMap.get(knowledge.id).validationStatus) {
                knowledge.author__c = UserInfo.getUserId();
                knowledge.Ready_For_Tech_Review_Timestamp__c = System.now();
                if(usr.ManagerId!=null){
                    knowledge.Technical_Reviewer__c=usr.ManagerId;
                }
            }
            else if((knowledge.validationStatus == 'In Tech Review' || knowledge.validationStatus =='Tech Review Rework') && knowledge.validationStatus != oldKbMap.get(knowledge.id).validationStatus) {
                knowledge.Technical_Reviewer__c = UserInfo.getUserId();  
                knowledge.In_Tech_Review_Date_and_Time__c= System.now();              
            }
            else if(knowledge.validationStatus == 'Ready For Editorial Review' && knowledge.validationStatus != oldKbMap.get(knowledge.id).validationStatus) {
                knowledge.Ready_For_Editorial_Review_Timestamp__c=System.now();         
            }
            else if(knowledge.validationStatus == 'Ready to Publish' && knowledge.validationStatus != oldKbMap.get(knowledge.id).validationStatus) {
                knowledge.Ready_To_Publish_Timestamp__c=System.now();           
            }
            else if((knowledge.validationStatus == 'In Editorial Review' || knowledge.validationStatus =='Editorial Rework') && knowledge.validationStatus != oldKbMap.get(knowledge.id).validationStatus) {
                knowledge.Editorial_Reviewer__c = UserInfo.getUserId();
                knowledge.In_Editorial_Review_Date_and_Time__c= System.now();                
            }
            else if(knowledge.validationStatus == 'Published' && knowledge.validationStatus != oldKbMap.get(knowledge.id).validationStatus) {
                knowledge.Article_Publisher__c = UserInfo.getUserId();
                if(knowledge.Review_Article_By__c == null)
                    knowledge.Review_Article_By__c = System.today().addYears(1);
                /*if(!mapKBRTs.isEmpty() && mapKBRTs.containsKey(knowledge.recordTypeId) && mapKBRTs.get(knowledge.recordTypeId).developerName == 'Technical_Guides_Internal_only') {
                knowledge.IsVisibleInPkb = false;
                knowledge.IsVisibleInCsp = false;
                }*/
            }
            if(knowledge.push_to_draft__c && knowledge.push_to_draft__c != oldKbMap.get(knowledge.id).push_to_draft__c) {
                if(knowledge.validationStatus == 'Draft Rework')
                    knowledge.addError('Knowledge Article is already in Draft Rework Stage');
                /* Commented for CR #2698 by Chetan
                 else if(knowledge.ValidationStatus == 'Ready for Tech Review' || knowledge.ValidationStatus=='Ready For Editorial Review' || knowledge.ValidationStatus=='Ready to Publish') {
                    knowledge.addError('Knowledge Article cannot be pushed to draft as it is pending for approval.');
                }*/
                else 
                    pushToDraft(knowledge);
            }
            
        }
    }
    
    public static void pushToDraft(KB__kav knowledge) {
        knowledge.validationStatus = 'Draft Rework';
        knowledge.Review_Article_By__c = null;
        //knowledge.author__c = null;
        knowledge.Technical_Reviewer__c = null;
        knowledge.Editorial_Reviewer__c = null;
        knowledge.Article_Publisher__c = null;
        knowledge.IsVisibleInPkb = false;
        knowledge.IsVisibleInCsp = false;
    }  
    
    public static void setKBMessage(KB__kav knowledge) {
        knowledge.Message__c = System.Label.KB_Record_Notice;
    }

}