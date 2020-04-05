public with sharing class Logger {
    private String scopeClass;
    private String scopeMethod;

    private List<Log> logs;

    public Logger() {
        this.logs = new List<Log>();
    }

    public Log log(Exception e) {
        Log l = Log.createLog(e, this.getScope());
        logs.add(l);
        return l;
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
    
    public void insertLogs() {
        this.insertLogs(this.logs);
    }

    public void insertLogs(List<Log> logs) {
        List<Log__c> toInsert = unwrapList(logs);
        insert toInsert;
    }

    private List<Log__c> unwrapList(List<Log> logs) {
        List<Log__c> unwrapped = new List<Log__c>();
        for (Log logWrapper : logs) {
            Log__c logRecord = logWrapper.unwrap();
            unwrapped.add(logRecord);
        }
        return unwrapped;
    }
}
