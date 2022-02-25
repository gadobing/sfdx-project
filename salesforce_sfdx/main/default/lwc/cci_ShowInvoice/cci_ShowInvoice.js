import { LightningElement ,api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getInvoiceDetails from '@salesforce/apex/CCI_ShowInvoiceController.getInvoiceDetails';
////import getInvoiceDetails from '@salesforce/apex/CCI_InvoiceController.getInvoiceDetails';
//import { getNamespaceDotNotation } from '%vlocity_namespace%/omniscriptInternalUtils'; 
//_%vlocity_namespace% = getNamespaceDotNotation();
import { OmniscriptActionCommonUtil } from 'omnistudio/omniscriptActionUtils';
export default class Cci_ShowInvoice extends LightningElement {
    strData;
    recId;
    invoice;
    connectedCallback() {
        setTimeout(() => {
          //  this.invoiceDetails();
          this._actionUtilClass = new OmniscriptActionCommonUtil();
          console.log("setTimeout");
          this.triggerRemote();
        }, 1000);
    }

    triggerRemote() {
        console.log("triggerRemote");
        const input = {
            memberId: this.recId,
            invoiceId:'123'
        };
        const params = {

            input: JSON.stringify(input),
            sClassName: 'CCI_ShowInvoiceController',
            sMethodName: 'getInvoiceDetails',
            options: '{}',
        };
    
        this._actionUtilClass
            .executeAction(params, null, this, null, null)
            .then(response => {
                window.console.log(response);
                 var result = response.result;
                 // this.showLoading =false;
                 console.log('result',result);
                 if(result.statusCode == 200 ){
                 this.invoice = result;
                 this.strData = 'data:'+this.invoice.format+ ';'+this.invoice.encoding+','+this.invoice.content;
               
                  console.log('result',result);
             
                 }
                 else if(result.statusCode == 404){
                     const evt = new ShowToastEvent({
                         title: 'Error',
                         message: 'Invoice not found for this member',
                         variant: 'error',
                         mode: 'sticky'
                     });
                     this.dispatchEvent(evt);
                    
                 }
                 else{
                     const evt = new ShowToastEvent({
                         title: 'Error',
                         message: 'Something went wrong, please try again after some time(Error Code= '+result.statusCode+',Message = '+result.status+')!',
                         variant: 'error',
                         mode: 'sticky'
                     });
                     this.dispatchEvent(evt);
                   
                 }
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
            });
    }
    invoiceDetails(){

    }
}