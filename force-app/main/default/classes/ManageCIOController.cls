public class ManageCIOController {
    
    //For Account -- Manage CIO Button
    @auraenabled(cacheable=true)
    Public Static CIODetails getCIODetails(String accountID){
        return fillCIODetailsWrapper(accountID);
    }
    
    @auraenabled
    Public Static CIODetails getCIODetailsUncached(String accountID){
        return fillCIODetailsWrapper(accountID);
    }
    
    private Static CIODetails fillCIODetailsWrapper(String accountID) {
        CIODetails cio = new CIODetails();
        try{
            if(accountID == null || String.isEmpty(accountID)){
                cio.hasError = true;
                cio.errorMsg = 'Invalid AccountID, kindly provide valid accountID.';
            }else{
                List<ContactDetail> contactList = new List<ContactDetail>();
                
                Account acc = [Select ID,Name,Domain__c,Additional_Organization_Domains__c,Override_CTM_Domain__c from Account where ID = :accountID];
                
                cio.accountName = acc.Name;
                cio.accountId = acc.Id;
                
                Map<String,String> pickListValuesMap= new Map<String,String>();
                Schema.DescribeFieldResult fieldResult = Contact.Send_CIO_Report__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
                }
                
                cio.execOptions = JSON.serialize(pickListValuesMap);
                
                Map<String,Case> caseMap = getAllCaseDetailsFromAccount(acc);
                
                for(Contact con : [Select ID,Name,Title,Send_CIO_Report__c,email,Level_From_CIO__c from Contact where Active__c = false and accountid = :accountID ORDER BY Name ASC]){
                    System.debug('--con--'+con);
                    ContactDetail condet = new ContactDetail();
                    condet.con = con;
                    condet.Send_Exec_Insights = con.Send_CIO_Report__c;
                    condet.MatchesDomainCriteria = checkContactMatchesDomainCriteria(acc, con.email);
                    
                    if(condet.MatchesDomainCriteria){
                        condet.CreateCase = false;
                        condet.CaseExist = false;
                    }else{
                        Case cs = getOpenCaseForContact(caseMap,con.Id);
                        if(cs != null){
                            condet.CaseExist = true;
                            condet.CaseId = cs.Id;
                            condet.CaseNumber = cs.CaseNumber ;
                            condet.CaseStaus = cs.Status;
                            condet.CreateCase = false;
                        }else{
                            condet.CaseExist = false;
                            condet.CreateCase = true;
                        } 
                    }
                    contactList.add(condet);
                }
                cio.conList = contactList;
            }
        }catch(Exception ex){
            System.debug('Exeption :: Message ::'+ex.getMessage());
            System.debug('Exeption :: Line ::'+ex.getLineNumber());
            System.debug('Exeption :: getStackTraceString ::'+ex.getStackTraceString());
            cio.hasError = true;
            cio.errorMsg = 'Exception Occured::'+ex.getMessage();
        }
        return cio;
    }
    
    @auraenabled
    Public Static CustomResult saveContactRecords(String cDetailStr){
        System.debug('saveContactRecords--cDetailStr--'+cDetailStr);
        CustomResult csr = new CustomResult();
        Savepoint sp = null;
        try{
            
            CIODetails cDetail = (ManageCIOController.CIODetails)JSON.deserialize(cDetailStr, ManageCIOController.CIODetails.class);
            System.debug('saveContactRecords--cDetail--'+cDetail);
            
            if(cDetail == null || cDetail.conList == null){
                csr.hasError = true;
                csr.errorMsg = 'Kindly provide contact records.';
            }else{
                sp = Database.setSavepoint();
                List<Contact> updateConList = new List<Contact>();
                List<Case> caseList = new List<Case>();
                List<Contact> caseConList = new List<Contact>();
                
                String accID = cDetail.accountId;
                String accName = cDetail.accountName;
                
                for(ContactDetail cDet : cDetail.conList){
                    System.debug('------hello-----------------');
                    if(cDet.Send_Exec_Insights != cDet.Con.Send_CIO_Report__c ){
                        //Fill CASE List to create CASE records.
                        if(cDet.CreateCase == true && cDet.CaseExist == false){
                            Contact con  = cDet.con;
                            Case addCase = createCaseRecord(accID,accName,con.Id,con.Name);
                            if(addCase != null){
                                caseList.add(addCase);
                            }
                        }
                        
                        //Fill Contact List to Update Send_CIO_Report__c
                        if(cDet.MatchesDomainCriteria == true){
                            cDet.Con.Send_CIO_Report__c = cDet.Send_Exec_Insights;
                            // CR# 739 - Modifications
                            System.debug('out side if');
                            if(String.isNotBlank(cDet.Con.Send_CIO_Report__c) && (cDet.Con.Send_CIO_Report__c.equalsIgnoreCase('Send') || cDet.Con.Send_CIO_Report__c.equalsIgnoreCase('Send Delayed'))){
                                cDet.Con.Contacts_that_matter__c = true;
                                System.debug('insie if');
                            }    
                            //CR#739 Modifications end
                            updateConList.add(cDet.Con);
                        }
                    }
                }
                
                
                update updateConList;
                System.debug('--updateConList--'+updateConList);
                insert caseList;
                System.debug('--caseList--'+caseList);
                csr.isSucess = true;
            }
        }catch(Exception ex){
            // if a savepoint was set, rollback updates
            if (sp != null) {
                Database.rollback(sp);
            }
            System.debug('Exeption :: Message ::'+ex.getMessage());
            System.debug('Exeption :: Line ::'+ex.getLineNumber());
            System.debug('Exeption :: getStackTraceString ::'+ex.getStackTraceString());
            csr.isSucess = false;
            csr.hasError = true;
            csr.errorMsg = 'Exeption: '+ex.getMessage()+', Line number:'+ex.getLineNumber();   
        }
        return csr;
    }
    
    
    
    //For Contact-- Manage CIO Button
    @auraenabled(cacheable=true)
    Public Static CIODetail getCIODetailForContact(String contactID){
        return fillCIOContactDetailWrapper(contactID);
    }
    
    @auraenabled
    Public Static CIODetail getCIODetailForContactUncached(String contactID){
        return fillCIOContactDetailWrapper(contactID);
    }
    
     
    private Static CIODetail fillCIOContactDetailWrapper(String contactID) {
        CIODetail cio = new CIODetail();
        try{
            if(contactID == null || String.isEmpty(contactID)){
                cio.hasError = true;
                cio.errorMsg = 'Invalid contactID, kindly provide valid contactID.';
            }else{
                
                Map<String,String> pickListValuesMap= new Map<String,String>();
                Schema.DescribeFieldResult fieldResult = Contact.Send_CIO_Report__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
                }
                cio.execOptions = JSON.serialize(pickListValuesMap);
                Contact con = [Select ID,Name,Title,Send_CIO_Report__c,email,accountid,Active__c from Contact where id = :contactID];
                Account acc = [Select ID,Name,Domain__c,Additional_Organization_Domains__c,Override_CTM_Domain__c from Account where ID = :con.accountid];
                
                Map<String,Case> caseMap = getAllCaseDetailsFromAccount(acc);
                
                ContactDetail condet = new ContactDetail();
                condet.con = con;
                condet.Send_Exec_Insights = con.Send_CIO_Report__c;
                condet.MatchesDomainCriteria = checkContactMatchesDomainCriteria(acc, con.email);
                
                condet.validContact = con.Active__c ? false : true;
                
                if(condet.MatchesDomainCriteria){
                    condet.CreateCase = false;
                    condet.CaseExist = false;
                }else{
                    Case cs = getOpenCaseForContact(caseMap,con.Id);
                    if(cs != null){
                        condet.CaseExist = true;
                        condet.CaseId = cs.Id;
                        condet.CaseNumber = cs.CaseNumber ;
                        condet.CaseStaus = cs.Status;
                        condet.CreateCase = false;
                    }else{
                        condet.CaseExist = false;
                        condet.CreateCase = true;
                    } 
                }
                cio.accountName = acc.Name;
                cio.accountId = acc.Id;
                cio.conDetail = condet;
            }
        }catch(Exception ex){
            System.debug('Exeption :: Message ::'+ex.getMessage());
            System.debug('Exeption :: Line ::'+ex.getLineNumber());
            System.debug('Exeption :: getStackTraceString ::'+ex.getStackTraceString());
            cio.hasError = true;
            cio.errorMsg = 'Exception Occured::'+ex.getMessage();
        }
        return cio;
    }
    
    @auraenabled
    Public Static CustomResultContact saveContactInformation(String cDetailStr){
        System.debug('saveContactInformation--cDetailStr--'+cDetailStr);
        CustomResultContact csr = new CustomResultContact();
        Savepoint sp = null;
        try{
            
            CIODetail cDetail = (ManageCIOController.CIODetail)JSON.deserialize(cDetailStr, ManageCIOController.CIODetail.class);
            System.debug('saveContactInformation--cDetail--'+cDetail);
            
            if(cDetail == null || cDetail.conDetail == null){
                csr.hasError = true;
                csr.errorMsg = 'Kindly provide valid contact record.';
            }else{
                sp = Database.setSavepoint();
                List<Contact> updateConList = new List<Contact>();
                List<Case> caseList = new List<Case>();
                List<Contact> caseConList = new List<Contact>();
                
                String accID = cDetail.accountId;
                String accName = cDetail.accountName;
                
                Set<String> SendCIOReportstatus= new Set<String>();
            	String ContactSendCIOReportstatus= ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus')!=null && ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus').Value__c!=null ? ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus').Value__c:'Send,Send delayed';
            	SendCIOReportstatus.addall(ContactSendCIOReportstatus.split(','));
                
                ContactDetail cDet  =  cDetail.conDetail;
                if(cDet.Send_Exec_Insights != cDet.Con.Send_CIO_Report__c ){
                    //Fill CASE List to create CASE records.
                    if(cDet.CreateCase == true && cDet.CaseExist == false){
                        Contact con  = cDet.con;
                        Case addCase = createCaseRecord(accID,accName,con.Id,con.Name);
                        if(addCase != null){
                            caseList.add(addCase);
                        }
                    }
                    //Fill Contact List to Update Send_CIO_Report__c
                    if(cDet.MatchesDomainCriteria == true){
 
                        cDet.Con.Send_CIO_Report__c = cDet.Send_Exec_Insights;
                        if(cDet.Send_Exec_Insights!=null && SendCIOReportstatus.contains(cDet.Send_Exec_Insights) ) {
                            cDet.Con.Contacts_that_matter__c = true;
                        }else  {
                            cDet.Con.Contacts_that_matter__c = false;
                        }
                        
     
                        updateConList.add(cDet.Con);
                    }
                    else if(cDet.Send_Exec_Insights!=null && SendCIOReportstatus.contains(cDet.Send_Exec_Insights) ) {
                                cDet.Con.Contacts_that_matter__c = true;
                        		updateConList.add(cDet.Con);
                    }else {
                        cDet.Con.Contacts_that_matter__c = False;
                        updateConList.add(cDet.Con);
                    }
                }
                update updateConList;
                System.debug('--updateConList--'+updateConList);
                insert caseList;
                System.debug('--caseList--'+caseList);
                
                
                if(updateConList.size()>0){
                    csr.isContactUpdated = true;
                }
                 if(caseList.size()>0){
                    csr.isCaseCreated = true;
                }
                
                csr.isSucess = true;
            }
        }catch(Exception ex){
            // if a savepoint was set, rollback updates
            if (sp != null) {
                Database.rollback(sp);
            }
            System.debug('Exeption :: Message ::'+ex.getMessage());
            System.debug('Exeption :: Line ::'+ex.getLineNumber());
            System.debug('Exeption :: getStackTraceString ::'+ex.getStackTraceString());
            csr.isSucess = false;
            csr.hasError = true;
            csr.isCaseCreated = false;
            csr.isContactUpdated = false;
            csr.errorMsg = 'Exeption: '+ex.getMessage()+', Line number:'+ex.getLineNumber();   
        }
        return csr;
    }
    
   
    
    
    
    
    
    private static Case createCaseRecord(id accId, String accName, id conId, String contactname){
        if(accId != null && accName != null && conId != null && contactname != null){
            case caseRec = new case();
            caseRec.AccountId = accId;
            caseRec.Subject = 'New Case for Domain verification is Created for Account: '+accName+' / '+accId + ' and for the Contact : '+ contactname + ' / ' + conId;
            caseRec.Description = 'Please verify the domain on contact and please add it to additional Organization domains on Account if Valid.';
            caseRec.Case_Category__c = 'Accounts';
            caseRec.Case_Sub_Category__c = 'Email Domain Verification';
            caseRec.recordtypeid=label.CaseRT_SalesOperation;
            if(!Test.isRunningTest())
                caseRec.OwnerId = ZscalerSetting__c.getValues('AccountDomainMismatchCaseOwnerId').Value__c;
            caseRec.Status = 'New';
            return caseRec;
        }else{
            return null;
        }
    }
    
    //Case Subject -- Case Details
    private Static Map<String,Case> getAllCaseDetailsFromAccount(Account acc){
        Map<String,Case> caseMAP = new Map<String,Case>();
        for(Case cs : [Select Id,Casenumber,Subject,Status from Case where AccountId = :acc.ID and Subject like 'New Case for Domain verification%' and Status not in ('Closed - Resolved' ,'Closed - No Action' ,'Closed - Duplicate') order by createdDate limit 100]){
            caseMAP.put(cs.Subject,cs);
        }
        return caseMAP;
    }
    
    
    private Static Case getOpenCaseForContact(MAP<String,Case> caseMAP,String conID){
        for(String sub : caseMAP.keyset()){
            if(sub.containsIgnoreCase(conID)){
                return caseMAP.get(sub);
            }            
        }
        return null;
    }
    
    
    
    private Static Boolean checkContactMatchesDomainCriteria(Account acc, String contactEmail){
        System.debug('--checkContactMatchesDomainCriteria--');
        System.debug('--contactEmail--'+contactEmail);
        System.debug('--acc Domain__c--'+acc.Domain__c);
        System.debug('--acc Additional_Organization_Domains__c--'+acc.Additional_Organization_Domains__c);
        Boolean matches = false;
        if(contactEmail != null && String.isNotEmpty(contactEmail)){
            if(Acc.Domain__c != null){
                String accdomain = Acc.Domain__c.remove('https://www.').remove('http://www.').remove('https://').remove('http://');
                if(contactEmail.endsWithIgnoreCase(accdomain) || contactEmail.containsIgnoreCase(accdomain)){
                    return true;
                }
            }
            if(Acc.Additional_Organization_Domains__c != null){
                List<String> additionalDomainsList = new List<String>();
                for(String str : Acc.Additional_Organization_Domains__c.Split(',')){
                    if(str != null && str.trim().length()>0){
                        String accdomain = str.trim().remove('https://www.').remove('http://www.').remove('https://').remove('http://');
                        if(contactEmail.endsWithIgnoreCase(accdomain) || contactEmail.containsIgnoreCase(accdomain)){
                            return true;
                        }
                    }
                }
            }
            if(acc.Override_CTM_Domain__c == true && matches == false){
                return true;
            }
            
        }
        return matches;
    }
  
    
    
    
    
    //For Account Manage CIO Button
    Public Class CIODetails{
        @auraenabled
        Public List<ContactDetail> conList;
        @auraenabled
        Public String execOptions;
        @auraenabled
        Public String accountName;
        @auraenabled
        Public String accountId;
        @auraenabled
        Public Boolean hasError;
        @auraenabled
        Public String errorMsg;
    }
    
   
    //For Contact Manage CIO button
    Public Class CIODetail{
        @auraenabled
        Public ContactDetail conDetail;
        @auraenabled
        Public String execOptions;
        @auraenabled
        Public String accountName;
        @auraenabled
        Public String accountId;
        @auraenabled
        Public Boolean hasError;
        @auraenabled
        Public String errorMsg;
    }
    
    
    Public Class ContactDetail{
        @auraenabled
        Public Contact Con;
        @auraenabled
        Public Boolean validContact;
        @auraenabled
        Public String  Send_Exec_Insights;
        @auraenabled
        Public Boolean MatchesDomainCriteria;
        @auraenabled
        Public Boolean CreateCase;
        @auraenabled
        Public Boolean CaseExist;
        @auraenabled
        Public String CaseId;
        @auraenabled
        Public String CaseNumber;
        @auraenabled
        Public String CaseStaus;
    }
    
    
    Public Class CustomResult{
        @auraenabled
        Public Boolean isSucess;
        @auraenabled
        Public Boolean hasError;
        @auraenabled
        Public String errorMsg;
    }
    
    
    Public Class CustomResultContact{
        @auraenabled
        Public Boolean isSucess;
        @auraenabled
        Public Boolean isCaseCreated;
        @auraenabled
        Public Boolean isContactUpdated;
        @auraenabled
        Public Boolean hasError;
        @auraenabled
        Public String errorMsg;
    }
    
}