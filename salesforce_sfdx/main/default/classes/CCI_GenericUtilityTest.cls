/*********************************************************************************************
* @ClassName 				: CCI_GenericUtilityTest
  @testClass				: None
* @Description 				: Test class of CCI_GenericUtility
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: CH00
* @Version          Date              Changes made 
    CH00		    2/11/2022		  Initial Draft
***********************************************************************************************/
@isTest(SeeAllData = false)
public class CCI_GenericUtilityTest {
    
    /*************************************************************************************
    @Description : Validate the getBase64String method
	@Author 	 : SFDC
	@Params 	 : None
	@Return 	 : None
    **************************************************************************************/
    @isTest private static void shouldGetBase64String(){
        Test.startTest();
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put(CCI_Constants.CONTENT_DOCUMENT_ID, documents[0].Id);
        
        CCI_GenericUtility genricUtility = new CCI_GenericUtility();
        System.assert(genricUtility.invokeMethod(CCI_Constants.GET_BASE64STRING, inputMap, new Map<String, Object>(), new Map<String, Object>()));
        
        Test.stopTest();
    }
    
    /*************************************************************************************
    @Description : Test Negative Scenario
	@Author 	 : SFDC
	@Params 	 : None
	@Return 	 : None
    **************************************************************************************/
    
    @isTest private static void shouldNotGetBase64String(){
        Test.startTest();
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put(CCI_Constants.CONTENT_DOCUMENT_ID, documents[0].Id);
        
        CCI_GenericUtility genricUtility = new CCI_GenericUtility();
        System.assert(!genricUtility.invokeMethod(CCI_Constants.GET_BASE64STRING, null, new Map<String, Object>(), new Map<String, Object>()));
        
        Test.stopTest();
    }
}