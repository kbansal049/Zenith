import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getColumnDetails from '@salesforce/apex/TechPartnerUsageController.getColumnDetails';
import getTechPartnerUsageRecordsForDataTable from '@salesforce/apex/TechPartnerUsageListViewController.getTechPartnerUsageRecordsForDataTable';

export default class TechPartnerUsageListView extends NavigationMixin(LightningElement) {

    //columns = columns;
    columns = [];
    data = [];
    error;
    totalNumberOfRows; // stop the infinite load after this threshold count
    // offSetCount to send to apex to get the subsequent result. 0 in offSetCount signifies for the initial load of records on component load.
    offSetCount = 0;
    loadMoreStatus;
    targetDatatable; // capture the loadmore event to fetch data and stop infinite loading
    totalSolutionRecords;
    totalIntegrationRecords;


    _recordId;

    @api set recordId(value) {
        this._recordId = value;
        // do your thing right here with this.recordId / value
    }

    get recordId() {
        return this._recordId;
    }


    connectedCallback() {
        this.setDataTableColumns();
        //Get initial chunk of data with offset set at 0
        this.getRecords();
    }

    async setDataTableColumns() {
        try {
            this.isSpinnerVisible = true;
            //Get the column names from field set
            let objectColumns_DataTable = await getColumnDetails({ fieldSetName: 'TechPartnerUsageListViewLWC' });//Apex Function Call
            //Emptying the array, to implement table refresh functionality
            this.columns = [];
            if (objectColumns_DataTable) {
                let objectColumnsNames = objectColumns_DataTable.map(function (element, index) {
                    //Converting to String values as per the standard syntax of LWC Data Table Column
                    //{ label: 'Opportunity name', fieldName: 'opportunityName', type: 'text' }
                    element.label = String(element.label);
                    element.fieldName = String(element.fieldName);
                    element.type = String(element.type);

                    if (element.fieldName == 'Customer_Account__c') {
                        element.label = 'Customer';
                        element["type"] = 'lookup';
                        element["typeAttributes"] = {
                            placeholder: 'Choose Customer Account',
                            object: 'Account',
                            fieldName: 'Customer_Account__c',
                            label: 'Customer',
                            value: { fieldName: 'Customer_Account__c' },
                            context: { fieldName: 'Id' },
                            variant: 'label-hidden',
                            name: 'Customer',
                            fields: ['Account.Name'],
                            target: '_blank',
                            inlineEditing: false,
                        };
                    }
                    if (element.fieldName == 'Is_Primary__c') {
                        element["type"] = 'boolean';
                    }
                    if (element.fieldName == 'Org_ID__c') {
                        element["type"] = 'lookup';
                        element["typeAttributes"] = {
                            placeholder: 'Choose Zscaler Cloud ID',
                            object: 'Zscaler_Cloud_ID__c',
                            fieldName: 'Org_ID__c',
                            label: 'Org Id',
                            value: { fieldName: 'Org_ID__c' },
                            context: { fieldName: 'Id' },
                            variant: 'label-hidden',
                            name: 'Org Id',
                            fields: ['Zscaler_Cloud_ID__c.Name'],
                            target: '_blank',
                            inlineEditing: false,
                        };
                    }
                    return element;
                });

                console.log('objectColumnsNames : ' + JSON.stringify(objectColumnsNames));
                this.columns = objectColumnsNames;// Data Table Columns are set                
            }
            this.isSpinnerVisible = false;
        } catch (error) {
            console.error('error : ' + JSON.stringify(error));
            this.isSpinnerVisible = false;
        }
    }

    getRecords() {
        getTechPartnerUsageRecordsForDataTable({ offSetCount: this.offSetCount, techPartnerId: this.recordId })
            .then(result => {
                // Returned result if from sobject and can't be extended so objectifying the result to make it extensible
                result = JSON.parse(JSON.stringify(result));
                console.log('result : ' + JSON.stringify(result));

                this.totalNumberOfRows = result.totalRecords;
                this.totalSolutionRecords = result.totalSolutionRecords;
                this.totalIntegrationRecords = result.totalIntegrationRecords;
                this.data = [...this.data, ...result.techPartnerUsageList];
                this.error = undefined;
                this.loadMoreStatus = '';
                if (this.targetDatatable && this.data.length >= this.totalNumberOfRows) {
                    //stop Infinite Loading when threshold is reached
                    this.targetDatatable.enableInfiniteLoading = false;
                    //Display "No more data to load" when threshold is reached
                    this.loadMoreStatus = 'No more data to load';
                }
                //Disable a spinner to signal that data has been loaded
                if (this.targetDatatable) this.targetDatatable.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.data = undefined;
                console.log('error : ' + JSON.stringify(this.error));
            });
    }

    // Event to handle onloadmore on lightning datatable markup
    handleLoadMore(event) {
        event.preventDefault();
        // increase the offset count by 20 on every loadmore event
        this.offSetCount = this.offSetCount + 20;
        //Display a spinner to signal that data is being loaded
        event.target.isLoading = true;
        //Set the onloadmore event taraget to make it visible to imperative call response to apex.
        this.targetDatatable = event.target;
        //Display "Loading" when more data is being loaded
        this.loadMoreStatus = 'Loading';
        // Get new set of records and append to this.data
        this.getRecords();
    }
}