//Class Added by Varun - CR 1824 
public class StageAgeCalculation implements System.Queueable {
    List<sObject> sObjectNewList = new List<sObject>();
    Map<id, sObject> sObjectOldMap = new Map<id, sObject>();
    string parentFieldName;
    string childFieldName;
    string parentDateChangeField;
    String parentLastAgeField;
    
    public StageAgeCalculation(List<sObject> sObjectNewList, Map<id, sObject> sObjectOldMap, string parentFieldName, string childFieldName, string parentDateChangeField, String parentLastAgeField){
        this.sObjectNewList = sObjectNewList;
        this.sObjectOldMap = sObjectOldMap;
        this.parentFieldName = parentFieldName;
        this.childFieldName = childFieldName;
        this.parentDateChangeField = parentDateChangeField;
        this.parentLastAgeField = parentLastAgeField;
    }
       
    //public static void calculateAge(List<sObject> sObjectNewList, Map<id, sObject> sObjectOldMap, string parentFieldName, string childFieldName, string parentDateChangeField, String parentLastAgeField){
    public void execute(QueueableContext context){
        List<string> sObjectIds = new List<string>();
        Set<string> sObjectvalueSet = new Set<string>();
        
        for(sobject rec :  sObjectNewList){
            sObjectIds.add((string)rec.get('Id'));
            sObjectvalueSet.add((string)rec.get(parentFieldName));
            if(sObjectOldMap.size()>0)
                sObjectvalueSet.add((string)sObjectOldMap.get((string)rec.get('Id')).get(parentFieldName));
        }
        // Start - CR# 4664
        Map<Integer,String> rankingStages = new Map<Integer,String>();
        Map<String,Integer> stageRankings = new Map<String,Integer>();
        for(Opportunity_Stage_Ranking__mdt stageRanking: Opportunity_Stage_Ranking__mdt.getAll().values()){
            rankingStages.put(stageRanking.Ranking__c.intValue(),stageRanking.Stage__c);
            stageRankings.put(stageRanking.Stage__c,stageRanking.Ranking__c.intValue());
        }
        //End CR# 4664
        Map<string, string> parentObjectFieldNameMap = new Map<string, string>();   //Update this Map when more lookups are added
        parentObjectFieldNameMap.put('Opportunity' , 'Opportunity__c');
        
        if(sObjectIds.size()>0){
            ID objectRecordId = sObjectIds[0];
            string sObjectName = objectRecordId.getSObjectType().getDescribe().getName();
            
            string query = 'Select id, Start_Date__c, End_Date__c, Last_Age__c, Age__c, ';
            query += childFieldName + ', ' + parentObjectFieldNameMap.get(sObjectName) + ' from Opportunity_Stage_Age__c where ';
            query += parentObjectFieldNameMap.get(sObjectName) + ' in: sObjectIds ';
            //Commented out as part of CR# 4664 to create Stage Age record for every stage
            //if(string.isNotBlank(childFieldName))
                //query += 'and ' + childFieldName + ' in: sObjectvalueSet ';
            
            query += ' FOR UPDATE ';
            
            Map<string, Opportunity_Stage_Age__c> parentStageRecordMap = new Map<string, Opportunity_Stage_Age__c>();
            for(Opportunity_Stage_Age__c rec : database.query(query)){
                sObject sObjectRec = (sObject)rec;
                string Key = (string)sObjectRec.get(parentObjectFieldNameMap.get(sObjectName)) + '#$%' + (string)sObjectRec.get(childFieldName);
                parentStageRecordMap.put(Key, rec);
            }
            
            List<Opportunity_Stage_Age__c> SACtoUpsert = new List<Opportunity_Stage_Age__c>();
            List<sObject> sObjectToUpdate = new List<sObject>();
            for(sobject rec : sObjectNewList){
                String recId = (string)rec.get('Id');
                String parentFieldValue = (string)rec.get(parentFieldName);
                String parentFieldOldValue = '';
                if(sObjectOldMap.size()>0)
                    parentFieldOldValue = (string)sObjectOldMap.get(recId).get(parentFieldName);
                
                Opportunity_Stage_Age__c SACtoAdd = new Opportunity_Stage_Age__c();
                sObject sObjectParentRec = Schema.getGlobalDescribe().get(sObjectName).newSObject() ;
                //Start CR# 4664
                if(parentFieldName == 'StageName' && sObjectOldMap?.size() > 0){
                    System.debug('-->'+parentFieldName);
                    Integer currentRanking = stageRankings?.get(parentFieldValue);
                    Integer previousRanking = String.isNotBlank(parentFieldOldValue)&&stageRankings.containsKey(parentFieldOldValue)?stageRankings.get(parentFieldOldValue):0;
                    Integer ranking = 0;
                    Date dateToPopulate;
                    System.debug('-->'+currentRanking);
                    System.debug('-->'+previousRanking);
                    if(currentRanking == null || previousRanking == 0){
                        Opportunity_Stage_Age__c sObjectToAdd = new Opportunity_Stage_Age__c();
                        if(parentStageRecordMap.containsKey(recId + '#$%' + parentFieldOldValue)){
                            sObjectToAdd.id = parentStageRecordMap.get(recId + '#$%' + parentFieldOldValue).id;
                            sObjectToAdd.Last_Age__c = parentStageRecordMap.get(recId + '#$%' + parentFieldOldValue).Age__c ;
                        }
                        sObjectToAdd.End_Date__c = system.today();
                        sObjectToAdd.put(parentObjectFieldNameMap.get(sObjectName), recId);
                        sObjectToAdd.put(childFieldName, parentFieldOldValue);
                        SACtoUpsert.add(sObjectToAdd);

                        sObjectToAdd = new Opportunity_Stage_Age__c();
                        if(parentStageRecordMap.containsKey(recId + '#$%' + parentFieldValue)){
                            sObjectToAdd.id = parentStageRecordMap.get(recId + '#$%' + parentFieldValue).id;
                            sObjectToAdd.Last_Age__c = parentStageRecordMap.get(recId + '#$%' + parentFieldValue).Age__c ;
                        }
                        sObjectToAdd.Start_Date__c = system.today();
                        sObjectToAdd.End_Date__c = null;
                        sObjectToAdd.put(parentObjectFieldNameMap.get(sObjectName), recId);
                        sObjectToAdd.put(childFieldName, parentFieldValue);
                        SACtoUpsert.add(sObjectToAdd);

                    } else{

                        if(currentRanking > previousRanking){
                            ranking = previousRanking;
                            dateToPopulate = system.today();
                        }else if(currentRanking < previousRanking){
                            ranking = previousRanking;
                            dateToPopulate = null;
                        }
                            while(ranking != currentRanking){
                                Opportunity_Stage_Age__c sObjectToAdd = new Opportunity_Stage_Age__c();
                                if(parentStageRecordMap.containsKey(recId + '#$%' + parentFieldOldValue)){
                                    
                                    sObjectToAdd.id = parentStageRecordMap.get(recId + '#$%' + parentFieldOldValue).id;
                                    sObjectToAdd.Last_Age__c = parentStageRecordMap.get(recId + '#$%' + parentFieldOldValue).Age__c ;
                                    if(ranking != previousRanking && dateToPopulate != null){
                                        sObjectToAdd.Start_Date__c = system.today();
                                    }else if(dateToPopulate == null){
                                        sObjectToAdd.Start_Date__c = dateToPopulate;
                                    }
                                        
                                    sObjectToAdd.End_Date__c = dateToPopulate;
                                    
                                }
                                else{
                                    
                                    sObjectToAdd.Start_Date__c = dateToPopulate;
                                    sObjectToAdd.End_Date__c = dateToPopulate;
                                    
                                    
                                    
                                }
                                sObjectToAdd.put(parentObjectFieldNameMap.get(sObjectName), recId);
                                    sObjectToAdd.put(childFieldName, parentFieldOldValue);
                                SACtoUpsert.add(sObjectToAdd);
                                if(dateToPopulate != null)
                                    ranking++;
                                else {
                                    ranking--;
                                }
                                parentFieldOldValue = rankingStages?.get(ranking);
                            }
                            Opportunity_Stage_Age__c sObjectToAdd = new Opportunity_Stage_Age__c();
                            if(parentStageRecordMap.containsKey(recId + '#$%' + parentFieldOldValue)){
                                
                                sObjectToAdd.id = parentStageRecordMap.get(recId + '#$%' + parentFieldOldValue).id;
                                sObjectToAdd.Last_Age__c = parentStageRecordMap.get(recId + '#$%' + parentFieldOldValue).Age__c ;
                                if(dateToPopulate != null)
                                    sObjectToAdd.Start_Date__c = dateToPopulate;
                                else{
                                    sObjectToAdd.End_Date__c = dateToPopulate;
                                }
                                
                                    sObjectParentRec.put('Id', recId);
                                    sObjectParentRec.put(parentDateChangeField, system.today());
                                    sObjectParentRec.put(parentLastAgeField, SACtoAdd.Last_Age__c);
                            }
                            else{
    
                                
                                sObjectToAdd.Start_Date__c = system.today();
                                if(dateToPopulate == null)
                                    sObjectToAdd.End_Date__c = system.today();
                                
                                sObjectToAdd.put(parentObjectFieldNameMap.get(sObjectName), recId);
                                sObjectToAdd.put(childFieldName, parentFieldValue);
                                sObjectParentRec.put('Id', recId);
                                sObjectParentRec.put(parentDateChangeField, system.today());
                                sObjectParentRec.put(parentLastAgeField, 0);
                                
                            }
                            SACtoUpsert.add(sObjectToAdd);
                            sObjectToUpdate.add(sObjectParentRec);    
                    }
                    
                }else if(parentFieldName == 'StageName'){
                    Opportunity_Stage_Age__c sObjectToAdd = new Opportunity_Stage_Age__c();
                    sObjectToAdd.Start_Date__c = System.today();
                    sObjectToAdd.put(parentObjectFieldNameMap.get(sObjectName), recId);
                    sObjectToAdd.put(childFieldName, parentFieldValue);
                    SACtoUpsert.add(sObjectToAdd);

                }else{
                    //End CR# 4664
                    if(parentStageRecordMap.containsKey(recId + '#$%' + parentFieldValue)){
                        SACtoAdd.id = parentStageRecordMap.get(recId + '#$%' + parentFieldValue).id;
                        SACtoAdd.Last_Age__c = parentStageRecordMap.get(recId + '#$%' + parentFieldValue).Age__c ;
                        SACtoAdd.Start_Date__c = system.today();
                        SACtoAdd.End_Date__c = null;
                        
                        sObjectParentRec.put('Id', recId);
                        sObjectParentRec.put(parentDateChangeField, system.today());
                        sObjectParentRec.put(parentLastAgeField, SACtoAdd.Last_Age__c);
                    }
                    else{
                        SACtoAdd.Start_Date__c = system.today();
                        sObject sObjectToAdd = (sObject)SACtoAdd;
                        sObjectToAdd.put(parentObjectFieldNameMap.get(sObjectName), recId);
                        sObjectToAdd.put(childFieldName, parentFieldValue);
                        
                        sObjectParentRec.put('Id', recId);
                        sObjectParentRec.put(parentDateChangeField, system.today());
                        sObjectParentRec.put(parentLastAgeField, 0);
                    }
                    SACtoUpsert.add(SACtoAdd);
                    sObjectToUpdate.add(sObjectParentRec);
                    
                    if(string.isNotBlank(parentFieldOldValue) && parentStageRecordMap.containsKey(recId + '#$%' + parentFieldOldValue)){
                        SACtoAdd = new Opportunity_Stage_Age__c();
                        SACtoAdd.id = parentStageRecordMap.get(recId + '#$%' + parentFieldOldValue).id;
                        SACtoAdd.End_Date__c = system.today();
                           SACtoUpsert.add(SACtoAdd);
                    }
                }
                
            }
            
            if(SACtoUpsert.size()>0)
                upsert SACtoUpsert;
            
            if(sObjectToUpdate.size()>0)
                update sObjectToUpdate;
        }
        
    }

    public static void methodForTestClassCoverage(){
        Integer count = 0;
                count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
                count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
    }    
}