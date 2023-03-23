import { LightningElement, wire,track,api } from 'lwc';
import getPOVProductListCrossPlatform from '@salesforce/apex/ProvisioningGroupController.getPOVProductListCrossPlatform';
import getALLProductSKUforTable from '@salesforce/apex/ProvisioningGroupController.getALLProductSKUforTable';
import { NavigationMixin } from 'lightning/navigation';
const DELAY = 300;
const columns = [
    { label: 'Product', fieldName: 'Name'},
    { label: 'Product Line', fieldName: 'Product_Line__c'},
    { label: 'SKU', fieldName: 'ProductCode'},
];

const addOnColumns = [
    { label: 'Product', fieldName: 'Name'},
    { label: 'Product Line', fieldName: 'Product_Line__c'},
    { label: 'SKU', fieldName: 'ProductCode'},
    { label: 'Auto Provisioning Status', fieldName: 'Auto_Provisioning_Status__c'},
];


export default class crossPlatformComponent extends NavigationMixin(LightningElement) {
    @api productLine;
    //@api initializeProductList;
    @api preSelectedProductsForCrossPlatform;
    @api preSelectedProducts;
    @track productSelectionMsg = true;
    @track selectedSKU=[];
    @track prodcodeList = [];
    @track selectedVal;
    @api selectedItemsList = [];
    @api selectedRadioProductrow;
    @api pgproduct;
    @track selectedRadioRow = [];
    @track selectedProductsUpdated = [];
    @track radioSelection;
    @track showPOVProdList = false; // flag to show or hide dataTable for POV Products on radio selection
    @track showaddondata=false;
    @track allSelectedProducts = [];
    @track prodList;
    @track selection = [];
    @api productSKUId;
    filteredRecords = [];
    crossPlatformSelectedProds =[];
    @track pocProductsColumns = columns;
    @track pocAddOnProductsColumns = addOnColumns;
    @api crossPlatform;
    @track preSelectedProductCrossPlatform =[];
    @api priceList;

    @api get selectedsku(){
        
        var skus = [];
        for(var i=0; i<this.pgproduct.length; i++){
            if(this.pgproduct[i].lineType == this.productLine){
                if(this.pgproduct[i].skuselectionId){
                    skus = this.pgproduct[i].skuselectionId;
                }
            }
        }
        console.log('skus'+skus);
        return skus;
    }
    @api get skulist(){
        var allskusList = [];
        this.crossPlatform.forEach(ele => {
            allskusList.push(ele);
            this.crossPlatformSelectedProds.push(ele.Id);
        });
        return allskusList;
    }
    handleRadioChange(event) {
        this.radioSelection = event.detail.value;
    }

    handlerowSelection(event) {
        var allskusList = [];
        for(var i=0; i<this.pgproduct.length; i++){
            if(this.pgproduct[i].lineType == this.productLine ){
                if(this.pgproduct[i].skuList){
                    allskusList = this.pgproduct[i].skuList;
                }
            }
        }
        allskusList = allskusList.filter((sku) => this.preSelectedProducts.includes(sku.Id));
        allskusList.forEach(ele => {
            this.selectedRadioRow = ele.Product_Line__c;
            this.selectedRadioProductrow = ele; 
            this.productSKUId = ele.Id;
        });
        
        const selectedEvent=new CustomEvent("skuvaluechange",{
            detail:this.selectedRadioProductrow
        });
        this.dispatchEvent(selectedEvent);
    }

    @api get selectedPOrow() {
        return this.selectedRadioProductrow;
    }

    get showSelectedItems(){
        return [...this.selectedItemsList,...this.crossPlatform];
    }

    @wire(getPOVProductListCrossPlatform, {
        criteria: '$selectedRadioRow', priceList: '$priceList'
    })
    processPOVProductList({error,data}) {
        if (data) {
            if (data.length > 0 || this.selectedRadioRow!=null) {
                this.showPOVProdList = true;
                if(data.length>0){
                    this.showaddondata=true;
                }else{
                    this.showaddondata=false;
                }
                console.log('@@@@data',data);
                this.prodList = data;
                this.filteredRecords = this.prodList;
                try{
                this.allSelectedProducts = this.pgproduct.filter(pgprod => pgprod.lineType === this.productLine)[0].selectedPOCProducts.map(ele => ele.Id);
                this.selectedItemsList = this.pgproduct.filter(pgprod => pgprod.lineType === this.productLine)[0].selectedPOCProducts;
                } catch(err){

                }
            } else {
                this.showPOVProdList = false;
            }
        }
        if (error) {
            console.log('fetch error ', error);
        }
    }

    get pocProductDatatableHeight() {
        return this.pocProductsColumns && this.pocProductsColumns.length > 4 ? "height: 300px;" : "height: 200px;";
    }

    get checkIfProductSelcetionMessageNeededtobeShown(){
        return this.selectedItemsList && this.selectedItemsList.length > 0 ? false : ( this.productSelectionMsg ? true : false);
    }

    renderedCallback(){
        if(this.allSelectedProducts && this.template.querySelector('[data-id="addonProductData"]') !=null){
           this.template.querySelector('[data-id="addonProductData"]').selectedRows = this.allSelectedProducts;
        }
    }

    handleSelectedPOCProducts(evt) {
        this.isDisabled=false;
        // List of selected items from the data table event.
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.allSelectedProducts);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();
        this.filteredRecords.map((ele) => {
            loadedItemsSet.add(ele.Id);
        });
        if (evt.detail.selectedRows) {
            evt.detail.selectedRows.map((ele) => {
                updatedItemsSet.add(ele.Id);
            });
            // Add any new items to the selection list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });
        }
        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });

        this.allSelectedProducts = [...selectedItemsSet];
        this.selectedItemsList = [...selectedItemsSet];
        this.addtoFinalAddonList();
        const selectedproduct= new CustomEvent("productvaluechange",{
            detail:{
                    "lineType":this.productLine,
                    "selectedItemsList":this.selectedItemsList
                }
        });
        this.dispatchEvent(selectedproduct);

    }

    addtoFinalAddonList(){
        if(this.allSelectedProducts){
            this.selectedItemsList = [];
            this.allSelectedProducts.forEach((prID) => {
                this.prodList.map((ele) => {
                    console.log('--filteredPovProdList ele--',ele);
                    if(ele.Id == prID ){
                        this.selectedItemsList.push(ele);
                    }
                });
            });
        }
    }

   removeAllItemsFromSelectedList(event) {
        this.allSelectedProducts = [];
        this.selectedItemsList = [];
        //303
        this.selectedRadioProductrow=[];
        var pgproductx = [];
        for(var i=0; i<this.pgproduct.length; i++){
            var product = {...this.pgproduct[i]};
            if(this.pgproduct[i].skuselectionId){
               product.skuselectionId=[];
            }
            pgproductx.push(product);
        }
        this.pgproduct = pgproductx;
    }

    prepareSelectedItemsList(passedRows) {
        let selectedProductIds = [];
        this.selectedProductsUpdated.forEach(ele => {
            selectedProductIds.push(ele.ProductID);
        });
        passedRows.forEach(ele => {
            if (!selectedProductIds.includes(ele.ProductID)) {
                this.selectedProductsUpdated.push({
                    ProductID: ele.ProductID,
                    ProductCode: ele.ProductCode,
                    ProductLine: ele.ProductLine,
                    prd: ele.prd,
                })
            }
        });
    }

    handleKeyChange(event) {
        const sKey = event.target.value;
        this.searchKey = sKey;
        if (sKey) {
            this.delayTimeout = setTimeout(() => {
                this.filteredRecords = this.prodList.filter(rec => JSON.stringify(rec).toLowerCase().includes(this.searchKey.toLowerCase()));
            }, DELAY);
            console.log('serach result' + this.filteredRecords);
        } else {
            this.filteredRecords = this.prodList;
            console.log('no reuslt filtered');
        }
    }
}