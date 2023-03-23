import { LightningElement, track, wire,api} from 'lwc';
import getNextEmailTrackers from '@salesforce/apex/getEmailTrackerData.getNextEmailTrackers';
import updateEmailTracker from '@salesforce/apex/getEmailTrackerData.updateEmailTracker';
import getMetadataPicklistsEmailTracker from '@salesforce/apex/getEmailTrackerData.getMetadataPicklistsEmailTracker'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import EMAIL_TRACKER_OBJECT from '@salesforce/schema/Email_Tracker__c';
import Email_Category_FIELD from '@salesforce/schema/Email_Tracker__c.Email_Category__c';
import Requester_Org_FIELD from '@salesforce/schema/Email_Tracker__c.Requester_Org__c';
import Priority_FIELD from '@salesforce/schema/Email_Tracker__c.Priority__c';
import Status_FIELD from '@salesforce/schema/Email_Tracker__c.Status__c';
import getUserInformation from '@salesforce/apex/OrderTrackerDashboard.getUserInformation';
import getEmailTracker from '@salesforce/apex/getEmailTrackerData.getEmailTracker';
import mergeRecords from '@salesforce/apex/getEmailTrackerData.mergeRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class EmailTrackerScreen extends LightningElement {
    @api clickedTab;
    @track orderTrackerId;
    @track emailTrackerId;//used for passing email tracker record ID to mail chain component 
    @track isEmailTracker = 'emailTracker';
    @track mainEmailTrackers = [];//total email trackers
    @track tableEmailTrackers = [];//mainEmailTrackers used in HTML to show emails on page   
    @track searchOrderTrackers = [];//variable to store searched mails
    @track singlePageOrders = [];//variable to store emails to show on a single page 
    @track totalRecords = 0;//total number of records
    @track isNoRecords = true;
    @track isNoFilter = true;
    @track disableSearch = false;
    @track pageOption = [
        { label: "10", value: "10" },
        { label: "25", value: "25" },
        { label: "50", value: "50" },
        { label: "100", value: "100" }
    ];//list of number of records to display on a page

    @track pageNumber = 1;//page index
    @track showPrevButton = true;//boolean to show Next button
    @track showNextButton = true;//boolean to show Previous button
    @track viewPicklistValues = [
        { label: "All", value: "All" },
        { label: "Open", value: "open" },
        { label: "Closed", value: "closed" }
    ];
    @track selectedViewvalue = 'All';//selected status value from status picklist
    @track searchFilterStr = '';

    @track selectedPageOption = 25;//number of records per page
    @track totalPages;//total number of pages
    //variables to show number of records as per page options
    @track recordStart = 0;
    @track recordEnd = 0;

    //picklst values
    @track emailCategoryPicklistValues;
    @track requestorOrgPicklistValues;
    @track priorityPicklistValues;
    @track statusPicklistValues;


    @track indexOfEmailTracker;
    @track oldRemarksValue = '';
    @track editRemarksValue = '';
    @track oldRequesterNameValue = '';
    @track editRequesterNameValue = '';
    @track oldPercentCompleteValue = '';
    @track editPercentCompleteValue = '';
    @track flagEdit = 0;
    @track openModalEditor = false;
    @track isRemarksEditor = false;
    @track isRequesterNameEditor = false;
    @track isCompletePercentEditor = false;
    @track editoSaveButtonDisable = false;

    @track userProfile='';
    @track userId='';
    @track isUserAdministrator='';

    @track assignedUser='';
    @track openAssignedUserModal=false;
    @track oldPicklistValue='';

    @track emailTrackerNew;
    @track emailTrackerId;

    @track isShowParentEmailTrackerComponent = true;
    @track isSpinnerLoading = true;

    @track firstAssigneeMap;
    @track secondAssigneeMap;
    @track thirdAssigneeMap;
    @track firstAssigneePicklist;
    @track secondAssigneePicklist;
    @track thirdAssigneePicklist;

    @track MessageWhenNoRecords='';

    @track blankSpace=true;

    @track newAssignee='';
    @track selectedRecords = [];
    openMergeModal = false;
    showMergeButton =false;


    //get the picklist value of status field from Order Tracker Object
    @wire(getObjectInfo, { objectApiName: EMAIL_TRACKER_OBJECT })
    emailMetadata;

    @wire(getPicklistValues,
        {
            recordTypeId: '$emailMetadata.data.defaultRecordTypeId',
            fieldApiName: Email_Category_FIELD
        }
    )
    wiredEmailCategoryPickList({ data }) {
        if (data) {
            this.emailCategoryPicklistValues = data.values;
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$emailMetadata.data.defaultRecordTypeId',
            fieldApiName: Requester_Org_FIELD
        }
    )
    wiredRequestorOrgPickList({ data }) {
        if (data) {
            this.requestorOrgPicklistValues = data.values;
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$emailMetadata.data.defaultRecordTypeId',
            fieldApiName: Priority_FIELD
        }
    )
    wiredPriorityPickList({ data }) {
        if (data) {
            this.priorityPicklistValues = data.values;
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$emailMetadata.data.defaultRecordTypeId',
            fieldApiName: Status_FIELD
        }
    )
    wiredStatusPickList({ data }) {
        if (data) {
            this.statusPicklistValues = data.values;
        }
    }


    connectedCallback() {
        this.isSpinnerLoading=true;
        this.getUserInformation();
    }

    getUserInformation()
    {
        getUserInformation()
        .then(result=>{
           
            this.userProfile=result['Profile'];
            this.userId=result['UserId'];       

            if(this.userProfile == 'System Administrator')
            {
                this.isUserAdministrator=true;
            }
            else
            {
                this.isUserAdministrator=false;
            }
            this.getMetadataPicklists();
        }).catch(error =>{

        })
    }
    getMetadataPicklists()
    {
        getMetadataPicklistsEmailTracker()
            .then(result => {
                let firstAssignee = result.firstAssignee;
                let secondAssignee = result.secondAssignee;
                let thirdAssignee = result.thirdAssignee;
                let picklist1 = [];
                let picklist2 = [];
                let picklist3 = [];
                let map1 = new Map();
                let map2 = new Map();
                let map3 = new Map();

                if(this.isUserAdministrator == true)
                {
                    for (var i = 0; i < firstAssignee.length; i++) {
                        picklist1.push({ label: firstAssignee[i].Label, value: firstAssignee[i].User_Id__c });
                        map1.set(firstAssignee[i].User_Id__c, firstAssignee[i].Label);
                    }
                    for (var i = 0; i < secondAssignee.length; i++) {
                        picklist2.push({ label: secondAssignee[i].Label, value: secondAssignee[i].User_Id__c });
                        map2.set(secondAssignee[i].User_Id__c, secondAssignee[i].Label);
                    }
                    for (var i = 0; i < thirdAssignee.length; i++) {
                        picklist3.push({ label: thirdAssignee[i].Label, value: thirdAssignee[i].User_Id__c });
                        map3.set(thirdAssignee[i].User_Id__c, thirdAssignee[i].Label);
                    }

                }
                else if(this.isUserAdministrator == false)
                {
                    for (var i = 0; i < firstAssignee.length; i++) {
                        map1.set(firstAssignee[i].User_Id__c, firstAssignee[i].Label);
                        if(firstAssignee[i].User_Id__c == this.userId)
                        {
                            picklist1.push({label:firstAssignee[i].Label, value:firstAssignee[i].User_Id__c});
                        }
                        
                        
                    }
                    for (var i = 0; i < secondAssignee.length; i++) {
                        
                        map2.set(secondAssignee[i].User_Id__c, secondAssignee[i].Label);
                        if(secondAssignee[i].User_Id__c == this.userId)
                        {
                            picklist2.push({ label: secondAssignee[i].Label, value: secondAssignee[i].User_Id__c });
                        }
                    }
                    for (var i = 0; i < thirdAssignee.length; i++) {
                        
                        map3.set(thirdAssignee[i].User_Id__c, thirdAssignee[i].Label);
                        if(thirdAssignee[i].User_Id__c == this.userId)
                        {
                            picklist3.push({ label: thirdAssignee[i].Label, value: thirdAssignee[i].User_Id__c });
                        }
                    }

                }

                this.firstAssigneeMap = map1;
                this.firstAssigneePicklist = picklist1;


                this.secondAssigneeMap = map2;
                this.secondAssigneePicklist = picklist2;


                this.thirdAssigneeMap = map3;
                this.thirdAssigneePicklist = picklist3;
       

            }).catch(error => {

            })
        this.getEmailTrackers();
    }

    getEmailTrackers() {

        this.tableEmailTrackers=[];
        getNextEmailTrackers({
            pageNumber: this.pageNumber,
            pageLimit: this.selectedPageOption,
            viewPicklistValue: this.selectedViewvalue,
            searchFilterStr: this.searchFilterStr,
            selectedTab : this.clickedTab
        })
            .then((result) => {
                let emails = result['emailTrackerList'];
                this.pageNumber = result['pageNumber'];
                this.totalRecords = result['totalEmailTrackerRecords'];
                this.recordStart = result['recordStart'];
                this.recordEnd = result['recordEnd'];
                this.totalPages = Math.ceil(result['totalEmailTrackerRecords'] / this.selectedPageOption);
                this.showNextButton = (this.pageNumber == this.totalPages || this.totalPages == 0);
                this.showPrevButton = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
             
                this.mainEmailTrackers = emails;
                let length;
                if (this.recordEnd - this.recordStart + 1 < this.selectedPageOption) {
                    length = this.recordEnd - this.recordStart + 1;
                }
                else {
                    length = this.selectedPageOption;
                }
                if (this.totalRecords == 0 && (this.searchFilterStr == '' && this.selectedViewvalue == 'All')) {
                    this.disableSearch = true;
                    this.isNoRecords = false;
                    this.isNoFilter = false;
                }
      
                else if (this.totalRecords == 0 && (this.searchFilterStr != '' || this.selectedViewvalue != 'All')) {
                    this.disableSearch = false;
                    this.isNoRecords = false;
                    this.isNoFilter = true;
                }
          
                else if (this.totalRecords != 0) {
                    this.disableSearch = false;
                    this.isNoRecords = true;
                    this.isNoFilter = true;
                }

                if(this.clickedTab == 'Assigned To Me')
                {
                   this.MessageWhenNoRecords='No Email Tickets Assigned To You!!'; 
                }
                else if(this.clickedTab == 'All')
                {
                    this.MessageWhenNoRecords='No Email Trackers!!';
                }
                var emailList = [];
                for (var i = 0; i < length; i++) {

                    if(this.isUserAdministrator == false)
                    {

                        if(emails[i].Assigned_To_1st_Assignee__c == this.userId || (emails[i].Assigned_To_1st_Assignee__c == undefined && this.firstAssigneePicklist.length != 0))
                        {
                       
                            emails[i].disable1stAssignee=false;
                        }                        
                        else 
                        {
                       
                            emails[i].disable1stAssignee=true;
                        }
                        
                        if(emails[i].Assigned_To_2nd_Assignee__c == this.userId || (emails[i].Assigned_To_2nd_Assignee__c == undefined && this.secondAssigneePicklist.length != 0))
                        {
                       
                            emails[i].disable2ndAssignee=false;
                        }                        
                        else
                        {
                      
                            emails[i].disable2ndAssignee=true;
                        }
                        if(emails[i].Assigned_To_3rd_Assignee__c == this.userId || (emails[i].Assigned_To_3rd_Assignee__c == undefined && this.thirdAssigneePicklist.length !=0) )
                        {
                 
                            emails[i].disable3rdAssignee=false;
                        }                        
                        else
                        {
                  
                            emails[i].disable3rdAssignee=true;
                        }
                    }
                    else if(this.isUserAdministrator == true)
                    {
                        emails[i].disable1stAssignee=false;
                        emails[i].disable2ndAssignee=false;
                        emails[i].disable3rdAssignee=false;
                    }
                    if(emails[i].TAT__c != '0.0')
                    {emails[i].TAT__c= this.tatFormat(emails[i].TAT__c);}
                    else if(emails[i].TAT__c == '0.0')  
                    {  emails[i].TAT__c='';  }  
                    if(emails[i].Status__c=='Completed' || emails[i].Status__c == 'Merged' )
                    {
                        emails[i].disableStatus=true;   
                    }  else
                    {
                        emails[i].disableStatus=false;  
                    }     
                    emails[i].Assigned_To_1st_Assignee__c=this.firstAssigneeMap.get(emails[i].Assigned_To_1st_Assignee__c);
                    emails[i].Assigned_To_2nd_Assignee__c=this.secondAssigneeMap.get(emails[i].Assigned_To_2nd_Assignee__c);
                    emails[i].Assigned_To_3rd_Assignee__c=this.thirdAssigneeMap.get(emails[i].Assigned_To_3rd_Assignee__c);
                    emails[i].Complete__c = (emails[i].Complete__c ? emails[i].Complete__c / 100 : '');                    
                    emails[i].Date_Received__c = (emails[i].Date_Received__c ? this.dateFormat(emails[i].Date_Received__c,'dateTime') : ' ');
                    emails[i].Completion_Date__c = (emails[i].Completion_Date__c ? this.dateFormat(emails[i].Completion_Date__c,'dateTime') : ' ');
                    emailList.push(emails[i]);
                }
                this.tableEmailTrackers = emailList;
                console.log(' this.tableEmailTrackers->>', this.tableEmailTrackers);
                this.handleSpinnerLoadingOff();
            }).catch((error) => {
                this.template.querySelector('c-custom-toast-component').showToast('error', 'No Record to Display');
                this.handleSpinnerLoadingOff();
            });


    }



    //function to handle status change
    handleViewChange(event) {
        this.isSpinnerLoading = true;
        this.selectedViewvalue = event.detail.value;
        this.pageNumber = 1;
        this.getEmailTrackers();
    }

    //handle search button event
    handleSearchInput(event) {
        this.searchFilterStr = event.target.value;
        if (event.target.value == '') {
            this.isSpinnerLoading = true;
            this.getEmailTrackers();
        }
    }

    handleSearchedValue() {
        this.isSpinnerLoading = true;
        this.pageNumber = 1;
        this.getEmailTrackers();
    }
    handleRefresh() {
        this.isSpinnerLoading = true;
        this.pageNumber = 1;
        this.selectedViewvalue = 'All';
        this.searchFilterStr = '';
        this.getEmailTrackers();
    }
    handlePageOptions(event) {
        this.isSpinnerLoading = true;
        this.selectedPageOption = event.detail.value;
        this.pageNumber = 1;
        this.getEmailTrackers();
    }

    //handle email subject on-click 
    handleEmailTracker(event) {
        this.isShowParentEmailTrackerComponent = false;
        this.orderTrackerId = event.currentTarget.dataset.id;
    }

    //handle Previous Page on-click 
    handlePreviouspage() {
        this.isSpinnerLoading = true;
        this.pageNumber -= 1;
        this.getEmailTrackers();
    }

    //handle Next Page on-click
    handleNextpage() {
        this.isSpinnerLoading = true;
        this.pageNumber += 1;
        this.getEmailTrackers();
    }

    handleMailChainEvent(event) {
        this.isSpinnerLoading = true;
        this.isShowParentEmailTrackerComponent = event.detail;
        this.getEmailTrackers();
        this.handleSpinnerLoadingOff();
    }

    handlePicklistFieldSelect(event) {
        this.picklistName=event.target.name;
        this.picklistValue=event.target.value;
        this.indexOfEmailTracker=event.currentTarget.dataset.id;
        this.emailTrackerId=this.tableEmailTrackers[this.indexOfEmailTracker].Id;
        if (this.picklistName === 'Email Category') {
            this.tableEmailTrackers[this.indexOfEmailTracker].Email_Category__c = this.picklistValue;
            this.updateEmailTracker();
        }
        else if (this.picklistName === 'Requestor Org') {
            this.tableEmailTrackers[this.indexOfEmailTracker].Requester_Org__c = this.picklistValue;
            this.updateEmailTracker();
        }
        else if (this.picklistName === 'Priority') {
            this.tableEmailTrackers[this.indexOfEmailTracker].Priority__c = this.picklistValue;
            this.updateEmailTracker();
        }
        else if (this.picklistName === 'Status') {
            if(this.picklistValue != 'Merged'){
                this.tableEmailTrackers[this.indexOfEmailTracker].Status__c = this.picklistValue;
                this.updateEmailTracker();                
            }
            else{
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Status cannot be changed to Merged manually. Please select a different status.')
            }
        }
        else if (this.picklistName === 'firstAssignee') {
            if(this.tableEmailTrackers[this.indexOfEmailTracker].Assigned_To_1st_Assignee__c!=this.firstAssigneeMap.get(this.picklistValue))
            this.getUpdatedemailTracker();    
        }
        else if (this.picklistName === 'secondAssignee') {
            if(this.tableEmailTrackers[this.indexOfEmailTracker].Assigned_To_2nd_Assignee__c!=this.secondAssigneeMap.get(this.picklistValue))
            this.getUpdatedemailTracker();            
        }
        else if (this.picklistName === 'thirdAssignee') {
            if(this.tableEmailTrackers[this.indexOfEmailTracker].Assigned_To_3rd_Assignee__c!=this.thirdAssigneeMap.get(this.picklistValue))
            this.getUpdatedemailTracker(); 
        }
        this.isSpinnerLoading = false;
        
    }

    getUpdatedemailTracker()
    {
        this.isSpinnerLoading = true;
        getEmailTracker({
            emailTrackerId:this.emailTrackerId
        }).then(result=>{
            this.isSpinnerLoading = false;
            this.emailTrackerNew= result;
            if(this.picklistName=='firstAssignee' && this.picklistValue != this.emailTrackerNew.Assigned_To_1st_Assignee__c)
            {
                if(this.picklistValue != this.emailTrackerNew.Assigned_To_1st_Assignee__c && this.emailTrackerNew.Assigned_To_1st_Assignee__c != null)
                {
                    this.assignedUser=this.firstAssigneeMap.get(this.emailTrackerNew.Assigned_To_1st_Assignee__c);
                    this.newAssignee= this.firstAssigneeMap.get(this.picklistValue);                          
                    this.openAssignedUserModal=true;

                }
                else
                {
                    this.saveChangedAssignedUser();
                }
               
            }
            else if(this.picklistName=='secondAssignee' && this.picklistValue != this.emailTrackerNew.Assigned_To_2nd_Assignee__c)
            {
                if(this.picklistValue != this.emailTrackerNew.Assigned_To_2nd_Assignee__c && this.emailTrackerNew.Assigned_To_2nd_Assignee__c != null)
                {
                    this.assignedUser=this.secondAssigneeMap.get(this.emailTrackerNew.Assigned_To_2nd_Assignee__c);  
                    this.newAssignee= this.secondAssigneeMap.get(this.picklistValue);                         
                    this.openAssignedUserModal=true;

                }
                else
                {
                    this.saveChangedAssignedUser();
                }
  
            }
            else if(this.picklistName=='thirdAssignee' && this.picklistValue != this.emailTrackerNew.Assigned_To_3rd_Assignee__c)
            {
                if(this.picklistValue != this.emailTrackerNew.Assigned_To_3rd_Assignee__c && this.emailTrackerNew.Assigned_To_3rd_Assignee__c != null)
                {
                    this.assignedUser=this.thirdAssigneeMap.get(this.emailTrackerNew.Assigned_To_3rd_Assignee__c); 
                    this.newAssignee= this.thirdAssigneeMap.get(this.picklistValue);                          
                    this.openAssignedUserModal=true;

                }
                else
                {
                    this.saveChangedAssignedUser();
                }

            }
        }).catch(error=>{
            this.isSpinnerLoading = false;
        
        })
    }

    updateEmailTracker()
    {
        updateEmailTracker({
            emailTrackerId: this.tableEmailTrackers[this.indexOfEmailTracker].Id,
            changedPicklistValue: this.picklistValue,
            typeOfPicklist: this.picklistName

        }).then(result => {
            let arr=this.formatNewEmailTracker(result);
            this.tableEmailTrackers[this.indexOfEmailTracker]=arr;     
            this.template.querySelector('c-custom-toast-component').showToast('success', 'Record succesfully updated')
            this.handleSpinnerLoadingOff();
        }).catch(error => {

            this.template.querySelector('c-custom-toast-component').showToast('error', 'Record update failed');
            this.handleSpinnerLoadingOff();
        })
    }

    closeAssignedUserModal()
    {
        this.isSpinnerLoading=true;
        this.getEmailTrackers();
        this.openAssignedUserModal=false;
        
    }

    saveChangedAssignedUser()
    {
        if(this.picklistName=='firstAssignee')
        {
            this.tableEmailTrackers[this.indexOfEmailTracker].Assigned_To_1st_Assignee__c=this.picklistValue;
            this.updateEmailTracker();
        }
        else if(this.picklistName=='secondAssignee')
        {
            this.tableEmailTrackers[this.indexOfEmailTracker].Assigned_To_2nd_Assignee__c=this.picklistValue;
            this.updateEmailTracker();
        }
        else if(this.picklistName=='thirdAssignee')
        {
            this.tableEmailTrackers[this.indexOfEmailTracker].Assigned_To_3rd_Assignee__c=this.picklistValue;
            this.updateEmailTracker();
        }        
        this.openAssignedUserModal=false;
        
    }

    openEditorModal(event) {
        this.editoSaveButtonDisable = false;
        this.flagEdit = 0;
        this.editPercentCompleteValue = '';
        this.indexOfEmailTracker = event.currentTarget.dataset.id;
        if (event.target.name == 'Remarks') {
            this.editRemarksValue = '';
            this.oldRemarksValue = this.tableEmailTrackers[this.indexOfEmailTracker].Remarks__c;
            this.editRemarksValue = this.oldRemarksValue;
            this.emailTrackerId = this.tableEmailTrackers[this.indexOfEmailTracker].Id;
            this.isRemarksEditor = true;
        }
        else if (event.target.name == 'RequesterName') {
            this.editRequesterNameValue = '';
            this.oldRequesterNameValue = this.tableEmailTrackers[this.indexOfEmailTracker].Requester_Name__c;
            this.editRequesterNameValue = this.oldRequesterNameValue;
            this.emailTrackerId = this.tableEmailTrackers[this.indexOfEmailTracker].Id;
            this.isRequesterNameEditor = true;
        }
        else if (event.target.name == 'PercentComplete') {
            this.editPercentCompleteValue = '';
            this.oldPercentCompleteValue = (this.tableEmailTrackers[this.indexOfEmailTracker].Complete__c) * 100;
            this.editPercentCompleteValue = this.oldPercentCompleteValue;
            this.emailTrackerId = this.tableEmailTrackers[this.indexOfEmailTracker].Id;
            this.isCompletePercentEditor = true;
        }
        this.openModalEditor = true;
    }

    editModalFields(event) {
        this.flagEdit = 1;
        if (event.target.name == 'Remarks') {
            this.editRemarksValue = event.target.value;
            if (this.editRemarksValue.length > 255) {
                this.editoSaveButtonDisable = true;
            }
            else {
                this.editoSaveButtonDisable = false;
            }
        }
        else if (event.target.name == 'RequesterName') {
            this.editRequesterNameValue = event.target.value;
            if (this.editRequesterNameValue.length > 255) {
                this.editoSaveButtonDisable = true;
            }
            else {
                this.editoSaveButtonDisable = false;
            }
        }
        else if (event.target.name == 'PercentComplete') {
            this.editPercentCompleteValue = event.target.value;
            if (this.editPercentCompleteValue > 100.00 || this.countPlaces(this.editPercentCompleteValue) > 2) {
                this.editoSaveButtonDisable = true;
            }
            else {
                this.editoSaveButtonDisable = false;
            }
        }

    }

    countPlaces(num) {
        var sep = String(23.32).match(/\D/)[0];
        var b = String(num).split(sep);
        return b[1] ? b[1].length : 0;
    }

    saveChangedRemarks(event) {
        if (this.flagEdit == 1) {
            var typeOfField = event.target.name;
            var valueForUpdate = '';
            this.isSpinnerLoading = true;
            
            if (typeOfField == 'PercentComplete') {
                this.tableEmailTrackers[this.indexOfEmailTracker].Complete__c = this.editPercentCompleteValue / 100;
                updateEmailTracker({
                    emailTrackerId: this.emailTrackerId,
                    changedPicklistValuePercent: this.editPercentCompleteValue,
                    typeOfPicklist: 'PercentComplete'
                }).then(result => {
                    let arr=this.formatNewEmailTracker(result);
                    this.tableEmailTrackers[this.indexOfEmailTracker]=arr;
                    this.template.querySelector('c-custom-toast-component').showToast('success', 'Record succesfully updated')
                    this.handleSpinnerLoadingOff();
                    this.openModalEditor = false;
                    this.isRemarksEditor = false;
                    this.isRequesterNameEditor = false;
                    this.isCompletePercentEditor = false;

                }).catch(error => {
                
                    this.template.querySelector('c-custom-toast-component').showToast('error', 'Record update failed')
                    this.handleSpinnerLoadingOff();
                });
            }
            else{
                if (typeOfField == 'Remarks') {
                    this.tableEmailTrackers[this.indexOfEmailTracker].Remarks__c = this.editRemarksValue;
                    valueForUpdate = this.editRemarksValue;
                    this.flagEdit = 2;
                }
                else if (typeOfField == 'RequesterName') {
                    this.tableEmailTrackers[this.indexOfEmailTracker].Requester_Name__c = this.editRequesterNameValue;
                    valueForUpdate = this.editRequesterNameValue;
                    this.flagEdit = 2;
                }
                if(this.flagEdit == 2){
                updateEmailTracker({
                    emailTrackerId: this.emailTrackerId,
                    changedPicklistValue: valueForUpdate,
                    typeOfPicklist: typeOfField
                }).then(result => {
                    let arr=this.formatNewEmailTracker(result);
                    this.tableEmailTrackers[this.indexOfEmailTracker]=arr;
              
                    this.template.querySelector('c-custom-toast-component').showToast('success', 'Record succesfully updated')
                    this.openModalEditor = false;
                    this.isRemarksEditor = false;
                    this.isRequesterNameEditor = false;
                    this.isCompletePercentEditor = false;
                    this.handleSpinnerLoadingOff();

                }).catch(error => {
                
                    this.template.querySelector('c-custom-toast-component').showToast('error', 'Record update failed')
                    this.handleSpinnerLoadingOff();
                });
            }
            }
        }
        this.openModalEditor = false;


    }

    formatNewEmailTracker(obj)
    {
        let tempdisable1st=this.tableEmailTrackers[this.indexOfEmailTracker].disable1stAssignee;
        let tempdisable2nd=this.tableEmailTrackers[this.indexOfEmailTracker].disable2ndAssignee;
        let tempdisable3rd=this.tableEmailTrackers[this.indexOfEmailTracker].disable3rdAssignee;
        if(obj.TAT__c != '0.0')
            obj.TAT__c= this.tatFormat(obj.TAT__c);
        else if(obj.TAT__c == '0.0') 
            obj.TAT__c='';
        obj.Complete__c = (obj.Complete__c ? obj.Complete__c / 100 : '');                    
        obj.Date_Received__c = (obj.Date_Received__c ? this.dateFormat(obj.Date_Received__c,'dateTime') : ' ');
        obj.Completion_Date__c = (obj.Completion_Date__c ? this.dateFormat(obj.Completion_Date__c,'dateTime') : ' ');
        obj.Assigned_To_1st_Assignee__c=this.firstAssigneeMap.get(obj.Assigned_To_1st_Assignee__c);
        obj.Assigned_To_2nd_Assignee__c=this.secondAssigneeMap.get(obj.Assigned_To_2nd_Assignee__c);
        obj.Assigned_To_3rd_Assignee__c=this.thirdAssigneeMap.get(obj.Assigned_To_3rd_Assignee__c);
        obj.disable1stAssignee=tempdisable1st;
        obj.disable2ndAssignee=tempdisable2nd;
        obj.disable3rdAssignee=tempdisable3rd;

        if(obj.Status__c=='Completed')
        {
          obj.disableStatus=true;   
        }  else
        {
          obj.disableStatus=false;  
        }     
        return obj;
    }

    closeEditorModal() {
        this.flagEdit = 0;
        this.editoSaveButtonDisable = true;
        this.openModalEditor = false;
        this.isRemarksEditor = false;
        this.isRequesterNameEditor = false;
        this.isCompletePercentEditor = false;

    }

    
    //handle date format
    dateFormat(dateTimeString, methodString) {
        var dateTime = new Date(dateTimeString);
     
        // dateTime.setHours(dateTime.getHours() - 12);
        // dateTime.setMinutes(dateTime.getMinutes() - 30);
     
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        var month = months[dateTime.getMonth()];
        var date = ((dateTime.getDate() < 10) ? ('0' + dateTime.getDate()) : (dateTime.getDate()));
        var year = dateTime.getFullYear().toString().substr(-2);
        var hours = ((dateTime.getHours() < 10) ? ('0' + dateTime.getHours()) : (dateTime.getHours()));
        var min = ((dateTime.getMinutes() < 10) ? ('0' + dateTime.getMinutes()) : (dateTime.getMinutes()));
        var amPm = hours >= 12 ? 'PM' : 'AM';
        if (hours > 12) {
            hours = hours - 12;
        }
        if (methodString === 'dateTime') {
            return date + ' ' + month + ' ' + year + ' at ' + hours + ':' + min + ' ' + amPm;
        }
        else if (methodString === 'date') {
            return date + ' ' + month + ' ' + year;
        }

    }
    
    tatFormat(hrsMinute)
    {
        let totalHours = hrsMinute.split('.');
        let convertedValue='';
        let hours = totalHours[0];
        let mins = totalHours[1];
        if((hours <= 9 && hours >=0) && hours!=undefined)
        {
            convertedValue = "0"+hours;
        }
        else
        {
            convertedValue = hours;
        }
        if(mins <= 9 && mins>=0 && mins!=undefined)
        {
            convertedValue = convertedValue + ":" +  "0"+mins;
        }
        else
        {
            convertedValue = convertedValue + ":"+ mins;
        }  
        return convertedValue;   
    }

    handleSpinnerLoadingOff() {
            this.isSpinnerLoading = false;
    }

    mergeRecordHandler(event){
        this.openMergeModal = true;
    }
    closeMergeModal(event){
        this.selectedRecords = [];
        this.openMergeModal = false;
        this.showMergeButton =false;
        let i;
        let checkboxes = this.template.querySelectorAll('lightning-input');
        for(i=0; i<checkboxes.length; i++) {
            checkboxes[i].checked = false;
        }
    }

    onrowSelectHandler(event){
        let indexAction = event.currentTarget.dataset.id;
        if(event.target.checked){
            this.selectedRecords.push(this.tableEmailTrackers[indexAction]);
        }
        else{
            if(this.selectedRecords){
                this.selectedRecords = this.selectedRecords.filter((data) =>{
                    return data.Id != this.tableEmailTrackers[indexAction].Id
                });
            }
        }
        if(this.selectedRecords.length > 1){
            this.showMergeButton = true ;
        }
        else{
            this.showMergeButton = false ;
        }
    }

    makeOrderPrimary(event){
        event.target.checked
        let indexOfEmailTracker = event.currentTarget.dataset.id;
        let orderTrackerRecordId = this.selectedRecords[indexOfEmailTracker].Id;
        let checkboxes = this.template.querySelectorAll('lightning-input');
        for(let item=0; item<checkboxes.length; item++) {
            if(checkboxes[item].name == 'primaryInputCheckbox'){
                if(event.target.checked){
                    if(checkboxes[item].checked){
                        checkboxes[item].disabled = false; 
                    }
                    else{
                        checkboxes[item].disabled = true;
                    }
                }
                else{
                    checkboxes[item].disabled = false; 
                }
            }
        }
        for (let i= 0 ; i< this.selectedRecords.length ; i++){
            if(this.selectedRecords[i].Id == orderTrackerRecordId){
                this.selectedRecords[i].primary = true;
            }
            else{
                this.selectedRecords[i].primary = false;
            }
        }
    }

    saveChangedMerge(event){
        this.isSpinnerLoading =true;
        this.openMergeModal = false;
        if(this.selectedRecords){
           mergeRecords({mergeRecord : JSON.stringify(this.selectedRecords)}).then((result)=>{
                if(result == 'success'){
                    this.getEmailTrackers();
                    this.template.querySelector('c-custom-toast-component').showToast('success', 'Record succesfully updated');
                    this.closeMergeModal();
                }
                else{
                    this.template.querySelector('c-custom-toast-component').showToast('error', result);
                }
           }).catch((error)=>{
                this.template.querySelector('c-custom-toast-component').showToast('error', error);
                this.isSpinnerLoading = false;
           }); 
        }
    }
}