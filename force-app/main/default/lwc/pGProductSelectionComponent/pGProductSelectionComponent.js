import { LightningElement, wire,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPOVProductList from '@salesforce/apex/ProvisioningGroupController.getPOVProductList';

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

export default class PGProductSelectionComponent extends NavigationMixin(LightningElement) {
    @api productLine;
    @api pgproduct;
    @api productSKUId;
    @api selectedItemsList = [];
    @api selectedRadioProductrow;
    @api priceList;
    
    @track productSelectionMsg = true;
    @track prodcodeList = [];
    @track selectedSKU = [];
    @track selectedVal;
    @track selectedRadioRow = [];
    @track selectedProductsUpdated = [];
    @track radioSelection;

    //flag to show or hide dataTable for POV Products on radio selection
    @track showPOVProdList = false; 

    @track showaddondata = false;
    @track allSelectedProducts = [];
    @track prodList;
    @track selection = [];

    filteredRecords = [];

    //POV Screen Products Columns
    @track pocProductsColumns = columns;
    @track pocAddOnProductsColumns = addOnColumns;

    @api get selectedsku(){
        var skus = [];
        for(var i=0; i<this.pgproduct.length; i++){
            if(this.pgproduct[i].lineType == this.productLine){
                if(this.pgproduct[i].skuselectionId){
                    skus = this.pgproduct[i].skuselectionId;
                }
            }
        }
        return skus;
    }

    @api get skulist(){
        console.log('inside skulist');
        var allskusList = [];
        for(var i=0; i<this.pgproduct.length; i++){
            console.log('.pgproduct[i].lineType'+this.pgproduct[i].lineType);
            if(this.pgproduct[i].lineType == this.productLine){
                if(this.pgproduct[i].skuList){
                    allskusList = this.pgproduct[i].skuList;
                }
            }
        }
        return allskusList;
    }

    handleRadioChange(event) {
        this.radioSelection = event.detail.value;
        console.log("this.radioSelection" , this.radioSelection);
    }

    handlerowSelection(event) {
        this.selectedRadioRow = event.detail.selectedRows[0].Product_Line__c;
        this.selectedRadioProductrow = event.detail.selectedRows[0];
        this.productSKUId = event.detail.selectedRows[0].Id;
        const selectedEvent=new CustomEvent("skuvaluechange",{
            detail:this.selectedRadioProductrow
        });
        this.dispatchEvent(selectedEvent);
        this.showPOVProdList = true;
        console.log('handlerowSelection----> this.selectedRadioRow: ', JSON.stringify(this.selectedRadioRow));
    }

    @api get selectedPOrow() {
        return this.selectedRadioProductrow;
    }

    get showSelectedItems(){
        return [...this.selectedItemsList,this.selectedRadioProductrow];
    }

    @wire(getPOVProductList, {criteria: '$selectedRadioRow' , priceList: '$priceList'})
    processPOVProductList({error,data}) {
        console.log('processPOVProductList----> this.productLine: ', JSON.stringify(this.productLine));
        console.log('processPOVProductList----> this.pgproduct: ', JSON.stringify(this.pgproduct));
        console.log('processPOVProductList----> this.selectedRadioRow: ', JSON.stringify(this.selectedRadioRow));
        if (data) {
             console.log('processPOVProductList----> data', JSON.stringify(data));
            if (data.length > 0 || this.selectedRadioRow != null) {
                this.showPOVProdList = true;
                if(data.length>0){
                    this.showaddondata=true;
                }else{
                    this.showaddondata=false;
                }
                this.prodList = data;
                this.filteredRecords = this.prodList;
                try{
                this.allSelectedProducts = this.pgproduct.filter(pgprod => pgprod.lineType === this.productLine)[0].selectedPOCProducts.map(ele => ele.Id);
                this.selectedItemsList = this.pgproduct.filter(pgprod => pgprod.lineType === this.productLine)[0].selectedPOCProducts;
                } catch(err){

                }
            } else {
                //code for no data table rows returned
                this.showPOVProdList = false;
            }
        }
        if (error) {
            console.log('processPOVProductList----> error: ' + JSON.stringify(error));
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
        console.log('this.finalAddOnList---'+JSON.stringify(this.finalAddOnList));
    }

    removeAllItemsFromSelectedList(event) {
        this.allSelectedProducts = [];
        this.selectedItemsList = [];
        //303
        this.showPOVProdList = false;
        this.selectedRadioProductrow=null;
        var pgproductx = [];
        for(var i=0; i<this.pgproduct.length; i++){
            var product = {...this.pgproduct[i]};
            if(this.pgproduct[i].skuselectionId){
               product.skuselectionId=[];
            }
            pgproductx.push(product);
        }
        this.pgproduct = pgproductx;
        
        /*const unselectedproduct= new CustomEvent("removeallproductclicked",{
            detail:{
                   
                }
        });
        this.dispatchEvent(unselectedproduct);*/
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