/*********************************************************************************************
* @ClassName 				: CCI_DownloadDocumentController
  @testClass				: CCI_DownloadDocumentControllerTest
* @Description 				: LWC Controller Class (CCI_ViewMemberIdCardC)
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: NK
* @Version          Date              Changes made 
    NK		    02/11/2022		  Initial Draft
***********************************************************************************************/
public with sharing class CCI_DownloadDocumentController {
    @AuraEnabled 
    public static String getPdfFileAsBase64String() {
        PageReference pdfPage = Page.envelope;
        Blob pdfBlob = pdfPage.getContent();
        String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        return base64Pdf;
    }
    @AuraEnabled 
    public static DocumentWrapper getDownloadDocumentDetails( string docSFId) {

        CCI_Document__c doc = new CCI_Document__c();
        doc =[ SELECT Id,Document_Id_Ext__c FROM CCI_Document__c WHERE Id =: docSFId ];
        if(doc.Document_Id_Ext__c == null){
            throw new AuraHandledException('This document is not uploaded to the P8 system yet. Please check the related tab\'s file section to download the file!');
        }
        /////////////
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        ipInput.put('documentNumber', doc.Document_Id_Ext__c);
        ipOutput = (Map<String, Object>) %vlocity_namespace%.IntegrationProcedureService.runIntegrationService('CCI_P8RetrieveDocumentCallout', ipInput, ipOptions);
        //////////////////
    
        if((integer)ipOutput.get('statusCode') !=200 ){
            DocumentWrapper docwrapper = new DocumentWrapper( (Integer)ipOutput.get('statusCode'),(string)ipOutput.get('status'),'','');
            return docwrapper;
        }
        else{
            DocumentWrapper docwrapper = new DocumentWrapper( (Integer)ipOutput.get('statusCode'),(string)ipOutput.get('status'),(string)ipOutput.get('base64String'),(string)ipOutput.get('mimeType'));
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
        }
        @AuraEnabled
        Public Integer statusCode;
        @AuraEnabled
        Public string status;
        @AuraEnabled
        Public string mimeType;
        @AuraEnabled
        Public string base64String;
    }
}