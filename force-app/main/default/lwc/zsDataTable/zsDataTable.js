import LightningDatatable from 'lightning/datatable';
import richTextRenderer from './richTextRenderer.html';
import percentRenderer from './percentRenderer.html';
import dateTimeRenderer from './dateTimeRenderer.html';
export default class zsDataTable extends LightningDatatable {
    static customTypes = {
        richTextRenderer: {
            template: richTextRenderer,
            // Provide template data here if needed
        },
        percentRenderer: {
            template: percentRenderer,
            // Provide template data here if needed
        },
        dateTimeRenderer: {
            template: dateTimeRenderer,
            // Provide template data here if needed
        }
        //more custom types here
    };
    
}