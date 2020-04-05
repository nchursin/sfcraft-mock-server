@isTest
private class Test_Logger {
    private class TestException extends Exception {}

    @isTest
    private static void testLogException() {
        Logger logger = new Logger();
        Exception e = new TestException('Test exception');
        Log errorLog = logger.log(e);
        System.assertEquals(Log.TYPE_ERROR, errorLog.getType());
        System.assertEquals(e.getTypeName(), errorLog.getErrorType());
        System.assertEquals(e.getMessage(), errorLog.getMessage());
        System.assertEquals(e.getStackTraceString(), errorLog.getDetails());
    }

    @isTest
    private static void testInsertLogs() {
        Logger logger = new Logger();
        Exception e = new TestException('Test exception');
        Log errorLog = logger.log(e);
        logger.insertLogs(new List<Log>{ errorLog });
        List<Log__c> logs = [
            SELECT Id, Name, Details__c, Message__c, Type__c, ErrorType__c 
            FROM Log__c
            ORDER BY CreatedDate
            DESC LIMIT 1
        ];
        System.assertEquals(1, logs.size());
        Log__c logRecord = logs[0];
        System.assertEquals(errorLog.getType(), logRecord.Type__c);
        System.assertEquals(errorLog.getErrorType(), logRecord.ErrorType__c);
        System.assertEquals(errorLog.getMessage(), logRecord.Message__c);
        System.assertEquals(errorLog.getDetails(), logRecord.Details__c);
    }
}
