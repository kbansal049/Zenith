import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class CreateSalesOrderLines extends NavigationMixin(LightningElement) {

    @api salesOrderWrapper;
    @track oppRecord;
    @track isLoaded = false;


    @track activeSections = ["A", "B", "C"];

    // initialize component
    connectedCallback() {
        console.log('---CreateSalesOrderLines--connectedCallback--called---');
        //console.log('---CreateSalesOrderLines--connectedCallback--salesOrderWrapper---', JSON.stringify(this.salesOrderWrapper));
        if (this.salesOrderWrapper) {
            this.oppRecord = this.salesOrderWrapper.hasOwnProperty('opp') ? this.salesOrderWrapper['opp'] : undefined;
            //console.log('---CreateSalesOrderLines--connectedCallback--oppRecord---', this.oppRecord);
        }
    }

    handleOpportunityLoad(event) {
        console.log('---handleOpportunityLoad--called---');
        this.isLoaded = true;
    }

    handleOpportunitySubmit(event) {
        this.isLoaded = false;
        event.preventDefault();
        // Get data from submitted form
        let fields = event.detail.fields;
        console.log("--handleSubmit--", fields);

        // You need to submit the form after modifications
        this.template.querySelector("lightning-record-edit-form").submit(fields);
    }

    handleOpportunitySuccess(event) {
        console.log("onsuccess event recordEditForm", event.detail.id);
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.recordId = event.detail.id;
        this.fireToastEvent(
            "Success",
            "Record saved successfully, Moving to the Next Step",
            "success"
        );
        this.isLoaded = true;
    }

    handleOpportunityError(event) {
        this.isLoaded = true;
        console.log("onerror event recordEditForm", event);
    }


    handleDoNotOverRideACVChange(event) {
        console.log("---handleDoNotOverRideACVChange--called--", event);
        let changedVal = event.target.checked;
        console.log("---changedVal--", changedVal);

        // Creates the event with the contact ID data.
        let det = { field: 'nooverrideACV', value: changedVal };
        const changeEvent = new CustomEvent('changevalue', { detail: det });


        // Dispatches the event.
        this.dispatchEvent(changeEvent);
    }



    draftValues = [];

    handleSave(event) {
        let draftValues = event.detail.draftValues;
        console.log('---draftValues---', draftValues);

        // Creates the event with the contact ID data.
        const changeEvent = new CustomEvent('changeacv', { detail: draftValues });
        // Dispatches the event.
        this.dispatchEvent(changeEvent);

        this.draftValues = [];
    }

    handlePreviousStep() {
        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('changestage', { detail: '1' });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }


    handleCalculateACV() {
        console.log('---handleCalculateACV called---');
        const calculateACV = new CustomEvent('caculateacv');
        // Dispatches the event.
        this.dispatchEvent(calculateACV);
    }


    handleSubmitRequest() {
        console.log('---handleSubmitRequest called---');
        const calculateACV = new CustomEvent('submitrequest');
        // Dispatches the event.
        this.dispatchEvent(calculateACV);
    }


    handleOpportunityCancel() {

        console.log('---handleOpportunityCancel--called--');
        //console.log('---this.oppRecord--', JSON.stringify(this.oppRecord));
        if (this.oppRecord && this.oppRecord.Id) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.oppRecord.Id,
                    objectApiName: 'Opportunity',
                    actionName: 'view'
                }
            });
        }
    }

    get doNotOverRideACV() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('nooverrideACV') ? this.salesOrderWrapper.nooverrideACV : false;
    }


    get oppLoaded() {
        this.oppRecord = this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('opp') ? this.salesOrderWrapper.opp : undefined;
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('opp') ? true : false;
    }


    get oppRecordId() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('opp') ? this.salesOrderWrapper.opp.Id : '';
    }


    get productLines() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('lstfinallinestoNSwithoutinternallines') ? this.salesOrderWrapper.lstfinallinestoNSwithoutinternallines : undefined;
    }


    get hasInternalLines() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('lstfinallinestoNSwithInternalLines') && this.salesOrderWrapper.lstfinallinestoNSwithInternalLines.length > 0 ? true : false;
    }

    get productInternalLines() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('lstfinallinestoNSwithInternalLines') ? this.salesOrderWrapper.lstfinallinestoNSwithInternalLines : undefined;
    }

    get isFy21VolumeTier() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('isFy21VolumeTier') ? this.salesOrderWrapper.isFy21VolumeTier : false;
    }

    get shownewacv() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('shownewacv') ? this.salesOrderWrapper.shownewacv : false;
    }

    get showrenewalacv() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('showrenewalacv') ? this.salesOrderWrapper.showrenewalacv : false;
    }

    get showupsellacv() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('showupsellacv') ? this.salesOrderWrapper.showupsellacv : false;
    }

    get ifPartnerSummit() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('partnerSummit') && this.oppRecord.hasOwnProperty('Primary_Partner_Program__c')
            ? this.salesOrderWrapper.partnerSummit === this.oppRecord.Primary_Partner_Program__c : false;
    }

    get ifPartnerDiscount() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('partnerDiscount') && this.oppRecord.hasOwnProperty('Primary_Partner_Program__c')
            ? this.salesOrderWrapper.partnerDiscount === this.oppRecord.Primary_Partner_Program__c : false;
    }

    get ifPartnerMarginAdjustment() {
        return this.oppRecord.Partner_Margin_Adjustment__c != undefined ? this.oppRecord.Partner_Margin_Adjustment__c == true : false;
    }

    get ifShowBillToCustomerID(){
        return   this.oppRecord.Netsuite_Primary_Partner_ID__c != undefined && this.salesOrderWrapper.nsPartnerIdOverridden != undefined
        &&  this.salesOrderWrapper.nsPartnerIdOverridden == false? true : false; 
    }

    get ifShowBillToCustomerIDOverridden(){
        return this.salesOrderWrapper.nsPartnerIdOverridden != undefined &&  this.salesOrderWrapper.nsPartnerIdOverridden == true ? true : false;
    }

    get ifShowShipToCustomerID(){
        return   this.oppRecord.Netsuite_Customer_ID__c != undefined && this.salesOrderWrapper.nsCustomerIdOverridden != undefined 
        &&  this.salesOrderWrapper.nsCustomerIdOverridden == false? true : false; 
    }

    get ifShowShipToCustomerIDOverridden(){
        return this.salesOrderWrapper.nsCustomerIdOverridden != undefined &&  this.salesOrderWrapper.nsCustomerIdOverridden == true ? true : false;
    }


    get getLineColumns() {
        let columns = [];

        columns.push({
            label: 'Product Name',
            fieldName: 'productName',
            type: 'text',
            initialWidth: 300,
        });
        columns.push({
            label: 'SKU',
            fieldName: 'productCode',
            type: 'text',
            initialWidth: 150,
        });
        columns.push({
            label: 'Base Price',
            fieldName: 'basePrice',
            type: 'currency',
            initialWidth: 150,
        });
        columns.push({
            label: 'Quantity',
            fieldName: 'Qty',
            type: 'number',
            initialWidth: 90,
        });
        columns.push({
            label: 'Start Date',
            fieldName: 'StartDate',
            type: 'date',
            initialWidth: 150,
        });
        columns.push({
            label: 'End Date',
            fieldName: 'EndDate',
            type: 'date',
            initialWidth: 150,
        });
        columns.push({
            label: 'Term',
            fieldName: 'SellingTerm',
            type: 'number',
            initialWidth: 90,
        });
        columns.push({
            label: 'List Price',
            fieldName: 'ListPrice',
            type: 'currency',
            initialWidth: 150,
        });
        if (this.isFy21VolumeTier) {
            columns.push({
                label: 'Volume Discount',
                fieldName: 'volumeDiscount',
                type: 'currency',
                initialWidth: 150,
            });
        }
        columns.push({
            label: 'Discount',
            fieldName: 'discPercent',
            type: 'percent',
            initialWidth: 110,
        });
        columns.push({
            label: 'Net Price',
            fieldName: 'NetPriceOriginal',
            type: 'currency',
            initialWidth: 150,
        });
        columns.push({
            label: 'TCV (after Adjustment)',
            fieldName: 'NetPrice',
            type: 'currency',
            initialWidth: 200,
        });
        columns.push({
            label: 'ACV (after Adjustment)',
            fieldName: 'ACV',
            type: 'currency',
            initialWidth: 200,
        });

        if (this.shownewacv) {
            columns.push({
                label: 'NetSuite Override New TCV',
                fieldName: 'newTCV',
                type: 'currency',
                initialWidth: 250,
                editable: true
            });
        }

        if (this.showrenewalacv) {
            columns.push({
                label: 'NetSuite Override Renewal TCV',
                fieldName: 'RenewalTCV',
                type: 'currency',
                initialWidth: 250,
                editable: true
            });
        }

        if (this.showupsellacv) {
            columns.push({
                label: 'NetSuite Override Upsell TCV',
                fieldName: 'UpsellTCV',
                type: 'currency',
                initialWidth: 250,
                editable: true
            });
        }


        if (this.shownewacv) {
            columns.push({
                label: 'NetSuite Override New ACV',
                fieldName: 'newACV',
                type: 'currency',
                initialWidth: 250,
                editable: true
            });
        }

        if (this.showrenewalacv) {
            columns.push({
                label: 'NetSuite Override Renewal ACV',
                fieldName: 'RenewalACV',
                type: 'currency',
                initialWidth: 250,
                editable: true
            });
        }

        if (this.showupsellacv) {
            columns.push({
                label: 'NetSuite Override Upsell ACV',
                fieldName: 'UpsellACV',
                type: 'currency',
                initialWidth: 250,
                editable: true
            });
        }

        if (this.showupsellacv && this.showrenewalacv) {
            columns.push({
                label: 'Renewed From Contract Details',
                fieldName: 'contractDetailName',
                type: 'text',
                initialWidth: 250,
                editable: true
            });

            columns.push({
                label: 'Additional Contract Details',
                fieldName: 'addcontractDetailName',
                type: 'text',
                initialWidth: 250,
                editable: true
            });

        }


        //partnerDiscount
        if (this.ifPartnerDiscount) {
            columns.push({
                label: 'Deal Reg (Sourced) Discount',
                fieldName: 'drSourcedDiscount',
                type: 'currency',
                initialWidth: 220,
            });

            columns.push({
                label: 'Deal Reg (Teaming-Reseller) Discount',
                fieldName: 'drTeamingResellerDiscount',
                type: 'currency',
                initialWidth: 220,
            });

            columns.push({
                label: 'AW Discount',
                fieldName: 'awDiscount',
                type: 'percentage',
                initialWidth: 100,
            });

            columns.push({
                label: 'POV Discount',
                fieldName: 'povDiscount',
                type: 'percentage',
                initialWidth: 100,
            });

            columns.push({
                label: 'Fulfilment Discount',
                fieldName: 'fulDiscount',
                type: 'percentage',
                initialWidth: 100,
            });

            columns.push({
                label: 'Distributor Discount',
                fieldName: 'distributorDiscount',
                type: 'percentage',
                initialWidth: 100,
            });


            columns.push({
                label: 'Deployment Discount',
                fieldName: 'depDiscount',
                type: 'percentage',
                initialWidth: 100,
            });
        }

        if (this.ifPartnerMarginAdjustment) {
            columns.push({
                label: 'Partner Adjustment Type',
                fieldName: 'adjustType',
                type: 'text',
                initialWidth: 100,
            });

            columns.push({
                label: 'Partner Adjustment',
                fieldName: 'adjustValue',
                type: 'text',
                initialWidth: 100,
            });
        }

        if (this.ifPartnerDiscount) {
            columns.push({
                label: 'Co-sell Discount',
                fieldName: 'coCellDiscount',
                type: 'percentage',
                initialWidth: 100,
            });

            columns.push({
                label: 'Blended Discount',
                fieldName: 'blendedDiscount',
                type: 'percentage',
                initialWidth: 100,
            });

            columns.push({
                label: 'ACV',
                fieldName: 'aptsACV',
                type: 'currency',
                initialWidth: 100,
            });
            columns.push({
                label: 'MMR',
                fieldName: 'aptsMRR',
                type: 'currency',
                initialWidth: 100,
            });
        }
        return columns;
    }
}