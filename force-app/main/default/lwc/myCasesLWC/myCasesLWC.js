import { LightningElement, track, wire, api } from 'lwc';
// importing apex class and method to retrive accounts
import retriveCases from '@salesforce/apex/CaseLWCController.fetchCases';
import { refreshApex } from '@salesforce/apex';
//import checkAccess from '@salesforce/apex/AiseraChatbotController.createCaseEnabled';

export default class myCasesLWC extends LightningElement {
    @track headerName = 'Existing Case Summary'
    @api allcases = false;
    @track caseData;
    @track caseDataTotal;
    @track allData;
    @track caseDataTemp;
    @track error;
    @track mapOfValues = [];
    @track loading = true;
    @track pcCases = 0;
    @track myCases = 0;
    @track openCases = 0;
    @track closedCases = 0;
    @track searchValue = '';
    @track searchResult = [];
    @track displaydiv = false;
    @track value = 'MyOpenCases';
    @track accvalue = '';
    @track selectedAccount = '';
    @track myopencasecss = 'zs-my-open-case-card highlight';
    @track allopencasecss = 'zs-all-open-case-card';
    @track pendingcss = 'zs-pending-case-card';
    @track closedcss = 'zs-closed-case-card';
    @api item;
    accountMap;
    accOptions = [];
    wiredResult;
    @track searchVal;
    @track sortOrder = 'ASC';
    @track sortfield;

    @track showpagination = false;
    @track showprevious = false;
    @track currentpage = 1;
    @track pageoptions;
    @track shownext = false;
    MAX_NO_OF_RECORDS = 10;

    @track hasCreateCaseAccess = false;
    //Added by Anup - Aisera - Start
    @api customerPortal = false;

    
    /*@wire(checkAccess)
    checkInterceptAccess({ error, data }) {
        if(data != 'No Session Id' && data!='false'){
            if(this.customerPortal == true){
                this.hasCreateCaseAccess = true;
            }
        }
    }*/
    //Added by Anup - Aisera - End

    get options() {
        return [
            { label: 'My Open Cases', value: 'MyOpenCases' },
            { label: 'All Open Cases', value: 'AllOpenCases' },
            { label: 'Pending Action', value: 'PendingAction' },
            { label: 'Closed Cases', value: 'ClosedCases' }
        ];
    }
    handleMyOpenCases() {
        this.loading = true;
        this.value = 'MyOpenCases'
        this.handleChange();
        this.myopencasecss += ' highlight';
        this.allopencasecss = 'zs-all-open-case-card';
        this.pendingcss = 'zs-pending-case-card';
        this.closedcss = 'zs-closed-case-card';
    }
    handleAllOpenCases() {
        this.loading = true;
        this.value = 'AllOpenCases'
        this.handleChange();
        this.allopencasecss += ' highlight';
        this.myopencasecss = 'zs-my-open-case-card';
        this.pendingcss = 'zs-pending-case-card';
        this.closedcss = 'zs-closed-case-card';
    }
    handlePendingAction() {
        this.loading = true;
        this.value = 'PendingAction'
        this.handleChange();
        this.pendingcss += ' highlight';
        this.myopencasecss = 'zs-my-open-case-card';
        this.allopencasecss = 'zs-all-open-case-card';
        this.closedcss = 'zs-closed-case-card';
    }
    handleClosedCases() {
        this.loading = true;
        this.value = 'ClosedCases'
        this.handleChange();
        this.closedcss += ' highlight';
        this.myopencasecss = 'zs-my-open-case-card';
        this.allopencasecss = 'zs-all-open-case-card';
        this.pendingcss = 'zs-pending-case-card';
    }
    handleListView(event) {
        this.loading = true;
        this.value = event.detail.value;
        this.handleChange();
    }
    handleChange() {
        this.searchVal = '';
        this.searchResult = [];
        //this.caseData = this.caseDataTemp;
        // eslint-disable-next-line guard-for-in
        if (this.value == 'MyOpenCases') {
            this.caseData = this.allData.myCases;
            this.caseDataTemp = this.allData.myCases;
        }
        if (this.value == 'AllOpenCases') {
            this.caseData = this.allData.openCases;
            this.caseDataTemp = this.allData.openCases;
        }
        if (this.value == 'PendingAction') {
            this.caseData = this.allData.pendingCases;
            this.caseDataTemp = this.allData.pendingCases;
        }
        if (this.value == 'ClosedCases') {
            this.caseData = this.allData.closedCases;
            this.caseDataTemp = this.allData.closedCases;
        }
        
        this.caseData = JSON.parse(JSON.stringify(this.caseData));
        this.caseDataTemp = JSON.parse(JSON.stringify(this.caseDataTemp));
        var communityUrl = window.location.href;
        
        for(var casedata1 in this.caseData)  {
            this.caseData[casedata1].cs.Full_Community_URL__c = communityUrl+this.caseData[casedata1].cs.Community_url__c;
        }

        for(var casedata1 in this.caseDataTemp)  {
            this.caseDataTemp[casedata1].cs.Full_Community_URL__c = communityUrl+this.caseDataTemp[casedata1].cs.Community_url__c;
        }
        
        this.caseDataTotal = this.caseData;
        this.calculatepaginationparameters();
        this.loading = false;

    }
    redirectToCreateCase() {
        let pathArray = window.location.pathname.split('/');
        let portalname = pathArray[1];
        window.location = '/' + portalname + '/s/create-case';
        //CR 2891 Added by Chetan-Start
        if(portalname=='partners')
        {
            window.location.href = '/' + portalname + '/s/create-case?acc='+ this.accvalue;
            console.log(window.location.href);
            console.log('Redirect Executed');
        }
        //CR 2891 Added by Chetan-End
        else
        {
            window.location.href = '/' + portalname + '/s/create-case';
        }
    }
    handleSearchChange(event) {
        this.searchValue = event.detail.value;
        this.searchResult = [];
        this.caseData = [...this.caseDataTemp];
        for (let key in this.caseData) {
            
            if (this.searchValue && this.caseData && this.caseData[key] && this.caseData[key].cs && ((this.caseData[key].cs.Subject && this.caseData[key].cs.Subject.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.CaseNumber && this.caseData[key].cs.CaseNumber.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.Zendesk_Reference_Id__c && this.caseData[key].cs.Zendesk_Reference_Id__c.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.Account && this.caseData[key].cs.Account.Name && this.caseData[key].cs.Account.Name.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.Contact && this.caseData[key].cs.Contact.Name && this.caseData[key].cs.Contact.Name.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.Owner && this.caseData[key].cs.Owner.Name && this.caseData[key].cs.Owner.Name.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.Priority && this.caseData[key].cs.Priority.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.Status && this.caseData[key].cs.Status.toLowerCase().includes(this.searchValue.toLowerCase()))
                )){
                this.searchResult = [...this.searchResult, this.caseData[key]];
            }
        }
        //if(this.searchResult.length >0){
        if (this.searchValue) {
            this.caseData = [...this.searchResult];
        }
        this.caseDataTotal = [...this.caseData];
        this.calculatepaginationparameters();

        //}

    }
    @wire(retriveCases, { showallCases: '$allcases', AccountId: '$accvalue' })
    cases(results) {
        this.wiredResult = results;
        if (results.data) {
            this.allData = results.data;
            if (this.value == 'MyOpenCases') {
                this.caseData = results.data.myCases;
                this.caseDataTemp = results.data.myCases;
            }
            if (this.value == 'AllOpenCases') {
                this.caseData = results.data.openCases;
                this.caseDataTemp = results.data.openCases;
            }
            if (this.value == 'PendingAction') {
                this.caseData = results.data.pendingCases;
                this.caseDataTemp = results.data.pendingCases;
            }
            if (this.value == 'ClosedCases') {
                this.caseData = results.data.closedCases;
                this.caseDataTemp = results.data.closedCases;
            }
            this.caseData = JSON.parse(JSON.stringify(this.caseData));
            this.caseDataTemp = JSON.parse(JSON.stringify(this.caseDataTemp));
            var communityUrl = window.location.href;
            for(var casedata1 in this.caseData)  {
                    this.caseData[casedata1].cs.Full_Community_URL__c = communityUrl+this.caseData[casedata1].cs.Community_url__c;
            }

            for(var casedata1 in this.caseDataTemp)  {
                this.caseDataTemp[casedata1].cs.Full_Community_URL__c = communityUrl+this.caseDataTemp[casedata1].cs.Community_url__c;
            }

            this.caseDataTotal = this.caseData;
            this.myCases = results.data.myCasecount;
            this.selectedAccount = results.data.selectedAccountName;
            this.openCases = results.data.openCasecount;
            this.pcCases = results.data.pendingCasecount;
            this.closedCases = results.data.closedCasecount;
            this.error = undefined;
            this.loading = false;
            this.calculatepaginationparameters();
            if (!this.accvalue) {
                this.accountMap = results.data.accMap;
                this.accOptions = [];
                this.accvalue = this.accountMap[this.selectedAccount];
                for (let key in this.accountMap) {
                    if (key) {
                        this.accOptions.push({ label: key, value: this.accountMap[key] });
                    }
                }
            }
            this.accOptions = this.accOptions.sort(function(a, b){
                return a.label > b.label ? 1 : -1;          
              });

        }
        else if (results.error) {
            this.caseData = undefined;
            this.error = results.error;
            window.console.log(results.error);
            this.loading = false;
        }
    }

    calculatepaginationparameters() {
        this.showprevious = false;
        this.currentpage = 1;
        let records = [...this.caseDataTotal];
        let numofpages = records.length / this.MAX_NO_OF_RECORDS;
        this.pageoptions = [];
        if (numofpages > 1) {
            this.showpagination = true;
            this.shownext = true;
            for (let i = 1; i <= Math.ceil(numofpages); i++) {
                this.pageoptions.push({ label: '' + i, value: i });
            }
            this.slicepage(this.currentpage, records);
        } else {
            this.showpagination = false;
        }
    }

    slicepage(pagenum, records) {
        let totrec = [...records];
        this.caseData = totrec.slice((pagenum - 1) * this.MAX_NO_OF_RECORDS, pagenum * this.MAX_NO_OF_RECORDS);
    }

    gonext() {
        this.currentpage += 1;
        if (Math.ceil(this.caseDataTotal.length / this.MAX_NO_OF_RECORDS) == this.currentpage) {
            this.shownext = false;
        }
        this.showprevious = true;
        this.slicepage(this.currentpage, this.caseDataTotal);
    }
    goback() {
        this.currentpage -= 1;
        if (this.currentpage == 1) {
            this.showprevious = false;
        }
        this.shownext = true;
        this.slicepage(this.currentpage, this.caseDataTotal);
    }
    handlepagechange(event) {
        this.currentpage = event.detail.value ? Number(event.detail.value) : this.currentpage;
        if (this.currentpage == 1) {
            this.showprevious = false;
        } else {
            this.showprevious = true;
        }
        if (Math.ceil(this.caseDataTotal.length / this.MAX_NO_OF_RECORDS) == this.currentpage) {
            this.shownext = false;
        } else {
            this.shownext = true;
        }
        this.slicepage(this.currentpage, this.caseDataTotal);
    }


    handleaccchange(event) {
        this.searchVal = '';
        this.loading = true;
        if(event.detail.value){
            this.headerName = 'Existing Case Summary for ' + event.target.options.find(opt => opt.value === event.detail.value).label;
        }else{
            this.headerName = 'Existing Case Summary';
        }
        
        this.accvalue = event.detail.value;
        return refreshApex(this.wiredResult);
    }

    sortdata(event) {
        let column = event.target.title;
        
        if (this.sortfield != column) {
            this.sortOrder = '';
            this.sortfield = column;
        }

        this.caseData = this.sort(column, this.sortOrder == 'ASC' ? 'DESC' : 'ASC');
        this.caseDataTotal = this.caseData;
        this.calculatepaginationparameters();
    }
    sort(field, sortOrder) {
        this.sortOrder = sortOrder;
        let records = [...this.caseDataTotal];
        records.sort(function (a, b) {
            let t1 = a['cs'][field] == b['cs'][field],
                t2 = (!a['cs'][field] && b['cs'][field]) || (a['cs'][field] < b['cs'][field]);
            return t1 ? 0 : (sortOrder == 'ASC' ? -1 : 1) * (t2 ? 1 : -1);
        });
        return records;
    }

    // this method validates the data and creates the csv file to download
    downloadCSVFile() {  
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
        // getting keys from data
        this.caseDataTemp.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });
        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        csvString += '"Case Number","Account Name","Subject","Description","Case Category","Case Sub Category","Product","Priority","Requestor","Status","Case Owner","Last Activity","Date Time Opened","Date Time Closed","Case Type","Preferred Contact Time Zone"'; 
        csvString += rowEnd;        
        // main for loop to get the data based on key value
        for(let i=0; i < this.caseDataTemp.length; i++){
            let colValue = 0;

            csvString += this.caseDataTemp[i].cs.CaseNumber!=undefined ? '"'+this.caseDataTemp[i].cs.CaseNumber+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.Account.Name!=undefined ? '"'+this.caseDataTemp[i].cs.Account.Name+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.Subject!=undefined ? '"'+this.caseDataTemp[i].cs.Subject+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.Description!=undefined ? '"'+this.caseDataTemp[i].cs.Description+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.Case_Category__c!=undefined ? '"'+this.caseDataTemp[i].cs.Case_Category__c+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.Case_Sub_Category__c!=undefined ? '"'+this.caseDataTemp[i].cs.Case_Sub_Category__c+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.Product_New__c!=undefined ? '"'+this.caseDataTemp[i].cs.Product_New__c+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.Priority!=undefined ? '"'+this.caseDataTemp[i].cs.Priority+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.Contact_Name__c!=undefined ? '"'+this.caseDataTemp[i].cs.Contact_Name__c+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.Status!=undefined ? '"'+this.caseDataTemp[i].cs.Status+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.Owner.Name!=undefined ? '"'+this.caseDataTemp[i].cs.Owner.Name+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.LastModifiedDate!=undefined ? '"'+this.caseDataTemp[i].cs.LastModifiedDate+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.CreatedDate!=undefined ? '"'+this.caseDataTemp[i].cs.CreatedDate+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.ClosedDate!=undefined ? '"'+this.caseDataTemp[i].cs.ClosedDate+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.Case_Type__c!=undefined ? '"'+this.caseDataTemp[i].cs.Case_Type__c+'"' + ',' : "" + ',';
            csvString += this.caseDataTemp[i].cs.Preferred_Contact_Time_Zone__c!=undefined ? '"'+this.caseDataTemp[i].cs.Preferred_Contact_Time_Zone__c+'"' + ',' : "" + ',';
            csvString += rowEnd;
        }
        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        //downloadElement.download = 'Account Data.csv';
        downloadElement.download = this.selectedAccount+'-Cases.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
    }
}