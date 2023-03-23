import { LightningElement, api, track,wire} from 'lwc';

const columns = [
    { label: 'Partner Name', fieldName: 'Partner_Name__c'},
    { label: 'Partner Program', fieldName: 'Partner_Program__c' },
    { label: 'Program Type', fieldName: 'Program_Type__c' }//CR# 4075
];



export default class LwcForFlow extends LightningElement {
    @api selectedPartner='';
    @api selectedOppPartnerID=''; // Added By Ritesh
    @api selectedPartnerProgram='';
    @api selectedPartnerName = '';
    @api selectedProgramType = '';
    @api selectedPartnerIncentive = '';
    @api selectedDistributor = '';
    @api selectedDistributorName='';
    @api selectedPartnerIsSummitDistributor=false;
    @api existingPartners = [];
    @api AccountPaymentTerms ='';
    @track columns = columns;
    @track maxRowSelection = 1;
    @track selectedRows = [];

    handleRowSelection() {
        var selectRow = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.selectedPartner = selectRow[0].Account__c;
        this.selectedOppPartnerID = selectRow[0].Id; // Added By Ritesh
        this.selectedPartnerName = selectRow[0].Partner_Name__c;
        this.selectedPartnerProgram = selectRow[0].Partner_Program__c;
        this.selectedPartnerIncentive = selectRow[0].Partner_Incentive__c;
        this.selectedProgramType =  selectRow[0].Program_Type__c;//added for 4520
        this.selectedDistributor = selectRow[0].DistributorAccount__c; //for summit distribution added by Rakshitha
        this.selectedDistributorName  = selectRow[0].DistributorAccountName__c;//for summit distribution added by Rakshitha
        this.selectedPartnerIsSummitDistributor = selectRow[0].SummitDistribution__c;
        this.AccountPaymentTerms = selectRow[0].Account_Payment_Terms__c;
    }
}