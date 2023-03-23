/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-11-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class PSAssignmentOrDelBatch implements Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('PSAssignmentOrDelBatch');
    String query = '';
    String psId = '';
    Boolean isUpsert = false;
    Boolean isDelete = false;
	public PSAssignmentOrDelBatch(String query, String psName, Boolean isUpsert, Boolean isDelete){
        this.isUpsert = isUpsert;
        this.isDelete = isDelete;

        if(this.isUpsert){
            //PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'SlackServiceUser' LIMIT 1];
            PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = :psName LIMIT 1];
            this.psId = ps.Id;

            if(String.isNotBlank(query)){
                this.query = query;
            }else{
                this.query = 'SELECT Id FROM User ORDER BY Name ASC';  
            }
        }else if(this.isDelete){
            if(String.isNotBlank(query)){
                this.query = query;
            }else{
                //this.query = 'SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSetGroupId, AssigneeId, Assignee.Name, IsActive FROM PermissionSetAssignment WHERE PermissionSet.Name = \'Slack_Standard_User\' ORDER BY Assignee.Name ASC';
                this.query = 'SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = \'Slack_Standard_User\' ORDER BY Assignee.Name ASC';  
            }
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        this.zb.callStart();
        this.query += (Test.isRunningTest() ? ' LIMIT 200' : '');
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        try{
            if(!scope.isEmpty()){
                this.zb.callExecute(scope[0]?.Id, scope.size());
                if(this.isUpsert){
                    List<PermissionSetAssignment> psAssignmentList = new List<PermissionSetAssignment>();
                    for(User u : (List<User>) scope){
                        PermissionSetAssignment psAssignment = new PermissionSetAssignment();
                        psAssignment.AssigneeId = u.Id;
                        psAssignment.PermissionSetId = this.psId;
                        psAssignmentList.add(psAssignment);
                    }
                    if(!psAssignmentList.isEmpty()){
                        List<Database.UpsertResult> upsertResultList = Database.upsert(psAssignmentList, false);
                    }
                }else if(this.isDelete){
                    List<PermissionSetAssignment> psAssignmentList = (List<PermissionSetAssignment>) scope;
                    List<Database.DeleteResult> deleteResultList = Database.delete(psAssignmentList, false);
                    List<Database.EmptyRecycleBinResult> emptyRecycleBinResultList = Database.emptyRecycleBin(psAssignmentList);
                }
            }
        }catch(Exception ex){
            System.debug('In PermissionSetAssignmentDelBatch.execute(), Exception val is: '+ex);
        }
    }
    
    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        System.debug('Successfully ran the PermissionSetAssignmentDelBatch ...!!');
    }
}