import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import getMainChainTableData from '@salesforce/apex/getMailChainData.getMainChainTableData';
import getNextMailChainData from '@salesforce/apex/getMailChainData.getNextMailChainData';
import getMetadataPicklists from '@salesforce/apex/OrderTrackerDashboard.getMetadataPicklists'
import getMetadataPicklistsEmailTracker from '@salesforce/apex/getEmailTrackerData.getMetadataPicklistsEmailTracker';
import TASK_TRACKER_TICKET_TYPE_FIELD from '@salesforce/schema/Task_Tracker__c.Ticket_Type__c'
import createTasksFromOrderTracker from '@salesforce/apex/getTaskTrackerData.createTasksFromOrderTracker'
import getTasks from '@salesforce/apex/getTaskTrackerData.getTasks'
import convertTracker from '@salesforce/apex/getMailChainData.convertTracker';
import convertToOrderTracker from '@salesforce/apex/getMailChainData.convertToOrderTracker'
import TASK_TRACKER_OBJECT from '@salesforce/schema/Task_Tracker__c';

export default class OrderTracker extends NavigationMixin(LightningElement) {
    @api isShowParentOrderTrackerComponent = false;
    @api orderTrackerId;
    @api trackerType;
    @api currentPage;
    @api currentPageqc;
    @api currentPageap;
    @api currentPageqr;
    @api currentPageReQr;
    @api allowMultiSelect = false;
    @api allowWithAttachment = false;

    @track isShowTrackerType;
    @track isEmailTracker = false;
    @track isOrderTracker = false;
    @track isOrderTrackerDashboard = false;
    @track OrderTrackerTableObj = {};   // to show order tracker data in table
    @track mailChainTableList = [];     // to show mail chain data in table
    @track isReplyButton = true;        // for reply button disable
    @track totalRecords;                // total records of mail chain
    @track pageOption = [
        { label: "10", value: "10" },
        { label: "20", value: "20" },
        { label: "50", value: "50" },
        { label: "100", value: "100" }
    ]            // page option in picklist to see records on page
    @track pageNumber = 0;              // pagenumber for handling next and previous
    @track showPrevButton = false;       // for hiding previous button
    @track showNextButton = true;       // for hiding next button
    @track selectedPageOption = 10;      // value of selecting option in picklist pagination 
    @track totalPages;                  // total pages in table 
    @track start;                       // start record no on Mail Chain Table 
    @track end;                         // end record no on Mail Chain Table
    @track idOfSelectedMailChain;       // selected row id for replying
    @track isSpinnerLoading = true;
    @track isShowTable = true;
    @track isDisablePageOption = false;
    @track taskButtonLabel='Tasks';


    @track isShowParentMailChainComponent = true;
    @track isShowParentMailChainComponentWithAttachments = true;


    @track mailChainObjectToReply = {};
    @track mailChainObjectListToReply = [];

    @track checkingOPRepMap;
    @track processingOPRepMap;
    @track OPRepFollowingUpMap;
    @track finalApproverMap;

    @track firstAssigneeMap;
    @track secondAssigneeMap;
    @track thirdAssigneeMap;

    @track openTaskTracker1Modal = false;
    @track openTaskTracker2Modal = false;
    @track taskList = [];
    @track deletedTaskList = [];
    @track index = 0;
    @track ticketTypePicklist = []
    @track noTasks = true;


    @track oldActionableItemValue = '';
    @track editActionableItemValue = '';
    @track openActionableItemEditor = false;
    @track indexOfTask = '';

    @track borderStyle;

    @track disableAddTask = false;
    @track disableSaveButton = false;
    @track openConvertWarningModal=false;
    @track quoteNumber;
    @track primaryTicketNumber;
    @track isMergedChechbox;

    @wire(getObjectInfo, { objectApiName: TASK_TRACKER_OBJECT })
    taskMetadata;

    @wire(getPicklistValues,
        {
            recordTypeId: '$taskMetadata.data.defaultRecordTypeId',
            fieldApiName: TASK_TRACKER_TICKET_TYPE_FIELD
        }
    )
    wiredTicketTypePickList({ data }) {
        if (data) {
            this.ticketTypePicklist = data.values;
        }
    }

    connectedCallback() {
        if (this.trackerType == 'emailTracker') {

            this.isEmailTracker = true;
            this.isOrderTracker = false;
            this.isOrderTrackerDashboard = false;
            this.borderStyle = "background-color:white";
            getMetadataPicklistsEmailTracker()
                .then(result => {

                    let firstAssignee = result['firstAssignee'];
                    let secondAssignee = result['secondAssignee'];
                    let thirdAssignee = result['thirdAssignee'];

                    let map1 = new Map();
                    let map2 = new Map();
                    let map3 = new Map();
                    for (var i = 0; i < firstAssignee.length; i++) {
                        map1.set(firstAssignee[i].User_Id__c, firstAssignee[i].Label);
                    }
                    for (var i = 0; i < secondAssignee.length; i++) {
                        map2.set(secondAssignee[i].User_Id__c, secondAssignee[i].Label);
                    }
                    for (var i = 0; i < thirdAssignee.length; i++) {
                        map3.set(thirdAssignee[i].User_Id__c, thirdAssignee[i].Label);
                    }

                    this.firstAssigneeMap = map1;
                    this.secondAssigneeMap = map2;
                    this.thirdAssigneeMap = map3;
                    this.getMainChainDataMethod();
                }).catch(error => {

                })
        }
        else if (this.trackerType == 'orderTracker'  || this.trackerType == 'Order Tracker Dashboard') {
            this.isEmailTracker = false;
            if(this.trackerType == 'orderTracker') 
           {
            this.isOrderTrackerDashboard = false;
            this.isOrderTracker = true;
            this.borderStyle = "background-color:white";
           }
           else{
            this.isOrderTracker = false;
            this.isOrderTrackerDashboard = true;
            this.borderStyle = "border:solid 1px;border-bottom:solid 2px;background-color:white";
           }  
            getMetadataPicklists()
                .then(result => {

                    let processing = result['processing op rep'];
                    let finalapp = result['final approver'];
                    let checking = result['checking op rep'];
                    let oprep = result['op rep following up']
                    let map1 = new Map();
                    let map2 = new Map();
                    let map3 = new Map();
                    let map4 = new Map();
                    for (var i = 0; i < processing.length; i++) {
                        map1.set(processing[i].User_Id__c, processing[i].Label);
                    }
                    for (var i = 0; i < oprep.length; i++) {
                        map2.set(oprep[i].User_Id__c, oprep[i].Label);
                    }
                    for (var i = 0; i < finalapp.length; i++) {
                        map3.set(finalapp[i].User_Id__c, finalapp[i].Label);
                    }
                    for (var i = 0; i < checking.length; i++) {
                        map4.set(checking[i].User_Id__c, checking[i].Label);
                    }
                    this.processingOPRepMap = map1;

                    this.OPRepFollowingUpMap = map2;

                    this.finalApproverMap = map3;

                    this.checkingOPRepMap = map4;
                    this.getMainChainDataMethod();
                }).catch(error => {

                })

                this.handleGetTaskTrackerData();
        }
    
    }


    getMainChainDataMethod() {
        getMainChainTableData({ orderTrackerId: this.orderTrackerId, isEmailTracker: this.trackerType })
            .then(result => {

                console.log(result.OrderTrackerData[0]);
                var varOrderTrackerTableObj = result.OrderTrackerData[0];
                if (this.trackerType != 'emailTracker') {
                    varOrderTrackerTableObj.Checking_OP_Rep_QC_Rep__c = this.checkingOPRepMap.get(varOrderTrackerTableObj.Checking_OP_Rep_QC_Rep__c);
                    varOrderTrackerTableObj.Processing_OP_Rep__c = this.processingOPRepMap.get(varOrderTrackerTableObj.Processing_OP_Rep__c);
                    varOrderTrackerTableObj.OP_Rep_Following_Up__c = this.OPRepFollowingUpMap.get(varOrderTrackerTableObj.OP_Rep_Following_Up__c);
                    varOrderTrackerTableObj.Final_Approver__c = this.finalApproverMap.get(varOrderTrackerTableObj.Final_Approver__c);

                }

                if (this.trackerType == 'emailTracker') {
                    varOrderTrackerTableObj.Assigned_To_1st_Assignee__c = this.firstAssigneeMap.get(varOrderTrackerTableObj.Assigned_To_1st_Assignee__c);
                    varOrderTrackerTableObj.Assigned_To_2nd_Assignee__c = this.secondAssigneeMap.get(varOrderTrackerTableObj.Assigned_To_2nd_Assignee__c);
                    varOrderTrackerTableObj.Assigned_To_3rd_Assignee__c = this.thirdAssigneeMap.get(varOrderTrackerTableObj.Assigned_To_3rd_Assignee__c);
                }


                varOrderTrackerTableObj.Received_Date__c = (varOrderTrackerTableObj.Received_Date__c ? this.dateFormat(varOrderTrackerTableObj.Received_Date__c, 'dateTime') : ' ');
                varOrderTrackerTableObj.Date_Received__c = (varOrderTrackerTableObj.Date_Received__c ? this.dateFormat(varOrderTrackerTableObj.Date_Received__c, 'dateTime') : ' ');
                varOrderTrackerTableObj.Completion_Date__c = (varOrderTrackerTableObj.Completion_Date__c ? this.dateFormat(varOrderTrackerTableObj.Completion_Date__c, 'dateTime') : ' ');
                if (varOrderTrackerTableObj.ACV__c)
                    varOrderTrackerTableObj.ACV__c = this.currencyFormat(varOrderTrackerTableObj.ACV__c);
                if (varOrderTrackerTableObj.PO_Amount__c)
                    varOrderTrackerTableObj.PO_Amount__c = this.currencyFormat(varOrderTrackerTableObj.PO_Amount__c);
                if (varOrderTrackerTableObj.X1st_Billing_Amount_USD__c)
                    varOrderTrackerTableObj.X1st_Billing_Amount_USD__c = this.currencyFormat(varOrderTrackerTableObj.X1st_Billing_Amount_USD__c);

                this.OrderTrackerTableObj = varOrderTrackerTableObj;
                var varMailChainTableList = result.mailChainData;
                if (varMailChainTableList.length === 0) {
                    this.isShowTable = false;

                }


                let varMChainAttachment = result.attachments;
                for (let mChain of varMailChainTableList) {
                    if (mChain.Date_Time_of_Email__c != null) {
                        mChain.Date_Time_of_Email__c = this.dateFormat(mChain.Date_Time_of_Email__c, 'dateTime');
                    }
                    if(mChain.To__c!=null)
                    {
                        mChain.To__c=mChain.To__c.replaceAll(';' ,'; ');
                    }
                    if(mChain.CC__c!=null)
                    {
                        mChain.CC__c=mChain.CC__c.replaceAll(';' ,'; ');
                    }
                    if(mChain.BCC__c!=null)
                    {
                        mChain.BCC__c=mChain.BCC__c.replaceAll(';' ,'; ');
                    }
                    var attachmentArr = [];

                    for (let attachment of varMChainAttachment) {
                        if (mChain.Id === attachment.mailChainId) {
                            var attachmentObj = {};
                            attachmentObj.fileId = attachment.fileId;
                            attachmentObj.fileTitle = attachment.fileTitle;
                            // mChain.fileId = attachment.fileId;
                            // mChain.fileTitle = attachment.fileTitle;
                            attachmentArr.push(attachmentObj);

                        }

                    }
                    mChain.fileAttachment = attachmentArr;

                }

                // this.mailChainTableList = varMailChainTableList;
                this.totalRecords = result.count;
                let mailList = [];
                let length;
                if (this.totalRecords < 10) {
                    length = this.totalRecords;
                    this.end = this.totalRecords;
                    this.showNextButton = false;

                }
                else {
                    length = 10;
                    this.end = 10;
                    if (this.totalRecords === 10) {
                        this.showNextButton = false;
                    }
                    else {
                        this.showNextButton = true;
                    }

                }
                //show records on page on load
                for (var i = 0; i < length; i++) {
                    varMailChainTableList[i].original_body__c = varMailChainTableList[i].Body__c;
                    if (varMailChainTableList[i].Body__c != undefined && varMailChainTableList[i].Body__c.length > 200) {
                        let htmlbody = varMailChainTableList[i].Body__c;

                        varMailChainTableList[i].Body_status__c = 'More';
                        varMailChainTableList[i].truncated_Body__c = htmlbody.substr(0, 200);
                        varMailChainTableList[i].Body__c = varMailChainTableList[i].truncated_Body__c;

                    }
                    mailList.push(varMailChainTableList[i]);
                }
                this.mailChainTableList = mailList;


                if (this.totalRecords === 0) {
                    this.start = 0;
                    this.showNextButton = false;
                }
                else {
                    this.start = 1;
                }

                this.totalPages = Math.ceil(this.totalRecords / length);



                this.error = undefined;
                this.handleSpinnerLoadingOff();
            })
            .catch(error => {
                this.error = error;

                // this.contacts = undefined;
            });
    }

    handleAttachmentClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: event.currentTarget.dataset.id
            }
        })
    }

    handleSelectCheckbox(event) {
        let boxes = this.template.querySelectorAll('lightning-input');
        this.mailChainObjectToReply = this.mailChainTableList[event.currentTarget.dataset.id];
        let boxCheckedList = [];
        let currentBox = event.target.name;
        for (let box of boxes) {
            if (box.name !== currentBox && box.checked) {
                box.checked = false;
            }
            boxCheckedList.push(box.checked);
        }

        if (boxCheckedList.includes(true)) {
            this.isReplyButton = false;
        }
        else {
            this.isReplyButton = true;
        }
    }

    handleMultiSelectCheckbox(event) {
        let boxes = this.template.querySelectorAll('lightning-input');

        this.mailChainObjectListToReply = [];
        for (let box of boxes) {
            if (box.name && box.checked) {
                if (this.mailChainTableList[box.dataset.id]) {
                    this.mailChainObjectListToReply.push(this.mailChainTableList[box.dataset.id]);
                }
            }
        }
        if (this.mailChainObjectListToReply.length > 0) {
            this.isReplyButton = false;
        } else {
            this.isReplyButton = true;
        }
    }


    handleReplyClick() {
        if(this.mailChainObjectToReply.To__c!=null)
        {
            this.mailChainObjectToReply.To__c=this.mailChainObjectToReply.To__c.replaceAll('; ',';')
        }
        if(this.mailChainObjectToReply.CC__c!=null)
        {
            this.mailChainObjectToReply.CC__c=this.mailChainObjectToReply.CC__c.replaceAll('; ',';')
        }
        if(this.mailChainObjectToReply.BCC__c!=null)
        {
            this.mailChainObjectToReply.BCC__c=this.mailChainObjectToReply.BCC__c.replaceAll('; ',';')
        }
        this.isShowParentMailChainComponent = false;
    }

    handlePageOptions(event) {
        this.isSpinnerLoading = true;
        this.selectedPageOption = event.detail.value;
        this.totalPages = Math.ceil(this.totalRecords / parseInt(this.selectedPageOption));
        this.pageNumber = 0;
        if (this.totalRecords <= this.selectedPageOption) {
            if (this.totalRecords === 0) {
                this.start = 0;
                this.end = 0;
            }
            else {
                this.start = 1;
                this.end = this.totalRecords;
            }
        }
        else {
            this.start = 1;
            this.end = parseInt(this.selectedPageOption);
        }

        this.getOrderTrackers();
        let boxes = this.template.querySelectorAll('lightning-input');
        for (let box of boxes) {
            if (box.checked) {
                box.checked = false;
            }
        }
        this.handleSpinnerLoadingOff();

    }
    handlePreviouspage() {
        this.isSpinnerLoading = true;
        this.pageNumber -= 1;
        this.start = (parseInt(this.selectedPageOption) * this.pageNumber) + 1;
        this.end = this.start + parseInt(this.selectedPageOption) - 1;
        this.getOrderTrackers();
        this.getMainChainDataMethod();
        if (this.start === 1) {
            this.showPrevButton = false;
        }
        this.handleSpinnerLoadingOff();
    }
    handleNextpage() {
        this.isSpinnerLoading = true;
        this.pageNumber += 1;
        this.start = (parseInt(this.selectedPageOption) * this.pageNumber) + 1;
        if (this.start + parseInt(this.selectedPageOption) > this.totalRecords) {
            this.end = this.totalRecords;
        }
        else {
            this.end = this.start - 1 + parseInt(this.selectedPageOption);
        }

        this.getOrderTrackers();
        this.handleSpinnerLoadingOff();
    }

    getOrderTrackers() {
        console.log('pageNumber in result',this.pageNumber);
        getNextMailChainData({
            pageNumber: this.pageNumber,
            pageLimit: this.selectedPageOption,
            orderTrackerId: this.orderTrackerId,
            isEmailTracker: this.trackerType,
            fromConvertFunction:false
        })
            .then((result) => {
                console.log('result>>',result.mailChainData);
                let varMailChainTableListNextPrevious = result.mailChainData;
                var varAttachments = result.attachments;
                for (let mChain of varMailChainTableListNextPrevious) {
                    mChain.original_body__c = mChain.Body__c;
                    if (mChain.Body__c != undefined && mChain.Body__c.length > 200) {
                        let htmlbody = mChain.Body__c;

                        mChain.Body_status__c = 'More';
                        mChain.truncated_Body__c = htmlbody.substr(0, 200);
                        mChain.Body__c = mChain.truncated_Body__c;

                    }
                    if (mChain.Date_Time_of_Email__c != null) {
                        mChain.Date_Time_of_Email__c = this.dateFormat(mChain.Date_Time_of_Email__c, 'dateTime');
                    }
                    var attachmentArr = [];

                    for (let attachment of varAttachments) {
                        if (mChain.Id === attachment.mailChainId) {
                            var attachmentObj = {};
                            attachmentObj.fileId = attachment.fileId;
                            attachmentObj.fileTitle = attachment.fileTitle;
                            // mChain.fileId = attachment.fileId;
                            // mChain.fileTitle = attachment.fileTitle;
                            attachmentArr.push(attachmentObj);

                        }

                    }
                    mChain.fileAttachment = attachmentArr;
                }
                this.mailChainTableList = varMailChainTableListNextPrevious;

                if (this.pageNumber > 0 && this.pageNumber < this.totalPages - 1) {
                    this.showNextButton = true;
                    this.showPrevButton = true;
                }
                else if (this.pageNumber == (this.totalPages - 1)) {
                    this.showNextButton = false;
                    this.showPrevButton = true;
                }
                else if (this.pageNumber == 0) {
                    this.showPrevButton = false;
                    this.showNextButton = true;
                }

                if (this.totalRecords <= this.selectedPageOption) {
                    this.showPrevButton = false;
                    this.showNextButton = false;
                    if (this.totalRecords === 0) {
                        this.start = 0;
                        this.end = 0;
                    }
                    else {
                        this.start = 1;
                        this.end = this.totalRecords;
                    }

                }




            }).catch((error) => {

            });
    }

    handleSpinnerLoadingOff() {
        this.isSpinnerLoading = false;
    }

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
    handleParentComponent() {
        this.isShowParentOrderTrackerComponent = true;
        const selectedEvent = new CustomEvent("showparentcomponent", {
            detail: {
                showParent: this.isShowParentOrderTrackerComponent,
                trackerMoved: false,
                isBackButtonClicked : true,
                currentPage: this.currentPage,
                currentPageqc : this.currentPageqc,
                currentPageap: this.currentPageap,
                currentPageqr: this.currentPageqr,
                currentPageReQr: this.currentPageReQr

            }
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    handleReplyPageEvent(event) {
        this.isShowParentMailChainComponent = event.detail.showParent;
        this.isReplyButton = event.detail.reply;
        let emailSent = event.detail.emailSent;
        if (emailSent == true) {
            this.template.querySelector('c-custom-toast-component').showToast('success', 'Email Sent Successfully');
        }
        this.getMainChainDataMethod();

    }

    currencyFormat(num) {
        return (Math.round((num + Number.EPSILON) * 100) / 100);
    }

    openTaskModal1() {
        this.isSpinnerLoading = true;
        console.log('this.OrderTrackerTableObj.Status__c', this.OrderTrackerTableObj.Status__c);
        if (this.OrderTrackerTableObj.Status__c == 'PO Pending for Booking') {
            this.openTaskTracker1Modal = true;
            this.disableAddTask = true;
            this.disableSaveButton = true;
            this.handleSpinnerLoadingOff();
        }
        else {
            this.disableAddTask = false;
            this.disableSaveButton = false;
           this.handleGetTaskTrackerData();
           this.openTaskTracker1Modal = true;
        }


    }
    //get Task Data 
    handleGetTaskTrackerData()
    {
        getTasks({
            orderTrackerId: this.orderTrackerId
        }).then(result => {
            this.deletedTaskList = [];
            this.taskList = [];
            this.index = 0;
            if (result.length == 0) {
                this.noTasks = true;
                this.taskButtonLabel='Tasks 0' ;
            }
            else if (result.length != 0) {
                this.taskButtonLabel='Tasks '+ result.length;
                this.noTasks = false;
                let tasks = result;
                for (let i = 0; i < tasks.length; i++) {
                    tasks[i].key = i + 1;
                }
                this.index = tasks.length;
                this.taskList = tasks;

            }
            this.handleSpinnerLoadingOff();
        }).catch(error => {
            this.error=error;
        })
    }
    saveTasks1() {
        this.isSpinnerLoading = true;
        if (this.taskList.length == 0 && this.deletedTaskList.length == 0) {
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Please create some tasks');
        }
        else if (this.taskList.length != 0 || this.deletedTaskList.length != 0) {
            let emptyTaskName = false;
            let emptyTaskNameIndex = '';
            for (var i = 0; i < this.taskList.length; i++) {
                if (this.taskList[i].Task_Name__c == '') {
                    emptyTaskName = true;
                    emptyTaskNameIndex = emptyTaskNameIndex + (parseInt(i) + 1) + ',';
                }

                if (this.taskList[i].Id == '' || this.taskList[i].Id == undefined) {
                    this.taskList[i].Order_Tracker__c = this.orderTrackerId;
                }
            }
            if (emptyTaskName == true) {
                emptyTaskNameIndex = emptyTaskNameIndex.substring(0, emptyTaskNameIndex.length - 1);
                this.template.querySelector('c-custom-toast-component').showToast('warning', 'Please enter task name at row number : ' + emptyTaskNameIndex);
            }
            else if (emptyTaskName == false) {
                if(this.taskList.length==0)
                this.taskButtonLabel='Tasks 0' ;
             else
                this.taskButtonLabel='Tasks '+ this.taskList.length ;
                createTasksFromOrderTracker({
                    updatedTasksList: this.taskList,
                    deletedTasksList: this.deletedTaskList
                }).then(result => {
                    this.template.querySelector('c-custom-toast-component').showToast('success', 'Tasks sucessfully created/updated');
                })
                this.openTaskTracker1Modal = false;
                this.handleSpinnerLoadingOff();
            }
        }

    }
    closeTaskTracker1Modal() {
        this.taskList = [];
        this.handleSpinnerLoadingOff();
        this.openTaskTracker1Modal = false;
    }


    addRow() {
        console.log('this.index', this.index);
        this.index++;
        this.noTasks = false;
        var i = this.index;
        let task = {
            Task_Name__c: '',
            Ticket_Type__c: '',
            Actionable_Item__c: '',
            Schedule_date__c: '',
            key: '',
            SO_Number__c: this.OrderTrackerTableObj.SO__c,
            Ticket_No__c: this.OrderTrackerTableObj.Ticket__c,
            Customer_Name__c:this.OrderTrackerTableObj.End_User__c
        }
        task.key = i;
        this.taskList.push(JSON.parse(JSON.stringify(task)));

    }

    removeRow(event) {
        var selectedRow = event.currentTarget;
        var indx = selectedRow.dataset.id;
        if (this.taskList[indx].Id != undefined) {
            this.deletedTaskList.push(this.taskList[indx]);
        }
        if (this.taskList.length > 1) {
            for (var i = (parseInt(indx) + 1); i < this.taskList.length; i++) {
                this.taskList[i].key--;
            }
            this.index--;
        }
        else if (this.taskList.length == 1) {
            this.index = 0;
        }
        this.taskList.splice(indx, 1);
        if (this.taskList.length == 0) {
            this.index = 0;
            this.noTasks = true;
        }
        else if (this.taskList.length != 0) {
            this.noTasks = false;
        }
    }

    handleTaskNameChange(event) {
        var selectedRow = event.currentTarget;
        var indx = selectedRow.dataset.id;
        this.taskList[indx].Task_Name__c = event.target.value;
    }

    handleActionableItemChange(event) {
        var selectedRow = event.currentTarget;
        var indx = selectedRow.dataset.id;
        this.taskList[indx].Actionable_Item__c = event.target.value;
    }

    handleScheduleDateChange(event) {
        var selectedRow = event.currentTarget;
        var indx = selectedRow.dataset.id;
        this.taskList[indx].Schedule_date__c = event.target.value;
    }

    handleTicketTypeChange(event) {
        var selectedRow = event.currentTarget;
        var indx = selectedRow.dataset.id;
        this.taskList[indx].Ticket_Type__c = event.target.value;
    }

    openActionableItemModal(event) {
        this.editActionableItemValue = '';
        this.indexOfTask = event.currentTarget.dataset.id;
        this.oldActionableItemValue = this.taskList[this.indexOfTask].Actionable_Item__c;
        if (this.oldActionableItemValue != undefined)
            this.editActionableItemValue = this.oldActionableItemValue;
        else {
            this.oldActionableItemValue = '';
        }
        this.openActionableItemEditor = true;
        this.openTaskTracker2Modal = false;
    }
    editActionableItem(event) {
        this.editActionableItemValue = event.target.value;
    }
    saveChangedActionableItem() {
        if (this.editActionableItemValue != this.oldActionableItemValue) {
            this.isSpinnerLoading = true;
            this.taskList[this.indexOfTask].Actionable_Item__c = this.editActionableItemValue;
            this.handleSpinnerLoadingOff();
            this.openActionableItemEditor = false;
            this.openTaskTracker2Modal = true;
        }
        else {
            this.openActionableItemEditor = false;
            this.openTaskTracker2Modal = true;
        }
    }
    closeChangedActionableModal() {
        this.editActionableItemValue = '';
        this.openActionableItemEditor = false;
        this.openTaskTracker2Modal = true;
    }

    handleTruncate(event) {

        if (this.mailChainTableList[event.currentTarget.dataset.id].Body_status__c == 'More') {
            this.mailChainTableList[event.currentTarget.dataset.id].Body__c = this.mailChainTableList[event.currentTarget.dataset.id].original_body__c;
            this.mailChainTableList[event.currentTarget.dataset.id].Body_status__c = 'Less';
        }
        else if (this.mailChainTableList[event.currentTarget.dataset.id].Body_status__c == 'Less') {
            this.mailChainTableList[event.currentTarget.dataset.id].Body__c = this.mailChainTableList[event.currentTarget.dataset.id].truncated_Body__c;
            this.mailChainTableList[event.currentTarget.dataset.id].Body_status__c = 'More';
        }


    }

    handleConvertTracker(event)
    {
        this.isSpinnerLoading=true;
        this.openConvertWarningModal=false;
        convertTracker({
            trackerType:this.trackerType,
            trackerId:this.orderTrackerId,
        })
        .then(result=>{
            let isSuccess=result;
            if(isSuccess)
            {
                this.handleSpinnerLoadingOff();
                this.isShowParentOrderTrackerComponent = true;
                const selectedEvent = new CustomEvent("showparentcomponent", {
                detail: {
                    showParent: this.isShowParentOrderTrackerComponent,
                    trackerMoved: true
                }
            });

            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
            }


        }).catch(error=>{

        })
    }
    handleOrderTrackerConvert(event){
        if(this.isInputValid()){
            this.openConvertWarningModal=false;
            convertToOrderTracker({
                trackerType:this.trackerType,
                trackerId:this.orderTrackerId,
                quoteNumber: this.quoteNumber,
                primaryTicketNumber: this.primaryTicketNumber
            }).then(result=>{
                if(result == 'true'){
                    this.template.querySelector('c-custom-toast-component').showToast('success', 'Email Sent Successfully');
                    this.primaryTicketNumber = '';
                    this.quoteNumber = '';
                }
                else{
                    this.template.querySelector('c-custom-toast-component').showToast('success', '');
                    this.primaryTicketNumber = '';
                    this.quoteNumber = '';
                }
            }).catch(error =>{
                this.template.querySelector('c-custom-toast-component').showToast('error', error.body.message);
                this.primaryTicketNumber = '';
                this.quoteNumber = '';
            });
        }      
    }

    openConvertWarning()
    {
        this.openConvertWarningModal=true;
    }
    closeConvertWarning()
    {
        this.openConvertWarningModal=false;
        this.primaryTicketNumber = '';
    }
    handleQuoteChange(event){
        this.quoteNumber = event.target.value;
    }
    handleTicketNumberChange(event){
        this.primaryTicketNumber = event.target.value;
    }
    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
    handleMergeCheckBoxChange(event){
        this.isMergedChechbox = event.target.checked;
    }
}