import { LightningElement,wire,api,track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
//import DealRegistrationMethod from '@salesforce/apex/THBApprovalProcessController.DealRegistrationProcessInstanceItems';
import retriveDealRegistration from '@salesforce/apex/THBApprovalProcessController.retriveDealRegistration';
import DealRegistration from '@salesforce/apex/THBApprovalProcessController.DealRegistration';

export default class DealRegistraionProcessInstanceList extends LightningElement {
    /*@track Columns = [
        { label: 'Assigned To', fieldName: 'OriginalActorId',type:'url',typeAttributes:{label: {fieldName:'OriginalActorName'},target:'_blank'}, sortable: "true"},
        { label: 'Actual Approver', fieldName: 'ActorId',type:'url',typeAttributes:{label: {fieldName:'ActorName'},target: '_blank' }, sortable: "true"},
        { label: 'Record', fieldName: 'targetObjId',type:'url',typeAttributes:{label: {fieldName:'targetObjName'},target: '_blank' }, sortable: "true"},
        { label: 'Status', fieldName: 'status', sortable: "true"}
    ];*/
    
    error;
    @api strAccName = '';
    @track processInstanceList;
    @track sortBy;
    @track sortDirection = 'ASC';
    @track objectInfo ;
    @track myMap = {};
    @track dealrecord;
    result;


    /*@wire(DealRegistrationMethod)
    processInstanceItems({ error, data }) {
        if (data) {
            this.processInstanceList = [];
            data.forEach(InstanceRec => {
                let processInstanceRec = {};
                processInstanceRec.Id = InstanceRec.Id;
                processInstanceRec.ActorId = '/'+InstanceRec.ActorId;
                processInstanceRec.ActorName = InstanceRec.Actor.Name;
                processInstanceRec.OriginalActorId = '/'+InstanceRec.OriginalActorId;
                processInstanceRec.OriginalActorName = InstanceRec.OriginalActor.Name;
                processInstanceRec.targetObjId = '/'+InstanceRec.ProcessInstance.TargetObjectId;
                processInstanceRec.targetObjName = InstanceRec.ProcessInstance.TargetObject.Name;
                processInstanceRec.status = InstanceRec.ProcessInstance.Status;
                this.processInstanceList.push(processInstanceRec);
            });
            console.log(this.processInstanceList);
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }*/
    @wire(DealRegistration)
    setObjectInfo({error, data}) {
        if (data) {
            this.objectInfo = [];
            data.forEach(InstanceRec => {
                this.dealrecord = {};
                this.dealrecord.Id = InstanceRec.Id;
                this.dealrecord.Region = InstanceRec.Area__c;
                this.dealrecord.Area = InstanceRec.Sub_Region__c;
                this.objectInfo.push(this.dealrecord);

                this.myMap[this.dealrecord.Id] = this.dealrecord;
            });
        this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(retriveDealRegistration,{strAccName: '$strAccName'})
        processInstanceItems({ error, data }) {
        if (data) {
            this.processInstanceList = [];
            data.forEach(InstanceRec => {
                let processInstanceRec = {};
                processInstanceRec.Id = '/'+InstanceRec.Id+'/e?et=REASSIGN&retURL=/'+InstanceRec.ProcessInstance.TargetObjectId;
                processInstanceRec.Id1 = '/p/process/ProcessInstanceWorkitemWizardStageManager?id='+InstanceRec.Id;
                processInstanceRec.ActorId = '/'+InstanceRec.ActorId;
                processInstanceRec.ActorName = InstanceRec.Actor.Name;
                processInstanceRec.OriginalActorId = '/'+InstanceRec.OriginalActorId;
                processInstanceRec.OriginalActorName = InstanceRec.OriginalActor.Name;
                processInstanceRec.targetObjId = '/'+InstanceRec.ProcessInstance.TargetObjectId;
                processInstanceRec.targetObjName = InstanceRec.ProcessInstance.TargetObject.Name;
                processInstanceRec.status = InstanceRec.ProcessInstance.Status;
                processInstanceRec.Action = ' Approve/Reject';
                processInstanceRec.Action2 = 'Reassign |';
                let PID = InstanceRec.ProcessInstance.TargetObjectId;
                if(this.myMap!=undefined){
                    if(this.myMap[PID].Region!=''){
                        processInstanceRec.Region = this.myMap[PID].Region;
                    }
                    if(this.myMap[PID].Area!=''){
                        processInstanceRec.Area = this.myMap[PID].Area;
                    }
                }
                
                this.processInstanceList.push(processInstanceRec);
                
            });
            this.error = undefined;
        } else if (error) {
            this.error = 'No Deal registered for entered region';
        }
    }

    doSorting(event) {
        let column = event.target.title;
        if (this.sortBy != column) {
            this.sortDirection = '';
            this.sortBy = column;
        }
        console.log('column' + JSON.stringify(event.target));
        console.log('event' + column);
        this.sortData(this.sortBy, this.sortDirection == 'ASC' ? 'DESC' : 'ASC');
        console.log('this.sortData'+this.sortData);
        console.log('this.sortBy'+this.sortBy);
    }
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.processInstanceList));
        // Return the value stored in the field
        let keyValue = (a) => {
        return a[fieldname];
        
        };
        this.sortDirection = direction;
        // cheking reverse direction
        let isReverse = direction === 'ASC' ? -1: 1;
        // sorting data
        parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; // handling null values
        y = keyValue(y) ? keyValue(y) : '';
        // sorting values based on direction
        return isReverse * ((x > y) - (y > x));
        });
        
        this.processInstanceList = parseData;
    }


    handleKeyChange( event ) {
        this.strAccName = event.target.value;
        return refreshApex(this.result);
    }

}