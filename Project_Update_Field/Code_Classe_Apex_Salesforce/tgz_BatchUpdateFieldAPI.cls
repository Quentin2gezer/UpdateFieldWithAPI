global class tgz_BatchUpdateField implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT id, Name, objectName__c, objectID__c, fieldName__c, urlApi__c FROM updateCustomFieldApiCS__c WHERE Update_Every_Hour__c= true';
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<updateCustomFieldApiCS__c> listCS)
    {
         tgz_componentUpdateFieldAPI.updateObject(listCS);
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
}