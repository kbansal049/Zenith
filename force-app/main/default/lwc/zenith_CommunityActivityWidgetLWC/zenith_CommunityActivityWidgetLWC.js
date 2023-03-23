import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchLatestFeedItemData from '@salesforce/apex/Zenith_CommunityActivityController.fetchLatestFeedItemData'
import isGuest from '@salesforce/user/isGuest';
import icons from '@salesforce/resourceUrl/zScalarResources'
export default class Zenith_CommunityActivityWidgetLWC extends NavigationMixin(LightningElement) {

    solvedBadge = icons + '/zScalarResources/images/Solved.png'
    calendarImg = icons + '/zScalarResources/images/calendar.png';
    view_icon = icons + '/zScalarResources/images/view_icon.png';
    thumbs_up_icon = icons + '/zScalarResources/images/thumbs_up.png';
    comment_icon = icons + '/zScalarResources/images/comment_icon.png';
    limitCount = 5;
    offSetCount = 0;
    queryType = 'Latest';
    resultList = '';
    latestData = '';
    isLatest = true;
    isSolved = false;
    isUnread = false;
    isBookmarked = false;
    showSpinner = false;
    solvedData = '';
    unreadData = '';
    bookmarkedData = '';
    showViewMore = true;
    isGuestUser = isGuest;
    connectedCallback() {
        console.log('isGuestUser ---> ', this.isGuestUser);
        this.showSpinner = true;
        console.log('isLatest ----> ', this.isLatest);
        fetchLatestFeedItemData({ limitCount: this.limitCount, offsetCount: this.offSetCount, queryType: this.queryType }).then(data => {
            console.log('Data from Activity ---> ', data);
            this.latestData = data;
            this.resultList = data;
            this.showSpinner = false;
            console.log('Latest Activity Data ---> ', this.resultList);
        }).catch(error => {
            this.showSpinner = false;
            console.error('Some error from Activity ---> ', error);
        })
    }

    renderedCallback(){
        if(this.isGuestUser){
            this.template.querySelector('.bookmarkDiv').style.cursor = 'not-allowed';
            this.template.querySelector('.bookmarkDiv').style.color = '#ccc';
            this.template.querySelector('.unreadDiv').style.cursor = 'not-allowed';
            this.template.querySelector('.unreadDiv').style.color = '#ccc';
        }
    }


    latestPosts() {
        this.showSpinner = true;
        console.log('Latest Clicked');
        this.isLatest = true;
        this.isSolved = false;
        this.isUnread = false;
        this.isBookmarked = false;
        this.queryType = 'Latest';
        this.resultList = '';
        this.offSetCount = 0;
        this.showViewMore = false;
        if(this.isLatest == true){
            this.template.querySelector('.latestDiv').style.color = '#236BF5';
        }
        this.template.querySelector('.solvedDiv').style.color = '#000';
        this.template.querySelector('.unreadDiv').style.color = '#000';
        this.template.querySelector('.bookmarkDiv').style.color = '#000';
        fetchLatestFeedItemData({ limitCount: this.limitCount, offsetCount: this.offSetCount, queryType: this.queryType }).then(data => {
            console.log('Data from Activity ---> ', data);
            if(data.length < 5){
                this.showViewMore = false;
            }else{
                this.showViewMore = true;
            }
            this.latestData = data;
            //this.solvedData = data;
            this.resultList = data;
            this.showSpinner = false;
            console.log('Latest Activity Data ---> ', this.resultList);
        }).catch(error => {
            console.error('Some error from Activity ---> ', error);
        })
    }

    solvedPosts() {
        console.log('Solved Clicked');
        this.isLatest = false;
        this.isUnread = false;
        this.isBookmarked = false;
        this.isSolved = true;
        this.offSetCount = 0;
        console.log('isSolved ---> ', this.isSolved);
        this.resultList = '';
        this.queryType = 'Solutions';
        this.showViewMore = false;
        if(this.isSolved == true){
            this.template.querySelector('.solvedDiv').style.color = '#236BF5';
        }
        this.template.querySelector('.latestDiv').style.color = '#000';
        this.template.querySelector('.unreadDiv').style.color = '#000';
        this.template.querySelector('.bookmarkDiv').style.color = '#000';
        fetchLatestFeedItemData({ limitCount: this.limitCount, offsetCount: this.offSetCount, queryType: this.queryType }).then(data => {
            console.log('Data from Activity ---> ', data);
            if(data.length < 5){
                this.showViewMore = false;
            }else{
                this.showViewMore = true;
            }
            //this.latestData = data;
            this.solvedData = data;
            this.resultList = data;
            console.log('Solved Activity Data ---> ', this.resultList);
        }).catch(error => {
            console.error('Some error from Activity ---> ', error);
        })
    }

    unreadPosts() {
        console.log('Unread Clicked');
        if(this.isGuestUser == true){

        }
        else{
            this.isLatest = false;
        this.isSolved = false;
        this.isBookmarked = false;
        this.isUnread = true;
        this.queryType = 'Unread';
        this.resultList = '';
        this.showSpinner = true;
        this.offsetCount = 0;
        this.showViewMore = false;
        if(this.isUnread == true){
            this.template.querySelector('.unreadDiv').style.color = '#236BF5';
        }
        this.template.querySelector('.latestDiv').style.color = '#000';
        this.template.querySelector('.solvedDiv').style.color = '#000';
        this.template.querySelector('.bookmarkDiv').style.color = '#000';
        console.log('spinner ---> ', this.showSpinner);
        fetchLatestFeedItemData({ limitCount: this.limitCount, offsetCount: this.offSetCount, queryType: this.queryType }).then(data => {
            console.log('Data from Activity ---> ', data);
            //this.latestData = data;
            if(data.length < 5){
                this.showViewMore = false;
            }else{
                this.showViewMore = true;
            }
            this.unreadData = data;
            this.resultList = data;
            this.showSpinner = false;
            console.log('Unread Activity Data ---> ', this.resultList);
            console.log('spinner imperative call ---> ', this.showSpinner);
        }).catch(error => {
            console.error('Some error from Activity ---> ', error);
        })
        }
    }

    bookmarkPost() {
        console.log('Bookmark Clicked');
        if(this.isGuestUser == true){

        }
        else{
            this.isLatest = false;
        this.isSolved = false;
        this.isUnread = false;
        this.isBookmarked = true;
        this.queryType = 'Bookmark';
        this.resultList = '';
        this.offsetCount = 0;
        this.showViewMore = false;
        if(this.isBookmarked == true){
            this.template.querySelector('.bookmarkDiv').style.color = '#236BF5';
        }
        this.template.querySelector('.latestDiv').style.color = '#000';
        this.template.querySelector('.solvedDiv').style.color = '#000';
        this.template.querySelector('.unreadDiv').style.color = '#000';
        fetchLatestFeedItemData({ limitCount: this.limitCount, offsetCount: this.offSetCount, queryType: this.queryType }).then(data => {
            console.log('Data from Activity ---> ', data);
            //this.latestData = data;
            if(data.length < 5){
                this.showViewMore = false;
            }else{
                this.showViewMore = true;
            }
            this.bookmarkedData = data;
            this.resultList = data;
            console.log('Bookmarked Activity Data ---> ', this.resultList);
        }).catch(error => {
            console.error('Some error from Activity ---> ', error);
        })
        }
        
    }

    handleViewMore(){
        console.log('view More clicked ----> ');
        if(this.isLatest == true){
            this.queryType = 'Latest';
            this.offSetCount  += 5;
            fetchLatestFeedItemData({ limitCount: this.limitCount, offsetCount: this.offSetCount, queryType: this.queryType }).then(data => {
                console.log(' Latest Data from Activity ---> ', data);
                if(data.length == 0){
                    this.showViewMore = false;
                }
                //this.latestData = data;
                this.latestData = data;
                this.resultList = [...this.resultList, ...this.latestData];
                console.log('Latest Activity Data ---> ', this.resultList);
            }).catch(error => {
                console.error('Some error from Activity ---> ', error);
            })
        }
        else if(this.isSolved == true){
            this.queryType = 'Solutions';
            this.offSetCount += 5;
            fetchLatestFeedItemData({ limitCount: this.limitCount, offsetCount: this.offSetCount, queryType: this.queryType }).then(data => {
                console.log(' Solved Data from Activity ---> ', data);
                if(data.length == 0){
                    this.showViewMore = false;
                }
                //this.latestData = data;
                this.latestData = data;
                this.resultList = [...this.resultList, ...this.latestData];
                console.log('Solved Activity Data ---> ', this.resultList);
            }).catch(error => {
                console.error('Some error from Activity ---> ', error);
            })
            
        }
        else if(this.isUnread == true){
            this.queryType = 'Unread';
            this.offSetCount += 5;
            fetchLatestFeedItemData({ limitCount: this.limitCount, offsetCount: this.offSetCount, queryType: this.queryType }).then(data => {
                console.log(' Unread Data from Activity ---> ', data);
                if(data.length == 0){
                    this.showViewMore = false;
                }
                //this.latestData = data;
                this.latestData = data;
                this.resultList = [...this.resultList, ...this.latestData];
                console.log('Unread Activity Data ---> ', this.resultList);
            }).catch(error => {
                console.error('Some error from Activity ---> ', error);
            })
        }
        else if(this.isBookmarked == true){
            this.queryType = 'Bookmark';
            this.offSetCount += 5;
            fetchLatestFeedItemData({ limitCount: this.limitCount, offsetCount: this.offSetCount, queryType: this.queryType }).then(data => {
                console.log(' Bookmark Data from Activity ---> ', data);
                if(data.length == 0){
                    this.showViewMore = false;
                }
                //this.latestData = data;
                this.latestData = data;
                this.resultList = [...this.resultList, ...this.latestData];
                console.log('Bookmark Activity Data ---> ', this.resultList);
            }).catch(error => {
                console.error('Some error from Activity ---> ', error);
            })
        }
    }

    navigateToFeedItemPage(event){
        var feedItem = event.target.dataset.targetId;
        console.log('FeedItem Id : .... ' , feedItem);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: feedItem,
                actionName: 'view'
            }
        });
    }

    handleUser(event){
        var userId = event.target.dataset.targetId;
        console.log('userId ---> ', userId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: userId,
                actionName: 'view'
            }
        });
    }
}