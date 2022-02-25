/*********************************************************************************************
* @ClassName 				: CCI_FrmwrkRetryCalloutBatch
  @testClass				: None
* @Description 				: This batch class will intiate automatic retry of failed records.
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: CH00
* @Version          Date              Changes made 
    CH00		    2/15/2022		  Initial Draft
***********************************************************************************************/

global class CCI_FrmwrkRetryCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
    private static final String STATUS_RESUBMISSION = 'Resubmission In Progress';
    private static final String PARENT_RECORD_SFDC_ID = 'Parent_Record_SFDC_ID';
    private static final String RETRY_RECORD_ID = 'Retry_Record_Id';
    global String serviceName;
    
    /*************************************************************************************
    @Description : Parametrized Constructor
	@Author 	 : SFDC
	@Params 	 : String serviceNameInput
	@Return 	 : None
    **************************************************************************************/
    public CCI_FrmwrkRetryCalloutBatch(String serviceNameInput) {
        serviceName = serviceNameInput;
    }
    
    /*************************************************************************************
    @Description : Start method of the Batch to return the Retry records which are in Resubmission in progress
	@Author 	 : SFDC
	@Params 	 : Database.BatchableContext BC
	@Return 	 : Database.QueryLocator
    **************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext BC){
        Integer maxRetries = CCI_FrmwrkRetryCalloutBatch.getRetryMasterData(serviceName);//retreiving master data for retry count from metadata.
        return Database.getQueryLocator([
            SELECT Id,Retry_Count__c,Retry_Status__c,
            System_Name__c,Integration_Procedure_Name__c,Parent_Record_SFDC_ID__c
            FROM CCI_Integration_Error_Retry__c 
            WHERE Retry_Count__c<=:maxRetries
            And Retry_Status__c=:STATUS_RESUBMISSION
            AND System_Name__c=:serviceName
        ]);
    }
	
    /*************************************************************************************
    @Description : Execute method of the Batch which will call the IP to retry
	@Author 	 : SFDC
	@Params 	 : Database.BatchableContext BC, List<CCI_Integration_Error_Retry__c> retryRecords
	@Return 	 : None
    **************************************************************************************/
    public void execute(Database.BatchableContext BC, List<CCI_Integration_Error_Retry__c> retryRecords){
        List<String> retryRecordsIdList = new List<String>();
        for(CCI_Integration_Error_Retry__c retryRecord:retryRecords){//loop start here..
            callIntegrationProcedure(retryRecord.Integration_Procedure_Name__c, 
                                     retryRecord.Parent_Record_SFDC_ID__c, retryRecord.Id);
        }
    }
    
    /*************************************************************************************
    @Description : Finish method of the Batch currently emty but can be used in future to write post processing logic
	@Author 	 : SFDC
	@Params 	 : Database.BatchableContext BC
	@Return 	 : None
    **************************************************************************************/
    public void finish(Database.BatchableContext BC){
    }
    
    /*************************************************************************************
    @Description : Get the Max Retry Count from Metadata
	@Author 	 : SFDC
	@Params 	 : String serviceName
	@Return 	 : Integer
    **************************************************************************************/
    public static Integer getRetryMasterData(String serviceName){
        CCI_Integration_System_Setting__mdt retryMasterData = CCI_Integration_System_Setting__mdt.getInstance(serviceName);
        return retryMasterData.Transport_Error_Max_Retry__c!=null ? (Integer)retryMasterData.Transport_Error_Max_Retry__c : 0;
    }
    
    /*************************************************************************************
    @Description : Used to call the integration procedure
	@Author 	 : SFDC
	@Params 	 : String IPName, String parentRecordId, String retryRecordId
	@Return 	 : None
    **************************************************************************************/
    private static void callIntegrationProcedure(String IPName, String parentRecordId, String retryRecordId) {
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        ipInput.put(PARENT_RECORD_SFDC_ID, parentRecordId);
        ipInput.put(RETRY_RECORD_ID, retryRecordId);
        ipOutput = (Map<String, Object>) %vlocity_namespace%.IntegrationProcedureService.runIntegrationService(
                IPName, ipInput, ipOptions);
    }
}