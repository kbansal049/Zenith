/**
 * CaseTAMReassignmentDateResetBatch
 * Added by : Ankit Bhatnagar
 * Description : Batch that processes the cases with passed Reassignment date, a new Reassignment date is set on these Cases.
 */
public class CaseTAMReassignmentDateResetBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CaseTAMReassignmentDateResetBatch');
    public string query;
    public CaseTAMReassignmentDateResetBatch() {
        this.query = 'SELECT id,caseNumber,status,RecordTypeId,Priority,Case_Type__c,Product_New__c,AccountId,Next_TAM_Date__c,is_Tam_Account__c,CreatedDate,OwnerId,TAM_Assignment__c,TAM_Reassignment__c FROM Case WHERE Next_TAM_Date__c= LAST_N_DAYS:2 AND Next_TAM_Date__c != YESTERDAY AND Next_TAM_Date__c != TODAY';
    }

    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Case> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        List<Case> updatedCases = new List<Case>();
        if(!scope.isEmpty()) {
            updatedCases = checkTAMReassignment(scope, null);
        }
        Database.update(updatedCases, false);
    }

    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        // execute any post-processing operations
    }

    public static List<Case> checkTAMReassignment(List<Case> newList, Map<Id, Case> oldMap){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        List<Case> caseForTAMassignment = new List<Case>();
        List<Id> listOfAccountId = new List<Id>();
        Set<Id> setOfAccountId = new Set<Id>();
        List<String> productsToExclude = new List<String>();
        if(String.isNotBlank(Label.TAM_Assignment_Exclusion_Products)){
            productsToExclude = Label.TAM_Reassignment_Excluded_Products.trim().split(';');
        }
        Map<Id, Set<Id>> mapOfAccountAndTAM = new Map<Id, Set<Id>>();
        for(Case currCase: newList){
            if(currCase.RecordTypeId == caseSupportRT /*&& currCase.is_TAM_account__c*/ && currCase.Priority != 'Low (P4)' && currCase.Priority != 'Urgent (P1)' && (currCase.Case_Type__c=='Problem' || currCase.Case_Type__c=='Question') && !productsToExclude.contains(currCase.Product_New__c)){
                listOfAccountId.add(currCase.AccountId);
            }
        }
        if(!listOfAccountId.isEmpty()){
            for(Account acc: [select id, Skip_TAM_Reassignments__c, TAM_Name_New__c, Secondary_TAM_Name__c, X3rd_TAM_Name__c from Account where Id in:listOfAccountId /*and Skip_TAM_Reassignments__c = true*/]){
                if(acc.Skip_TAM_Reassignments__c){
                    setOfAccountId.add(acc.Id);
                }
                Set<Id> setOfTAMIds = new Set<Id>();
                if(acc.TAM_Name_New__c != null){
                    setOfTAMIds.add(acc.TAM_Name_New__c);
                }
                if(acc.Secondary_TAM_Name__c != null){
                    setOfTAMIds.add(acc.Secondary_TAM_Name__c);
                }
                if(acc.X3rd_TAM_Name__c != null){
                    setOfTAMIds.add(acc.X3rd_TAM_Name__c);
                }
                if(!setOfTAMIds.isEmpty()){
                    mapOfAccountAndTAM.put(acc.Id, setOfTAMIds);
                }
            }
        }  
        for(Case currentCase : newList){
            Set<Id> setOfPresentTAMs = new Set<Id>();
            if(mapOfAccountAndTAM.containsKey(currentCase.AccountId)){
                setOfPresentTAMs = mapOfAccountAndTAM.get(currentCase.AccountId);
            }
            if((currentCase.RecordTypeId == caseSupportRT) && currentCase.is_Tam_Account__c && currentCase.Priority != 'Low (P4)' && currentCase.Priority != 'Urgent (P1)' && (currentCase.Case_Type__c=='Problem' || currentCase.Case_Type__c=='Question') && !productsToExclude.contains(currentCase.Product_New__c)){
                Integer daysAdded = 1;
                Integer numberOfDays = 0;
                DateTime nextTamDate;
                if(oldMap!=null){
                    nextTamDate = currentCase.CreatedDate;    
                }else{
                    nextTamDate = System.now();    
                }
                if(currentcase.Priority == 'High (P2)'){
                    numberOfDays = 3;
                }
                if(currentcase.Priority == 'Medium (P3)'){
                    numberOfDays = 7;
                }
                while(daysAdded <= numberOfDays){
                    nextTamDate = nextTamDate.addDays(1);
                    daysAdded += 1;
                }
                String day = nextTamDate.format('E');
                if(day == 'Sat'){
                    nextTamDate = nextTamDate.addDays(2);
                    nextTamDate = DateTime.newInstance(nextTamDate.year(), nextTamDate.month(), nextTamDate.day());
                }
                else if(day == 'Sun'){
                    nextTamDate = nextTamDate.addDays(1);
                    nextTamDate = DateTime.newInstance(nextTamDate.year(), nextTamDate.month(), nextTamDate.day());
                }
                currentCase.Next_TAM_Date__c = nextTamDate;
            }
            if(setOfPresentTAMs!= null && !setOfPresentTAMs.isEmpty() && setOfPresentTAMs.contains(currentCase.OwnerId)){
                currentCase.TAM_Assignment__c = 'Assigned To TAM';
            }
            else if(setOfPresentTAMs.isEmpty()){
                currentCase.TAM_Assignment__c = 'Not TAM Account';
            }
            else{
                currentCase.TAM_Assignment__c = 'Assigned To Support';
            }
            if(!setOfAccountId.isEmpty() && setOfAccountId.contains(currentCase.AccountId)){
                currentCase.TAM_Reassignment__c = true; 
            }
        }
        return newList;
    }
}