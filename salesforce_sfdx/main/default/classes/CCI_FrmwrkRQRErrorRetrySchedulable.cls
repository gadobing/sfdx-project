/*********************************************************************************************
* @ClassName 				: CCI_FrmwrkRQRErrorRetrySchedulable
  @testClass				: CCI_FrmwrkTransportErrorRetryTest
* @Description 				: Scheduler class
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: CH00
* @Version          Date              Changes made 
    CH00		    12/27/2021		  Initial Draft
***********************************************************************************************/
global class CCI_FrmwrkRQRErrorRetrySchedulable implements Schedulable {
    global String RQRId;
    global String rqrBatchId;
    global String systemName;
    global String messageID;
    global String path;
    global String payload;
    global String IPName;

    /*************************************************************************************
    @Description : Parametrized Constructor
	@Author 	 : SFDC
	@Params 	 : String IPNameInput, String rqrIdInput, String retryRequestIdInput, String systemNameInput, String messageIDInput, String pathInput, String payloadInput
	@Return 	 : None
    **************************************************************************************/
    public CCI_FrmwrkRQRErrorRetrySchedulable(String IPNameInput, String rqrIdInput, String retryRequestIdInput, String systemNameInput, String messageIDInput, String pathInput, String payloadInput) {
        RQRId = rqrIdInput;
        rqrBatchId = retryRequestIdInput;
        systemName = systemNameInput;
        path = pathInput;
        messageID = messageIDInput;
        payload = payloadInput;
        IPName = IPNameInput;
    }

    /*************************************************************************************
    @Description : Execute method of the Scheduler
	@Author 	 : SFDC
	@Params 	 : SchedulableContext sc
	@Return 	 : None
    **************************************************************************************/
    global void execute(SchedulableContext sc) {
        CCI_Integration_Error_Retry__c rqrBatchProcessLog = (CCI_Integration_Error_Retry__c) [SELECT Id FROM CCI_Integration_Error_Retry__c WHERE Id = :rqrBatchId LIMIT 1];
        rqrBatchProcessLog.Status__c = 'Processing';
        update rqrBatchProcessLog;
        callIntegrationProcedure(IPName, RQRId, rqrBatchId, path, messageID, systemName, payload);
    }

    /*************************************************************************************
    @Description : Used to call the IP
	@Author 	 : SFDC
	@Params 	 : String IPName, String iRQRId, String rqrBatchId, String Path, String MessageID, String SystemName, String Payload
	@Return 	 : None
    **************************************************************************************/
    @Future(Callout=true)
    private static void callIntegrationProcedure(String IPName, String iRQRId, String rqrBatchId, String Path, String MessageID, String SystemName, String Payload) {
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        ipInput.put('RelativePath', Path);
        ipInput.put('Parent_Record_SFDC_ID', iRQRId);
        ipInput.put('Message_ID', MessageID);
        ipInput.put('Service_Name', SystemName);
        ipInput.put('Payload', Payload);
        ipOutput = (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService(
                IPName, ipInput, ipOptions);

        CCI_Integration_Error_Retry__c rqrBatchProcessLog = (CCI_Integration_Error_Retry__c) [SELECT Id FROM CCI_Integration_Error_Retry__c WHERE Id = :rqrBatchId LIMIT 1];
        rqrBatchProcessLog.Status__c = 'Processed';
        update rqrBatchProcessLog;
    }
}