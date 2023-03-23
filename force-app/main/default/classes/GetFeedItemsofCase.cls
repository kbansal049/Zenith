public class GetFeedItemsofCase{
    public Id equipmentRequestRecordId { get; set; }
    public String typeofTemplate { get; set; }
    public FeedItem latestFi { get; set; }
    public Id Caseid {get;set;}
    public Case Case1 {get;set;}

    public GetFeedItemsofCase() {
        getER();
        
    }
    public string url{get{
     String OrgURL= ZscalerCustomSetting__c.getInstance('OrgURL')!=null && ZscalerCustomSetting__c.getInstance('OrgURL').Value__c!=null ? ZscalerCustomSetting__c.getInstance('OrgURL').Value__c:'https://zscaler--uat.cs26.my.salesforce.com';
        url = OrgURL;
        return url;
    } set;}

    public Case getER(){
        List<Case> erlst = [SELECT id,owner.name,Description,CaseNumber,Subject,Status,Contactid,Contact.Name,Ownerid,Accountid,Account.Name,Case_Owner__c,Case_URL__c, Case_Type__c, Priority, Case_Owner_Manager_Name__c FROM Case where id = :equipmentRequestRecordId];
        if(!erlst.isEmpty()){
            return erlst[0];
        }
        return null;
    }

    public FeedItem getFeedItem() {
    	return null;
    }
    public String Casecomment{
    get{
        Casecomment = '';
        List<FeedItem> FeedItemlist= new List<FeedItem>([Select id,Body,ParentId,Status,Title,Type,Visibility,CreatedDate,CreatedBy.FirstName FROM FeedItem where ParentId=:equipmentRequestRecordId and type NOT IN ('ChangeStatusPost','TrackedChange') order by CreatedDate Desc Limit 1]);
        
        if(!FeedItemlist.isEmpty()){
            Casecomment=FeedItemlist[0].body;
            if(FeedItemlist[0].Type == 'EmailMessageEvent'){
                List<EmailMessage> emlst = new List<EmailMessage>([Select Id, HTMLBody from EmailMessage where ParentId=:equipmentRequestRecordId and (not fromAddress like '%@zscaler.com') order by Createddate Desc limit 1]);
                if(!emlst.isEmpty()){
                    Casecomment = emlst[0].HTMLBody;
                }
            }
        }
        return Casecomment;
    }set;}
}