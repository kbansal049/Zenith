import LightningDatatable from 'lightning/datatable';
import customOTTLink from './ottDetailLink.html';

export default class CustomDashboardDataTable  extends LightningDatatable {
    static customTypes = {
        ottDetailView: {
            template: customOTTLink,
            standardCellLayout: true,
            typeAttributes: ['OTTName', 'OTTId'],
        },
    }
}