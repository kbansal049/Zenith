public class generateOneDocController {
    
    @auraEnabled
    public static ResultWrapper generateOneDocForMeeting(ID meetingID){
        String message = '';
        String dId = '';
        try{
            ID templateId = [select id from OneDoc__Template__c where name = 'Meeting Doc'].id;
            Map<String, Blob> files = null;
            if(!Test.isRunningTest()){
                OneDoc.Generator generator = new OneDoc.Generator(templateId, meetingID,'pdf');
                files = generator.generate();
            }else{
                files = new Map<String, Blob>();
                files.put('Test',Blob.valueOf('Test'));
            }
            
            System.debug('---files---'+files);
            
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
                
                System.debug('---cv---'+cv);
                
                String cdId = [select ContentDocumentId 
                        from ContentVersion where Id =: cv.Id].ContentDocumentId;
                
                ContentDocumentLink cdl = new ContentDocumentLink(
                    ContentDocumentId = cdId,
                    LinkedEntityId = meetingID,
                    Visibility='AllUsers',
                    ShareType = 'I'
                );
                cdllst.add(cdl);
                
                dId = cdId;
            }
            if(!cdllst.isEmpty()){
                insert cdllst;
            }
           
            System.debug('---cdllst---'+cdllst); 
            
        }catch(exception ex){
            message = ex.getmessage();
        }
        return new ResultWrapper(dId, message); //Modified By Swathi CR1318
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