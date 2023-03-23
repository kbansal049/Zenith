import { LightningElement, track, wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getNextOrderTrackers from '@salesforce/apex/OrderTrackerDashboard.getNextOrderTrackers';
import mergeRecords from '@salesforce/apex/OrderTrackerDashboard.mergeRecords';
import updateOrderTracker from '@salesforce/apex/OrderTrackerDashboard.updateOrderTracker';
import editRemarksofOrderTracker from '@salesforce/apex/OrderTrackerDashboard.editRemarksofOrderTracker'
import editPartnerEndUserofOrderTracker from '@salesforce/apex/OrderTrackerDashboard.editPartnerEndUserofOrderTracker';
import editCurrencyNumberofOrderTracker from '@salesforce/apex/OrderTrackerDashboard.editCurrencyNumberofOrderTracker'
import getMetadataPicklists from '@salesforce/apex/OrderTrackerDashboard.getMetadataPicklists'
import getUserInformation from '@salesforce/apex/OrderTrackerDashboard.getUserInformation'
import sendSEMailNotificationMethod from '@salesforce/apex/OrderTrackerDashboard.sendMailNotificationMethod'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ORDER_TRACKER_OBJECT from '@salesforce/schema/Order_Tracker__c';
import STATUS_FIELD from '@salesforce/schema/Order_Tracker__c.Status__c';
import ORDER_TYPE_FIELD from '@salesforce/schema/Order_Tracker__c.Order_Type__c';
import Region_FIELD from '@salesforce/schema/Order_Tracker__c.Region__c';
import Attachment_on_NS_SF_FIELD from '@salesforce/schema/Order_Tracker__c.Attachment_on_NS_SF__c';
import Billing_Frequency_FIELD from '@salesforce/schema/Order_Tracker__c.Billing_Frequency__c';
import ZA_Updated_FIELD from '@salesforce/schema/Order_Tracker__c.ZA_Updated__c';
import All_SFDC_Processses_Updated_FIELD from '@salesforce/schema/Order_Tracker__c.All_SFDC_Processses_Updated__c';
import Confirm_all_dependant_PRs_moved_to_prod_FIELD from '@salesforce/schema/Order_Tracker__c.confirm_all_dependant_PRs_moved_to_prod__c';
import BOT_Auto_QC_Done_FIELD from '@salesforce/schema/Order_Tracker__c.BOT_Auto_QC_Done__c';
import BOT_Re_QC_Required_FIELD from '@salesforce/schema/Order_Tracker__c.BOT_Re_QC_Required__c';
import Mail_Forwarded_FIELD from '@salesforce/schema/Order_Tracker__c.Mail_Forwarded__c';
import { deleteRecord } from 'lightning/uiRecordApi';
import getOrderTracker from'@salesforce/apex/OrderTrackerDashboard.getOrderTracker';
// CR# 4946 START
import attachPODocumentToOpportunity from '@salesforce/apex/OrderTrackerDashboard.attachPODocumentToOpportunity';
import { updateRecord } from "lightning/uiRecordApi";
import ID_FIELD from "@salesforce/schema/Order_Tracker__c.Id";
// CR# 4946 END
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';



import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrderTrackerScreen extends NavigationMixin(LightningElement) {
    @api clickedTab;
    @track orderTrackerId;//used for passing email tracker record ID to mail chain component 
    @track tableOrderTrackers = [];//mainOrderTrackers used in HTML to show emails on page   
    @track totalRecords=0;//total number of records
    @track noRecords;
    @track pageOption = [];//list of number of records to display on a page   
    @track isEmailTracker='orderTracker';
    @track pageNumber = 1;//page index
    @track showPrevButton = true;//boolean to show Next button
    @track showNextButton = true;//boolean to show Previous button
    @track viewPicklistValues=[
        { label: "All", value: "All" },
        { label: "PO Pending for Booking", value: "PO Pending for Booking" },
        { label: "PO Pending for QR", value: "PO Pending for QR" },
        { label: "PO Pending for QC", value: "PO Pending for QC" },
        { label: "PO Pending with Sales", value: "PO Pending with Sales" },
        { label: "PO pending Re-QR", value: "PO pending Re-QR" }
    ];
    @track sourcePicklistValues=[
        { label: "All", value: "All" },
        { label: "EDI", value: "EDI" },
        { label: "RPA", value: "RPA" },
        { label: "Sales", value: "Sales" }
    ];    
    @track selectedViewvalue = 'All';//selected status value from status picklist
    @track searchedPOValue = '';//searched PO Number value from search input
    @track searchedSOValue = '';//searched SO Number value from search input
    @track searchedProposalValue = ''; //searched the proposal value from the search input
    @track searchedSubjectValue = '';//searched Subject value from search input
    @track searchedTicketValue='';//searched Ticket value from search input
    @track selectedSourcevalue= 'All'; //searched source value from the search input
    @track universalSearchValue='';
    @track searchedTicketAndEmailValue='';
    @track recordEnd = 0;
    @track recordStart = 0;
    @track pageOption=[
        {label:"10",value:"10"},
        {label:"25", value:"25"},
        {label:"50",value:"50"},
        {label:"100",value:"100"}
    ]
    @track selectedPageOption = 25;//number of records per page
    @track totalPages=0;//total number of pages
    @track disableSearch=false;
    //picklst values
    @track statusPicklistValues;
    @track checkingOPRepPicklist=[];
    @track processingOPRepPicklist=[];
    @track OPRepFollowingUpPicklist=[];
    @track finalApproverPicklist=[];
    @track attachmentOnNsSFPicklist;
    @track ZA_UpdatedPicklist;
    @track All_SFDC_Processses_UpdatedPicklist;
    @track Confirm_all_dependant_PRs_moved_to_prodPicklist;
    @track BOT_Auto_QC_DonePicklist;
    @track BOT_Re_QC_RequiredPicklist;
    @track Mail_Forwarded_Picklist;
    @track billingPicklistValues;
    @track regionPicklistValues;
    @track OrderTypePicklist;

    @track oldOrderTracker;

    @track isShowParentOrderTrackerComponent = true;
    @track isSpinnerLoading = true;
    @track openRemarksEditor=false;
    @track oldRemarksValue='';
    @track editRemarksValue='';
    @track indexOfOrderTracker;//index of order tracker to be edited
    @track fieldName='';//field name to refer which picklist is selected
    

    @track checkingOPRepMap=[];
    @track processingOPRepMap=[];
    @track OPRepFollowingUpMap=[];
    @track finalApproverMap=[];
    @track isUserAdministrator='';
    @track openPartnerandEndUserEditor=false;
    @track oldPartnerEndUserValue='';
    @track editPartnerEndUserValue='';
    @track openCurrencyModalEditor=false;
    @track oldCurrencyValue='';
    @track editCurrencyValue='';
    @track MessageWhenNoRecords='';
    @track picklistName;
    @track picklistValue;
    @track oldPicklistValue='';

    @track prfName='';

    @track userProfile='';
    @track userId='';

    @track assignedUser='';
    @track openAssignedUserModal=false;

    @track newAssignee='';

    @track blankSpace=true;
    @track selecetdOT;
    @track selectedPOID;
    @track showPOModal = false;


    @track selectedMailChainId;
    @track showPOFileUploadModal = false;
    showMergeButton = false;
    openMergeModal = false;

    @track poFileMAP;
    @track mailChainMAP;
    @track selectedRecords =[];
    @track arrayWithPrimaryKey =[];
    @track showPOFileModifyModal = false;
    @track selectedOTFiles = [];
    showSpinner = false;

    openPOFileUploadModal(){
        if(this.selectedMailChainId){
            this.showPOFileUploadModal = true;
        }
    }
    openPOFileModifyModal(){
        if(this.selectedMailChainId){
            this.showPOFileModifyModal = true;
        }
        console.log(this.selectedMailChainId);
        console.log('testing ')
    }

    SubmitOTForReQc(event){
        this.submitForReqcCheck = event.target.checked;
    }
    saveForReQc(event){
        if(this.submitForReqcCheck){
            this.showSpinner = true;
            let botReqcValue = 'Yes';
            const fields = {};

            fields[ID_FIELD.fieldApiName] = this.selecetdOT;
            fields[BOT_Re_QC_Required_FIELD.fieldApiName] = botReqcValue;
                //5. Create a config object that had info about fields. 
                //Quick heads up here we are not providing Object API Name
            const recordInput = {
              fields: fields
            };
        
                //6. Invoke the method updateRecord()
            updateRecord(recordInput).then((record) => {
                this.showSpinner = false;
                this.closePOFileModifyModal();
                this.getOrderTrackers();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Submitted For Re-Qc',
                        variant: 'success'
                    })
                );              
            }).catch(error =>{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed To Update Record, Please Contact System Administrator',
                        variant: 'error'
                    })
                ); 
            });
        }
        this.showSpinner = false;
    }

    closePOFileUploadModal() {
        this.showPOFileUploadModal = false;
        this.selecetdOT = undefined;
        this.selectedMailChainId = undefined;
    }

    closePOFileModifyModal() {
        this.showPOFileModifyModal = false;
        this.selecetdOT = undefined;
        this.selectedMailChainId = undefined;
        this.submitForReqcCheck = false;
    }

    handlePOFileUploadButtonClick(event){
        console.log('--handlePOFileUploadButtonClick-called--');
        if(event.target && event.target.dataset  && event.target.dataset.id && event.target.dataset.ot){
            console.log('--selectedMailChainId--',event.target.dataset.id);
            console.log('--selected-ot--',event.target.dataset.ot);
            this.selecetdOT = event.target.dataset.ot;
            this.selectedMailChainId =  event.target.dataset.id;
            this.openPOFileUploadModal();
        }
    }

    handlePOFileModifyButtonClick(event){
        if(event.target && event.target.dataset  && event.target.dataset.id && event.target.dataset.ot){
            console.log('--selectedMailChainId--',event.target.dataset.id);
            console.log('--selected-ot--',event.target.dataset.ot);
            this.selecetdOT = event.target.dataset.ot;
            this.selectedMailChainId =  event.target.dataset.id;
            console.log('Test');
            console.log(this.poFileMAP[this.selecetdOT]);
            this.selectedOTFiles = this.poFileMAP[this.selecetdOT];
            this.openPOFileModifyModal();
        }
    }

    get fileFieldValue(){
        return 'PO_Document';
    }

    deleteFile(event){
        this.showSpinner = true;
        let deleteId = event.target.name;
        deleteRecord(deleteId)
        .then(() => {
            let objIndex = this.selectedOTFiles.findIndex((obj => obj.fileId == deleteId ));
            this.selectedOTFiles.splice(objIndex,1);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record deleted successfully',
                    variant: 'success'
                })
            );
            this.showSpinner = false;
    });
}

    handleUploadFinished(event) {
        this.showSpinner = true;
        console.log('--handleUploadFinished-called--');
        let uploadedFiles=event.detail.files;
        if (uploadedFiles) {
            
            // CR# 4946 START
            let contentDocumentIds = [];
            for (let file of uploadedFiles) {
                contentDocumentIds.push(file.documentId);
            }
            // CR# 4946 END

            this.isSpinnerLoading = true;

            // CR# 4946 START
            attachPODocumentToOpportunity({
                orderTrackerId : this.selecetdOT,
                contentDocumentIdsList : contentDocumentIds
            }).then(result => {
                this.closePOFileModifyModal();
                this.getOrderTrackers();
                this.closePOFileUploadModal();
                this.showSpinner = false;
            }).catch(error => {
                this.template.querySelector('c-custom-toast-component').showToast('error', error);
                this.handleSpinnerLoadingOff();
                this.showSpinner = false;
            })
            // CR# 4946 END
        }
    }
    openPOModal(){
        if(this.selecetdOT){
            this.showPOModal = true;
        }
    }

    closePOModal() {
        this.showPOModal = false;
        this.selectedPOID = undefined;
    }


    handlePODetailButtonClick(event){
         console.log('--handlePODetailButtonClick-called--');
        if(event.target && event.target.dataset && event.target.dataset.id  && event.target.dataset.ot){
            console.log('--selected-po--',event.target.dataset.id);
            console.log('--selected-Ot--',event.target.dataset.ot);
            this.selectedPOID = event.target.dataset.id;
            this.selecetdOT = event.target.dataset.ot;
            //this.openPOModal();
            this.handleRedirectToRecord(this.selectedPOID, 'PO_Detail__c');
        }
    }

    handleCreatePODetail(event){
        console.log('--handleCreatePODetail-called--');   
        if(event.target && event.target.dataset && event.target.dataset.ot){ 
            console.log('--selecetdOT--',event.target.dataset.ot);
            this.selecetdOT = event.target.dataset.ot;
            this.selectedPOID = undefined;
            this.openPOModal();
        }
    }
    //get the picklist value of status field from Order Tracker Object
    @wire(getObjectInfo, { objectApiName: ORDER_TRACKER_OBJECT })
    orderMetadata;

    @wire(getPicklistValues,
        {
            recordTypeId: '$orderMetadata.data.defaultRecordTypeId',
            fieldApiName: STATUS_FIELD
        }
    )
    wiredstatusPickList({ data }) {
        if (data) {
            this.statusPicklistValues=data.values;           
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$orderMetadata.data.defaultRecordTypeId',
            fieldApiName: Region_FIELD
        }
    )
    wiredregionPickList({ data }) {
        if (data) {
            this.regionPicklistValues=data.values;           
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$orderMetadata.data.defaultRecordTypeId',
            fieldApiName: Billing_Frequency_FIELD
        }
    )
    wiredBillingFrequencyPickList({ data }) {
        if (data) {
            this.billingPicklistValues=data.values;           
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$orderMetadata.data.defaultRecordTypeId',
            fieldApiName: Attachment_on_NS_SF_FIELD
        }
    )
    wiredAttchmentPickList({ data,error }) {
        if (data) {
            this.attachmentOnNsSFPicklist=data.values;           
        }
        else if(error)
        {
           
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$orderMetadata.data.defaultRecordTypeId',
            fieldApiName: ZA_Updated_FIELD
        }
    )
    wiredZAUpdPickList({ data }) {
        if (data) {
            this.ZA_UpdatedPicklist=data.values;           
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$orderMetadata.data.defaultRecordTypeId',
            fieldApiName: All_SFDC_Processses_Updated_FIELD
        }
    )
    wiredAllSFDCPickList({ data,error }) {
        if (data) {
            this.All_SFDC_Processses_UpdatedPicklist=data.values;           
        }
        else if(error)
        {
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$orderMetadata.data.defaultRecordTypeId',
            fieldApiName: Confirm_all_dependant_PRs_moved_to_prod_FIELD
        }
    )
    wiredConfirmPickList({ data }) {
        if (data) {
            this.Confirm_all_dependant_PRs_moved_to_prodPicklist=data.values;           
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$orderMetadata.data.defaultRecordTypeId',
            fieldApiName: BOT_Auto_QC_Done_FIELD
        }
    )
    wiredBotAutoPickList({ data }) {
        if (data) {
            this.BOT_Auto_QC_DonePicklist=data.values;           
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$orderMetadata.data.defaultRecordTypeId',
            fieldApiName: BOT_Re_QC_Required_FIELD
        }
    )
    wiredBotRePickList({ data }) {
        if (data) {
            
            this.BOT_Re_QC_RequiredPicklist=data.values;    
            console.log('-- this.BOT_Re_QC_RequiredPicklist---',this.BOT_Re_QC_RequiredPicklist);       
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$orderMetadata.data.defaultRecordTypeId',
            fieldApiName: Mail_Forwarded_FIELD
        }
    )
    wiredMailForwardedPickList({ data }) {
        if (data) {
            this.Mail_Forwarded_Picklist=data.values;           
        }
    }


    @wire(getPicklistValues,
        {
            recordTypeId: '$orderMetadata.data.defaultRecordTypeId',
            fieldApiName: ORDER_TYPE_FIELD
        }
    )
    wiredOrderTypePickList({ data }) {
        if (data) {
            this.OrderTypePicklist=data.values;           
        }
    }

    
    
    connectedCallback() {
        this.isSpinnerLoading=true;
        this.showPicklist=true;
        this.getUserInformation();
        
    }
    handleEnter(event){
        if(event.keyCode === 13) {
            this.handleSearchedValue();
        }
    }

    get enhancedTableOrderTrackers() {
        let otList = [];
        if (this.tableOrderTrackers && this.tableOrderTrackers.length > 0) {
            this.tableOrderTrackers.forEach(currentItem => {
                let curEle = currentItem;
                if (curEle.PO_Detail__c && curEle.PO_Detail__r) {
                    curEle.PO_ID = curEle.PO_Detail__c;
                    curEle.PO_NAME = curEle.PO_Detail__r.Name;
                }

                //CR#4456
                curEle.ShowMailForwarded =      (
                                                    (curEle.Source__c == undefined || curEle.Source__c == null) || 
                                                    (curEle.Source__c && curEle.Source__c  != 'EDI' )
                                                )
                                                && curEle.Proposal_for_initiating_QC__c
                                                && curEle.From__c 
                                                && !(curEle.From__c.toUpperCase().indexOf("ZSCALER.COM")  > 0) ? true : false;
                curEle.POFromEDI = curEle.Source__c && curEle.Source__c  == 'EDI' ? true: false;
                otList.push(curEle);
            });
        }
        return otList;
    }




    getUserInformation() {
        getUserInformation()
            .then(result => {

                this.userProfile = result['Profile'];
                this.userId = result['UserId'];

                if (this.userProfile == 'System Administrator') {
                    this.isUserAdministrator = true;
                } else {
                    this.isUserAdministrator = false;
                }
                this.getMetadataPicklists();
            }).catch(error => {

            })
    }

    getMetadataPicklists() {
        getMetadataPicklists()
            .then(result => {
                let oprep = [];
                let processing = [];
                let finalapp = [];
                let checking = [];
                let picklist1 = [];
                let picklist2 = [];
                let picklist3 = [];
                let picklist4 = [];


                let map1 = new Map();

                let map2 = new Map();

                let map3 = new Map();

                let map4 = new Map();

                processing = result['processing op rep'];
                finalapp = result['final approver'];
                checking = result['checking op rep'];
                oprep = result['op rep following up'];


                if (this.isUserAdministrator == true) {
                    for (let i = 0; i < processing.length; i++) {
                        picklist1.push({
                            label: processing[i].Label,
                            value: processing[i].User_Id__c
                        });
                        map1.set(processing[i].User_Id__c, processing[i].Label);
                    }
                    for (let i = 0; i < oprep.length; i++) {

                        picklist2.push({
                            label: oprep[i].Label,
                            value: oprep[i].User_Id__c
                        });
                        map2.set(oprep[i].User_Id__c, oprep[i].Label);
                    }
                    for (let i = 0; i < finalapp.length; i++) {

                        picklist3.push({
                            label: finalapp[i].Label,
                            value: finalapp[i].User_Id__c
                        });
                        map3.set(finalapp[i].User_Id__c, finalapp[i].Label);
                    }
                    for (let i = 0; i < checking.length; i++) {

                        picklist4.push({
                            label: checking[i].Label,
                            value: checking[i].User_Id__c
                        });
                        map4.set(checking[i].User_Id__c, checking[i].Label);
                    }
                } else if (this.isUserAdministrator == false) {

                    for (let i = 0; i < processing.length; i++) {

                        map1.set(processing[i].User_Id__c, processing[i].Label);
                        if (processing[i].User_Id__c == this.userId) {
                            picklist1.push({
                                label: processing[i].Label,
                                value: processing[i].User_Id__c
                            });
                        }

                    }
                    for (let i = 0; i < oprep.length; i++) {

                        map2.set(oprep[i].User_Id__c, oprep[i].Label);
                        if (oprep[i].User_Id__c == this.userId) {
                            picklist2.push({
                                label: oprep[i].Label,
                                value: oprep[i].User_Id__c
                            });
                        }
                    }
                    for (let i = 0; i < finalapp.length; i++) {

                        map3.set(finalapp[i].User_Id__c, finalapp[i].Label);
                        if (finalapp[i].User_Id__c == this.userId) {
                            picklist3.push({
                                label: finalapp[i].Label,
                                value: finalapp[i].User_Id__c
                            });
                        }

                    }
                    for (let i = 0; i < checking.length; i++) {

                        map4.set(checking[i].User_Id__c, checking[i].Label);
                        if (checking[i].User_Id__c == this.userId) {
                            picklist4.push({
                                label: checking[i].Label,
                                value: checking[i].User_Id__c
                            });
                        }
                    }
                }
                this.processingOPRepMap = map1;
                this.processingOPRepPicklist = picklist1;
                this.processingOPRepPicklist = this.processingOPRepPicklist.sort(this.sortBy('label', false));
                

                this.OPRepFollowingUpMap = map2;
                this.OPRepFollowingUpPicklist = picklist2;
                this.OPRepFollowingUpPicklist = this.OPRepFollowingUpPicklist.sort(this.sortBy('label', false));

                this.finalApproverMap = map3;
                this.finalApproverPicklist = picklist3;
                this.finalApproverPicklist = this.finalApproverPicklist.sort(this.sortBy('label', false));

                this.checkingOPRepMap = map4;
                this.checkingOPRepPicklist = picklist4;
                this.checkingOPRepPicklist = this.checkingOPRepPicklist.sort(this.sortBy('label', false));

                this.getOrderTrackers();
            }).catch(error => {

            })
    }


    async sendPODetailstoSE(otid){
        console.log('sendPODetailstoSE--called---');
        console.log('sendPODetailstoSE--otid---',otid);
        await sendSEMailNotificationMethod({
                orderTrackerId : otid
            })
            .then((result) => {

            }).catch((error) => {
                this.template.querySelector('c-custom-toast-component').showToast('error', 'No Records To Display');
                this.handleSpinnerLoadingOff();
            });
        
    }
    

    //function to get order trackers from search, change of page
    getOrderTrackers() {
        this.tableOrderTrackers = [];
        let PO = this.searchedPOValue,
        SO = this.searchedSOValue,
        Proposal = this.searchedProposalValue,
        Subject = this.searchedSubjectValue,
        Ticket = this.searchedTicketValue,
        Source = this.selectedSourcevalue,
        Universal = this.universalSearchValue,
        EmailAndTicket = this.searchedTicketAndEmailValue;

        if (this.searchedPOValue != '' || this.searchedSOValue != '' || this.searchedSubjectValue != '' || this.searchedTicketValue != '' || this.searchedProposalValue != '' || this.universalSearchValue != '' || this.searchedTicketAndEmailValue !='') {

            if (this.searchedPOValue == '')
                PO = '@,,@@&&&&***$$###kl.mn';

            if (this.searchedSOValue == '')
                SO = '@,,@@&&&&***$$###kl.mn';

            if (this.searchedSubjectValue == '')
                Subject = '@,,@@&&&&***$$###kl.mn';

            if (this.searchedTicketValue == '')
                Ticket = '@,,@@&&&&***$$###kl.mn';
            if (this.searchedProposalValue == '')
                Proposal = '@,,@@&&&&***$$###kl.mn';  
            if(this.searchedTicketAndEmailValue == '')
                EmailAndTicket = '@,,@@&&&&***$$###kl.mn'; 
        }
        getNextOrderTrackers({
                selectedTab: this.clickedTab,
                pageNumber: this.pageNumber,
                pageLimit: this.selectedPageOption,
                viewPicklistValue: this.selectedViewvalue,
                searchedPONumber: PO,
                searchedSONumber: SO,
                searchedEmailSubject: Subject,
                searchedTicketValue: Ticket,
                searchedProposalValue : Proposal,
                selectedSourcevalue : Source,
                universalSearchValue : Universal,
                searchedEmailTicket : EmailAndTicket
            })
            .then((result) => {

                console.log('--result--', result);

                let orders = [];
                let length;
                let orderList = [];
                let varMChainAttachment = [];
                orders = result['orderTrackerList'];



                if (result['attachments'] != undefined) {
                    varMChainAttachment = result['attachments'];
                }
                this.pageNumber = result['pageNumber'];
                this.totalRecords = result['totalOrderTrackerRecords'];
                this.recordStart = result['recordStart'];
                this.recordEnd = result['recordEnd'];
                this.totalPages = Math.ceil(result['totalOrderTrackerRecords'] / this.selectedPageOption);
                this.showNextButton = (this.pageNumber == this.totalPages || this.totalPages == 0);
                this.showPrevButton = (this.pageNumber == 1 || this.totalRecords < this.pageSize);

                this.poFileMAP = result['poFileAttachments'];
                this.mailChainMAP = result['mailChainMAP'];

                if (this.recordEnd - this.recordStart + 1 < this.selectedPageOption) {
                    length = this.recordEnd - this.recordStart + 1;
                } else {
                    length = this.selectedPageOption;
                }
                if (this.totalRecords == 0 && (this.searchedSubjectValue == '' && this.searchedPOValue == '' && this.searchedSOValue == '' && this.selectedViewvalue == 'All' && this.searchedTicketValue == '' && this.searchedProposalValue == '' && this.searchedTicketAndEmailValue == '' && this.universalSearchValue == '')){

                    this.disableSearch = true;
                    this.noRecords = true;
                } else if (this.totalRecords == 0 && (this.searchedSOValue != '' || this.selectedViewvalue != 'All' || this.searchedPOValue != '' || this.searchedSubjectValue != '' || this.searchedTicketValue != '' || this.searchedProposalValue != '' || this.searchedTicketAndEmailValue != '' || this.universalSearchValue != '' || this.selectedSourcevalue !='All')) {

                    this.disableSearch = false;
                    this.noRecords = true;
                } else if (this.totalRecords != 0) {
                    this.disableSearch = false;
                    this.noRecords = false;
                }
                if (this.clickedTab == 'Assigned To Me') {
                    this.MessageWhenNoRecords = 'No Order Tickets Assigned To You!!';
                } else if (this.clickedTab == 'All') {
                    this.MessageWhenNoRecords = 'No Order Trackers!!';
                }

                for (var i = 0; i < length; i++) {
                    if (this.isUserAdministrator == false) {
                        if (orders[i].Checking_OP_Rep_QC_Rep__c == this.userId || (orders[i].Checking_OP_Rep_QC_Rep__c == undefined && this.checkingOPRepPicklist.length != 0)) {
                            orders[i].disableChecking = false;
                        } else {
                            orders[i].disableChecking = true;
                        }
                        if (orders[i].Processing_OP_Rep__c == this.userId || (orders[i].Processing_OP_Rep__c == undefined && this.processingOPRepPicklist.length != 0)) {
                            orders[i].disableProcessing = false;
                        } else {
                            orders[i].disableProcessing = true;
                        }
                        if (orders[i].OP_Rep_Following_Up__c == this.userId || (orders[i].OP_Rep_Following_Up__c == undefined && this.OPRepFollowingUpPicklist.length != 0)) {
                            orders[i].disableOPRep = false;
                        } else {
                            orders[i].disableOPRep = true;
                        }
                        if (orders[i].Final_Approver__c == this.userId || (orders[i].Final_Approver__c == undefined && this.finalApproverPicklist.length != 0)) {
                            orders[i].disableFinalApp = false;
                        } else {
                            orders[i].disableFinalApp = true;
                        }
                    } else if (this.isUserAdministrator == true) {
                        orders[i].disableChecking = false;
                        orders[i].disableFinalApp = false;
                        orders[i].disableOPRep = false;
                        orders[i].disableProcessing = false;
                    }

                    var attachmentArr = [];
                    if (orders[i].BOT_Auto_QC_Done__c == 'Yes') {
                        for (let attachment of varMChainAttachment) {
                            if (orders[i].Id === attachment.orderTrackerId) {
                                var attachmentObj = {};
                                attachmentObj.fileId = attachment.fileId;
                                attachmentObj.fileTitle = attachment.fileTitle;
                                // orders[i]..fileId = attachment.fileId;
                                // orders[i]..fileTitle = attachment.fileTitle;
                                attachmentArr.push(attachmentObj);
                                if (attachmentArr.length === 2) {
                                    break;
                                }
                            }

                        }

                        orders[i].fileAttachment = attachmentArr;
                    }
                    if (orders[i].TAT_QC_Check__c != '0.0') {
                        orders[i].TAT_QC_Check__c = this.tatFormat(orders[i].TAT_QC_Check__c);
                    } else if (orders[i].TAT_QC_Check__c == '0.0') {
                        orders[i].TAT_QC_Check__c = '';
                    }

                    if (orders[i].TAT_Order_Approval__c != '0.0') {
                        orders[i].TAT_Order_Approval__c = this.tatFormat(orders[i].TAT_Order_Approval__c);
                    } else if (orders[i].TAT_Order_Approval__c == '0.0') {
                        orders[i].TAT_Order_Approval__c = '';
                    }

                    if (orders[i].TAT_Billing__c != '0.0') {
                        orders[i].TAT_Billing__c = this.tatFormat(orders[i].TAT_Billing__c);
                    } else if (orders[i].TAT_Billing__c == '0.0') {
                        orders[i].TAT_Billing__c = '';
                    }
                    orders[i].Checking_OP_Rep_QC_Rep__c = this.checkingOPRepMap.get(orders[i].Checking_OP_Rep_QC_Rep__c);
                    orders[i].Processing_OP_Rep__c = this.processingOPRepMap.get(orders[i].Processing_OP_Rep__c);
                    orders[i].OP_Rep_Following_Up__c = this.OPRepFollowingUpMap.get(orders[i].OP_Rep_Following_Up__c);
                    orders[i].Final_Approver__c = this.finalApproverMap.get(orders[i].Final_Approver__c);
                    orders[i].Received_Date__c = (orders[i].Received_Date__c ? this.dateFormat(orders[i].Received_Date__c, 'dateTime') : ' ');
                    if (orders[i].ACV__c)
                        orders[i].ACV__c = this.currencyFormat(orders[i].ACV__c);
                    if (orders[i].PO_Amount__c)
                        orders[i].PO_Amount__c = this.currencyFormat(orders[i].PO_Amount__c);
                    if (orders[i].X1st_Billing_Amount_USD__c)
                        orders[i].X1st_Billing_Amount_USD__c = this.currencyFormat(orders[i].X1st_Billing_Amount_USD__c);


                    for(let orderID in this.poFileMAP){
                        if(orderID == orders[i].Id ){
                            let poattachmentArr = [];
                            for (let attachment of this.poFileMAP[orderID]) {    
                                var attachmentObj = {};
                                attachmentObj.fileId = attachment.fileId;
                                attachmentObj.fileTitle = attachment.fileTitle;
                                poattachmentArr.push(attachmentObj);
                            }
                            orders[i].pofileAttachment = poattachmentArr;
                        }
                    }

                    for(let orderID in this.mailChainMAP){
                        if(orderID == orders[i].Id ){
                            orders[i].mailChainId = this.mailChainMAP[orderID];
                        }
                    }
                    if(orders[i].Status__c == 'Merged'){
                        orders[i].disableStatus = true;
                    }
                    else{
                        orders[i].disableStatus = false;  
                    }

                    orderList.push(orders[i]);

                }
                this.tableOrderTrackers = orderList;
                console.log('---this.tableOrderTrackers---', this.tableOrderTrackers);
                this.handleSpinnerLoadingOff();

            }).catch((error) => {
                this.template.querySelector('c-custom-toast-component').showToast('error', 'No Records To Display');
                this.handleSpinnerLoadingOff();
            });


    }
    
    //function to handle status change
    handleViewChange(event) {
        this.isSpinnerLoading=true;
        this.selectedViewvalue = event.detail.value;
        this.universalSearchValue = '';
        this.pageNumber=1;
        this.getOrderTrackers();        
    }
    handleSourceChange(event) {
        this.isSpinnerLoading=true;
        this.selectedSourcevalue = event.detail.value;
        this.universalSearchValue ='';
        this.pageNumber=1;
        this.getOrderTrackers();        
    }

    //function to handle changes in page options 
    handlePageOptions(event) {
        this.isSpinnerLoading = true;
        this.selectedPageOption = event.detail.value;
        this.pageNumber = 1;
        this.getOrderTrackers();       
    }

    //handle changes in search input field
    handlePOSearchInput(event) {
        this.searchedPOValue = event.target.value;
        this.universalSearchValue = '';
        if (event.target.value == '') {
            this.isSpinnerLoading = true;
            this.getOrderTrackers();

        }

    }
    handleSOSearchInput(event) {
        this.searchedSOValue = event.target.value;
        this.universalSearchValue = '';
        if (event.target.value == '') {
            this.isSpinnerLoading = true;
            this.getOrderTrackers();

        }
    }
    handleSubjectSearchInput(event) {
        this.searchedSubjectValue = event.target.value;
        this.universalSearchValue = '';
        if (event.target.value == '') {
            this.isSpinnerLoading = true;
            this.getOrderTrackers();

        }
    }
    handleProposalSearchInput(event) {
        this.searchedProposalValue = event.target.value;
        this.universalSearchValue = '';
        if (event.target.value == '') {
            this.isSpinnerLoading = true;
            this.getOrderTrackers();
        }
    }

    handleTicketSearchInput(event) {
        this.searchedTicketValue = event.target.value;
        this.universalSearchValue = '';
        if (event.target.value == '') {
            this.isSpinnerLoading = true;
            this.getOrderTrackers();

        }
    }
    	
    handleTicketEmailSearchInput(event) {
        this.searchedTicketAndEmailValue = event.target.value;
        this.universalSearchValue = '';
        if (event.target.value == '') {
            this.isSpinnerLoading = true;
            this.getOrderTrackers();
        }
    }
    handleUniversalSearchInput(event){
        this.universalSearchValue = event.target.value;
        this.setDefault();
        if (event.target.value == '') {
            this.isSpinnerLoading = true;
            this.getOrderTrackers();
        }
    }
    //Set default values
    setDefault(){
        this.selectedViewvalue = 'All';
        this.searchFilterStr = '';
        this.searchedPOValue = '';
        this.searchedSOValue = '';
        this.searchedSubjectValue = '';
        this.searchedTicketValue = '';
        this.searchedProposalValue = '';
        this.selectedSourcevalue ='All';
        this.searchedTicketAndEmailValue = '';
        this.pageNumber = 1;
    }
    //handle search button event
    handleSearchedValue() {
        this.isSpinnerLoading = true;
        this.pageNumber = 1;
        this.getOrderTrackers();

    }


    //handle refresh button event
    handleRefresh() {
        this.isSpinnerLoading = true;
        this.selectedViewvalue = 'All';
        this.searchFilterStr = '';
        this.searchedPOValue = '';
        this.searchedSOValue = '';
        this.searchedSubjectValue = '';
        this.searchedTicketValue = '';
        this.searchedProposalValue = '';
        this.selectedSourcevalue ='All';
        this.universalSearchValue='';
        this.searchedTicketAndEmailValue = '';
        this.pageNumber = 1;
        this.getOrderTrackers();
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
        } else if (methodString === 'date') {
            return date + ' ' + month + ' ' + year;
        }

    }

    //handle Previous Page on-click 
    handlePreviouspage() {
        this.isSpinnerLoading = true;
        this.pageNumber -= 1;
        this.getOrderTrackers();

    }

    //handle Next Page on-click
    handleNextpage() {
        this.isSpinnerLoading = true;
        this.pageNumber += 1;
        this.getOrderTrackers();
    }

    //event to go from parent to child
    handleOrderTracker(event) {
        this.isShowParentOrderTrackerComponent = false;
        this.orderTrackerId = event.currentTarget.dataset.id;
    }

    //event to get from child to parent
    handleMailChainEvent(event) {
        this.isSpinnerLoading = true;
        this.isShowParentOrderTrackerComponent = event.detail.showParent;
        let isTrackerMoved = event.detail.trackerMoved;

        if (isTrackerMoved == true) {
            this.template.querySelector('c-custom-toast-component').showToast('success', 'Ticket coverted to Email Tracker successfully');
        }
        this.getOrderTrackers();
        //this.handleSpinnerLoadingOff();
    }

    //handle picklist changes
    async handlepicklistValueChange(event) {

        this.indexOfOrderTracker = event.currentTarget.dataset.id;
        this.picklistName = event.target.name;
        this.picklistValue = event.target.value;
        this.orderTrackerId = this.tableOrderTrackers[this.indexOfOrderTracker].Id;
        console.log('---orderTrackerId---',this.orderTrackerId);

        if (this.picklistName == 'All SFDC Processes Updated' && (this.tableOrderTrackers[this.indexOfOrderTracker].All_SFDC_Processses_Updated__c != this.picklistValue || this.tableOrderTrackers[this.indexOfOrderTracker].All_SFDC_Processses_Updated__c == undefined)) {
            this.tableOrderTrackers[this.indexOfOrderTracker].All_SFDC_Processses_Updated__c = this.picklistValue;
            this.updateOrderTracker();
        } else if (this.picklistName == 'Attachment on NS and SF' && (this.tableOrderTrackers[this.indexOfOrderTracker].Attachment_on_NS_SF__c != this.picklistValue || this.tableOrderTrackers[this.indexOfOrderTracker].Attachment_on_NS_SF__c == undefined)) {
            this.tableOrderTrackers[this.indexOfOrderTracker].Attachment_on_NS_SF__c = this.picklistValue;
            this.updateOrderTracker();
        } else if (this.picklistName == 'Bot Auto QC done' && (this.tableOrderTrackers[this.indexOfOrderTracker].BOT_Auto_QC_Done__c != this.picklistValue || this.tableOrderTrackers[this.indexOfOrderTracker].BOT_Auto_QC_Done__c == undefined)) {
            this.tableOrderTrackers[this.indexOfOrderTracker].BOT_Auto_QC_Done__c = this.picklistValue;
            this.updateOrderTracker();
        } else if (this.picklistName == 'Bot Re QC Required' && (this.tableOrderTrackers[this.indexOfOrderTracker].BOT_Re_QC_Required__c != this.picklistValue || this.tableOrderTrackers[this.indexOfOrderTracker].BOT_Re_QC_Required__c == undefined)) {
            this.tableOrderTrackers[this.indexOfOrderTracker].BOT_Re_QC_Required__c = this.picklistValue;
            this.updateOrderTracker();
        } else if (this.picklistName == 'Checking OP Rep/QC Rep' && this.tableOrderTrackers[this.indexOfOrderTracker].Checking_OP_Rep_QC_Rep__c != this.checkingOPRepMap.get(this.picklistValue)) {
            this.getUpdatedOrderTracker();
        } else if (this.picklistName == 'Confirm if all dependent PRs are moved to Production' && (this.tableOrderTrackers[this.indexOfOrderTracker].confirm_all_dependant_PRs_moved_to_prod__c != this.picklistValue || this.tableOrderTrackers[this.indexOfOrderTracker].confirm_all_dependant_PRs_moved_to_prod__c == undefined)) {
            this.tableOrderTrackers[this.indexOfOrderTracker].confirm_all_dependant_PRs_moved_to_prod__c = this.picklistValue;
            this.updateOrderTracker();
        } else if (this.picklistName == 'Final Approver' && this.tableOrderTrackers[this.indexOfOrderTracker].Final_Approver__c != this.finalApproverMap.get(this.picklistValue)) {
            this.getUpdatedOrderTracker();
        } else if (this.picklistName == 'OP Rep Following Up' && this.tableOrderTrackers[this.indexOfOrderTracker].OP_Rep_Following_Up__c != this.OPRepFollowingUpMap.get(this.picklistValue)) {
            this.getUpdatedOrderTracker();
        } else if (this.picklistName == 'Processing OP Rep' && this.tableOrderTrackers[this.indexOfOrderTracker].Processing_OP_Rep__c != this.processingOPRepMap.get(this.picklistValue)) {
            this.getUpdatedOrderTracker();
        } else if (this.picklistName == 'Status' && (this.tableOrderTrackers[this.indexOfOrderTracker].Status__c != this.picklistValue || this.tableOrderTrackers[this.indexOfOrderTracker].Status__c == undefined)) {
            if(this.picklistValue != 'Merged'){
                this.tableOrderTrackers[this.indexOfOrderTracker].Status__c = this.picklistValue;
                this.updateOrderTracker();
            }
            else{
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Status cannot be changed to Merged manually. Please select a different status.');
            }
        } else if (this.picklistName == 'ZA Updated' && (this.tableOrderTrackers[this.indexOfOrderTracker].ZA_Updated__c != this.picklistValue || this.tableOrderTrackers[this.indexOfOrderTracker].ZA_Updated__c == undefined)) {
            this.tableOrderTrackers[this.indexOfOrderTracker].ZA_Updated__c = this.picklistValue;
            this.updateOrderTracker();
        } else if (this.picklistName == 'Billing Frequency' && (this.tableOrderTrackers[this.indexOfOrderTracker].Billing_Frequency__c != this.picklistValue || this.tableOrderTrackers[this.indexOfOrderTracker].Billing_Frequency__c == undefined)) {
            this.tableOrderTrackers[this.indexOfOrderTracker].Billing_Frequency__c = this.picklistValue;
            this.updateOrderTracker();
        } else if (this.picklistName == 'Region' && (this.tableOrderTrackers[this.indexOfOrderTracker].Region__c != this.picklistValue || this.tableOrderTrackers[this.indexOfOrderTracker].Region__c == undefined)) {
            this.tableOrderTrackers[this.indexOfOrderTracker].Region__c = this.picklistValue;
            this.updateOrderTracker();
        } else if (this.picklistName == 'Order Type' && (this.tableOrderTrackers[this.indexOfOrderTracker].Order_Type__c != this.picklistValue || this.tableOrderTrackers[this.indexOfOrderTracker].Order_Type__c == undefined)) {
            this.tableOrderTrackers[this.indexOfOrderTracker].Order_Type__c = this.picklistValue;
            this.updateOrderTracker();
        } else if (this.picklistName == 'Mail Forwarded' && (this.tableOrderTrackers[this.indexOfOrderTracker].Mail_Forwarded__c != this.picklistValue || this.tableOrderTrackers[this.indexOfOrderTracker].Mail_Forwarded__c == undefined)) {
            let oldVal =  this.tableOrderTrackers[this.indexOfOrderTracker].Mail_Forwarded__c
            console.log('---Mail_Forwarded__c--oldVal--',oldVal);
            this.tableOrderTrackers[this.indexOfOrderTracker].Mail_Forwarded__c = this.picklistValue;
            if(oldVal !=this.picklistValue &&  this.picklistValue == 'Yes'){
                if(this.tableOrderTrackers[this.indexOfOrderTracker].Proposal_for_initiating_QC__c == undefined || this.tableOrderTrackers[this.indexOfOrderTracker].Proposal_for_initiating_QC__c == ''){
                    this.template.querySelector('c-custom-toast-component').showToast('error', 'Quote Number is required before proceeding');
                }
                else{
                    this.isSpinnerLoading = true;
                    await this.sendPODetailstoSE(this.orderTrackerId);
                    this.updateOrderTracker();
                }
            }else{
                this.updateOrderTracker();
            }
        }
    }

    getUpdatedOrderTracker() {
        this.isSpinnerLoading = true;
        getOrderTracker({
            orderTrackerId: this.orderTrackerId
        }).then(result => {
            this.isSpinnerLoading = false;
            this.orderTrackerNew = result;
            if (this.picklistName == 'Checking OP Rep/QC Rep') {
                if (this.picklistValue != this.orderTrackerNew.Checking_OP_Rep_QC_Rep__c && this.orderTrackerNew.Checking_OP_Rep_QC_Rep__c != null) {
                    this.assignedUser = this.checkingOPRepMap.get(this.orderTrackerNew.Checking_OP_Rep_QC_Rep__c);
                    this.newAssignee = this.checkingOPRepMap.get(this.picklistValue);
                    this.openAssignedUserModal = true;

                } else {
                    this.saveChangedAssignedUser();
                }

            } else if (this.picklistName == 'Final Approver' && this.picklistValue != this.orderTrackerNew.Final_Approver__c) {
                if (this.picklistValue != this.orderTrackerNew.Final_Approver__c && this.orderTrackerNew.Final_Approver__c != null) {
                    this.assignedUser = this.finalApproverMap.get(this.orderTrackerNew.Final_Approver__c);
                    this.newAssignee = this.finalApproverMap.get(this.picklistValue);
                    this.openAssignedUserModal = true;
                } else {
                    this.saveChangedAssignedUser();
                }
            } else if (this.picklistName == 'OP Rep Following Up' && this.picklistValue != this.orderTrackerNew.OP_Rep_Following_Up__c) {
                if (this.picklistValue != this.orderTrackerNew.OP_Rep_Following_Up__c && this.orderTrackerNew.OP_Rep_Following_Up__c != null) {
                    this.assignedUser = this.OPRepFollowingUpMap.get(this.orderTrackerNew.OP_Rep_Following_Up__c);
                    this.newAssignee = this.OPRepFollowingUpMap.get(this.picklistValue);
                    this.openAssignedUserModal = true;
                } else {
                    this.saveChangedAssignedUser();
                }
            } else if (this.picklistName == 'Processing OP Rep' && this.picklistValue != this.orderTrackerNew.Processing_OP_Rep__c) {
                if (this.picklistValue != this.orderTrackerNew.Processing_OP_Rep__c && this.orderTrackerNew.Processing_OP_Rep__c != null) {
                    this.assignedUser = this.processingOPRepMap.get(this.orderTrackerNew.Processing_OP_Rep__c);
                    this.newAssignee = this.processingOPRepMap.get(this.picklistValue);
                    this.openAssignedUserModal = true;
                } else {
                    this.saveChangedAssignedUser();
                }
            }
        }).catch(error=>{
            this.isSpinnerLoading=false;

        })
    }



    formatNewOrderTracker(obj) {
        let tempdisableChecking = this.tableOrderTrackers[this.indexOfOrderTracker].disableChecking;
        let tempdisableFinalApp = this.tableOrderTrackers[this.indexOfOrderTracker].disableFinalApp;
        let tempdisableOPRep = this.tableOrderTrackers[this.indexOfOrderTracker].disableOPRep;
        let tempdisableProcessing = this.tableOrderTrackers[this.indexOfOrderTracker].disableProcessing;
        obj.Checking_OP_Rep_QC_Rep__c = this.checkingOPRepMap.get(obj.Checking_OP_Rep_QC_Rep__c);
        obj.Processing_OP_Rep__c = this.processingOPRepMap.get(obj.Processing_OP_Rep__c);
        obj.OP_Rep_Following_Up__c = this.OPRepFollowingUpMap.get(obj.OP_Rep_Following_Up__c);
        obj.Final_Approver__c = this.finalApproverMap.get(obj.Final_Approver__c);
        obj.Received_Date__c = (obj.Received_Date__c ? this.dateFormat(obj.Received_Date__c, 'dateTime') : ' ');
        if (obj.TAT_QC_Check__c != '0.0') {
            obj.TAT_QC_Check__c = this.tatFormat(obj.TAT_QC_Check__c);
        } else if (obj.TAT_QC_Check__c == '0.0') {
            obj.TAT_QC_Check__c = '';
        }

        if (obj.TAT_Order_Approval__c != '0.0') {
            obj.TAT_Order_Approval__c = this.tatFormat(obj.TAT_Order_Approval__c);
        } else if (obj.TAT_Order_Approval__c == '0.0') {
            obj.TAT_Order_Approval__c = '';
        }

        if (obj.TAT_Billing__c != '0.0') {
            obj.TAT_Billing__c = this.tatFormat(obj.TAT_Billing__c);
        } else if (obj.TAT_Billing__c == '0.0') {
            obj.TAT_Billing__c = '';
        }

        if (obj.ACV__c)
            obj.ACV__c = this.currencyFormat(obj.ACV__c);
        if (obj.PO_Amount__c)
            obj.PO_Amount__c = this.currencyFormat(obj.PO_Amount__c);
        if (obj.X1st_Billing_Amount_USD__c)
            obj.X1st_Billing_Amount_USD__c = this.currencyFormat(obj.X1st_Billing_Amount_USD__c);
        obj.disableChecking = tempdisableChecking;
        obj.disableFinalApp = tempdisableFinalApp;
        obj.disableOPRep = tempdisableOPRep;
        obj.disableProcessing = tempdisableProcessing;
        console.log('----formatNewOrderTracker--',obj);
        return obj;
    }

    saveChangedAssignedUser() {
        if (this.picklistName == 'Checking OP Rep/QC Rep') {
            this.tableOrderTrackers[this.indexOfOrderTracker].Checking_OP_Rep_QC_Rep__c = this.picklistValue;
            this.updateOrderTracker();
        } else if (this.picklistName == 'Final Approver') {
            this.tableOrderTrackers[this.indexOfOrderTracker].Final_Approver__c = this.picklistValue;
            this.updateOrderTracker();
        } else if (this.picklistName == 'OP Rep Following Up') {
            this.tableOrderTrackers[this.indexOfOrderTracker].OP_Rep_Following_Up__c = this.picklistValue;
            this.updateOrderTracker();
        } else if (this.picklistName == 'Processing OP Rep') {
            this.tableOrderTrackers[this.indexOfOrderTracker].Processing_OP_Rep__c = this.picklistValue;
            this.updateOrderTracker();
        }
        this.openAssignedUserModal = false;
    }

    closeAssignedUserModal() {
        this.isSpinnerLoading = true;
        this.getOrderTrackers();
        this.openAssignedUserModal = false;
    }

    //function to update order tracker on change of picklist values
    updateOrderTracker() {
        this.isSpinnerLoading = true;
        updateOrderTracker({
            orderTrackerId: this.orderTrackerId,
            changedPicklistValue: this.picklistValue,
            selectedPickListValue: this.picklistName
        }).then(result => {

            let arr = [];
            let attachmentList = [];
            arr = this.formatNewOrderTracker(result['updatedorderTracker']);
            if (result['attachments'] != undefined) {
                attachmentList = result['attachments'];
            }
            var attachmentArr = [];
            if (arr.BOT_Auto_QC_Done__c == 'Yes' && attachmentList.length != 0) {
                for (let attachment of attachmentList) {
                    if (arr.Id === attachment.orderTrackerId) {
                        var attachmentObj = {};
                        attachmentObj.fileId = attachment.fileId;
                        attachmentObj.fileTitle = attachment.fileTitle;
                        // arr..fileId = attachment.fileId;
                        // arr..fileTitle = attachment.fileTitle;
                        attachmentArr.push(attachmentObj);
                        if(attachmentArr.length===2){
                            break;
                        }
                    }

                }    
                arr.fileAttachment = attachmentArr;
            }


            console.log('--before--update--poFileMAP---',this.poFileMAP);
            for(let orderID in this.poFileMAP){
                if(orderID == this.orderTrackerId ){
                    let poattachmentArr = [];
                    for (let attachment of this.poFileMAP[orderID]) {    
                        var attachmentObj = {};
                        attachmentObj.fileId = attachment.fileId;
                        attachmentObj.fileTitle = attachment.fileTitle;
                        poattachmentArr.push(attachmentObj);
                    }
                    arr.pofileAttachment = poattachmentArr;
                }
            }

            console.log('--before--update--mailChainMAP---',this.mailChainMAP);

            for(let orderID in this.mailChainMAP){
                if(orderID == this.orderTrackerId ){
                    arr.mailChainId = this.mailChainMAP[orderID];
                }
            }


            console.log('--before--update---',this.tableOrderTrackers[this.indexOfOrderTracker]);
            this.tableOrderTrackers[this.indexOfOrderTracker]=arr;
            console.log('--after--update---',this.tableOrderTrackers[this.indexOfOrderTracker]);
            this.template.querySelector('c-custom-toast-component').showToast('success', 'Record succesfully updated.');

            this.handleSpinnerLoadingOff();
        }).catch(error=>{
          
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Record update failed');
            this.handleSpinnerLoadingOff();
        })
    }

    //handle remarks change
    openEditRemarksModal(event) {
        this.editRemarksValue = '';
        this.indexOfOrderTracker = event.currentTarget.dataset.id;
        this.oldRemarksValue = this.tableOrderTrackers[this.indexOfOrderTracker].Remarks__c;
        this.orderTrackerId = this.tableOrderTrackers[this.indexOfOrderTracker].Id;
        if (this.oldRemarksValue != undefined)
            this.editRemarksValue = this.oldRemarksValue;
        else {
            this.oldRemarksValue = '';
        }
        this.openRemarksEditor = true;
    }
    editRemarks(event) {
        this.editRemarksValue = event.target.value;
    }
    saveChangedRemarks() {

        if (this.editRemarksValue.length > 255) {
            this.template.querySelector('c-custom-toast-component').showToast('warning', 'Character Limit reached(255),Please remove some characters');
        } else if (this.oldRemarksValue != this.editRemarksValue) {
            this.isSpinnerLoading = true;

            this.tableOrderTrackers[this.indexOfOrderTracker].Remarks__c = this.editRemarksValue;
            editRemarksofOrderTracker({
                orderTrackerId:this.orderTrackerId,
                newRemarksValue:this.editRemarksValue
            }).then(result=>{
                let arr=this.formatNewOrderTracker(result);
                this.tableOrderTrackers[this.indexOfOrderTracker]=arr;             
                this.template.querySelector('c-custom-toast-component').showToast('success', 'Record succesfully updated');                
                this.handleSpinnerLoadingOff();
               
            }).catch(error=>{
           
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Record update failed');
                this.handleSpinnerLoadingOff();
            });
            this.orderTrackerId = '',
                this.editRemarksValue = '';

            this.openRemarksEditor = false;
        } else {
            this.openRemarksEditor = false;
        }

    }
    closeRemarksModal() {
        this.orderTrackerId='',
        this.editRemarksValue='';
        this.openRemarksEditor = false;
    }

    //handle partner/end user change
    openEditPartnerEndUserModal(event) {
        this.editPartnerEndUserValue = '';
        this.indexOfOrderTracker = event.currentTarget.dataset.id;
        this.fieldName = event.target.name;
        if (this.fieldName == 'Partner') {
            this.oldPartnerEndUserValue = this.tableOrderTrackers[this.indexOfOrderTracker].Partner__c;
            this.editPartnerEndUserValue = this.oldPartnerEndUserValue;
        } else if (this.fieldName == 'End User') {
            this.oldPartnerEndUserValue = this.tableOrderTrackers[this.indexOfOrderTracker].End_User__c;
            this.editPartnerEndUserValue = this.oldPartnerEndUserValue;
        } else if (this.fieldName == 'Proposal for initiating QC') {
            this.oldPartnerEndUserValue = this.tableOrderTrackers[this.indexOfOrderTracker].Proposal_for_initiating_QC__c;
            this.editPartnerEndUserValue = this.oldPartnerEndUserValue;
        } else if (this.fieldName == 'SO') {
            this.oldPartnerEndUserValue = this.tableOrderTrackers[this.indexOfOrderTracker].SO__c;
            this.editPartnerEndUserValue = this.oldPartnerEndUserValue;
        }
        this.orderTrackerId = this.tableOrderTrackers[this.indexOfOrderTracker].Id;
        this.openPartnerandEndUserEditor = true;
    }

    onrowSelectHandler(event){
        let indexOfOrderTracker = event.currentTarget.dataset.id;
        if(event.target.checked){
            this.selectedRecords.push(this.tableOrderTrackers[indexOfOrderTracker]);
        }
        else{
            if(this.selectedRecords){
                this.selectedRecords = this.selectedRecords.filter((data) =>{
                    return data.Id != this.tableOrderTrackers[indexOfOrderTracker].Id
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

    saveChangedMerge(event){
        this.isSpinnerLoading =true;
        this.openMergeModal = false;
        console.log(JSON.stringify(this.selectedRecords));
        if(this.selectedRecords){
           mergeRecords({mergeRecord : JSON.stringify(this.selectedRecords)}).then((result)=>{
                if(result == 'success'){
                    this.getOrderTrackers();
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

    editPartnerEndUser(event) {
        this.editPartnerEndUserValue = event.target.value;
    }
    makeOrderPrimary(event){
        event.target.checked
        let indexOfOrderTracker = event.currentTarget.dataset.id;
        let orderTrackerRecordId = this.selectedRecords[indexOfOrderTracker].Id;
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

    saveChangedPartnerEndUser() {
        this.isSpinnerLoading = true;
        if (this.fieldName == 'Partner' && this.oldPartnerEndUserValue != this.editPartnerEndUserValue && this.editPartnerEndUserValue != '') {
            this.tableOrderTrackers[this.indexOfOrderTracker].Partner__c = this.editPartnerEndUserValue;
            this.editPartnerEndUserofOrderTracker();
        } else if (this.fieldName == 'End User' && this.oldPartnerEndUserValue != this.editPartnerEndUserValue && this.editPartnerEndUserValue != '') {
            this.tableOrderTrackers[this.indexOfOrderTracker].End_User__c = this.editPartnerEndUserValue;
            this.editPartnerEndUserofOrderTracker();
        } else if (this.fieldName == 'Proposal for initiating QC' && this.oldPartnerEndUserValue != this.editPartnerEndUserValue && this.editPartnerEndUserValue != '') {
            this.tableOrderTrackers[this.indexOfOrderTracker].Proposal_for_initiating_QC__c = this.editPartnerEndUserValue;
            this.editPartnerEndUserofOrderTracker();
        } else if (this.fieldName == 'SO' && this.oldPartnerEndUserValue != this.editPartnerEndUserValue && this.editPartnerEndUserValue != '') {
            this.tableOrderTrackers[this.indexOfOrderTracker].SO__c = this.editPartnerEndUserValue;
            this.editPartnerEndUserofOrderTracker();
        } else if (this.oldPartnerEndUserValue != '' && this.editPartnerEndUserValue == '') {
            this.editPartnerEndUserofOrderTracker();
        } else if (this.oldPartnerEndUserValue == this.editPartnerEndUserValue) {

            this.openPartnerandEndUserEditor = false;
            this.handleSpinnerLoadingOff();
        }
    }
    editPartnerEndUserofOrderTracker() {
        editPartnerEndUserofOrderTracker({
            orderTrackerId: this.orderTrackerId,
            newPartnerEndUserValue: this.editPartnerEndUserValue,
            fieldName: this.fieldName
        }).then(result => {
            //  console.log('result at 1028',result);
            let arr = this.formatNewOrderTracker(result);
            this.tableOrderTrackers[this.indexOfOrderTracker] = arr;
            this.template.querySelector('c-custom-toast-component').showToast('success', 'Record succesfully updated');
            this.orderTrackerId = '',
                this.editPartnerEndUserValue = '',
                this.handleSpinnerLoadingOff();

            }).catch(error=>{
          
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Record update failed');
                this.handleSpinnerLoadingOff();
            });
            
        this.openPartnerandEndUserEditor=false;
          
       
    }
    closePartnerEndUserModal() {
        this.orderTrackerId = '';
        this.editPartnerEndUserValue = '';
        this.openPartnerandEndUserEditor = false;
    }


    //handle currency change
    openCurrencyModal(event) {
        this.editCurrencyValue = '';
        this.indexOfOrderTracker = event.currentTarget.dataset.id;
        this.fieldName = event.target.name;
        let currencyValue = 0;
        if (this.fieldName == 'ACV' && this.tableOrderTrackers[this.indexOfOrderTracker].ACV__c != undefined) {

            currencyValue = this.tableOrderTrackers[this.indexOfOrderTracker].ACV__c;
        } else if (this.fieldName == 'PO Amount' && this.tableOrderTrackers[this.indexOfOrderTracker].PO_Amount__c != undefined) {

            currencyValue = this.tableOrderTrackers[this.indexOfOrderTracker].PO_Amount__c;
        } else if (this.fieldName == '1st Billing Amount' && this.tableOrderTrackers[this.indexOfOrderTracker].X1st_Billing_Amount_USD__c != undefined) {

            currencyValue = this.tableOrderTrackers[this.indexOfOrderTracker].X1st_Billing_Amount_USD__c;
        }
      
        this.oldCurrencyValue=parseFloat(currencyValue);      
        this.editCurrencyValue=this.oldCurrencyValue;
        this.orderTrackerId=this.tableOrderTrackers[this.indexOfOrderTracker].Id;        
        this.openCurrencyModalEditor = true;
    }
    editCurrency(event) {
        this.editCurrencyValue = event.target.value;
        if (event.target.value == '') {
            this.editCurrencyValue = 0;
        }
    }
    saveChangedCurrency() {

        if (this.fieldName == 'ACV' && this.oldCurrencyValue != this.editCurrencyValue) {
            this.isSpinnerLoading = true;
            this.editCurrencyNumberofOrderTracker();
            this.tableOrderTrackers[this.indexOfOrderTracker].ACV__c = this.editCurrencyValue;
        } else if (this.fieldName == 'PO Amount' && this.oldCurrencyValue != this.editCurrencyValue) {
            this.isSpinnerLoading = true;
            this.editCurrencyNumberofOrderTracker();
            this.tableOrderTrackers[this.indexOfOrderTracker].PO_Amount__c = this.editCurrencyValue;
        } else if (this.fieldName == '1st Billing Amount' && this.oldCurrencyValue != this.editCurrencyValue) {
            this.isSpinnerLoading = true;
            this.editCurrencyNumberofOrderTracker();
            this.tableOrderTrackers[this.indexOfOrderTracker].X1st_Billing_Amount_USD__c = this.editCurrencyValue;
        } else if (this.editCurrencyValue == '' && this.oldCurrencyValue != '') {
            this.isSpinnerLoading = true;
            this.editCurrencyValue = 0;
            this.editCurrencyNumberofOrderTracker();
        } else if (this.editCurrencyValue == this.oldCurrencyValue) {
            this.openCurrencyModalEditor = false;
        }
    }

    editCurrencyNumberofOrderTracker() {
        editCurrencyNumberofOrderTracker({
            orderTrackerId: this.orderTrackerId,
            newCurrencyValue: this.editCurrencyValue,
            fieldName: this.fieldName
        }).then(result => {
            let arr = this.formatNewOrderTracker(result);
            this.tableOrderTrackers[this.indexOfOrderTracker] = arr;
            this.template.querySelector('c-custom-toast-component').showToast('success', 'Record succesfully updated');
            this.editCurrencyValue = '';
            this.orderTrackerId = '';
            this.handleSpinnerLoadingOff();

        }).catch(error => {
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Record update failed');
            this.handleSpinnerLoadingOff();
        });

        this.openCurrencyModalEditor = false;

    }
    closeCurrencyModal() {
        this.openCurrencyModalEditor = false;
    }

    //change currency format
    currencyFormat(num) {
        return (Math.round((num + Number.EPSILON) * 100) / 100);
    }

    tatFormat(hrsMinute) {
        let totalHours = hrsMinute.split('.');
        let convertedValue = '';
        let hours = totalHours[0];
        let mins = totalHours[1];
        if (hours <= 9 && hours >= 0 && hours != undefined) {
            convertedValue = "0" + hours;
        } else {
            convertedValue = hours;
        }
        if (mins <= 9 && mins >= 0 && mins != undefined) {
            convertedValue = convertedValue + ":" + "0" + mins;
        } else {
            convertedValue = convertedValue + ":" + mins;
        }
        return convertedValue;
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


    handleRedirectToRecord(recID, obejctAPiName) {
        // Make sure the event is only handled here
        //event.stopPropagation();

        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recID,
                objectApiName: obejctAPiName,
                actionName: 'view'
            }
        });*/
      
        // Navigate to the Contact object's Recent list view.
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recID,
                objectApiName: obejctAPiName,
                actionName: 'view'
            }
        }).then(url => { window.open(url) });
    }


    //handle spinner timeout
    handleSpinnerLoadingOff() {
        this.isSpinnerLoading = false;
    }


    sortBy (field, reverse, primer){
        console.log('Sort by:reverse:' + reverse);
        var key = function (x) {return primer ? primer(x[field]) : x[field]};
        return function (a,b) {
            var A = key(a), B = key(b);
            if (A === undefined) A = '';
            if (B === undefined) B = '';
            return (A < B ? -1 : (A > B ? 1 : 0)) * [1,-1][+!!reverse];                  
        }
    }
}