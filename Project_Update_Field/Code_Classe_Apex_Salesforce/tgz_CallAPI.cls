public class tgz_SaveCallAPI {
    
    public static HttpResponse calloutAPI(String urlApi)
    {     
        //Requete Api
        Http http=new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(urlApi);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
       
        /*
        if(response.getStatusCode()==200)
        {
            ApexPages.Message myMsg= new ApexPages.Message(ApexPages.Severity.ERROR, 'Il y a une erreur');
        	ApexPages.addMessage(myMsg);  

        }
        */
        return response;
    }


}