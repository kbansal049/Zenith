import { LightningElement, track, api, wire } from 'lwc';
import getTotalResponedToRepData from '@salesforce/apex/DashBoardComponent.getTotalPOPendingForReQRData';
import updateOpportunity from '@salesforce/apex/DashBoardComponent.updateOpportunity';
import getNextResponedToRepData from '@salesforce/apex/DashBoardComponent.getNextPOPendingForReQRData';
import getDataForExporting from '@salesforce/apex/DashBoardComponent.getDataForExporting';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import cssStaticResource from '@salesforce/resourceUrl/buttoncss';
import { loadStyle } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
const columns = [
    { label: 'Ticket #',type: 'button', typeAttributes: { label: { fieldName: 'Ticket__c' }, variant: 'base', value: { fieldName: 'Ticket__c' }, target: 'Ticket__c' }},
    { label: 'End User', fieldName: 'End_User__c'},
    { label: 'Region', fieldName: 'Region__c', },
    { label: 'Proposal #', fieldName: 'Proposal_for_initiating_QC__c',},
    { label: 'SO #', fieldName: 'SO__c',},
    { label: 'New/Upsell ACV', fieldName: 'New_Upsell_ACV__c', sortable: true, type: 'currency' },
    { label: 'Renewal ACV', fieldName: 'Renewal_ACV__c', sortable: true, type: 'currency' },             
    { label: 'Total ACV', fieldName: 'ACV__c', sortable: true, type: 'currency' },
    { label: 'TCV', fieldName: 'TCV__c', type: 'currency', sortable: true, type: 'currency' },
    { label: 'Reason For 5c', fieldName: 'relationData',cellAttributes: {class: 'my-vertical-padding' } ,editable: true, type:'button', initialWidth: 350,typeAttributes: { label: { fieldName: 'relationDataPretext' }, variant: 'base', value:{ fieldName: 'relationData' } , target: 'relationData',name :'Reason' }},
    { label: 'Opened Since', fieldName: 'Opened_Since__c',sortable: true, },
    { label: 'Last Status Change', fieldName: 'Live_Status_Change_Time_Difference__c', type: 'text', cellAttributes: { alignment: 'left' },sortable: true,},  
];
//TEXT(FLOOR(((((Now() - Received_Date__c)*24)-FLOOR((Now() - Received_Date__c)*24))*60)))&' Mins'
export default class PoPendingForReQr extends LightningElement {
    @track isShowParentOrderTrackerComponent = true;
    @track orderTrackerId;
    // @track isEmailTracker = 'emailTracker';
    @track mainrespondedToRepList;
    @track tablerespondedToRepList;
    @track totalRecords;                // total records of mail chain
    @track pageOption = [];             // page option in picklist to see records on page
    @track pageNumber = 0;              // pagenumber for handling next and previous
    @track showPrevButton = false;       // for disabling previous button
    @track showNextButton = true;       // for disabling next button
    @track selectedPageOption = 10;      // value of selecting option in picklist pagination 
    @track totalPages;                  // total pages in table 
    @track start;                       // start record no on Mail Chain Table 
    @track end;
    @track pageOption = [
        { label: "10", value: "10" },
        { label: "20", value: "20" },
        { label: "50", value: "50" },
        { label: "100", value: "100" }
    ]                     // end record no on Mail Chain Table
    // @track idOfSelectedMailChain;       // selected row id for replying
    @track isSpinnerLoading = true;
    @track isDisablePageOption = false;
    @track isShowTable = true;
    @track hrefdata;
    @track exportingData = [];
    @track finalDataTable = [];
    @track totalSumArr = [];

    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    isModalOpen = false;
    ReasonFor5c;
    @track modalRecord =[];
    @api currentPageReQr ;
    @api isBackButtonClicked = false;


    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                if (primer(x[field]) != null) {
                    return primer(x[field]);
                }
                else {
                    return -Infinity;
                }

            }
            : function (x) {
                if (x[field] != null) {
                    return x[field];
                }
                else {
                    return -Infinity;
                }

            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.getResponedToRepDataMethod();
        const cloneData = [...this.tablerespondedToRepList];
        //cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        let cloneDataUpdated = [];
        for (let cData of cloneData) {
            if (cData.End_User__c != 'Total') {
                cloneDataUpdated.push(cData);
            }
        }
        var objTotal = {};
        objTotal.Id = 'objtotalid123'
        objTotal.End_User__c = 'Total';
        objTotal.Region__c = ' ';
        objTotal.Proposal_for_initiating_QC__c = ' ';
        objTotal.relationData ='';
        objTotal.SO__c = ' ';
        objTotal.New_Upsell_ACV__c = this.totalSumArr['upsell'];
        objTotal.Renewal_ACV__c = this.totalSumArr['renewal'];
        objTotal.ACV__c = this.totalSumArr['acv'];
        objTotal.TCV__c = this.totalSumArr['tcv'];

        cloneDataUpdated.push(objTotal);
        this.finalDataTable = cloneDataUpdated;
    }

    renderedCallback(){
        if(this.isBackButtonClicked && this.currentPageReQr){
 /*           this.template.querySelector('lightning-datatable').scrollIntoView({
                block: 'center',
                behavior: 'smooth'
                [data-row-key-value="' +this.currentPage.Id +'"]
            }); */
           let currentpageurl =  window.location.href;
           window.location.href = currentpageurl + '#:~:text='+this.currentPageReQr.Ticket;
        } 
    }

    connectedCallback() {
        loadStyle(this, cssStaticResource).then(()=>{
            
        });
            getDataForExporting({ statusVal: 'PO pending Re-QR' })
            .then(result => {
                this.exportingData = result;
            })
            .catch(error => {

            })
            if(this.isBackButtonClicked && this.currentPageReQr){

                this.start = this.currentPageReQr.start;
                this.end = this.currentPageReQr.end;
                this.selectedPageOption = this.currentPageReQr.selectedPageOption;
                this.pageNumber = this.currentPageReQr.pageNumber
                this.sortedBy = this.currentPageReQr.sortBy;
                this.sortDirection = this.currentPageReQr.sortDirection;
                this.totalPages = this.currentPageReQr.totalPages;
                this.totalRecords = this.currentPageReQr.totalRecords;
                this.totalSumArr = this.currentPageReQr.totalSumArr;
                this.getResponedToRepDataMethod();
                this.handleSpinnerLoadingOff();
            }
            else{
                getTotalResponedToRepData()
                .then(result => {
                    this.totalSumArr = result.totalSum;
                    var objTotal = {};
                    objTotal.Id = 'objtotalid123'
                    objTotal.End_User__c = 'Total';
                    objTotal.Region__c=' ';
                    objTotal.Proposal_for_initiating_QC__c = ' ';
                    objTotal.SO__c = ' ';
                    objTotal.relationData = ' ';
                    objTotal.New_Upsell_ACV__c = this.totalSumArr['upsell'];
                    objTotal.Renewal_ACV__c = this.totalSumArr['renewal'];
                    objTotal.ACV__c = this.totalSumArr['acv'];
                    objTotal.TCV__c = this.totalSumArr['tcv'];
                    this.exportingData.push(objTotal);
                    this.isSpinnerLoading = false;
                    let respondedToRepList = result;
                    this.totalRecords = respondedToRepList['Count'];
                    if(this.totalRecords==0){
                        this.isShowTable = false;
                    }
                    // Rishi's features
                    this.mainrespondedToRepList = this.createNewData(respondedToRepList['respondedToRepList'], false);
                    this.start = 1;
                    if (this.totalRecords < this.selectedPageOption) {
                        this.end = this.totalRecords;
                    }
                    else if (this.totalRecords >= this.selectedPageOption) {
                        this.end = this.selectedPageOption;
                    }
                    let tempList = [];
                    // for (var i = 0; i < this.end; i++) {
                    //     this.mainrespondedToRepList[i].New_Upsell_ACV__c = (this.mainrespondedToRepList[i].New_Upsell_ACV__c == 0) ? '' : this.mainrespondedToRepList[i].New_Upsell_ACV__c;
                    //     this.mainrespondedToRepList[i].Renewal_ACV__c = (this.mainrespondedToRepList[i].Renewal_ACV__c == 0) ? '' : this.mainrespondedToRepList[i].Renewal_ACV__c;
                    //     this.mainrespondedToRepList[i].ACV__c = (this.mainrespondedToRepList[i].ACV__c == 0) ? '' : this.mainrespondedToRepList[i].ACV__c;
                    //     this.mainrespondedToRepList[i].TCV__c = (this.mainrespondedToRepList[i].TCV__c == 0) ? '' : this.mainrespondedToRepList[i].TCV__c;
                    //     tempList.push(this.mainrespondedToRepList[i]);
                    // }
                    if (this.totalRecords <= this.selectedPageOption) {
                        this.showPrevButton = false;
                        this.showNextButton = false;
                    }
                    else {
                        this.showPrevButton = false;
                        this.showNextButton = true;
                    }
                    this.tablerespondedToRepList =  this.mainrespondedToRepList;
                    this.mainTableFunction();
                    this.totalPages = Math.ceil(this.totalRecords / this.selectedPageOption);
                    this.handleSpinnerLoadingOff();
                });
            }
    }


    getResponedToRepDataMethod() {
        getNextResponedToRepData({
            pageNumber: this.pageNumber,
            pageLimit: this.selectedPageOption,
            sortedBy:this.sortedBy,
            sortDirection:this.sortDirection
        })
            .then(result => {
                let orders = result;
                // for (let order of orders) {
                //     order.New_Upsell_ACV__c = (order.New_Upsell_ACV__c == 0) ? '' : order.New_Upsell_ACV__c;
                //     order.Renewal_ACV__c = (order.Renewal_ACV__c == 0) ? '' : order.Renewal_ACV__c;
                //     order.ACV__c = (order.ACV__c == 0) ? '' : order.ACV__c;
                //     order.TCV__c = (order.TCV__c == 0) ? '' : order.TCV__c;
                // }
                this.tablerespondedToRepList = orders;
                this.tablerespondedToRepList= this.createNewData(this.tablerespondedToRepList, false);
                this.mainTableFunction();
                this.totalPages = Math.ceil(this.totalRecords / this.selectedPageOption);
                if (this.pageNumber > 0 && this.pageNumber < this.totalPages - 1) {
                    this.showNextButton = true;
                    this.showPrevButton = true;
                }
                else if (this.pageNumber == (this.totalPages - 1)) {
                    if (this.totalRecords <= this.selectedPageOption) {
                        this.showNextButton = false;
                        this.showPrevButton = false;
                    }
                    else {
                        this.showNextButton = false;
                        this.showPrevButton = true;
                    }

                }
                else if (this.pageNumber == 0) {
                    if (this.totalRecords <= this.selectedPageOption) {
                        this.showNextButton = false;
                        this.showPrevButton = false;
                    }
                    else {
                        this.showPrevButton = false;
                        this.showNextButton = true;
                    }

                }
            })
    }

    createNewData(inputData, isForExport){
        let newData = [];
        inputData.forEach(data => {
            let obj = {};
            obj.End_User__c = data.End_User__c;
            obj.Proposal_for_initiating_QC__c= data.Proposal_for_initiating_QC__c;
            obj.PO__c = data.PO__c;
            obj.SO__c =data.SO__c;
            obj.New_Upsell_ACV__c =data.New_Upsell_ACV__c;
            obj.Renewal_ACV__c =data.Renewal_ACV__c;
            obj.ACV__c = data.ACV__c;
            obj.TCV__c = data.TCV__c;
            obj.Id = data.Id;
            if(isForExport){
                obj.relationData = (data.Opportunity__r?.Reason_for_5C__c?.replace(/(<([^>]+)>)/ig, ' '));
            }
            else{
                obj.relationData = data.Opportunity__r?.Reason_for_5C__c;            
            }
            obj.relationDataPretext =  data.Opportunity__r?.Reason_for_5C__c ? (((data.Opportunity__r?.Reason_for_5C__c?.replace(/(<([^>]+)>)/ig, '')).substring(0,100)).replace(/^\s+/g, '')).trim() : 'Add New Reason';
            obj.opportunityId = data.Opportunity__r?.Id;
            obj.Ticket__c = data.Ticket__c;
            obj.Live_Status_Change_Time_Difference__c = data.Live_Status_Change_Time_Difference__c;
            obj.Opened_Since__c = data.Opened_Since__c;
            newData.push(obj);
        });
        return newData;
    }


    onRowActionClick(event) {
        const actionName = event.detail.action.name;
        this.orderTrackerId = event.detail.row.Id;
        if(actionName === 'Reason'){
            var oTId = event.detail.row.Id;
            this.isModalOpen = true;
            var filteredArray  = [...this.finalDataTable].filter((data)=>{
                    if(data.Id === oTId){
                        return  data.Id === oTId;
                    }                
            });
            this.modalRecord = filteredArray[0];
            this.isBackButtonClicked = false;
        }
        else{

            this.isShowParentOrderTrackerComponent = false;
            let currentPageReQr = {};
            currentPageReQr.start = this.start;
            currentPageReQr.end = this.end;
            currentPageReQr.selectedPageOption = this.selectedPageOption;
            currentPageReQr.sortedBy = this.sortedBy;
            currentPageReQr.sortDirection = this.sortDirection;
            currentPageReQr.pageNumber = this.pageNumber;
            currentPageReQr.totalPages = this.totalPages;
            currentPageReQr.totalRecords = this.totalRecords;
            currentPageReQr.totalSumArr = this.totalSumArr;
            currentPageReQr.Id = event.detail.row.Id;           
            var filteredArray  = [...this.finalDataTable].filter((data)=>{
                if(data.Id === event.detail.row.Id){
                    return  data.Id === event.detail.row.Id;
                }                
        });
        currentPageReQr.Ticket = (filteredArray[0].Ticket__c).replace('-','%2D');
            const selectedEvent = new CustomEvent("showparentcomponent", {
                detail: { recordId: this.orderTrackerId, showParent: this.isShowParentOrderTrackerComponent, currentPageReQr: currentPageReQr }
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        }
    }

    submitDetails(event){
        if(this.modalRecord){
            this.handleSave(this.modalRecord);
            this.isModalOpen =false;
        }
    }

    closeModal(event){
        this.isModalOpen = false;
    }

    handleReasonChange(event){
        this.ReasonFor5c = event.target.value;
    }
    exportToCSV() {
        let columnHeader = ["Ticket","End User","Region", "Proposal", "SO", "New/Upsell ACV", "Renewal ACV", "Total ACV", "TCV", "Reason For 5c","Opened Since","Last Status Change"];  // This array holds the Column headers to be displayd
        let jsonKeys = ["Ticket__c","End_User__c","Region__c", "Proposal_for_initiating_QC__c", "SO__c" ,"New_Upsell_ACV__c", "Renewal_ACV__c", "ACV__c", "TCV__c", "relationData","Opened_Since__c","Live_Status_Change_Time_Difference__c"]; // This array holds the keys in the json data  
      
        var jsonRecordsData = this.exportingData;
        jsonRecordsData = this.createNewData(this.exportingData, true);
        let csvIterativeData;
        let csvSeperator
        let newLineCharacter;
        csvSeperator = ",";
        newLineCharacter = "\n";
        csvIterativeData = "";
        csvIterativeData += columnHeader.join(csvSeperator);
        csvIterativeData += newLineCharacter;
        for (let i = 0; i < jsonRecordsData.length; i++) {
            let counter = 0;
            for (let iteratorObj in jsonKeys) {
                let dataKey = jsonKeys[iteratorObj];
                if (counter > 0) { csvIterativeData += csvSeperator; }
                if (jsonRecordsData[i][dataKey] !== null &&
                    jsonRecordsData[i][dataKey] !== undefined
                ) {
                    csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';
                } else {
                    csvIterativeData += '""';
                }
                counter++;
            }
            csvIterativeData += newLineCharacter;
        }
        this.hrefdata = "data:text/csv;charset=utf-8," + encodeURIComponent(csvIterativeData);
    }
    
    handlePageOptions(event) {
        this.isSpinnerLoading = true;
        this.selectedPageOption = event.detail.value;
        this.pageNumber = 0;
        if (this.totalRecords < this.selectedPageOption) {
            this.end = this.totalRecords;
        }
        else if (this.totalRecords >= this.selectedPageOption) {
            this.end = this.selectedPageOption;
        }
        this.isBackButtonClicked = false;
        this.getResponedToRepDataMethod();
        this.handleSpinnerLoadingOff();
    }

    handlePreviouspage() {
        this.isSpinnerLoading = true;
        this.pageNumber -= 1;
        this.start = (parseInt(this.selectedPageOption) * this.pageNumber) + 1;
        this.end = this.start + parseInt(this.selectedPageOption) - 1;
        this.getResponedToRepDataMethod();
        if (this.start === 1) {
            this.showPrevButton = true;
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
        this.getResponedToRepDataMethod();
        this.handleSpinnerLoadingOff();
    }
    
    handleSpinnerLoadingOff() {
        this.delayTimeout = setTimeout(() => {
            this.isSpinnerLoading = false;
        }, 1000);
    }

    mainTableFunction() {
        var objTotal = {}
        this.finalDataTable = this.tablerespondedToRepList;
        objTotal.Id = 'objtotalid123'
        objTotal.End_User__c = 'Total';
        objTotal.Region__c = ' ';
        objTotal.Proposal_for_initiating_QC__c = ' ';
        objTotal.SO__c = ' ';
        objTotal.New_Upsell_ACV__c = this.totalSumArr['upsell'];
        objTotal.Renewal_ACV__c = this.totalSumArr['renewal'];
        objTotal.ACV__c = this.totalSumArr['acv'];
        objTotal.TCV__c = this.totalSumArr['tcv'];
        this.finalDataTable.push(objTotal);
    }

    handleSave(filteredArray) {
        this.isSpinnerLoading = true ;
        const dataObject = [];
        var dataObjectToPass ;
        var fields = {};

        fields[ID_FIELD.fieldApiName] = filteredArray.opportunityId;
        fields['REASON'] = this.ReasonFor5c;
        dataObject.push(fields);

        if(dataObject){
            dataObjectToPass= JSON.stringify(dataObject);
        }
        updateOpportunity({json: dataObjectToPass}).then((result)=>{
            if(result === 'success'){
                this.getResponedToRepDataMethod();
                getDataForExporting({ statusVal: 'PO pending Re-QR' })
                .then(result => {
                    this.exportingData = result;
                })
                .catch(error => {
    
                })
                this.isSpinnerLoading = false ;
                this.showToastMessage('Success','Update Successfull', 'success');
            }
        });
        }   

        showToastMessage(title, message, variant){
            const toast = new ShowToastEvent({
                title : title,
                message : message,
                variant : variant
            });
            this.dispatchEvent(toast);
    }

}