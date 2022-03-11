import { api, LightningElement } from 'lwc';
import {  getRecordNotifyChange } from 'lightning/uiRecordApi';

import { NavigationMixin } from 'lightning/navigation';
import updateMem from '@salesforce/apex/CCI_MemberRefreshController.refreshMember';
export default class Cci_RefreshMember extends NavigationMixin(LightningElement){
    @api recordId;
    boolShowSpinner = true;
    refreshDate;
    refreshMember() {
        getRecordNotifyChange({fields: this.recordId});
        updateMem({recordId: this.recordId})
            .then(result => {
                console.log("@@@result",result);
                this.boolShowSpinner = false;
               
                    if (result) {
                       
                    }
                this.refreshTab();
                }).catch(error => {
                    console.log('@@Error: ' +error);
                    this.refreshTab();
                });
    }
    connectedCallback() {
        setTimeout(() => {
          this.refreshMember();
        }, 2000);
       
    }
    refreshTab(){
        let reloadEventDetail = true;
        let reloadEvent = new CustomEvent('pagereload',{
            detail: {reloadEventDetail},
        });
        this.dispatchEvent(reloadEvent);
        console.log('Fireddd');
    }


}