import { LightningElement, api, wire, track } from "lwc";
import callAllInDoc from "@salesforce/apex/ActionPlanLWCController.updateAllInDoc";
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class related_List_with_ShowAllinDoc extends LightningElement {
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

    @api showUnselectAllInDocs;

    @track showSpinner = false;
    @api showAllInDocs = false;
    @track showAllActionName = "Show All in doc";

    @wire(CurrentPageReference) pageRef;

    hanldeAllInDocs(event) {
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