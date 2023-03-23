import LightningDatatable from 'lightning/datatable';
/*
    import all supporting components like picklist, image,fileUpload, customLookup
*/
import GenericRecordLookupTemplate from './lookupfield-template.html';

export default class CustomDataTable extends LightningDatatable {
    static customTypes = {
        lookup: {
            template: GenericRecordLookupTemplate,
            standardCellLayout: true,
            typeAttributes: ['label', 'value', 'placeholder', 'fieldName', 'object', 'context', 'variant', 'name', 'fields', 'target', 'inlineEditing']
        },

        // fileUpload: {
        //     template: FileUploadTemplate,
        //     typeAttributes: ['acceptedFormats', 'doUpload']
        // },        
        // picklist: {
        //     template: picklistTemplate,
        //     typeAttributes: ['label', 'placeholder', 'options', 'parentrecord', 'showEdit'],
        // },
        // image: {
        //     template: imageTemplate,
        //     typeAttributes: ['alttxt', 'width', 'height'],
        // },
    };
}