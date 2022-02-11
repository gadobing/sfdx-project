import { LightningElement ,api, wire, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import downloadjs from '@salesforce/resourceUrl/downloadjs';
import downloadPDF from '@salesforce/apex/PrintJobPDFController.getPdfFileAsBase64String';
import getDocumentDetails from '@salesforce/apex/CCI_DownloadDocumentController.getDownloadDocumentDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PrintJobsContainer extends LightningElement {
    boolShowSpinner = false;
    pdfString;
    @api recordId;
    generatePdf(){ 
        this.boolShowSpinner = true;
        downloadPDF({}).then(response => {
            console.log(response);
            this.boolShowSpinner = false;
            var strFile = "data:application/pdf;base64,"+response;
            window.download(strFile, "sample.pdf", "application/pdf");

        }).catch(error => {
            console.log('Error: ' +error.body.message);
        });
    }
    downloadFile(){ 
        this.boolShowSpinner = true;
        getDocumentDetails({ docSFId: this.recordId })
        .then(result => {
            console.log(result);
            this.boolShowSpinner = false;

            if(result.statusCode == 200 ){  
                console.log('@@result',result);
                var strFile = "data:"+result.mimeType+";base64,"+result.base64String;
                console.log('@@strFile',strFile);
                window.download(strFile, "Document", result.mimeType);
                }
            else if(result.statusCode == 404){
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Document not found in P8 system for this record',
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
        }).catch(error => {
            console.log('@@Error: ');
            console.log('Error: ' +error);

            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        });
    }
    renderedCallback() {
        loadScript(this, downloadjs)
        .then(() => console.log('Loaded download.js'))
        .catch(error => console.log(error));
    }        
}