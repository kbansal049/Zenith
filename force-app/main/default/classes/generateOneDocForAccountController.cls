public class generateOneDocForAccountController {
    
    @auraEnabled
    public static ResultWrapper generateOneDocForAccount(ID accountID){
        String message = '';
        String dId = '';
        try{
            ID templateId = [select id from OneDoc__Template__c where name = 'Value Summary'].id;
            
            Map<String, Blob> files = null;
            if(!Test.isRunningTest()){
                OneDoc.Generator generator = new OneDoc.Generator(templateId, accountID,'pdf');
                files = generator.generate();
            }else{
                files = new Map<String, Blob>();
                files.put('Test',Blob.valueOf('Test'));
            }
            
            //  Currently only one file will be returned in the output
            List<ContentDocumentLink> cdllst = new List<ContentDocumentLink>();
            for(String name : files.keySet()) {
                //  Creating ContentVersion record will create ContentDocument record automatically
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
                    LinkedEntityId = accountID,
                    Visibility='AllUsers',
                    ShareType = 'I'
                );
                cdllst.add(cdl);
                
                dId = cdId;
            }
            if(!cdllst.isEmpty()){
                insert cdllst;
            }
            
        }catch(exception ex){
            message = ex.getmessage();
        }
        return new ResultWrapper(dId, message);
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