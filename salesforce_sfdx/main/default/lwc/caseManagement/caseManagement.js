import { LightningElement, api } from 'lwc';

export default class CaseManagement extends LightningElement {
    @api recordId;
    get prefill(){
       return '{"ContextId":"'+this.recordId+'"}';
    }
}