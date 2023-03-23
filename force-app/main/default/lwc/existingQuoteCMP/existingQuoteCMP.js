import { LightningElement, api, track} from 'lwc';

const columns = [
    { label: 'Quote Number', fieldName: 'Name' },
    { label: 'Quote Name', fieldName: 'Proposal_Name__c',wrapText:true},
    { label: 'Partner Name', fieldName: 'Partner_Name__c',wrapText:true},
    { label: 'Partner Program', fieldName: 'Partner_ProgramHeader__c' }
];
export default class LwcForFlow extends LightningElement {
    @api selectedQuote = '';
    @api existingQuotes = [];
    @track columns = columns;
    @track maxRowSelection = 1;
    @track selectedRows = [];

    handleRowSelection() {
        var selectRow = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.selectedQuote = selectRow[0].Id;
        console.log('selectRow.Id',selectRow[0].Id,'this.selectedQuote',this.selectedQuote);
    }
}