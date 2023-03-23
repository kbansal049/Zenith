import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getColumnDetails from '@salesforce/apex/TechPartnerUsageController.getColumnDetails';
import getTechnologyPartnerUsageRecords from '@salesforce/apex/TechPartnerUsageController.getTechnologyPartnerUsageRecords';
import updateIsPrimaryFieldOnTechPartnerRecords from '@salesforce/apex/TechnologyPartnerUsageHelper.updateIsPrimaryFieldOnTechPartnerRecords';
import getZSCloudDetails from '@salesforce/apex/TechPartnerUsageController.getZSCloudDetails';
import getTechPartnerRecordsToDelete from '@salesforce/apex/TechPartnerUsageController.getTechPartnerRecordsToDelete';
import deleteTechPartnerUsageRecords from '@salesforce/apex/TechPartnerUsageController.deleteTechPartnerUsageRecords';
import updateTechPartnerUsageRecords from '@salesforce/apex/TechPartnerUsageController.updateTechPartnerUsageRecords';

// Import custom labels
import AddPartnerSolutionBeingUsed_ButtonLabel from '@salesforce/label/c.TechPartnerUsage_AddPartnerSolutionBeingUsed_ButtonLabel';
import AddPartnerSolutionBeingUsed_HeaderLabel from '@salesforce/label/c.TechPartnerUsage_AddPartnerSolutionBeingUsed_HeaderLabel';
import EditAction_HeaderLabel from '@salesforce/label/c.TechPartnerUsage_EditAction_HeaderLabel';

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const actionColumn = [
    {
        label: 'Action',
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class TechPartnerUsage extends LightningElement {

    //@api recordId;

    _recordId;

    @api set recordId(value) {
        this._recordId = value;
        // logic after we have this.recordId value, LWC Qucik Action (Screen), we do not get the recordId onLoad
        this.setDataTableColumns();
        this.setDataTableData();
    }

    get recordId() {
        return this._recordId;
    }

    // Expose the labels to use in the template.
    label = {
        AddPartnerSolutionBeingUsed_ButtonLabel,
        AddPartnerSolutionBeingUsed_HeaderLabel,
        EditAction_HeaderLabel,
    };

    showErrorMessage = '';
    @track data = [];
    @track columns = [];
    @track draftValues = [];
    rowOffset = 0;

    @track dataObjects = [];
    // Create an empty array
    @track segmentRecordsMap = new Map();

    //Modal Variables
    showModal = false;
    modalHeaderString = '';

    //Record Edit Form variables
    techPartnerUsageRecordId = '';
    techPartnerUsageObjectApiName = 'Technology_Partner_Usage__c';
    @track fieldAPINameList_RecordEditForm = [];

    isAddSolutionPartnerClick = false;
    recordEditFormSubmitButtonName = '';

    isEditFromDataTableAction = false;

    //Spinner Variables
    isSpinnerVisible = false;

    //
    @track segmentIsPrimaryNotEditableSet = new Set();
    isPrimaryFieldReadOnly = false;

    editAction = false;
    recordIdSelectedForEditOrDelete;

    isAddSolutionPartnerClickedBool = false;
    segmentNameOnCreate;

    showDeleteConfirmationModal = false;
    selectedRowForRowAction;
    selectedSegmentOnEdit = '';

    //Org Id Combobox Value
    orgIdComboBoxValueOnChange;
    orgIdComboBoxValue;

    @track orgIdComboBoxOptions;

    multipleRecordsToDelete = false;
    @track recordsToDeleteData = [];
    @track recordsToDeleteColumns;

    @track accordion_section_iconname = 'utility:add';

    @api selectedTechPartnerUsageList = [];

    connectedCallback() {
        console.log('Record Id : ' + this.recordId);
        this.setDataTableColumns();
        this.setDataTableData();
    }

    renderedCallback() {

        //Pre Populate the Default values, make fields readOnly/mandatory for LWC Record Edit Form
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.fieldName == 'Usage_Type__c') {
                    field.value = 'Solution';
                    field.readOnly = true;
                }
                if (field.fieldName == 'Segment__c') {//On Create of a new record
                    field.readOnly = true;
                    if (this.isAddSolutionPartnerClickedBool) {
                        field.value = this.segmentNameOnCreate;
                    }
                }
                if (field.fieldName == 'Technology_Partner_Id__c') {
                    field.required = true;
                }
            });
        }

        //Add slds-hide class to the fields which are not required for Users to input value, but we require for our logic
        if (this.template.querySelector(`[data-id="Customer_Account__c"]`)) {
            if (this.template.querySelector(`[data-id="Customer_Account__c"]`).classList) {
                this.template.querySelector(`[data-id="Customer_Account__c"]`).classList.add('slds-hide');
            }
        }
        if (this.template.querySelector(`[data-id="Org_ID__c"]`)) {
            if (this.template.querySelector(`[data-id="Org_ID__c"]`).classList) {
                this.template.querySelector(`[data-id="Org_ID__c"]`).classList.add('slds-hide');
            }
        }
    }

    async setDataTableColumns() {
        try {
            this.isSpinnerVisible = true;
            //Get the column names from field set
            let objectColumns_DataTable = await getColumnDetails({ fieldSetName: 'TechPartnerUsageLWC_DataTable' });//Apex Function Call
            //Emptying the array, to implement table refresh functionality
            this.columns = [];

            if (objectColumns_DataTable) {
                let objectColumnsNames = objectColumns_DataTable.map(function (element, index) {
                    //Converting to String values as per the standard syntax of LWC Data Table Column
                    //{ label: 'Opportunity name', fieldName: 'opportunityName', type: 'text' }
                    element.label = String(element.label);
                    element.fieldName = String(element.fieldName);
                    element.type = String(element.type);

                    if (element.fieldName == 'Technology_Partner_Id__c') {
                        element["label"] = 'Technology Partner';
                        element["fieldName"] = String(element.fieldName);
                        //Custom Type "lookup", created as part of CustomDataTable component,
                        //Used to show the field as Lightning Formatted URL, navigate to the record (Tech Partner/Org Id) 
                        //Actual functionality of "look up" field (Inline EDIT) - have some issues in CSS, not implemented
                        element["type"] = 'lookup';
                        element["typeAttributes"] = {
                            placeholder: 'Choose Tech Partner Account',
                            object: 'Account',
                            fieldName: String(element.fieldName),
                            label: 'Technology Partner',
                            value: { fieldName: String(element.fieldName) },
                            context: { fieldName: 'Id' },
                            variant: 'label-hidden',
                            name: 'Technology Partner',
                            fields: ['Account.Name'],
                            target: '_blank',
                            inlineEditing: false,
                        };
                        element["cellAttributes"] = {
                            class: { fieldName: 'accountNameClass' }
                        }
                    }
                    if (element.fieldName == 'Is_Primary__c') {
                        element["type"] = 'boolean';
                    }

                    if (element.fieldName == 'Org_ID__c') {
                        element["label"] = String(element.label);
                        element["fieldName"] = String(element.fieldName);
                        element["type"] = 'lookup';
                        element["typeAttributes"] = {
                            placeholder: 'Choose Zscaler Cloud ID',
                            object: 'Zscaler_Cloud_ID__c',
                            fieldName: String(element.fieldName),
                            label: String(element.label),
                            value: { fieldName: String(element.fieldName) },
                            context: { fieldName: 'Id' },
                            variant: 'label-hidden',
                            name: String(element.label),
                            fields: ['Zscaler_Cloud_ID__c.Name'],
                            target: '_blank',
                            inlineEditing: false,
                        };
                        element["cellAttributes"] = {
                            class: { fieldName: 'accountNameClass' }
                        }
                    }
                    if (element.fieldName == 'Notes__c') {
                        element["editable"] = true;
                    }
                    return element;
                });

                objectColumnsNames.unshift(actionColumn[0]); //Adds at the beginning of an array

                console.log('columns : ' + JSON.stringify(objectColumnsNames));
                this.columns = objectColumnsNames;// Data Table Columns are set                
            }
            this.isSpinnerVisible = false;
        } catch (error) {
            console.error('error : ' + JSON.stringify(error));
            this.isSpinnerVisible = false;
        }
    }

    async setDataTableData() {
        try {
            let techPartnerRecordsMap = new Map();
            let segmentRecordsMapLocal = new Map();
            let localSegment = ['Cloud', 'Data Protection', 'Endpoint', 'Identity', 'Network', 'Operations'];

            //Emptying the array, to implement table refresh functionality
            let dataObjectsLocal = [];
            let techPartnerRecordsUnique = [];
            let segmentRecordsMapLocalWithSegmentLength = new Map();

            this.isSpinnerVisible = true;

            localSegment.forEach(element => {
                // Shorcut || returns left side if it is "truthy," or the right otherwise.
                // This means that we only assign a new Array to the Object's property
                // if it has not previously been used.
                //segmentRecordsMapLocal[key] = segmentRecordsMapLocal[key] || [];
                segmentRecordsMapLocal[String(element)] = segmentRecordsMapLocal[String(element)] || [];
            });

            //Get the records for Data Table
            let techPartnerRecords = await getTechnologyPartnerUsageRecords({ recordIdOfCustomerAccount: this.recordId });//Apex Function Call

            //If no records found allow creation of new records
            if (techPartnerRecords.length === 0) {
                //Below logic creates a Map of Segment as key and RecordList as Value, one segment multiple records
                for (let key in segmentRecordsMapLocal) {
                    // Preventing unexcepted data
                    if (segmentRecordsMapLocal.hasOwnProperty(key)) { // Filtering the data in the loop 
                        let isRecordsAvailable = segmentRecordsMapLocal[key].length > 0 ? true : false;
                        dataObjectsLocal.push({ value: segmentRecordsMapLocal[key], key: `${key} (0)`, segmentString: key, recordsAvailable: isRecordsAvailable });
                    }
                }
            } else {
                //Don’t show a duplicate record, Boomi and manually created
                //Combination of as Segment__c,Technology_Partner__c & Usage_Type__c which was manually created            
                techPartnerRecords.forEach(element => {
                    element.linkName = '/' + element.Id;//used for lightning formatted URL
                    element.accountNameClass = 'slds-cell-edit';
                    let key = String(element.Segment__c) + String(element.Technology_Partner_Id__c) + String(element.Usage_Type__c);
                    //If one of the duplicate records is having Is_Primary__c = TRUE,
                    //to show the record which has the Is_Primary__c = TRUE in Front end
                    //records from apex controller "getTechnologyPartnerUsageRecords" also has "Order By" field "CreatedDate"
                    if (element.Is_Primary__c && techPartnerRecordsMap.has(key)) {
                        techPartnerRecordsMap.delete(key);
                    }
                    techPartnerRecordsMap.set(key, element);
                });

                // iterate over values techPartnerRecordsMap.values()
                for (let record of techPartnerRecordsMap.values()) {
                    techPartnerRecordsUnique.push(record);
                }

                if (techPartnerRecordsUnique) {
                    techPartnerRecordsUnique.forEach(element => {
                        // Shorcut || returns left side if it is "truthy," or the right otherwise.
                        // This means that we only assign a new Array to the Object's property
                        // if it has not previously been used.
                        //segmentRecordsMapLocal[key] = segmentRecordsMapLocal[key] || [];
                        segmentRecordsMapLocal[String(element.Segment__c)] = segmentRecordsMapLocal[String(element.Segment__c)] || [];
                        // Adds a value to the end of the Array
                        //segmentRecordsMapLocal[key].push(value);
                        segmentRecordsMapLocal[String(element.Segment__c)].push(element);

                    });
                    console.log('segmentRecordsMapLocal : ' + JSON.stringify(segmentRecordsMapLocal));

                    for (let segment in segmentRecordsMapLocal) {
                        // executes the body for each key among object properties
                        let segmentLength = segmentRecordsMapLocal[segment].length;
                        console.log('segmentLength : ' + segmentLength);
                        let mapKey = String(segment) + ' (' + String(segmentLength) + ')';
                        console.log('mapKey : ' + mapKey);
                        segmentRecordsMapLocalWithSegmentLength[mapKey] = segmentRecordsMapLocal[segment];
                    }
                    console.log('segmentRecordsMapLocalWithSegmentLength : ' + JSON.stringify(segmentRecordsMapLocalWithSegmentLength));

                    //Below logic creates a Map of Segment as key and RecordList as Value, one segment multiple records
                    for (let key in segmentRecordsMapLocalWithSegmentLength) {
                        // Preventing unexcepted data
                        if (segmentRecordsMapLocalWithSegmentLength.hasOwnProperty(key)) { // Filtering the data in the loop 
                            let indexOfresult = key.indexOf("(") - 1;//Subtract 1 for the space betweensegment and it's length
                            let subStringresult = key.substring(0, indexOfresult);
                            let isRecordsAvailable = segmentRecordsMapLocalWithSegmentLength[key].length > 0 ? true : false;
                            dataObjectsLocal.push({ value: segmentRecordsMapLocalWithSegmentLength[key], key: key, segmentString: subStringresult, recordsAvailable: isRecordsAvailable });
                        }
                    }
                }
            }
            this.dataObjects = dataObjectsLocal;// DataTable records are set
            console.log('data : ' + JSON.stringify(this.dataObjects));
            this.isSpinnerVisible = false;
        } catch (error) {
            console.error('error : ' + JSON.stringify(error));
            this.isSpinnerVisible = false;
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.recordIdSelectedForEditOrDelete = row.Id;
        if (row.Usage_Type__c === 'Integration') {
            let errorMessage = 'Edit/Delete Opeartion is not allowed for "Integration" Usage Type.';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: errorMessage,
                    variant: 'error'
                })
            );
        } else {
            switch (actionName) {
                case 'delete':
                    this.selectedRowForRowAction = row;
                    this.techPartnerRecordsToDelete(JSON.stringify(row));
                    this.showDeleteConfirmationModal = true;
                    break;
                case 'edit':
                    this.handleEditFromDataTableAction(row);
                    break;
                default:
            }
        }
    }

    async handleEditFromDataTableAction(row) {
        try {
            this.editAction = true;
            this.isSpinnerVisible = true;
            this.isEditFromDataTableAction = true;
            this.techPartnerUsageRecordId = row.Id;
            this.modalHeaderString = this.label.EditAction_HeaderLabel;
            this.recordEditFormSubmitButtonName = 'Save';

            let fieldApiNameArray = [];
            let objectColumns_RecordEditForm = await getColumnDetails({ fieldSetName: 'TechPartnerUsageLWC_RecordEditForm' });
            if (objectColumns_RecordEditForm) {
                let objectColumnsNames = objectColumns_RecordEditForm.map(function (element, index) {
                    fieldApiNameArray.push(element.fieldName);
                    return element;
                });
                this.fieldAPINameList_RecordEditForm = fieldApiNameArray;
                this.showModalPopover();
            }
        } catch (error) {
            console.error('error : ' + JSON.stringify(error));
            this.isSpinnerVisible = false;
        }

    }

    handleAccordionSectionClick(event) {
        let dataKey = event.currentTarget.dataset.id

        if (this.template.querySelector(`[data-key="${dataKey}"]`) &&
            this.template.querySelector(`[data-key="${dataKey}"]`).classList.contains('slds-is-close')) {
            this.template.querySelector(`[data-key="${dataKey}"]`).classList.remove('slds-is-close');
            this.template.querySelector(`[data-key="${dataKey}"]`).classList.add('slds-is-open');
            event.target.iconName = "utility:dash";//Icon change on Accordion Section
        } else if (this.template.querySelector(`[data-key="${dataKey}"]`) &&
            this.template.querySelector(`[data-key="${dataKey}"]`).classList.contains('slds-is-open')) {
            this.template.querySelector(`[data-key="${dataKey}"]`).classList.remove('slds-is-open');
            this.template.querySelector(`[data-key="${dataKey}"]`).classList.add('slds-is-close');
            event.target.iconName = "utility:add";//Icon change on Accordion Section
        }
    }

    async handleAddSolutionPartnerClick(event) {
        try {
            this.isSpinnerVisible = true;
            this.isAddSolutionPartnerClickedBool = true;
            let dataKey = event.currentTarget.dataset.id;
            this.segmentNameOnCreate = dataKey;
            this.isAddSolutionPartnerClick = true;
            this.modalHeaderString = this.label.AddPartnerSolutionBeingUsed_HeaderLabel;
            this.recordEditFormSubmitButtonName = 'Create';
            let fieldApiNameArray = [];
            this.getZSCloudDetailsForAccountRecord();//Get ComoboBox Details
            let objectColumns_RecordEditForm = await getColumnDetails({ fieldSetName: 'TechPartnerUsageLWC_RecordEditForm' });
            if (objectColumns_RecordEditForm) {
                let objectColumnsNames = objectColumns_RecordEditForm.map(function (element, index) {
                    fieldApiNameArray.push(element.fieldName);
                    return element;
                });
                this.fieldAPINameList_RecordEditForm = fieldApiNameArray;
                this.showModalPopover();
            }
            this.isSpinnerVisible = false;
        } catch (error) {
            console.error('error : ' + JSON.stringify(error));
            this.isSpinnerVisible = false;
        }
    }

    showModalPopover() {
        this.showModal = true;
    }

    handleModalDialogClose() {
        this.showModal = false;
        if (this.isAddSolutionPartnerClickedBool) {
            this.isAddSolutionPartnerClickedBool = false;
        }
    }

    handleOnLoadEvent(event) {
        //console.log('handleOnLoadEvent event.detail.record : ' + JSON.stringify(event.detail.records));
        this.isSpinnerVisible = false;
        if (this.isAddSolutionPartnerClickedBool) {//On Create of a new record
            //When "Add a solution partner being used" button was clicked, values were getting prepulated
            //This was happening because when "Edit" action was clicked this.techPartnerUsageRecordId,
            //was populated with the selected rowId
            //to avoid pre-populate values on click of add a new record, we empty the this.techPartnerUsageRecordId
            this.techPartnerUsageRecordId = '';
        }
        //To set the Segment
        if (this.editAction && this.techPartnerUsageRecordId) {
            console.log('Segment__c : ' + JSON.stringify(event.detail.records[this.techPartnerUsageRecordId].fields.Segment__c.value));
            this.selectedSegmentOnEdit = event.detail.records[this.techPartnerUsageRecordId].fields.Segment__c.value;
            this.getZSCloudDetailsForAccountRecord();//Get ComoboBox Details
            this.orgIdComboBoxValue = event.detail.records[this.techPartnerUsageRecordId].fields.Org_ID__c.value;//Sets default value
        }
    }

    handleFieldChange(event) {
        //console.log("handleFieldChange fieldName : " + event.target.fieldName + " , Value : " + event.target.value);
    }

    async handleOnSubmitEvent(event) {
        this.isSpinnerVisible = true;
        //console.log('handleOnSubmitEvent event.detail.fields : ' + JSON.stringify(event.detail.fields));
        if (this.isAddSolutionPartnerClickedBool) {//On Create of a new record
            event.preventDefault();
            const fields = event.detail.fields;
            fields.Customer_Account__c = this.recordId;
            fields.Segment__c = this.segmentNameOnCreate;
            fields.Usage_Type__c = 'Solution'; //Default value on create (always) 
            fields.Org_ID__c = this.orgIdComboBoxValueOnChange;
            //console.log('handleOnSubmitEvent event.detail.fields isAddSolutionPartnerClickedBool : ' + JSON.stringify(event.detail.fields));
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }

        if (this.editAction) {
            event.preventDefault();
            const fields = event.detail.fields;
            if (fields.Is_Primary__c) {
                let custAccIdSegmentStringMap = new Map();
                let techPartnerUsageIdSet;
                custAccIdSegmentStringMap[String(fields.Customer_Account__c)] = String(this.selectedSegmentOnEdit);
                techPartnerUsageIdSet = String(this.techPartnerUsageRecordId);
                await updateIsPrimaryFieldOnTechPartnerRecords({ customerAccountIdSegmentStringMap: custAccIdSegmentStringMap, technologyPartnerUsageIds: techPartnerUsageIdSet });
            }
            if (this.orgIdComboBoxValueOnChange) {
                fields.Org_ID__c = this.orgIdComboBoxValueOnChange;
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    handleOnSuccessEvent(event) {
        this.setDataTableColumns();
        this.setDataTableData();
        this.isSpinnerVisible = false;
        let successMessage = '';
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: '',
                variant: 'success'
            })
        );
        if (this.showModal) {
            this.handleModalDialogClose();
        }
    }

    handleOnErrorEvent(event) {
        this.setDataTableColumns();
        this.setDataTableData();
        this.isSpinnerVisible = false;
        let successMessage = '';
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error, Please Refresh the Page.',
                message: event.detail.message,
                variant: 'error'
            })
        );
        if (this.showModal) {
            this.handleModalDialogClose();
        }
    }

    handleDeleteConfirmationYes(event) {
        this.isSpinnerVisible = true;
        this.deleteTechPartnerUsageRecordAction();
        this.isSpinnerVisible = false;
        this.showDeleteConfirmationModal = false;
    }

    async deleteTechPartnerUsageRecordAction() {
        //If single is selected for delete action, this.selectedRowForRowAction
        if (!this.recordsToDeleteData.length) {
            this.recordsToDeleteData.push(this.selectedRowForRowAction);
        }
        if (this.recordsToDeleteData.length) {
            try {
                let result = await deleteTechPartnerUsageRecords({ techPartnerUsageRecords: JSON.stringify(this.recordsToDeleteData) });
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: result.status,
                        message: result.message,
                        variant: result.status
                    })
                );
            } catch (error) {
                console.log('Error : ' + JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record, Please Refresh the Page.',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            }
        }
        this.setDataTableColumns();
        this.setDataTableData();
    }

    handleDeleteConfirmationNo(event) {
        this.showDeleteConfirmationModal = false;
    }

    handleOrgIdChange(event) {
        this.orgIdComboBoxValueOnChange = event.detail.value;
    }

    async getZSCloudDetailsForAccountRecord() {
        try {
            this.isSpinnerVisible = true;
            let zsCloudIdRecords = await getZSCloudDetails({ accountRecordId: this.recordId });
            this.orgIdComboBoxOptions = zsCloudIdRecords;
            this.isSpinnerVisible = false;
        } catch (error) {
            this.isSpinnerVisible = false;
            console.log('error: ' + JSON.stringify(error));
        }

    }

    //Checks if duplicate records are present and needs to be deleted
    async techPartnerRecordsToDelete(row) {
        try {
            this.recordsToDeleteData = [];
            this.isSpinnerVisible = true;
            let techPartnerRecords = await getTechPartnerRecordsToDelete({ techPartnerUsageRecordString: row });
            if (Array.isArray(techPartnerRecords) && techPartnerRecords.length > 1) {
                this.multipleRecordsToDelete = true;
                this.recordsToDeleteColumns = this.columns;
                if (this.recordsToDeleteColumns[0].type === "action") {
                    this.recordsToDeleteColumns.shift(); //Remove the Action column  
                }
                techPartnerRecords.forEach(element => {
                    element.linkName = '/' + element.Id;//used for lightning formatted URL
                });

                this.recordsToDeleteData = techPartnerRecords;
            } else {
                this.multipleRecordsToDelete = false;
            }
            this.isSpinnerVisible = false;
        } catch (error) {
            this.isSpinnerVisible = false;
            console.log('error : ' + JSON.stringify(error));
        }

    }

    handleMutipleRowDeleteAction(event) {
        const selectedTechPartnerUsageRows = event.detail.selectedRows;
        this.selectedTechPartnerUsageList = selectedTechPartnerUsageRows;

    }

    deleteContactRowAction() {
        this.isSpinnerVisible = true;
        this.recordsToDeleteData = this.selectedTechPartnerUsageList;
        this.deleteTechPartnerUsageRecordAction();
        this.isSpinnerVisible = false;
        this.showDeleteConfirmationModal = false;
    }

    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        await updateTechPartnerUsageRecords({ data: updatedFields })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Tech Partner Usage Record(s) updated',
                        variant: 'success'
                    })
                );
                this.setDataTableColumns();
                this.setDataTableData();
            }).catch(error => {
                console.log('Error is ' + JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating or refreshing records',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}