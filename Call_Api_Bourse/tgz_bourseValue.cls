public class tgz_bourseValue{
    
    //Attribute of the class
    public String valueBourse{get;set;}
    private Account account{get;set;}
    private ApexPages.StandardController sctrl;
  
    public tgz_bourseValue(ApexPages.StandardController stdController)
    {
        //Initialisation
        String symbolBourse;
        this.sctrl = stdController;
        
        Account account = (Account)stdController.getRecord();
        this.account = [SELECT Id, symbolBourse__c FROM Account WHERE Id =: account.id ]; 
        symbolBourse = this.account.symbolBourse__c;
       
        System.debug('Account: '+account);
        System.debug('Symbol Bourse: '+symbolBourse);

        HttpResponse rep = tgz_callBourseAPI.calloutBourse(symbolBourse);
        System.debug('Réponse API: '+rep.getBody());
        
        if(rep.getStatusCode() == 200)
        {
            this.valueBourse = getValue(rep.getBody());
        	System.debug('Valeur Bourse: ' + valueBourse);
        }
        else
        {
            this.valueBourse = 'Symbole invalide ou plus de jeton pour appeler l\'API';
        }
        
    }
   
    
    //Maj account et retour à la page précédente
    public PageReference MajTempAndBack(){
        
        this.account.valueBourse__c = this.valueBourse;
    	update account;
        PageReference cancel = sctrl.cancel();
        return cancel;
    }
     
    public static String getValue(String bodyResponse)
    {
        Map<String, Object> resultMap= (Map<String,Object>)JSON.deserializeUntyped(bodyResponse);
        List<Object> resultList = (List<Object>)resultMap.get('data');
        resultMap = (Map<String,Object>)resultList[0]; 
        String valueBourse = String.valueOf(resultMap.get('open'));
        return valueBourse;
    }  
}