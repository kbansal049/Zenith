import { LightningElement, track } from 'lwc';
import getDataForExportingAll from '@salesforce/apex/DashBoardComponent.getDataForExportingAll';
export default class ParentDashboardComponent extends LightningElement {
  @track isShowParentOrderTrackerComponent = true;   // for hiding unhiding parent child component
  @track orderTrackerId;     // Id of order tracker
  @track isEmailTracker = 'Order Tracker Dashboard';   // type of tracker for handling mail chain component
  @track xlsHeader = []; // store all the headers of the the tables
  @track workSheetNameList = []; // store all the sheets name of the the tables
  @track xlsData = []; // store all tables data
  @track filename = "OrderTrackerDashboardReports.xlsx"; // Name of the file
  @track isBackButtonClicked = false;
  @track currentPage;
  @track currentPageqc;
  @track currentPageap;
  @track currentPageqr;
  @track currentPageReQr;

  connectedCallback() {
    getDataForExportingAll()
      .then(result => {
        // Data Preparation for Responed to Rep OR Cleared OR To Be Approved For Exporting
        var totalRespondObj = this.totalDataLineInReport(result.totalSumRespond, 'Respond');
        var newRespondData = this.createNewData(result.respond);
        var respondExportList = this.exportDataAccordingToStages(newRespondData, 'Respond');
        respondExportList.push(totalRespondObj);
        var respondHeader = ["Ticket","End User", "Region", "Proposal","SO","New/Upsell ACV", "Renewal ACV", "Total ACV", "TCV", "Reason For 5c","Opened Since","Last Status Change"];
        this.xlsFormatter(respondExportList, "POPendingwithSales", respondHeader);

        // Data Preparation for Order Pending QR for Exporting
        var totalOrderPendingObj = this.totalDataLineInReport(result.totalSumOrdersPending, 'notRespond');
        var newQRpendingData = this.createNewData(result.QRpending);
        var orderPendingExportList = this.exportDataAccordingToStages(newQRpendingData, 'notRespond');
        orderPendingExportList.push(totalOrderPendingObj);
        var orderPendingHeader = ["Ticket","End User","Region", "Proposal", "SO","New/Upsell ACV", "Renewal ACV", "Total ACV", "TCV", "Reason For 5c","Opened Since","Last Status Change"];
        this.xlsFormatter(orderPendingExportList, "POPendingforQR", orderPendingHeader);

        // Data Preparation for Approved for Processing ,Yet to be Processed for Exporting 
        var totalApprovedObj = this.totalDataLineInReport(result.totalSumApproved, 'notRespond');
        var newApprovedData = this.createNewData(result.Approved);
        var approvedExportList = this.exportDataAccordingToStages(newApprovedData, 'notRespond');
        approvedExportList.push(totalApprovedObj);
        var approvedExportHeader = ["Ticket","End User","Region", "Proposal", "SO","New/Upsell ACV", "Renewal ACV", "Total ACV", "TCV", "Reason For 5c","Opened Since","Last Status Change"];
        this.xlsFormatter(approvedExportList, "POPendingforBooking", approvedExportHeader);

        // Data Preparation for Total PO Pending for Exporting
        var totalPoPendingObj = this.totalDataLineInReport(result.totalSumPoPending, 'notRespond');
        var newPoPendingData = this.createNewData(result.POpending);
        var poPendingExportList = this.exportDataAccordingToStages(newPoPendingData, 'notRespond');
        poPendingExportList.push(totalPoPendingObj);
        var poPendingHeader = ["Ticket","End User","Region", "Proposal", "SO", "New/Upsell ACV", "Renewal ACV", "Total ACV", "TCV", "Reason For 5c","Opened Since","Last Status Change"];
        this.xlsFormatter(poPendingExportList, "POPendingForQC", poPendingHeader);

        // Data Preparation for Po pending for Re-Qr For Exporting
        var totalreQrObj = this.totalDataLineInReport(result.totalSumReqr, 'Respond');
        var newReqrData = this.createNewData(result.pendingReqr);
        var reQrExportList = this.exportDataAccordingToStages(newReqrData, 'Respond');
        reQrExportList.push(totalreQrObj);
        var reQrHeader = ["Ticket","End User", "Region", "Proposal","SO","New/Upsell ACV", "Renewal ACV", "Total ACV", "TCV", "Reason For 5c","Opened Since","Last Status Change"];
        this.xlsFormatter(reQrExportList, "POPendingforReQR", reQrHeader);

      })
      .catch(error => {

      })
  }

  createNewData(inputData){
      let newData = [];
      inputData.forEach(data => {
          let obj = {};
          obj.End_User__c = data.End_User__c;
          obj.Proposal_for_initiating_QC__c= data.Proposal_for_initiating_QC__c;
          obj.PO__c = data.PO__c;
          obj.SO__c =data.SO__c;
          obj.New_Upsell_ACV__c =data.New_Upsell_ACV__c;
          obj.Renewal_ACV__c =data.Renewal_ACV__c;
          obj.ACV__c = data.ACV__c;
          obj.TCV__c = data.TCV__c;
          obj.Id = data.Id;
          obj.relationData =data.Opportunity__r?.Reason_for_5C__c ? (data.Opportunity__r?.Reason_for_5C__c?.replace(/(<([^>]+)>)/ig, '')) : ' ';
          obj.opportunityId = data.Opportunity__r?.Id;
          obj.Ticket__c = data.Ticket__c;
          obj.Live_Status_Change_Time_Difference__c = data.Live_Status_Change_Time_Difference__c;
          obj.Opened_Since__c = data.Opened_Since__c;      
          newData.push(obj);
      });
      return newData;
  }    
  // formating the data to send as input to  xlsxMainToExportDashboards component
  xlsFormatter(data, sheetName, headers) {
    let Header = headers;
    this.xlsHeader.push(Header);
    this.workSheetNameList.push(sheetName);
    this.xlsData.push(data);
  }

  // calling the download function from xlsxMainToExportDashboards.js 
  download() {
    this.template.querySelector("c-xlsx-main-to-export-dashboards").download();
  }

  // To handle child dashboards 
  handleChildDashboard(event) {
    this.isShowParentOrderTrackerComponent = event.detail.showParent;
    this.orderTrackerId = event.detail.recordId;
    this.currentPage = event.detail.currentPage;
    this.currentPageqc = event.detail.currentPageqc;
    this.currentPageap = event.detail.currentPageap;
    this.currentPageqr = event.detail.currentPageqr;
    this.currentPageReQr = event.detail.currentPageReQr;
    if(!this.isShowParentOrderTrackerComponent){
      this.template.querySelector('.showParent').classList.add('slds-hide');
    }
  }
  handleNewEvent(event){
    this.currentPageap = event.detail.currentPageap;
  }

  // To handle mail chain components
  handleMailChainEvent(event) {
    this.isShowParentOrderTrackerComponent = event.detail;
    if(this.isShowParentOrderTrackerComponent){
      this.template.querySelector('.showParent').classList.remove('slds-hide');
    }
    this.isBackButtonClicked = event.detail.isBackButtonClicked;
    this.currentPage = event.detail.currentPage;
    this.currentPageqc = event.detail.currentPageqc;
    this.currentPageap = event.detail.currentPageap;
    this.currentPageqr = event.detail.currentPageqr;
    this.currentPageReQr = event.detail.currentPageReQr;
    let currentpageurl =  window.location.href;
    
    if(this.currentPage && this.currentPage.Ticket && this.currentPage.Ticket != undefined){
      window.location.href = currentpageurl + '#:~:text='+this.currentPage.Ticket;
    }
    if(this.currentPageqc && this.currentPageqc.Ticket && this.currentPageqc.Ticket != undefined){
      window.location.href = currentpageurl + '#:~:text='+this.currentPageqc.Ticket;
    }
    if(this.currentPageap && this.currentPageap.Ticket && this.currentPageap.Ticket != undefined){
      window.location.href = currentpageurl + '#:~:text='+this.currentPageap.Ticket;
    }
    if(this.currentPageqr && this.currentPageqr.Ticket && this.currentPageqr.Ticket != undefined){
      window.location.href = currentpageurl + '#:~:text='+this.currentPageqr.Ticket;
    }
    if(this.currentPageReQr && this.currentPageReQr.Ticket && this.currentPageReQr.Ticket != undefined){
      window.location.href = currentpageurl + '#:~:text='+this.currentPageReQr.Ticket;
    }
  }

  // to get all data for exporting with formatting
  exportDataAccordingToStages(arrOfData, strStage) {
    var varRespondData = arrOfData;
    var varRespondExportList = [];
    for (let respond of varRespondData) {
      var respondObj = {};
      respondObj.Ticket__c = respond.Ticket__c ? respond.Ticket__c : '';
      respondObj.End_User__c = respond.End_User__c ? respond.End_User__c : '';
      respondObj.Region__c = respond.Region__c ? respond.Region__c : '';
      respondObj.Proposal_for_initiating_QC__c = respond.Proposal_for_initiating_QC__c ? respond.Proposal_for_initiating_QC__c : '';
      respondObj.SO__c = respond.SO__c ? respond.SO__c : '';
      respondObj.New_Upsell_ACV__c = respond.New_Upsell_ACV__c ;
      respondObj.Renewal_ACV__c = respond.Renewal_ACV__c ;
      respondObj.ACV__c = respond.ACV__c ;
      respondObj.TCV__c = respond.TCV__c;
      respondObj.relationData = respond.relationData ? (respond.relationData.replace(/(<([^>]+)>)/ig, '')) : ' ';
      respondObj.Opened_Since__c = respond.Opened_Since__c;
      respondObj.Live_Status_Change_Time_Difference__c = respond.Live_Status_Change_Time_Difference__c;
        varRespondExportList.push(respondObj);
    }
    return varRespondExportList;
  }


  // To get total currencies for Total Row functionality
  totalDataLineInReport(totalSumArr, strStage) {
    var objTotal = {}
    objTotal.Ticket__c = '';
    objTotal.Reason_for_5C__c = '';
    objTotal.End_User__c = 'Total';
    objTotal.Region__c = ' ';
    objTotal.Proposal_for_initiating_QC__c = ' ';
    objTotal.SO__c = ' ';
    objTotal.New_Upsell_ACV__c = totalSumArr['upsell'];
    objTotal.Renewal_ACV__c = totalSumArr['renewal'];
    objTotal.ACV__c = totalSumArr['acv'];
    objTotal.TCV__c = totalSumArr['tcv'];

    return objTotal;
  }
  handleRefresh(event) {
    eval("$A.get('e.force:refreshView').fire();");
  }

}