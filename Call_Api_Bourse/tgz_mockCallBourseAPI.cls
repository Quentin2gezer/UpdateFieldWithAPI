@isTest
global class tgz_mockCallBourseAPI implements HttpCalloutMock {
    
    global static HttpResponse respond(HttpRequest request)
    {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type','application/json');
        response.setBody('{"pagination":{"limit":100,"offset":0,"count":100,"total":252},"data":[{"open":140.28,"high":140.76,"low":137.06,"close":137.13,"volume":91437900.0,"adj_high":null,"adj_low":null,"adj_close":137.13,"adj_open":null,"adj_volume":null,"split_factor":1.0,"dividend":0.0,"symbol":"AAPL","exchange":"XNAS","date":"2022-06-10T00:00:00+0000"}]}');
    	response.setStatusCode(200);
        return response;
    }    		 
}