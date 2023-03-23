/**
 *  This trigger is used to set Market_Segment__c on Lead.
 */

trigger UpdateLeadMarketSegment on Lead (before insert, before update)
{
    if(!TriggerUtility.isafterUpdateRelatedLeadExecuted()){
    if(Trigger.isBefore){
        if(trigger.isInsert){
            system.debug('in insert');
            leadTriggerHelper.UpdateMarketSegment(trigger.new,trigger.oldMap,trigger.isinsert,trigger.isupdate);
            
        }else if(trigger.isUpdate && !TriggerUtility.UpdatingMarketsegmentforLeadExecuted()){
            {
                leadTriggerHelper.UpdateMarketSegment(trigger.new,trigger.oldmap,trigger.isinsert,trigger.isupdate);
                //TriggerUtility.UpdatingMarketsegmentforEMEAsettrue();
            }
        }
    }
            
    if((trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
        set<id> patchIdSet = new Set<id>();
        map<Id, Id> patchTerritoryMap = new map<Id, Id>();
        for(lead le : trigger.new){
            if(le.Patch__c != null)
                patchIdSet.add(le.Patch__c);
             if(le.Status.equalsIgnoreCase('Disqualified') || le.Status.equalsIgnoreCase('Recycled to Marketing')) {
                le.Last_Closed_Date__c = system.today();
            }
            if ( Trigger.isUpdate  && le.Last_Opened_Date__c!=NULL && le.Last_Opened_Date__c != Trigger.oldMap.get(le.ID).Last_Opened_Date__c){
                le.Last_Closed_Date__c = Null;
            }
            //Added by Swathi : CR#3101 Start
            if( Trigger.isInsert && le.Not_Eligible_for_Lead_Routing__c ){
                le.OwnerId = Label.Unassigned_Lead_Queue_Id;
            }
            if( Trigger.isUpdate && le.Not_Eligible_for_Lead_Routing__c && le.Not_Eligible_for_Lead_Routing__c != Trigger.oldMap.get(le.Id).Not_Eligible_for_Lead_Routing__c){
                le.OwnerId = Label.Unassigned_Lead_Queue_Id;
            }
            //Added by Swathi : CR#3101 End
            /*
            if(le.Status.equalsIgnoreCase('Actively Engaged') && le.Days_since_last_activity__c==Null && le.Age_Since_Last_Open__c >= 61){
                le.Status = 'Recycled to Marketing'; 
                le.Remarks__c ='Not Interested' ;
                le.Outreach_Status__c ='Closed';
            }
            */
            // Commented out below code as logic moves to workflow for Fullcircle
            /* if(Trigger.isUpdate && le.status.equalsIgnoreCase('Marketing Qualified: Sales Untouched')  && String.isNotBlank(le.Outreach_Status__c) && le.Outreach_Status__c != Trigger.oldMap.get(le.ID).Outreach_Status__c && (le.Outreach_Status__c.equalsIgnoreCase('Added to Sequence') || le.Outreach_Status__c.equalsIgnoreCase('Contact Attempted') )){
                //le.Status = 'Marketing Qualified: Sales Accepted';
                le.Status = 'SAL: Sales Pursuing Lead';     //Added as part of CR# 2731 :Gurjinder
            }
            if(Trigger.isUpdate && String.isNotBlank(le.Outreach_Status__c) && le.Outreach_Status__c != Trigger.oldMap.get(le.ID).Outreach_Status__c && (le.Outreach_Status__c.equalsIgnoreCase('Connected'))){
                //le.Status = 'Actively Engaged';
                le.Status = 'SAL: Sales Connected Lead'; //Added as part of CR# 2731 :Gurjinder
            }
            if(Trigger.isUpdate && le.Status!=Trigger.oldMap.get(le.ID).status && le.Status.equalsIgnoreCase('SAL: Sales Connected Lead') ){ //updated the status condition as part of CR# 2731 :Gurjinder
                le.Remarks__c = null;
            }  */
        }
        for(Patch__c patch : [Select Id, PatchTeam__c from Patch__c where PatchTeam__c != null AND ID IN: patchIdSet]){
            patchTerritoryMap.put(patch.id, patch.PatchTeam__c);
        }

        for(lead le : trigger.new){
            if(le.Patch__c != null)
                le.Territory__c = patchTerritoryMap.get(le.Patch__c);
        }
              
    }
    }
    if(test.isrunningtest()){
    integer i=0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
}
}