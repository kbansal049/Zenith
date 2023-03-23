/**
* @File Name          : FocusPartnerMasterTriggerHelper.cls
* @TestClass          : FocusPartnerMasterTriggerTest
*==============================================================================
* Ver         Date                     Author                    Modification
* 1.0         2022-06-09               Swathi                    Initialized
  2.0         10-11-2022(MM-DD-YYYY)   Mahesh T                  IBA-3660
  3.0         10-14-2022               Mahesh T                  iba-3858
  4.0 	      10-25-2022               Rajat                     IBA-3697
*==============================================================================
**/
public class FocusPartnerMasterTriggerHelper {
    public void onAfterInsert(map<ID,Focus_Partner__c> newMap){
        System.debug('000(A) ==>> onAfterInsert() entered ..!!');
        Set<Id> salesTerritoryIDSet = new Set<Id>();
        for(Focus_Partner__c newFP : newMap.values()){
            salesTerritoryIDSet.add(newFP.Sales_Territory__c);
        }
        rollupFocusPartner(newMap);
        createSalesTeamMember(salesTerritoryIDSet, newMap);
    }
    
    public void onAfterupdate(map<ID, Focus_Partner__c> newMap, map<ID, Focus_Partner__c> oldMap){
        System.debug('111(A) ==>> onAfterupdate() entered ..!!');
        Set<Id> salesTerritoryIdSet = new Set<Id>();
        Map<Id, Focus_Partner__c> oldRAMIdMap = new Map<Id, Focus_Partner__c>();
        for(Focus_Partner__c newFP : newMap.values()){
            Focus_Partner__c oldFP = oldMap.get(newFP.Id);
            if(newFP.RAM__c != oldFP.RAM__c){
                salesTerritoryIdSet.add(newFP.Sales_Territory__c);
                oldRAMIdMap.put(oldFP.RAM__c, newFP);
            }
        }
        System.debug('111(B) ==>> salesTerritoryIdSet is: '+salesTerritoryIdSet);
        System.debug('111(C) ==>> oldRAMIdMap is: '+oldRAMIdMap);
        if(!salesTerritoryIdSet.IsEmpty() && !TriggerUtility2.isfocusPartnerSalesTeamUpdateExecuted()){
            //IBA-3697 -- Start
            ID jobID = System.enqueueJob(new updateSalesTeamMemberQueueable(salesTerritoryIdSet, oldRAMIdMap, newMap, oldMap));
            System.debug('jobID'+jobID);
            TriggerUtility2.setfocusPartnerSalesTeamUpdateExecuted();
            //IBA-3697 -- End
        //    updateSalesTeamMember(salesTerritoryIdSet, oldRAMIdMap, newMap, oldMap);
        } 
    }
    
    public void onAfterDelete(map<ID, Focus_Partner__c> oldMap){
        
        System.debug('101(A) ==>> onAfterDelete() entered ..!!');
        Set<Id> salesTerritoryIdSet = new Set<Id>();
        Map<Id, Focus_Partner__c> oldRAMIdMap = new Map<Id, Focus_Partner__c>();
        rollupFocusPartner(oldMap);
        for(Focus_Partner__c oldFP : oldMap.values()){
            salesTerritoryIdSet.add(oldFP.Sales_Territory__c);
            oldRAMIdMap.put(oldFP.RAM__c, oldFP);
        }
        System.debug('101(B) ==>> salesTerritoryIdSet is: '+salesTerritoryIdSet);
        System.debug('101(C) ==>> oldRAMIdMap is: '+oldRAMIdMap);
        if(!salesTerritoryIdSet.IsEmpty()){
            //IBA-3697 -- Start
            ID jobID = System.enqueueJob(new updateSalesTeamMemberQueueable(salesTerritoryIdSet, oldRAMIdMap, oldMap, null));
            System.debug('jobID'+jobID);
            //IBA-3697 -- End
        //    updateSalesTeamMember(salesTerritoryIdSet, oldRAMIdMap, oldMap, null);
        } 
    }
    
    public void rollupFocusPartner(map<ID, Focus_Partner__c> newMap){
        Set<Id> salesTerritoryIds = new Set<Id>();
        for(Focus_Partner__c newFP : newMap.values()){
            if(newFP.Sales_Territory__c != null){
                salesTerritoryIds.add(newFP.Sales_Territory__c);
            }
        }
        if(!salesTerritoryIds.isEmpty()){
            List<PatchTeam__c> updateSTList = new List<PatchTeam__c>();
            for(PatchTeam__c objPatchTeam : [SELECT Id, Total_Number_of_Focus_Partner__c, (SELECT Id FROM Focus_Partners__r) FROM PatchTeam__c WHERE Id IN :salesTerritoryIds]){
                if(objPatchTeam.Focus_Partners__r.size()>0){
                    objPatchTeam.Total_Number_of_Focus_Partner__c = objPatchTeam.Focus_Partners__r.size();
                    updateSTList.add(objPatchTeam);
                }
            }
            try{
                if(!updateSTList.isEmpty()){
                    List<Database.SaveResult> updateResultList = Database.update(updateSTList);
                }
            }catch(Exception ex){
                System.debug('In rollupFocusPartner(), Exception is: '+ex);
            }
        } 
    }
    
    public void createSalesTeamMember(Set<ID> salesTerritoryIDSet,map<ID,Focus_Partner__c> newMap){
        List<PatchTeamMember__c> salesTeam = new List<PatchTeamMember__c>();
        Map<ID,ID> userIDVSPatchTeamId = new Map<ID,ID>();
        for(PatchTeamMember__c ptm : [SELECT Id, User__c FROM PatchTeamMember__c WHERE PatchTeam__c = :salesTerritoryIDSet AND Role__c = 'FP Regional Alliance Manager']){
            userIDVSPatchTeamId.put(ptm.User__c, ptm.Id);
        }
        for(Focus_Partner__c newFP : newMap.values()){
            if(!userIDVSPatchTeamId.containsKey(newFP.RAM__c)){
                PatchTeamMember__c ptm = New PatchTeamMember__c();
                ptm.Role__c = 'FP Regional Alliance Manager';
                ptm.User__c = newFP.RAM__c;
                ptm.PatchTeam__c = newFP.Sales_Territory__c;
                salesTeam.add(ptm);
            }
        }
        try{
            if(!salesTeam.isEmpty()){
                List<Database.SaveResult> insertResultList = Database.insert(salesTeam);
            }
        }catch(Exception ex){
            System.debug('In createSalesTeamMember(), Exception is: '+ex);
        }
    }
    
    @TestVisible
    
    /*
    private void updateSalesTeamMember(Set<ID> salesTerritoryID, Map<Id, Focus_Partner__c> oldRAMIdMap,
                                      Map<ID, Focus_Partner__c> newMap, Map<ID, Focus_Partner__c> oldMap){
        System.debug('222(A) ==>> replaceInactiveUserWithManagerAsRam() entered ..!!');
        System.debug('222(B) ==>> newMap is: '+newMap);
        System.debug('222(C) ==>> oldMap is: '+oldMap);
        Map<ID, List<PatchTeamMember__c>> userIDVSPatchTeamId = new Map<ID, List<PatchTeamMember__c>>();
        Map<ID, List<ID>> ramIDVSPatchTeamId = new Map<ID, List<ID>>();
		Set<Id> salesTeamToBeDeleteSet = new Set<Id>();
        Map<Id, List<PatchTeamMember__c>> salesTeamToBeUpdateMap = new Map<Id, List<PatchTeamMember__c>>();
        List<PatchTeamMember__c> salesTeamToBeInsertList = new List<PatchTeamMember__c>();
		
      //  for(PatchTeam__c patch : [Select Id, (SELECT Id, User__c FROM PatchTeamMembers__r WHERE Role__c = 'FP Regional Alliance Manager'), (SELECT Id, RAM__c FROM Focus_Partners__r WHERE RAM__c = :oldRAMIdMap.keySet()) FROM PatchTeam__c WHERE Id = :salesTerritoryID]){
            if(!patch.PatchTeamMembers__r.isEmpty()){
                for(PatchTeamMember__c ptm : patch.PatchTeamMembers__r){
                    List<PatchTeamMember__c> ptmsList = null;
                    if(userIDVSPatchTeamId.containsKey(ptm.User__c)){
                        ptmsList = userIDVSPatchTeamId.get(ptm.User__c);
                        ptmsList.add(ptm);
                        userIDVSPatchTeamId.put(ptm.User__c, ptmsList);
                    }else{
                        ptmsList = new List<PatchTeamMember__c>();
                        ptmsList.add(ptm);
                        userIDVSPatchTeamId.put(ptm.User__c, ptmsList);
                    }	
                }
            }
            System.debug('222(D) ==>> userIDVSPatchTeamId is: '+userIDVSPatchTeamId);
            
            if(!patch.Focus_Partners__r.isEmpty()){
                for(Focus_Partner__c fp : patch.Focus_Partners__r){
                    List<Id> ramIdList = null;
                    if(ramIDVSPatchTeamId.containsKey(fp.RAM__c)){
                        ramIdList = ramIDVSPatchTeamId.get(fp.RAM__c);
                        ramIdList.add(patch.Id);
                        ramIDVSPatchTeamId.put(fp.RAM__c, ramIdList);
                    }else{
                        ramIdList = new List<Id>();
                        ramIdList.add(patch.Id);
                        ramIDVSPatchTeamId.put(fp.RAM__c, ramIdList);
                    }
                }
            }
            System.debug('222(E) ==>> ramIDVSPatchTeamId is: '+ramIDVSPatchTeamId);
            
            for(Focus_Partner__c newFP : newMap.values()){
                //Update Sales Team record(s)
                if(newFP.RAM__c != Null 
                   && ramIDVSPatchTeamId.IsEmpty() 
                   && !userIDVSPatchTeamId.containsKey(newFP.RAM__c) 
                   && oldMap != null 
                   && oldMap.get(newFP.Id) != null 
                   && userIDVSPatchTeamId.containsKey(oldMap.get(newFP.Id).RAM__c)){
		    		Focus_Partner__c oldFP = oldMap.get(newFP.Id);
                    for(PatchTeamMember__c ptmember : userIDVSPatchTeamId.get(oldFP.RAM__c)){ 
                        ptmember.User__c = newFP.RAM__c;
                        if(salesTeamToBeUpdateMap.containsKey(oldFP.RAM__c)){
                            salesTeamToBeUpdateMap.get(oldFP.RAM__c).add(ptmember);
                        }else{
                            salesTeamToBeUpdateMap.put(oldFP.RAM__c, New List<PatchTeamMember__c>());
                            salesTeamToBeUpdateMap.get(oldFP.RAM__c).add(ptmember);
                        }
                    }
                }
                //Delete Sales Team record(s)
                 else if(newFP.RAM__c != Null 
                        && ramIDVSPatchTeamId.IsEmpty()
                        /* IBA-3660 Fix 
                        && oldMap != null
                        && oldMap.get(newFP.Id) != null
                        && userIDVSPatchTeamId.containsKey(oldMap.get(newFP.Id).RAM__c)*
                        && userIDVSPatchTeamId.containsKey(newFP.RAM__c)){
                    for(PatchTeamMember__c ptmember : userIDVSPatchTeamId.get(newFP.RAM__c)){
                        if(oldRAMIdMap.containsKey(ptmember.User__c)){
							salesTeamToBeDeleteSet.add(ptmember.Id);
                        
                    }else{
                            continue;
                        }
                    }
                }
                //Insert Sales Team record(s)
                else if(newFP.RAM__c != Null && !ramIDVSPatchTeamId.IsEmpty()){
                    if(!userIDVSPatchTeamId.containsKey(newFP.RAM__c)){
                        PatchTeamMember__c PTM = New PatchTeamMember__c();
                        PTM.Role__c = 'FP Regional Alliance Manager';
                        PTM.User__c = newFP.RAM__c;
                        PTM.PatchTeam__c = newFP.Sales_Territory__c;
                        salesTeamToBeInsertList.add(PTM);
                    }
                } 
            }
            
            try{
                System.debug('222(F1) ==>> salesTeamToBeDeleteSet is: '+salesTeamToBeDeleteSet);
                if(!salesTeamToBeDeleteSet.isEmpty()){
                    List<Database.DeleteResult> deleteResultList = Database.delete(new List<Id>(salesTeamToBeDeleteSet));
                    System.debug('222(F2) ==>> deleteResultList is: '+deleteResultList);
                }

                System.debug('222(G) ==>> salesTeamToBeUpdateMap is: '+salesTeamToBeUpdateMap);
                if(!salesTeamToBeUpdateMap.isEmpty()){
                    Set<PatchTeamMember__c> salesTeamToBeUpdateSet = new Set<PatchTeamMember__c>();
                    for(Id i : salesTeamToBeUpdateMap.keyset()){
                        for(PatchTeamMember__c p : salesTeamToBeUpdateMap.get(i)){
                            salesTeamToBeUpdateSet.add(p);
                        }
                    }
                    System.debug('222(G1) ==>> salesTeamToBeUpdateSet is: '+salesTeamToBeUpdateSet);
                    List<Database.SaveResult> updateResultList = Database.update(new List<PatchTeamMember__c>(salesTeamToBeUpdateSet));
                    System.debug('222(G2) ==>> updateResultList is: '+updateResultList);
                }

                System.debug('222(H1) ==>> salesTeamToBeInsertList is: '+salesTeamToBeInsertList);
                if(!salesTeamToBeInsertList.isEmpty()){
                    List<Database.SaveResult> insertResultList = Database.insert(salesTeamToBeInsertList);
                    System.debug('222(H2) ==>> insertResultList is: '+insertResultList);
                }
            }catch(Exception ex){
            	System.debug('In updateSalesTeamMember(), Exception is: '+ex);
            }
        }
    } */
    
    @future
    public static void replaceInactiveUserWithManagerAsRam(Set<Id> inActiveUserIdSet){
        System.debug('333(A) ==>> replaceInactiveUserWithManagerAsRam() entered ..!!');
        System.debug('333(B) ==>> inActiveUserIdSet is: '+inActiveUserIdSet);
        try{
            List<Focus_Partner__c> tobeUpdateFPList = new List<Focus_Partner__c>();
            for(Focus_Partner__c fp : [SELECT Id, RAM__c, RAM__r.ManagerId, RAM__r.Manager.ManagerId, RAM__r.Manager.isActive FROM Focus_Partner__c WHERE RAM__c IN :inActiveUserIdSet]){
                if(fp.RAM__r.Manager.isActive == true){
                    fp.RAM__c = fp.RAM__r.ManagerId;
                    fp.Comments__c = 'RAM is replaced with Reporting Manager as user got deactivated';
                }
                else{
                    fp.RAM__c = FP.RAM__r.Manager.ManagerId;
                    fp.Comments__c = 'RAM is replaced with Manager of Reporting Manager as user got deactivated and Reporting manager is Inactive as well';
                }
                tobeUpdateFPList.add(fp);
            }
            System.debug('333(C) ==>> tobeUpdateFPList is: '+tobeUpdateFPList);
            if(!tobeUpdateFPList.isEmpty()){
                List<Database.SaveResult> updateResultList = Database.update(tobeUpdateFPList);
                System.debug('333(D) ==>> updateResultList is: '+updateResultList);
            }
        }catch(Exception ex){
            System.debug('In replaceInactiveUserWithManagerAsRam(), Exception is: '+ex);
        }
    }
}