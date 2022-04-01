import { LightningElement,api,track } from 'lwc';
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

export default class Cci_ViewLineItemDetails extends OmniscriptBaseMixin(LightningElement){
    @track displayRows = [];
    @track showModal = false;
    @track showTotalModal = false;
    @track selectedRow;
    @track showLineDetails = false;
    @track showTotalTable = false;
    @track showCodesTable=false;
    @track showCommentsTable=false;
    @track showViewEOB=false;
    

    @api total;
    @api allowed;
    @api denied;
    @api tpd;
    @api interest;
    @api deductible;
    @api copay;
    @api insurance;
    @api paid;
    @api disallowed;
    @api risk;
    @api memberid;
    @api claimid;

    //Audit block boolean
    @track showAuditTable = false;

    //Audit block properties
    @api claim;
    @track type;
    @track record;
    @track isModalOpen = false;
    @track isAccordianOpen = false;
    @track chevron = 'utility:chevronright';

    @api 
    get table (){
        return "";
    }
    set table (val) {
        // The setter is used to drive updates to the table, but there may be times when the
        // data is not yet present, and we want to avoid trying to generate a bad table...
        
        if (val === undefined ) {
            return;
        }
        if(val == 'LineDetails'){
            this.showLineDetails = true;
        }
        else if(val == 'Totals'){
            this.showTotalTable = true;
        }
        else if(val == 'Comments'){
            this.showCommentsTable = true;
        }
        else if(val == 'Codes'){
            this.showCodesTable = true;
        }
        else if(val == 'Audit'){
            this.showAuditTable = true;
        }
    }

    input_data_json = '{}';

    @api 
    get source () {
        return "";
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
        console.log('this.selectedRow--->'+JSON.stringify(this.selectedRow))
        this.showModal = true;
    }

    closeModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.showModal = false;
    }

    handleButtonClick(event) {
        this.showTotalModal = true;
    }


    closeTotalModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.showTotalModal = false;
    }

    //Audit block methods
    openModalClaims() {
        // to open claim level modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.type = 'Claim';
        this.record = this.claim.ClaimLevel;
    }
    openModalService(event) {
        // to open Service level modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.type = "Service";
        this.record = this.claim.ServiceLevel[event.target.value];
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    
    validateparams() {
        if((memberid != null && memberid != '')&&(claimid!= null && claimid != ''))
        {
            console.log('memberid>>::'+memberid);
            console.log('claimid>>::'+claimid);
            this.showViewEOB = true;
            console.log('showViewEOB>>::'+showViewEOB);
        }
    }

    handleAccordianClick(){
        this.isAccordianOpen = !this.isAccordianOpen;
        this.chevron = this.isAccordianOpen ? 'utility:chevrondown' : 'utility:chevronright';
    }
    
}