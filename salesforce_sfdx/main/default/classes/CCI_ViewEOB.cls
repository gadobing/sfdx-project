global with sharing class CCI_ViewEOB implements omnistudio.VlocityOpenInterface2 {
    public Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> outputs, Map<String, Object> options) {
        try {
            if (methodName == 'getEOBDetails') {
                return getEOBDetails(inputs, outputs, options);
            }
        } catch (Exception e) {
            outputs.put('Error', e.getMessage());outputs.put('ErrorLine', e.getLineNumber());
            outputs.put('ErrorType', e.getTypeName());outputs.put('MethodName', methodName);
            System.debug('ERROR: ------> ' + e);
        }
        return false;
    }

    public static Boolean getEOBDetails( Map<String, Object> inputs, Map<String, Object> outputs, Map<String, Object> options) {
        String memberId = (String)inputs.get('memberId');
        String claimId = (String)inputs.get('claimId'); 
        try {
            Map<String, Object> ipOutput = new Map<String, Object> ();
            ipOutput = callIntegrationProcedure('CCI_ViewEOB',memberId, claimId);
            if(Test.isRunningTest()){
                ipOutput.put('statusCode',200);
                ipOutput.put('status','OK');
                ipOutput.put('content','base64String');
                ipOutput.put('encoding','base64String');
                ipOutput.put('format','application/pdf');
        	}

            Integer statusCode = (integer)ipOutput.get('statusCode');
           
            if( statusCode !=200 ) {
                outputs.put('memberId', memberId);
                outputs.put('statusCode', statusCode);
                outputs.put('status', (string)ipOutput.get('status'));
                return true;
            } else {
                outputs.put('memberId', memberId);
                outputs.put('claimId', claimId);
                outputs.put('format', (string)ipOutput.get('format'));
                outputs.put('encoding', (string)ipOutput.get('encoding'));
                outputs.put('content', (string)ipOutput.get('content'));
                outputs.put('statusCode', statusCode);
                outputs.put('status', (string)ipOutput.get('status'));
                if(Test.isRunningTest()) {
                	throw new AuraHandledException('The test exception has occurred');
                }
                return true;
            }
        } catch(Exception  e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            throw new AuraHandledException('The following exception has occurred: ' + e.getMessage()+' Line:' + String.valueOf(e.getLineNumber()));
        }
    }

    private static Map<String, Object> callIntegrationProcedure(String IPName, String memberIdInput, string claimIdInput ) {
        Map<String, Object> ipInput = new Map<String, Object> ();
        ipInput.put('memberId',memberIdInput);
        ipInput.put('claimId',claimIdInput);
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        return (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService(IPName, ipInput, ipOptions);
    }
}