public class DSAT{
    public String ProjectrecordId { get; set; }
    public String ProjectAccName { get; set; }
    public String ProjectAccountName { get; set; }
    public String CaseId1 {get;set;}

    public DSAT() {
        getER();
    }
    public Case getER(){
        
        List<Case> erlst = new List<Case>();
        if(CaseId1 != '' && CaseId1 !=null){
            erlst = [Select Id, Case_Owner__c,Project__c,Project__r.Name,Contact_Name__c,CaseNumber,Survey__c,Survey__r.Name,
                      Will_you_recommend_Zscaler__c,How_can_we_make_you_happier__c,Easy_to_handle_issue__c,
                      One_thing_we_could_do_to_make_it_easy__c,Rate_your_experience__c,Your_Comments__c,Did_we_meet_your_project_timeline__c   
                      FROM Case 
                      where Id =: CaseId1
                      limit 1];
        
            if(!erlst.isEmpty()){
                	String projId = erlst[0].Project__c;
                	List<inspire1__Project__c> CurrentProj = new List<inspire1__Project__c>();
                    CurrentProj = [SELECT inspire1__Account__c, inspire1__Account__r.Name,
                                                        Primary_Customer_Contact__c,Primary_Customer_Contact__r.Name
                                                    	FROM inspire1__Project__c
                                                    	WHERE Id =: projId];
                	
                    if(!CurrentProj.isEmpty()){
                        ProjectAccName = CurrentProj[0].inspire1__Account__r.Name;
                		ProjectAccountName = CurrentProj[0].Primary_Customer_Contact__r.Name;
                    }
                   	
                	return erlst[0];
            }else{
                return null;
            }
            
            
        }
        else{
            return null;
        }
        
    }
}