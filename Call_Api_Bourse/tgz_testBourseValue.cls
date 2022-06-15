@isTest
public class tgz_testBourseValue {
    
    @isTest
    public static void testBourseValue() {
       
        Account acc = new Account(Name = 'TestAccountName', symbolBourse__c = 'AAPL');
        insert acc;
        
        Test.startTest();
         
		System.Test.setMock(HttpCalloutMock.class, new tgz_mockCallBourseAPI());
        
		ApexPages.StandardController sc = new ApexPages.standardController(acc);
		tgz_bourseValue controller = new tgz_bourseValue(sc);   
        System.assertEquals(controller.valueBourse,'140.28');
        controller.MajTempAndBack();
        
        Test.stopTest();
    }

}