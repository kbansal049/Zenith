import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import retriveCustomerDetails from '@salesforce/apex/CreateSalesOrderExtensionCPQLWC.getCustomerDetails';
import createCaseForOverride from '@salesforce/apex/CreateSalesOrderExtensionCPQLWC.doReview';

import { NavigationMixin } from "lightning/navigation";

export default class createSalesOrderOpportunityCPQ extends NavigationMixin(LightningElement) {

    @track oppRecord;
    @api salesOrderWrapper;
    @track error;
    @track hasError = false;
    @track isLoaded = false;

    @track activeSections = ["A", "B", "C", "D", "E", "F", "G", "H"];
    // initialize component
    connectedCallback() {
        console.log('---CreateSalesOrderOpportunity--connectedCallback--called---');
        console.log('---CreateSalesOrderOpportunity--connectedCallback--salesOrderWrapper---', this.salesOrderWrapper);
        if (this.salesOrderWrapper) {
            this.oppRecord = this.salesOrderWrapper.hasOwnProperty('opp') ? this.salesOrderWrapper['opp'] : undefined;
            console.log('---CreateSalesOrderOpportunity--connectedCallback--oppRecord---', this.oppRecord);
        }
    }

    handleOpportunityLoad(event) {
        console.log('---handleOpportunityLoad--called---');
        this.isLoaded = true;
    }


    handleCustomerDetails(event) {
        this.isLoaded = false;
        console.log('---handleCustomerDetails--called---');
        console.log('---handleCustomerDetails--this.oppRecord---', JSON.stringify(this.oppRecord));
        this.oppRecord = this.salesOrderWrapper.opp;
        retriveCustomerDetails({ opp: this.oppRecord })
            .then(result => {
                console.log('--result---', result);

                this.parseTheCustomerDetailWarpper(result);

                this.hasError = false;
                this.isLoaded = true;
            })
            .catch(error => {
                this.error = error;
                this.hasError = true;
                this.isLoaded = true;
            });
    }

    parseTheCustomerDetailWarpper(result) {

        console.log('---parseTheCustomerDetailWarpper--called---');

        this.oppRecord = this.salesOrderWrapper.opp;

        //Ship To
        let customerId = this.oppRecord.Netsuite_Customer_ID__c;
        let customerOverriddenId = this.oppRecord.Netsuite_Customer_ID_Override__c;

        //Bill To
        let partnerId = this.oppRecord.Netsuite_Primary_Partner_ID__c;
        let partnerOverriddenId = this.oppRecord.Netsuite_Primary_Partner_ID_Override__c;


        let partnerInternalOverriddenId = this.oppRecord.Netsuite_Partner_Internal_ID_Override__c;

        console.log('---customerId----', customerId);
        console.log('---customerOverriddenId----', customerId);
        console.log('---partnerId----', customerId);
        console.log('---partnerOverriddenId----', customerId);
        console.log('---partnerInternalOverriddenId----', partnerInternalOverriddenId);



        console.log('--result.length--', result.length);

        if (result.length > 0) {

            let billToDetails;
            let billToOverriddenDetails;
            let shipToDetails;
            let shipToOverriddenDetails;
            let partnerIdOverriddendetails;



            result.forEach(function (element) {
                console.log('--------for Each Starts----------');

                if (partnerId == element.id && element.type == 'customer') {
                    console.log('--------1----------');
                    billToDetails = element.id + ' - ' + element.name + ' - ' + element.entityId;
                } else if (partnerOverriddenId == element.id && element.type == 'customer') {
                    console.log('--------2----------');
                    billToOverriddenDetails = element.id + ' - ' + element.name + ' - ' + element.entityId;
                } else if (customerId == element.id && element.type == 'customer') {
                    console.log('--------3----------');
                    shipToDetails = element.id + ' - ' + element.name + ' - ' + element.entityId;
                } else if (customerOverriddenId == element.id && element.type == 'customer') {
                    console.log('--------4----------');
                    shipToOverriddenDetails = element.id + ' - ' + element.name + ' - ' + element.entityId;
                }
                if (partnerInternalOverriddenId == element.id && element.type == 'partner') {
                    console.log('--------5----------');
                    partnerIdOverriddendetails = element.id + ' - ' + element.name + ' - ' + element.entityId;
                }

                console.log('--------for Each Ends----------');
            });

            console.log('--------for Each Starts----------');
            console.log('--billToDetails--', billToDetails);
            console.log('--partnerbillToOverriddenDetailsId--', billToOverriddenDetails);
            console.log('--shipToDetails--', shipToDetails);
            console.log('--shipToOverriddenDetails--', shipToOverriddenDetails);
            console.log('--partnerIdOverriddendetails--', partnerIdOverriddendetails);


            if (billToDetails) {
                let det = { field: 'billToDetails', value: billToDetails };
                const changeEvent = new CustomEvent('changevalue', { detail: det });
                this.dispatchEvent(changeEvent);
            }
            if (billToOverriddenDetails) {
                let det = { field: 'billToOverriddenDetails', value: billToOverriddenDetails };
                const changeEvent = new CustomEvent('changevalue', { detail: det });
                this.dispatchEvent(changeEvent);
            }
            if (shipToDetails) {
                let det = { field: 'shipToDetails', value: shipToDetails };
                const changeEvent = new CustomEvent('changevalue', { detail: det });
                this.dispatchEvent(changeEvent);
            }
            if (shipToOverriddenDetails) {
                let det = { field: 'shipToOverriddenDetails', value: shipToOverriddenDetails };
                const changeEvent = new CustomEvent('changevalue', { detail: det });
                this.dispatchEvent(changeEvent);
            }
            if (partnerIdOverriddendetails) {
                let det = { field: 'partnerIdOverriddendetails', value: partnerIdOverriddendetails };
                const changeEvent = new CustomEvent('changevalue', { detail: det });
                this.dispatchEvent(changeEvent);
            }

        }

    }




    handleOpportunitySubmit(event) {
        this.isLoaded = false;
        event.preventDefault();
        // Get data from submitted form
        let fields = event.detail.fields;
        console.log("--handleSubmit--", JSON.stringify(fields));

        for (const property in fields) {
            console.log('${property}:', property, '- ${object[property]}-', fields[property]);
            this.dispatchEvent(new CustomEvent('changeoppwrapper', { detail: { field: property, value: fields[property] } }));
        }


        createCaseForOverride({ cow: this.salesOrderWrapper })
            .then(result => {
                console.log('--result---', result);

                this.hasError = false;

                if (result.isSuccess) {
                    // You need to submit the form after modifications
                    this.salesOrderWrapper = result.cow;
                    this.template.querySelector("lightning-record-edit-form").submit(fields);
                } else {
                    this.hasError = true;
                    this.error = result.errMsg;
                    this.isLoaded = true;
                }
            })
            .catch(error => {
                this.error = error;
                this.hasError = true;
                this.isLoaded = true;
            });
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

        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('changestage', { detail: '2' });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

        // Creates the event with the contact ID data.
        const reloadEvent = new CustomEvent('wrapperreload', {});

        // Dispatches the event.
        this.dispatchEvent(reloadEvent);

    }

    handleOpportunityError(event) {
        this.isLoaded = true;
        console.log("onerror event recordEditForm", event);
        this.error = event.detail ?  event.detail : 'Unknown Error Ocuured, please connect with administartor.';
        this.hasError = true;
    }

    handleOverrideBillToIdChange(event) {
        console.log('--handleOverrideBillToIdChange--called--');
        let changeVal = event.target.checked;
        let det = { field: 'overrideBillToId', value: changeVal };
        const changeEvent = new CustomEvent('changevalue', { detail: det });
        this.dispatchEvent(changeEvent);
    }

    handleOverridePartnerIdChange(event) {
        console.log('--handleOverridePartnerIdChange--called--');
        let changeVal = event.target.checked;
        let det = { field: 'overridePartnerId', value: changeVal };
        const changeEvent = new CustomEvent('changevalue', { detail: det });
        this.dispatchEvent(changeEvent);
    }

    handleoverrideShipToIdChange(event) {
        console.log('--handleoverrideShipToIdChange--called--');
        let changeVal = event.target.checked;
        let det = { field: 'overrideShipToId', value: changeVal };
        const changeEvent = new CustomEvent('changevalue', { detail: det });
        this.dispatchEvent(changeEvent);
    }

    handleBillToOverride(event) {
        console.log('--handleBillToOverride--called--');
        let changeVal = event.target.value;
        console.log('--changeVal--', changeVal);
        if (this.salesOrderWrapper.opp) {
            let det = { field: 'Netsuite_Primary_Partner_ID_Override__c', value: changeVal }
            const changeEvent = new CustomEvent('changeoppwrapper', { detail: det });
            this.dispatchEvent(changeEvent);
        }
    }

    handleInternalPartnerOverride(event) {
        console.log('--handleInternalPartnerOverride--called--');
        let changeVal = event.target.value;
        console.log('--changeVal--', changeVal);
        if (this.salesOrderWrapper.opp) {
            let det = { field: 'Netsuite_Partner_Internal_ID_Override__c', value: changeVal }
            const changeEvent = new CustomEvent('changeoppwrapper', { detail: det });
            this.dispatchEvent(changeEvent);
        }
    }

    handleShipToOverrideChange(event) {
        console.log('--handleShipToOverrideChange--called--');
        let changeVal = event.target.value;
        console.log('--changeVal--', changeVal);
        if (this.salesOrderWrapper.opp) {
            let det = { field: 'Netsuite_Customer_ID_Override__c', value: changeVal }
            const changeEvent = new CustomEvent('changeoppwrapper', { detail: det });
            this.dispatchEvent(changeEvent);
        }
    }


    handleOpportunityCancel() {
        console.log('---handleOpportunityCancel--called--');
        console.log('---this.oppRecord--', this.oppRecord);
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



    get oppLoaded() {
        this.oppRecord = this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('opp') ? this.salesOrderWrapper.opp : undefined;
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('opp') ? true : false;
    }


    get oppRecordId() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.hasOwnProperty('opp') ? this.salesOrderWrapper.opp.Id : '';
    }


    get shipToDetails() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.shipToDetails != undefined ? this.salesOrderWrapper.shipToDetails : '-';
    }

    get billToDetails() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.billToDetails != undefined ? this.salesOrderWrapper.billToDetails : '-';
    }

    get shipToOverriddenDetails() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.shipToOverriddenDetails != undefined ? this.salesOrderWrapper.shipToOverriddenDetails : '-';
    }

    get billToOverriddenDetails() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.billToOverriddenDetails != undefined ? this.salesOrderWrapper.billToOverriddenDetails : '-';
    }

    get partnerIdOverriddendetails() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.partnerIdOverriddendetails != undefined ? this.salesOrderWrapper.partnerIdOverriddendetails : '-';
    }

    get overrideBillToId() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.overrideBillToId != null ? this.salesOrderWrapper.overrideBillToId : false;
    }

    get overridePartnerId() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.overridePartnerId != null ? this.salesOrderWrapper.overridePartnerId : false;
    }

    get overrideShipToId() {
        return this.salesOrderWrapper != undefined && this.salesOrderWrapper.overrideShipToId != null ? this.salesOrderWrapper.overrideShipToId : false;
    }


    fireToastEvent(title, message, variant) {
        //Lightning Toast
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}