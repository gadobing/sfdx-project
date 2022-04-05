import { LightningElement ,api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getMemberCardDetails from '@salesforce/apex/CCI_ViewMemberIdCardController.getMemberCardDetails';
import { OmniscriptActionCommonUtil } from 'omnistudio/omniscriptActionUtils';

export default class Cci_ViewMemberIdCard extends LightningElement {   

    cardDetails;
    strData;
    strData2;
    error;
    customMessage ='';
    showLoading = true;
    errorMessage = '';
    isError = false;
    @api recordId;
    @track isModalOpen = false;

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
            memberId: this.recordId
        };
 
        const params = {

            input: JSON.stringify(input),
            sClassName: 'CCI_ViewMemberIdCardController',
            sMethodName: 'getMemberCardDetails',
            options: '{}',
        };
    
        this._actionUtilClass
            .executeAction(params, null, this, null, null)
            .then(response => {
                this.boolShowSpinner = false;
                window.console.log(response);
                 var result = response.result;
                 window.console.log(JSON.parse(result.data));
                if(result.data){
                    this.handleData(JSON.parse(result.data));
                }
                if(result.Error){
                 this.error = result.Error;
                    console.log('error',error);

                    
                    this.errorMessage = this.error;
                    this.isError = true;
                    this.isModalOpen = false;
                }
            });
        }
    handleData(result) {
        this.isModalOpen = true;
        if(this.cardDetails === undefined || (this.cardDetails != undefined && this.cardDetails.statusCode !=200)){
            this.showLoading =true;
           // console.log('@@getMemberCardDetails');//12972630W05t
           // console.log('@@recordId',this.recordId);//0017j00000ghZNHAA2
            
                    
                    this.showLoading =false;
                    console.log('result',result);
                    if(result.statusCode == 200 ){
                    this.cardDetails = result;
                    this.strData = 'data:'+this.cardDetails.format+ ';'+this.cardDetails.encoding+','+this.cardDetails.content;
                  
                  //download test
                   // this.strData2 = 'data:'+this.cardDetails.format+ ';content-disposition:attachment;'+this.cardDetails.encoding+','+this.cardDetails.content;
                 //  
                    console.log('result',result);
                
                    }
                    else if(result.statusCode == 404){
                        
                        this.errorMessage = 'Member ID card not found for this member';
                        this.isError = true;
                        this.isModalOpen = false;
                    }
                    else{
                        
                        this.errorMessage = 'Something went wrong, please try again after some time(Error Code= '+result.statusCode+',Message = '+result.status+')!';
                        this.isError = true;
                        this.isModalOpen = false;
                    }
               
               
                    
               
        }    

    }
   
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }


}