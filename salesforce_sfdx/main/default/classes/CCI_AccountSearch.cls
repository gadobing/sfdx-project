/*********************************************************************************************
* @ClassName 				: CCI_AccountSearch
  @testClass				: CCI_AccountSearchTest
* @Description 				: 
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: NK
* @Version          Date              Changes made 
    NK		    02/15/2022		  Initial Draft
***********************************************************************************************/
global with sharing class CCI_AccountSearch implements omnistudio.VlocityOpenInterface2 {
    /*************************************************************************************
    @Description : Execute method of the Queueable
	@Author 	 : SFDC
	@Params 	 : QueueableContext qc
	@Return 	 : None
    **************************************************************************************/

  public Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputs,
    Map<String, Object> outputs,
    Map<String, Object> options
  ) {
    try {
      if (methodName.equals('querySearch')) {
        querySearch(inputs, outputs, options);
      }

    } catch (Exception e) {
      outputs.put('Error', e.getMessage());
      outputs.put('ErrorLine', e.getLineNumber());
      outputs.put('ErrorType', e.getTypeName());
      outputs.put('MethodName', methodName);
      System.debug('ERROR: ------> ' + e);
    }

    return false;
  }

  private static Boolean querySearch(
    Map<String, Object> inputs,
    Map<String, Object> outputs,
    Map<String, Object> options
  ) {
    
    String RadioUserType = (String)inputs.get('RadioUserType'); 
    String ProviderFirstName = (String)inputs.get('ProviderFirstName');
    String ProviderLastName = (String)inputs.get('ProviderLastName');
    String ProviderID = (String)inputs.get('ProviderID'); 
    String ProviderNPI = (String)inputs.get('ProviderNPI'); 
    String FacilityName = (String)inputs.get('FacilityName'); 
    String FacilityNPI = (String)inputs.get('FacilityNPI'); 
    String LeadFirstName = (String)inputs.get('LeadFirstName'); 
    String LeadLastName = (String)inputs.get('LeadLastName'); 
    String LeadPhoneNumber = (String)inputs.get('LeadPhoneNumber'); 
    String MemberFirstName = (String)inputs.get('MemberFirstName');
    String MemberLastName = (String)inputs.get('MemberLastName'); 
    String MemberPhoneNumber = (String)inputs.get('MemberPhoneNumber'); 
    String MemberDateOfBirth = (String)inputs.get('MemberDateOfBirth');  
    String MemberID = (String)inputs.get('MemberID'); 
    String MemberLast4SocialSecurityNumber = (String)inputs.get('MemberLast4SocialSecurityNumber');
    // Integer MemberLast4SocialSecurityNumber = (Integer)inputs.get('MemberLast4SocialSecurityNumber');

    try {
        
        String query = 'SELECT personmobilephone, firstname, member_id__c, recordtypeid, parentid, lastname, ssn__c, ispersonaccount, personhomephone, work_phone__c, personbirthdate, name, id, personcontactid, abcbs_id__c, npi__c FROM Account';
                
        if (RadioUserType.equals('Provider')) {
            query+=' WHERE isPersonAccount = true AND recordTypeId IN (SELECT id FROM RecordType WHERE DeveloperName = \'Provider\' AND SobjectType = \'Account\')';

            if(!String.isEmpty(ProviderFirstName)) {
                ProviderFirstName = '%'+ProviderFirstName+'%'; 
                query+=' AND FirstName LIKE \''+ProviderFirstName+'\'';
            }

            if(!String.isEmpty(ProviderLastName)) {
                ProviderLastName = '%'+ProviderLastName+'%'; 
                query+=' AND LastName LIKE \''+ProviderLastName+'\'';
            }

            if(!String.isEmpty(ProviderID)) {
                query+=' AND ABCBS_ID__c = \''+ProviderID+'\'';
            }

            if(!String.isEmpty(ProviderNPI)) {
                query+=' AND NPI__c = \''+ProviderNPI+'\'';
            }
            
        } else if(RadioUserType.equals('Member')) {
            query+=' WHERE isPersonAccount = true and recordTypeId IN (SELECT id FROM RecordType WHERE DeveloperName = \'Member\' AND SobjectType = \'Account\')';

            if(!String.isEmpty(MemberFirstName)) {
                MemberFirstName = '%'+MemberFirstName+'%'; 
                query+=' AND FirstName LIKE \''+MemberFirstName+'\'';
            }

            if(!String.isEmpty(MemberLastName)) {
                MemberLastName = '%'+MemberLastName+'%';
                query+=' AND LastName LIKE \''+MemberLastName+'\'';
            }

            if(!String.isEmpty(MemberDateOfBirth)) {
                String year = MemberDateOfBirth.substring(0, 4);
                String month = MemberDateOfBirth.substring(5, 7);
                String day = MemberDateOfBirth.substring(8, 10);
                String stringDate = year + '-' + month+ '-' + day;

                query+=' AND PersonBirthdate = '+stringDate+'';
            }

            if(!String.isEmpty(MemberPhoneNumber)) {
                query+=' AND (PersonMobilePhone = \''+MemberPhoneNumber+'\' OR PersonHomePhone = \''+MemberPhoneNumber+'\' OR Work_Phone__c = \''+MemberPhoneNumber+'\')';
            }

            // if(MemberLast4SocialSecurityNumber != null) {
            //     query+=' AND SSN__c = \''+MemberLast4SocialSecurityNumber+'\'';
            // }

            if(!String.isEmpty(MemberLast4SocialSecurityNumber)) {
                query+=' AND SSN__c = \''+MemberLast4SocialSecurityNumber+'\'';
            }

        } else if(RadioUserType.equals('Facility')) {
            query+=' WHERE isPersonAccount = false and recordTypeId IN (SELECT id FROM RecordType WHERE DeveloperName = \'AccountRecord\' AND SobjectType = \'Account\')'; 

            if(!String.isEmpty(FacilityName)) {
                FacilityName = '%'+FacilityName+'%';
                query+=' AND Name LIKE \''+FacilityName+'\'';
            }

            if(!String.isEmpty(FacilityNPI)) {
                query+=' AND NPI__c = \''+FacilityNPI+'\'';
            }

        } else if(RadioUserType.equals('Prospect')) {
            query = '';
            query+='SELECT name, firstname, phone, middlename, id, recordtypeid, lastname FROM lead';
            query+=' WHERE recordTypeId IN (SELECT id FROM RecordType WHERE DeveloperName = \'CCI_Prospective_Member\' AND SobjectType = \'Lead\')';  
            
            if(!String.isEmpty(LeadFirstName)) {
                LeadFirstName = '%'+LeadFirstName+'%';
                query+=' AND FirstName LIKE \''+LeadFirstName+'\'';
            }

            if(!String.isEmpty(LeadLastName)) {
                LeadLastName = '%'+LeadLastName+'%';
                query+=' AND LastName LIKE \''+LeadLastName+'\'';
            }

            if(!String.isEmpty(LeadPhoneNumber)) {
                query+=' AND Phone = \''+LeadPhoneNumber+'\'';
            }
        }

        query+=' ORDER BY FirstName LIMIT 10';
        System.debug(query);

        List<Object> listDataBase = Database.query(query);

        if(!listDataBase.isEmpty()) {
            outputs.put('Detail', listDataBase);
            outputs.put('hasData', true);
        } else {
            outputs.put('Detail', null);
            outputs.put('hasData', false);
        }
       
    } catch (Exception e) {
        outputs.put('Error', e.getMessage());
        outputs.put('ErrorLine', e.getLineNumber());
        outputs.put('ErrorType', e.getTypeName());
        System.debug('ERROR: ------> ' + e);
    }

    return true;
  }

}