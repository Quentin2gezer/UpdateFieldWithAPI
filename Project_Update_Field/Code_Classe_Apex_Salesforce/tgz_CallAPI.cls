public class tgz_SaveCallAPI {
    
    public static list<String> calloutAPI(String urlApi)
    {     
        //Début du chronomètre
        datetime myDateTimeStart = datetime.now();
        Integer secondStart = myDateTimeStart.second();
        Integer millisecondStart = myDateTimeStart.millisecond();
        
        
        //Requete Api
        Http http=new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(urlApi);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        //Calcul temps requête
        datetime myDateTimeEnd = datetime.now();
        Integer secondEnd = myDateTimeEnd.second();
        Integer millisecondEnd = myDateTimeEnd.millisecond();
        
        Integer nbSecond = secondEnd - secondStart;
        String timerString;
        Integer nbMillisecond;
        
        if(nbSecond == 0)
       	{
       		timerString = String.valueOf(millisecondEnd - millisecondStart);
            timerString += ' ms';
	 	}
        else
        {
            nbMillisecond = 1000 - millisecondStart + millisecondEnd ;
            if(nbMillisecond >= 1000)
            {
                nbSecond = nbSecond +1;
                nbMillisecond = nbMillisecond - 1000;
            }

            timerString = String.valueOf(nbSecond);
            timerString += ' sec ';
            timerString += String.valueOf(nbMillisecond);
            timerString += ' ms';
        }
     
        System.debug('calloutAPI: #2');
       	List<tgz_Debug_LogV2__c> listModeDebugCS = [Select Activation_Mode_Debug__c From tgz_Debug_LogV2__c];
       	boolean isActivate =  listModeDebugCS.get(0).Activation_Mode_Debug__c;
        
        List<String> listString = new list<String>();
        System.debug('calloutAPI: Response: '+response.getBody());

      	listString.add(response.getBody());
        listString.add(String.valueOf(response.getStatusCode()));
        String statutCode;
        
   
        if(isActivate == true || response.getBody() == '[]' || response.getStatusCode() != 200)
        {
            listString.add(String.valueOf(DateTime.now()));
            statutCode = String.valueOf(response.getStatusCode());
            statutCode +=': ';
            statutCode += response.getStatus();
            listString.add(statutCode);
            listString.add(urlApi);
           	listString.add(timerString);
        }

        
        System.debug('ListString: '+listString);
        return listString;
    }
}
