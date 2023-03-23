import { LightningElement, api, wire, track } from "lwc";
import getparams from "@salesforce/apex/RelatedListController.getdefaultParameters";
import callAllInDoc from "@salesforce/apex/ActionPlanLWCController.updateAllInDoc";
import { fireEvent } from "c/pubsub_Internal";
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class Related_List_with_New_Action_Plan extends LightningElement {
    @api objectName;
    @api childRelFieldAPIName;
    @api childRelFieldValue;
    @api parentRelFieldAPIName;
    @api recordId;
    @api strTitle;
    @api filterCriteia;
    @api showActions;
    @api showRowActions;
    @api allowInlineEdit;
    @api fieldSet;
    @api showStandardView;
    @api showStandardEdit;
    @api showStandardDelete;
    @api showNew;
    @track showNewActionPlanModal = false;
    @api newRT;
    @api defparams;
    @api numofrecords;
    @api showAccordion;
    @api showExpanded;
    @api showCustomstyle;
    @api actionFieldSetName;
    @api actionFieldSetNameEdit;
    @track recordTypeId;
    @track showSpinner = false;
    @api showAllInDocs = false;
    @track showAllActionName = "Show All in doc";

    @api showUnselectAllInDocs; //Added by Anup : CR#1477

    @wire(CurrentPageReference) pageRef;

    sendMessage() {
        console.log('inside pubsub');
        fireEvent(this.pageRef, 'dynamicTableContentRefresh', 'Action_Plan__c');
    }

    constructor() {
        super();
        this.template.addEventListener('newactionplan', this.newactionplan.bind(this));
    }

    get additionalRowActions() {
        let rowactions = [];
        rowactions.push({ label: 'New Action Plan', name: 'newactionplan' });
        return rowactions;
    }

    handleCreateCancel(event) {
        console.log('inside cancel');
        this.showNewActionPlanModal = false;
    }

    handleCreateSave(event) {
        console.log('inside handleCreateSave');
        this.showNewActionPlanModal = false;
        this.sendMessage();
    }
    newactionplan(event) {
        console.log(event.detail.Id);
        if (
            this.objectInfo &&
            this.objectInfo.data &&
            this.objectInfo.data.recordTypeInfos
        ) {
            const rtis = this.objectInfo.data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(
                (rti) => rtis[rti].name === 'TAM_Meeting'
            );
        } else if (this.objectInfo && this.objectInfo.data) {
            this.recordTypeId = "$objectInfo.data.defaultRecordTypeId";
        }
        getparams({ recId: event.detail.Id, meetingId: this.recordId }).then(result => {
            this.defparams = result;
            console.log(result);
            this.showNewActionPlanModal = true;
            console.log(this.showNewActionPlanModal);
        }).catch(error => {
            // Showing errors if any while inserting the files
            if (error) {
                console.log('inside error');
                console.log(error);
                let message = 'Error: ';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (error.body && error.body.message && typeof error.body.message === 'string') {
                    message = error.body.message;
                } else if (error.body.pageErrors && error.body.pageErrors[0] && error.body.pageErrors[0].message) {
                    message += error.body.pageErrors[0].message;
                } else if (error.body && error.body.fieldErrors && error.body.fieldErrors[0] && error.body.fieldErrors[0].message) {
                    message += error.body.fieldErrors[0].message;
                }
                this.errmsg = message;

                // Fire the custom event
                this.loading = false;
            }
        });
    }

    hanldeAllInDocs(event) {
        console.log('Event :'+ event.detail.actionName);
        this.progressValue = event.detail;
        let records = JSON.parse(JSON.stringify(event.detail.records));
        console.log(records);
        //Added by Anup- CR#1477 - Start
        if(event.detail.actionName === "Show All in doc"){
            records = records.map(rec => {
                rec['Visible_in_Doc__c'] = true;
                return rec;
            });
        }
        if(event.detail.actionName === "Unselect All"){
            records = records.map(rec => {
                rec['Visible_in_Doc__c'] = false;
                return rec;
            });
        }
        //Added by Anup- CR#1477 - End
        console.log(records);
        this.showSpinner = true;
        if (
            event.detail.actionName &&
            (event.detail.actionName === "Show All in doc" || event.detail.actionName === "Unselect All")
        ) {
            if(records.length > 150 && this.objectName == 'Case'){
                console.log('Splitted Updates');
                var x,y;
                var splittedArray;
                var splitSize = 150;
                var showSuccess=false;
                for (x = 0,y = records.length; x < y; x += splitSize) {
                    this.showSpinner = true;
                    splittedArray = records.slice(x, x + splitSize);
                    callAllInDoc({
                        records: splittedArray
                    })
                        .then((result) => {
                            this.showSpinner=true;
                            console.log("---callAllInDoc--result--", result);
                            this.template.querySelector("c-dynamic-related-list-component").refreshdata();
                            if(showSuccess == false){
                                let msg = "Records modified succesfully.";
                                this.fireToastEvent("Success", msg, "success");
                                showSuccess = true;
                            }
                            this.showSpinner = false;
                        })
                        .catch((error) => {
                            this.showSpinner = false;
                            console.log("---error--", error);
                            let msg = "Error occured, Please contact administartor.";
                            this.fireToastEvent("Error Occured,", msg, "error");
                        });
                }

            }else{
                callAllInDoc({
                    records: records
                })
                    .then((result) => {
                        console.log("---callAllInDoc--result--", result);
                        this.template.querySelector("c-dynamic-related-list-component").refreshdata();
                        let msg = "Records modified succesfully.";
                        this.fireToastEvent("Success", msg, "success");
    
                        this.showSpinner = false;
                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        console.log("---error--", error);
                        let msg = "Error occured, Please contact administartor.";
                        this.fireToastEvent("Error Occured,", msg, "error");
                    });
            }
            /*callAllInDoc({
                records: records
            })
                .then((result) => {
                    console.log("this is Anup Test");
                    console.log("---callAllInDoc--result--", result);
                    this.template.querySelector("c-dynamic-related-list-component").refreshdata();
                    let msg = "Records modified succesfully.";
                    this.fireToastEvent("Success", msg, "success");

                    this.showSpinner = false;
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log("---error--", error);
                    let msg = "Error occured, Please contact administartor.";
                    this.fireToastEvent("Error Occured,", msg, "error");
                });*/
        }
    }

    fireToastEvent(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}