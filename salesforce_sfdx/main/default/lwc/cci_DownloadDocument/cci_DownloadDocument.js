import { LightningElement ,api, wire, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import downloadjs from '@salesforce/resourceUrl/downloadjs';
import { CloseActionScreenEvent } from 'lightning/actions';
import getDocumentDetails from '@salesforce/apex/CCI_DownloadDocumentController.getDownloadDocumentDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Cc_DownloadDocument extends NavigationMixin(LightningElement){
    boolShowSpinner = true;
    pdfString;
    @api recordId;
    downloadFile(){ 
        this.boolShowSpinner = true;
        getDocumentDetails({ docSFId: this.recordId })
        .then(result => {
            console.log(result);
            this.boolShowSpinner = false;
            if(result.sfDocId !='')
            {
                this.navigateToFiles(result.sfDocId);
                this.closeQuickAction();
                return;
            }
            if(result.statusCode == 200 ){  
              //  console.log('@@result',result);//
                //var strFile = "data:"+result.mimeType+";base64,"+result.base64String;
               
                var strFile = "data:application/octet-stream"+";base64,"+result.base64String;
                var docName = result.docName =='' ? 'Document':result.docName;
                var docNamewExtension =  result.extension ==''?docName :docName+'.'+result.extension;
 
                window.download(strFile, docNamewExtension, "application/octet-stream");
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
                this.closeQuickAction();
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
            this.boolShowSpinner = false;
            this.closeQuickAction();
        });
    }
    renderedCallback() {
        loadScript(this, downloadjs)
        .then(() => console.log('Loaded download.js'))
        .catch(error => console.log(error));
    }    
    connectedCallback() {
        setTimeout(() => {
            this.downloadFile();
        }, 1000);
       
    }
    navigateToFiles(recordIds) {
        this[NavigationMixin.Navigate]({
          type: 'standard__namedPage',
          attributes: {
              pageName: 'filePreview'
          },
          state : {
              recordIds: recordIds
              
          }
        })
      }
      closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }  
}