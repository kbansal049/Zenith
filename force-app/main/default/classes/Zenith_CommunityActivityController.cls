public without sharing class Zenith_CommunityActivityController {
    
    public static final String COMM_ID = Label.Zenith_Network_Id;
    public static final Id LOGGED_IN_USER = UserInfo.getUserId();
    
    
    @AuraEnabled(cacheable = true)
    public static List<LatestSolvedFeedItemWrapper> fetchLatestFeedItemData(Integer limitCount, Integer offsetCount, String queryType){
        
        List<FeedItem> fiList = new List<FeedItem>();
        List<LatestSolvedFeedItemWrapper> fiWrpList = new List<LatestSolvedFeedItemWrapper>();
        Map<id,User> userDetail=new Map<id,User>();
        List<Id> userIds =  new List<Id>();
        if(queryType == 'Latest'){
            fiList = Zenith_CommunityActivityController.fetchLatestDataFromQuery(limitCount, offsetCount);    
        }
        else if(queryType == 'Solutions'){
            fiList = Zenith_CommunityActivityController.fetchSolutionsDataFromQuery(limitCount, offsetCount);
        }
        
        else if(queryType == 'Unread'){
            user currentUser = [Select Id, LastLoginDate from User WHERE Id = :LOGGED_IN_USER];
            fiList = Zenith_CommunityActivityController.fetchUnreadDataFromQuery(limitCount, offsetCount, currentUser);
        }
        else if(queryType == 'Bookmark'){
            user currentUser = [Select Id, LastLoginDate from User WHERE Id = :LOGGED_IN_USER];
            fiList = Zenith_CommunityActivityController.fetchBookmarkFromQuery(limitCount, offsetCount, currentUser);
        }
        
        for(FeedItem feed : fiList){
            userIds.add(feed.CreatedById);
        }
        
        for(user u : [select id, SmallPhotoURL, LastLoginDate from user where id IN:userIds]){
            userDetail.put(u.Id, u);
        }
        
        if(fiList.size() > 0){
            for(FeedItem feed : fiList){
                LatestSolvedFeedItemWrapper fiWrp = new LatestSolvedFeedItemWrapper();
                fiWrp.userImg = userDetail.get(feed.CreatedById).SmallPhotoURL;
                fiWrp.bestAnswerId = feed.BestCommentId;
                fiWrp.createdDate = feed.CreatedDate;
                if(feed.Title!='' && feed.Title!=null){
                    fiWrp.feedItemTitle = feed.Title;    
                }
                if(feed.body!='' && feed.body!=null){
                    fiWrp.feedItemBody = feed.Body.stripHtmlTags();    
                }
                fiWrp.createdByName = feed.CreatedBy.Name;
                fiWrp.createdById = feed.CreatedById;
                fiWrp.feedLikesCount = feed.LikeCount;
                fiWrp.feedCommentCount = feed.CommentCount;
                fiWrp.feedItemId = feed.Id;
                ConnectApi.ReadByPage feedRead=ConnectApi.chatterfeeds.getReadByForFeedElement(COMM_ID, feed.Id);
                fiWrp.viewsCount = Integer.valueOf(feedRead.total);
                fiWrp.userLastLoginDate = userDetail.get(feed.CreatedById).LastLoginDate;
                fiWrpList.add(fiWrp);
            }
            
        }
        System.debug('Wrapper ---> ' + fiWrpList.size());
        return fiWrpList;
    }
    
    //Method to return the FeedItems based on CreatedDate DESC     
    public static List<FeedItem> fetchLatestDataFromQuery(Integer limitCount, Integer offsetCount){
        
        return [Select Id, Type, NetworkScope, BestCommentId, CreatedDate, CreatedById, CreatedBy.Name,
                Title, Body, LikeCount, CommentCount
                From FeedItem
                WHERE NetworkScope = :COMM_ID
                Order By CreatedDate DESC
                LIMIT :limitCount OFFSET :offsetCount];
    }
    
    //Method to return the FeedItems with BestComment    
    public static List<FeedItem> fetchSolutionsDataFromQuery(Integer limitCount, Integer offsetCount){
        return [Select Id, Type, NetworkScope, BestCommentId, CreatedDate, CreatedById, CreatedBy.Name,
                Title, Body, LikeCount, CommentCount
                From FeedItem
                WHERE NetworkScope = :COMM_ID
                AND BestCommentId != Null
                Order By CreatedDate DESC
                LIMIT :limitCount OFFSET :offsetCount];
    }
    
    //Method to return the Unread FeedItem for a particular user
    public static List<FeedItem> fetchUnreadDataFromQuery(Integer limitCount, Integer offsetCount, User currentUser){
        return [Select Id, Type, NetworkScope, BestCommentId, CreatedDate, CreatedById, CreatedBy.Name,
                Title, Body, LikeCount, CommentCount
                From FeedItem
                WHERE NetworkScope = :COMM_ID
                AND CreatedDate > :currentUser.LastLoginDate
                AND CreatedById != :currentUser.Id
                Order By CreatedDate DESC
                LIMIT :limitCount OFFSET :offsetCount];
    }
    
    
    // Method to return the Bookmarked FeedItems for a particular user
    public static List<FeedItem> fetchBookmarkFromQuery(Integer limitCount, Integer offsetCount, User currentUser){
        Set<Id> feedItemIdSet = new Set<Id>();
        ConnectApi.FeedElementPage feedItemPage = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(COMM_ID, ConnectApi.FeedType.Bookmarks,currentUser.Id);
        for(ConnectApi.FeedElement fi : feedItemPage.elements){
            feedItemIdSet.add(fi.Id);
        }
        
        return [Select Id, Type, NetworkScope, BestCommentId, CreatedDate, CreatedById, CreatedBy.Name,
                Title, Body, LikeCount, CommentCount
                From FeedItem
                WHERE NetworkScope = :COMM_ID
                AND Id IN :feedItemIdSet
                Order By CreatedDate DESC
                LIMIT :limitCount OFFSET :offsetCount];
    }
    
    // Wrapper Class used to wrap the FeedItem data
    public class LatestSolvedFeedItemWrapper{
        @AuraEnabled public String userImg;
        @AuraEnabled public String bestAnswerId;
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public String feedItemTitle;
        @AuraEnabled public String feedItemBody;
        @AuraEnabled public String createdByName;
        @AuraEnabled public String createdById;
        @AuraEnabled public Integer feedLikesCount;
        @AuraEnabled public Integer feedCommentCount;
        @AuraEnabled public String feedItemId;
        @AuraEnabled public Integer viewsCount;
        @AuraEnabled public DateTime userLastLoginDate;
    }    
    
}