public class generatePSQuestionnaireController {
    @AuraEnabled
    public static ResultWrapper exportDocumentFromQuestionnaire(Id questionnaireId){
        String message = '';
        String dId = '';
        try{
            String templateName='';
            if(questionnaireId != null){
                String psRecordType = [select recordType.Name, Status__c from PS_Questionnaire__c where Id=:questionnaireId].RecordType.Name;
                if(psRecordType == 'ZPA'){
                    templateName = 'PS Questionnaire Template ZPA';
                }
                else if(psRecordType == 'ZIA'){
                    templateName = 'PS Questionnaire Template ZIA';
                }
            }
            if(!String.isBlank(templateName)){
                ID templateId = [select id from OneDoc__Template__c where name =: templateName].id;
                Map<String, Blob> files = null;
                if(!Test.isRunningTest()){
                    system.debug('This is generate Questionnaire :'+templateId);
                    OneDoc.Generator generator = new OneDoc.Generator(templateId, questionnaireId,'docx');
                    files = generator.generate();
                }else{
                    files = new Map<String, Blob>();
                    files.put('Test',Blob.valueOf('Test'));
                }
                system.debug('files :'+files);
                
                List<ContentDocumentLink> cdllst = new List<ContentDocumentLink>();
                for(String name : files.keySet()) {
                    ContentVersion cv = new ContentVersion(
                        ContentLocation = 'S',
                        VersionData = files.get(name),
                        Title = name,
                        PathOnClient = name
                    );
                    insert cv;
                    
                    String cdId = [select ContentDocumentId 
                                   from ContentVersion where Id =: cv.Id].ContentDocumentId;
                    
                    ContentDocumentLink cdl = new ContentDocumentLink(
                        ContentDocumentId = cdId,
                        LinkedEntityId = questionnaireId,
                        Visibility='AllUsers',
                        ShareType = 'I'
                    );
                    cdllst.add(cdl);
                    system.debug('cdllst :'+cdllst);
                    dId = cdId;
                }
                if(!cdllst.isEmpty()){
                    insert cdllst;
                }  
            }else{
                message = 'Questionnaire Generation Template Not Found.';
            }
            
        }catch(exception ex){
            message = ex.getmessage();
        }
        return new ResultWrapper(dId, message);
    }
    
    @AuraEnabled
    public static ResultWrapper generateDesignPlanFromQuestionnaire(Id questionnaireId){
        String message = '';
        String dId = '';
        Boolean validationError=false;
        try{
            String templateName='';
            if(questionnaireId != null){
                PS_Questionnaire__c psq = [select id, recordType.Name, Status__c from PS_Questionnaire__c where Id=:questionnaireId];
                String psRecordType = psq.RecordType.Name;
                if(psq.Status__c != 'Questionnaire Submitted'){
                    message = 'Design Plan can only be generated when Questionnaire is submitted';
                    validationError = true;
                }
                //String psRecordType = [select recordType.Name from PS_Questionnaire__c where Id=:questionnaireId].RecordType.Name;
                if(psRecordType == 'ZPA'){
                    templateName = 'Design Document ZPA';
                }
                else if(psRecordType == 'ZIA'){
                    templateName = 'Design Document ZIA';
                }
            }
            if(!String.isBlank(templateName) && !validationError){
                ID templateId = [select id from OneDoc__Template__c where name =: templateName].id;
                Map<String, Blob> files = null;
                if(!Test.isRunningTest()){
                    system.debug('This is generate Design Plan :'+templateId);
                    OneDoc.Generator generator = new OneDoc.Generator(templateId, questionnaireId,'docx');
                    files = generator.generate();
                }else{
                    files = new Map<String, Blob>();
                    files.put('Test',Blob.valueOf('Test'));
                }
                system.debug('files :'+files);
                
                List<ContentDocumentLink> cdllst = new List<ContentDocumentLink>();
                for(String name : files.keySet()) {
                    ContentVersion cv = new ContentVersion(
                        ContentLocation = 'S',
                        VersionData = files.get(name),
                        Title = name,
                        PathOnClient = name
                    );
                    insert cv;
                    
                    String cdId = [select ContentDocumentId 
                                   from ContentVersion where Id =: cv.Id].ContentDocumentId;
                    
                    ContentDocumentLink cdl = new ContentDocumentLink(
                        ContentDocumentId = cdId,
                        LinkedEntityId = questionnaireId,
                        Visibility='AllUsers',
                        ShareType = 'I'
                    );
                    cdllst.add(cdl);
                    system.debug('cdllst :'+cdllst);
                    dId = cdId;
                }
                if(!cdllst.isEmpty()){
                    insert cdllst;
                }  
            }else{
                if(!validationError){
                    message = 'Design Plan Template Not Found.';    
                }
            }
            
        }catch(exception ex){
            message = ex.getmessage();
        }
        return new ResultWrapper(dId, message);
    }
    
    @AuraEnabled
    public static void sendEmailWithDesignDoc(Id questionnaireId,Id docId){
        String Primary_PS_Consultant = '';
        String Account = '';
        List<String> sendTo = new List<String>();
        List<String> sendCC = new List<String>();
        
        if(questionnaireId != null){
            PS_Questionnaire__c psq = [select id,Name,Primary_PS_Consultant__r.Name,Account__r.Name,Primary_PS_Consultant__r.Email,Secondary_PS_Consultant__r.Email,Project_Manager__r.Email,Opportunity_Owner__r.Email,Sales_Engineer__r.Email from PS_Questionnaire__c where Id=:questionnaireId];
            Primary_PS_Consultant=psq.Primary_PS_Consultant__r.Name;
            Account=psq.Account__r.Name;
            
            EmailTemplate emailTemplate = [select Id, HTMLValue,Name,Subject  from EmailTemplate where Name = 'Email to PS team after design doc'];
            String emailTemplatebody = emailTemplate.HTMLValue;
            String emailTemplatesubject = emailTemplate.Subject;
            emailTemplatesubject = emailTemplatesubject.replace('[**Account_Name**]',Account);
            emailTemplatebody = emailTemplatebody.replace('[**PS_Name**]',Primary_PS_Consultant);
            emailTemplatebody = emailTemplatebody.replace(']]>', '');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(psq.Secondary_PS_Consultant__c !=null && psq.Secondary_PS_Consultant__r.Email !=null)
            {
                sendTo.add(psq.Secondary_PS_Consultant__r.Email);
                
            }
            if(psq.Primary_PS_Consultant__c !=null && psq.Primary_PS_Consultant__r.Email !=null)
            {
                sendTo.add(psq.Primary_PS_Consultant__r.Email);
                
            }
            if(psq.Project_Manager__c !=null && psq.Project_Manager__r.Email !=null)
            {
                sendTo.add(psq.Project_Manager__r.Email);
                
            }
            if(psq.Sales_Engineer__c !=null && psq.Sales_Engineer__r.Email !=null)
            {
                sendCC.add(psq.Sales_Engineer__r.Email);
                
            }
            if(psq.Opportunity_Owner__c !=null && psq.Opportunity_Owner__r.Email !=null)
            {
                sendCC.add(psq.Opportunity_Owner__r.Email);          
                
            }
            if(Label.Email_Design_Doc !=null)
            {
                sendTo.addAll((Label.Email_Design_Doc).split(';'));
                
            }
            
            system.debug(sendTo);
            system.debug(sendCC);
            
            mail.setToAddresses(sendTo);
            mail.setCCAddresses(sendCC);
            
            mail.setSubject(emailTemplatesubject);
            mail.setHtmlBody(emailTemplatebody);
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            if(!test.isRunningTest())
            {
                ContentVersion Content = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId FROM ContentVersion WHERE isLatest = true AND ContentDocumentId=:docId LIMIT 1];       
                attachment.setBody(Content.VersionData);
                attachment.setFileName(Content.Title);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});                
            }
            system.debug('---Mail Sent----');
            system.debug('Document ID'+docId);
        }
        
    }
    
    public class ResultWrapper{
        @AuraEnabled
        public string docId;
        @AuraEnabled
        public string mes;
        public ResultWrapper(string dId, string m){
            docId = dId;
            mes = m;
        }
    }
}