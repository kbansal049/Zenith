/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* MyWorkCenterTriggerHandler
* @description    This is the My_WorkCenter__c Trigger handler class called synchronously from MyWorkCenterTrigger.
*				  All the methods needs to be called synchronously from the MyWorkCenterTrigger
* 				  should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-02-28
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class MyWorkCenterTriggerHandler extends TriggerHandler {
        
    public override void beforeInsert(){ 
        
    }
    
    public override void beforeUpdate(){        
        
    }
    
    public override void afterInsert(){
        
        System.debug('MyWorkCenterTriggerHandler afterInsert Is Invoked');
        System.Debug('Enter afterInsert : ' + Limits.getCpuTime());
               
        Map<Id, My_WorkCenter__c> newMyWorkCenterMap = new Map<Id,My_WorkCenter__c>();
        Map<Id, My_WorkCenter__c> oldMyWorkCenterMap = new Map<Id,My_WorkCenter__c>();
        Map<Id,Id> recordIdManagerIdMap = new Map<Id,Id>();
        for (SObject myWorkCenterRec: Trigger.new) {
            
            My_WorkCenter__c newMyWorkCenter = (My_WorkCenter__c) myWorkCenterRec;       
            
            if(newMyWorkCenter.Manager__c != NULL){
                recordIdManagerIdMap.put(newMyWorkCenter.Id,newMyWorkCenter.Manager__c);
            }
            
            newMyWorkCenterMap.put(newMyWorkCenter.Id,newMyWorkCenter);
        }
        
        if(!recordIdManagerIdMap.isEmpty()){
            manualShareEdit(recordIdManagerIdMap);
        }
		        
    }
    
    public override void afterUpdate(){
        System.debug('MyWorkCenterTriggerHandler afterUpdate Is Invoked');
        System.debug('MyWorkCenterTriggerHandler AfterUpdate SOQLs: '+Limits.getQueries()+'; DMLs: '+Limits.getDmlStatements());
        System.Debug('MyWorkCenterTriggerHandler afterUpdate CpuTime : ' + Limits.getCpuTime());
        
        ManageRecursive.timesMyWorkCenterInvoked = ManageRecursive.timesMyWorkCenterInvoked + 1;
        Map<Id,Id> recordIdManagerIdMap = new Map<Id,Id>();
        Map<Id, My_WorkCenter__c> newMyWorkCenterMap = new Map<Id,My_WorkCenter__c>();
        Map<Id, My_WorkCenter__c> oldMyWorkCenterMap = new Map<Id,My_WorkCenter__c>();
        
        for (SObject myWorkCenterRec: Trigger.new) {
            My_WorkCenter__c newMyWorkCenter = (My_WorkCenter__c) myWorkCenterRec;
            My_WorkCenter__c oldMyWorkCenter = (My_WorkCenter__c) Trigger.oldMap.get(newMyWorkCenter.Id);
            
            if(!ManageRecursive.processedMyWorkCenterIds.contains(newMyWorkCenter.Id) || qualifiedUpdate(newMyWorkCenter, oldMyWorkCenter)){
                
                newMyWorkCenterMap.put(newMyWorkCenter.Id, newMyWorkCenter);
                oldMyWorkCenterMap.put(oldMyWorkCenter.Id, oldMyWorkCenter);
                
                ManageRecursive.processedMyWorkCenterIds.add(newMyWorkCenter.Id);
                
                System.Debug('Test Recursive- No of times MyWorkCenter After Update Invoked: '+ ManageRecursive.timesMyWorkCenterInvoked);
                System.Debug('MyWorkCenterTriggerHandler: '+ ManageRecursive.timesMyWorkCenterInvoked);
                System.debug('MyWorkCenterTriggerHandler Processed Ids: ' + ManageRecursive.processedMyWorkCenterIds);
                System.debug('MyWorkCenterTriggerHandler newMyWorkCenterMap: ' + newMyWorkCenterMap);
                
                if(newMyWorkCenter.Manager__c != NULL && newMyWorkCenter.Manager__c != oldMyWorkCenter.Manager__c){
                    recordIdManagerIdMap.put(newMyWorkCenter.Id,newMyWorkCenter.Manager__c);
                }
                
            }
        }
        
        if(!recordIdManagerIdMap.isEmpty()){
            manualShareEdit(recordIdManagerIdMap);
        }
    }
    
    public override void beforeDelete(){
        
    }
    
    public override void afterDelete(){
        
    }
    
    public override void afterUndelete(){
        
    }
    
    public boolean qualifiedUpdate(My_WorkCenter__c newMyWorkCenter, My_WorkCenter__c oldMyWorkCenter){
        
        Boolean valChanged = false;
        /*
		if( newMyWorkCenter.Name != oldMyWorkCenter.Name )
		{
			valChanged = true;
		} 
		*/
        return valChanged;
        
    }
    
    public static void manualShareEdit(Map<Id,Id> recordIdManagerIdMap){
        
        List<My_WorkCenter__Share> jobShrList  = new List<My_WorkCenter__Share>();
        for(Id recordId : recordIdManagerIdMap.keySet()){
            // Create new sharing object for the custom object Job.
            My_WorkCenter__Share jobShr  = new My_WorkCenter__Share();
            
            // Set the ID of record being shared.
            jobShr.ParentId = recordId;
            
            // Set the ID of user or group being granted access.
            jobShr.UserOrGroupId = recordIdManagerIdMap.get(recordId);
            
            // Set the access level.
            jobShr.AccessLevel = 'Edit';
            
            // Set rowCause to 'manual' for manual sharing.
            // This line can be omitted as 'manual' is the default value for sharing objects.
            jobShr.RowCause = Schema.My_WorkCenter__Share.RowCause.Manual;
            
            jobShrList.add(jobShr);
        }        
        
        // Insert the sharing record and capture the save result. 
        // The false parameter allows for partial processing if multiple records passed 
        // into the operation.
        Database.SaveResult[] srList = Database.insert(jobShrList,false);
        
        for(Database.SaveResult sr : srList){
            // Process the save results.
            if(sr.isSuccess()){
                // Indicates success
                System.debug('Successfully inserted record ID: ' + sr.getId());
            }
            else {
                for(Database.Error objErr : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                    System.debug('Oject field which are affected by the error:' 
                                 + objErr.getFields());
                }
            }
        }
    }
    
}