public without sharing class AmberRoadValidation {
    
    public static List<ScreeningStatusWrapper> checkOppPartnerAccComplianceScreeningStatus(Map<Id, Opportunity> checkOppComplianceStatusMap){
        
        List<ScreeningStatusWrapper> screeningStatusWrapperList = new List<ScreeningStatusWrapper>();
        
        for(Opportunity_Partner__c oppPartRecord : [SELECT Id,Name,
                                                    Opportunity__c,
                                                    Opportunity__r.AccountId,
                                                    Opportunity__r.Account.Amber_Road_Status__c,
                                                    Opportunity__r.Primary_Reseller_Partner__c,
                                                    Opportunity__r.Primary_Reseller_Partner__r.Amber_Road_Status__c,
                                                    Account__c,
                                                    Account__r.Name,
                                                    Account__r.Amber_Road_Status__c,
                                                    Account__r.Is_Federal_Account_Sync__c
                                                    FROM Opportunity_Partner__c 
                                                    WHERE Opportunity__c IN : checkOppComplianceStatusMap.keySet()]){
                                                        if(!oppPartRecord.Account__r.Is_Federal_Account_Sync__c && 
                                                           (oppPartRecord.Account__r.Amber_Road_Status__c == 'Potential Match' || 
                                                            oppPartRecord.Account__r.Amber_Road_Status__c == 'Match')){
                                                                ScreeningStatusWrapper screeningStatusWrapperObj = new ScreeningStatusWrapper();
                                                                screeningStatusWrapperObj.isFlagged = TRUE;
                                                                screeningStatusWrapperObj.screeningStatus = oppPartRecord.Account__r.Amber_Road_Status__c;
                                                                screeningStatusWrapperObj.oppPartnerAccountName = oppPartRecord.Account__r.Name;
                                                                screeningStatusWrapperObj.oppotunityRecord = checkOppComplianceStatusMap.get(oppPartRecord.Opportunity__c);
                                                                
                                                                screeningStatusWrapperList.add(screeningStatusWrapperObj);
                                                            }
                                                    }                
        return screeningStatusWrapperList;        
    }
    
    public static PRScreeningWrapper checkPRComplianceStatusForOppotunity(Id opportunityRecordId){
        System.debug('CR# 4395 opportunityRecordId : ' + opportunityRecordId);
        PRScreeningWrapper prScreeningWrapperObj = new PRScreeningWrapper();
        if(opportunityRecordId != NULL){
            for(Opportunity oppRecord : [SELECT Id,Name,
                                         Primary_Reseller_Partner__c,
                                         Primary_Reseller_Partner__r.Name,
                                         Primary_Reseller_Partner__r.Amber_Road_Status__c,
                                         Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c,
                                         AccountId,
                                         Account.Name,
                                         Account.Amber_Road_Status__c,
                                         Account.Is_Federal_Account_Sync__c
                                         FROM Opportunity
                                         WHERE Id =: opportunityRecordId]){
                                             System.debug('CR# 4395 oppRecord : ' + oppRecord);                              
                                             if(!oppRecord.Account.Is_Federal_Account_Sync__c && 
                                                (oppRecord.Account.Amber_Road_Status__c == 'Potential Match' || 
                                                 oppRecord.Account.Amber_Road_Status__c == 'Match')){
                                                     prScreeningWrapperObj.isAccOrOppCompliant = FALSE;
                                                     prScreeningWrapperObj.nonCompliantAccountName = oppRecord.Account.Name;
                                                     prScreeningWrapperObj.nonCompliantAccountType = 'Opportunity\'s account';
                                                     break;
                                                 }
                                             if(!oppRecord.Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c && 
                                                (oppRecord.Primary_Reseller_Partner__r.Amber_Road_Status__c == 'Potential Match' || 
                                                 oppRecord.Primary_Reseller_Partner__r.Amber_Road_Status__c == 'Match')){
                                                     prScreeningWrapperObj.isAccOrOppCompliant = FALSE;
                                                     prScreeningWrapperObj.nonCompliantAccountName = oppRecord.Primary_Reseller_Partner__r.Name;
                                                     prScreeningWrapperObj.nonCompliantAccountType = 'Opportunity primary reseller partner account';
                                                     break;
                                                 }                                              
                                         }
            System.debug('CR# 4395 prScreeningWrapperObj BEFORE OppPartner Check : ' + prScreeningWrapperObj);  
            if(prScreeningWrapperObj.isAccOrOppCompliant){
                for(Opportunity_Partner__c oppPartRecord : [SELECT Id,Name,
                                                            Opportunity__c,
                                                            Opportunity__r.AccountId,
                                                            Opportunity__r.Account.Name,
                                                            Opportunity__r.Account.Amber_Road_Status__c,
                                                            Opportunity__r.Account.Is_Federal_Account_Sync__c,
                                                            Opportunity__r.Primary_Reseller_Partner__c,
                                                            Opportunity__r.Primary_Reseller_Partner__r.Name,   
                                                            Opportunity__r.Primary_Reseller_Partner__r.Amber_Road_Status__c,
                                                            Opportunity__r.Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c,
                                                            Account__c,
                                                            Account__r.Name,
                                                            Account__r.Amber_Road_Status__c,
                                                            Account__r.Is_Federal_Account_Sync__c
                                                            FROM Opportunity_Partner__c 
                                                            WHERE Opportunity__c =: opportunityRecordId]){
                                                                System.debug('CR# 4395 oppPartRecord : ' + oppPartRecord);                                               
                                                                if(!oppPartRecord.Account__r.Is_Federal_Account_Sync__c && 
                                                                   (oppPartRecord.Account__r.Amber_Road_Status__c == 'Potential Match' || 
                                                                    oppPartRecord.Account__r.Amber_Road_Status__c == 'Match')){
                                                                        prScreeningWrapperObj.isAccOrOppCompliant = FALSE;
                                                                        prScreeningWrapperObj.nonCompliantAccountName = oppPartRecord.Account__r.Name;
                                                                        prScreeningWrapperObj.nonCompliantAccountType = 'Opportunity partner account';
                                                                        break;
                                                                    }                                            
                                                            } 
            }
            
        }
        System.debug('CR# 4395 prScreeningWrapperObj : ' + prScreeningWrapperObj);
        return prScreeningWrapperObj;
    }
    
    public static PRScreeningWrapper checkPRComplianceStatusForAccount(Id accountRecordId){
        System.debug('CR# 4395 accountRecordId : ' + accountRecordId);
        PRScreeningWrapper prScreeningWrapperObj = new PRScreeningWrapper();
        if(accountRecordId != NULL){
            for(Account accRecord : [SELECT Id,Name,
                                     Amber_Road_Status__c,
                                     Is_Federal_Account_Sync__c
                                     FROM Account
                                     WHERE Id =: accountRecordId]){
                                         System.debug('CR# 4395 accRecord : ' + accRecord);                          
                                         if(!accRecord.Is_Federal_Account_Sync__c && 
                                            (accRecord.Amber_Road_Status__c == 'Potential Match' || 
                                             accRecord.Amber_Road_Status__c == 'Match')){
                                                 prScreeningWrapperObj.isAccOrOppCompliant = FALSE;
                                                 prScreeningWrapperObj.nonCompliantAccountName = accRecord.Name;
                                                 prScreeningWrapperObj.nonCompliantAccountType = 'Account';
                                                 break;
                                             }                                           
                                     }            
        }
        System.debug('CR# 4395 prScreeningWrapperObj : ' + prScreeningWrapperObj);
        return prScreeningWrapperObj;
    }
    
    public static void checkPRComplianceStatusOnUpdate(List<Provisioning_Request__c> newPRRecordList){
        
        System.debug('CR# 4395 newPRRecordList : ' + newPRRecordList);       
        
        //Get loggedIn User Profile
        List<Profile> loggedInUserProflie = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String loggedInUserProflieName = loggedInUserProflie[0].Name;
        System.debug('CR# 4395 loggedInUserProflieName ' + loggedInUserProflieName);
        
        Map<Id,Provisioning_Request__c> prWithRelatedFieldMap = getPRRelatedFieldValues(newPRRecordList);
        System.debug('CR# 4395 prWithRelatedFieldMap ' + prWithRelatedFieldMap);
        
        Map<Id, Opportunity> checkOppPartnerComplianceStatusMap;
        Map<Id,Id> opportunityIdPRIdMap = new Map<Id,Id>();
        
        for(Provisioning_Request__c newPRRecord : newPRRecordList){
            //CR# 4395 START 4th April 2022 - Bikram AmberRoadValidation            
            System.debug('CR# 4395 newPRRecord ' + newPRRecord);
            System.debug('CR# 4395 prWithRelatedFieldMap containsKey ' + prWithRelatedFieldMap.containsKey(newPRRecord.Id));
            if(prWithRelatedFieldMap.containsKey(newPRRecord.Id) && loggedInUserProflieName != 'System Administrator'
              ){
                  if(!prWithRelatedFieldMap.get(newPRRecord.Id).Account__r.Is_Federal_Account_Sync__c && 
                     (prWithRelatedFieldMap.get(newPRRecord.Id).Account__r.Amber_Road_Status__c == 'Potential Match' || 
                      prWithRelatedFieldMap.get(newPRRecord.Id).Account__r.Amber_Road_Status__c == 'Match')
                    ){
                        newPRRecord.addError('ERROR : \"' + 
                                             prWithRelatedFieldMap.get(newPRRecord.Id).Account__r.Name + 
                                             '\" account has been blocked by export compliance screening.' + 
                                             ' Contact dplscreening@zscaler.com who can help review this account.');
                    }
                  else if(!prWithRelatedFieldMap.get(newPRRecord.Id).Opportunity__r.Account.Is_Federal_Account_Sync__c && 
                          (prWithRelatedFieldMap.get(newPRRecord.Id).Opportunity__r.Account.Amber_Road_Status__c == 'Potential Match' ||
                           prWithRelatedFieldMap.get(newPRRecord.Id).Opportunity__r.Account.Amber_Road_Status__c == 'Match')
                         ){
                             newPRRecord.addError('ERROR : Related opportunity\'s account \"' + 
                                                  prWithRelatedFieldMap.get(newPRRecord.Id).Opportunity__r.Account.Name + 
                                                  '\" has been blocked by export compliance screening.' + 
                                                  ' Contact dplscreening@zscaler.com who can help review this account.');
                         }
                  else if(!prWithRelatedFieldMap.get(newPRRecord.Id).Opportunity__r.Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c && 
                          (prWithRelatedFieldMap.get(newPRRecord.Id).Opportunity__r.Primary_Reseller_Partner__r.Amber_Road_Status__c == 'Potential Match' ||
                           prWithRelatedFieldMap.get(newPRRecord.Id).Opportunity__r.Primary_Reseller_Partner__r.Amber_Road_Status__c == 'Match')
                         ){
                             newPRRecord.addError('ERROR : Related opportunity\'s primary reseller partner account \"' + 
                                                  prWithRelatedFieldMap.get(newPRRecord.Id).Opportunity__r.Primary_Reseller_Partner__r.Name + 
                                                  '\" has been blocked by export compliance screening.' + 
                                                  ' Contact dplscreening@zscaler.com who can help review this account.');
                         }
                  else {
                      opportunityIdPRIdMap.put(prWithRelatedFieldMap.get(newPRRecord.Id).Opportunity__c,newPRRecord.Id);
                  }
              }                  
            //CR# 4395 END 4th April 2022 - Bikram AmberRoadValidation
        }
        
        if(!opportunityIdPRIdMap.isEmpty()){
            checkOppPartnerComplianceStatusMap = new Map<Id,Opportunity>([SELECT Id 
                                                                          FROM Opportunity
                                                                          WHERE Id IN :opportunityIdPRIdMap.keySet()]);
        }
        
        //CR# 4395 START 4th April 2022 - Bikram AmberRoadValidation
        System.debug('CR# 4395 checkOppPartnerComplianceStatusMap ' + checkOppPartnerComplianceStatusMap);
        if(checkOppPartnerComplianceStatusMap != NULL && !checkOppPartnerComplianceStatusMap.isEmpty()){
            List<AmberRoadValidation.ScreeningStatusWrapper> oppPartnerComplianceStatus = 
                AmberRoadValidation.checkOppPartnerAccComplianceScreeningStatus(checkOppPartnerComplianceStatusMap);
            System.debug('CR# 4395 oppPartnerComplianceStatus ' + oppPartnerComplianceStatus);
            if(!oppPartnerComplianceStatus.isEmpty()){
                for(Provisioning_Request__c newPRRecord : newPRRecordList){
                    for(AmberRoadValidation.ScreeningStatusWrapper wrapperRecord : oppPartnerComplianceStatus){
                        System.debug('CR# 4395 wrapperRecord ' + wrapperRecord);
                        if(wrapperRecord.isFlagged && newPRRecord.Id == wrapperRecord.oppotunityRecord.Id){
                            newPRRecord.addError(
                                'ERROR : ' + 'Opportunity Partner Account \"' + 
                                wrapperRecord.oppPartnerAccountName + 
                                '\" has been blocked by export compliance screening.' + 
                                ' Contact dplscreening@zscaler.com who can help review this account.');
                        }
                    }
                }
            }                
        }
        //CR# 4395 END 4th April 2022 - Bikram AmberRoadValidation
    }
    
    public static void checkPRComplianceStatusOnInsert(List<Provisioning_Request__c> newPRRecordList){
        System.debug('CR# 4395 newPRRecordList : ' + newPRRecordList);
        //Get loggedIn User Profile
        List<Profile> loggedInUserProflie = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String loggedInUserProflieName = loggedInUserProflie[0].Name;
        System.debug('CR# 4395 loggedInUserProflieName ' + loggedInUserProflieName);
        if(loggedInUserProflieName != 'System Administrator'){
            List<PRAccOppScreenStatusWrapper> pRAccOppScreenStatusWrapperObj = getAcc_Opp_OppPartner_ScreenStatus(newPRRecordList);
            System.debug('CR# 4395 pRAccOppScreenStatusWrapperObj : ' + pRAccOppScreenStatusWrapperObj);
            for(PRAccOppScreenStatusWrapper pRAccOppScreenStatusWrapper : pRAccOppScreenStatusWrapperObj){
                System.debug('CR# 4395 pRAccOppScreenStatusWrapper : ' + pRAccOppScreenStatusWrapper);
                if(pRAccOppScreenStatusWrapper.isFlagged){
                    pRAccOppScreenStatusWrapper.prRecord.addError('ERROR : ' + 
                                                                  pRAccOppScreenStatusWrapper.accountType + ' \"' +
                                                                  pRAccOppScreenStatusWrapper.flaggedAccountName + 
                                                                  '\" has been blocked by export compliance screening.' + 
                                                                  ' Contact dplscreening@zscaler.com who can help review this account.');
                }
            } 
        }        
    }
    
    private static Map<Id,Provisioning_Request__c> getPRRelatedFieldValues(List<Provisioning_Request__c> newPRRecordList){
        
        return new Map<Id,Provisioning_Request__c>([SELECT ID,
                                                    Account__c,
                                                    Account__r.Name,
                                                    Account__r.Amber_Road_Status__c,                                        
                                                    Account__r.Is_Federal_Account_Sync__c,
                                                    Opportunity__c,
                                                    Opportunity__r.Name, 
                                                    Opportunity__r.AccountId,
                                                    Opportunity__r.Account.Name,
                                                    Opportunity__r.Account.Amber_Road_Status__c,
                                                    Opportunity__r.Account.Is_Federal_Account_Sync__c,                                       
                                                    Opportunity__r.Primary_Reseller_Partner__c,
                                                    Opportunity__r.Primary_Reseller_Partner__r.Name,
                                                    Opportunity__r.Primary_Reseller_Partner__r.Amber_Road_Status__c,                                        
                                                    Opportunity__r.Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c
                                                    FROM Provisioning_Request__c 
                                                    WHERE Id IN :newPRRecordList LIMIT 50000]);
    }
   
    //Before Insert of PR
    private static List<PRAccOppScreenStatusWrapper> getAcc_Opp_OppPartner_ScreenStatus(List<Provisioning_Request__c> newPRRecordList){
        
        List<PRAccOppScreenStatusWrapper> pRAccOppScreenStatusWrapperList = new List<PRAccOppScreenStatusWrapper>();
        Map<Id,Provisioning_Request__c> accountIdPRRecordMap = new Map<Id,Provisioning_Request__c>();
        Map<Id,Provisioning_Request__c> opportunityIdPRRecordMap = new Map<Id,Provisioning_Request__c>();
        for(Provisioning_Request__c newPRRecord : newPRRecordList){
            if(newPRRecord.Account__c != NULL){
                accountIdPRRecordMap.put(newPRRecord.Account__c,newPRRecord);
            }
            if(newPRRecord.Opportunity__c != NULL){
                opportunityIdPRRecordMap.put(newPRRecord.Opportunity__c,newPRRecord);
            }
        }
        System.debug('CR# 4395 accountIdPRRecordMap : ' + accountIdPRRecordMap);
        System.debug('CR# 4395 opportunityIdPRRecordMap : ' + opportunityIdPRRecordMap);
        if(!accountIdPRRecordMap.isEmpty() && !accountIdPRRecordMap.keySet().isEmpty()){
            for(Account accRecord : [SELECT ID,Name,Is_Federal_Account_Sync__c,Amber_Road_Status__c
                                     FROM Account 
                                     WHERE Id IN :accountIdPRRecordMap.keySet() LIMIT 50000])
            {                             
                if(!accRecord.Is_Federal_Account_Sync__c && 
                   (accRecord.Amber_Road_Status__c == 'Potential Match' || 
                    accRecord.Amber_Road_Status__c == 'Match'))
                {
                    PRAccOppScreenStatusWrapper pRAccOppScreenStatusWrapperObj = new PRAccOppScreenStatusWrapper();
                    pRAccOppScreenStatusWrapperObj.isFlagged = TRUE;
                    pRAccOppScreenStatusWrapperObj.accountRecordMap = new Map<Id,Account>{accRecord.Id => accRecord};
                    pRAccOppScreenStatusWrapperObj.flaggedAccountName = accRecord.Name;
                    pRAccOppScreenStatusWrapperObj.accountType = 'Account';
                    if(accountIdPRRecordMap.containsKey(accRecord.Id)){
                        pRAccOppScreenStatusWrapperObj.prRecord = accountIdPRRecordMap.get(accRecord.Id);
                    }
                    
                    pRAccOppScreenStatusWrapperList.add(pRAccOppScreenStatusWrapperObj);
                }
            }
            if(!pRAccOppScreenStatusWrapperList.isEmpty())
            {
                System.debug('CR# 4395 pRAccOppScreenStatusWrapperList : ' + pRAccOppScreenStatusWrapperList);
                return pRAccOppScreenStatusWrapperList;
            }
        }
        if(!opportunityIdPRRecordMap.isEmpty() && !opportunityIdPRRecordMap.keySet().isEmpty()){
            for(Opportunity oppRecord : [SELECT ID,
                                         AccountId,
                                         Account.Name,
                                         Account.Amber_Road_Status__c,                                        
                                         Account.Is_Federal_Account_Sync__c,                                      
                                         Primary_Reseller_Partner__c,
                                         Primary_Reseller_Partner__r.Name,
                                         Primary_Reseller_Partner__r.Amber_Road_Status__c,                                        
                                         Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c
                                         FROM Opportunity 
                                         WHERE Id IN :opportunityIdPRRecordMap.keySet() LIMIT 50000])
            {
                System.debug('CR# 4395 oppRecord : ' + oppRecord);
                if(!oppRecord.Account.Is_Federal_Account_Sync__c && 
                   (oppRecord.Account.Amber_Road_Status__c == 'Potential Match' || 
                    oppRecord.Account.Amber_Road_Status__c == 'Match'))
                {
                    PRAccOppScreenStatusWrapper pRAccOppScreenStatusWrapperObj = new PRAccOppScreenStatusWrapper();
                    pRAccOppScreenStatusWrapperObj.isFlagged = TRUE;
                    pRAccOppScreenStatusWrapperObj.opportunityRecordMap = new Map<Id,Opportunity>{oppRecord.Id => oppRecord};
                    pRAccOppScreenStatusWrapperObj.flaggedAccountName = oppRecord.Account.Name;
                    pRAccOppScreenStatusWrapperObj.accountType = 'Opportunity\'s account';
                    if(opportunityIdPRRecordMap.containsKey(oppRecord.Id)){
                        pRAccOppScreenStatusWrapperObj.prRecord = opportunityIdPRRecordMap.get(oppRecord.Id);
                    }
                    
                    pRAccOppScreenStatusWrapperList.add(pRAccOppScreenStatusWrapperObj);
                }
                if(pRAccOppScreenStatusWrapperList.isEmpty())
                {
                    if(!oppRecord.Primary_Reseller_Partner__r.Is_Federal_Account_Sync__c && 
                       (oppRecord.Primary_Reseller_Partner__r.Amber_Road_Status__c == 'Potential Match' || 
                        oppRecord.Primary_Reseller_Partner__r.Amber_Road_Status__c == 'Match'))
                    {
                        PRAccOppScreenStatusWrapper pRAccOppScreenStatusWrapperObj = new PRAccOppScreenStatusWrapper();
                        pRAccOppScreenStatusWrapperObj.isFlagged = TRUE;
                        pRAccOppScreenStatusWrapperObj.opportunityRecordMap = new Map<Id,Opportunity>{oppRecord.Id => oppRecord};
                        pRAccOppScreenStatusWrapperObj.flaggedAccountName = oppRecord.Primary_Reseller_Partner__r.Name;
                        pRAccOppScreenStatusWrapperObj.accountType = 'Opportunity primary reseller partner account';
                        if(opportunityIdPRRecordMap.containsKey(oppRecord.Id)){
                            pRAccOppScreenStatusWrapperObj.prRecord = opportunityIdPRRecordMap.get(oppRecord.Id);
                        }
                        
                        pRAccOppScreenStatusWrapperList.add(pRAccOppScreenStatusWrapperObj);
                    }
                }
            }           
            
            if(!pRAccOppScreenStatusWrapperList.isEmpty())
            {
                System.debug('CR# 4395 pRAccOppScreenStatusWrapperList : ' + pRAccOppScreenStatusWrapperList);
                return pRAccOppScreenStatusWrapperList;
            }
            else{
                for(Opportunity_Partner__c oppPartRecord : [SELECT Id,Name,
                                                            Opportunity__c,
                                                            Opportunity__r.AccountId,
                                                            Opportunity__r.Account.Amber_Road_Status__c,
                                                            Opportunity__r.Primary_Reseller_Partner__c,
                                                            Opportunity__r.Primary_Reseller_Partner__r.Amber_Road_Status__c,
                                                            Account__c,
                                                            Account__r.Name,
                                                            Account__r.Amber_Road_Status__c,
                                                            Account__r.Is_Federal_Account_Sync__c
                                                            FROM Opportunity_Partner__c 
                                                            WHERE Opportunity__c IN : opportunityIdPRRecordMap.keySet() LIMIT 50000])
                {
                    if(!oppPartRecord.Account__r.Is_Federal_Account_Sync__c && 
                       (oppPartRecord.Account__r.Amber_Road_Status__c == 'Potential Match' || 
                        oppPartRecord.Account__r.Amber_Road_Status__c == 'Match')){
                            PRAccOppScreenStatusWrapper pRAccOppScreenStatusWrapperObj = new PRAccOppScreenStatusWrapper();
                            pRAccOppScreenStatusWrapperObj.isFlagged = TRUE;
                            //pRAccOppScreenStatusWrapperObj.opportunityPartnerRecordMap = new Map<Id,Opportunity>{oppPartRecord.Opportunity__c => oppPartRecord.Opportunity__c};
                            pRAccOppScreenStatusWrapperObj.flaggedAccountName = oppPartRecord.Account__r.Name;
                            pRAccOppScreenStatusWrapperObj.accountType = 'Opportunity partner account';
                            if(opportunityIdPRRecordMap.containsKey(oppPartRecord.Opportunity__c)){
                                pRAccOppScreenStatusWrapperObj.prRecord = opportunityIdPRRecordMap.get(oppPartRecord.Opportunity__c);  
                            }                   
                            
                            pRAccOppScreenStatusWrapperList.add(pRAccOppScreenStatusWrapperObj);
                        }
                } 
            }
        }
        System.debug('CR# 4395 pRAccOppScreenStatusWrapperList : ' + pRAccOppScreenStatusWrapperList);
        return pRAccOppScreenStatusWrapperList;        
    }
    
    public class PRAccOppScreenStatusWrapper{
        public Boolean isFlagged = FALSE;
        public String flaggedAccountName;
		public String accountType;          
        public Map<Id,Account> accountRecordMap;
        public Map<Id,Opportunity> opportunityRecordMap;
        public Map<Id,Opportunity_Partner__c> opportunityPartnerRecordMap;
        public Provisioning_Request__c prRecord;
    }
    
    public class ScreeningStatusWrapper{
        public Boolean isFlagged = FALSE;        
        public String screeningStatus;
        public String oppPartnerAccountName;
        public Opportunity oppotunityRecord;
    }
    
    public class PRScreeningWrapper{
        public Boolean isAccOrOppCompliant = TRUE;
        public String nonCompliantAccountName;
        public String nonCompliantAccountType;
    }
    
}