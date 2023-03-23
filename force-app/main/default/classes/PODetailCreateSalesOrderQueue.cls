public class PODetailCreateSalesOrderQueue implements System.Queueable {
    
    Set<ID> poDetailIdsSet = new Set<ID>();
    
    public PODetailCreateSalesOrderQueue(Set<ID> poDetailIdsSet){
        this.poDetailIdsSet = poDetailIdsSet;
    }
    
    
    public void execute(QueueableContext context){
        System.debug('--poDetailIdsSet--'+poDetailIdsSet);
        List<PO_Detail__c> poDetail=new List<PO_Detail__c>();
        for(PO_Detail__c pod : [Select Id,POCreateSOQueue_Stage_Failure__c,Opportunity__c,Opportunity__r.Sales_Declaration_Done__c from PO_Detail__c where Opportunity__c != null and id in :poDetailIdsSet]){
            
            System.debug('--pod--'+pod);
            Id oppId = pod.Opportunity__c;
            CreateSalesOrderExtensionCPQSalesLWC.PreQCResultWrapper preQCWarpp =  CreateSalesOrderExtensionCPQSalesLWC.retrivePreQCDetails(oppId);
            String check=verifyIFSalesOrderNeedstobeCreated(preQCWarpp); 
            //boolean check = verifyIFSalesOrderNeedstobeCreated(preQCWarpp); 
            System.debug('--pod--check--'+check);
            if(check =='Success'){
                CreateSalesOrderExtensionCPQSalesLWC.createSalesOrderPODetail(oppID);
            }
            else{
                pod.POCreateSOQueue_Stage_Failure__c=check;
                poDetail.add(pod);
            }
        }
        if(poDetail.size()>0){
            TriggerHandler.bypass('PODetailTriggerHandler');
            update poDetail;
        }
    }
    
        
    public string verifyIFSalesOrderNeedstobeCreated(CreateSalesOrderExtensionCPQSalesLWC.PreQCResultWrapper preQCResultWarp){
        
        System.debug('-----verifyIFSalesOrderNeedstobeCreated--preQCResultWarp---'+preQCResultWarp);
        String stage='Failure Reasons :   ';
        CreateSalesOrderExtensionCPQSalesLWC.PreQCWrapper  preQCWrapper = preQCResultWarp.pqw;
        
        if(preQCWrapper != null && preQCResultWarp.isSuccess == true){
            
            Opportunity opp = preQCWrapper.opp;
            
            //Step1. Check IF isPrimaryQuote Step Passed
            if(!isPrimaryQuoteStepsPassed(opp)){
                stage +='isPrimaryQuoteStep-Failed';
                return stage;}
            
            //Step2. Check IF PR Step Passed
            if(!isPRStepPassed(preQCWrapper)){
                stage +='isPRSStep-Failed';
                return stage;}

            //Step3. Check IF Legal Step Passed
            if(!isLeagalStepPassed(preQCWrapper)){
                //return false;
                stage +='isLegalStep-Failed';
                return stage;}
            
            //Step 4 Check if ER Step Passed
            if(!isERStepPassed(preQCWrapper)){
                stage +='isERStep-Failed';
                return stage;}
            
            //Step 5 Check if PO Attached
            if(!isPOAttachedStepPassed(opp))
            {
                stage +='isPOAttachedStep-Failed';
                return stage;}
            
            //Step 6 Check if SOW Attach Step Passed
            if(!isSOWAttachedStepPassed(preQCWrapper))
            {
                stage +='isSOWAttachedStep-Failed';
                return stage;}
            
            //Step 7 Check if Billing Declaration Step Passed
            if(!isBillingDeclartionAttachStepPassed(preQCWrapper))
            {
                stage +='isBillingDeclartionAttach-Failed';
                return stage;}
            
            //Step 8 Check if SalesDeclartion has been Done
            if(!isSalesDeclarationDone(opp))
            {
                stage +='isSalesDeclaration-Failed';
                return stage;}
            
            //Step 9 Check if PS Start Date Step Passed
            if(!isPSStarDateCheckPassed(preQCWrapper))
            {
                stage +='isPSStarDateCheck-Failed';
                return stage;}
            
            //Step 10 Check if MultiCloud Step Passed
            if(!isMultiCloudCheckPassed(preQCWrapper))
            {
                stage +='isMultiCloudCheck-Failed';
                return stage;}
            
            return 'Success';
        }
        return 'verifyIFSalesOrderNeedstobeCreated-Failed';
    }
    
    
    
    
    public Boolean isMultiCloudCheckPassed(CreateSalesOrderExtensionCPQSalesLWC.PreQCWrapper preQCWrapper){
        Boolean checkIfMultipleCloudIds = preQCWrapper.multipleCloudIdforsameProduct == true  ?  true : false;
        System.debug('-----isMultiCloudCheckPassed--checkIfMultipleCloudIds---'+checkIfMultipleCloudIds);
        Boolean specialInstructionNotRequired = preQCWrapper.opp != null && preQCWrapper.specialInstructionNotRequired == true  ?  true : false; 
        System.debug('-----isMultiCloudCheckPassed--specialInstructionNotRequired---'+specialInstructionNotRequired);
        return (!checkIfMultipleCloudIds) || ( checkIfMultipleCloudIds && specialInstructionNotRequired);   
    }
    
    
    public Boolean isPSStarDateCheckPassed(CreateSalesOrderExtensionCPQSalesLWC.PreQCWrapper preQCWrapper){
        Boolean isPSStartDateNeeded = preQCWrapper.isPSStartDateRequired == true  ?  true : false;
        System.debug('-----isPSStarDateCheckPassed--isPSStartDateNeeded---'+isPSStartDateNeeded);
        Boolean psStartDatePresent = preQCWrapper.opp != null && preQCWrapper.opp.DAS_Start_Date__c != null  ?  true : false; 
        System.debug('-----isPSStarDateCheckPassed--psStartDatePresent---'+psStartDatePresent);
        return (!isPSStartDateNeeded) || ( isPSStartDateNeeded && psStartDatePresent);   
    }
    
    public Boolean isSalesDeclarationDone(Opportunity opp){
        Boolean salesDeclarationDone = opp.Sales_Declaration_Done__c == true  ?  true : false;
        System.debug('-----isSalesDeclarationDone--salesDeclarationDone---'+salesDeclarationDone);
        return salesDeclarationDone;   
    }
    
    public Boolean isBillingDeclartionAttachStepPassed(CreateSalesOrderExtensionCPQSalesLWC.PreQCWrapper preQCWrapper){
        Boolean isBillingDeclartionRequired = preQCWrapper.isBillingCheckRequired == true  ?  true : false;
        System.debug('-----isBillingDeclartionAttachStepPassed--isBillingDeclartionRequired---'+isBillingDeclartionRequired);
        Boolean isBillingDeclartionAttached = preQCWrapper.isBillingDeclarationAttached == true  ?  true : false; 
        System.debug('-----isBillingDeclartionAttachStepPassed--isBillingDeclartionAttached---'+isBillingDeclartionAttached);
        return (!isBillingDeclartionRequired) || ( isBillingDeclartionRequired && isBillingDeclartionAttached);   
    }
    
    public Boolean isSOWAttachedStepPassed(CreateSalesOrderExtensionCPQSalesLWC.PreQCWrapper preQCWrapper){
        Boolean isSOWRequired = preQCWrapper.isSOWRequired == true  ?  true : false;
        System.debug('-----isSOWAttachedStepPassed--isSOWRequired---'+isSOWRequired);
        Boolean isSOWAttached = preQCWrapper.isSOWAttached == true  ?  true : false; 
        System.debug('-----isSOWAttachedStepPassed--isSOWAttached---'+isSOWAttached);
        return (!isSOWRequired) || ( isSOWRequired && isSOWAttached);   
    }
    
    
    public Boolean isPOAttachedStepPassed(Opportunity oppRecord){
        return oppRecord != null && oppRecord.PO_Attached__c == true ? true : false;
    }
    
    
    public Boolean isERStepPassed(CreateSalesOrderExtensionCPQSalesLWC.PreQCWrapper preQCWrapper){
        Boolean erApprovalNeeded = preQCWrapper.erServiceEdgeNeeded == true || preQCWrapper.erVirtualServiceEdgeNeeded == true ?  true : false;
        System.debug('-----isERStepPassed--erApprovalNeeded---'+erApprovalNeeded);
        Boolean erApprovalStatus = checkIFLegalApproved(preQCWrapper);
        System.debug('-----isERStepPassed--erApprovalStatus---'+erApprovalStatus);
        return (!erApprovalNeeded) || ( erApprovalNeeded && erApprovalStatus);   
    }
    
    public Boolean checkERApprovalStatus(CreateSalesOrderExtensionCPQSalesLWC.PreQCWrapper preQCWrapper){
        if(preQCWrapper.erServiceEdgeNeeded){
            if(preQCWrapper.erServiceEdgeList != null){
                for(Equipment_Request__c currentItem :  preQCWrapper.erServiceEdgeList){
                    if(currentItem.Approval_Status__c != 'Approved'){
                        return false;
                    }
                }
            }
        }
        if(preQCWrapper.erVirtualServiceEdgeNeeded){
            if(preQCWrapper.erVirtualServiceEdgeList != null){
                for(Equipment_Request__c currentItem :  preQCWrapper.erServiceEdgeList){
                    if(currentItem.Approval_Status__c != 'Approved'){
                        return false;
                    }
                }
            }
        }
        return true;
    }
    
    public Boolean isLeagalStepPassed(CreateSalesOrderExtensionCPQSalesLWC.PreQCWrapper preQCWrapper){
        Boolean islegalNeeded = preQCWrapper != null && preQCWrapper.isLegalRequired == true ?  true : false;
        System.debug('-----isLeagalStepPassed--islegalNeeded---'+islegalNeeded);
        Boolean legalApproved = checkIFLegalApproved(preQCWrapper);
        System.debug('-----isLeagalStepPassed--legalApproved---'+legalApproved);
        return (!islegalNeeded) ||  (islegalNeeded && legalApproved);   
    }
    
    public boolean checkIFLegalApproved(CreateSalesOrderExtensionCPQSalesLWC.PreQCWrapper preQCWrapper){
        List<Legal__c> lgUnapprovedList = new List<Legal__c>();
        if(preQCWrapper.leagalRecList != null){
            List<Legal__c> lgRecList =  preQCWrapper.leagalRecList;
            for(Legal__c legal : lgRecList){
                if(legal.Contract_Execution_Date__c == null){
                    lgUnapprovedList.add(legal);
                }
            }
        }
        return lgUnapprovedList.size() > 0 ? false : true; 
    }
    
    
    public boolean isPRStepPassed(CreateSalesOrderExtensionCPQSalesLWC.PreQCWrapper preQCWrapper){
        Boolean checkIfPRRequired = preQCWrapper != null && preQCWrapper.prRequired == true ?  true : false;
        System.debug('-----isPRStepPassed--checkIfPRRequired---'+checkIfPRRequired);
        Boolean checkIFPRProvisioned = checkIFPRProvisioned(preQCWrapper);
        System.debug('-----isPRStepPassed--checkIFPRProvisioned---'+checkIFPRProvisioned);
        
        return !checkIfPRRequired || ( checkIfPRRequired && checkIFPRProvisioned);   
    }
    
    public boolean checkIFPRProvisioned(CreateSalesOrderExtensionCPQSalesLWC.PreQCWrapper preQCWrapper){
        //CR# 3611 added below if condition
        if(preQCWrapper != null &&   preQCWrapper.cloudIdAlreadyProvisionedForUpsell == true){
            return true;
        }
        if(preQCWrapper != null &&  preQCWrapper.prMAP != null){
            MAP<String, List<Provisioning_Request__c>> cloudCatPRList =  preQCWrapper.prMAP;
            for(String cloudCat : cloudCatPRList.keyset()){
                List<Provisioning_Request__c> prList = cloudCatPRList.get(cloudCat);
                if(prList.size() > 0){
                    for(Provisioning_Request__c pr : prList){
                        if(pr.Provisioning_Status__c != 'Provisioned' && pr.Provisioning_Status__c != 'Production'){
                            return false;
                        }
                    }
                }else{
                    return false;
                }
            }
        }
        return true;
    }
    
    
    public boolean isPrimaryQuoteStepsPassed(Opportunity oppRecord){
        System.debug('--PrimaryQuoteStepsPassed--called--');
        String primaryQuoteType = PrimaryQuoteType(oppRecord);
        System.debug('--PrimaryQuoteStepsPassed--primaryQuoteType--'+primaryQuoteType);
        
        Boolean checkifPrimaryQuoteExist = (primaryQuoteType == 'CPQ') ?  true : false;
        System.debug('--PrimaryQuoteStepsPassed--checkifPrimaryQuoteExist--'+checkifPrimaryQuoteExist);
        
        Boolean checkIfQuoteIsApproved = false;
        if(primaryQuoteType == 'CPQ'){
            checkIfQuoteIsApproved =  (oppRecord != null  && oppRecord.SBQQ__PrimaryQuote__c != null &&  oppRecord.SBQQ__PrimaryQuote__r.SBQQ__Status__c == 'Approved') ?  true : false;
        }
        System.debug('--PrimaryQuoteStepsPassed--checkIfQuoteIsApproved--'+checkIfQuoteIsApproved);
        return checkifPrimaryQuoteExist && checkIfQuoteIsApproved;
    }
    
    
    public String PrimaryQuoteType(Opportunity oppRecord)
    {
        return (oppRecord != null && 
                oppRecord.SBQQ__PrimaryQuote__c != null && 
                oppRecord.SBQQ__PrimaryQuote__r.SBQQ__Primary__c)
            ? 'CPQ' 
            : 'None'
        ;
    }
    
}