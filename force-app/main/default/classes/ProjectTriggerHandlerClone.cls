public class ProjectTriggerHandlerClone {
    
    
    public void MainEntry(System.TriggerOperation triggerEvent, Boolean IsExecuting, List<SObject> newlist, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap){
        
        List<inspire1__Project__c> lstNew = (List<inspire1__Project__c>)newlist;
        List<inspire1__Project__c> lstOld = (List<inspire1__Project__c>)oldList;
        Map<ID, inspire1__Project__c> mapNew = (Map<ID,inspire1__Project__c>)newMap;
        Map<ID, inspire1__Project__c> mapOld = (Map<ID,inspire1__Project__c>)oldMap;
        
        // Add entries to the dispatcher static variable if they need to be updated or do direct DML
        
        System.debug('ProjectTriggerHandlerClone MainEntry. triggerEvent: ' + triggerEvent);
        
        switch on triggerEvent {
            
            when AFTER_INSERT {
                System.debug('inspire1__Project__c ---- > AFTER_INSERT');
                TriggerUtility.updateProjectCloneExecuted(); //important to break the Loop
                insertPSPRecords(mapNew);
            }
            when AFTER_UPDATE {
                System.debug('inspire1__Project__c ---- > AFTER_UPDATE');
                TriggerUtility.updateProjectCloneExecuted(); //important to break the Loop
                updatePSPRecords(mapNew);
            }
            when AFTER_DELETE {
                System.debug('inspire1__Project__c ---- > AFTER_DELETE');
                deletePSPRecords(mapOld);
            }
            when else {
                System.debug('Not expecting Trigger Event: ' + triggerEvent);
            }
        }
    }
    
    
    //Insert PSP Record for inspire1__Project__c records
    public void insertPSPRecords(Map<ID,inspire1__Project__c> newMAP){
        System.debug('insertPSPRecords ---- > called');
        // Get mapping of Professional_Service_Project  with Inspire1_Project
        list<Professional_Service_Project_Fld_Mapping__mdt> InterivewEventMaplist = 
            [SELECT Inspire1_Project_Field_API_Name__c, PSP_Field_API_Name__c FROM Professional_Service_Project_Fld_Mapping__mdt];
        
        MAP<ID,Professional_Service_Project__c> pspRecordInsertMAP = new MAP<ID,Professional_Service_Project__c>();
        
        for(Id insProjectID : newMAP.keyset()){
            //Inspire1 Project Record
            inspire1__Project__c insProject = newMAP.get(insProjectID);
            //Fill PSP record list for Insert
            Professional_Service_Project__c pspRecord = new Professional_Service_Project__c();
            pspRecord.Related_Inspire_Project_ID__c = insProject.id;
            for(Professional_Service_Project_Fld_Mapping__mdt fldMapping : InterivewEventMaplist){
                pspRecord.put(fldMapping.PSP_Field_API_Name__c, insProject.get(fldMapping.Inspire1_Project_Field_API_Name__c));
            }
            pspRecordInsertMAP.put(insProjectID,pspRecord);
        }
        
        List<inspire1__Project__c> failedInspList = new List<inspire1__Project__c>();
        
        system.debug('--pspRecordInsertMAP--'+pspRecordInsertMAP);
        if(pspRecordInsertMAP.size()>0){
            Database.SaveResult[] srlist = Database.insert(pspRecordInsertMAP.values(), false);
            getSaveResultErrorDetails(srlist);
            //For Failed Records Set the Flag on Inspire [PSP_Record_Sync_Failed__c]
            for(Id insProjectID : pspRecordInsertMAP.keyset()){
                Professional_Service_Project__c pspec =  pspRecordInsertMAP.get(insProjectID);
                if(pspec.id == null){
                    failedInspList.add(new inspire1__Project__c(id= insProjectID,PSP_Record_Sync_Failed__c = true));
                }
            }
        }
        
        //Update the Failed Inspire Project Records with the Flag
        system.debug('--failedInspList--'+failedInspList);
        if(failedInspList.size()>0){
            Database.update(failedInspList, false);
        }
        
    }
    
    //Update PSP Record for equivalent inspire1__Project__c record
    public void updatePSPRecords(Map<ID,inspire1__Project__c> newMAP){
        System.debug('updatePSPRecords ---- > called');
        // Get mapping of Professional_Service_Project  with Inspire1_Project
        list<Professional_Service_Project_Fld_Mapping__mdt> InterivewEventMaplist = 
            [SELECT Inspire1_Project_Field_API_Name__c, PSP_Field_API_Name__c FROM Professional_Service_Project_Fld_Mapping__mdt];
        
        MAP<ID,ID> pspInspRecordIDMap = getPSPRecord(newMAP.keyset());
        MAP<ID,Professional_Service_Project__c> pspRecordUpdateMAP = new MAP<ID,Professional_Service_Project__c>();
        MAP<ID,Professional_Service_Project__c> pspRecordInsertMAP = new MAP<ID,Professional_Service_Project__c>();
        
        for(Id insProjectID : newMAP.keyset()){
            //Inspire1 Project Record
            inspire1__Project__c insProject = newMAP.get(insProjectID);
            Professional_Service_Project__c pspRecord = new Professional_Service_Project__c();
            pspRecord.Related_Inspire_Project_ID__c = insProjectID;
            
            for(Professional_Service_Project_Fld_Mapping__mdt fldMapping : InterivewEventMaplist){
                pspRecord.put(fldMapping.PSP_Field_API_Name__c, insProject.get(fldMapping.Inspire1_Project_Field_API_Name__c));
            }
            
            if(pspInspRecordIDMap.containskey(insProjectID) && pspInspRecordIDMap.get(insProjectID) != null){
                //Fill PSP record list for Update
                pspRecord.id = pspInspRecordIDMap.get(insProjectID);               
                pspRecordUpdateMAP.put(insProjectID, pspRecord);
            } else{
                //Create New Equivalent PSP Record if not exist, and no errors
                if(insProject.PSP_Record_Sync_Failed__c == false){
                    pspRecordInsertMAP.put(insProjectID, pspRecord);
                }
            }
        }
        
        List<inspire1__Project__c> failedInspList = new List<inspire1__Project__c>();
        
        system.debug('--pspRecordUpdateMAP--'+pspRecordUpdateMAP);
        if(pspRecordUpdateMAP.size()>0){
            Database.SaveResult[] srlist = Database.update(pspRecordUpdateMAP.values(), false);
            getSaveResultErrorDetails(srlist);
            //For Failed Records Set the Flag on Inspire [PSP_Record_Sync_Failed__c]
            integer i = 0;
            for(Database.SaveResult Sr : srlist){
                if(!Sr.isSuccess()){
                    Professional_Service_Project__c pspec =  pspRecordUpdateMAP.get(Sr.getId());
                    if(pspec.id == null){
                       failedInspList.add(new inspire1__Project__c(id= pspec.id,PSP_Record_Sync_Failed__c = true));
                    }
                }
                i++;
            }
        }
        
        system.debug('--pspRecordInsertMAP--'+pspRecordInsertMAP);
        if(pspRecordInsertMAP.size()>0){
            Database.SaveResult[] srlist = Database.insert(pspRecordInsertMAP.values(), false);
            getSaveResultErrorDetails(srlist);
            //For Failed Records Set the Flag on Inspire [PSP_Record_Sync_Failed__c]
            for(Id insProjectID : pspRecordInsertMAP.keyset()){
                Professional_Service_Project__c pspec =  pspRecordInsertMAP.get(insProjectID);
                if(pspec.id == null){
                   failedInspList.add(new inspire1__Project__c(id= insProjectID,PSP_Record_Sync_Failed__c = true));
                }
            }
        }
        
        
        //Update the Failed Inspire Project Records with the Flag
        system.debug('--failedInspList--'+failedInspList);
        if(failedInspList.size()>0){
            Database.update(failedInspList, false);
        }
        
    }
    
    
    //Delete PSP Record for equivalent inspire1__Project__c record
    public void deletePSPRecords(Map<ID,inspire1__Project__c> oldMAP){
        System.debug('deletePSPRecords ---- > called');
        MAP<ID,ID> pspInspRecordIDMap = getPSPRecord(oldMAP.keyset());
        List<Professional_Service_Project__c> pspRecordDeleteList = new  List<Professional_Service_Project__c>();
        for(Id insProjectID : oldMAP.keyset()){
            //Inspire1 Project Record
            inspire1__Project__c insProject = oldMAP.get(insProjectID);   
            if(pspInspRecordIDMap.containskey(insProjectID) && pspInspRecordIDMap.get(insProjectID) != null){
                //Fill PSP record list for Delete
                Professional_Service_Project__c pspRecord = new Professional_Service_Project__c();
                pspRecord.id = pspInspRecordIDMap.get(insProjectID);
                pspRecordDeleteList.add(pspRecord);
            }   
        }
        if(pspRecordDeleteList.size()>0){
            //Delete pspRecordDeleteList;
            Database.delete(pspRecordDeleteList, false);
        }
    }
    
    
    //Get PSP Record ID for equivalent inspire1__Project__c record ID
    private MAP<ID,ID> getPSPRecord(Set<ID> inspireRecordIDSet){
        MAP<ID,ID> pspMap = new MAP<ID,ID>();
        for(Professional_Service_Project__c pspRec : [Select ID,Related_Inspire_Project_ID__c from Professional_Service_Project__c where Related_Inspire_Project_ID__c in :inspireRecordIDSet]){
            pspMap.put(pspRec.Related_Inspire_Project_ID__c,pspRec.id);
        }
        return pspMap;
    }
    
    private void getSaveResultErrorDetails( Database.SaveResult[] srlist ){
        for(Database.SaveResult Sr : srlist){
            if(!Sr.isSuccess()){
                System.debug('--Errors--'+sr.getErrors());
            }
        }
    }
}