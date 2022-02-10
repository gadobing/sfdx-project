import { LightningElement, api } from 'lwc';

export default class CCIUploadDocumentQuickAction extends LightningElement {
		
		@api recordId;
    retrievedRecordId = false;
		prefill={};
		
		renderedCallback() {
				if (!this.retrievedRecordId && this.recordId) {

						this.retrievedRecordId = true; // Escape case from recursion
						var data = '\{"ContextId":"'+this.recordId+'"}';
						this.prefill = data;
        }
    }
		
}