global without sharing class Zenith_LikesCounterBatch implements Database.Batchable<sObject>, Database.Stateful{
	
    global static Integer likesCounter;
    public static final String COMM_ID = Label.Zenith_Network_Id;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String queryOne = Label.Likes_Query_Priority_1;
        String queryTwo = Label.Likes_Query_Priority_2;
        if(queryOne != '' || queryOne != null){
            return Database.getQueryLocator(queryOne + 'AND NetworkScope =' + COMM_ID);
        }
        else{
            return Database.getQueryLocator(queryTwo + 'AND NetworkScope =' + COMM_ID);
        }
    }
    
    global void execute(Database.BatchableContext bc, List<FeedItem> scope){
        for(FeedItem fi : scope){
            likesCounter += fi.LikeCount;
        }
    }
    
    global void finish(Database.BatchableContext bc){

        //Fetch CustomMetadata Record
        List<Zenith_Community_Stats__mdt> recordList = [Select DeveloperName,MasterLabel, Likes_Counter__c from Zenith_Community_Stats__mdt];
        
        // instance of record
        MetaData.CustomMetadata mData = new MetaData.CustomMetadata();
        mData.fullName = 'Zenith_Community_Stats__mdt.'+ recordList[0].DeveloperName;
        mData.label = recordList[0].MasterLabel;
        
        //instance of value
        MetaData.CustomMetadataValue cvalue = new MetaData.CustomMetadataValue();
        cvalue.field = 'Likes_Counter__c';
        cvalue.value = likesCounter;
        
        //Adding the value to the record
        mData.values.add(cvalue);
        
        //Creating the container for the Metadata
        MetaData.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(mData);
        
        //Enqueue Deployment to the Org
        Metadata.Operations.enqueueDeployment(mdContainer, null);
        
    }
}