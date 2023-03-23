import { LightningElement,track} from 'lwc';
import itemsToApprove from '@salesforce/apex/FetchApproverRecordController.itemsToApprove';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: 'Approval Action', fieldName: 'actionURL', type: 'url', typeAttributes: {label: 'Approve/Reject', tooltip: 'Approve/Reject'}},
    { label: 'Rule Name', fieldName: 'Approval_Rule_Name__c'},
    { label: 'Quote', fieldName: 'quoteURL', type: 'url', typeAttributes: {label: {fieldName: 'quoteNumber'}, tooltip: {fieldName: 'quoteNumber'}}},
    { label: 'Opportunity', fieldName: 'OpportunityURL', type: 'url', typeAttributes: {label: {fieldName: 'OpportunityName'}, tooltip: {fieldName: 'OpportunityName'}}},
    { label: 'Opportunity Owner', fieldName: 'OppOwner'},
    { label: 'Close Date', fieldName: 'OppCloseDate', type: 'date-local', sortable: true},
    { label: 'Submitted On', fieldName: 'Submitted_On__c', type: 'date-local', sortable: true},
    { label: 'Geo', fieldName: 'Geo_Approval__c', sortable: true},
	{ label: 'Sub Region', fieldName: 'SubRegion', sortable: true},
    { label: 'User Geo', fieldName: 'User_Geo_Approval__c', sortable: true},
    { label: 'RVP', fieldName: 'RegionalVPURL', type: 'url', typeAttributes: {label: {fieldName: 'RegionalVPName'}, tooltip: {fieldName: 'RegionalVPName'}}},
    { label: 'ACV', fieldName: 'ACV', type: 'currency', sortable: true},
    { label: 'TCV', fieldName: 'TCV', type: 'currency', sortable: true},
    { label: 'Total Discount', fieldName: 'TotalDiscount', type: 'percent',typeAttributes: {maximumFractionDigits: '2'}, sortable: true},
    { label: 'Term', fieldName: 'Term', sortable: true},
];

export default class QuoteToApprove extends NavigationMixin(LightningElement) {
    
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    data;

	connectedCallback(){
		itemsToApprove()
			.then(result => {
                let processedData = [];
                for(let dataIns of JSON.parse(JSON.stringify(result))){
                    if(dataIns.hasOwnProperty('Quote__r')){
                        
                        dataIns['actionURL'] = dataIns.Action__c.replace('<a href="','').replace('" target="_blank">Approve/Reject</a>','');
                        dataIns['quoteURL'] = '/lightning/r/SBQQ__Quote__c/'+dataIns.Quote__c+'/view';
                        dataIns['quoteNumber'] = dataIns.Quote__r.Name;
                        dataIns['ACV'] = dataIns.Quote__r.ACVHeader__c;
                        dataIns['TCV'] = dataIns.Quote__r.TCV__c;
                        dataIns['TotalDiscount'] = dataIns.Quote__r.Total_Discount__c/100; //diving by 100 to display proper percentage format
                        dataIns['Term'] = dataIns.Quote__r.SBQQ__SubscriptionTerm__c;

                        if(dataIns.Quote__r.SBQQ__Opportunity2__c != undefined && dataIns.Quote__r.SBQQ__Opportunity2__c != null && dataIns.Quote__r.SBQQ__Opportunity2__c){

                            dataIns['OpportunityURL'] = '/lightning/r/Opportunity/'+dataIns.Quote__r.SBQQ__Opportunity2__c+'/view';
                            dataIns['OpportunityName'] = dataIns.Quote__r.SBQQ__Opportunity2__r.Name;
                            dataIns['OppCloseDate'] = dataIns.Quote__r.SBQQ__Opportunity2__r.CloseDate;
							if(dataIns.Quote__r.SBQQ__Account__r.Sales_Territory__r.District__c && dataIns.Quote__r.SBQQ__Account__r.Sales_Territory__r.District__c != null){
							    dataIns['SubRegion'] = dataIns.Quote__r.SBQQ__Account__r.Sales_Territory__r.District__c;
                            }
							//dataIns['RegionalVPURL'] = dataIns.Quote__r.SBQQ__Account__r.Sales_Territory__r.Regional_VP__c;
							if(dataIns.Quote__r.SBQQ__Account__r.Sales_Territory__r.Regional_VP__c && dataIns.Quote__r.SBQQ__Account__r.Sales_Territory__r.Regional_VP__c != null){
                                dataIns['RegionalVPURL'] = '/lightning/r/SBQQ__Quote__c/'+dataIns.Quote__r.SBQQ__Account__r.Sales_Territory__r.Regional_VP__c+'/view';
							    dataIns['RegionalVPName'] = dataIns.Quote__r.SBQQ__Account__r.Sales_Territory__r.Regional_VP__r.Name;
                            }
                            if(dataIns.Quote__r.SBQQ__Opportunity2__r.Owner){
                                dataIns['OppOwner'] = dataIns.Quote__r.SBQQ__Opportunity2__r.Owner.Name;
                            }

                        }
                        processedData.push(dataIns);
                    }

                }
                this.data = processedData;
                console.log('Processed Data: ');
                console.log(this.data);
		    });
    }

    sortBy(field, reverse) {
        const key = function (x) { return x[field]; };// Return the value stored in the field

        return function (a, b) {
            a = key(a) ? key(a) : '';
            b = key(b) ? key(b) : '';
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        console.log(event.detail);
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    //--------------------OLD CODE--------------------
    /*
    @track error;
    @track data ;
    @track approvalList = [];

    isAsc = false;
    isDsc = true;
    isNameSort = false;
    isSubmiitedDateSort = false;

    sortedDirection = 'asc';
    sortedColumn;

	connectedCallback(){
		itemsToApprove()
			.then(result => {
                console.log('data before 2## '+JSON.stringify(result));
                let dataCopy = [];
					for(let dataIns of JSON.parse(JSON.stringify(result))){
					    if(dataIns.hasOwnProperty('Quote__r')){

					    	dataIns['quoteNoURL'] = dataIns.Quote_Number__c.split('<a href=\"')[1].split('\" target=\"_blank\">'+dataIns.Quote__r.Name+'</a>')[0];
                            dataIns['quoteNoName'] = dataIns.Quote__r.Name;

                            if(dataIns.Quote__r.SBQQ__Opportunity2__c != undefined && dataIns.Quote__r.SBQQ__Opportunity2__c != null && dataIns.Quote__r.SBQQ__Opportunity2__c){

                             //   dataIns['OpportunityNameURL'] = dataIns.Opportunity_Name__c.split('<a href=\"')[1].replace('amp;','').split('\" target=\"_blank\">'+dataIns.Quote__r.SBQQ__Opportunity2__r.Name+'</a>')[0];

                                dataIns['OpportunityNameURL'] = '/lightning/r/Opportunity/'+dataIns.Quote__r.SBQQ__Opportunity2__c+'/view';
                                dataIns['OpportunityName'] = dataIns.Quote__r.SBQQ__Opportunity2__r.Name;
                                dataIns['OppCloseDate'] = dataIns.Quote__r.SBQQ__Opportunity2__r.CloseDate;
								dataIns['OppOwner'] = dataIns.Quote__r.SBQQ__Opportunity2__r.Owner.Name;
                            }
                            dataIns['actionURL'] = dataIns.Action__c.split('<a href=\"')[1].split('\" target=\"_blank\">Approve/Reject</a>')[0];
							dataCopy.push(dataIns);
						}

					}
					this.data = dataCopy;
                    console.log('data after 2## '+JSON.stringify(this.data));
		    });
    }


    // - HTMl table Sort methods
    sortName(event) {
        this.isNameSort = true;
        this.isSubmiitedDateSort = false;
        this.sortData(event.currentTarget.dataset.id);
    }
    sortSubmiitedDate(event) {
        this.isNameSort = false;
        this.isSubmiitedDateSort = true;
        this.sortData(event.currentTarget.dataset.id);
    }

    sortData(sortColumnName) {
        let previousColumn = false;
        // check previous column and direction
        if (this.sortedColumn === sortColumnName) {
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        }
        else {
            previousColumn = true;
            this.sortedDirection = 'asc';
        }
        // check arrow direction
        if (this.sortedDirection === 'asc') {
            this.isAsc = true;
            this.isDsc = false;
        }
        else {
            this.isAsc = false;
            this.isDsc = true;
        }

        // check reverse direction
        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;
        this.sortedColumn = sortColumnName;

        // sort the data
        let dataCopy = JSON.parse(JSON.stringify(this.data)).sort((a, b) => {
            console.log('data '+JSON.stringify(this.data));
                console.log('a '+JSON.stringify(a));
                console.log('b '+JSON.stringify(b));
                let innerA = typeof a[sortColumnName] === 'string' ? a[sortColumnName].toLowerCase() : a[sortColumnName]; // Handle null values
                let innerB = typeof b[sortColumnName] === 'string' ? b[sortColumnName].toLowerCase() : b[sortColumnName];

            console.log('innerA ',innerA);
            console.log('innerB ',innerB);
            if (innerA > innerB) {
                if (this.sortedDirection === 'asc') {
                    return 1;
                } else {
                    return -1;
                }
            } else if (innerA < innerB) {
                if (this.sortedDirection === 'asc') {
                    return -1;
                } else {
                    return 1;
                }
            }
            return 0;
        });
        this.data = JSON.parse(JSON.stringify(dataCopy));
    }
    */
}