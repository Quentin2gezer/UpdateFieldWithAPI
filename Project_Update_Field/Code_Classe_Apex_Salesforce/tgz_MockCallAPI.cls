@isTest
global class tgz_mockCallAPI implements HttpCalloutMock {
    
    global static HttpResponse respond(HttpRequest request)
    {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type','application/json');
        response.setBody('{"coord":{"lon":-0.5805,"lat":44.8404},"weather":[{"id":701,"main":"Mist","description":"mist","icon":"50d"}],"base":"stations","main":{"temp":284.3,"feels_like":283.9,"temp_min":284.3,"temp_max":284.45,"pressure":1014,"humidity":93},"visibility":4500,"wind":{"speed":1.54,"deg":0},"clouds":{"all":100},"dt":1650873234,"sys":{"type":1,"id":6450,"country":"FR","sunrise":1650862881,"sunset":1650913137},"timezone":7200,"id":3031582,"name":"Bordeaux","cod":200}');
    	response.setStatusCode(200);
        return response;
    }    		 
}