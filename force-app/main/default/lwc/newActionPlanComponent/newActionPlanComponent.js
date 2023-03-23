import { LightningElement, api, wire, track } from 'lwc';

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
    @api showAllInDocs = false;

    get defaultparams() {
        return [{'name' : 'Meeting__c', 'value': this.recordId}];
    }
}