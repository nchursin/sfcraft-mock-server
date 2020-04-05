public with sharing class Logger {
    private String scopeClass;
    private String scopeMethod;

    public Logger() {

    }

    public Log log(Exception e) {
        return Log.createLog(e, this.getScope());
    }

    public void setClass(String className) {
        this.scopeClass = className;
    }

    public void setMethod(String methodName) {
        this.scopeMethod = methodName;
    }

    public String getScope() {
        return String.join(
            new List<String> {
                this.scopeClass,
                this.scopeMethod
            },
            '.'
        );
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
