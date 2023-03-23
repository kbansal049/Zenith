import { LightningElement,track, api, wire } from 'lwc';
import checkIfItsAllowed from '@salesforce/apex/AddOpportunityTeamMember.checkIfItsAllowed';
import createOpportunityTeamMember from '@salesforce/apex/AddOpportunityTeamMember.createOpportunityTeamMember';
import deleteOppTeamMember from '@salesforce/apex/AddOpportunityTeamMember.deleteOppTeamMember';
import fetchMetaData from '@salesforce/apex/AddOpportunityTeamMember.fetchMetaData';
import saveOppTeamMember from '@salesforce/apex/AddOpportunityTeamMember.saveOppTeamMember';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import USER_FIELD from '@salesforce/schema/OpportunityTeamMember.UserId';
import TAG_FIELD from '@salesforce/schema/OpportunityTeamMember.TAG__c';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const DELAY = 300;

const actions = [
    { label: 'Delete', name: 'delete' },
    { label: 'Edit', name: 'edit' },
];

export default class AddOpportunityTeamMemberLWC extends NavigationMixin(LightningElement) {

    @track isTeamMemCreationModalOpen = false;
    @track currentStep = "1";
    @track isDisabled = true;
    @api recordId;
    @api recordToEdit;
    @track hasEditFormChanged = true;
    @track otmList;
    @track loading = false;
    @track existingUserVal;
    @track existingTagVal;
    @track existingRoleVal;
    @track teamRoleList;
    @track selectedViewvalue = null;
    @track hasError = false;
    @track error;

    tagField = TAG_FIELD;
    userField = USER_FIELD;

    @track credList = []; 

    searchKey;

    index = 0;

    @track columns = [
        { label: 'User Name', fieldName: 'UserName', editable: false },
        { label: 'Roles', fieldName: 'TeamMemberRole', editable: false },
        { label: 'Additional Roles', fieldName: 'TAG__c', editable: false },
        {
            type: 'action',
            typeAttributes: { rowActions: actions },
        },
    ];

    record = {};

    fields = ["Name","Email","Phone"];
    displayFields = 'Name, Email, Phone';

    @wire(getPicklistValues, { recordTypeId: '01270000000EAPJ', fieldApiName: TAG_FIELD })
    taglVals;

    @wire(fetchMetaData)
      wiredCallbackResult({ error, data }) {
          console.log('OTM Role =>',data);
        if (data) {
            this.teamRoleList = JSON.parse(data);
            console.log('Mayank, this.teamRoleList:', this.teamRoleList.length);
            if(this.teamRoleList.length === 1){
                this.selectedViewvalue = this.teamRoleList[0].value;
            }
            
        } else if (error) {
          //Set Error Details
        }
      }

    connectedCallback() {
        this.loading = true;
       // this.addInitialRow();
        this.openTeamMemCreationModal();
    }

    openTeamMemCreationModal(){
        this.isTeamMemCreationModalOpen = true;
        this.loading = true;
        checkIfItsAllowed({oppId:this.recordId})
        .then(result => {
            this.isAllowed = result.isAllowed;
            if(this.isAllowed){
                this.hasError = false;
                this.otmList = result.oppTeamList;
                for ( var i = 0; i < this.otmList.length; i++ ) {
                    var row = this.otmList[i];
                   
                    if ( row.User ) {
                        row.UserName = row.User.Name;
                    }
                }
                this.loading = false;
                
            }else{
                this.loading = false;
                this.hasError = true;
                this.error = 'Only SE Users or Team Members are allowed to leverage this functioanlity';
            }
            
            
            
        }).catch(error => {
            this.error = error;
            this.loading = false;
            this.hasError = true;
        });
    }

    get showFirstStep() {
        return this.currentStep && this.currentStep === "1" ? true : false;
    }
    get showSecondStep() {
        return this.currentStep && this.currentStep === "2" ? true : false;
    }
    get showThirdStep() {
        return this.currentStep && this.currentStep === "3" ? true : false;
    }

    handleClick(){
        this.currentStep = "2";
        this.credList = [];
        this.index = 0;
        this.addInitialRow();
    }

    previous(){
        this.currentStep = "1";
    }

    handleViewChange(event) {
        if(event.detail.value){
            for (var i = 0; i < this.credList.length; i++) {
                if(i == event.target.dataset.id){
                    this.credList[i].role = event.detail.value;
                }
            }
        }
        this.validateData();
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            case 'edit':
                this.editRow(row);
                break;
            default:
        }
    }

    editRow(row){
        this.currentStep = "3";
        this.recordToEdit = row.Id;
        this.existingUserVal = row.UserId;
        this.existingTagVal = row.TAG__c;
        this.existingRoleVal = row.TeamMemberRole;
    }

    deleteRow(row) {
        this.loading = true;

        deleteOppTeamMember({oppTeamId:row.Id})
            .then(result => {
                this.loading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Deleted',
                        variant: 'success'
                    })
                );
                this.currentStep = "1"; 
                this.error = null;   
                this.hasError = false;   
                this.openTeamMemCreationModal();  
            }).catch(error => {
                this.loading = false;
                this.error = error;
                this.hasError = true;
            });
    }

    addInitialRow(){
        this.credList.push ({
            Index : this.index,
            oppId: this.recordId,
            user: null,
            tagList : null,
            role: this.selectedViewvalue,
            filterClause : 'where Profile.UserLicense.LicenseDefinitionKey = \'SFDC\'',
            unfinished : true,
        });
        this.index++;
        this.validateData();
    }

    saveEditForm(){

        this.loading = true;
        saveOppTeamMember({oppTeamId:this.recordToEdit, userId:this.existingUserVal, tagList:this.existingTagVal, role:this.existingRoleVal})
            .then(result => {
                this.loading = false;
                this.index= 1;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Deleted',
                        variant: 'success'
                    })
                );
                this.currentStep = "1"; 
                this.error = null;   
                this.hasError = false;   
                this.openTeamMemCreationModal();  
            }).catch(error => {
                this.loading = false;
                this.error = error;
                this.hasError = true;
            });
    }

    onRoleChange(event){
        this.existingRoleVal = event.detail.value;
        this.hasEditFormChanged = false;
    }

    onTagChange(event){
        this.existingTagVal = event.detail.value;
        this.hasEditFormChanged = false;
    }

    validateData(){
        let notValid = 0;
        let mySet = new Set();
        if(this.credList && this.credList.length > 0){
            for (var i = 0; i < this.credList.length; i++) {
                if(this.credList[i].user == '' ||  this.credList[i].user == undefined || this.credList[i].tagList == '' || this.credList[i].tagList == undefined || this.credList[i].role == '' || this.credList[i].role == null){
                    this.credList[i].unfinished = true;
                    notValid++;
                }
               
                else{
                    this.credList[i].unfinished = false;
                }
            }
            
            if(notValid === 0){
                this.isDisabled = false; 
            }else{
                this.isDisabled = true; 
            }
            return notValid>0 ? true : false;
        }else{
            return true;
        }
    }

    handleTagChange(event){
        if(event.detail.value){
            for (var i = 0; i < this.credList.length; i++) {
                if(i == event.target.dataset.id){
                    this.credList[i].tagList = null;
                    event.detail.value.forEach(tag => {
                        if(this.credList[i].tagList === null || this.credList[i].tagList === ''){
                            this.credList[i].tagList = tag;
                        }else{
                            this.credList[i].tagList = this.credList[i].tagList + ';'+ tag;
                        }
                        
                    });
                }
            }
        }
        this.validateData();
    }

    handleLookup(event){
        if(event.detail.data && event.detail.data.sourceId !=  undefined){
            for (var i = 0; i < this.credList.length; i++) {
                if(i == event.detail.data.sourceId){
                    this.credList[i].user = event.detail.data.recordId ? event.detail.data.recordId : '';
                }
            }
        }
        this.validateData();
    }

    submitOTMRequest(){
        let detailsUnFilled = this.validateData();
        if(!detailsUnFilled){
            this.loading = true;
            let dataToSend = JSON.stringify(this.credList);
            createOpportunityTeamMember({jsonStr:dataToSend})
                .then(result => {
                    this.isDisabled = true;
                    this.loading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records Created',
                            variant: 'success'
                        })
                    );
                    this.currentStep = "1"; 
                    this.error = null;   
                    this.hasError = false;   
                    this.openTeamMemCreationModal();  
                }).catch(error => {
                    this.loading = false;
                    this.error = error;
                    this.hasError = true;
                });
        }
        
    }

    removeRow(event){
        let ind = event.currentTarget.dataset.id;
        if(ind){
            if(this.credList.length>0)
                this.credList.splice(ind, 1);
            this.index = 0
            for (var i = 0; i < this.credList.length; i++) {
                this.credList[i].Index = this.index;
                this.index++;
            }
        }
        this.validateData();
    }

    closeTeamMemCreationModal(){
        this.navigateToRecordViewPage();
    }


    navigateToRecordViewPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }


}