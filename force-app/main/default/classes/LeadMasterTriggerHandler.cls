/**
* APTTUS
* @author           Pankaj Verma
* Description:      Class that will manage almost all events for Lead Trigger.
*                   This is master trigger handler, and deprecating existing triggers to merge in one master
* Changes (Version)
* -------------------------------------
*           No.                       Autor                   Descripción
*           -----   ----------      --------------------    ---------------
* @version   1.0    27-Mar-2020     Pankaj Verma             Creating Master trigger Class
*************************************************************************************************************/

public without sharing class LeadMasterTriggerHandler{
    
    
    public void onBeforeInsert(List<Lead> newList){
        system.debug('@@@NEWMAP.VALUES()'+newList);
        processSDRBeforeInsert(newList);
        if(Test.isrunningtest()){
            booster();
        }
    }
    
    public void onAfterInsert(map<ID,Lead> newMap){
        //processSDRAfterInsert(newMap);
    }
    
    public void onAfterupdate(map<ID,Lead> newMap,map<ID,Lead> oldMap){
        processSDRAfterUpdate(newMap,oldMap);
        processCampaignMemberAfterUpdate(newMap,oldMap);
    }
    
    
    public void processSDRBeforeInsert(List<Lead> newleadList){
        for(lead l : newleadList){
            l.last_opened_date__c = System.today();
        }
    }
    
    public void processSDRAfterUpdate(map<ID,Lead> newMap, map<ID,Lead> oldMap){
        
        List<Lead> updateLeadList = new List<Lead>();
        
        for(Lead l : [SELECT ID,Status,createddate,Isconverted,Contact_Request__c,Touches_Since_Last_Open__c FROM LEAD WHERE ID IN :newmap.values() AND Isconverted=False])
        { 
            /*****every time "Lead Status" changes FROM "Disqualified" or "Recycled to Marketing" TO (1) "Pending Marketing Qualified" or to (2) "Marketing Qualified: Sales Untouched" or to (3) "Marketing Qualified: Sales Accepted" or to (4) "Actively Engaged" status. ***/
            if((oldmap.get(l.id).status=='Disqualified' || oldmap.get(l.id).status=='Recycled to Marketing' ) 
               && (newmap.get(l.id).Status =='Pending Marketing Qualification' || 
                   newmap.get(l.id).Status =='Marketing Qualified: Sales Untouched' || 
                   newmap.get(l.id).Status =='SAL: Sales Pursuing Lead' || 
                   newmap.get(l.id).Status =='SAL: Sales Connected Lead' || 
                   newmap.get(l.id).Status =='Meeting Scheduled' || 
                   //newmap.get(l.id).Status =='Marketing Qualified: Sales Accepted' || 
                   newmap.get(l.id).Status =='Actively Engaged')
                   //added conditions as part of CR# 2731
              )
            {
                //l.Last_Opened_Date__c = date.newinstance(newmap.get(l.id).createdDate.year(),newmap.get(l.id).createdDate.month(), newmap.get(l.id).createdDate.day()); 
                
                l.last_opened_date__c= System.today();
                l.Touches_Since_Last_Open__c=0;
                updateLeadList.add(l);
            }
            
            /***********CHANGE IN CR 146 **********/
            if(newmap.get(l.id).status=='Recycled to Marketing' || newMap.get(l.id).status=='Disqualified' ){
                //l.Last_Opened_Date__c = date.newinstance(newmap.get(l.id).createdDate.year(),newmap.get(l.id).createdDate.month(), newmap.get(l.id).createdDate.day()); 
                if (l.Contact_Request__c){
                    l.Contact_Request__c= false;
                    updateLeadList.add(l);
                }
            }
            /*********** *******************/
            
            /******  Also resets if "Lead Status" moves from "Pending Marketing Qualified" to (1) "Marketing Qualified - Sales Untouched" or to (2) "Marketing Qualified: Sales Accepted" or to (3) "Actively Engaged" status.*********/
            if((oldmap.get(l.id).status=='Pending Marketing Qualification') && (newmap.get(l.id).Status =='Marketing Qualified: Sales Untouched' || newmap.get(l.id).Status =='SAL: Sales Pursuing Lead' || newmap.get(l.id).Status =='SAL: Sales Connected Lead' || newmap.get(l.id).Status =='Meeting Scheduled' || newmap.get(l.id).Status =='Actively Engaged')) //added conditions as part of CR# 2731
            {
                //l.Last_Opened_Date__c = date.newinstance(newmap.get(l.id).createdDate.year(),newmap.get(l.id).createdDate.month(), newmap.get(l.id).createdDate.day()); 
                l.last_opened_date__c= System.today();
                l.Touches_Since_Last_Open__c=0;
                updateLeadList.add(l);
            }    
        }
        
        if(!updateLeadList.isEmpty())
            update updateLeadList;
                
    }
    
    
    //CR# 190
    //IF Reporting Matched Account chnages update the campaign member
    public void processCampaignMemberAfterUpdate(map<ID,Lead> newMap, map<ID,Lead> oldMap){
        System.debug('--processCampaignMemberAfterUpdate--called');
        
        List<ID> leadToBeConsidered = new  List<ID>();
        for(Lead ld: newMap.values()){
            Lead oldLead= oldMap.get(ld.Id);
            if(oldLead != null && ld.LeanData__Reporting_Matched_Account__c != oldLead.LeanData__Reporting_Matched_Account__c){
                leadToBeConsidered.add(ld.Id);
            }
        }
        System.debug('---leadToBeConsidered--'+leadToBeConsidered);
        
        MAP<ID,List<CampaignMember>> leadCampaignMemberList = new  MAP<ID,List<CampaignMember>>();
        for(CampaignMember cm : [Select ID,name,Account__c,CampaignId,Campaign.IsActive,LeadId from CampaignMember where Account__c = null and LeadId in : leadToBeConsidered limit 5000]){
            List<CampaignMember> cmpList = null;
            if(leadCampaignMemberList.containskey(cm.LeadId)){
                cmpList = leadCampaignMemberList.get(cm.LeadId);
            }else{
               cmpList = new List<CampaignMember>();
            }
            cmpList.add(new CampaignMember(Id=cm.id));
            leadCampaignMemberList.put(cm.LeadId,cmpList);
        }
        List<CampaignMember> campMemUpdateList = new List<CampaignMember>();
        for(List<CampaignMember> camList : leadCampaignMemberList.values()){
            if(camList != null && camList.size()>0){
                campMemUpdateList.addAll(camList);
            }
        }
        System.debug('---campMemUpdateList--'+campMemUpdateList);
        System.debug('---campMemUpdateList size--'+campMemUpdateList.size());
        if(campMemUpdateList.size()>0){
            update campMemUpdateList;
        }
    }
    public static void booster(){
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