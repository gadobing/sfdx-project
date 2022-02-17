/*********************************************************************************************
* @ClassName 				: CCI_DownloadDocumentController
  @testClass				: CCI_DownloadDocumentControllerTest
* @Description 				: LWC Controller Class (CCI_DownloadDocument)
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: NK
* @Version          Date              Changes made 
    NK		    02/11/2022		  Initial Draft
***********************************************************************************************/
public with sharing class CCI_DownloadDocumentController {

    @AuraEnabled 
    public static DocumentWrapper getDownloadDocumentDetails( string docSFId) {
        system.debug('docSFId@@'+docSFId);
        CCI_Document__c doc = new CCI_Document__c();
        doc =[ SELECT Id,Document_Id_Ext__c,Document_Title__c FROM CCI_Document__c WHERE Id =: docSFId ];
        if(doc.Document_Id_Ext__c == null){
            List<ContentDocumentLink>cDLList = new list<ContentDocumentLink>();

            cDLList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId =: doc.Id];
            if(cDLList.size()>0){
                DocumentWrapper docwrapper = new DocumentWrapper();
                docwrapper.sfDocId =cDLList[0].ContentDocumentId;
                return docwrapper;
            }
            else{
                throw new AuraHandledException('No file is available for this record!');
            }
            
        }
        /////////////
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        ipInput.put('documentNumber', doc.Document_Id_Ext__c);
        ipOutput = (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService('CCI_P8RetrieveDocumentCallout', ipInput, ipOptions);
        //////////////////
    
        if((integer)ipOutput.get('statusCode') !=200 ){
            DocumentWrapper docwrapper = new DocumentWrapper( (Integer)ipOutput.get('statusCode'),(string)ipOutput.get('status'),'','');
            return docwrapper;
        }
        else{
            DocumentWrapper docwrapper = new DocumentWrapper( (Integer)ipOutput.get('statusCode'),(string)ipOutput.get('status'),(string)ipOutput.get('base64String'),(string)ipOutput.get('mimeType'));
            if(CCI_Constants.GET_MIMETYPE_MAPPING.containsKey(docwrapper.mimeType)){
                docwrapper.extension = CCI_Constants.GET_MIMETYPE_MAPPING.get(docwrapper.mimeType);
            }
            docwrapper.docName = doc.Document_Title__c;
            return docwrapper;
        }
    }

    public class DocumentWrapper{
        public DocumentWrapper(){}
       
        public DocumentWrapper(Integer statusCode, string status, string base64String, string mimeType){
            this.mimeType		    =	mimeType;
            this.base64String		=	base64String;
            this.statusCode		    =	statusCode;
            this.status		        =	status;
            this.sfDocId            = '';
            this.extension          = '';
        }
        @AuraEnabled
        Public Integer statusCode;
        @AuraEnabled
        Public string status;
        @AuraEnabled
        Public string mimeType;
        @AuraEnabled
        Public string base64String;
        @AuraEnabled
        Public string extension;
        @AuraEnabled
        Public string docName;
        @AuraEnabled
        Public string sfDocId;
    }
}