import { LightningElement,api,wire } from 'lwc';
import getSurveyRecords from '@salesforce/apex/ServiceQualityAuditLWCCtrl.getSurveyRecords';
import {loadStyle} from 'lightning/platformResourceLoader';
import COLORS from '@salesforce/resourceUrl/serviceQualityAuditLWCColors';
import ColorGreen from '@salesforce/label/c.ColorGreen';
import ColorRed from '@salesforce/label/c.ColorRed';
import ColorYellow from '@salesforce/label/c.ColorYellow';


const COLUMNS = [
    /*{label: 'Name', fieldName: 'NameURL', type: 'url',
    typeAttributes: {
        label: {
            fieldName: 'Name'
        },
        target:'_blank'
    }, cellAttributes:{class:{fieldName:'colorCode'}}},*/
    {label: 'Audit Engineer Name', fieldName: 'NameURL', type: 'url',
    typeAttributes: {
        label: {
            fieldName: 'AuditEngineerName'
        },
        target:'_blank'
    }, cellAttributes:{class:{fieldName:'colorCode'}}},
    //{label:'Audit Engineer Name', fieldName:'Audit_Engineer_Name__r.Name', type:'url', cellAttributes:{class:{fieldName:'colorCode'}}},
    {label:'Engineer\'s Case Audit Score', fieldName:'Engineer_s_Case_Work_Audit_Score__c', type:'percent', cellAttributes:{alignment: 'left',class:{fieldName:'colorCode'}}},
];

export default class ServiceQualityAuditLWC extends LightningElement {
    @api recordId;

    tableData;
    columns = COLUMNS;
    isCssLoaded = false;

    /*@wire(getSurveyRecords)
    surveyHandler({data, error}){ 
        if(data){ 
            console.log("##data::", data);
            this.tableData = data.map(item=>{
                let colorCode;
                if(item.Engineer_s_Case_Work_Audit_Score__c >= 90) {
                    colorCode = "datatable-green";
                }
                else if(item.Engineer_s_Case_Work_Audit_Score__c < 90 && item.Engineer_s_Case_Work_Audit_Score__c>=70){
                    colorCode = "datatable-yellow";
                }
                else if(item.Engineer_s_Case_Work_Audit_Score__c < 70 ){
                    colorCode = "datatable-red";
                }
                return {...item, 
                    "colorCode":colorCode,
                    "NameURL":'/lightning/r/Survey__c/' +item['Id'] +'/view',
                    //"AuditEngineerName" : item.Audit_For_Engineer__r.Name
                }
            })
            console.log(this.tableData)
        }
        if(error){
            console.error(error)
        }
    }*/

    getSurveyRecordsHandler(){
        //clearInterval(this.timeIntervalInstance);
        getSurveyRecords({recordId : this.recordId})
        .then(result => {
            if(result) {
                console.log("##", result);
                console.log('Color Green ->' + ColorGreen);
                this.tableData = result.map(item=>{
                    let colorCode;
                    console.log('Color Green ->' + item.Engineer_s_Case_Work_Audit_Score__c);
                    console.log('Color Green ->' + parseInt(ColorGreen));
                    if(item.Engineer_s_Case_Work_Audit_Score__c >= parseInt(ColorGreen)) {
                        console.log('Inside Color Green ->');
                        colorCode = "datatable-green";
                    }
                    else if(item.Engineer_s_Case_Work_Audit_Score__c < parseInt(ColorYellow) && item.Engineer_s_Case_Work_Audit_Score__c>=parseInt(ColorRed)){
                        console.log('Inside Color Yellow ->');

                        colorCode = "datatable-yellow";
                    }
                    else if(item.Engineer_s_Case_Work_Audit_Score__c < parseInt(ColorRed) ){
                        console.log('Inside Color Red ->');
                        colorCode = "datatable-red";
                    }
                    return {...item, 
                        "colorCode":colorCode,
                        "NameURL":'/lightning/r/Survey__c/' +item['Id'] +'/view',
                        "AuditEngineerName" : item.Audit_For_Engineer__r.Name,
                        "Engineer_s_Case_Work_Audit_Score__c":item.Engineer_s_Case_Work_Audit_Score__c/100                    }
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