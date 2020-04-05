public with sharing class Logger {
    public Logger() {

    }

    public Log log(Exception e) {
        return Log.createLog(e);
    }
    
    public void insertLogs(List<Log> logs) {
        List<Log__c> toInsert = new List<Log__c>();
        for (Log logWrapper : logs) {
            Log__c logRecord = logWrapper.unwrap();
            toInsert.add(logRecord);
        }
        insert toInsert;
    }
}
