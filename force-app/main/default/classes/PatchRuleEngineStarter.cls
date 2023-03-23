global class PatchRuleEngineStarter
{
    private static Set<Id> globalPipeline = new Set<Id>();
    private List<Id> currentPipeline = new List<Id>();
    
    global PatchRuleEngineStarter(List<Id> recordIds)
    {
        Set<Id> dedup = new Set<Id>(recordIds);
        currentPipeline.addAll(dedup);
    }
    
    global void start()
    {
        globalPipeline.addAll(currentPipeline);
        /*
        if(currentPipeline.size() <= 10)
        {
            assignPatch(currentPipeline);
        }
        else
        {
            InnerJob job = new InnerJob(currentPipeline);
            System.enqueueJob(job);
        }
        */
        if(currentPipeline.size() > 0)
        {
            InnerJob job = new InnerJob(currentPipeline);
            System.enqueueJob(job);
        }   
    }
    
    public static Boolean isInPipeline(Id recordId)
    {
        return globalPipeline.contains(recordId);
    }
    
    private void assignPatch(List<Id> recordIds)
    {
        if(recordIds == null || recordIds.size() == 0)
        {
            return;
        }
        List<sObject> objs = PatchRuleHelper.getSObjects(recordIds);
        SavePoint sp = Database.setSavePoint();
        List<sObject> sharingsAndTeams = assignPatches(objs);
        List<sObject> existingSharesAndTeams = getExistingSharings(objs);
        if(objs.size() > 0)
        {
            try 
            {
                update objs;
                //Added By Anup : CR#1091 - Start
                SObject singleItem;
                if(!existingSharesAndTeams.isEmpty()){
                    singleItem = existingSharesAndTeams[0];
                    if(singleItem instanceOf AccountTeamMember){
                        List<AccountTeamMember> storedAccountTeam = new List<AccountTeamMember>();
                        for(SObject act : existingSharesAndTeams){
                            System.debug('act '+ act);
                            if(act.get('TeamMemberRole') != 'Account Manager'){
                                AccountTeamMember accountTeamMember1 = new AccountTeamMember();
                                accountTeamMember1.put('UserId', act.get('UserId'));
                                accountTeamMember1.put('TeamMemberRole', act.get('TeamMemberRole'));
                                accountTeamMember1.put('AccountAccessLevel', act.get('AccountAccessLevel'));
                                accountTeamMember1.put('OpportunityAccessLevel', act.get('OpportunityAccessLevel'));
                                accountTeamMember1.put('CaseAccessLevel', act.get('CaseAccessLevel'));
                                accountTeamMember1.put('ContactAccessLevel', act.get('ContactAccessLevel'));
                                accountTeamMember1.put('AccountId',act.get('AccountId'));
                                storedAccountTeam.add((AccountTeamMember)accountTeamMember1); 
                            }
                            
                        }
                        if(!storedAccountTeam.isEmpty()){
                            Database.insert(storedAccountTeam, false);
                            sharingsAndTeams = assignPatches(objs);
                            existingSharesAndTeams.clear();
                            existingSharesAndTeams.addAll(storedAccountTeam);
                            System.debug('storedAccountTeam '+storedAccountTeam);
                            System.debug('storedAccountTeam '+sharingsAndTeams);
                        }
                    }
                }
                //Added By Anup : CR#1091 - End
                
                //Realgin AccountTeamMember / LeadShare
                PatchRuleHelper.mergeTeamMembers(sharingsAndTeams, PatchRuleHelper.getExistingSharingsToDelete(existingSharesAndTeams), existingSharesAndTeams);
                if(!System.isBatch())
                {
                    System.debug('inside mergeTeamMembers');
                    //Assign team members to related opportunities 
                    if(objs[0] instanceOf Account)
                    {
                        Integer numberOfOpps = PatchRuleHelper.countOpportunity(recordIds);
                        if(numberOfOpps < 10)
                        {
                            //add Opportunity Incremental Change code here and commentout the code. Tomorrow Zscaler Dev team will test the changes
                            //less than 10 opportunities, go within same transaction
                            PatchRuleHelper.assignSalesTeamMembers(recordIds, 'Account');    
                        }
                        else
                        {
                            //more than 10 opps, open an job. Disable following 3 lines and use the logic above to test realign opps in same transaction
                            List<schema.SObjectType> sObjTypes = new List<Schema.SObjectType>{Schema.Opportunity.SObjectType};
                            PatchRealignJob job = new PatchRealignJob(recordIds, sObjTypes, true);
                            Database.executeBatch(job, 10);
                        }
                    }
                }
                else {
                    //batch job here
                    //PatchRuleHelper.mergeTeamMembers(sharingsAndTeams, PatchRuleHelper.getExistingSharingsToDelete(existingSharesAndTeams));
                    //opp team member are handled by a separate PatchRealginJob
                }
            }
            catch(Exception ex)
            {
                Database.rollback(sp);
                PatchRuleHelper.logError(ex);
                if(objs[0] instanceOf Account)
                {
                    update failedToRealign(objs);
                }
            }  
        }
    }
    
    private List<sObject> assignPatches(List<sObject> objs)
    {
        Map<Id, PatchDataModel.PatchInfo> patches = new Map<Id, PatchDataModel.PatchInfo>();
        List<PatchDataModel.PatchInfo> patchlst = PatchRuleHelper.getPatches();
        Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping = getObject2Role2Mapping();
        for(PatchDataModel.PatchInfo patch : patchlst)
        {
            patches.put(patch.PatchId, patch);
        }
        List<sObject> sharingsAndTeams = new List<sObject>();
        for(sObject obj : objs)
        {
            PatchDataModel.PatchInfo patch = null;
            if((Boolean)obj.get(PatchRuleHelper.NamespacePrefix + 'PatchLocked__c'))
            {
                //if a record is locked, we keep the patch member up to date, leave the patch unchanged
                patch = patches.get((Id)obj.get(PatchRuleHelper.NamespacePrefix + 'Patch__c'));
            }
            else
            {
                PatchDataModel.MatchTarget target = new PatchDataModel.MatchTarget(obj);
                patch = matchPatch(target);
            }
            sharingsAndTeams.addAll(assignPatch(obj, patch, object2Role2Mapping));
        }
        return sharingsAndTeams;
    }
    
    @testvisible
    private List<sObject> assignPatch(sObject obj, PatchDataModel.PatchInfo patch, Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping)
    { 
        String objType = obj.getSObjectType().getDescribe().getName();
        globalPipeline.add(obj.Id);
        if(patch != null)
        {
            obj.put(PatchRuleHelper.NamespacePrefix + 'Patch__c', patch.PatchId);
            PatchDataModel.PatchConfig config = PatchRuleHelper.getConfig();
            if(config.roles.containsKey(objType))
            {
                for(PatchDataModel.TeamMemberRoleConfig memberConfig : config.roles.get(objType))
                {
                    if(String.isNotBlank(memberConfig.fieldName))
                    {
                        if(obj instanceOf Lead)
                        {
                            obj.put(memberConfig.fieldName, null);
                        }
                    }
                    for(PatchDataModel.TeamMemberInfo member : patch.members)
                    {
                        if(member.role == memberConfig.role)
                        {
                            if(String.isNotBlank(memberConfig.fieldName))
                            {
                                if(obj instanceOf Lead)
                                {
                                    obj.put(memberConfig.fieldName, member.userId);
                                }
                            }
                            if(memberConfig.assignOwnership == true)
                            {
                                obj.put('OwnerId', member.userId);
                            }
                            break;
                        }
                    }
                }
            }
            if(obj instanceOf Opportunity)
            {
                Opportunity opportunity = (Opportunity)obj;
                opportunity.Patch__c = patch.PatchId;
                opportunity.PatchLocked__c = opportunity.Account.PatchLocked__c;
            }
        }
        else
        {
            obj.put(PatchRuleHelper.NamespacePrefix + 'Patch__c', null);
            PatchDataModel.PatchConfig config = PatchRuleHelper.getConfig();
            if(config.roles.containsKey(objType))
            {
                for(PatchDataModel.TeamMemberRoleConfig memberConfig : config.roles.get(objType))
                {
                    if(memberConfig.fieldName != 'OwnerId' && String.isNotBlank(memberConfig.fieldName))
                    {
                        if(obj instanceOf Lead)
                        {
                            obj.put(memberConfig.fieldName, null);
                        }
                    }
                }
            }            
        }
        obj.put(PatchRuleHelper.NamespacePrefix + 'TriggerPatchAssignment__c', false);
        return newPatchSharing(obj, patch, object2Role2Mapping);
    }
    
    @testvisible
    private List<sObject> newPatchSharing(sObject obj, PatchDataModel.PatchInfo patch, Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping)
    {
        List<sObject> result = new List<sObject>();
        List<PatchDataModel.TeamMemberInfo> CSMandTAMMembertoremove= new List<PatchDataModel.TeamMemberInfo>();
        if(patch != null)
        { 
            if(obj instanceOf Lead)
            {
                Lead ld = (Lead)obj;
                SObjectType leadShareType = PatchRuleHelper.getSObjectType('LeadShare');
                if(leadShareType != null && leadShareType.getDescribe().isCreateable())
                {
                    for(PatchDataModel.TeamMemberInfo member : patch.Members)
                    {
                        SObject leadShare = leadShareType.newSObject();
                        leadShare.put('LeadId', ld.Id);
                        leadShare.put('UserOrGroupId', member.UserId);
                        leadShare.put('LeadAccessLevel', 'Edit');
                        result.add(leadShare);
                    }
                }
            }
            else if(obj instanceOf Account)
            {
                Account acc = (Account)obj;
                Set<String> CSMandTAMRoleSet= new Set<String>{'Customer Success Manager','Technical Account Manager'};
                SObjectType accountTeamMemberType = PatchRuleHelper.getSObjectType('AccountTeamMember');
                if(accountTeamMemberType != null && accountTeamMemberType.getDescribe().isCreateable())
                {
                    for(PatchDataModel.TeamMemberInfo member : patch.Members)
                    {
                        if(object2Role2Mapping.containsKey('Account') && object2Role2Mapping.get('Account').containsKey(member.role))
                        {
                            PatchFieldMapping__c mapping = object2Role2Mapping.get('Account').get(member.role);
                            if(mapping.Field__c != null)
                            {
                                SObject accountTeamMember = accountTeamMemberType.newSObject();
                                accountTeamMember.put('AccountId', acc.Id);
                                accountTeamMember.put('UserId', member.UserId);
                                accountTeamMember.put('TeamMemberRole', mapping.Field__c);
                                accountTeamMember.put('AccountAccessLevel', mapping.Account_Access__c);
                                accountTeamMember.put('OpportunityAccessLevel', mapping.Opportunity_Access__c);
                                accountTeamMember.put('CaseAccessLevel', mapping.Case_Access__c);
                                accountTeamMember.put('ContactAccessLevel', mapping.Contact_Access__c);
                                result.add(accountTeamMember);    
								if(CSMandTAMRoleSet.contains(member.role)){
                                    system.debug('inside logic to remove CSM and TAM');
                                    CSMandTAMMembertoremove.add(member);
                                }
                            }
                        }
                    }
					for(PatchDataModel.TeamMemberInfo member :  CSMandTAMMembertoremove){
                        if(patch.Members.indexof(member)!=-1){
                        patch.Members.remove(patch.Members.indexof(member));
                        }
                    }
                }
            }
            //CR#-5089-Start
             else if(obj instanceOf Opportunity)
             {
                Opportunity opp = (Opportunity)obj;
                Set<String> CSMandTAMRoleSet= new Set<String>{'Customer Success Manager','Technical Account Manager'};
                SObjectType oppTeamMemberType = PatchRuleHelper.getSObjectType('OpportunityTeamMember');
                if(oppTeamMemberType != null && oppTeamMemberType.getDescribe().isCreateable())
                {
                    for(PatchDataModel.TeamMemberInfo member : patch.Members)
                    {
                        if(object2Role2Mapping.containsKey('Opportunity') && object2Role2Mapping.get('Opportunity').containsKey(member.role))
                        {
                            PatchFieldMapping__c mapping = object2Role2Mapping.get('Opportunity').get(member.role);
                            if(mapping.Field__c != null)
                            {
                                 SObject oppTeamMember = oppTeamMemberType.newSObject();
                                 oppTeamMember.put('OpportunityId', opp.Id);
                                 oppTeamMember.put('UserId', member.UserId);
                                 oppTeamMember.put('TeamMemberRole', mapping.Field__c);
                                 oppTeamMember.put('OpportunityAccessLevel', mapping.Opportunity_Access__c);
                                 result.add(oppTeamMember);
                                 if(CSMandTAMRoleSet.contains(member.role)){
                                    system.debug('inside logic to remove CSM and TAM');
                                    CSMandTAMMembertoremove.add(member);
                                }
                            }
                        }
                    }
                    for(PatchDataModel.TeamMemberInfo member :  CSMandTAMMembertoremove){
                        if(patch.Members.indexof(member)!=-1){
                        patch.Members.remove(patch.Members.indexof(member));
                        }
                    } 
                 }
             }  //CR#-5089-End
        }
        return result;
    }

    @testvisible
    private Map<String, Map<String, PatchFieldMapping__c>> getObject2Role2Mapping()
    {
        Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping = new Map<String, Map<String, PatchFieldMapping__c>>();
        for(PatchFieldMapping__c mapping : PatchFieldMapping__c.getAll().values())
        {
            if(mapping.Type__c == 'Role')
            {
                if(!object2Role2Mapping.containsKey(mapping.Object__c))
                {
                    object2Role2Mapping.put(mapping.Object__c, new Map<String, PatchFieldMapping__c>{mapping.Value__c => mapping});
                }
                else 
                {
                    object2Role2Mapping.get(mapping.Object__c).put(mapping.Value__c, mapping);
                }
            }
        }
        return object2Role2Mapping;
    }
    
    private List<sObject> getExistingSharings(List<sObject> objs)
    {
        List<sObject> result = new List<sObject>();
        if(objs.size() > 0)
        {
            sObject obj = objs[0];
            if(obj instanceOf Lead)
            {
                SObjectType leadShareType = PatchRuleHelper.getSObjectType('LeadShare');
                if(leadShareType != null && leadShareType.getDescribe().isQueryable())
                {
                    return Database.query('select Id from LeadShare where LeadId in :objs');
                }
            }
            else if(obj instanceOf Account)
            {
                List<Id> patchUnlockedAccs = PatchRuleHelper.getPatchUnlockedObjIds(objs);
                SObjectType accountTeamMemberType = PatchRuleHelper.getSObjectType('AccountTeamMember');
                if(accountTeamMemberType != null && accountTeamMemberType.getDescribe().isQueryable())
                {
                    return Database.query('select Id, UserId, AccountId, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel from AccountTeamMember where AccountId in :objs');
                }
            }
            else if(obj instanceOf Opportunity)
            {
                SObjectType oppTeamMemberType = PatchRuleHelper.getSObjectType('OpportunityTeamMember');
                if(oppTeamMemberType != null && oppTeamMemberType.getDescribe().isQueryable())
                {
                    return Database.query('select Id, UserId, OpportunityId, OpportunityAccessLevel, TeamMemberRole from OpportunityTeamMember where OpportunityId in :objs');
                }
            }
        }
        return result;
    }

    private static PatchDataModel.PatchInfo matchPatch(PatchDataModel.MatchTarget target)
    {
        PatchDataModel.PatchInfo matchedPatch = null;
        Set<Id> overlayMatches = new Set<Id>();
        for(Integer i = 0; i < 9999; i++)
        {
            String engineClassName = 'PatchRuleEngine' + (i == 0 ? '' : String.valueOf(i));
            Type engineType = Type.forName('', engineClassName);
            if(engineType != null)
            {
                IPatchRuleEngine engine = (IPatchRuleEngine)engineType.newInstance();
                if(engine instanceOf PatchRuleEngineBase)
                {
                    ((PatchRuleEngineBase)engine).overlayingPatchIds.addAll(overlayMatches);
                }
                matchedPatch = engine.match(target);
                if(engine instanceOf PatchRuleEngineBase)
                {
                    overlayMatches.addAll(((PatchRuleEngineBase)engine).overlayingPatchIds);
                }
                if(matchedPatch != null && matchedPatch.patchId != null) break;
            }
            else
            {
                break;
            }
        }

        return matchedPatch;
    }
    @testvisible
    private List<sObject> failedToRealign(List<sObject> objs)
    {
        for(sObject obj : objs)
        {
            obj.put('Patch_Assignment_Failed__c', true);
            obj.put('TriggerPatchAssignment__c', false);  
        }
        return objs;
    }

    public class InnerJob implements Queueable
    {
        private List<Id> currentBatch;
        private List<Id> pipeline;
        
        public InnerJob(List<Id> records)
        {
            if(records != null)
            {
                if(records.size() <= 1)
                {
                    currentBatch = new List<Id>(records);
                    pipeline = null;
                }
                else
                {
                    currentBatch = new List<Id>();
                    pipeline = new List<Id>();
                    for(Integer i = 0; i < records.size(); i++)
                    {
                        if(i < 1)
                        {
                            currentBatch.add(records[i]);
                        }
                        else
                        {
                            pipeline.add(records[i]);
                        }
                    }
                }
            }
        }
        
        public void execute(QueueableContext context) 
        {
            if(currentBatch != null)
            {
                PatchRuleEngineStarter starter = new PatchRuleEngineStarter(currentBatch);
                starter.assignPatch(currentBatch);
            }
            if(pipeline != null && !test.isRunningTest())
            {
                System.enqueueJob(new InnerJob(pipeline));
            }
        }
    }
    
    public class EmptyEngine implements IPatchRuleEngine
    {
        public PatchDataModel.PatchInfo match(PatchDataModel.MatchTarget t)
        {
            return null;
        }
    }

//Booster class removed : CR 1415  
}