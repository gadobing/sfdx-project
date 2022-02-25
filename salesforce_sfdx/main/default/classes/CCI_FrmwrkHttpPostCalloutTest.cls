/*********************************************************************************************
* @ClassName 				: CCI_FrmwrkHttpPostCalloutTest
  @testClass				: None
* @Description 				: Test class of CCI_FrmwrkHttpPostCallout
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: CH00
* @Version          Date              Changes made 
    CH00		    2/17/2022		  Initial Draft
***********************************************************************************************/
@isTest(SeeAllData = false)
public class CCI_FrmwrkHttpPostCalloutTest {
	@isTest private static void shouldInvokeUtilityMethod(){
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        
        CCI_Document__c documentRecord = new CCI_Document__c();
        insert documentRecord;
        
        CCI_Integration_System_Setting__mdt p8ItegrationSetting = [
            SELECT Apex_Method_Name__c,Named_Credential__c,Logging_Enabled__c,
            Params__c,System_Name__c
            FROM CCI_Integration_System_Setting__mdt
            WHERE DeveloperName = 'P8DocumentUpload'
        ];
        
        //String payLoad='{"searchIndexes":[{"name":"CaseID","value":"00001023"},{"name":"ContractNumber","value":""}],"image":{"format":"application/txt","content":"base64string"},"objectStore":"MemAppOS","documentClass":"MEMAPP","documentType":"APPL","lineOfBusiness":"BCBS"}';
		//CCI_P8PostRequestWrapper reqWrapper = (CCI_P8PostRequestWrapper)JSON.deserialize(payload, CCI_HTTPPostRequestWrapper.class);
        CCI_P8PostRequestWrapper reqWrapper = new CCI_P8PostRequestWrapper();
        reqWrapper.objectStore = 'MemAppOS';
        reqWrapper.documentClass = 'MEMAPP';
        reqWrapper.documentType = 'APPL';
        reqWrapper.lineOfBusiness = 'BCBS';
        
        Set<CCI_P8PostRequestWrapper.cls_searchIndexes> searchIndexes = new Set<CCI_P8PostRequestWrapper.cls_searchIndexes>();
        CCI_P8PostRequestWrapper.cls_searchIndexes searchString = new CCI_P8PostRequestWrapper.cls_searchIndexes();
        searchString.name = 'CaseID';
        searchString.value = '00001023';
        searchIndexes.add(searchString);
        reqWrapper.searchIndexes = searchIndexes;
        
        CCI_P8PostRequestWrapper.cls_image imageData = new CCI_P8PostRequestWrapper.cls_image();
        imageData.content = 'base64string';
        imageData.format = 'application/jpg';
        reqWrapper.image = imageData;
        
        
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('Payload', reqWrapper);
        inputMap.put('endpoint', p8ItegrationSetting.Named_Credential__c+p8ItegrationSetting.Params__c);
        inputMap.put('authorization', 'dummy token');
        inputMap.put('contentType', 'application/json');
        inputMap.put('additionalMethodArguments', 'contentDocumentId='+documents[0].Id+'&documentId='+documentRecord.Id);
        inputMap.put('utilityMethodName', p8ItegrationSetting.Apex_Method_Name__c);
        inputMap.put('isLoggingEnabled',p8ItegrationSetting.Logging_Enabled__c);
        inputMap.put('Service_Name', 'P8DocumentUpload');
        inputMap.put('Message_ID', 'dummyMessageId');
        inputMap.put('DynamicParams', 'dummyMessageId');
        Test.startTest();
        CCI_FrmwrkHttpPostCallout frmwrkPost = new CCI_FrmwrkHttpPostCallout();
        System.assert(frmwrkPost.invokeMethod('utilityMethod', inputMap, new Map<String, Object>(), new Map<String, Object>()));
        Test.stopTest();
    }
}