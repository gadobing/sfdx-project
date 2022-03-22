/*********************************************************************** 
* @ClassName                : CCI_Five9_AccountSearch
  @testClass                : 
* @Description              :  Class
* @Reason for Class Sharing :  Class
* @Author                   : SFDC
* @RevisionHistory          : CH00
* @Version          Date              Changes made 
    CH00             02/22/2022             Initial Draft
************************************************************************/

public class CCI_Five9_AccountSearch {
   public list <account> acc {get;set;}  
   public  String searchstring {get;set;}
   private String intent='';
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
       	System.debug('Five9 NPI: ' + npi);
        System.debug('Five9 memberid: ' + memberid);
        System.debug('Five9 dob: ' + dob);
        System.debug('Five9 language: ' + language);
        if(!String.isBlank(npi)){
            System.debug('Five9 searching by NPI');
            acc = [SELECT Id,Name,NPI__c FROM Account WHERE NPI__c = :npi];
        }
        else if(!String.isBlank(memberId)){
            System.debug('Five9 searching by MemberId');
            MemberPlan tempPlan = [SELECT Id, MemberId FROM MemberPlan WHERE MemberNumber = :memberId LIMIT 1];
            System.debug('Five9 tempPlan: ' + tempPlan);
            acc = [SELECT Id, Name FROM Account WHERE Id = :tempPlan.MemberId];
        }
        
       	System.debug('Five9 account found: ' + acc);
   	}
    
    public PageReference searchAndredirect(){
        System.debug('Five9 searching');
        this.search();
        System.debug('Five9 redirecting');
        return this.callPageRedirect(acc[0].Id);
    }
    
    public PageReference callPageRedirect(Id recordId){
        System.debug('Five9 recordId: ' + recordId);
        createCase(recordId);
        //RefreshMemberData
      //  callMemberUpdate();
        PageReference demoPage = new PageReference('/' + recordId);
        demoPage.setRedirect(true);
        return demoPage;
	}
    
    public void clear(){  
   		acc.clear();  
	}  
    private static void createCase(Id accountId){
        User csr = [SELECT Id,Name,Product_Line__c,Department__c FROM User WHERE Id=:UserInfo.getUserId()];
        Case c = new Case();
        c.Origin = 'Telephone';
        c.OwnerId = csr.Id;
        c.Department__c = csr.Department__c;
        c.Product_Line__c = csr.Product_Line__c;
        insert c;
        
        
    }
  /*  public void callMemberUpdate(){
        /////////////
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        ipInput.put('memberId',ApexPages.currentPage().getParameters().get('memberid'));
        ipOutput = (Map<String, Object>) %vlocity_namespace%.IntegrationProcedureService.runIntegrationService('CCI_RefreshMember', ipInput, ipOptions);
        //////////////////
 
    }*/
}