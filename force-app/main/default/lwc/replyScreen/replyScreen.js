import { LightningElement, api, track, wire } from 'lwc';
import sendMailMethod from '@salesforce/apex/OrderTrackerDashboard.sendMailMethod'
//import sendMailMethodAttachment from '@salesforce/apex/OrderTrackerDashboard.sendMailMethodWithAttachment'

import updateOrderTrackerStatusFromReply from '@salesforce/apex/OrderTrackerDashboard.updateOrderTrackerStatusFromReply'
import getEmailTemplate from '@salesforce/apex/OrderTrackerDashboard.getEmailTemplate'
import updateEmailTracker from '@salesforce/apex/getEmailTrackerData.updateEmailTracker'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ORDER_TRACKER_OBJECT from '@salesforce/schema/Order_Tracker__c';
import ORDER_TRACKER_STATUS_FIELD from '@salesforce/schema/Order_Tracker__c.Status__c';
import EMAIL_TRACKER_OBJECT from '@salesforce/schema/Email_Tracker__c';
import EMAIL_TRACKER_STATUS_FIELD from '@salesforce/schema/Email_Tracker__c.Status__c';
import getTasks from '@salesforce/apex/getTaskTrackerData.getTasks'
import updateTasksFromReply from '@salesforce/apex/getTaskTrackerData.updateTasksFromReply'


export default class ReplyScreen extends LightningElement {

    @api mailChainObject = {};
    @api isShowParentMailChainComponent;
    //@api orderTrackerstatus;
    @api parentTrackerObject;
    @api trackerType;
    @api isReplyButton;
    @track ccEmailAddress =[];
    @track bccEmailAddress = [];
    @api allowWithAttachment = false;


    @track isSpinnerLoading = true;
    @track toEmails = '';//To Emails
    @track ccEmails = '';//CC emails
    @track bccEmails = '';//BCC Emails
    @track subject = ' ';//Email Subject
    @track inputBody = '';//Email Body
    @track previousMailChain;
    @track replyMap = [];//Map to send values to apex
    @track parentTrackerId;
    @track orderTrackerStatusPicklist;
    @track emailTrackerStatusPicklist;
    @track selectedStatusValue = '';
    @track savedfiles = [];//to show files on main page  
    @track openUploadFileModal = false;//boolean check to open/close Upload File modal/pop-up
    @track modalFilesUploaded = [];//input files in modal/pop-up

    @track isEmailTracker = false;
    @track isOrderTracker = false;
    @track isOrderTrackerDashboard = false;

    @track toError = '';//Errors in To email Section
    @track ccErrors = '';//Errors in CC email section
    @track bccErrors = '';//Errors in BCC email section
    @track toEmailAddress =[];



    @track borderStyle;
    //Regular Expression(Regex) for Email    
    emailregex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

    @wire(getObjectInfo, { objectApiName: ORDER_TRACKER_OBJECT })
    orderMetadata;

    @wire(getPicklistValues,
        {
            recordTypeId: '$orderMetadata.data.defaultRecordTypeId',
            fieldApiName: ORDER_TRACKER_STATUS_FIELD
        }
    )
    wiredOrderstatusPickList({ data }) {
        if (data) {

            this.orderTrackerStatusPicklist = data.values;

        }
    }

    @wire(getObjectInfo, { objectApiName: EMAIL_TRACKER_OBJECT })
    emailMetadata;

    @wire(getPicklistValues,
        {
            recordTypeId: '$emailMetadata.data.defaultRecordTypeId',
            fieldApiName: EMAIL_TRACKER_STATUS_FIELD
        }
    )
    wiredEmailstatusPickList({ data }) {
        if (data) {

            this.emailTrackerStatusPicklist = data.values;

        }
    }

    joinToCc(emails,finalCcEmail)
    {
                emails=emails.split(';');
                for(var i=0;i<emails.length;i++)
                {
                if(this.validateEmail(emails[i]))
                finalCcEmail.push(emails[i])
                }
                return finalCcEmail;   

    }
     validateEmail(email) {
        const re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(String(email).toLowerCase());
    }

    connectedCallback() {
       // console.log('this.parentTrackerObject', this.parentTrackerObject.Thread_ID__c);
       
        if (this.trackerType == 'emailTracker') {
            this.parentTrackerId = this.parentTrackerObject.Id;
            this.isEmailTracker = true;
            this.isOrderTracker = false;
            this.isOrderTrackerDashboard = false;
            this.borderStyle = "border:none";
        }
        else if (this.trackerType == 'orderTracker') {
            this.parentTrackerId = this.parentTrackerObject.Id;
            this.isEmailTracker = false;
            this.isOrderTracker = true;
            this.isOrderTrackerDashboard = false;
            this.borderStyle = "border:none";
        }
        else if (this.trackerType == 'Order Tracker Dashboard') {
            this.isEmailTracker = false;
            this.isOrderTracker = false;
            this.isOrderTrackerDashboard = true;
            this.borderStyle = "border:solid 2px";
        }

      
        if (this.mailChainObject.From__c)
         {   this.toEmails = this.mailChainObject.From__c;
             this.toEmailAddress.push(this.mailChainObject.From__c);
         }

            let finalCcEmail =[];
        if (this.mailChainObject.CC__c){
            console.log('CC EMails');
            console.log(this.mailChainObject.CC__c);
            let ccAdd = this.mailChainObject.CC__c.split(';');
            this.ccEmailAddress = ccAdd ;
            console.log(this.ccEmailAddress);
          //  console.log('this.mailChainObject.CC__c', this.mailChainObject.CC__c)
            finalCcEmail=this.joinToCc(this.mailChainObject.CC__c,finalCcEmail);
         //   console.log('finalCcEmail cc', finalCcEmail)
        }
        if(this.mailChainObject.To__c){
          //  console.log('this.mailChainObject.To__c', this.mailChainObject.To__c)
          let toAd = [];    
          toAd = this.mailChainObject.To__c.split(';');
          this.ccEmailAddress.concat(toAd);
          for(let i=0; i<toAd.length; i++){
            this.ccEmailAddress.push(toAd[i]);
          }
          this.ccEmailAddress = [...this.ccEmailAddress].filter(element =>{
            return element!= '';
          })
          //this.ccEmailAddress.push(this.mailChainObject.To__c);
        finalCcEmail=this.joinToCc(this.mailChainObject.To__c,finalCcEmail);
      //  console.log('finalCcEmail To__c', finalCcEmail)
        }
        if(finalCcEmail)
        {
            this.ccEmails=Array.from(finalCcEmail).join(';');
           // console.log('this.ccEmails ', this.ccEmails)
        }
        
        if (this.mailChainObject.BCC__c)
            this.bccEmails = this.mailChainObject.BCC__c;

            this.bccEmailAddress.push(this.mailChainObject.BCC__c);
        if (this.mailChainObject.Email_Subject__c)
            this.subject = this.mailChainObject.Email_Subject__c;
        if (this.mailChainObject.original_body__c) {
            // if (this.mailChainObject.original_body__c.includes('\n')) {
            //     this.previousMailChain = this.mailChainObject.original_body__c.split('\n').join('<br>');
            // }
            //else if (!this.mailChainObject.original_body__c.includes('\n')) {
                this.previousMailChain = this.mailChainObject.original_body__c;
           // }

        }


        this.selectedStatusValue = this.parentTrackerObject.Status__c;
        this.getEmailTemplate();
        let varMChainAttachment = this.mailChainObject.fileAttachment;
       // console.log('---varMChainAttachment--', JSON.stringify(varMChainAttachment));
        if (varMChainAttachment) {
            let attachmentArr = [];
            for (let attachment of varMChainAttachment) {
                var attachmentObj = {};
                attachmentObj.fileId = attachment.fileId;
                attachmentObj.PathOnClient = attachment.fileTitle;
                attachmentObj.Title = attachment.fileTitle;
                attachmentArr.push(attachmentObj);
            }
            this.savedfiles = attachmentArr;
        }
    }
    //handle input file in modal/pop-up
    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            for (var i = 0; i < event.target.files.length; i++) {
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    let base64 = 'base64,';
                    let content = reader.result.indexOf(base64) + base64.length;
                    let fileContents = reader.result.substring(content);
                    this.modalFilesUploaded.push({ PathOnClient: file.name, Title: file.name, VersionData: fileContents });
                };
                reader.readAsDataURL(file);
            }
        }
    }

    //function to open modal/pop-up
    handleModalPopUp() {
        this.openUploadFileModal = true;
    }
    //function to close modal
    closeModal() {
        this.openUploadFileModal = false;
        this.modalFilesUploaded = [];
    }
    //function to save the attachments
    submitDetails() {
        for (var i = 0; i < this.modalFilesUploaded.length; i++) {
            this.savedfiles.push(this.modalFilesUploaded[i]);
        }
    //    console.log('this.savedfiles',this.savedfiles);
        this.openUploadFileModal = false;
        this.modalFilesUploaded = [];
    }

    //set the value of To email in "toEmails" variable
    setToEmails(event) {
/*        this.toEmails = event.target.value;
        
        // email validation for To emails

        this.toError = '';
        let toArray = this.toEmails.split(';'); */
        console.log('To array Validation');
        let toArray = this.toEmailAddress;
        for (var i = 0; i < toArray.length; i++) {
            if (!this.emailregex.test(toArray[i]) && i != toArray.length - 1) {
                this.toError = this.toError + toArray[i] + ',';
            }
            if (!this.emailregex.test(toArray[i]) && i == toArray.length - 1) {
                this.toError = this.toError + toArray[i];
            }
        }
    }

    //set the value of CC email in "ccEmails" variable
    setCCEmails(event) {
        this.ccEmails = event.target.value;
        //email validation for CC Emails
        let ccArray = this.ccEmails.split(';');
        this.ccErrors = '';
        for (var i = 0; i < ccArray.length; i++) {
            if (!this.emailregex.test(ccArray[i]) && i != ccArray.length - 1) {
                this.ccErrors = this.ccErrors + ccArray[i] + ',';
            }
            if (!this.emailregex.test(ccArray[i]) && i == ccArray.length - 1) {
                this.ccErrors = this.ccErrors + ccArray[i];
            }
        }
    }

    //set the value of BCC email in "bccEmails" variable
    setBccEmails(event) {
        this.bccEmails = event.target.value;
        //email validation for BCC Emails
        let bccArray = this.bccEmails.split(';');
        this.bccErrors = '';
        for (var i = 0; i < bccArray.length; i++) {
            if (!this.emailregex.test(bccArray[i]) && i != bccArray.length - 1) {
                this.bccErrors = this.bccErrors + bccArray[i] + ',';
            }
            if (!this.emailregex.test(bccArray[i]) && i == bccArray.length - 1) {
                this.bccErrors = this.bccErrors + bccArray[i];
            }
        }
    }
    //Set vale of email subject in "subject" variable
    setSubject(event) {
        this.subject = event.target.value;
    }
    //set value of email body in "inputBody" variable
    setBody(event) {
        this.inputBody = event.target.value;


    }
    //handle removing of files from modal/pop-up
    handleRemove(event) {
        this.modalFilesUploaded.splice(event.currentTarget.dataset.id, 1);
      //  console.log('this.modalFilesUploaded',this.modalFilesUploaded);
    }
    //handle removing of files from main page 
    handleRemovesavedFiles(event) {

        this.savedfiles.splice(event.target.name, 1);
     //   console.log('after remove this.savedfiles',this.savedfiles);
    }

    //function on click of reply button which sets the variables and call apex function
    replyAll() {
        this.toEmails = this.toEmailAddress.join(';');
        this.ccEmails = this.ccEmailAddress.join(';');
        this.bccEmails = this.bccEmailAddress.join(';');
        
        //check the required fields if empty or not
        if (this.toEmails == '' || this.subject == '') {
            this.template.querySelector('c-custom-toast-component').showToast('warning', 'Please enter required fields');
        }
        else if (this.toEmails.includes(',')) {
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Invalid Email Seperator in TO Section , Please use semi-colon ; to seperate multiple emails');

        }
        else if (this.ccEmails.includes(',')) {
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Invalid Email Seperator in CC Section , Please use semi-colon ; to seperate multiple emails');
        }
        else if (this.bccEmails.includes(',')) {
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Invalid Email Seperator in BCC Section , Please use semi-colon ; to seperate multiple emails');

        }

        else if (this.toError != '' || this.ccErrors != '' || this.bccErrors != '') {
            this.template.querySelector('c-custom-toast-component').showToast('warning', 'Please handle all errors');
        }

        //finally set the parameters of apex function
        else {
            this.isSpinnerLoading = true;
            if (this.selectedStatusValue == 'PO Pending for Booking') {
                updateTasksFromReply({
                    orderTrackerId: this.mailChainObject.Order_Tracker__c
                }).then(result => {
                    let tasks = result;

                    this.sendMailMethod();
                })
            }
            else {
                this.sendMailMethod();
            }

        }
    }


    sendMailMethod() {
        //console.log('Body Check 2', this.inputBody);
        let finalmailbody = '';
        if (this.inputBody == '') {
            if (this.parentTrackerObject.SO__c != undefined && this.selectedStatusValue == 'PO Pending for Booking')
                finalmailbody = '<br/><br/>===Previous Mail Chain===<br/><br/>' + this.previousMailChain + '<br/>This is Approved for Billing Schedule [{' + this.parentTrackerObject.SO__c + '}]';
            else
                finalmailbody = '<br/><br/>===Previous Mail Chain===<br/><br/>' + this.previousMailChain;

            finalmailbody  = '<span data-source-id="#Zscaler-Reply#" style="display:none">-Zscaler-Reply-</span>' + finalmailbody;
        }
        else {
            this.inputBody=this.inputBody.replaceAll("<p>", '<p style="margin:0">')
            if (this.parentTrackerObject.SO__c != undefined && this.selectedStatusValue == 'PO Pending for Booking')
                finalmailbody = this.inputBody + '<br/><br/>===Previous Mail Chain===<br/><br/>' + this.previousMailChain + '<br/>This is Approved for Billing Schedule [{' + this.parentTrackerObject.SO__c + '}]';
            else
                finalmailbody = this.inputBody + '<br/><br/>===Previous Mail Chain===<br/><br/>' + this.previousMailChain;

            finalmailbody  = '<span data-source-id="#Zscaler-Reply#" style="display:none">-Zscaler-Reply-</span>' + finalmailbody;
        }
        if(finalmailbody.length>130000)
        {
            let pbody=finalmailbody.length-this.inputBody.length;
            let maxlimit=130000-pbody;
            let excedBody=this.inputBody.length-maxlimit;

            let x=(130000-(finalmailbody.length-this.inputBody.length))-this.inputBody;
            this.template.querySelector('c-custom-toast-component').showToast('warning', 'max character limit reached for email body please remove some character');
            this.handleSpinnerLoadingOff();
            return;
        }
        //console.log('replace para', this.inputBody);
       // console.log('finalmailbody before send', finalmailbody);
      //  console.log('Threadid' , this.parentTrackerObject.Thread_ID__c);
        this.replyMap = {
            To: this.toEmails,
            CC: this.ccEmails,
            BCC: this.bccEmails,
            Subject: this.subject,
            ThreadId:this.parentTrackerObject.Thread_ID__c,
            Body: finalmailbody
        }

        if (this.isEmailTracker == false && this.selectedStatusValue != this.parentTrackerObject.Status__c) {

            updateOrderTrackerStatusFromReply({
                parentOrderTrackerId: this.mailChainObject.Order_Tracker__c,
                changedStatusValue: this.selectedStatusValue
            })
        }
        else if (this.isEmailTracker == true && this.selectedStatusValue != this.parentTrackerObject.Status__c) {
            updateEmailTracker({
                emailTrackerId: this.mailChainObject.Email_Tracker__c,
                changedPicklistValue: this.selectedStatusValue,
                typeOfPicklist: 'Status'
            })
        }


        if (this.allowWithAttachment) {

            //calling "sendMailMethod" of apex class
            sendMailMethod({
                mp: this.replyMap,
                files: this.savedfiles,
                parentTrackerId: this.parentTrackerId,
                messageId: this.mailChainObject.Message_Id__c,
                isEmailTracker: this.isEmailTracker
            }).then(() => {
                this.handleSpinnerLoadingOff();
                this.isShowParentMailChainComponent = true;
                const selectedEvent = new CustomEvent("showparentcomponent", {
                    detail: {
                        showParent: this.isShowParentMailChainComponent,
                        reply: this.isReplyButton,
                        emailSent: true
                    }

                });
                //clearing every variable in the end
                this.toEmails = '';
                this.ccEmails = '';
                this.bccEmails = '';
                this.subject = '';
                this.inputBody = '';
                this.savedfiles = [];
                this.toError = '';
                this.ccErrors = '';
                this.bccErrors = '';
                this.previousMailChain = '';
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
            }).catch(error => {
                this.handleSpinnerLoadingOff();
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Error Occured while sending email'+error);
            });


        } else {

            //calling "sendMailMethod" of apex class
            console.log('parentTrackerId----',this.parentTrackerId);
            sendMailMethod({
                mp: this.replyMap,
                files: this.savedfiles,
                parentTrackerId: this.parentTrackerId,
                messageId: this.mailChainObject.Message_Id__c,
                isEmailTracker: this.isEmailTracker
            }).then(() => {
                this.handleSpinnerLoadingOff();
                this.isShowParentMailChainComponent = true;
                const selectedEvent = new CustomEvent("showparentcomponent", {
                    detail: {
                        showParent: this.isShowParentMailChainComponent,
                        reply: this.isReplyButton,
                        emailSent: true
                    }

                });
                //clearing every variable in the end
                this.toEmails = '';
                this.ccEmails = '';
                this.bccEmails = '';
                this.subject = '';
                this.inputBody = '';
                this.savedfiles = [];
                this.toError = '';
                this.ccErrors = '';
                this.bccErrors = '';
                this.previousMailChain = '';
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
            }).catch(error => {
                this.handleSpinnerLoadingOff();
              //  console.log('error'+JSON.stringify(error));
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Error Occured while sending email'+JSON.stringify(error));
            });
        }
    }

    handleStatusChange(event) {
        this.isSpinnerLoading = true;
        this.selectedStatusValue = event.target.value;
        this.getEmailTemplate();
    }

    getEmailTemplate() {
        let recordId;
        let objName;
        if (this.isEmailTracker == true) {
            recordId = this.mailChainObject.Email_Tracker__c;
            objName = 'Email_Tracker__c';
        }
        else if (this.isEmailTracker == false) {
            recordId = this.mailChainObject.Order_Tracker__c;
            objName = 'Order_Tracker__c';
        }
        getEmailTemplate({
            picklistValue: this.selectedStatusValue,
            recordId: recordId,
            objectName: objName
        }).then(result => {

            let body = result;
            this.inputBody = body;
            this.handleSpinnerLoadingOff();
        })
        .catch(error => {
            this.handleSpinnerLoadingOff();
        });
    }

    handleSpinnerLoadingOff() {
        this.delayTimeout = setTimeout(() => {
            this.isSpinnerLoading = false;
        }, 10);
    }


    handleParentComponent() {
        this.isShowParentMailChainComponent = true;
        this.isReplyButton = true;
        const selectedEvent = new CustomEvent("showparentcomponent", {
            detail: {
                showParent: this.isShowParentMailChainComponent,
                reply: this.isReplyButton,
                emailSent: false
            }

        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    dateFormat(dateTimeString) {
        var dateTime = new Date(dateTimeString);
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        var month = months[dateTime.getUTCMonth()];
        var date = ((dateTime.getUTCDate() < 10) ? ('0' + dateTime.getUTCDate()) : (dateTime.getUTCDate()));
        var year = dateTime.getUTCFullYear().toString().substr(-2);

        return date + ' ' + month + ' ' + year;
    }


    handleUploadFinished(event) {
        let uploadedFiles=event.detail.files;
        if (uploadedFiles) {
            let attachmentArr = [];
            for (let attachment of uploadedFiles) {
                var attachmentObj = {};
                attachmentObj.fileId = attachment.documentId;
                attachmentObj.PathOnClient = attachment.name;
                attachmentObj.Title = attachment.name;
                attachmentArr.push(attachmentObj);
                //this.modalFilesUploaded.push(attachmentObj);
            }
            this.modalFilesUploaded.push(...attachmentArr);
            //this.modalFilesUploaded.push(attachmentArr);
        }
       // console.log('modalFilesUploaded',this.modalFilesUploaded);
    }  

    handleLookup(event) {
        let selectedObj;
        selectedObj = JSON.parse(JSON.stringify(event.detail));
        if(selectedObj.Name != undefined)
            this.toEmailAddress.push(selectedObj.Name);

        console.log(this.toEmailAddress);
    }

    handleCClookup(event) {
        console.log('n the cc event')
        let selectedObj;
        selectedObj = JSON.parse(JSON.stringify(event.detail));
        if(selectedObj.Name != undefined)
            this.ccEmailAddress.push(selectedObj.Name);

        console.log(this.ccEmailAddress);        
    }

    handlePillRemove(event) {
        if(this.toEmailAddress && this.toEmailAddress.length > 0 ) {
            if(this.toEmailAddress.indexOf(event.currentTarget.dataset.id) > -1) {
                this.toEmailAddress.splice(this.toEmailAddress.indexOf(event.currentTarget.dataset.id),1);
            }
        }
    }

    handleCCPillRemove(event) {
        if(this.ccEmailAddress && this.ccEmailAddress.length > 0 ) {
            if(this.ccEmailAddress.indexOf(event.currentTarget.dataset.id) > -1) {
                this.ccEmailAddress.splice(this.ccEmailAddress.indexOf(event.currentTarget.dataset.id),1);
            }
        }
    }

    handleBCCPillRemove(event) {
        if(this.bccEmailAddress && this.bccEmailAddress.length > 0 ) {
            if(this.bccEmailAddress.indexOf(event.currentTarget.dataset.id) > -1) {
                this.bccEmailAddress.splice(this.bccEmailAddress.indexOf(event.currentTarget.dataset.id),1);
            }
        }
    }

    handleBCClookup(event) {
        console.log('n the cc event')
        let selectedObj;
        selectedObj = JSON.parse(JSON.stringify(event.detail));
        if(selectedObj.Name != undefined)
            this.bccEmailAddress.push(selectedObj.Name);

        console.log(this.bccEmailAddress);   
    }
}