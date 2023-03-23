global class BatchToUpdateIsExtensionAllowed implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('BatchToUpdateIsExtensionAllowed');
    global Integer RecordsProcessed = 0;
    global Integer RecordsProcessedSize = 0;
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        return Database.getQueryLocator('select id,Deployment_Package__c,Rejected_SKU__c,inspire1__Project_Template__r.Name,Name from inspire1__Project__c where RecordType.DeveloperName = \'Deployment_Project\' and inspire1__Project_Status__c != \'Cancelled\' and inspire1__Project_Status__c != \'Completed\'');
    }
    global void execute(Database.BatchableContext BC, List<inspire1__Project__c> projectList){
        this.zb.callExecute(projectList[0]?.Id, projectList.size());
        Set<String> allowedSKUs = new Set<String>();
        Boolean CheckTemplate = false;
        allowedSKUs.addAll(Label.SKUs_allowed_for_PS_Extension.split(','));
        List<inspire1__Project__c> listToUpdate = new List<inspire1__Project__c>();
        for(inspire1__Project__c project:projectList){
            if(project.Deployment_Package__c != null){
                List<String> SKUlst = project.Deployment_Package__c.split(',');
                For(String SKU: SKUlst){
                    CheckTemplate = allowedSKUs.contains(SKU);
                    if(CheckTemplate==false){
                        project.Rejected_SKU__c = SKU;
                        break;
                    }
                }
            }
            if(CheckTemplate==false){
                if(project.inspire1__Project_Template__r.Name!=null && (
                    (project.inspire1__Project_Template__r.Name.toLowercase().Contains('advanced') || project.inspire1__Project_Template__r.Name.toLowercase().Contains('enterprise') || project.inspire1__Project_Template__r.Name.toLowercase().Contains('credit')|| project.inspire1__Project_Template__r.Name.toLowercase().Contains('advance'))
                    &&(!project.inspire1__Project_Template__r.Name.toLowercase().Contains('federal') && !project.inspire1__Project_Template__r.Name.toLowercase().Contains('optimize') && !project.inspire1__Project_Template__r.Name.toLowercase().Contains('opt'))
                )){
                    project.Is_Extension_Allowed__c = true;
                }else if(project.inspire1__Project_Template__r.Name==null){
                    project.Is_Extension_Allowed__c = false;
                }
            }else{
                project.Is_Extension_Allowed__c = true;
            }
            listToUpdate.add(project);
            RecordsProcessed = RecordsProcessed +1; 
        }
        if(!listToUpdate.isEmpty()){
            database.update(listToUpdate);
        }
        /*try {
            system.debug('total surveys:'+listToUpdate.size());
            system.debug(Limits.getCpuTime());
            system.debug(Limits.getLimitCpuTime());
            InspireProjectMasterTriggerHandler.skiptrigger = true;
            Integer a = listToUpdate.size();
            RecordsProcessedSize = RecordsProcessedSize + a; 
            update listToUpdate;
        } catch (Exception e){
            system.debug('Error msg'+e.getmessage());   
        }*/
        
    }
    global void finish(Database.BatchableContext BC){
        this.zb.callFinish(BC);
        system.debug('Records Processed:'+RecordsProcessed); 
        List<String> lstSendToEmails = new List<String>();
        lstSendToEmails.add(UserInfo.getUserId());
        Messaging.SingleEmailMessage Emailmessage = new Messaging.SingleEmailMessage();
        Emailmessage.toaddresses = lstSendToEmails;
        Emailmessage.subject='Processed Records';
        String Message = 'Hi, <br/>';
        Message += 'Number of Processed Records are: ';   
        Message += RecordsProcessed;
        Message += '<br/>Thank you';
        Emailmessage.setHtmlBody(Message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {Emailmessage});
    }
}