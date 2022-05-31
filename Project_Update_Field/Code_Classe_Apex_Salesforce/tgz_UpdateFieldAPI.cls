public with sharing class tgz_UpdateFieldAPI{
     
   // Renvoie tous les Custom Setting (=CS) correspondant à ce que l'utilisateur écrit dans la barre de recherche 
   @AuraEnabled(cacheable=true)
   public static List<updateCustomFieldApiCS__c> getCS(String searchKey) {
      
       String query = 'SELECT id, Name, objectName__c, objectID__c, fieldName__c, Update_on_page_load__c, Update_Every_Hour__c FROM updateCustomFieldApiCS__c';
       if ( searchKey != null && searchKey != '' ) {
           String key = '%' + searchKey + '%';
           query += ' WHERE Name LIKE :key';
       }
       
       query = query + ' LIMIT 10';
       return Database.query( query );
   }
    
    //Important que ce soit @AuraEnabled et non @AuraEnabled(cacheable=true) pour éviter "Too many DML statement 1"
    //Renvoie tous les CS ayant la case "Update_on_page_load__c" cochée. 
    @AuraEnabled
    public static List<String> getMajAutomaticallyCS() {
        
  		List<updateCustomFieldApiCS__c> cs =[SELECT id, Name, objectName__c, objectID__c, fieldName__c, urlApi__c, Update_Every_Hour__c
            								FROM updateCustomFieldApiCS__c
            								WHERE Update_on_page_load__c= true];

        //listInvalideCS est une liste contenant les CS invalides 
        List<String> listInvalideCS = updateObject(cs);
        return listInvalideCS;
    }
    
   //Permet de supprimer un CS depuis le tableau Datatable
   @AuraEnabled  
   public static void deleteCS(List<updateCustomFieldApiCS__c> csList){  
     delete csList;  
   }  
    
    //Fonction principale permettant de mettre à jour un champ grâce à un appel d'API
    @AuraEnabled 
    public static List<String> updateObject(List<updateCustomFieldApiCS__c> nameCustomSettingMAJ)
    {
        // Indique si la'objet cherché a été trouvé
        boolean isFound = true;
        
        // Liste contenant l'ensemble des valeurs que nous allons affecter aux champs
        List<String> listVal = new List<String>();
        
        List<String> listInvalideCS = new List<String>();
        integer i = 0;
        
        for(updateCustomFieldApiCS__c cs : nameCustomSettingMAJ )
        {
       		// Récupération des valeurs présentes dans le Custom Setting
       		cs = updateCustomFieldApiCS__c.getValues(cs.Name);
   	               
            // Appel de l'API
       		HttpResponse rep = tgz_SaveCallAPI.calloutAPI(cs.urlApi__c); 
      		
            //Récupération de la valeur à affecter au champ de l'objet
            String val= getDesiredValue(rep.getBody(), cs.Name);            
        
        	listVal.add(val);
        }
        
        for(updateCustomFieldApiCS__c cs : nameCustomSettingMAJ )
        {
       		// Récupération des valeurs présentes dans le Custom Setting
       		cs = updateCustomFieldApiCS__c.getValues(cs.Name);
    		String objectID = cs.objectID__c;
   	        
 	    	//Génération du type d'Objet concerné ('Account', 'Contact', ...)
  			Schema.SObjectType convertType = Schema.getGlobalDescribe().get(cs.objectName__c);
			Sobject genericObject = convertType.newSObject();

            // Récupération de l'Objet concerné
        	String query = 'SELECT Id, ' + cs.fieldName__c + ' FROM '+cs.objectName__c+' WHERE Id =: objectID';
			genericObject = Database.query(query);
       
            if(listVal.get(i) != null) // Paramètres du CS valides.
            {
                Object o = genericObject.get(cs.fieldName__c);
                genericObject.put(cs.fieldName__c, listVal.get(i));
                update genericObject;
            }
            else // Paramètres du CS invalides.
            {
                listInvalideCS.add(nameCustomSettingMAJ.get(i).Name);
            }

            i++;
        }
        return listInvalideCS;
    }
     
    public static String getDesiredValue(String body, String nameCustomSetting)
    {
        // Récupération des valeurs présentes dans le Custom Setting
        updateCustomFieldApiCS__c cs = updateCustomFieldApiCS__c.getValues(nameCustomSetting);

        String valueDesired; // Valeur que nous souhaitons affecter au champ de l'objet

        // Liste contenant l'ensemble des variables permettant de récupérer le premier objet cherché
        List<String> listVarSearched1 = new List<String>();
        
        //Récupération de toutes les variables présentes dans le CS permettant d'accéder à 'valueDesired' 
        if(cs.varSearchedObject__c != null)
        {
            listVarSearched1.add(cs.varSearchedObject__c);
        }
        if(cs.varSearchedObject2__c != null)
        {
            listVarSearched1.add(cs.varSearchedObject2__c);
        }
        if(cs.varSearchedObject3__c != null)
        {
            listVarSearched1.add(cs.varSearchedObject3__c);
        }
        if(cs.varSearchedObject4__c != null)
        {
            listVarSearched1.add(cs.varSearchedObject4__c);
        }
        if(cs.varSearchedObject5__c != null)
        {
            listVarSearched1.add(cs.varSearchedObject5__c);
        }
        if(cs.varSearchedObject6__c != null)
        {
            listVarSearched1.add(cs.varSearchedObject6__c);
        }
        
        // Liste contenant l'ensemble des variables permettant de récupérer le premier objet cherché
        List<String> listVarSearched2 = new List<String>();
        
        if(cs.varSecondSearchedObject1__c != null)
        {
            listVarSearched2.add(cs.varSecondSearchedObject1__c);
        }
        if(cs.varSecondSearchedObject2__c != null)
        {
            listVarSearched2.add(cs.varSecondSearchedObject2__c);
        }
        if(cs.varSecondSearchedObject3__c != null)
        {
            listVarSearched2.add(cs.varSecondSearchedObject3__c);
        }
        if(cs.varSecondSearchedObject4__c != null)
        {
            listVarSearched2.add(cs.varSecondSearchedObject4__c);
        }
        if(cs.varSecondSearchedObject5__c != null)
        {
            listVarSearched2.add(cs.varSecondSearchedObject5__c);
        }
        if(cs.varSecondSearchedObject6__c != null)
        {
            listVarSearched2.add(cs.varSecondSearchedObject6__c);
        }
        
        String result= body;
        Map<String, Object> resultObjMap;
        
   		// Si il y a des variables permettant de récuéprer le premier Objet
        if(listVarSearched1.size()>0)
   	    {
            //enterParty retourne le plus grand objet répondant aux exigences.
            //Ex pour ce JSON: '[{"code": 12, "univ": {"alpha_two_code": "FR", "ville": Bordeaux}}, {"code": 12, "univ": {"alpha_two_code": "FR", "ville": Anglet}}]
            //Si l'on cherche l'objet ayant Bordeaux comme ville, enterParty nous renverra cet objet:
            //{"code": 12, "univ": {"alpha_two_code": "FR", "ville": Bordeaux}} et non celui-ci {"alpha_two_code": "FR", "ville": Bordeaux}.
            
           	resultObjMap = enterParty(result, listVarSearched1, cs.valueVarSearchedObject__c);
            
            // JSON.serialize permet de convertir un Map en String, String.valueOf(...) provoque des erreurs.
            result = JSON.serialize(resultObjMap);
        }
        // Si il y a des variables permettant de récupérer le deuxième Objet
        if(listVarSearched2.size()>0)
   	    {
           	resultObjMap = enterParty(result, listVarSearched2, cs.valueVarSecondSearchedObject__c);
       		result = String.valueOf(resultObjMap.get(cs.variableChercheeApi__c));
        }
        else
        {
            // Grâce à enterParty nous avons récupéré l'objet souhaité et donc on  peut maintenant récupérer
            // la valeur de la variable qui sera affectée à un champ
            result = String.valueof(((Map<String, Object>)JSON.deserializeUntyped(result)).get(cs.variableChercheeApi__c));
        }
     	
        System.debug('ResultFinal: '+result); 	   
      	return result;
  	}
    
     public static Map<String, Object> enterParty(String result, List<String> listVarSearched,String valueVarSearched)
     {     
         
        Map<String, Object> objMap;  //Stock le map courant.
        List<Object> liste;
        integer index =0;
        integer indexTamp; //Integer utilisé pour ne pas modifier la variable “index” 
        //(afin qu'il puisse être chaque objet ) et étant égale à celui-ci
        
        boolean isFound =false; // Indique si la'objet cherché a été trouvé
         
        // Traitement effectué si c'est une liste
        if(JSON.deserializeUntyped(result) instanceof Map<String, Object>)
      	{
            objMap = (Map<String, Object>)JSON.deserializeUntyped(result);
            
            // Boucle permettant de rentrer dans le plus de Map possible 
            while(objMap.get(listVarSearched.get(index)) instanceof Map<String, Object>)
            {
                objMap = (Map<String, Object>)objMap.get(listVarSearched.get(index));
                index ++;
                if(index >= listVarSearched.size())break;
            }
            
            // On continu le traitement si il reste encore des variables dans 'listVarSearched'
            if(index < listVarSearched.size())
        	{
            	if(objMap.get(listVarSearched.get(index)) instanceof List<Object>)
        		{
            		liste = (List<Object>)objMap.get(listVarSearched.get(index));
                    index++;
					
                    indexTamp=index;
                    
                    // On parcourt chaque objet de la liste
                    for(Object obj : liste)
           			{
                        // On converti en Map l'objet courant de la liste
                		objMap =(Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                        
                        // Boucle permettant de rentrer dans le plus de Map possible
                		while(objMap.get(listVarSearched.get(indexTamp)) instanceof Map<String, Object>)
            			{
                			objMap = (Map<String, Object>)objMap.get(listVarSearched.get(indexTamp));
                			indexTamp++;
                			if(indexTamp >= listVarSearched.size())break;
            			}
	        	
                		if(indexTamp < listVarSearched.size())
                		{
                    		if(objMap.get(listVarSearched.get(indexTamp)) instanceof List<Object>)
                    		{
                        		liste = (List<Object>)objMap.get(listVarSearched.get(indexTamp));
                        		indexTamp ++;
                                
                                // recurrence renvoie true si l'objet courant est celui que l'on recherche
                        		if(recurrence(liste, listVarSearched, indexTamp, valueVarSearched, result) == true)
                                {
                                    isFound = true;
                                    break;
                                }
                    		}
                    		else if( objMap.get(listVarSearched.get(indexTamp)) == valueVarSearched || String.valueOf(objMap.get(listVarSearched.get(indexTamp))) == valueVarSearched)
                            {
                                isFound = true;
                                break;
                            }
                		}
                		else if( obj == valueVarSearched || String.valueOf(obj) == valueVarSearched)
                        {
                            isFound = true;
                            break; 
                        }
                        indexTamp=index;
    	    		}
        		}
        	}
   	   	}
        else if(JSON.deserializeUntyped(result) instanceof List<Object>)
       	{
			liste = (List<Object>)JSON.deserializeUntyped(result);
            
            for(Object obj : liste)
           	{
                objMap =(Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                
                while(objMap.get(listVarSearched.get(index)) instanceof Map<String, Object>)
            	{
                	objMap = (Map<String, Object>)objMap.get(listVarSearched.get(index));
                	index++;
                	if(index >= listVarSearched.size())break;
            	}
	        	
                if(index < listVarSearched.size())
                {
                    if(objMap.get(listVarSearched.get(index)) instanceof List<Object>)
                    {
                        liste = (List<Object>)objMap.get(listVarSearched.get(index));
                        index ++;
                        if(recurrence(liste, listVarSearched, index, valueVarSearched, result) == true)
                        {
                            isFound = true;
                            break;
                        }
                    }
                    else if( objMap.get(listVarSearched.get(index)) == valueVarSearched || String.valueOf(objMap.get(listVarSearched.get(index))) == valueVarSearched)
                    {
                        isFound = true;
                        break;
                    }
                }
                else if( obj == valueVarSearched || String.valueOf(obj) == valueVarSearched)
                {
                    isFound = true;
                    break;  
                }
                
               	if(index < listVarSearched.size())
                {
                	if(objMap.get(listVarSearched.get(index)) == null)
            		{
                  		objMap = null; 
              		}
                }
                index =0;
    	    }
        }
        
        if(valueVarSearched != null && isFound ==  false)
        {
            objMap = null;
        }
         
        return objMap;    
  	}
    
    public static boolean recurrence(List<Object> listeObject, List<String> listVarSearched,
                                     integer index, String valueVarSearched, String mapTampString)
    {
        Map<String, Object> objMap;
        integer indexTamp = index;
        boolean isFound = false;
        
        for(Object obj : listeObject)
        {
         	if(JSON.deserializeUntyped(JSON.serialize(obj)) instanceof Map<String,Object>)
           	{
           		objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
              	
                // mapTampString permet de garder en mémoire le Map de l’itération précédente.
                mapTampString = JSON.serialize(objMap);
                
                if(indexTamp < listVarSearched.size())
                {
                    while(objMap.get(listVarSearched.get(indexTamp)) instanceof Map<String, Object>)
              		{
               			objMap = (Map<String, Object>)objMap.get(listVarSearched.get(indexTamp));
               			indexTamp ++;
                   		if(indexTamp >= listVarSearched.size())break;
               		}
                }
        	   	
    	       	if(indexTamp < listVarSearched.size())
           	    {    
           			if(objMap.get(listVarSearched.get(indexTamp)) instanceof List<Object>)
                   	{
                       	List<Object> uneListe = (List<Object>)objMap.get(listVarSearched.get(indexTamp));
                       	indexTamp++;
            	        isFound = recurrence(uneListe, listVarSearched, indexTamp, valueVarSearched, mapTampString);

                        if(isFound == true)break;
                   	}
                   	else
                    {
                        if( objMap.get(listVarSearched.get(indexTamp)) == valueVarSearched ||
                           String.valueOf(objMap.get(listVarSearched.get(indexTamp))) == valueVarSearched)
                      	{	
                            isFound = true;
                       	  	break;
                       	}
       		      	}
              	}
                else
                {
                    if( obj == valueVarSearched || String.valueOf(obj) == valueVarSearched)
            		{
                        isFound = true;
  	      		  		break;
 	          		}
                }
         	}
            else
           	{   
          		if( obj == valueVarSearched || String.valueOf(obj) == valueVarSearched)
            	{	
                    isFound = true;
  	      		  	break;
 	          	}
           	}
            indexTamp = index ;
        }
        return isFound;
    }    
}