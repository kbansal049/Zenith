import { LightningElement, api, track } from "lwc";
/* eslint-disable no-console */
export default class Paginator extends LightningElement {
  @api totalRecords;
  @api currentPageNumber;
  @api pageSize;

  @track paginationList = [];
  @track paginationRange = [];
  @track totalPages;

  connectedCallback() {
    this.calculatePaginationAttributes();
  }

  @api updateAttributesfromParent(tr, cpn, ps) {
    this.totalRecords = tr;
    this.currentPageNumber = cpn;
    this.pageSize = ps;
    this.calculatePaginationAttributes();
  }

  calculatePaginationAttributes() {
    this.paginationList = [];
    this.paginationRange = [];
    //looking at displaying 3 recrods per page
    const paginationNumbers = Math.ceil(this.totalRecords / this.pageSize);
    this.totalPages = paginationNumbers;
    let i = 1;
    //create an array with size equals to paginationNumbers
    while (
      this.paginationRange.push(i++) < paginationNumbers
      // eslint-disable-next-line no-empty
    ) { }

    //console.log("paginationRange --", this.paginationRange);

    let pageList = new Array();
    this.paginationRange.forEach(element => {
      if (element === this.currentPageNumber) {
        pageList.push({
          key: element,
          value: element,
          isSelected: true
        });
      } else {
        pageList.push({
          key: element,
          value: element,
          isSelected: false
        });
      }
    });
    this.paginationList = pageList;
  }

  handlePageChange(event) {
    event.preventDefault();
    const s_value = event.target.value;
    this.currentPageNumber = s_value;
    this.updatePaginationList();
    this.dispachPageChangeEvent();
  }

  previousPageHandler() {
    if (this.currentPageNumber > 0) {
      this.currentPageNumber = Number(this.currentPageNumber) - 1;
      this.updatePaginationList();
      this.dispachPageChangeEvent();
    }
  }

  nextPageHandler() {
    //console.log("--nextPageHandler called --");
    if (this.currentPageNumber < this.totalPages) {
      this.currentPageNumber = Number(this.currentPageNumber) + 1;
      this.updatePaginationList();
      this.dispachPageChangeEvent();
    }
  }

  dispachPageChangeEvent() {
    const selectedEvent = new CustomEvent("selectedpage", {
      detail: this.currentPageNumber
    });
    console.log('inside dispatch');
    this.dispatchEvent(selectedEvent);
  }

  @api
  get showPrevious() {
    //console.log("showPrevious called --");
    return this.currentPageNumber > 1 ? true : false;
  }
  @api
  get showDropDown() {
    //console.log("showPrevious called --");
    return this.paginationList.length > 1;
  }

  @api
  get showNext() {
    //console.log("showNext called --");
    return this.currentPageNumber < this.totalPages ? true : false;
  }


  updatePaginationList() {
    console.log("updatePaginationList called --");
    //console.log("this.currentPageNumber --",this.currentPageNumber);
    let pageList = new Array();
    this.paginationList.forEach(ele => {
      if (ele.value == this.currentPageNumber) {
        pageList.push({
          key: ele.key,
          value: ele.value,
          isSelected: true
        });
      } else {
        pageList.push({
          key: ele.key,
          value: ele.value,
          isSelected: false
        });
      }
    });
    this.paginationList = pageList;
    console.log(this.paginationList);
    //console.log("updatePaginationList called --",JSON.stringify(this.paginationList));
  }
}