import { LightningElement,api,track } from 'lwc';
import { OmniscriptBaseMixin } from "%vlocity_namespace%/omniscriptBaseMixin";

export default class Cci_ViewLineItemDetails extends OmniscriptBaseMixin(LightningElement){
    @track displayRows = [];
    @track showModal = false;
    @track selectedRow;
    input_data_json = '{}';
    @api 
    get source () {
        return "Hello";
    }
    set source (val) {
        // The setter is used to drive updates to the table, but there may be times when the
        // data is not yet present, and we want to avoid trying to generate a bad table...
        
        if (val === undefined || ! Array.isArray(val) || val.length === 0) {
            return;
        }
        this.input_data_json = JSON.stringify(val);
        console.log('input_data_json--->'+this.input_data_json)
        this.generateData();
    }

    /*connectedCallback() {
        console.log('this.input_data_json1-->'+this.input_data_json);
        console.log('selected--->'+this.selected);
        console.log('tableData--->'+JSON.stringify(this.tableData));
    }*/

    /**
     * Generates the data portion of the table
     */
     generateData() {

        //	This is an area where easy misconfiguration can cause a problem, so
		//	we should be a bit helpful if we throw an error.
        try {
            let tempRows = JSON.parse(this.input_data_json);

            
            if (tempRows === undefined || !Array.isArray(tempRows) || tempRows.length === 0) {
                return;                         // No data yet...
            }

            this.displayRows = [];

            tempRows.forEach((item, i) => {
                // console.log(item);
                // console.log("cb_" + String(i));
                item.rowid = i;
                this.displayRows.push(item);
            });
            console.log('this.displayRows-->'+JSON.stringify(this.displayRows))
        } catch (e) {
            console.log('Error in generate data:');
            console.log(e.message);
        }
    }

    handleClick(event) {
        this.selectedRow = this.displayRows[event.target.value];
        this.showModal = true;
    }

    closeModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.showModal = false;
    }
}