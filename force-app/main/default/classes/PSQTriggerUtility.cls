public class PSQTriggerUtility {
    
    //IBA-4912 START
    //PS Questionnaire Recordtypes
    private static final Id PSQ_RT_ZIA = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get('ZIA').getRecordTypeId();
    private static final Id PSQ_RT_ZPA = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get('ZPA').getRecordTypeId();
        
    //PS Questionnaire Recordtype valid for manual creation and creation of PSQ and Project Junction
    private static final List<Id> PSQ_RECORDTYPES = new List<Id>{
        PSQ_RT_ZIA,
        PSQ_RT_ZPA    
    };

	private static final Id PROJECT_RT_DEPLOYMENT = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('Deployment_Project').getRecordTypeId();        
    //IBA-4912 END
    
    public static void updateOpportunityTeam(List<PS_Questionnaire__c>newList)
    {
        Set<Id> oppIds=new Set<Id>();
        Map<Id, Id> mapOfOppAndSE = new Map<Id, Id>();
        Map<Id,Id> mapOO=new Map<Id,Id>();
        
        for(PS_Questionnaire__c PSQ:newList)
        {
            if(PSQ.Opportunity__c!=null)
            {
                oppIds.add(PSQ.Opportunity__c);
            }                
        }
        
        for(OpportunityTeammember oppMem : [select OpportunityId,TeamMemberRole,UserId from OpportunityTeamMember where TeamMemberRole='Sales Engineer' and OpportunityId in:oppIds]){
            mapOfOppAndSE.put(oppMem.OpportunityId, oppMem.UserId);
        }
        for(Opportunity Opp:[select Id,OwnerId,Owner.Name from Opportunity where Id in :oppIds])
        {
            mapOO.put(Opp.Id,Opp.OwnerId);                     
        }
        
        
        if(!oppIds.isEmpty())
        {
            for(PS_Questionnaire__c PSQ:newList)
            {
                if(mapOfOppAndSE.containsKey(PSQ.Opportunity__c) && mapOfOppAndSE.get(PSQ.Opportunity__c) != null){
                    PSQ.Sales_Engineer__c=mapOfOppAndSE.get(PSQ.Opportunity__c);
                }
                if(mapOO.containsKey(PSQ.Opportunity__c) && mapOO.get(PSQ.Opportunity__c) != null){
                    PSQ.Opportunity_Owner__c=mapOO.get(PSQ.Opportunity__c);
                }
            }           
        }   
        
    }
    public static void updateResponsesOnPSQ(list<ps_questionnaire__c> newList)
    {
        String questionnareRecordTypeZIA = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get('ZIA').getRecordTypeId();
        String questionnareRecordTypeZPA = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get('ZPA').getRecordTypeId();
        string recordTypeName='';             
        List<String> listOfFields = new List<String>();
        for(Schema.FieldSetMember f : SObjectType.PS_Questionnaire__c.FieldSets.Update_Responses_on_PSQ.getFields()){
            listOfFields.add(f.getFieldPath());
        }
        Map<Id, PS_Questionnaire__c> mapOfOppIdAndPSQ =  new Map<Id, PS_Questionnaire__c>();
        List<Id> listOfOppIds=new List<Id>();
        for(PS_Questionnaire__c psq1 : newList){
            if(!mapOfOppIdAndPSQ.containsKey(psq1.Opportunity__c)){
                if(psq1.RecordTypeId==questionnareRecordTypeZIA)
                {
                    recordTypeName='ZPA';
                }
                else if(psq1.RecordTypeId==questionnareRecordTypeZPA)
                {
                    recordTypeName='ZIA';
                }
                mapOfOppIdAndPSQ.put(psq1.Opportunity__c, psq1);
                listOfOppIds.add(psq1.Opportunity__c);
            }
        }
        
        List<String> queryBuilder = new List<String>();
        queryBuilder.add('SELECT Opportunity__c,');
        queryBuilder.add(String.join(listOfFields, ','));
        queryBuilder.add('FROM PS_Questionnaire__c');
        queryBuilder.add('WHERE');
        queryBuilder.add('RecordType.Name=:recordTypeName and Opportunity__c in :listOfOppIds order by CreatedDate DESC limit 1');
        String query = String.join(queryBuilder, ' ');
        List<PS_Questionnaire__c> psqToUpdate = new List<PS_Questionnaire__c>();
        system.debug(query);
        
        for(PS_Questionnaire__c psq : Database.query(query)){
            if(mapOfOppIdAndPSQ.containsKey(psq.Opportunity__c)){
                PS_Questionnaire__c mainPSQ = mapOfOppIdAndPSQ.get(psq.Opportunity__c);
                Boolean toUpdate = false;
                for(String fieldAPIName : listOfFields){
                    if(mainPSQ.get(fieldAPIName) != null && psq.get(fieldAPIName)==null){
                        psq.put(fieldAPIName, mainPSQ.get(fieldAPIName));
                        toUpdate = true;
                    }
                }
                if(toUpdate){
                    psqToUpdate.add(psq);
                }
            }
        }
        if(!psqToUpdate.isEmpty())
        {
            TriggerUtility.executeUpdateResponseExecuted();
            
            database.update(psqToUpdate,False);
            
        }
        
    }
    
    //Added by Ayush Kangar as part of CR#3300 - Start
    //We are created 3 new fields and populating those via below code so that we can use it in email templates.
    public static void updateEmailFieldsCSMManagerPrimaryTam(List<PS_Questionnaire__c>newList)
    {
        Set<Id> accIds=new Set<Id>();
        for(PS_Questionnaire__c PSQ:newList)
        {
            if(PSQ.Account__c!=null)
            {
                accIds.add(PSQ.Account__c);
            }                
        }
        if(!accIds.isEmpty()){
            Map<Id, Account> accIdMap = new Map<Id, Account>([Select id,CSM_Manager_Email__c,TAM_Name_New__r.Email,Solution_Architect__r.Email,CSM_Name_New__r.Email,CSM_Name_2__r.Email,CSM_NAMEOverlay__c from Account where id in: accIds]);
            if(!accIdMap.isEmpty()){
                for (PS_Questionnaire__c PSQ : newList) {
                    If(PSQ.Account__c!=null){
                        PSQ.CSM_Manager_Email__c = accIdMap.get(PSQ.Account__c).CSM_Manager_Email__c;
                        PSQ.Primary_TAM_Email__c = accIdMap.get(PSQ.Account__c).TAM_Name_New__r.Email;
                        PSQ.Solution_Architect_Email__c = accIdMap.get(PSQ.Account__c).Solution_Architect__r.Email; 
                        PSQ.CSM_Email__c = accIdMap.get(PSQ.Account__c).CSM_Name_New__r.Email;
                        PSQ.CSM_2_Email__c = accIdMap.get(PSQ.Account__c).CSM_Name_2__r.Email;	//Added by Ayush kangar as part of CR# 4367
                        PSQ.CSM_Name__c = accIdMap.get(PSQ.Account__c).CSM_NAMEOverlay__c; 		//Added by Ayush kangar as part of CR# 4367
                    }else{
                        PSQ.CSM_Manager_Email__c = null;
                        PSQ.Primary_TAM_Email__c = null;
                        PSQ.Solution_Architect_Email__c = null;
                        PSQ.CSM_Email__c = null;
                        PSQ.CSM_2_Email__c = null;		//Added by Ayush kangar as part of CR# 4367
                        PSQ.CSM_Name__c = null; 		//Added by Ayush kangar as part of CR# 4367
                    }
                }
            }
        }      
    }
    //Added by Ayush Kangar as part of CR#3300 - End
    
    /**IBA-4912 START :
    * @Description : Create PSQ and Project Junction Records when ZIA and ZPA record are created 
    * And deployment Project records are existing on the opportunity
    * @Param : List<PS_Questionnaire__c> newPSQuestionnaires - newly created ps Questionnaires
    * @Return : void
	*/
    public void createPSQAndProjectRecords(List<PS_Questionnaire__c> psQuestionnaires) {
        
        Map<Id,List<Id>> psqIdsByOpportunityId = getPSQHavingOldRecordtypesByOpportunityId(psQuestionnaires);
        if(psqIdsByOpportunityId == null || psqIdsByOpportunityId.isEmpty()) {
            return;
        }
        
        Map<Id,List<inspire1__Project__c>> projectsByOpportunityId = getProjectsByOpportunityId(psqIdsByOpportunityId.KeySet());
        if(projectsByOpportunityId == null || projectsByOpportunityId.isEmpty()) {
            return;
        }
        InspireProjectMasterTriggerService junctionCreationService = new InspireProjectMasterTriggerService();
        junctionCreationService.insertJunctionObjectRecords(projectsByOpportunityId,psqIdsByOpportunityId);
    }
    
    private Map<Id,List<Id>> getPSQHavingOldRecordtypesByOpportunityId(List<PS_Questionnaire__c> psQuestionnaires) {
        Map<Id,List<Id>> psqIdsByOpportunityId = new Map<Id,List<Id>>();
        
        for(PS_Questionnaire__c psQuestionnaire : psQuestionnaires){
           if(!PSQ_RECORDTYPES.contains(psQuestionnaire.recordTypeId) && psQuestionnaire.Opportunity__c != null){	//Updated by Ayush as part of IBA-6048
                if(!psqIdsByOpportunityId.containsKey(psQuestionnaire.Opportunity__c)) {
                 	psqIdsByOpportunityId.put(psQuestionnaire.Opportunity__c,new List<Id>());   
                }
                psqIdsByOpportunityId.get(psQuestionnaire.Opportunity__c).add(psQuestionnaire.Id);
           }
        }
        
        return psqIdsByOpportunityId;
    }
    
    private Map<Id,List<inspire1__Project__c>> getProjectsByOpportunityId(Set<Id> opportunityIds) {
        Map<Id,List<inspire1__Project__c>> projectsByOpportunityId = new Map<Id,List<inspire1__Project__c>>();
        for(inspire1__Project__c project : [SELECT Id,Opportunity__c,
                                            		inspire1__Account__c 
                                         	FROM inspire1__Project__c 
                                         	WHERE Opportunity__c IN : opportunityIds
                                            AND recordTypeId =: PROJECT_RT_DEPLOYMENT
        	]){
                if(!projectsByOpportunityId.containsKey(project.Opportunity__c)) {
                 	projectsByOpportunityId.put(project.Opportunity__c,new List<inspire1__Project__c>());   
                }
                projectsByOpportunityId.get(project.Opportunity__c).add(project);
        }
        
        return projectsByOpportunityId;
    }
    //IBA-4912 END
}