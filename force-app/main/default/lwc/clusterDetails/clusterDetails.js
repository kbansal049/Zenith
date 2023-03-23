import { LightningElement, track, api , wire } from 'lwc';
import getALLClusterRecords from '@salesforce/apex/ClusterDetailsController.getALLClusterRecords';

const columns = [
    { label: 'Name', fieldName: 'name'},
    { label: 'SF Cloud', fieldName: 'sfCloud'},
    { label: 'Cloud', fieldName: 'cloud'},
];

export default class ClusterDetails extends LightningElement {
    @track clusterList =[];
    @track tempClusterList = [];
    @track intermediaryList = [];
    @track finalClusterList =[];
    @track clusterColumns = columns;

    get clusterOptions() {
        return [
            { label: 'Nanalog Clusters', value: 'Nanalog Clusters' },
            { label: 'Sandbox Clusters', value: 'Sandbox Clusters' },
            { label: 'SMCDSS DLP Clusters', value: 'SMCDSS DLP Clusters' }
        ];
    }

    get cloudOptions() {
        return [
            {label: 'Select', value: '' },
            { label: 'Zscaler.net', value: 'zscaler.net' },
            { label: 'Zscalerone.net', value: 'zscalerone.net' },
            { label: 'ZscalerTwo.net', value: 'zscalertwo.net' },
            { label: 'Zscalerbeta.net', value: 'zscalerbeta.net' },
            { label: 'Zscloud.net', value: 'zscloud.net' },
            { label: 'Zscalerthree.net', value: 'zscalerthree.net' },
            { label: 'ZPA Production', value: 'ZPA Production' },
            { label: 'ZPA Beta', value: 'ZPA Beta' },
            { label: 'Cloud Browser Isolation -Prod', value: 'Cloud Browser Isolation -Prod' },
            { label: 'Cloud Browser Isolation -Beta	', value: 'Cloud Browser Isolation -Beta' },
            { label: 'Posture Control Cloud', value: 'Posture Control Cloud	' },
            
        ];
    }

    connectedCallback(){
        this.getClusterRecords();
    }

    getClusterRecords(){
        console.log('getClusterRecords');
        getALLClusterRecords()
        .then(result=>{
            if(result){
                console.log('result',result);
                this.clusterList= result;
                this.finalClusterList = result;
            }
        })
        .catch(error=>{
            this.error = error;
        });
    }

    handleClusterTypeChange(event){
        this.tempClusterList = this.clusterList.filter(rec => rec.clusterObject && rec.clusterObject.includes(event.detail.value));
        this.intermediaryList = this.tempClusterList;
        this.finalClusterList = this.tempClusterList;
    }

    handleCloudTypeChange(event){
        var tempClusterList2 = [];
        this.tempClusterList = this.intermediaryList.filter(rec => rec.sfCloud && rec.sfCloud.toLowerCase().includes(event.detail.value));
        this.finalClusterList = this.tempClusterList;
    }

    
}