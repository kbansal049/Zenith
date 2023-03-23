import { LightningElement,api,wire } from 'lwc';
import getSurveyRecords from '@salesforce/apex/ServiceQualityAuditLWCCtrl.getTAMAuditRecords';
import {loadStyle} from 'lightning/platformResourceLoader';
import COLORS from '@salesforce/resourceUrl/serviceQualityAuditLWCColors';
import ColorGreen from '@salesforce/label/c.ColorGreen';
import ColorRed from '@salesforce/label/c.ColorRed';
import ColorYellow from '@salesforce/label/c.ColorYellow';


const COLUMNS = [
    {label: 'TAM Meeting Owner', fieldName: 'NameURL', type: 'url',
    typeAttributes: {
        label: {
            fieldName: 'AuditEngineerName'
        },
        target:'_blank'
    }, cellAttributes:{class:{fieldName:'colorCode'}}},
    {label:'TAM Weekly Audit Score', fieldName:'TAM_Weekly_Audit_Score__c', type:'percent', cellAttributes:{alignment: 'left',class:{fieldName:'colorCode'}}},
];

export default class tamMeetingAuditLWC extends LightningElement {
    @api recordId;

    tableData;
    columns = COLUMNS;
    isCssLoaded = false;

    getSurveyRecordsHandler(){
        getSurveyRecords({recordId : this.recordId})
        .then(result => {
            if(result) {
                console.log("##", result);
                console.log('Color Green ->' + ColorGreen);
                this.tableData = result.map(item=>{
                    let colorCode;
                    console.log('Color Green ->' + item.TAM_Weekly_Audit_Score__c);
                    console.log('Color Green ->' + parseInt(ColorGreen));
                    if(item.TAM_Weekly_Audit_Score__c >= parseInt(ColorGreen)) {
                        console.log('Inside Color Green ->');
                        colorCode = "datatable-green";
                    }
                    else if(item.TAM_Weekly_Audit_Score__c < parseInt(ColorYellow) && item.TAM_Weekly_Audit_Score__c>=parseInt(ColorRed)){
                        console.log('Inside Color Yellow ->');

                        colorCode = "datatable-yellow";
                    }
                    else if(item.TAM_Weekly_Audit_Score__c < parseInt(ColorRed) ){
                        console.log('Inside Color Red ->');
                        colorCode = "datatable-red";
                    }
                    return {...item, 
                        "colorCode":colorCode,
                        "NameURL":'/lightning/r/Survey__c/' +item['Id'] +'/view',
                        "AuditEngineerName" : item.Audit_For_Engineer__r.Name,
                        "TAM_Weekly_Audit_Score__c":item.TAM_Weekly_Audit_Score__c/100                    }
                })
            }
        })
        .catch(error => {});
    }


    connectedCallback() {
        this.getSurveyRecordsHandler();
    }

    refreshCall() {
        this.getSurveyRecordsHandler();
    }
    

    renderedCallback(){ 
        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(()=>{
            console.log("Loaded Successfully")
        }).catch(error=>{ 
            console.error("Error in loading the colors")
        })
    }

}