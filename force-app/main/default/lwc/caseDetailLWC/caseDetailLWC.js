import { LightningElement, track, wire, api } from 'lwc';
import retriveCase  from '@salesforce/apex/CaseDetailLWCController.fetchCase';
import COMMENTBODY_FIELD from '@salesforce/schema/CaseComment.CommentBody';
import PARENTID_FIELD from '@salesforce/schema/CaseComment.ParentId';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import ID_FIELD from '@salesforce/schema/Contact.Id';
import { registerListener, unregisterAllListeners} from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import { publish,subscribe,unsubscribe,createMessageContext,releaseMessageContext } from 'lightning/messageService';
import priorityMessageService from "@salesforce/messageChannel/priorityMessage__c";

const columns = [
    {label: 'Title', fieldName: 'Title'}
];

export default class CaseDetailLWC extends LightningElement {
    subscription;
    @track caseId;
    @track caseData;
    @track emailList;
    @track contactId;
    @track error;
    @track commentBody = COMMENTBODY_FIELD;
    @track parId = PARENTID_FIELD;
    rec = {
        CommentBody : this.commentBody,
        ParentId : this.parId
    }
    //file upload
    @api recordId;
    @track columns = columns;
    @track data;
    @track fileName = '';
    @track UploadFile = 'Upload File';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    @track firstName;
    @track lastName;
    @track email;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    emailRefreshData;
    MAX_FILE_SIZE = 1500000;
    @track openmodel = false;
    @track addMode = false;
    @track editMode = false;

    @track isDeception = false;

    @track ctRecord = {
        FirstName : FIRSTNAME_FIELD,
        LastName : LASTNAME_FIELD ,
        Email : EMAIL_FIELD,
        Id : ID_FIELD
    };

    
    caseNumber;
    caseOwnerName;
    createdDate;
    lastModifiedDate;
    @track priority;
    caseType;
    product;
    isContactPresent;
    contactName;
    category;
    subCategory;
    preferredContact;
    preferredTimezone;
    testCount = 0;


    @wire(retriveCase, {strObjectName : '$caseId'})
    cases({data, error}) {
        if(data) {
            this.caseData = data[0];
            console.log('This is case details-->'+JSON.stringify(this.caseData));
            this.error = undefined;
            this.caseNumber = this.caseData.CaseNumber;
            this.caseOwnerName =this.caseData.Owner.Name;
            this.createdDate = this.caseData.CreatedDate;
            this.lastModifiedDate = this.caseData.LastModifiedDate;
            this.priority = this.caseData.Priority;
            if(this.caseData.Product_New__c == 'Zscaler Deception'){
                this.priority = this.caseData.Priority_Deception__c;
            }
            this.caseType = this.caseData.Case_Type__c;
            this.product =  this.caseData.Product_New__c;
            this.isContactPresent = this.caseData.ContactId;
            if(this.isContactPresent){
                this.contactName = this.caseData.Contact.Name;
            }
            this.category = this.caseData.Case_Category__c;
            this.subCategory = this.caseData.Case_Sub_Category__c;
            this.preferredContact = this.caseData.Preferred_Contact_Number__c;
            this.preferredTimezone = this.caseData.Preferred_Contact_Time_Zone__c
            
        }
        else if(error) {
            this.caseData = undefined;
            this.error = error;
        }
    }
    /*
    openmodal() {
        this.ctRecord = {};
        this.addMode = true;
        this.editMode = false;
        this.openmodel = true;
    }
    closeModal() {
        this.addMode = false;
        this.editMode = false;
        this.openmodel = false
    }

    handleCloseCase(){
        updateCaseDetails({ caseDetailId: this.caseId})
        .then(result => {
            this.caseData = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Case Closed Successfully!!!',
                    variant: 'success',
                }),
            );
            window.location.reload();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while Closing Case',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }
    showEscCmp(){
        this.template.querySelector('c-customer-escalation-l-w-c').showModal();
    }
    */
    connectedCallback() {
        this.subscribeMC();
        var str = window.location.href;
        var extracted = str.split("/").find(function(v){
        return v.indexOf("500") > -1;
        });
        this.caseId = extracted;
    }
    parId = this.caseId;

    context = createMessageContext();
    subscribeMC() {
        this.subscription = subscribe(this.context, priorityMessageService, (message) => {
            this.displayMessage(message);
        });
     }

     displayMessage(message){
       this.priority = message.currentPriority;
     }
}