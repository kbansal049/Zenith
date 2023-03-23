import { api, LightningElement, wire } from 'lwc';
import fetchCommunityStats from '@salesforce/apex/Zenith_CommunityStatsApexController.fetchCommunityStats';
import faviconIcons from '@salesforce/resourceUrl/zScalarResources';
export default class Zenith_CommunityStatsLWC extends LightningElement {

    // @wire(fetchCommunityStats)
    // wireFlows({ error, data }) {
    //     if (data) {
    //         console.log('Data check ----> ', data);
    //     }
    //     else if(error){
    //         console.error('error ->>> ', error);
    //     }
    // }
    statsWrapper;
    bestAnswerCount;
    communityMembersCount;
    feedPostCount;
    likesCounter;
    @api
    membersIcon;
    @api
    postIcon;
    @api
    solutionsIcon;
    @api
    likesIcon;

    connectedCallback(){
        fetchCommunityStats().then((result)=>{
            console.log('Result ',result);
            this.statsWrapper = result;
            console.log('statsWrapper -> ', this.statsWrapper);
            this.bestAnswerCount = result.bestAnswerCount;
            console.log('bestAnswerCount ---> ', this.bestAnswerCount);
            this.communityMembersCount = result.communityMembersCount;
            console.log('communityMembersCount ---> ', this.communityMembersCount);
            this.feedPostCount = result.feedPostCount;
            console.log('feedPostCount ---> ', this.feedPostCount);
            if(result.likesCounter == undefined || result.likesCounter == null){
                this.likesCounter = 0;
            }
            this.likesCounter = result.likesCounter;
            console.log('likesCounter --->', this.likesCounter);
        })
        .catch((error)=>{
            console.log('Error ',error)
        })


        if(this.membersIcon === undefined || this.membersIcon === '' || this.membersIcon === null){
            this.membersIcon = faviconIcons + '/zScalarResources/Favicons/Members.png';
        }
        if(this.postIcon === undefined || this.postIcon === '' || this.postIcon === null){
            this.postIcon = faviconIcons + '/zScalarResources/Favicons/Posts.png';
        }
        if(this.solutionsIcon == undefined || this.solutionsIcon == '' || this.solutionsIcon == null){
            this.solutionsIcon = faviconIcons + '/zScalarResources/Favicons/Solutions.png';
        }
        if(this.likesIcon == undefined || this.likesIcon == '' || this.likesIcon == null){
            this.likesIcon = faviconIcons + '/zScalarResources/Favicons/Likes.png';
        }
    }
}