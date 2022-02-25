/*********************************************************************************************
* @ClassName 				: CCI_DownloadDocumentControllerTest
  @testClass				: Test Class for CCI_DownloadDocumentController
* @Description 				: Test Class
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: NK
* @Version          Date              Changes made 
    NK		    02/14/2022		  Initial Draft
***********************************************************************************************/
@isTest
public class CCI_DownloadDocumentControllerTest {
	@isTest 
    public static void getDownloadDocumentDetails(){
        CCI_Document__c doc = new CCI_Document__c();
        //doc.Document_Id_Ext__c ='asded-ffss-sdsds-2344';
        insert doc;
        CCI_DownloadDocumentController.DocumentWrapper docWrap = new CCI_DownloadDocumentController.DocumentWrapper();
        docWrap = CCI_DownloadDocumentController.getDownloadDocumentDetails(doc.Id);
        doc.Document_Id_Ext__c ='asded-ffss-sdsds-2344';
        update doc;
        CCI_DownloadDocumentController.DocumentWrapper docWrap2 = new CCI_DownloadDocumentController.DocumentWrapper();
        docWrap2 = CCI_DownloadDocumentController.getDownloadDocumentDetails(doc.Id);
    }
}