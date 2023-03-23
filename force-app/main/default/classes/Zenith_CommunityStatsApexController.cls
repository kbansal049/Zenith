public without sharing class Zenith_CommunityStatsApexController {
	public static final String COMM_ID = Label.Zenith_Network_Id;
    
    @AuraEnabled
    public static StatsWrapper fetchCommunityStats(){
        StatsWrapper wrp = new StatsWrapper();
        
        List<FeedItem> feedItemList = [Select Id from FeedItem WHERE NetworkScope = :COMM_ID];
        wrp.feedPostCount = feedItemList.size();
        
        List<FeedItem> bestAnsList = [Select Id, BestCommentId from FeedItem WHERE BestCommentId != Null AND NetworkScope = :COMM_ID];
        wrp.bestAnswerCount = bestAnsList.size();
        
        List<User> userList = [SELECT Id, Profile.Name  FROM User  WHERE IsActive = TRUE AND Profile.Name IN ('System Administrator','Customer Support - Internal')];
        wrp.communityMembersCount = userList.size();
        
        
        Zenith_Community_Stats__mdt commStats = Zenith_Community_Stats__mdt.getInstance('LikeStats');
        
        wrp.likesCounter = Integer.valueOf(commStats.Likes_Counter__c);
        System.debug('Wrapper Object ----> ' + wrp);
        return wrp;
    }
    
    public class StatsWrapper{
        @AuraEnabled public Integer communityMembersCount;
        @AuraEnabled public Integer feedPostCount;
        @AuraEnabled public Integer bestAnswerCount;
        @AuraEnabled public Integer likesCounter;
    }
}