import { LightningElement, api, track} from 'lwc';

const columns = [
    { label: 'Distributor Name', fieldName: 'Partner_Name__c'}
];

export default class LwcForFlow extends LightningElement {
    @api selectedDistributor='';
    @api selectedDistributorName = '';
    @api existingDistributors = [];
    @track columns = columns;
    @track maxRowSelection = 1;
    @track selectedRows = [];

    handleRowSelection() {
        var selectRow = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.selectedDistributor = selectRow[0].Account__c;
        this.selectedDistributorName = selectRow[0].Partner_Name__c;
        console.log('selectRow.Id',selectRow[0].Account__c);
    }
}