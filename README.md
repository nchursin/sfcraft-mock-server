# Salesforce Clean Code

This library consists of several parts:

1. Trigger framework
1. Mock server
1. Logger

Each part is completely independent and can be extracted to use separately.

## Trigger framework

[Trigger Framework](../master/app/main/triggerFramework) is located in `app/main/triggerFramework` folder.

To use the framework extend the ATrigger class. The following methods exists to be overriden:

1. `protected override void initialize(List<sObject> records)`
1. `protected override void calculate(List<sObject> records)`
1. `protected override void validate(List<sObject> records)`
1. `protected override void preValidate(List<sObject> records)`
1. `protected override void afterInsert(List<sObject> records)`
1. `protected override void afterUpsert(List<sObject> records)`
1. `protected override void afterUpdate(List<sObject> records)`
1. `protected override void validateBeforeDelete(List<sObject> records)`
1. `protected override void afterDelete(List<sObject> records)`
1. `protected override void afterUndelete(List<sObject> records)`

`List<sObject> records` parameter is a list of records in a trigger. These are `new` records for insert, update, and undelete triggers, and `old` records for delete triggers.

There is also a set of helper methods:

1. `protected Boolean isFieldChanged(sObject record, Schema.SObjectField field);`
1. `protected Boolean isFieldChangedTo(sObject record, Schema.SObjectField field, Object checkValue);`
1. `protected Boolean isFieldChangedFrom(sObject record, Schema.SObjectField field, Object checkValue);`
1. `protected sObject getOldRecord(sObject record);`
1. `protected Object getOldFieldValue(sObject record, Schema.SObjectField field);`

Finally the trigger framework supports partial trigger disablement.

1. `public static void disable(Schema.SObjectType sobjType, TriggerOperation triggerOper);`
1. `public static void disableAll(Schema.SObjectType sobjType);`
1. `public static void disableAll();`
1. `public static void enableAll();`

`TriggerOperation` here is a standard Salesforce `TriggerOperation` enum;

### Example info
For usage examples take a look at the [ATrigger test class](../master/app/main/triggerFramework/tests/Test_ATrigger.cls).

Another word on tests: I used account object for testing, which may not suite you. In order to change this you need:

1. Create a trigger for object you want to use and paste the code from `app/main/triggerFramework/triggers/TestTrigger.trigger` to you newly created trigger.
1. Update the following variables in `app/main/triggerFramework/tests/Test_ATrigger.cls` if needed:
```java
private static final sObject TEST_RECORD = new Account(Name = 'Test_ATrigger');
private static final String TEST_FIELD_NAME = 'Name';
private static final Object TEST_FIELD_CHANGED_VALUE = 'Changed Name';
```

## Mock server

Mock server is an implementation of `HttpCalloutMock` which can help you make your mocks more organized.

The mock server framework consists of the following parts:

1. `MockServer` class - the actual mock server.
1. `MockServer.APIResource` class - a class which actually represents a single resource available at some endpoint.
1. `MockServer.RequestAsserter` interface - implement it and add to a resource to run assertion "on server side".
1. `MockServer.HttpMockable` interface - implement it by class that represents you server response. E.g. you parse body into a class `ServerResponseBody`. Then you need to implement the `MockServer.HttpMockable` by it to be teach the `MockServer` to respond with it.
1. `MockServer.MockServerException` - exception that is thrown by `MockServer` in case something went wrong, e.g. misconfiguration.

### Example info
For usage examples take a look at the [`MockServer` test class](../master/app/main/mockServer/tests/Test_MockServer.cls).

## Logger

Documenting in progress...