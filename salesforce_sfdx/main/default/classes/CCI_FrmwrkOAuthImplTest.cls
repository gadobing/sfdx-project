/*********************************************************************************************
* @ClassName 				: CCI_FrmwrkOAuthImplTest
  @testClass				: None
* @Description 				: Test class of CCI_FrmwrkOAuthImpl
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: CH00
* @Version          Date              Changes made 
    CH00		    12/27/2021		  Initial Draft
***********************************************************************************************/
@isTest(SeeAllData = false)
public class CCI_FrmwrkOAuthImplTest {
    
        /*************************************************************************************
    @Description : Validate the Retry IP
	@Author 	 : SFDC
	@Params 	 : None
	@Return 	 : None
    **************************************************************************************/
    @isTest public static void validateOAuthImplFun(){
   

            Test.startTest();
            Map<String, Object> inputMap = new Map<String, Object>();
            inputMap.put('Username', 'username');
            inputMap.put('AuthType', 'pwd');
            inputMap.put('Password', 'pwd');
            inputMap.put('IntegrationProcedureName', 'Framework_HTTPGETCallout');
            
            CCI_FrmwrkOAuthImpl objAuthImpl = new CCI_FrmwrkOAuthImpl();
            objAuthImpl.invokeMethod('Authtoken2', inputMap, new Map<String, Object>(), new Map<String, Object>());
            system.assert(true  == objAuthImpl.invokeMethod('Authtoken', inputMap, new Map<String, Object>(), new Map<String, Object>()));
        	objAuthImpl.invokeMethod('Test Exception', inputMap, new Map<String, Object>(), new Map<String, Object>());
        	system.assert( false == objAuthImpl.invokeMethod('Test Exception', inputMap, new Map<String, Object>(), new Map<String, Object>()));
            
            system.assert(objAuthImpl != null);
            Test.stopTest();
  
    }

}