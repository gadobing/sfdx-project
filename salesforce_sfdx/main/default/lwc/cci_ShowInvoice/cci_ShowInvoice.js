import { LightningElement ,api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInvoiceDetails from '@salesforce/apex/CCI_ShowInvoiceController.getInvoiceDetails';
//import getInvoiceDetails from '@salesforce/apex/CCI_InvoiceController.getInvoiceDetails';
export default class Cci_ShowInvoice extends LightningElement {
    strData;
    recId;
    invoice;
    connectedCallback() {
        setTimeout(() => {
            this.invoiceDetails();
        }, 1000);
       
    }
    invoiceDetails(){
        getInvoiceDetails({ memberId: this.recId,invoiceId:'1234' })
                .then(result => {
                    
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
                    this.error = error;
                    console.log('error',error);

                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                  
                });
    }
}