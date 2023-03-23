public without sharing class CreateCaseController {

    
    //CR# 441
    Public Class PortalDetail{
        @AuraEnabled
        Public string zScalerORGId;
        @AuraEnabled
        Public string zScalerORGPortalName;   
    }
    
    //CR# 441
    @AuraEnabled(cacheable=true)
    public static PortalDetail getZscalerPortalDetails(){
        PortalDetail pd = new PortalDetail();
        List<SSO_SAML_History__c> smList = [select id,Portal_UserName__c,Cloud_Id__c,SSO_Initiated_from__c from SSO_SAML_History__c where Portal_UserName__c =: UserInfo.getUserName() and createddate = LAST_N_DAYS:1 order by createddate limit 1 ];
        if(smList.size()>0){
            System.debug('smList--'+smList);
            pd.zScalerORGId =  smList[0].Cloud_Id__c;
            //Added by Ankit - IBA-36 - Start
            if(smList.get(0).SSO_Initiated_from__c=='Cloud Connector') {
                pd.zScalerORGPortalName = smList.get(0).SSO_Initiated_from__c;
            }
            else {
                List<Zscaler_Cloud_ID__c> zScalerCloudList = [SELECT Id, Name,Org_Name__c,Account__c,Cloud_Type__c FROM Zscaler_Cloud_ID__c WHERE Name = : pd.zScalerORGId LIMIT 1];
                if(zScalerCloudList.size()>0){
                    System.debug('zScalerCloudList--'+zScalerCloudList);
                    pd.zScalerORGPortalName = zScalerCloudList[0].Cloud_Type__c;
                }
            }
            //Added by Ankit - IBA-36 - End
        }
        return pd;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static User fetchPreferredFields(){
        User ur = [select id, AccountId, Account.Name, ContactId, phone, TimeZoneSidKey from User where id =: UserInfo.getUserId() limit 1];
        return ur;
    }
    @AuraEnabled
    public static String saveCaseRecord(Case objCase, List<String> contDocIds){
        System.debug('saveCaseRecord--objCase--'+objCase);
        objCase.Status = 'New';
		//added by Swathi:CR#779 Starts
        if(objCase.Case_Type__c == Null || objCase.Case_Type__c == ''){
            objCase.Case_Type__c = 'Problem';
        }
        //added by Swathi:CR#779 Ends
        insert objCase;
        updateContentDocLinks(contDocIds, objCase.Id);
        return objCase.Id;
    }
    public static void updateContentDocLinks(List<String> contDocIds, string recordId){

        if(contDocIds!=null && !contDocIds.isEmpty()){
            List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();
            for(Id cdId: contDocIds){
                ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=cdId);
                cdl.LinkedEntityId = recordId;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                contentDocLinks.add(cdl);
            }
            system.debug(contentDocLinks);
            //delete [Select Id from ContentDocumentLink where ContentDocumentId in :contDocIds];
            insert contentDocLinks;
            
            //Added Bu Anup : CR#613 - Start
            String postContent ='';
            List<FeedAttachment> listOfFeedAttachment = new List<FeedAttachment>();
            postContent += '  <b>Attachments Uploaded by Customer :'+contDocIds.size() + '</b><p>&nbsp;</p>\n\n';
            
            FeedItem post = new FeedItem();
            post.Title = 'Attachments added by customer';
            post.ParentId = recordId;
            post.Visibility = 'InternalUsers';
            post.IsRichText = true;
            post.Body = postContent;
            insert post;

            for(ContentVersion conVer : [select id from ContentVersion where ContentDocumentId IN :contDocIds]){
                FeedAttachment feedAttachment = new FeedAttachment();
                feedAttachment.FeedEntityId = post.Id;
                feedAttachment.RecordId = conVer.Id;
                feedAttachment.Type = 'CONTENT';
                listOfFeedAttachment.add(feedAttachment);
            }
            
            if(!listOfFeedAttachment.isEmpty()){
                insert listOfFeedAttachment;
            }
            //Added by Anup : CR#613 - End
        }        
    }
    @AuraEnabled
    public static void saveFile(Id idParent, String strFileName, String base64Data) {
        // // Decoding base64Data
        // base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        // System.debug('idParent:-'+idParent);
        // // inserting file

        // Attachment attachment = new Attachment();
        // attachment.Name = strFileName;
        // attachment.Body = EncodingUtil.base64Decode(base64Data);
        // attachment.ParentId = id.valueof(idParent);
        // insert attachment;
        // System.debug('attachment:-'+attachment);
        // return attachment;

        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.ContentDocumentId = null;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.Title = strFileName;
        cv.PathOnClient = strFileName;
        
        insert cv;
        
        //***This DEBUG statement must return an Id for the rest of the code to work***
        List<ContentVersion> cdlst = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id];

        ContentDocumentLink cdl = new ContentDocumentLink();
        if(cdlst != null && !cdlst.isEmpty()){
            cdl.ContentDocumentId = cdlst[0].ContentDocumentId;
            cdl.LinkedEntityId = id.valueof(idParent);
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }

        
    }

    @AuraEnabled(cacheable=true)
    public static String getPortalContent(String type){
        List<Portal_Content__c> plst = new List<Portal_Content__c>();
        String content = '';
        if(type == 'partners'){
            plst = [select Id, Content__c from Portal_Content__c where Portal_type__c = 'Partner'];
        }else{
            plst = [select Id, Content__c from Portal_Content__c where Portal_type__c = 'Customer'];
        }
        if(!plst.isEmpty()){
            content = plst[0].Content__c;
        }
        return content;
    }
        
}