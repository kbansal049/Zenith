import { LightningElement, wire, api, track } from 'lwc';
import getrelatedRecords from '@salesforce/apex/RelatedListController.fetchRecords';
import saveRecords from '@salesforce/apex/RelatedListController.saveRecs';
import deleteRecords from '@salesforce/apex/RelatedListController.delRecs';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub_Internal';
import { CurrentPageReference } from 'lightning/navigation';
import relatedtablecss from '@salesforce/resourceUrl/Service_360_css';
import { loadStyle } from 'lightning/platformResourceLoader';


export default class DynamicTableComponent extends NavigationMixin(LightningElement) {
    
    @api actionFieldSetName;
  @api actionFieldSetNameEdit;
    
    @api fieldSetName;
    @api objectName;
    @api recordId;
    @api childRelFieldName;
    @api parentRelFieldName;
    @api inlineEdit;
    @api filterCondition;
    @api showRowActions;
    @api recordActions;
    @api showStandardView;
    @api showStandardEdit;
    @api showStandardDelete;
    @api showCustomstyle;
    @track columns;
    @track showData;
    @track rldata;
    @track rldatafinal;
    @track currentpgnum = 1;
    @track loading = true;
    @track showgenericEdit = false;
    @track searchVal;
    @track sortBy;
    @track sortDirection;
    @track recordStartnum;
    @track recordEndnum;
    @track records = [];
    @track customStyle;
    @track errmsg;
    @api numofrecords = 10;
    @track showViewEdit=false;
    totalRecords;
    showgenericEditrecId;
    wiredResults;
    relValue;

    @wire(CurrentPageReference) pageRef;

    get loadData() {
        return !this.loading;
    }

    get vals() {
        let req = {};
        if (!this.recordId) {
            let paramobj = this.urlparams('c__id');
            if (paramobj && paramobj.length > 1) {
                this.recordId = paramobj[1];
            }
        }
        if(this.objectName=='GCS_Project__c'){
            this.showViewEdit=true;
        }
        //this.loading = true;
        console.log('++++' + this.loading);
        req['parentId'] = this.recordId;
        req['child_API_Name'] = this.childRelFieldName;
        req['parent_API_Name'] = this.parentRelFieldName;
        req['objName'] = this.objectName;
        req['filterCondition'] = this.filterCondition;
        req['fieldSetName'] = this.fieldSetName;
        req['showInlineEdit'] = this.inlineEdit;
        return JSON.stringify(req);

    }

    urlparams(paramreq) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.

            if (sParameterName[0] === paramreq) { //lets say you are looking for param name - firstName
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
                break;
            } else {
                sParameterName = [];
            }
        }
        console.log(sParameterName);
        return sParameterName;
    }

    @wire(getrelatedRecords, { req: '$vals' })
    processres(results) {
        console.log('++++' + this.loading);
        this.wiredResults = results;
        if (results.data) {
            console.log(results.data);
            if (results.data.soblst) {
                this.rldata = JSON.parse(JSON.stringify(results.data.soblst));
                this.rldatafinal = JSON.parse(JSON.stringify(results.data.soblst));
                this.showpagination = this.rldatafinal.length > this.numofrecords;
                this.setrecordsforindex(this.currentpgnum);
            }
            this.showData = results.data.showData;
            if (results.data.relatedId) {
                console.log(results.data.relatedId);
                console.log(this.relValue);
                if (this.relValue != results.data.relatedId) {
                    this.relValue = results.data.relatedId;
                    console.log('inside if' + this.relValue);
                    this.dispatchEvent(new CustomEvent('assignparentid', { detail: this.relValue }));
                }
            }
            //this.columns = results.data.collst;
            if (results.data.collst) {
                this.columns = [...results.data.collst];
                let actions = [];
                if (this.showRowActions || this.showStandardView || this.showStandardEdit || this.showStandardDelete) {
                    if (this.recordActions) {
                        actions = [...this.recordActions];
                    }
                    if (this.showStandardView) {
                        actions.push({ label: 'View', name: 'view' });
                    }
                    if (this.showViewEdit) {
                        actions.push({ label: 'View/Edit', name: 'view' });
                    }
                    if (this.showStandardEdit) {
                        actions.push({ label: 'Edit', name: 'edit' });
                    }
                    if (this.showStandardDelete) {
                        actions.push({ label: 'Delete', name: 'delete' });
                    }
                    if (actions) {
                        this.columns.push({ type: 'action', typeAttributes: { rowActions: actions, menuAlignment: "slds-popover__body" } });
                    }
                }
            }
            this.loading = false;
            console.log(this.columns);
            console.log(this.rldata);
        } else if (results.error) {
            let error = results.error;
            let message = 'Unknown error';
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
            this.loading = false;
        }
    }

    setrecordsforindex(index) {
        this.recordStartnum = this.rldatafinal.length < 1 ? this.rldatafinal.length : (index - 1) * this.numofrecords + 1;
        this.recordEndnum = (index * this.numofrecords) > this.rldatafinal.length ? this.rldatafinal.length : (index * this.numofrecords);
        this.totalRecords = this.rldatafinal.length;
        this.records = this.rldatafinal.slice((index - 1) * this.numofrecords, (index * this.numofrecords));

    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        switch (action.name) {
            case 'edit':
                this.showgenericEdit = true;
                this.showgenericEditrecId = row.Id;
                break;
            case 'view':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        objectApiName: this.objectApiName,
                        actionName: 'view'
                    }
                });
                break;
            case 'delete':
                this.loading = true;
                deleteRecords({ rec: row }).then(result => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record is deleted',
                            variant: 'success'
                        })
                    );
                    // Display fresh data in the datatable
                    return refreshApex(this.wiredResults);
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
                break;
            default:
                this.dispatchEvent(new CustomEvent(action.name, { detail: row, bubbles: true, composed: true }));
        }
    }

    handleSave(event) {
        const recordInputs = event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            console.log(Object.assign({}, draft));
            return fields;
        });
        this.loading = true;
        //this.errmsg = '';
        console.log(recordInputs);
        console.log('+++++' + this.loading);
        saveRecords({ soblst: recordInputs }).then(result => {
            console.log('++++++' + result);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record(s) updated',
                    variant: 'success'
                })
            );
            this.errmsg = '';
            // Clear all draft values
            this.draftValues = [];
            // Display fresh data in the datatable
            return refreshApex(this.wiredResults);
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

    @api
    handleEditSave(event) {
        this.refreshapex();
    }

    handleEditCancel(event) {
        this.showgenericEdit = false;
    }
    @api
    refreshapex() {
        this.loading = true;
        this.searchVal = '';
        this.errmsg = '';
        console.log(this.loading);
        return refreshApex(this.wiredResults);
    }

    connectedCallback() {
        this.numofrecords = this.numofrecords ? this.numofrecords : 10;
        registerListener('dynamicTableContentRefresh', this.handleMessage, this);
        console.log('inside connectedoftable');
        this.customStyle = 'dynamic-table-scrollbar';
        loadStyle(this, relatedtablecss + '/css/dynamic-table-scrollbar.css')
        console.log(this.showCustomstyle);
        if (this.showCustomstyle) {
            console.log('++++inside custom css table');
            this.customStyle = 'dynamic-table ' + this.customStyle;
            loadStyle(this, relatedtablecss + '/css/dynamic-table.css')
        }
    }

    handleMessage(message) {
        let mes = '' + message;
        if (mes && this.objectName && mes == this.objectName) {
            console.log(message);
            console.log(this.objectName);
            this.refreshapex();
        }
        //Add your code here
    }

    disconnectCallback() {
        unregisterAllListeners(this);
    }

    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;

        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.rldatafinal));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1 : -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.rldatafinal = parseData;
        this.setrecordsforindex(this.currentpgnum);
    }
    handlePageChange(event) {
        this.currentpgnum = event.detail;
        console.log(this.currentpgnum);
        this.setrecordsforindex(this.currentpgnum);
    }


    handleSearchChange(event) {
        let searchValue = event.detail.value;
        let subsetResult = [];
        if (searchValue && this.rldata) {
            for (let datakey in this.rldata) {
                let el = this.rldata[datakey];
                for (let key in this.columns) {
                    let column = this.columns[key];
                    let value = '';
                    if (column && el && el[column.fieldName]) {
                        value += el[column.fieldName];
                    }
                    console.log(column);
                    console.log(column.fieldName);
                    console.log(value);
                    console.log(value && value.toLowerCase().includes(searchValue.toLowerCase()));
                    if (value && value.toLowerCase().includes(searchValue.toLowerCase())) {
                        subsetResult.push(el);
                        break;
                    }
                }
            }
            if (subsetResult) {
                this.rldatafinal = subsetResult;
            } else {
                this.rldatafinal = this.rldata;
            }
        } else {
            this.rldatafinal = this.rldata;
        }
        console.log(subsetResult);
        console.log(this.rldata);

        this.setrecordsforindex(this.currentpgnum);
        if (this.template.querySelector('c-paginator-l-w-c')) {
            this.template.querySelector('c-paginator-l-w-c').updateAttributesfromParent(this.totalRecords, this.currentpgnum, this.numofrecords);
        }
    }
    
    @api
    getTotalrecords(){
        console.log(this.rldata[0]);
        console.log(this.rldata);
        return JSON.parse(JSON.stringify(this.rldata));
    }
}