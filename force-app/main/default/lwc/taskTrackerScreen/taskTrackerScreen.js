import { LightningElement, track, wire, api } from 'lwc';
import getNextTaskTrackers from '@salesforce/apex/getTaskTrackerData.getNextTaskTrackers';
import updateTaskTracker from '@salesforce/apex/getTaskTrackerData.updateTaskTracker';
import getMetadataPicklists from '@salesforce/apex/getTaskTrackerData.getMetadataPicklists';
import getSearchTicketNumber from '@salesforce/apex/getTaskTrackerData.getSearchTicketNumber';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Task_TRACKER_OBJECT from '@salesforce/schema/Task_Tracker__c';
import Ticket_Type_FIELD from '@salesforce/schema/Task_Tracker__c.Ticket_Type__c';
import Status_FIELD from '@salesforce/schema/Task_Tracker__c.Status__c';
import getUserInformation from '@salesforce/apex/OrderTrackerDashboard.getUserInformation'
import getTaskTracker from '@salesforce/apex/getTaskTrackerData.getTaskTracker'
import { getDataConnectorSourceFields } from 'lightning/analyticsWaveApi';

export default class TaskTrackerScreen extends LightningElement {
    // @track taskTrackerId;
    // @track emailTrackerId;
    
    @track mainTaskTrackers = [];
    @track tableTaskTrackers = [];
    @track singlePageOrders = [];//variable to store emails to show on a single page 
    @track totalRecords = 0;//total number of records
    @track isNoRecords = true;
    @track isNoFilter = true;
    @track disableSearch = false;
    @track pageOption = [
        { label: "10", value: "10" },
        { label: "20", value: "20" },
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
    @track selectedPageOption = 10;//number of records per page
    @track totalPages;//total number of pages
    //variables to show number of records as per page options
    @track recordStart = 0;
    @track recordEnd = 0;
    @track isSpinnerLoading = true;
    @track isModalAction = false;
    @track taskTrackerId;
    @track indexAction;
    @track actionableItemsDetails;
    @track isRecordEditFormModal = false;
    @track searchTicketNumberStr = '';
    @track isValue = false;
    @track valueTickerPillObj = {};
    @track isSpinnerLoadingModalCreateNew = false;
    @track valueAssignee = '';
    @track customerNameOrderTrackerValue = '';
    @track disableCreateNewSaveButton = false;
    @track isTicketNumberNotFound = false;
    @track createTaskActionableItemValue = '';
    @track isErrorActionableItemLenght = false;
    @track isActionable = false;
    @track isCustomerName = false;
    @track editoSaveButtonDisable = false;
    @track customerNameEditValue = '';
    @track oldCustomerValue = '';
    @track flagEdit = 0;
    @track ticketTypePicklistValues = [];
    @track statusPicklistValues = [];
    @track assigneePicklist = [];
    @track assigneeMap;
    @track blankSpace=true;

    @track userProfile='';
    @track userId='';
    @track isUserAdministrator='';

    @track taskTrackerNew='';        
    @track picklistName='';
    @track picklistValue='';
    @track taskTrackerId='';

    @api  clickedTab;

    @wire(getObjectInfo, { objectApiName: Task_TRACKER_OBJECT })
    taskMetadata;
    @wire(getPicklistValues,
        {
            recordTypeId: '$taskMetadata.data.defaultRecordTypeId',
            fieldApiName: Ticket_Type_FIELD
        }
    )
    wiredTicketTypePickList({ data }) {
        if (data) {
            this.ticketTypePicklistValues = data.values;
        }
    }
    @wire(getPicklistValues,
        {
            recordTypeId: '$taskMetadata.data.defaultRecordTypeId',
            fieldApiName: Status_FIELD
        }
    )
    wiredStatusPickList({ data }) {
        if (data) {
            this.statusPicklistValues = data.values;
        }
    }
    connectedCallback() {
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

    getMetadataPicklists(){
        getMetadataPicklists()
            .then(result => {
                let assignee = result;
                let picklist1 = [];
                let map1 = new Map();
                if(this.isUserAdministrator == true)
                {  
                    for (var i = 0; i < assignee.length; i++) {
                        picklist1.push({ label: assignee[i].Label, value: assignee[i].User_Id_c__c });
                        map1.set(assignee[i].User_Id_c__c, assignee[i].Label);
                    }
                }
                else if(this.isUserAdministrator == false)
                {

                    for (var i = 0; i < assignee.length; i++) {
                        map1.set(assignee[i].User_Id_c__c, assignee[i].Label);
                        if(assignee[i].User_Id_c__c == this.userId)
                        {
                            picklist1.push({ label: assignee[i].Label, value: assignee[i].User_Id_c__c });
                        }                                              
                    }
                }
                this.assigneeMap = map1;
                this.assigneePicklist = picklist1;
                this.getTaskTrackers();
            }).catch(error => {
            })
        
    }
    getTaskTrackers() {
        this.tableTaskTrackers=[];
        getNextTaskTrackers({
            pageNumber: this.pageNumber,
            pageLimit: this.selectedPageOption,
            viewPicklistValue: this.selectedViewvalue,
            searchFilterStr: this.searchFilterStr,
            selectedTab :this.clickedTab
        })
            .then((result) => {
                let tasks = result['taskTrackerList'];
                this.pageNumber = result['pageNumber'];
                this.totalRecords = result['totalTaskTrackerRecords'];
                this.recordStart = result['recordStart'];
                this.recordEnd = result['recordEnd'];
                this.totalPages = Math.ceil(result['totalTaskTrackerRecords'] / this.selectedPageOption);
                this.showNextButton = (this.pageNumber == this.totalPages || this.totalPages == 0);
                this.showPrevButton = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
                this.mainTaskTrackers = tasks;
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
                else if (this.totalRecords == 0 && (this.searchFilterStr != '' || this.selectedViewvalue == 'All')) {
                    this.disableSearch = false;
                    this.isNoRecords = false;
                    this.isNoFilter = true;
                }
                else if (this.totalRecords == 0 && (this.searchFilterStr != '' || this.selectedViewvalue != 'All')) {
                    this.disableSearch = false;
                    this.isNoRecords = false;
                    this.isNoFilter = true;
                }
                else if (this.totalRecords == 0 && (this.searchFilterStr == '' || this.selectedViewvalue != 'All')) {
                    this.disableSearch = false;
                    this.isNoRecords = false;
                    this.isNoFilter = true;
                }
                else if (this.totalRecords != 0) {
                    this.disableSearch = false;
                    this.isNoRecords = true;
                    this.isNoFilter = true;
                }
                var taskList = [];
                for (var i = 0; i < length; i++) {
                    if(this.isUserAdministrator == false)
                    {
                        if(tasks[i].Assignee__c == this.userId || (tasks[i].Assignee__c == undefined && this.assigneePicklist.length != 0))
                        {
                            tasks[i].disableAssignee=false;
                        }  
                        else 
                        {
                            tasks[i].disableAssignee=true;
                        }
                    }
                    else if(this.isUserAdministrator == true)
                    {
                        tasks[i].disableAssignee=false;
                    }
                    tasks[i].Assignee__c = this.assigneeMap.get(tasks[i].Assignee__c);
                    tasks[i].Schedule_date__c = (tasks[i].Schedule_date__c ? this.dateFormat(tasks[i].Schedule_date__c) : ' ');
                    taskList.push(tasks[i]);
                }
                this.tableTaskTrackers = taskList;
                this.handleSpinnerLoadingOff();
            }).catch((error) => {
            });
    }

 
    getTicketData(ticketNumber) {
        this.customerNameOrderTrackerValue = '';
        let ticketFound='';
        getSearchTicketNumber({
            searchTerm: ticketNumber,
        }).then(result => {
            if (result.orderTracker || result.emailTracker) {
                ticketFound = false;
                if (result.orderTracker) {
                    this.isValue = true;
                    var orderTrackerPillObj = result.orderTracker;
                    this.valueTickerPillObj = orderTrackerPillObj[0];
                    this.valueTickerPillObj.trackerType = 'Order';
                    this.customerNameOrderTrackerValue = this.valueTickerPillObj.End_User__c;
                    this.valueTickerPillObj.TicketTypeWithTrackerType = 'Order Tracker Ticket Number : ' + this.valueTickerPillObj.Ticket__c;
                }
                else if (result.emailTracker) {
                    this.isValue = true;
                    var emailTrackerPillObj = result.emailTracker;
                    this.valueTickerPillObj = emailTrackerPillObj[0];
                    this.valueTickerPillObj.trackerType = 'Email';
                    this.valueTickerPillObj.TicketTypeWithTrackerType = 'Email Tracker Ticket Number : ' + this.valueTickerPillObj.Ticket__c;
                }
            }
            else {
                ticketFound = true;
             
            }
        }).catch(error => {
        })
        this.handleSpinnerLoadingOff();
        return ticketFound;
    }
    handleChangeAssigneeCreateTask(event) {
        this.valueAssignee = event.detail.value;
        this.disableCreateNewSaveButton = false;
    }
    handleActionableItemChange(event) {
        this.createTaskActionableItemValue = event.detail.value;
        if (this.customerNameEditValue.length > 131072) {
            this.editoSaveButtonDisable = true;
        }
        else {
            this.editoSaveButtonDisable = false;
        }
    }
    handleSubmitCreateNew(event) {
        // const isInputsCorrect = [...this.template.querySelectorAll('lightning-combobox')]
        //     .reduce((validSoFar, inputField) => {
        //         inputField.reportValidity();
        //         return validSoFar && inputField.checkValidity();
        //     }, true);
        this.isSpinnerLoadingModalCreateNew = true;
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        
            this.customerNameOrderTrackerValue = '';
            fields.Assignee__c = this.valueAssignee;
            fields.Actionable_Item__c = this.createTaskActionableItemValue;
            fields.is_Appoved_Mail_Sent__c = true;
            
            if(fields.Ticket_No__c)
            {
                getSearchTicketNumber({
                    searchTerm: fields.Ticket_No__c,
                }).then(result => {
                    if (result.orderTracker || result.emailTracker) {
                        this.isTicketNumberNotFound = false;
                        if (result.orderTracker) {
                            this.isValue = true;
                            var orderTrackerPillObj = result.orderTracker;
                            this.valueTickerPillObj = orderTrackerPillObj[0];
                            this.valueTickerPillObj.trackerType = 'Order';
                            this.customerNameOrderTrackerValue = this.valueTickerPillObj.End_User__c;
                            this.valueTickerPillObj.TicketTypeWithTrackerType = 'Order Tracker Ticket Number : ' + this.valueTickerPillObj.Ticket__c;
                        }
                        else if (result.emailTracker) {
                            this.isValue = true;
                            var emailTrackerPillObj = result.emailTracker;
                            this.valueTickerPillObj = emailTrackerPillObj[0];
                            this.valueTickerPillObj.trackerType = 'Email';
                            this.valueTickerPillObj.TicketTypeWithTrackerType = 'Email Tracker Ticket Number : ' + this.valueTickerPillObj.Ticket__c;
                        }
                        if (this.valueTickerPillObj.trackerType == 'Order') {
                            fields.Order_Tracker__c = this.valueTickerPillObj.Id;
                            fields.SO_Number__c = this.valueTickerPillObj.SO__c;
                            if(fields.Customer_Name__c=='')
                           { fields.Customer_Name__c =this.customerNameOrderTrackerValue;}
                            //fields.Ticket_No__c = this.valueTickerPillObj.Ticket__c;
                        }
                        else if (this.valueTickerPillObj.trackerType == 'Email') {
                            fields.Email_Tracker__c = this.valueTickerPillObj.Id;
                            //fields.Ticket_No__c = this.valueTickerPillObj.Ticket__c;
                        }
                        this.template.querySelector('lightning-record-edit-form').submit(fields);
                        
                    }
                    else {
                        this.isTicketNumberNotFound = true;
                    }
                }).catch(error => {
                })
                this.handleSpinnerLoadingOff();

            }
            else
            {
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
            
    }
    handleSucessCreateNew(event) {
        const updatedRecord = event.detail.id;
        this.isRecordEditFormModal = false;

        this.template.querySelector('c-custom-toast-component').showToast('success', 'Task succesfully Created')
        this.pageNumber = 1;
        this.selectedPageOption = 10;
        this.selectedViewvalue = 'All';
        this.searchFilterStr = '';
        this.getTaskTrackers();
        
        this.handleSpinnerLoadingOff();
        this.isValue = false;
        this.searchTicketNumberStr = '';
        this.valueAssignee = '';
        this.createTaskActionableItemValue = '';
        this.disableCreateNewSaveButton = false;
        this.customerNameOrderTrackerValue='';
    }
    //function to handle status change
    handleViewChange(event) {
        this.isSpinnerLoading = true;
        this.selectedViewvalue = event.detail.value;
        this.pageNumber = 1;
        this.getTaskTrackers();
    }
    //  handle search button event
    handleSearchInput(event) {
        this.searchFilterStr = event.target.value;
        if (event.target.value == '') {
            this.isSpinnerLoading = true;
            this.getTaskTrackers();
        }
    }
    handleSearchedValue() {
        this.isSpinnerLoading = true;
        this.pageNumber = 1;
        this.getTaskTrackers();
    }

    handleRefresh() {
        this.selectedViewvalue = 'All';
        this.searchFilterStr = '';
        this.isSpinnerLoading = true;
        this.pageNumber = 1;
        this.getTaskTrackers();
    }

    handlePageOptions(event) {
        this.isSpinnerLoading = true;
        this.selectedPageOption = event.detail.value;
        this.pageNumber = 1;
        this.getTaskTrackers();
    }
    //handle Previous Page on-click 
    handlePreviouspage() {
        this.isSpinnerLoading = true;
        this.pageNumber -= 1;
        this.getTaskTrackers();
        // this.handleSpinnerLoadingOff();
    }
    //handle Next Page on-click
    handleNextpage() {
        this.isSpinnerLoading = true;
        this.pageNumber += 1;
        this.getTaskTrackers();
        // this.handleSpinnerLoadingOff();
    }
    handleActionableItem(event) {
        this.flagEdit = 0;
        this.editoSaveButtonDisable = false;
        this.customerNameEditValue = '';
        this.indexAction = event.currentTarget.dataset.id;
        this.taskTrackerId = this.tableTaskTrackers[this.indexAction].Id;
        if (event.target.name == 'Actionable') {
            this.isActionable = true;
            this.actionableItemsDetails = this.tableTaskTrackers[this.indexAction].Actionable_Item__c;
        }
        else if (event.target.name == 'Customer') {
            this.isCustomerName = true;
            this.customerNameEditValue = '';
            this.oldCustomerValue = this.tableTaskTrackers[this.indexAction].Customer_Name__c;
            this.customerNameEditValue = this.oldCustomerValue;
            this.taskTrackerId = this.tableTaskTrackers[this.indexAction].Id;
        }
        this.isModalAction = true;
    }
    editCustomerNameEdit(event) {
        this.flagEdit = 1;
        if (event.target.name == 'Customer') {
            this.customerNameEditValue = event.target.value;
            if (this.customerNameEditValue.length > 255) {
                this.editoSaveButtonDisable = true;
            }
            else {
                this.editoSaveButtonDisable = false;
            }
        }
    }
    closeActionModal() {
        this.isModalAction = false;
        this.editoSaveButtonDisable = false;
        this.isActionable = false;
        this.isCustomerName = false;
        this.isRecordEditFormModal = false;
        this.isTicketNumberNotFound = false;
        this.isValue = false;
        this.searchTicketNumberStr = '';
        this.valueAssignee = '';
        this.createTaskActionableItemValue = '';
        this.disableCreateNewSaveButton = false;
    }
    saveEditedField(event) {
        if (this.flagEdit == 1) {
            this.isSpinnerLoading = true;
            this.picklistName=event.target.name;
            if (event.target.name == 'Customer') {
                this.tableTaskTrackers[this.indexAction].Customer_Name__c = this.customerNameEditValue;
                this.picklistValue=this.customerNameEditValue;
                this.updateTaskTracker();
            }
        }
        this.isActionable = false;
        this.isCustomerName = false;
        this.isModalAction = false;
    }
    createNewTaskMethod() {
        this.isSpinnerLoading = true;
        this.createTaskActionableItemValue = '';
        this.isRecordEditFormModal = true;
        this.isSpinnerLoading = false;
        this.isTicketNumberNotFound = false;
    }
    submitForm() {
        this.isSpinnerLoading = true;
        this.connectedCallback();
        this.isRecordEditFormModal = false;
        this.isSpinnerLoading = false;
    }
    handlePicklistFieldSelect(event) {

        this.indexAction=event.currentTarget.dataset.id;        
        this.picklistName=event.target.name;
        this.picklistValue=event.target.value;
        this.taskTrackerId=this.tableTaskTrackers[this.indexAction].Id;
        if (this.picklistName === 'Ticket Type') {
            this.tableTaskTrackers[this.indexAction].Ticket_Type__c = this.picklistValue;
            this.updateTaskTracker();
        }
        else if (this.picklistName === 'Status') {
            this.tableTaskTrackers[this.indexAction].Status__c = this.picklistValue;
            this.updateTaskTracker();
        }
        else if (this.picklistName === 'Assignee' && this.tableTaskTrackers[this.indexAction].Assignee__c != this.assigneeMap.get(this.picklistValue)) {
            this.getUpdatedTaskTracker();
        }
    }

    formatTaskTracker(newTask)
    {
        let tempdisableAssignee=this.tableTaskTrackers[this.indexAction].disableAssignee;
        newTask.disableAssignee=tempdisableAssignee;
        newTask.Assignee__c = this.assigneeMap.get(newTask.Assignee__c);
        newTask.Schedule_date__c = (newTask.Schedule_date__c ? this.dateFormat(newTask.Schedule_date__c) : ' ');
        return newTask;
    }

    updateTaskTracker(){
        updateTaskTracker({
            taskTrackerId: this.tableTaskTrackers[this.indexAction].Id,
            changedPicklistValue: this.picklistValue,
            typeOfPicklist: this.picklistName
        }).then(result => {
            console.log(JSON.stringify(result));
            this.tableTaskTrackers[this.indexAction]=this.formatTaskTracker(result);
            this.template.querySelector('c-custom-toast-component').showToast('success', 'Record succesfully updated')
            this.handleSpinnerLoadingOff();
        }).catch(error => {
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Record update failed')
            this.handleSpinnerLoadingOff();
        })
        
    }

    getUpdatedTaskTracker()
    {
        this.isSpinnerLoading=true;
        getTaskTracker({
            taskTrackerId:this.taskTrackerId
        }).then(result=>{
            this.taskTrackerNew = result;
            this.handleSpinnerLoadingOff();
            if(this.picklistName =='Assignee' )
            {
                if(this.picklistValue != this.taskTrackerNew.Assignee__c && this.taskTrackerNew.Assignee__c != null)
                {
                    this.assignedUser=this.assigneeMap.get(this.taskTrackerNew.Assignee__c);
                    this.newAssignee= this.assigneeMap.get(this.picklistValue);                          
                    this.openAssignedUserModal=true;

                }
                else
                {
                    this.saveChangedAssignedUser();
                }
                
            }
        }).catch(error=>{
            this.handleSpinnerLoadingOff();
        })
    }

    saveChangedAssignedUser()
    {
        if(this.picklistName=='Assignee')
        {
            this.tableTaskTrackers[this.indexAction].Assignee__c=this.picklistValue;
            this.updateTaskTracker();
        }
        this.openAssignedUserModal=false;
    }

    closeAssignedUserModal()
    {
        this.isSpinnerLoading=true;      
        this.getTaskTrackers(); 
        this.openAssignedUserModal=false;        
    }

   
    //handle date format
    dateFormat(dateTimeString) {
        var dateTime = new Date(dateTimeString);
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        var month = months[dateTime.getUTCMonth()];
        var date = ((dateTime.getUTCDate() < 10) ? ('0' + dateTime.getUTCDate()) : (dateTime.getUTCDate()));
        var year = dateTime.getUTCFullYear().toString().substr(-2);
        return date + ' ' + month + ' ' + year;
    }
    handleSpinnerLoadingOff() {
        this.delayTimeout = setTimeout(() => {
            this.isSpinnerLoading = false;
            this.isSpinnerLoadingModalCreateNew = false;
        }, 200);
    }
}