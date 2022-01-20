/*********************************************************************************************
* @ClassName 				: CCI_FrmwrkTransportErrorRetryTest
  @testClass				: None
* @Description 				: Test class of CCI_FrmwrkRQRErrorRetrySchedulable
* @Reason for Class Sharing : 
* @Author 					: 
* @RevisionHistory 			: CH00
* @Version          Date              Changes made 
    CH00		    12/27/2021		  Initial Draft
***********************************************************************************************/
@isTest(SeeAllData = false)
public class CCI_FrmwrkTransportErrorRetryTest {
	
    /*************************************************************************************
    @Description : Validate the Retry IP
	@Author 	 : SFDC
	@Params 	 : None
	@Return 	 : None
    **************************************************************************************/
    @isTest public static void validateTransportErrorRetryFun(){
   

            Test.startTest();
            //Create Error Retry record
            CCI_Integration_Error_Retry__c obj = new CCI_Integration_Error_Retry__c();
            obj.Message_ID__c = 'Group_Upload';
            obj.Parent_Record_SFDC_ID__c = UserInfo.getUserId();
            obj.System_Name__c = 'apigee';
            obj.Error_Message__c = 'Test Error Message';
            obj.Status__c = 'Pending';
           	insert obj;
            
            Map<String, Object> inputMap = new Map<String, Object>();
            inputMap.put('ParentRecordId', obj.Parent_Record_SFDC_ID__c);
            inputMap.put('ErrorObjectLogId', obj.Id);
            inputMap.put('SystemName', obj.System_Name__c);
            inputMap.put('Path', '');
            inputMap.put('MessageID', obj.Message_ID__c);
            inputMap.put('Payload', '');
            inputMap.put('IntegrationProcedureName', 'Framework_HTTPGETCallout');
            
            CCI_FrmwrkTransportErrorRetry retryObj = new CCI_FrmwrkTransportErrorRetry();
            retryObj.invokeMethod('retryRequest', inputMap, new Map<String, Object>(), new Map<String, Object>());
            retryObj.invokeMethod('retryRequest', inputMap, new Map<String, Object>(), new Map<String, Object>());
            system.assert(obj != null);
            Test.stopTest();
  
    }
}