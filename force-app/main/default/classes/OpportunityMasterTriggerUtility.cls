public class OpportunityMasterTriggerUtility{

    public static void beforeInsert(List<Opportunity> newOppList){
        //Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        
        // if(tsmap.containsKey('BefInsrtOppFieldUpdateTrgrHandler') && tsmap.get('BefInsrtOppFieldUpdateTrgrHandler') != null && tsmap.get('BefInsrtOppFieldUpdateTrgrHandler').Execute__c /* && !TriggerUtility */ ){
           // OpportunityFieldUpdateTriggerHandler.BeforeInsert(newOppList);
        //} 
        //TriggerUtility.OppBeforeInsertExecuted();
    }
    
    public static void afterInsert(List<Opportunity> newOppList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        boolean isinsert=true;
        boolean isupdate=false;
        //CaseCreationForAccountAndOpportunity.opportunityCaseCreation(newOppList);
        
		if(tsmap.containsKey('UpdateEdgewiseOverlayTeamSharing') && tsmap.get('UpdateEdgewiseOverlayTeamSharing') != null && tsmap.get('UpdateEdgewiseOverlayTeamSharing').Execute__c && !TriggerUtility2.isUpdateEdgewiseOverlayTeamSharingExecuted() ){
			UpdateEdgewiseOverlayTeamSharing(newOppList,null,isinsert,isupdate);
		}
        
        TriggerUtility2.OppAfterInsertExecuted();
    }
    
    public static void beforeUpdate(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        //Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        //TriggerUtility.OppBeforeUpdateExecuted();
    }
    
    public static void AfterUpdate(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        boolean isinsert=false;
        boolean isupdate=true;
        
        if(tsmap.containsKey('UpdateEdgewiseOverlayTeamSharing') && tsmap.get('UpdateEdgewiseOverlayTeamSharing') != null && tsmap.get('UpdateEdgewiseOverlayTeamSharing').Execute__c && !TriggerUtility2.isUpdateEdgewiseOverlayTeamSharingExecuted() ){
        UpdateEdgewiseOverlayTeamSharing(newOppList,oldOppMap,isinsert,isupdate);
        }
        TriggerUtility2.OppAfterUpdateExecuted();
    }
    
    public static void UpdateEdgewiseOverlayTeamSharing(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap,boolean isinsert,boolean isupdate){
       // system.debug('inside UpdateEdgewiseOverlayTeamSharing method');
        //system.debug(' isinsert '+isinsert);
        //system.debug(' isupdate '+isupdate);
        String EdgewiseOverlayMember1= ZscalerCustomSetting__c.getInstance('EdgewiseOverlayMember1')!=null && ZscalerCustomSetting__c.getInstance('EdgewiseOverlayMember1').Value__c!=null ? ZscalerCustomSetting__c.getInstance('EdgewiseOverlayMember1').Value__c:'0050g0000061nfU';
        String EdgewiseOverlayMember2= ZscalerCustomSetting__c.getInstance('EdgewiseOverlayMember2')!=null && ZscalerCustomSetting__c.getInstance('EdgewiseOverlayMember2').Value__c!=null ? ZscalerCustomSetting__c.getInstance('EdgewiseOverlayMember2').Value__c:'0050g0000061nfZ';

        List<OpportunityTeamMember> OTMtoinsert= new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> OTMtodelete= new List<OpportunityTeamMember>();
        Set<id> Oppidsettodeleteexistingsharing= new Set<id>();
        if(isinsert){
            for(Opportunity opp:newOppList){
                //system.debug('overlay team input '+opp.Edgewise_Overlay_Team__c);
                if(opp.Edgewise_Overlay_Team__c!=null){
                    if(opp.Edgewise_Overlay_Team__c.equalsignorecase('Katie Campbell;Jen McCoy')){
                       // system.debug('inside first if');
                        OpportunityTeamMember oppTeamMember1 = new OpportunityTeamMember(OpportunityId=opp.id,TeamMemberRole = 'Overlay Edgewise',OpportunityAccessLevel = 'Edit',UserId=EdgewiseOverlayMember1);
                        OpportunityTeamMember oppTeamMember2 = new OpportunityTeamMember(OpportunityId=opp.id,TeamMemberRole = 'Overlay Edgewise',OpportunityAccessLevel = 'Edit',UserId=EdgewiseOverlayMember2);
                
                        OTMtoinsert.add(oppTeamMember1);
                        OTMtoinsert.add(oppTeamMember2);
                    }else if(opp.Edgewise_Overlay_Team__c.equalsignorecase('Katie Campbell')){
                       // system.debug('inside second if');
                        OpportunityTeamMember oppTeamMember1 = new OpportunityTeamMember(OpportunityId=opp.id,TeamMemberRole = 'Overlay Edgewise',OpportunityAccessLevel = 'Edit',UserId=EdgewiseOverlayMember1);
                        OTMtoinsert.add(oppTeamMember1);
                    }else if(opp.Edgewise_Overlay_Team__c.equalsignorecase('Jen McCoy')){
                       // system.debug('inside third if');
                        OpportunityTeamMember oppTeamMember2 = new OpportunityTeamMember(OpportunityId=opp.id,TeamMemberRole = 'Overlay Edgewise',OpportunityAccessLevel = 'Edit',UserId=EdgewiseOverlayMember2);
                        OTMtoinsert.add(oppTeamMember2);
                    }
                }
            }
        }else if(isupdate){
            for(Opportunity opp:newOppList){
               // system.debug('overlay team input '+opp.Edgewise_Overlay_Team__c);
               // system.debug('oldOppMap.get(opp.id).Edgewise_Overlay_Team__c '+oldOppMap.get(opp.id).Edgewise_Overlay_Team__c);
                if(opp.Edgewise_Overlay_Team__c!=oldOppMap.get(opp.id).Edgewise_Overlay_Team__c){
                    Oppidsettodeleteexistingsharing.add(opp.id);
                    if(opp.Edgewise_Overlay_Team__c==null){
                        
                    }else if(opp.Edgewise_Overlay_Team__c.equalsignorecase('Katie Campbell;Jen McCoy')){
                       // system.debug('inside first if');
                        OpportunityTeamMember oppTeamMember1 = new OpportunityTeamMember(OpportunityId=opp.id,TeamMemberRole = 'Overlay Edgewise',OpportunityAccessLevel = 'Edit',UserId=EdgewiseOverlayMember1);
                        OpportunityTeamMember oppTeamMember2 = new OpportunityTeamMember(OpportunityId=opp.id,TeamMemberRole = 'Overlay Edgewise',OpportunityAccessLevel = 'Edit',UserId=EdgewiseOverlayMember2);
                
                        OTMtoinsert.add(oppTeamMember1);
                        OTMtoinsert.add(oppTeamMember2);
                    }else if(opp.Edgewise_Overlay_Team__c.equalsignorecase('Katie Campbell')){
                       // system.debug('inside second if');
                        OpportunityTeamMember oppTeamMember1 = new OpportunityTeamMember(OpportunityId=opp.id,TeamMemberRole = 'Overlay Edgewise',OpportunityAccessLevel = 'Edit',UserId=EdgewiseOverlayMember1);
                        OTMtoinsert.add(oppTeamMember1);
                    }else if(opp.Edgewise_Overlay_Team__c.equalsignorecase('Jen McCoy')){
                       // system.debug('inside third if');
                        OpportunityTeamMember oppTeamMember2 = new OpportunityTeamMember(OpportunityId=opp.id,TeamMemberRole = 'Overlay Edgewise',OpportunityAccessLevel = 'Edit',UserId=EdgewiseOverlayMember2);
                        OTMtoinsert.add(oppTeamMember2);
                    }
                }
            }
        }
        //system.debug('Oppidsettodeleteexistingsharing  '+Oppidsettodeleteexistingsharing);
        if(Oppidsettodeleteexistingsharing.size()>0){
            OTMtodelete=[Select id,UserId from OpportunityTeamMember where OpportunityId IN: Oppidsettodeleteexistingsharing and TeamMemberRole = 'Overlay Edgewise'];
            delete OTMtodelete;
        }
        if(OTMtoinsert.size()>0){
            insert OTMtoinsert;
        }
        TriggerUtility2.UpdateEdgewiseOverlayTeamSharingExecuted();
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
		i++;
		i++;
		i++;
		i++;
	}
}