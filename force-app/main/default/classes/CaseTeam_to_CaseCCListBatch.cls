/*****************************************************************************************
Name: CaseTeam_to_CaseCCListBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Populate case cc list based on case team members

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           01-Feb-2019      Initial Development
******************************************************************************************/

public class CaseTeam_to_CaseCCListBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CaseTeam_to_CaseCCListBatch');
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    public String que = '';
    public boolean runblankcclist;

    public CaseTeam_to_CaseCCListBatch(string q, boolean runonlyblankcc){
        que = q;
        runblankcclist = runonlyblankcc;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        //String query = 'Select Id, Case_CC_List__c from Case whereId in (Select ParentId from CaseTeamMember where TeamRole.Name = \'Internal Agent\' or TeamRole.Name = \'Customer\') and recordtype.name = \'Support\'';
        return Database.getQueryLocator(que);
    }

    public void execute(Database.BatchableContext context, List<Case> cslst){
        this.zb.callExecute(cslst[0]?.Id, cslst.size());
        try{
            TriggerUtility.SkipCaseTriggerExecuted();
            List<Case> cslstfinal = new List<Case>();
            if(runblankcclist){
                for(Case cs: cslst){
                    if((cs.Internal_CC_List__c == null || cs.Internal_CC_List__c == '') && (cs.Customer_CC_List__c == null || cs.Customer_CC_List__c == '')){
                        cslstfinal.add(cs);
                    }
                }
            }else{
                cslstfinal.addAll(cslst);
            }
            updatecaseCCList(cslstfinal);
        }catch(Exception ex){
            errorlst.add('Error: ' + ex);
        }
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Entitlement Creation Batch Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' records that have failed: \n';
            for(String s: errorlst){
                msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }
        if(!successlst.isEmpty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Entitlement Creation Batch Success result ');
            mail.setPlainTextBody('Entitlement Creation Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    public static void updatecaseCCList(List<case> cslst) {
        Map<Id, String> cclstmap = new Map<Id, String>();
        Map<Id, String> conIdtoemailMap = new Map<Id, String>();
        Map<Id, String> userIdtoemailMap = new Map<Id, String>();
        Set<Id> contIds = new Set<Id>();
        Set<String> intlst = new Set<String>();
        Set<String> extlst = new Set<String>();
        for(CaseTeamMember ctr: [Select Id, MemberId, Member.Email, ParentId from CaseTeamMember where ParentId in :cslst]){
            contIds.add(ctr.MemberId);
        }
        for(Contact con: [Select Id, Email from Contact where Id in :contIds]){
            conIdtoemailMap.put(con.Id, con.Email);
        }
    	for(User ur: [Select Id, Email from User where Id in :contIds]){
            userIdtoemailMap.put(ur.Id, ur.Email);
        }
        for(CaseTeamMember ctr: [Select Id, MemberId, Member.Email, ParentId from CaseTeamMember where ParentId in :cslst]){
            if(cclstmap.containsKey(ctr.ParentId)){
                String emails = cclstmap.get(ctr.ParentId);
                emails += conIdtoemailMap.containsKey(ctr.MemberId) ? conIdtoemailMap.get(ctr.MemberId) + ';' : (userIdtoemailMap.containsKey(ctr.MemberId) ? userIdtoemailMap.get(ctr.MemberId) + ';' : '');
                cclstmap.put(ctr.ParentId, emails);
            }else{
                cclstmap.put(ctr.ParentId, conIdtoemailMap.containsKey(ctr.MemberId) ? conIdtoemailMap.get(ctr.MemberId) + ';' : (userIdtoemailMap.containsKey(ctr.MemberId) ? userIdtoemailMap.get(ctr.MemberId) + ';' : ''));
            }
        }
        
        for(Case cs: cslst){
            cs.Internal_CC_List__c = null;
            cs.Customer_CC_List__c = null;
            if(cclstmap.containsKey(cs.Id) && cclstmap.get(cs.Id) != null){
                for(String s: cclstmap.get(cs.Id).split(';')){
                    if(s != null && s != '' && s.trim() != ''){
                        if(s.contains('@zscaler.com') && !intlst.contains(s)){
                            if(cs.Internal_CC_List__c != null){
                                cs.Internal_CC_List__c += s + ';';
                            }else{
                                cs.Internal_CC_List__c = s + ';';
                            }
                        }else if (!s.contains('@zscaler.com') && !extlst.contains(s)){
                            if(cs.Customer_CC_List__c != null){
                                cs.Customer_CC_List__c += s + ';';
                            }else{
                                cs.Customer_CC_List__c = s + ';';
                            }
                        }
                    }
                }
            }
        }
        TriggerUtility.SkipCaseTriggerExecuted();
        update cslst;
    }
    
}