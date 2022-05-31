@isTest
public class tgz_testSchedulable {
    
    @isTest static void testSchedulable() {
	
        Account acc = new Account();
        acc.Name= 'acc1';
        insert acc;
        
        updateCustomFieldApiCS__c setting = new updateCustomFieldApiCS__c();
		setting.Name = 'TestCS';
		setting.fieldName__c = 'temperature__c';
        setting.objectName__c = 'Account';
        setting.variableChercheeApi__c = 'temp';
		setting.objectID__c = String.valueOf(acc.Id);
        setting.urlApi__c = 'https://api.openweathermap.org/data/2.5/weather?q=Bordeaux&appid=c0532c5354d86e09a5a965986b147ec9';
        setting.varSearchedObject__c = 'main';
        setting.Update_Every_Hour__c = true;
        insert setting;
        
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new tgz_mockCallAPI());
		String jobId = System.schedule('testBasicScheduledApex',
      		'0 1 * * * ?', 
        	new tgz_ScheduleUpdateField());
    }
}