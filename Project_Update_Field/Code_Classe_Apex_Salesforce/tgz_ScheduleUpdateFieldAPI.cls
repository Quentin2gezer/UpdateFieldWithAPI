global class tgz_ScheduleUpdateField implements Schedulable {
   
    global void execute(SchedulableContext SC) {
  		tgz_BatchUpdateField b = new tgz_BatchUpdateField(); 
      	database.executebatch(b);
   }
}