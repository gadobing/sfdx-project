/*********************************************************************** 
* @ClassName                : CCI_Five9_AccountSearch
  @testClass                : 
* @Description              :  Class
* @Reason for Class Sharing :  Class
* @Author                   : SFDC
* @RevisionHistory          : CH00
* @Version          Date                    Changes made 
    CH00             02/22/2022             Initial Draft
    CH01             03/22/2022             Added logic to create case before redirect
************************************************************************/

public class CCI_Five9_AccountSearch {
    public list <account> acc {get;set;}  
    public  String searchstring {get;set;}
    private Static String intent='';
    private Static List<String> valuesAuth = new List<String>();
    
    public CCI_Five9_AccountSearch(ApexPages.StandardController controller) {  
    }  

    public CCI_Five9_AccountSearch(){     
    }
    
    public void search(){  
        String npi = ApexPages.currentPage().getParameters().get('npi');
        String memberId = ApexPages.currentPage().getParameters().get('memberid');
        String dob = ApexPages.currentPage().getParameters().get('dob');
        String language = ApexPages.currentPage().getParameters().get('language');
        intent = ApexPages.currentPage().getParameters().get('intent');
        if(String.isNotBlank(npi)){
            valuesAuth.add('NPI');
        }
        else if(String.isNotBlank(memberId)){
            valuesAuth.add('Member ID');
        }
        if(String.isNotBlank(dob)){
            valuesAuth.add('Date of birth');
        }
        if(!String.isBlank(npi)){
            acc = [SELECT Id,Name,NPI__c FROM Account WHERE NPI__c = :npi];
        }
        else if(!String.isBlank(memberId)){
            MemberPlan tempPlan = [SELECT Id, MemberId FROM MemberPlan WHERE MemberNumber = :memberId LIMIT 1];
            acc = [SELECT Id, Name FROM Account WHERE Id = :tempPlan.MemberId];
        }
    }
     
    public PageReference searchAndredirect(){
        //RefreshMemberData
        String memberId = ApexPages.currentPage().getParameters().get('memberid');
        if(String.isNotBlank(memberId)){
            this.callMemberUpdate(memberId);
        }
        this.search();
        return this.callPageRedirect(acc[0].Id);
     }
     
    public PageReference callPageRedirect(Id recordId){
        this.createCase(recordId);
        PageReference recordPage = new PageReference('/' + recordId);
        recordPage.setRedirect(true);
        return recordPage;
     }
     
    public void clear(){  
            acc.clear();  
    }

    private void createCase(Id accountId){
        User csr = [SELECT Id,Name,Product_Line__c,Department__c FROM User WHERE Id=:UserInfo.getUserId()];
        List<CCI_Five9_Call_Intent__mdt> callIntents = [SELECT Case_Type__c, Intent_Name__c FROM CCI_Five9_Call_Intent__mdt WHERE Intent_Name__c=:intent];
        Case c = new Case();
        c.Origin = 'Telephone';
        c.AccountId = accountId;
        c.OwnerId = csr.Id;
        if(!callIntents.isEmpty()){
            c.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(callIntents[0].Case_Type__c).getRecordTypeId();
        }
        else{
            c.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Other').getRecordTypeId();
        }
        c.Subject = 'Call Intent - ' + intent;
        c.Department__c = csr.Department__c;
        c.Product_Line__c = csr.Product_Line__c;
        if(!valuesAuth.isEmpty()){
            c.Values_Authenticated__c = String.join(valuesAuth, ';');
        }
        insert c;
    }

    private void callMemberUpdate(String memberId){
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        ipInput.put('memberId', memberId);
        ipOutput = (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService('CCI_RefreshMember', ipInput, ipOptions);
    }
 }