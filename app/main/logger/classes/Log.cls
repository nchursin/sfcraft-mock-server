public with sharing class Log {
    public static final String TYPE_ERROR = 'Error';

    private String type;
    private String errorType;
    private String message;
    private String stackTrace;
    private String scope;
    
    private Log(Exception e) {
        this.type = TYPE_ERROR;
        this.errorType = e.getTypeName();
        this.message = e.getMessage();
        this.stackTrace = e.getStackTraceString();
    }

    public static Log createLog(Exception ex, String scope) {
        Log l = new Log(ex);
        l.scope = scope;
        return l;
    }

    public String getType() {
        return this.type;
    }

    public String getErrorType() {
        return this.errorType;
    }

    public String getMessage() {
        return this.message;
    }

    public String getDetails() {
        return this.stackTrace;
    }

    public String getScope() {
        return this.scope;
    }

    public Log__c unwrap() {
        return new Log__c(
            Type__c = this.getType(),
            ErrorType__c = this.getErrorType(),
            Message__c = this.getMessage(),
            Details__c = this.getDetails(),
            Scope__c = this.getScope()
        );
    }
}
