global class CTMDomainVerificationandCaseCreation{
    @AuraEnabled
    webservice static Boolean checkdomain(Id accountId, String contactemaildomain){
    Boolean domainmatches = false;
        List<Account> acclst = [Select Id, Domain__c, Additional_Organization_Domains__c,Override_CTM_Domain__c from Account where Id = :accountId];
        if(!acclst.isEmpty()){
            if(acclst[0].Domain__c != null){
                //String accdomain = acclst[0].Domain__c.remove('https://www.').remove('http://www.').remove('https://').remove('http://').split('\\.')[0];
                String accdomain = acclst[0].Domain__c.remove('https://www.').remove('http://www.').remove('https://').remove('http://');
                if(accdomain.contains(contactemaildomain) || contactemaildomain.contains(accdomain)){
                    domainmatches = true;
                    return domainmatches;
                }
            }
            if(acclst[0].Additional_Organization_Domains__c != null){
                for(String adddomain: acclst[0].Additional_Organization_Domains__c.split(',')){
                    //String accdomain = adddomain.trim().remove('https://www.').remove('http://www.').remove('https://').remove('http://').split('\\.')[0];
                    String accdomain = adddomain.trim().remove('https://www.').remove('http://www.').remove('https://').remove('http://');
                    if(accdomain.contains(contactemaildomain) || contactemaildomain.contains(accdomain)){
                        domainmatches = true;
                        return domainmatches;
                    }
                }
            }
            /* if(contactemaildomain.toLowerCase().contains(acclst[0].Domain__c.tolowercase())){
                system.debug('++++ inside lowercase domain match');
                domainmatches = true;
                return domainmatches;
            } */
            if(!domainmatches && acclst[0].Override_CTM_Domain__c==true /*&& Userinfo.getprofileid()=='00e70000000wOVwAAM' */){
                domainmatches = true;
                return domainmatches;
            }
        }
        return domainmatches;
    }
    @AuraEnabled
    webservice static String createCase(id accId, String accName, id conId, String contactname){
        system.debug('Inside Create Case');
        String subject = '%'+conId+'%';
        List<Case> cslst = [Select Id, Casenumber from Case where AccountId = :accId and Subject like :subject and Status not in ('Closed - Resolved' ,'Closed - No Action' ,'Closed - Duplicate')]; 
        if(!cslst.isempty()){
            return 'A case ' + cslst[0].Casenumber + ' already exists. Please reach out to SFDC Support team for status.';
        }
        case tempCase = new case();
        String  result = '';
        tempCase.AccountId = accId;
        tempCase.Subject = 'New Case for Domain verification is Created for Account: '+accName+' / '+accId + ' and for the Contact : '+ contactname + ' / ' + conId;
        tempCase.Description = 'Please verify the domain on contact and please add it to additional Organization domains on Account if Valid.';
        
        tempCase.Case_Category__c = 'Accounts';
        tempCase.Case_Sub_Category__c = 'Email Domain Verification';
        tempCase.recordtypeid=label.CaseRT_SalesOperation;
        if(!Test.isRunningTest())
            tempCase.OwnerId = ZscalerSetting__c.getValues('AccountDomainMismatchCaseOwnerId').Value__c;
            tempCase.Status = 'New';
        try{
            insert tempCase;
            system.debug('Case Created');
            Case tempCase1 = [Select Id, Casenumber from case where Id = :tempCase.Id];
            result =  tempCase1.CaseNumber +' - '+tempCase1.Id;
        }catch(Exception ex){
            result = 'Error: ' +ex; 
        }
        return result;
    }

}