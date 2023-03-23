import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import getMyWorkCenterRecord from '@salesforce/apex/MyWorkCenterLandingPageCtrl.getMyWorkCenterRecord';
import getTeamWorkCenterRecords from '@salesforce/apex/MyWorkCenterLandingPageCtrl.getTeamWorkCenterRecords';
import isLoggedInUserAManager from '@salesforce/apex/MyWorkCenterLandingPageCtrl.isLoggedInUserAManager';

export default class MyWorkCenterLandingPage extends NavigationMixin(LightningElement) {

    resultWrapperObj = [];
    teamWorkCenterRecord = [];
    isManager = false;

    connectedCallback() {
        console.log('Inside connectedCallback');
        this.fetchMyWorkCenterRecord();
    }

    async fetchMyWorkCenterRecord() {
        try {
            this.resultWrapperObj = await getMyWorkCenterRecord({ loggedInUserId: USER_ID });
            console.log('this.resultWrapperObj : ' + JSON.stringify(this.resultWrapperObj));
            this.isManager = await isLoggedInUserAManager({ loggedInUserId: USER_ID });
            console.log('this.isManager : ' + this.isManager);
            if (!this.isManager) {
                this.navigateToRecordViewPage();
            }
        } catch (error) {
            console.log('Error : ' + JSON.stringify(error));
        }

    }

    async fetchTeamWorkCenterRecords() {
        try {
            this.teamWorkCenterRecord = await getTeamWorkCenterRecords({ loggedInUserId: USER_ID });
            console.log('this.teamWorkCenterRecord : ' + JSON.stringify(this.teamWorkCenterRecord));
        } catch (error) {
            console.log('Error : ' + JSON.stringify(error));
        }
    }

    handleMyWorkCenterClick(event) {
        console.log('Inside handleMyWorkCenterClick');
        this.navigateToRecordViewPage();
    }

    handleTeamWorkCenterClick(event) {
        console.log('Inside handleTeamWorkCenterClick');
        this.navigateToListView();
    }

    navigateToListView() {
        console.log('Inside navigateToListView');
        // Navigate to the Contact object's Recent list view.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'My_WorkCenter__c',
                actionName: 'list'
            },
            state: {
                // 'filterName' is a property on the page 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.
                filterName: 'All' // or by 18 char '00BT0000002TONQMA4'
            }
        });
    }

    navigateToRecordViewPage() {
        console.log('Inside navigateToRecordViewPage - ' + this.resultWrapperObj[0].recordId);
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: `${this.resultWrapperObj[0].recordId}`,
                objectApiName: 'My_WorkCenter__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
}