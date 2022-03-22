import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { OmniscriptActionCommonUtil } from '%vlocity_namespace%/omniscriptActionUtils';
export default class Ccivieweob extends LightningElement {

    eob;
    boolShowSpinner = true;
    url;
    @api memberid;
    @api claimid;
    screenText = 'Downloading the file...';

    connectedCallback() {
        setTimeout(() => {
            this._actionUtilClass = new OmniscriptActionCommonUtil();
            console.log("setTimeout");
            this.triggerRemote();
        }, 1000);
    }
    triggerRemote() {
        console.log("triggerRemote");
        const input = {
            memberId: this.memberid,
            claimId: this.claimid
        };
        const params = {
            input: JSON.stringify(input),
            sClassName: 'CCI_ViewEOB',
            sMethodName: 'getEOBDetails',
            options: '{}',
        };
    
        this._actionUtilClass
            .executeAction(params, null, this, null, null)
            .then(response => {
                console.log('resp',response);
                var result = response.result;
                if(result.statusCode == 200 ) {
                    this.eob = result;
                    const linkSource = 'data:application/pdf;base64,'+this.eob.content;
                    this.url = linkSource;
                    //Creating anchor tag in DOM
                    const downloadLink = document.createElement('a');
                    document.body.appendChild(downloadLink);
                    downloadLink.href = linkSource;
                    downloadLink.target = "_blank";
                    downloadLink.download = this.claimid+"_EOB.pdf";
                    downloadLink.click(); 
                    this.boolShowSpinner = false;
                    this.screenText = 'Document is downloaded';
                } else if(result.statusCode == 404){
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'EOB not found for this member',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                 } else{
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
                console.log('e',error);
                this.boolShowSpinner = false;
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