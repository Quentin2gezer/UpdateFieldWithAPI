@isTest
public class tgz_testComponentUpdateFieldAPI {
    
    @isTest static void testGetMajAutomaticallyCS()
    {
        Account acc = new Account();
        acc.Name= 'acc1';
        insert acc;
        
        List<updateCustomFieldApiCS__c> listCS = new List<updateCustomFieldApiCS__c>();
        updateCustomFieldApiCS__c setting = new updateCustomFieldApiCS__c();
		setting.Name = 'TestCS';
		setting.fieldName__c = 'temperature__c';
        setting.objectName__c = 'Account';
        setting.variableChercheeApi__c = 'temp';
		setting.objectID__c = String.valueOf(acc.Id);
        setting.urlApi__c = 'https://api.openweathermap.org/data/2.5/weather?q=Bordeaux&appid=c0532c5354d86e09a5a965986b147ec9';
        setting.varSearchedObject__c = 'main';
        setting.Update_Every_Hour__c = true;
                
        insert listCS;
        
        Test.startTest();
        
        List<String> listString;
        
		System.Test.setMock(HttpCalloutMock.class, new tgz_mockCallAPI()); 
  		System.assertEquals(tgz_componentUpdateFieldAPI.getMajAutomaticallyCS().size(),0);
        
        Test.stopTest();
    }

    @isTest static void testUpdateObject()
    {
        
        Account acc = new Account();
        acc.Name= 'acc1';
        insert acc;
        
        List<updateCustomFieldApiCS__c> listCS = new List<updateCustomFieldApiCS__c>();
        updateCustomFieldApiCS__c setting = new updateCustomFieldApiCS__c();
		setting.Name = 'TestCS';
		setting.fieldName__c = 'temperature__c';
        setting.objectName__c = 'Account';
        setting.variableChercheeApi__c = 'temp';
		setting.objectID__c = String.valueOf(acc.Id);
        setting.urlApi__c = 'https://api.openweathermap.org/data/2.5/weather?q=Bordeaux&appid=c0532c5354d86e09a5a965986b147ec9';
        setting.varSecondSearchedObject1__c = 'main';
        listCS.add(setting);
        insert listCS;
          
        Test.startTest();
        
		System.Test.setMock(HttpCalloutMock.class, new tgz_mockCallAPI());        
  		System.assertEquals(tgz_componentUpdateFieldAPI.updateObject(listCS).size(),0);
        
        Test.stopTest();
    }
    
	@isTest static void testGetCS()
    {
        updateCustomFieldApiCS__c setting = new updateCustomFieldApiCS__c();
		setting.Name = 'TestCS';
		setting.fieldName__c = 'temperature__c';
        setting.objectName__c = 'Account';
        setting.variableChercheeApi__c = 'temp';
		setting.objectID__c = '0017Q00000FN4SSQA1';
        setting.urlApi__c = 'https://api.openweathermap.org/data/2.5/weather?q=Bordeaux&appid=c0532c5354d86e09a5a965986b147ec9';
        setting.Update_on_page_load__c = true;
        setting.varSearchedObject__c = 'main';
        List<updateCustomFieldApiCS__c> listCS2 = new List<updateCustomFieldApiCS__c>();
        listCS2.add(setting);
        insert setting;
     
        List<updateCustomFieldApiCS__c> listCS = tgz_componentUpdateFieldAPI.getCS('TestCS');
        updateCustomFieldApiCS__c cs = listCS.get(0);
        
        System.assertEquals(cs.Name,'TestCS');
        
        tgz_componentUpdateFieldAPI.deleteCS(listCS2);
        
       
    }
  
    @isTest static void testCustomSettingV2() {
        
        updateCustomFieldApiCS__c setting1 = new updateCustomFieldApiCS__c();
		setting1.Name = 'TestCS';
		setting1.fieldName__c = 'temperature__c';
        setting1.objectName__c = 'Account';
        setting1.variableChercheeApi__c = 'temp';
		setting1.objectID__c = '0017Q00000FN4SSQA1';
        setting1.urlApi__c = 'https://api.openweathermap.org/data/2.5/weather?q=Bordeaux&appid=c0532c5354d86e09a5a965986b147ec9';
   		setting1.varSecondSearchedObject1__c = 'sp1';
        setting1.varSecondSearchedObject2__c = 'sp2';
        setting1.varSecondSearchedObject3__c = 'sp3';
        setting1.varSecondSearchedObject4__c = 'sp4';
        setting1.varSecondSearchedObject5__c = 'sp5';
        setting1.varSecondSearchedObject6__c = 'main';
        
        insert setting1;
        
        String body ='{"sp1": {"sp2": {"sp3": {"sp4": {"sp5": {"coord": {"lon": -0.5805, "lat": 44.8404}, "weather": [{"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}], "base": "stations", "main": {"temp": 302.3, "feels_like" :301.04, "temp_min": 302.3, "temp_max": 303.9, "pressure": 1020, "humidity": 28}, "visibility": 10000, "wind": {"speed": 2.06, "deg": 150}, "clouds": {"all": 0}, "dt": 1652183214, "sys": {"type": 1, "id": 6450, "country": "FR", "sunrise": 1652157598, "sunset": 1652210253}, "timezone": 7200, "id": 3031582, "name": "Bordeaux", "cod": 200}}}}}}';      
        String result1 = tgz_componentUpdateFieldAPI.getDesiredValue(body, setting1.Name);
       	System.assertEquals(result1,'302.3');

    }
    
        @isTest static void testEnterParty1() {
           	
             	
        String result = '[{"alpha_two_code": "FR", "domains": ["student.42.fr"], "country": "France", "state-province": null, "web_pages": ["http://www.42.fr/"], "name": "42 FR"}]'; 
            
        List<String> listVarSearched= new List<String>();
        listVarSearched.add('web_pages');
        String valueVarSearched = 'http://www.42.fr/';
		
        Map<String,Object> uneMap = tgz_componentUpdateFieldAPI.enterParty(result, listVarSearched,valueVarSearched );
       	System.assertEquals(uneMap.get('name'),'42 FR');
        
    }
    
        @isTest static void testEnterParty2() {
           	
             	
        String result = '{"univ": [{"alpha_two_code": "FR", "domains": {"listeTest": [{"ville": {"uneVille": [{"codePostal": {"test": "unTest"}}]}}]}, "country": "France", "state-province": null, "web_pages": ["http://www.42.fr/"], "name": "42 FR"}]}'; 
            
        List<String> listVarSearched= new List<String>();
        listVarSearched.add('univ');
        listVarSearched.add('domains');
        listVarSearched.add('listeTest');
        listVarSearched.add('ville');
        listVarSearched.add('uneVille');
        listVarSearched.add('codePostal');
        listVarSearched.add('test');
        
        String valueVarSearched = 'unTest';
		
        Map<String,Object> uneMap = tgz_componentUpdateFieldAPI.enterParty(result, listVarSearched,valueVarSearched );
       	System.assertEquals(uneMap.get('name'),'42 FR');
    }
    
    @isTest static void testEnterParty3() {
           	
             	
        String result = '{"univ": [{"alpha_two_code": "FR", "domains": {"listeTest": [{"ville": {"uneVille": ["Parempuyre"]}}]}, "country": "France", "state-province": null, "web_pages": ["http://www.42.fr/"], "name": "42 FR"}]}'; 
            
        List<String> listVarSearched= new List<String>();
        listVarSearched.add('univ');
        listVarSearched.add('domains');
        listVarSearched.add('listeTest');
        listVarSearched.add('ville');
        listVarSearched.add('uneVille');
        
        String valueVarSearched = 'Parempuyre';
		
        Map<String,Object> uneMap = tgz_componentUpdateFieldAPI.enterParty(result, listVarSearched,valueVarSearched );
       	System.assertEquals(uneMap.get('name'),'42 FR');
    } 
    
    
    @isTest static void testEnterParty4() {
           	
        String result2 = '{"univ": [{"alpha_two_code": "FR", "domains": {"listeTest": [{"ville": "Parempuyre"}]}, "country": "France", "state-province": null, "web_pages": ["http://www.42.fr/"], "name": "42 FR"}]}'; 
        List<String> listVarSearched2= new List<String>();
        listVarSearched2.add('univ');
        listVarSearched2.add('alpha_two_code');
        String valueVarSearched2 = 'FR';
        Map<String,Object> uneMap2 = tgz_componentUpdateFieldAPI.enterParty(result2, listVarSearched2,valueVarSearched2 );
        System.assertEquals(uneMap2.get('name'),'42 FR');
        
        
        String result5 = '{"univ": [{"alpha_two_code": "FR", "domains": {"listeTest": [{"ville": {"uneVille": [{"uneAutreVille": "Parempuyre"}]}}]}, "country": "France", "state-province": null, "web_pages": ["http://www.42.fr/"], "name": "42 FR"}]}'; 
        List<String> listVarSearched5= new List<String>();
        listVarSearched5.add('univ');
        listVarSearched5.add('domains');
        listVarSearched5.add('listeTest');
        listVarSearched5.add('ville');
        listVarSearched5.add('uneVille');
        listVarSearched5.add('uneAutreVille');
        String valueVarSearched5 = 'Parempuyre';
        Map<String,Object> uneMap5 = tgz_componentUpdateFieldAPI.enterParty(result5, listVarSearched5,valueVarSearched5 );
       	System.assertEquals(uneMap5.get('name'),'42 FR');
        
        String result6 = '{"univ": [{"alpha_two_code": "USA", "domains": {"listeTest": [{"ville": "Parempuyre"}]}, "country": "France", "state-province": null, "web_pages": ["http://www.42.fr/"], "name": "42 FR"},{"alpha_two_code": "FR", "domains": {"listeTest": [{"ville": "Parempuyre"}]}, "country": "France", "state-province": null, "web_pages": ["http://www.42.fr/"], "name": "42 FR"}]}'; 
        List<String> listVarSearched6= new List<String>();
        listVarSearched6.add('univ');
        listVarSearched6.add('alpha_two_code');
        String valueVarSearched6 = 'FR';
        Map<String,Object> uneMap6 = tgz_componentUpdateFieldAPI.enterParty(result6, listVarSearched6,valueVarSearched6 );
        System.assertEquals(uneMap6.get('name'),'42 FR');

    }

    
    @isTest static void testGetDesiredValueTab() 
    {
        String result = '{"univ": [{"alpha_two_code": "FR", "domains": {"listeTest": [{"ville": {"uneVille": [{"uneAutreVille": "Parempuyre"}]}}]}, "country": "France", "state-province": null, "web_pages": ["http://www.42.fr/"], "name": "42 FR"}]}';         
        updateCustomFieldApiCS__c setting1 = new updateCustomFieldApiCS__c();
		setting1.Name = 'TestCS';
		setting1.fieldName__c = 'temperature__c';
        setting1.objectName__c = 'Account';
        setting1.variableChercheeApi__c = 'country';
		setting1.objectID__c = '0017Q00000FN4SSQA1';
        setting1.urlApi__c = 'https://api.openweathermap.org/data/2.5/weather?q=Bordeaux&appid=c0532c5354d86e09a5a965986b147ec9';
   		setting1.varSearchedObject__c = 'univ';
        setting1.varSearchedObject2__c = 'domains';
        setting1.varSearchedObject3__c = 'listeTest';
        setting1.varSearchedObject4__c = 'ville';
        setting1.varSearchedObject5__c = 'uneVille';
        setting1.varSearchedObject6__c = 'uneAutreVille';
        setting1.valueVarSearchedObject__c ='Parempuyre';
        insert setting1;
        
        System.assertEquals(tgz_componentUpdateFieldAPI.getDesiredValue(result, setting1.Name),'France');
        
    }
}