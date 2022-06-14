public with sharing class tgz_componentUpdateFieldAPI{
     
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
    
    @AuraEnabled
    public static integer getMajAutoCS() {
        
  		List<updateCustomFieldApiCS__c> cs =[SELECT id, Name, objectName__c, objectID__c, fieldName__c, urlApi__c, Update_Every_Hour__c
            								FROM updateCustomFieldApiCS__c
            								WHERE Update_on_page_load__c= true];
        System.debug('cs.size: '+cs.size());

        return cs.size();
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
        // Indique si l'objet cherché a été trouvé
        boolean isFound = true;
        
        // Liste contenant l'ensemble des valeurs que nous allons affecter aux champs
        List<String> listVal = new List<String>();
        
        // Liste contenant la liste des objets debug que nous allons insert
        List<tgz_tool_logs__c> listDebug = new List<tgz_tool_logs__c>();
        
        // Liste contenant le Name des cs ayant des paramètres invalides
        List<String> listInvalideCS = new List<String>();
        
        integer i = 0;
        String val;
        
        for(updateCustomFieldApiCS__c cs : nameCustomSettingMAJ )
        {
            System.debug('updateObject: listCS: '+ nameCustomSettingMAJ);
            System.debug('updateObject:  size listCS: '+ nameCustomSettingMAJ.size());
            
       		// Récupération de l'ensemble des paramètres présents dans le Custom Setting
       		cs = updateCustomFieldApiCS__c.getValues(cs.Name);
                
            if(cs.urlApi__c != null)
            {
                // Appel de l'API
                List<String> rep = tgz_SaveCallAPI.calloutAPI(cs.urlApi__c); 
            	System.debug('updateObject: Reponse API: '+rep.get(0));
                System.debug('Statut code: '+rep.get(1));
                
          		// Vérification de la valeur du body retournée par l'url 
                if(rep.get(0).equals('[]') == false && rep.get(1) == '200')
               	{
                    //Récupération de la valeur à affecter au champ de l'objet
               		val= getDesiredValue(rep.get(0), cs.Name);
            		System.debug('Valeur Retournée getDesiredValue: '+val);
                    
                    // Vérification de la valeur retournée par getDesiredValue
                    if(val == null || val == 'null')
                   	{
                      	System.debug('updateObject: Val getDesiredValue = Null');
                        listInvalideCS.add(cs.Name);
                   	}
                    else
                    {
                        listVal.add(val);
            			System.debug('Valeur Retournée getDesiredValue: '+val);
                    }                    
               	}
                else
                {
                    //Si erreur dans l'url
   					listInvalideCS.add(cs.Name);
                }
            	
                // Vérification si il y a des objets de debug à insert
            	if(rep.size()>2)
            	{
                    //Création de l'objet debug à insert
                	tgz_tool_logs__c HistoricDebug = new tgz_tool_logs__c();
            		HistoricDebug.Url__c = rep.get(4);
            		HistoricDebug.Date__c = rep.get(2);
            		HistoricDebug.Statut__c = rep.get(3);
                	HistoricDebug.temps_exe_requete__c = rep.get(5);
                    HistoricDebug.Corps_du_JSON__c = rep.get(0);
                	listDebug.add(HistoricDebug); 
                    System.debug('updateObject: Fin hydratation  objet debug: '+HistoricDebug);
           	 	}
            }
            else
            {
                // url == null
                listInvalideCS.add(cs.Name);
            }
        }
        
        for(updateCustomFieldApiCS__c cs : nameCustomSettingMAJ )
        {
            System.debug('updateObject: 2eme FOR');
            // Récupération de l'Objet (Account, Contact ...) concerné
            if(cs.fieldName__c != null && cs.objectName__c != null && cs.objectID__c != null )
            {
                // Récupération des valeurs présentes dans le Custom Setting
       			cs = updateCustomFieldApiCS__c.getValues(cs.Name);
    			String objectID = cs.objectID__c;
   	       
                if(listInvalideCS.contains(cs.Name) == false) // Paramètres du CS valides.
            	{
                    if(doesFieldExist(cs.objectName__c, cs.fieldName__c) == true) //On vérifie que le champ existe
                   	{
                        if(doesObjectExist(cs.objectName__c, cs.fieldName__c,objectID) == true)
                        {
                            //Génération du type d'Objet concerné ('Account', 'Contact', ...)
  							Schema.SObjectType convertType = Schema.getGlobalDescribe().get(cs.objectName__c);
							Sobject genericObject = convertType.newSObject();
                
                            // Récupération de l'objet concerné
                			String query = 'SELECT Id, ' + cs.fieldName__c + ' FROM '+cs.objectName__c+' WHERE Id =: objectID';
							genericObject = Database.query(query);

                            //Mise à jour de la valeur du champ de l'objet 
                    		genericObject.put(cs.fieldName__c, listVal.get(i));
                			update genericObject;
                            i++;
                        }
                        else
                        {
                            listInvalideCS.add(cs.Name);
                        }
                    }
                    else
                    {
                        listInvalideCS.add(cs.Name);
                    }
            	}
            }
            else 
            {
                if(listInvalideCS.contains(cs.Name) == false) // Paramètres du CS valides.
                {
                    listInvalideCS.add(cs.Name);
                }
            }
        }
        
        if(listDebug.size() > 0)
       	{                
          	for(tgz_tool_logs__c unDebug : listDebug)
           	{
                
                System.debug('Objet Degug Inséré: '+unDebug);
              	insert unDebug;

           	}
       	}
        return listInvalideCS;
    }
     
    // Fonction permettant de récupérer la valeur à affecter au champ de l'objet
    public static String getDesiredValue(String body, String nameCustomSetting)
    {
        // Récupération des valeurs présentes dans le Custom Setting
        updateCustomFieldApiCS__c cs = updateCustomFieldApiCS__c.getValues(nameCustomSetting);

        String valueDesired; // Valeur que nous souhaitons affecter au champ de l'objet

        // Liste contenant l'ensemble des variables permettant de récupérer le premier objet cherché
        List<String> listVarSearched1 = new List<String>();
        
        //Récupération de toutes les variables présentes dans le CS permettant de récupérer le premier objet cherché
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
        
        // Liste contenant l'ensemble des variables permettant de récupérer le deucième objet cherché
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
        
        //Permet de stocker le Map renvoyé par la fonction enterParty
        Map<String, Object> resultObjMap;
        
   		// Si il y a des variables permettant de récupérer le premier Objet
        if(listVarSearched1.size()>0)
   	    {
            //enterParty retourne le plus grand objet répondant aux exigences.
            //Ex pour ce JSON: '[{"code": 12, "univ": {"alpha_two_code": "FR", "ville": Bordeaux}}, {"code": 12, "univ": {"alpha_two_code": "FR", "ville": Anglet}}]
            //Si l'on cherche l'objet ayant Bordeaux comme ville, enterParty nous renverra cet objet:
            //{"code": 12, "univ": {"alpha_two_code": "FR", "ville": Bordeaux}} et non celui-ci {"alpha_two_code": "FR", "ville": Bordeaux}.
            
            System.debug('getDesiredValue: listVarSearched1.size()>0 ');
           	resultObjMap = enterParty(result, listVarSearched1, cs.valueVarSearchedObject__c);
            System.debug('getDesiredValue: result enterParty 1: '+resultObjMap);
            
            // JSON.serialize permet de convertir un Map en String, String.valueOf(...) provoque des erreurs.
            result = JSON.serialize(resultObjMap);
            System.debug('getDesiredValue: result 1: '+result);
        }
        
        // Si il y a des variables permettant de récupérer le deuxième Objet
        if(listVarSearched2.size()>0 && result != 'null')
   	    {
            System.debug('getDesiredValue: listVarSearched2.size()>0 ');
           	resultObjMap = enterParty(result, listVarSearched2, cs.valueVarSecondSearchedObject__c);
            System.debug('getDesiredValue: result enterParty 2: '+resultObjMap);
            result = JSON.serialize(resultObjMap);
            
            if(result != 'null')
            {
                result = String.valueOf(resultObjMap.get(cs.variableChercheeApi__c));
            	System.debug('getDesiredValue: result final un deux objets à récup: '+result);
            }
       		
        }
        else
        {
            // Grâce à enterParty nous avons récupéré l'objet souhaité et donc on  peut maintenant récupérer
            // la valeur de la variable qui sera affectée à un champ
                    
            if(cs.variableChercheeApi__c != null && result != 'null' )
           	{
                result = String.valueof(((Map<String, Object>)JSON.deserializeUntyped(result)).get(cs.variableChercheeApi__c));
                System.debug('getDesiredValue: result final un un seul objet à récup: '+result);
            }
        }
        
        System.debug('getDesiredValue: Result Return'+ result);
       	return result;
  	}
    
     public static Map<String, Object> enterParty(String result, List<String> listVarSearched,String valueVarSearched)
     {     
        Map<String, Object> objMapTamp; // Map Tampon
        Map<String, Object> objMap;  //Stock le map courant.
        List<Object> liste; // liste des objets à parcourir
        integer index =0;
        integer indexTamp; //Integer utilisé pour ne pas modifier la variable “index” 
        //(afin qu'il puisse être chaque objet ) et étant égale à celui-ci
        
        boolean isFound =false; // Indique si l'objet cherché a été trouvé
         
        // Traitement effectué si c'est un Map
        if(JSON.deserializeUntyped(result) instanceof Map<String, Object>)
      	{
            System.debug('enterParty: isMap #1');
            objMap = (Map<String, Object>)JSON.deserializeUntyped(result);
            
            // Boucle permettant de rentrer dans le plus de Map possible 
            while(objMap.get(listVarSearched.get(index)) instanceof Map<String, Object>)
            {
                System.debug('enterParty: isMap #2: '+objMap);
                objMap = (Map<String, Object>)objMap.get(listVarSearched.get(index));
                index ++;
                if(index >= listVarSearched.size())break;
            }
            
            // On continu le traitement si il reste encore des variables dans 'listVarSearched'
            if(index < listVarSearched.size())
        	{
               	System.debug('enterParty: size>0 #1');
            	if(objMap.get(listVarSearched.get(index)) instanceof List<Object>)
        		{
            		liste = (List<Object>)objMap.get(listVarSearched.get(index));
                    System.debug('enterParty: isList #1'+liste);
                    index++;
					
                    indexTamp=index;
                    
                    // On parcourt chaque objet de la liste
                    for(Object obj : liste)
           			{
                        if(JSON.deserializeUntyped(JSON.serialize(obj)) instanceof Map<String, Object>)
                        {
                            // On converti en Map l'objet courant de la liste
                			objMap =(Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                        	objMapTamp = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));

                        	// Boucle permettant de rentrer dans le plus de Map possible
                			while(objMap.get(listVarSearched.get(indexTamp)) instanceof Map<String, Object>)
            				{
                            	System.debug('enterParty: isMap #3'+objMap);
                				objMap = (Map<String, Object>)objMap.get(listVarSearched.get(indexTamp));
                				indexTamp++;
                				if(indexTamp >= listVarSearched.size())break;
            				}
	        	
                			if(indexTamp < listVarSearched.size())
                        	{
                            	System.debug('enterParty: size>0 #2');
                    			if(objMap.get(listVarSearched.get(indexTamp)) instanceof List<Object>)
                    			{
                        			liste = (List<Object>)objMap.get(listVarSearched.get(indexTamp));
                                	System.debug('enterParty: isList #2: '+liste);
                        			indexTamp ++;
                                
                                	// recurrence renvoie true si l'objet courant est celui que l'on recherche
                        			if(recurrence(liste, listVarSearched, indexTamp, valueVarSearched, result) == true)
                                	{
                                    	System.debug('enterParty: Break recurrence #1');
                                    	isFound = true;
                                    	break;
                                	}
                    			}
                    			else if( objMap.get(listVarSearched.get(indexTamp)) == valueVarSearched || String.valueOf(objMap.get(listVarSearched.get(indexTamp))) == valueVarSearched)
                            	{
                                	System.debug('enterParty: Break #2');
                                	isFound = true;
                                	break;
                            	}
                                else
                            	{
                                	objMapTamp = null;        
                               	}
                			}	   
                        }
                        else if( obj == valueVarSearched || String.valueOf(obj) == valueVarSearched)
                       	{
                        	System.debug('enterParty:Break #3');
                           	isFound = true;
                           	break; 
                        }
                        indexTamp=index;
    	    		}
        		}
        	}
            else
            {
				System.debug('enterParty: else du if size >0 #1: '+objMapTamp);
                objMapTamp = objMap;
            }

   	   	}
        else if(JSON.deserializeUntyped(result) instanceof List<Object>)
       	{
			liste = (List<Object>)JSON.deserializeUntyped(result);
            System.debug('enterParty: isList #3(elif du premier if Map): '+liste);
                        
            for(Object obj : liste)
           	{
                if(JSON.deserializeUntyped(JSON.serialize(obj)) instanceof Map<String,Object>)
                {
                    objMapTamp = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                	objMap =(Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                
                	while(objMap.get(listVarSearched.get(index)) instanceof Map<String, Object>)
            		{
                    	System.debug('enterParty: isMap#4: '+objMap);
                		objMap = (Map<String, Object>)objMap.get(listVarSearched.get(index));
                    	System.debug('enterParty: listVarSearched.get(index): '+listVarSearched.get(index));
                		index++;
                		if(index >= listVarSearched.size())break;
            		}
	        	
                	if(index < listVarSearched.size()) 
                	{
                    	System.debug('enterParty: size>0 #2');
                    	if(objMap.get(listVarSearched.get(index)) instanceof List<Object>)
                    	{
                        	liste = (List<Object>)objMap.get(listVarSearched.get(index));
                        	System.debug('enterParty: isList #4');
                        	index ++;
                        	if(recurrence(liste, listVarSearched, index, valueVarSearched, result) == true)
                        	{
                            	System.debug('enterParty: break reccurence #4');
                            	isFound = true;
                            	break;
                        	}
                    	}
                    	else if( objMap.get(listVarSearched.get(index)) == valueVarSearched || String.valueOf(objMap.get(listVarSearched.get(index))) == valueVarSearched)
                    	{
                        	System.debug('enterParty: break #5');
                        	isFound = true;
                        	break;
                    	}
                    	else
                    	{
                        	objMapTamp = null;
                    	}
                	}
                }
                else if( obj == valueVarSearched || String.valueOf(obj) == valueVarSearched)
            	{	
                    System.debug('enterParty: Break #6');
                    isFound = true;
  	      		  	break;
 	          	}
           		
                // S'il reste des variables dans la liste mais que
                // l'on peut pas y acccéder
               	if(index < listVarSearched.size())
                {
                	if(objMap.get(listVarSearched.get(index)) == null)
            		{
                        System.debug('enterParty: Map nulle  #1');
                  		objMapTamp = null; 
              		}
                }

                index =0;
    	    }
        }
        
        // S'il l'on n'a pas trouvé l'objet ayant la valueVarSearched
        if(valueVarSearched != null && isFound ==  false)
        {
            System.debug('enterParty: Map nulle  #2');
            objMapTamp = null;
        }

		System.debug('enterParty: fin');        
        return objMapTamp;    
  	}
    
    public static boolean recurrence(List<Object> listeObject, List<String> listVarSearched,
                                     integer index, String valueVarSearched, String mapTampString)
    {
        Map<String, Object> objMap; // Permet de stocker le map obtenu
        integer indexTamp = index; // Sauvegarde un index (pour chaque début de for)
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
                    System.debug('recurrence: size>0  #1');
                    while(objMap.get(listVarSearched.get(indexTamp)) instanceof Map<String, Object>)
              		{
                        System.debug('reccurence: isMap #1'+objMap);
               			objMap = (Map<String, Object>)objMap.get(listVarSearched.get(indexTamp));
               			indexTamp ++;
                   		if(indexTamp >= listVarSearched.size())break;
               		}
                }
        	   	
    	       	if(indexTamp < listVarSearched.size())
           	    {    
                    System.debug('recurrence: size>0  #2');
           			if(objMap.get(listVarSearched.get(indexTamp)) instanceof List<Object>)
                   	{
                       	List<Object> uneListe = (List<Object>)objMap.get(listVarSearched.get(indexTamp));
                       	indexTamp++;
                        System.debug('reccurence: isList #1'+uneListe);
            	        isFound = recurrence(uneListe, listVarSearched, indexTamp, valueVarSearched, mapTampString);

                        if(isFound == true)
                        {
                            System.debug('recurrence: Break recu #1');
                       		break;  
                        }
                   	}
                   	else
                    {
                        if( objMap.get(listVarSearched.get(indexTamp)) == valueVarSearched ||
                           String.valueOf(objMap.get(listVarSearched.get(indexTamp))) == valueVarSearched)
                      	{	
                            isFound = true;
                            System.debug('recurrence: Break #2');
                       	  	break;
                       	}
       		      	}
              	}
         	}
            else
           	{   
          		if( obj == valueVarSearched || String.valueOf(obj) == valueVarSearched)
            	{	
                    System.debug('recurrence: Break #3');
                    isFound = true;
  	      		  	break;
 	          	}
           	}
            indexTamp = index ;
        }
        return isFound;
    }

	public static boolean doesFieldExist(String objName, string fieldName)
    {
        try {
            SObject so = Schema.getGlobalDescribe().get(objName).newSObject();
            return so.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);
        }
        catch(Exception ex) {}
         
        return false;
    }

    public static boolean doesObjectExist(String objName, string fieldName, String objectID)
    {
        try
        {
            Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objName);
			Sobject genericObject = convertType.newSObject();
             
      		String query = 'SELECT Id, ' + fieldName + ' FROM '+objName+' WHERE Id =: objectID';
			genericObject = Database.query(query);
            return true;
        }
        catch(Exception ex) {}
	
		return false;        
    }
    
}
