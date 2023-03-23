public  class EmailComponentController {
     
    public Id accountId {get;set;}
    public Boolean lingeringC {get;set;}
    public Boolean closedCases {get;set;} //Added by Anup : CR#505
    public Integer caseLimit {get;set;} // Added by Anup : CR#505
    public List<Case> getcases(){
        String rtId =  Schema.sObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        List<Case> caselst;
        DateTime rightNow = System.now();
        rightNow = rightNow.addDays(-14);
        if(lingeringC)  {
            caselst = [SELECT CreatedDate,Subject,Type__c,Account.Name,Owner.Name,CaseNumber,Case_Type__c FROM Case WHERE RecordtypeId = :rtId AND Accountid =: accountId and (not Status like 'Closed%') and createdDate <= :rightNow ];
        }
        else if(closedCases){
            //Added by Anup : CR#505 - Start
            rightNow = rightNow.addDays(7);
            if(caseLimit!= null && caseLimit > 0){
                caselst = [SELECT CreatedDate,Subject,Type__c,Account.Name,Owner.Name,CaseNumber,Case_Type__c FROM Case WHERE RecordtypeId = :rtId AND Accountid =: accountId and (Status like 'Closed%') and ClosedDate >= :rightNow AND Case_Type__c IN (:Label.Case_Type_Problem, :Label.Case_Type_Question) order by ClosedDate DESC limit :caseLimit];//modified by Swathi : CR#951     
            }else{
                caselst = [SELECT CreatedDate,Subject,Type__c,Account.Name,Owner.Name,CaseNumber,Case_Type__c FROM Case WHERE RecordtypeId = :rtId AND Accountid =: accountId and (Status like 'Closed%') and ClosedDate >= :rightNow AND Case_Type__c IN (:Label.Case_Type_Problem, :Label.Case_Type_Question) order by ClosedDate DESC limit 100];//modified by Swathi : CR#951 
            }
            //Added by Anup : CR#505 - End
        }
        else {
            caselst = [SELECT CreatedDate,Subject,Type__c,Account.Name,Owner.Name,CaseNumber,Case_Type__c FROM Case WHERE RecordtypeId = :rtId AND Accountid =: accountId and (not Status like 'Closed%') and createdDate >= :rightNow ];
        }
        return caselst;
        
    }
    
    //CR# 486
    public Integer plannerProjectsLimit {get;set;}
    public List<inspire1__Project__c> getplannerProjects(){
        List<inspire1__Project__c> prList;
        if(accountId == null){
            return new List<inspire1__Project__c>();
        }
        if(plannerProjectsLimit != null && plannerProjectsLimit > 0){
            prList = [Select Id,Name,Project_ID__c,Project_Type__c,inspire1__Project_Status__c,inspire1__Complete__c,Management_Notes__c,createddate from inspire1__Project__c where inspire1__Account__c = :accountId order by createddate LIMIT :plannerProjectsLimit];
        }else{
            prList = [Select Id,Name,Project_ID__c,Project_Type__c,inspire1__Project_Status__c,inspire1__Complete__c,Management_Notes__c,createddate from inspire1__Project__c where inspire1__Account__c = :accountId order by createddate LIMIT 100];
        }
        return prList;
    }
    
}