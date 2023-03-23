/**
* @File Name          : updateSalesTeamMemberQueueable.cls
*==============================================================================
* Ver         Date                     Author                    Modification
* 1.0         2022-10-13               Rajat                    Initialized
*==============================================================================
**/
public class updateSalesTeamMemberQueueable implements Queueable {
    Set<ID> salesTerritoryID = new Set<ID>();
    Map<Id, Focus_Partner__c> oldRAMIdMap = new Map<Id, Focus_Partner__c>();
    Map<ID, Focus_Partner__c> newMap = new Map<ID, Focus_Partner__c>();
    Map<ID, Focus_Partner__c> oldMap = new Map<ID, Focus_Partner__c>();
    
    Public updateSalesTeamMemberQueueable(Set<ID> salesTerritoryID, Map<Id, Focus_Partner__c> oldRAMIdMap,
                                 Map<ID, Focus_Partner__c> newMap, Map<ID, Focus_Partner__c> oldMap){
                                     this.salesTerritoryID = salesTerritoryID;
                                     this.oldRAMIdMap = oldRAMIdMap;
                                         this.newMap = newMap;
                                         this.oldMap = oldMap; 
                                 }
      @TestVisible
    public void execute(QueueableContext context) {
         System.debug('222(A) ==>> replaceInactiveUserWithManagerAsRam() entered ..!!');
        System.debug('222(B) ==>> newMap is: '+newMap);
        System.debug('222(C) ==>> oldMap is: '+oldMap);
        System.debug('222(R) ==>> oldRAMIdMap is: '+oldRAMIdMap);
        Map<ID, List<PatchTeamMember__c>> userIDVSPatchTeamId = new Map<ID, List<PatchTeamMember__c>>();
        Map<ID, List<ID>> ramIDVSPatchTeamId = new Map<ID, List<ID>>();
		Set<Id> salesTeamToBeDeleteSet = new Set<Id>();
        Map<Id, List<PatchTeamMember__c>> salesTeamToBeUpdateMap = new Map<Id, List<PatchTeamMember__c>>();
        List<PatchTeamMember__c> salesTeamToBeInsertList = new List<PatchTeamMember__c>();
		
        for(PatchTeam__c patch : [Select Id, (SELECT Id, User__c FROM PatchTeamMembers__r WHERE Role__c = 'FP Regional Alliance Manager'), (SELECT Id, RAM__c FROM Focus_Partners__r WHERE RAM__c = :oldRAMIdMap.keySet()) FROM PatchTeam__c WHERE Id = :salesTerritoryID]){
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
                   && ramIDVSPatchTeamId.IsEmpty()&& !userIDVSPatchTeamId.containsKey(newFP.RAM__c)&& oldMap != null && oldMap.get(newFP.Id) != null && userIDVSPatchTeamId.containsKey(oldMap.get(newFP.Id).RAM__c)){
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
                        && userIDVSPatchTeamId.containsKey(oldMap.get(newFP.Id).RAM__c)*/
                        && userIDVSPatchTeamId.containsKey(newFP.RAM__c)){
                    for(PatchTeamMember__c ptmember : userIDVSPatchTeamId.get(newFP.RAM__c)){
                        if(oldRAMIdMap.containsKey(ptmember.User__c)){
							salesTeamToBeDeleteSet.add(ptmember.Id);   
                     // Added for IBA-3858   
                    }else if(ramIDVSPatchTeamId.IsEmpty()){
                         for(PatchTeamMember__c ptmember1 : userIDVSPatchTeamId.get(oldMap.get(newFP.Id).RAM__c)){
                        		if(oldRAMIdMap.containsKey(ptmember1.User__c)){
                                	System.debug('222  Inside delete else if condition: ');
									salesTeamToBeDeleteSet.add(ptmember1.Id);
                                 }
                         }
                    }
                        else{
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
    }
}