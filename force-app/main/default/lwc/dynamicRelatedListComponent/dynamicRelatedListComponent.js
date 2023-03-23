import { LightningElement, api, wire, track } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import relatedlistcss from "@salesforce/resourceUrl/Service_360_css";
import { loadStyle } from "lightning/platformResourceLoader";

export default class dynamicRelatedListComponent extends LightningElement {
  @api objectName;
  @api childRelFieldAPIName;
  @api childRelFieldValue;
  @api parentRelFieldAPIName;
  @api recordId;
  @api strTitle;
  @api filterCriteia;
  @api showMoreActions;
  @api showRowActions;
  @api allowInlineEdit;
  @api recordActionObj;
  @api fieldSet;
  @api showStandardView;
  @api showStandardEdit;
  @api showStandardDelete;
  @api showNew;
  @api newRT;
  @api numofrecords;
  @api showAccordion;
  @api showExpanded;
  @api showCustomstyle;
  @api defparams;

  //Added for Edit and view Action
  @api actionFieldSetName;
  @api actionFieldSetNameEdit;

  @api showCustomAction;
  @api actionName;

  @api showUnselectAll; //Added by Anup- CR#1477
  
  @track customStyle;

  showcreatenew = false;
  @wire(getObjectInfo, { objectApiName: "$objectName" })
  objectInfo;

  connectedCallback() {
    console.log(this.showCustomstyle);
    console.log("inside connectedofrelated");
    this.customStyle = "dynamic-related-list";
    if (this.showCustomstyle) {
      loadStyle(this, relatedlistcss + "/css/dynamic-related-list.css");
    }
  }

  createNewRec(event) {
    console.log("inside create new rec");
    if (
      this.objectInfo &&
      this.objectInfo.data &&
      this.objectInfo.data.recordTypeInfos
    ) {
      const rtis = this.objectInfo.data.recordTypeInfos;
      this.recordTypeId = Object.keys(rtis).find(
        (rti) => rtis[rti].name === this.newRT
      );
    } else if (this.objectInfo && this.objectInfo.data) {
      this.recordTypeId = "$objectInfo.data.defaultRecordTypeId";
    }
    this.showcreatenew = true;
  }
  handleCreateCancel(event) {
    console.log("inside cancel");
    this.showcreatenew = false;
  }

  handleCreateSave(event) {
    console.log("inside handleCreateSave");
    this.showcreatenew = false;
    if(this.template.querySelector("c-dynamic-table-component")!=null && this.template.querySelector("c-dynamic-table-component")!=undefined){
      this.template.querySelector("c-dynamic-table-component").refreshapex();
    }
  }
  assignparentId(event) {
    this.childRelFieldValue = event.detail;
  }
  expand(event) {
    this.showExpanded = true;
  }
  collapse(event) {
    this.showExpanded = false;
  }
  
  @api
  refreshdata(event) {
    this.template.querySelector("c-dynamic-table-component").refreshapex();
  }

  handleCustomAction(event) {
    const custAction = new CustomEvent("customaction", {
      detail: {
        actionName: this.actionName,
        records: JSON.parse(JSON.stringify(this.template.querySelector("c-dynamic-table-component").getTotalrecords()))
      },
      bubbles: true,
      composed: true
    });
    this.dispatchEvent(custAction);
  }

  //Added By Anup : CR#1477 - Start
  handleUnselectAll(event) {
    const custAction1 = new CustomEvent("customaction1", {
      detail: {
        actionName: 'Unselect All',
        records: JSON.parse(JSON.stringify(this.template.querySelector("c-dynamic-table-component").getTotalrecords()))
      },
      bubbles: true,
      composed: true
    });
    this.dispatchEvent(custAction1);
  }
  //Added By Anup : CR#1477 - End
}